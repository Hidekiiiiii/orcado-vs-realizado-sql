# Resultados das consultas

Gerado automaticamente por `executar.py`. Valores em R$.

## 01 | Quanto foi realizado em cada grupo da DRE no ano?

Consulta: [`sql/01_realizado_por_grupo.sql`](../sql/01_realizado_por_grupo.sql)

| grupo | qtd_lancamentos | realizado |
|---|---|---|
| Receita Bruta | 268 | 15.818.911,54 |
| Deduções | 58 | 3.110.644,25 |
| CMV | 34 | 8.202.931,80 |
| Despesas com Pessoal | 238 | 1.511.663,78 |
| Despesas Comerciais | 95 | 1.424.221,15 |
| Despesas Administrativas | 215 | 631.599,63 |
| Resultado Financeiro | 51 | 181.582,06 |

## 02 | Orçado × realizado no ano, por conta, com avaliação favorável/desfavorável

Consulta: [`sql/02_orcado_vs_realizado_por_conta.sql`](../sql/02_orcado_vs_realizado_por_conta.sql)

| conta_id | conta | natureza | orcado | realizado | variacao | variacao_pct | avaliacao |
|---|---|---|---|---|---|---|---|
| 3.1.01 | Venda de mercadorias | receita | 14.640.000,00 | 14.716.402,42 | 76.402,42 | 0,50 | favorável |
| 3.1.02 | Prestação de serviços | receita | 1.080.000,00 | 1.102.509,12 | 22.509,12 | 2,10 | favorável |
| 3.2.01 | Impostos sobre vendas | despesa | 2.829.600,00 | 2.818.835,80 | -10.764,20 | -0,40 | favorável |
| 3.2.02 | Devoluções | despesa | 292.800,00 | 291.808,45 | -991,55 | -0,30 | favorável |
| 4.1.01 | Custo das mercadorias vendidas | despesa | 8.052.000,00 | 8.202.931,80 | 150.931,80 | 1,90 | desfavorável |
| 4.2.01 | Salários e encargos | despesa | 1.260.000,00 | 1.259.213,50 | -786,50 | -0,10 | favorável |
| 4.2.02 | Benefícios | despesa | 252.000,00 | 252.450,28 | 450,28 | 0,20 | desfavorável |
| 4.3.01 | Marketing e publicidade | despesa | 300.000,00 | 320.407,82 | 20.407,82 | 6,80 | desfavorável |
| 4.3.02 | Comissões de vendas | despesa | 471.600,00 | 469.170,09 | -2.429,91 | -0,50 | favorável |
| 4.3.03 | Fretes sobre vendas | despesa | 585.600,00 | 634.643,24 | 49.043,24 | 8,40 | desfavorável |
| 4.4.01 | Aluguel | despesa | 216.000,00 | 214.610,83 | -1.389,17 | -0,60 | favorável |
| 4.4.02 | Energia e utilidades | despesa | 96.000,00 | 95.787,29 | -212,71 | -0,20 | favorável |
| 4.4.03 | Software e licenças | despesa | 108.000,00 | 124.816,63 | 16.816,63 | 15,60 | desfavorável |
| 4.4.04 | Serviços de terceiros | despesa | 144.000,00 | 145.855,00 | 1.855,00 | 1,30 | desfavorável |
| 4.4.05 | Viagens | despesa | 72.000,00 | 50.529,88 | -21.470,12 | -29,80 | favorável |
| 5.1.01 | Receitas financeiras | receita | 36.000,00 | 36.173,66 | 173,66 | 0,50 | favorável |
| 5.1.02 | Despesas financeiras | despesa | 144.000,00 | 145.408,40 | 1.408,40 | 1,00 | desfavorável |

## 03 | DRE gerencial mensal (realizado) com margens

Consulta: [`sql/03_dre_mensal.sql`](../sql/03_dre_mensal.sql)

