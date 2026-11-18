-- 06 | Resultado mensal e acumulado no ano (YTD): orçado × realizado
-- Conceitos: função de janela SUM() OVER (ORDER BY ...) para soma acumulada

WITH orcado AS (
    SELECT
        o.ano_mes,
        SUM(CASE WHEN pc.natureza = 'receita' THEN o.valor ELSE -o.valor END) AS resultado
    FROM orcamento AS o
    JOIN plano_contas AS pc ON pc.conta_id = o.conta_id
    GROUP BY o.ano_mes
),
realizado AS (
    SELECT
        strftime('%Y-%m', l.data) AS ano_mes,
        SUM(CASE WHEN pc.natureza = 'receita' THEN l.valor ELSE -l.valor END) AS resultado
    FROM lancamentos AS l
    JOIN plano_contas AS pc ON pc.conta_id = l.conta_id
    GROUP BY ano_mes
)
SELECT
    o.ano_mes,
    ROUND(o.resultado, 2)                                       AS resultado_orcado,
    ROUND(r.resultado, 2)                                       AS resultado_realizado,
    ROUND(SUM(o.resultado) OVER (ORDER BY o.ano_mes), 2)        AS acumulado_orcado,
    ROUND(SUM(r.resultado) OVER (ORDER BY o.ano_mes), 2)        AS acumulado_realizado,
    ROUND(SUM(r.resultado - o.resultado) OVER (ORDER BY o.ano_mes), 2) AS diferenca_acumulada
FROM orcado AS o
JOIN realizado AS r USING (ano_mes)
ORDER BY o.ano_mes;
