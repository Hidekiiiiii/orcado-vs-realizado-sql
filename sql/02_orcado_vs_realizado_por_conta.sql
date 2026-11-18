-- 02 | Orçado × realizado no ano, por conta, com avaliação favorável/desfavorável
-- Conceitos: CTE (WITH), LEFT JOIN, COALESCE, CASE WHEN

WITH orcado AS (
    SELECT conta_id, SUM(valor) AS orcado
    FROM orcamento
    GROUP BY conta_id
),
realizado AS (
    SELECT conta_id, SUM(valor) AS realizado
    FROM lancamentos
    GROUP BY conta_id
)
SELECT
    pc.conta_id,
    pc.conta,
    pc.natureza,
    ROUND(o.orcado, 2)                                    AS orcado,
    ROUND(COALESCE(r.realizado, 0), 2)                    AS realizado,
    ROUND(COALESCE(r.realizado, 0) - o.orcado, 2)         AS variacao,
    ROUND(100.0 * (COALESCE(r.realizado, 0) - o.orcado) / o.orcado, 1) AS variacao_pct,
    -- Receita acima do orçado é bom; despesa acima do orçado é ruim
    CASE
        WHEN pc.natureza = 'receita' AND COALESCE(r.realizado, 0) >= o.orcado THEN 'favorável'
        WHEN pc.natureza = 'despesa' AND COALESCE(r.realizado, 0) <= o.orcado THEN 'favorável'
        ELSE 'desfavorável'
    END AS avaliacao
FROM plano_contas AS pc
JOIN orcado AS o
    ON o.conta_id = pc.conta_id
LEFT JOIN realizado AS r          -- LEFT: uma conta orçada pode não ter nenhum lançamento
    ON r.conta_id = pc.conta_id
ORDER BY pc.conta_id;