| ano_mes | receita_bruta | receita_liquida | lucro_bruto | margem_bruta_pct | resultado_operacional | margem_operacional_pct | resultado_antes_ir |
|---|---|---|---|---|---|---|---|
| 2025-01 | 1.106.282,49 | 886.889,31 | 328.219,71 | 37,00 | 53.002,40 | 6,00 | 43.642,01 |
| 2025-02 | 1.106.785,85 | 886.609,25 | 334.524,24 | 37,70 | 59.726,12 | 6,70 | 50.995,22 |
| 2025-03 | 1.086.017,53 | 870.683,66 | 328.587,89 | 37,70 | 53.878,01 | 6,20 | 45.074,54 |
| 2025-04 | 1.080.800,39 | 867.642,62 | 320.993,69 | 37,00 | 46.270,05 | 5,30 | 37.676,68 |
| 2025-05 | 1.328.751,49 | 1.066.325,80 | 386.325,96 | 36,20 | 95.285,22 | 8,90 | 85.715,17 |
| 2025-06 | 1.300.351,78 | 1.041.301,80 | 389.861,90 | 37,40 | 100.081,17 | 9,60 | 90.717,01 |
| 2025-07 | 1.262.818,05 | 1.014.482,63 | 342.406,42 | 33,80 | 51.352,88 | 5,10 | 42.278,54 |
| 2025-08 | 1.279.327,65 | 1.024.177,31 | 344.993,38 | 33,70 | 55.347,59 | 5,40 | 46.579,90 |
| 2025-09 | 1.341.792,98 | 1.074.471,11 | 364.751,04 | 33,90 | 71.241,29 | 6,60 | 61.593,78 |
| 2025-10 | 1.352.928,48 | 1.083.696,40 | 343.392,51 | 31,70 | 21.303,48 | 2,00 | 12.612,91 |
| 2025-11 | 1.790.911,66 | 1.431.296,64 | 433.537,47 | 30,30 | 73.982,99 | 5,20 | 64.582,21 |
| 2025-12 | 1.782.143,19 | 1.460.690,76 | 587.741,28 | 40,20 | 256.379,73 | 17,60 | 247.148,22 |

## 04 | Custos e despesas por centro de custo: orçado × realizado

Consulta: [`sql/04_despesas_por_centro_custo.sql`](../sql/04_despesas_por_centro_custo.sql)

| centro_custo | orcado | realizado | variacao | variacao_pct |
|---|---|---|---|---|
| Comercial | 4.446.000,00 | 4.437.791,98 | -8.208,02 | -0,20 |
| Operações | 9.165.600,00 | 9.362.343,99 | 196.743,99 | 2,10 |
| Administrativo | 762.000,00 | 754.410,95 | -7.589,05 | -1,00 |
| TI | 450.000,00 | 468.375,44 | 18.375,44 | 4,10 |
| (sem centro de custo) | 0,00 | 3.546,65 | 3.546,65 |  |

## 05 | Top 10 estouros mensais em despesas operacionais (as que a gestão controla)

Consulta: [`sql/05_maiores_estouros.sql`](../sql/05_maiores_estouros.sql)

| ano_mes | conta | orcado | realizado | estouro | estouro_pct |
|---|---|---|---|---|---|
| 2025-11 | Fretes sobre vendas | 64.800,00 | 88.636,48 | 23.836,48 | 36,80 |
| 2025-12 | Fretes sobre vendas | 60.000,00 | 78.058,02 | 18.058,02 | 30,10 |
| 2025-10 | Fretes sobre vendas | 50.400,00 | 66.334,75 | 15.934,75 | 31,60 |
| 2025-11 | Marketing e publicidade | 25.000,00 | 38.921,24 | 13.921,24 | 55,70 |
| 2025-10 | Marketing e publicidade | 25.000,00 | 35.411,19 | 10.411,19 | 41,60 |
| 2025-08 | Software e licenças | 9.000,00 | 11.965,12 | 2.965,12 | 32,90 |
| 2025-09 | Software e licenças | 9.000,00 | 11.755,28 | 2.755,28 | 30,60 |
| 2025-07 | Software e licenças | 9.000,00 | 11.713,89 | 2.713,89 | 30,20 |
| 2025-11 | Software e licenças | 9.000,00 | 11.691,68 | 2.691,68 | 29,90 |
| 2025-10 | Software e licenças | 9.000,00 | 11.661,01 | 2.661,01 | 29,60 |

## 06 | Resultado mensal e acumulado no ano (YTD): orçado × realizado

Consulta: [`sql/06_resultado_acumulado.sql`](../sql/06_resultado_acumulado.sql)

| ano_mes | resultado_orcado | resultado_realizado | acumulado_orcado | acumulado_realizado | diferenca_acumulada |
|---|---|---|---|---|---|
| 2025-01 | 41.700,00 | 43.642,01 | 41.700,00 | 43.642,01 | 1.942,01 |
| 2025-02 | 41.700,00 | 50.995,22 | 83.400,00 | 94.637,23 | 11.237,23 |
| 2025-03 | 63.300,00 | 45.074,54 | 146.700,00 | 139.711,77 | -6.988,23 |
| 2025-04 | 63.300,00 | 37.676,68 | 210.000,00 | 177.388,45 | -32.611,55 |
| 2025-05 | 74.100,00 | 85.715,17 | 284.100,00 | 263.103,62 | -20.996,38 |
| 2025-06 | 74.100,00 | 90.717,01 | 358.200,00 | 353.820,63 | -4.379,37 |
| 2025-07 | 63.300,00 | 42.278,54 | 421.500,00 | 396.099,17 | -25.400,83 |
| 2025-08 | 74.100,00 | 46.579,90 | 495.600,00 | 442.679,07 | -52.920,93 |
| 2025-09 | 74.100,00 | 61.593,78 | 569.700,00 | 504.272,85 | -65.427,15 |
| 2025-10 | 84.900,00 | 12.612,91 | 654.600,00 | 516.885,76 | -137.714,24 |
| 2025-11 | 149.700,00 | 64.582,21 | 804.300,00 | 581.467,97 | -222.832,03 |
| 2025-12 | 128.100,00 | 247.148,22 | 932.400,00 | 828.616,19 | -103.783,81 |

