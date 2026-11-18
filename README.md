# Orçado × Realizado com SQL

Análise de orçado versus realizado de um ano de DRE, feita só com SQL (SQLite). Principal descoberta: três lançamentos duplicados inflaram o resultado antes do IR. Sem eles, o ano fecha 30,0% abaixo do orçado, e não 11,1%.

> **Aviso:** a empresa (Atlas Distribuidora) e todos os dados são fictícios, gerados por script (`gerar_dados.py`).

## Contexto de negócio

A Atlas Distribuidora é uma empresa fictícia. O período é o ano de 2025. A base tem plano de contas, centros de custo, orçamento mensal e razão contábil. As consultas respondem:

- Quanto foi realizado em cada grupo da DRE?
- Onde o realizado se afastou do orçado, por conta e por centro de custo?
- Como evoluíram as margens e o resultado, mês a mês e acumulado?
- Quais despesas estouram de forma recorrente?
- Os dados são confiáveis? Qual o efeito de duplicidades e de lançamentos sem centro de custo?

## Descoberta principal: duplicidades distorcem o resultado

A consulta 09 encontrou 3 lançamentos duplicados, somando R$ 177.188,82 em valor bruto: 2 vendas de dezembro (R$ 176.573,10) e 1 despesa de Viagens de junho (R$ 615,72). O efeito líquido no resultado é de R$ 175.957,38. A consulta 11 compara as visões:

| Visão | Venda de mercadorias | Resultado antes do IR | Contra o orçado |
|---|---|---|---|
| Orçado | 14.640.000,00 | 932.400,00 | - |
| Realizado (bruto) | 14.716.402,42 | 828.616,19 | −11,1% |
| Realizado (sem duplicidades) | 14.539.829,32 | 652.658,81 | −30,0% (−R$ 279.741,19) |

- **Venda de mercadorias:** parecia +0,5% sobre o orçado e, sem duplicidades, fica em −0,7%.
- **Dezembro:** o resultado bruto (R$ 247.148,22 contra R$ 128.100,00 orçados) parecia uma recuperação, mas vem das duas vendas duplicadas. Sem elas, dezembro fica em R$ 70.575,12, abaixo do orçado.
- **Acumulado (consulta 06):** a visão bruta fecha o ano em −R$ 103.783,81. Essa consulta só traz a versão bruta. O valor sem duplicidades vem da consulta 11.
- **Margem:** a margem bruta mensal (consulta 03, realizado bruto) caiu de 37,00% em janeiro para 30,30% em novembro. O CMV ficou R$ 150.931,80 acima do orçado (+1,9%) com vendas abaixo do orçado, o que pressiona a margem.

## Desvios operacionais

Contas com desvio desfavorável no ano (consulta 02) e meses seguidos com estouro acima de 10% (consulta 10):

| Conta | Orçado | Realizado | Variação | Meses seguidos > 10% |
|---|---|---|---|---|
| Software e licenças | 108.000,00 | 124.816,63 | +15,6% | 6 (jul a dez) |
| Fretes sobre vendas | 585.600,00 | 634.643,24 | +8,4% | 3 (out a dez) |
| Marketing e publicidade | 300.000,00 | 320.407,82 | +6,8% | 2 (out e nov) |
| Custo das mercadorias vendidas | 8.052.000,00 | 8.202.931,80 | +1,9% | não aparece |

- **Maiores estouros mensais (consulta 05):** Fretes em novembro (R$ 88.636,48 contra R$ 64.800,00, +36,8%) e Marketing em novembro (R$ 38.921,24 contra R$ 25.000,00, +55,7%).
- **Centros de custo (consulta 04):** Operações fechou R$ 196.743,99 acima do orçado (+2,1%); TI, +4,1%.
- **Resultado mensal (consulta 06):** em outubro foi R$ 12.612,91 contra R$ 84.900,00 orçados. O acumulado bruto está abaixo do orçado desde março (−R$ 6.988,23) e chegou a −R$ 222.832,03 em novembro, antes das vendas duplicadas de dezembro.
- **Viagens (nota):** ficou abaixo do orçado, mas o valor da consulta 02 (−29,8%) inclui a duplicidade de R$ 615,72. Sem ela, fica em R$ 49.914,16 (−30,7% contra R$ 72.000,00).
- **Sem centro de custo (consulta 09):** 2 lançamentos de Serviços de terceiros, R$ 3.546,65 no total.

