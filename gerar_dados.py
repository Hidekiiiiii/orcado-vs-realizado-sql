"""
Gera a base financeira SIMULADA da "Atlas Distribuidora" (empresa fictícia) para 2025.

Saídas:
  dados/plano_contas.csv, dados/centros_custo.csv, dados/orcamento.csv, dados/lancamentos.csv
  dados/atlas.db  (banco SQLite com as 4 tabelas)

Os dados são aleatórios, mas reprodutíveis (semente fixa), e trazem "histórias" plantadas
para a análise descobrir: queda de receita, estouros de despesa e problemas de qualidade.
Usa apenas a biblioteca padrão do Python.
"""
import calendar
import csv
import random
import sqlite3
from pathlib import Path

SEMENTE = 42
ANO = 2025
RAIZ = Path(__file__).resolve().parent
PASTA_DADOS = RAIZ / "dados"

# (conta_id, conta, grupo da DRE, natureza)
PLANO_CONTAS = [
    ("3.1.01", "Venda de mercadorias", "Receita Bruta", "receita"),
    ("3.1.02", "Prestação de serviços", "Receita Bruta", "receita"),
    ("3.2.01", "Impostos sobre vendas", "Deduções", "despesa"),
    ("3.2.02", "Devoluções", "Deduções", "despesa"),
    ("4.1.01", "Custo das mercadorias vendidas", "CMV", "despesa"),
    ("4.2.01", "Salários e encargos", "Despesas com Pessoal", "despesa"),
    ("4.2.02", "Benefícios", "Despesas com Pessoal", "despesa"),
    ("4.3.01", "Marketing e publicidade", "Despesas Comerciais", "despesa"),
    ("4.3.02", "Comissões de vendas", "Despesas Comerciais", "despesa"),
    ("4.3.03", "Fretes sobre vendas", "Despesas Comerciais", "despesa"),
    ("4.4.01", "Aluguel", "Despesas Administrativas", "despesa"),
    ("4.4.02", "Energia e utilidades", "Despesas Administrativas", "despesa"),
    ("4.4.03", "Software e licenças", "Despesas Administrativas", "despesa"),
    ("4.4.04", "Serviços de terceiros", "Despesas Administrativas", "despesa"),
    ("4.4.05", "Viagens", "Despesas Administrativas", "despesa"),
    ("5.1.01", "Receitas financeiras", "Resultado Financeiro", "receita"),
    ("5.1.02", "Despesas financeiras", "Resultado Financeiro", "despesa"),
]

CENTROS_CUSTO = [(1, "Comercial"), (2, "Operações"), (3, "Administrativo"), (4, "TI")]

# Sazonalidade da venda (varejo: pico em novembro/dezembro)
SAZONALIDADE = {1: 0.85, 2: 0.85, 3: 0.95, 4: 0.95, 5: 1.00, 6: 1.00,
                7: 0.95, 8: 1.00, 9: 1.00, 10: 1.05, 11: 1.35, 12: 1.25}
VENDA_BASE = 1_200_000.00
SERVICOS_BASE = 90_000.00

# Orçamento mensal fixo por (conta, centro de custo)
ORCAMENTO_FIXO = {
    ("4.2.01", 1): 35_000, ("4.2.01", 2): 30_000, ("4.2.01", 3): 22_000, ("4.2.01", 4): 18_000,
    ("4.2.02", 1): 7_000, ("4.2.02", 2): 6_000, ("4.2.02", 3): 4_500, ("4.2.02", 4): 3_500,
    ("4.3.01", 1): 25_000,
    ("4.4.01", 3): 18_000,
    ("4.4.02", 2): 8_000,
    ("4.4.03", 4): 9_000,
    ("4.4.04", 3): 5_000, ("4.4.04", 4): 7_000,
    ("4.4.05", 1): 4_000, ("4.4.05", 3): 2_000,
    ("5.1.01", 3): 3_000,
    ("5.1.02", 3): 12_000,
}

# Contas proporcionais: (conta, centro de custo, base, % orçado)
PROPORCIONAIS = [
    ("3.2.01", 1, "receita_bruta", 0.18),
    ("3.2.02", 1, "venda", 0.02),
    ("4.1.01", 2, "venda", 0.55),
    ("4.3.02", 1, "receita_bruta", 0.03),
    ("4.3.03", 2, "venda", 0.04),
]


def ruido(desvio=0.03):
    return random.gauss(1.0, desvio)


def fator_real_venda(mes):
    """Histórias da receita: queda em março/abril; Black Friday acima do esperado."""
    if mes in (3, 4):
        return 0.88 * ruido(0.02)
    if mes == 11:
        return 1.06 * ruido(0.02)
    return ruido(0.02)


def percentual_real(conta, mes, percentual_orcado):
    """Histórias das contas proporcionais."""
    if conta == "4.1.01" and mes >= 7:      # reajuste de fornecedor no 2º semestre
        return 0.57
    if conta == "4.3.03" and mes >= 10:     # frete mais caro no 4º trimestre
        return 0.052
    return percentual_orcado


def fator_real_fixo(conta, mes):
    """Histórias das despesas fixas."""
    if conta == "4.3.01" and mes == 10:     # campanha de Black Friday
        return 1.45 * ruido(0.02)
    if conta == "4.3.01" and mes == 11:
        return 1.60 * ruido(0.02)
    if conta == "4.4.03" and mes >= 7:      # nova licença de ERP a partir de julho
        return 1.30 * ruido(0.01)
    if conta == "4.4.05":                   # política de corte de viagens
        return 0.70 * ruido(0.05)
    if conta.startswith("4.2."):            # folha é estável
        return ruido(0.01)
    return ruido(0.04)