## 07 | Receita líquida realizada: variação contra o mês anterior

Consulta: [`sql/07_receita_liquida_mes_a_mes.sql`](../sql/07_receita_liquida_mes_a_mes.sql)

| ano_mes | receita_liquida | mes_anterior | variacao_pct |
|---|---|---|---|
| 2025-01 | 886.889,31 |  |  |
| 2025-02 | 886.609,25 | 886.889,31 | 0,00 |
| 2025-03 | 870.683,66 | 886.609,25 | -1,80 |
| 2025-04 | 867.642,62 | 870.683,66 | -0,30 |
| 2025-05 | 1.066.325,80 | 867.642,62 | 22,90 |
| 2025-06 | 1.041.301,80 | 1.066.325,80 | -2,30 |
| 2025-07 | 1.014.482,63 | 1.041.301,80 | -2,60 |
| 2025-08 | 1.024.177,31 | 1.014.482,63 | 1,00 |
| 2025-09 | 1.074.471,11 | 1.024.177,31 | 4,90 |
| 2025-10 | 1.083.696,40 | 1.074.471,11 | 0,90 |
| 2025-11 | 1.431.296,64 | 1.083.696,40 | 32,10 |
| 2025-12 | 1.460.690,76 | 1.431.296,64 | 2,10 |

## 08 | Em cada centro de custo, as 2 contas com maior variação desfavorável no ano

Consulta: [`sql/08_ranking_estouros_por_centro.sql`](../sql/08_ranking_estouros_por_centro.sql)

| centro_custo | posicao | conta | orcado | realizado | variacao |
|---|---|---|---|---|---|
| Administrativo | 1 | Despesas financeiras | 144.000,00 | 145.408,40 | 1.408,40 |
| Administrativo | 2 | Salários e encargos | 264.000,00 | 264.731,30 | 731,30 |
| Comercial | 1 | Marketing e publicidade | 300.000,00 | 320.407,82 | 20.407,82 |
| Comercial | 2 | Benefícios | 84.000,00 | 84.432,73 | 432,73 |
| Operações | 1 | Custo das mercadorias vendidas | 8.052.000,00 | 8.202.931,80 | 150.931,80 |
| Operações | 2 | Fretes sobre vendas | 585.600,00 | 634.643,24 | 49.043,24 |
| TI | 1 | Software e licenças | 108.000,00 | 124.816,63 | 16.816,63 |
| TI | 2 | Salários e encargos | 216.000,00 | 217.420,87 | 1.420,87 |

## 09 | Auditoria de qualidade: lançamentos duplicados e sem centro de custo

Consulta: [`sql/09_qualidade_dos_dados.sql`](../sql/09_qualidade_dos_dados.sql)

| problema | data | conta_id | descricao | valor | ocorrencias | impacto_no_realizado |
|---|---|---|---|---|---|---|
| duplicidade | 2025-06-12 | 4.4.05 | Viagens - doc 20077 | 615,72 | 2 | 615,72 |
| duplicidade | 2025-12-05 | 3.1.01 | Venda de mercadorias - doc 95199 | 82.141,96 | 2 | 82.141,96 |
| duplicidade | 2025-12-17 | 3.1.01 | Venda de mercadorias - doc 49223 | 94.431,14 | 2 | 94.431,14 |
| sem centro de custo | 2025-06-20 | 4.4.04 | Serviços de terceiros - doc 26545 | 1.743,25 | 1 | 1.743,25 |
| sem centro de custo | 2025-07-27 | 4.4.04 | Serviços de terceiros - doc 90090 | 1.803,40 | 1 | 1.803,40 |

## 10 | Alerta: despesas que estouraram mais de 10% em meses CONSECUTIVOS

Consulta: [`sql/10_estouros_recorrentes.sql`](../sql/10_estouros_recorrentes.sql)

| conta | meses_seguidos | mes_inicio | mes_fim |
|---|---|---|---|
| Software e licenças | 6 | 7 | 12 |
| Fretes sobre vendas | 3 | 10 | 12 |
| Marketing e publicidade | 2 | 10 | 11 |

## 11 | Impacto da limpeza: o ano com e sem os lançamentos duplicados

Consulta: [`sql/11_impacto_da_limpeza.sql`](../sql/11_impacto_da_limpeza.sql)

| visao | venda_mercadorias | resultado_antes_ir |
|---|---|---|
| orçado | 14.640.000,00 | 932.400,00 |
| realizado (bruto) | 14.716.402,42 | 828.616,19 |
| realizado (sem duplicidades) | 14.539.829,32 | 652.658,81 |
