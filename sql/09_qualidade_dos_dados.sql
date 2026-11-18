-- 09 | Auditoria de qualidade: lançamentos duplicados e sem centro de custo
-- Conceitos: GROUP BY + HAVING para achar duplicidades, IS NULL, UNION ALL

WITH duplicados AS (
    SELECT data, conta_id, cc_id, descricao, valor, COUNT(*) AS ocorrencias
    FROM lancamentos
    GROUP BY data, conta_id, cc_id, descricao, valor
    HAVING COUNT(*) > 1
)
SELECT
    'duplicidade'                        AS problema,
    data,
    conta_id,
    descricao,
    valor,
    ocorrencias,
    ROUND(valor * (ocorrencias - 1), 2)  AS impacto_no_realizado   -- valor contado a mais
FROM duplicados

UNION ALL

SELECT
    'sem centro de custo',
    data,
    conta_id,
    descricao,
    valor,
    1,
    valor                                -- valor que não aparece em nenhum centro
FROM lancamentos
WHERE cc_id IS NULL

ORDER BY problema, data;
