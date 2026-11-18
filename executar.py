"""
Executa todas as consultas de sql/ no banco dados/atlas.db.

Para cada consulta, salva o resultado em resultados/<nome>.csv e monta
resultados/RESULTADOS.md com todas as tabelas, para leitura direta no GitHub.
Usa apenas a biblioteca padrão do Python.
"""
import csv
import sqlite3
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent
BANCO = RAIZ / "dados" / "atlas.db"
PASTA_SQL = RAIZ / "sql"
PASTA_RESULTADOS = RAIZ / "resultados"


def formatar(valor):
    """Formata números no padrão brasileiro (1.234,56) para o relatório em markdown."""
    if isinstance(valor, float):
        if abs(valor) < 0.005:
            valor = 0.0  # evita "-0,00"
        return f"{valor:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return "" if valor is None else str(valor)


def tabela_markdown(colunas, linhas):
    saida = ["| " + " | ".join(colunas) + " |", "|" + "---|" * len(colunas)]
    saida += ["| " + " | ".join(formatar(v) for v in linha) + " |" for linha in linhas]
    return "\n".join(saida)


def main():
    if not BANCO.exists():
        sys.exit("Banco não encontrado. Rode antes: python gerar_dados.py")
    PASTA_RESULTADOS.mkdir(exist_ok=True)
    con = sqlite3.connect(BANCO)
    relatorio = ["# Resultados das consultas", "",
                 "Gerado automaticamente por `executar.py`. Valores em R$.", ""]

    for arquivo in sorted(PASTA_SQL.glob("*.sql")):
        sql = arquivo.read_text(encoding="utf-8")
        cursor = con.execute(sql)
        colunas = [c[0] for c in cursor.description]
        linhas = cursor.fetchall()

        with open(PASTA_RESULTADOS / f"{arquivo.stem}.csv", "w", newline="", encoding="utf-8") as f:
            escritor = csv.writer(f)
            escritor.writerow(colunas)
            escritor.writerows(linhas)

        titulo = sql.splitlines()[0].lstrip("- ").strip()   # 1ª linha do .sql é a pergunta
        relatorio += [f"## {titulo}", "", f"Consulta: [`sql/{arquivo.name}`](../sql/{arquivo.name})", "",
                      tabela_markdown(colunas, linhas), ""]
        print(f"OK  {arquivo.name}: {len(linhas)} linhas")

    con.close()
    (PASTA_RESULTADOS / "RESULTADOS.md").write_text("\n".join(relatorio), encoding="utf-8")
    print(f"Relatório salvo em {PASTA_RESULTADOS / 'RESULTADOS.md'}")


if __name__ == "__main__":
    main()