def dividir_em_lancamentos(valor, mes, n):
    """Divide um valor mensal em n lançamentos com datas aleatórias no mês."""
    pesos = [random.uniform(0.5, 1.5) for _ in range(n)]
    total_pesos = sum(pesos)
    partes = [round(valor * p / total_pesos, 2) for p in pesos]
    partes[-1] = round(valor - sum(partes[:-1]), 2)  # garante que a soma bate
    ultimo_dia = calendar.monthrange(ANO, mes)[1]
    return [(f"{ANO}-{mes:02d}-{random.randint(1, ultimo_dia):02d}", parte) for parte in partes]


def gerar():
    random.seed(SEMENTE)
    nomes_contas = {c[0]: c[1] for c in PLANO_CONTAS}
    orcamento = []      # (ano_mes, conta_id, cc_id, valor)
    reais = []          # (mes, conta_id, cc_id, valor_mensal_real)

    for mes in range(1, 13):
        ano_mes = f"{ANO}-{mes:02d}"

        venda_orc = VENDA_BASE * SAZONALIDADE[mes]
        servicos_orc = SERVICOS_BASE
        venda_real = venda_orc * fator_real_venda(mes)
        servicos_real = servicos_orc * ruido(0.05)
        bases_orc = {"venda": venda_orc, "receita_bruta": venda_orc + servicos_orc}
        bases_real = {"venda": venda_real, "receita_bruta": venda_real + servicos_real}

        orcamento += [(ano_mes, "3.1.01", 1, venda_orc), (ano_mes, "3.1.02", 1, servicos_orc)]
        reais += [(mes, "3.1.01", 1, venda_real), (mes, "3.1.02", 1, servicos_real)]

        for conta, cc, base, pct in PROPORCIONAIS:
            orcamento.append((ano_mes, conta, cc, bases_orc[base] * pct))
            pct_real = percentual_real(conta, mes, pct)
            reais.append((mes, conta, cc, bases_real[base] * pct_real * ruido(0.01)))

        for (conta, cc), valor in ORCAMENTO_FIXO.items():
            orcamento.append((ano_mes, conta, cc, float(valor)))
            reais.append((mes, conta, cc, valor * fator_real_fixo(conta, mes)))

    # Lançamentos individuais (o "realizado" vem do razão, não de um total pronto)
    lancamentos = []
    for mes, conta, cc, valor in reais:
        n = random.randint(15, 25) if conta == "3.1.01" else random.randint(1, 4)
        for k, (data, parte) in enumerate(dividir_em_lancamentos(valor, mes, n), start=1):
            descricao = f"{nomes_contas[conta]} - doc {random.randint(10000, 99999)}"
            lancamentos.append([data, conta, cc, descricao, parte])

    # Problemas de qualidade plantados: 3 duplicidades e 2 lançamentos sem centro de custo
    for linha in random.sample(lancamentos, 3):
        lancamentos.append(list(linha))
    terceiros = [l for l in lancamentos if l[1] == "4.4.04"]
    for linha in random.sample(terceiros, 2):
        linha[2] = None

    lancamentos.sort(key=lambda l: (l[0], l[1]))
    lancamentos = [[i] + l for i, l in enumerate(lancamentos, start=1)]
    orcamento = [(a, c, cc, round(v, 2)) for a, c, cc, v in orcamento]
    return orcamento, lancamentos


def salvar_csv(nome, cabecalho, linhas):
    with open(PASTA_DADOS / nome, "w", newline="", encoding="utf-8") as f:
        escritor = csv.writer(f)
        escritor.writerow(cabecalho)
        escritor.writerows(linhas)


def criar_banco(orcamento, lancamentos):
    caminho = PASTA_DADOS / "atlas.db"
    if caminho.exists():
        caminho.unlink()  # o banco é sempre recriado a partir do script
    con = sqlite3.connect(caminho)
    con.executescript((RAIZ / "schema.sql").read_text(encoding="utf-8"))
    con.executemany("INSERT INTO plano_contas VALUES (?, ?, ?, ?)", PLANO_CONTAS)
    con.executemany("INSERT INTO centros_custo VALUES (?, ?)", CENTROS_CUSTO)
    con.executemany("INSERT INTO orcamento VALUES (?, ?, ?, ?)", orcamento)
    con.executemany("INSERT INTO lancamentos VALUES (?, ?, ?, ?, ?, ?)", lancamentos)
    con.commit()
    con.close()


def main():
    PASTA_DADOS.mkdir(exist_ok=True)
    orcamento, lancamentos = gerar()
    salvar_csv("plano_contas.csv", ["conta_id", "conta", "grupo", "natureza"], PLANO_CONTAS)
    salvar_csv("centros_custo.csv", ["cc_id", "centro_custo"], CENTROS_CUSTO)
    salvar_csv("orcamento.csv", ["ano_mes", "conta_id", "cc_id", "valor"], orcamento)
    salvar_csv("lancamentos.csv", ["lancamento_id", "data", "conta_id", "cc_id", "descricao", "valor"], lancamentos)
    criar_banco(orcamento, lancamentos)
    print(f"Orçamento: {len(orcamento)} linhas | Lançamentos: {len(lancamentos)} linhas")
    print(f"Banco criado em {PASTA_DADOS / 'atlas.db'}")


if __name__ == "__main__":
    main()
