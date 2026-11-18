-- 04 | Custos e despesas por centro de custo: orçado × realizado
-- Conceitos: WHERE antes do GROUP BY, LEFT JOIN para não perder linhas, tratamento de NULL

WITH orcado AS (
    SELECT o.cc_id, SUM(o.valor) AS orcado
    FROM orcamento AS o
    JOIN plano_contas AS pc ON pc.conta_id = o.conta_id
    WHERE pc.natureza = 'despesa'
    GROUP BY o.cc_id
),
realizado AS (
    SELECT l.cc_id, SUM(l.valor) AS realizado
    FROM lancamentos AS l
    JOIN plano_contas AS pc ON pc.conta_id = l.conta_id
    WHERE pc.natureza = 'despesa'
    GROUP BY l.cc_id              -- lançamentos sem centro de custo formam um grupo NULL
)
SELECT
    COALESCE(cc.centro_custo, '(sem centro de custo)')        AS centro_custo,
    ROUND(COALESCE(o.orcado, 0), 2)                           AS orcado,
    ROUND(r.realizado, 2)                                     AS realizado,
    ROUND(r.realizado - COALESCE(o.orcado, 0), 2)             AS variacao,
    ROUND(100.0 * (r.realizado - o.orcado) / o.orcado, 1)     AS variacao_pct
FROM realizado AS r
LEFT JOIN orcado AS o        ON o.cc_id = r.cc_id
LEFT JOIN centros_custo AS cc ON cc.cc_id = r.cc_id
ORDER BY r.cc_id IS NULL, r.cc_id;   -- o grupo "sem centro de custo" fica por último
