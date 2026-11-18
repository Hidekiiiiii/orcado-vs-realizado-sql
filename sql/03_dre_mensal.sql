-- 03 | DRE gerencial mensal (realizado) com margens
-- Conceitos: strftime (datas), "pivot" com SUM(CASE WHEN), CTEs encadeadas, cálculo de margens

WITH mensal AS (
    SELECT
        strftime('%Y-%m', l.data) AS ano_mes,
        pc.grupo,
        pc.natureza,
        SUM(l.valor) AS valor
    FROM lancamentos AS l
    JOIN plano_contas AS pc ON pc.conta_id = l.conta_id
    GROUP BY ano_mes, pc.grupo, pc.natureza
),
linhas AS (
    -- Transforma linhas (grupos) em colunas: cada coluna é uma linha da DRE
    SELECT
        ano_mes,
        SUM(CASE WHEN grupo = 'Receita Bruta' THEN valor ELSE 0 END) AS receita_bruta,
        SUM(CASE WHEN grupo = 'Deduções'      THEN valor ELSE 0 END) AS deducoes,
        SUM(CASE WHEN grupo = 'CMV'           THEN valor ELSE 0 END) AS cmv,
        SUM(CASE WHEN grupo IN ('Despesas com Pessoal', 'Despesas Comerciais', 'Despesas Administrativas')
                 THEN valor ELSE 0 END)                               AS despesas_operacionais,
        SUM(CASE WHEN grupo = 'Resultado Financeiro' AND natureza = 'receita' THEN valor
                 WHEN grupo = 'Resultado Financeiro' AND natureza = 'despesa' THEN -valor
                 ELSE 0 END)                                          AS resultado_financeiro
    FROM mensal
    GROUP BY ano_mes
),
dre AS (
    SELECT
        ano_mes,
        receita_bruta,
        receita_bruta - deducoes                                   AS receita_liquida,
        receita_bruta - deducoes - cmv                             AS lucro_bruto,
        receita_bruta - deducoes - cmv - despesas_operacionais     AS resultado_operacional,
        receita_bruta - deducoes - cmv - despesas_operacionais
            + resultado_financeiro                                 AS resultado_antes_ir
    FROM linhas
)
SELECT
    ano_mes,
    ROUND(receita_bruta, 2)                                   AS receita_bruta,
    ROUND(receita_liquida, 2)                                 AS receita_liquida,
    ROUND(lucro_bruto, 2)                                     AS lucro_bruto,
    ROUND(100.0 * lucro_bruto / receita_liquida, 1)           AS margem_bruta_pct,
    ROUND(resultado_operacional, 2)                           AS resultado_operacional,
    ROUND(100.0 * resultado_operacional / receita_liquida, 1) AS margem_operacional_pct,
    ROUND(resultado_antes_ir, 2)                              AS resultado_antes_ir
FROM dre
ORDER BY ano_mes;