## Recomendações de negócio

1. **Validar as duplicidades com o documento de origem.** Confirmar se os 3 lançamentos são mesmo duplicados antes de adotar R$ 652.658,81 como resultado de referência, e incluir a auditoria da consulta 09 no fechamento.
2. **Investigar a causa do estouro recorrente de Software e licenças, Fretes e Marketing.** Software estourou mais de 10% por 6 meses seguidos. O alerta da consulta 10 pode sinalizar o desvio mais cedo.
3. **Acompanhar CMV e fretes em Operações junto com a margem.** O CMV está acima do orçado com vendas abaixo dele, e a margem bruta caiu ao longo do ano. Operações concentra o maior desvio em reais por centro de custo.

## Técnicas de SQL demonstradas

| Consulta | Conceitos |
|---|---|
| 01 `realizado_por_grupo` | SELECT, JOIN, GROUP BY, COUNT, SUM, ORDER BY |
| 02 `orcado_vs_realizado_por_conta` | CTE (WITH), LEFT JOIN, COALESCE, CASE WHEN |
| 03 `dre_mensal` | strftime, pivot com SUM(CASE WHEN), CTEs encadeadas, cálculo de margens |
| 04 `despesas_por_centro_custo` | WHERE antes do GROUP BY, LEFT JOIN para não perder linhas, tratamento de NULL |
| 05 `maiores_estouros` | JOIN com USING em várias colunas, filtro por grupo, ORDER BY + LIMIT |
| 06 `resultado_acumulado` | Função de janela SUM() OVER (ORDER BY ...) |
| 07 `receita_liquida_mes_a_mes` | LAG(), cláusula WINDOW reutilizável |
| 08 `ranking_estouros_por_centro` | RANK() OVER (PARTITION BY ...) |
| 09 `qualidade_dos_dados` | GROUP BY + HAVING, IS NULL, UNION ALL |
| 10 `estouros_recorrentes` | Gaps and islands com ROW_NUMBER() |
| 11 `impacto_da_limpeza` | Deduplicação com ROW_NUMBER() OVER (PARTITION BY ...), UNION ALL de visões |

## Modelo de dados

Definido em `schema.sql`. Os valores são sempre positivos; a coluna `natureza` indica se a conta soma ou subtrai na DRE.

- `plano_contas`: contas, com o grupo da DRE e a natureza (receita ou despesa).
- `centros_custo`: centros de custo da empresa.
- `orcamento`: orçamento mensal por conta e centro de custo.
- `lancamentos`: razão contábil, um lançamento realizado por linha (o centro de custo pode vir vazio).

## Como executar

Requer Python 3, sem dependências externas.

```bash
python gerar_dados.py   # cria os CSVs e o banco SQLite em dados/
python executar.py      # roda as consultas de sql/ e grava os resultados em resultados/
```

Os resultados completos estão em [`resultados/RESULTADOS.md`](resultados/RESULTADOS.md).

## Estrutura de pastas

```
01-orcado-vs-realizado-sql/
├── GUIA_DE_ESTUDO.md # guia de estudo do projeto
├── schema.sql        # modelo de dados
├── gerar_dados.py    # gera a base fictícia (CSVs e atlas.db)
├── executar.py       # executa as consultas e grava os resultados
├── dados/            # CSVs e banco SQLite gerados
├── sql/              # 11 consultas (01 a 11)
└── resultados/       # um CSV por consulta e RESULTADOS.md
