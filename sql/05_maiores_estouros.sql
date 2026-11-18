-- 05 | Top 10 estouros mensais em despesas operacionais (as que a gestão controla)
-- Conceitos: JOIN com USING em várias colunas, filtro por grupo, ORDER BY + LIMIT

WITH orcado AS (
    SELECT ano_mes, conta_id, SUM(valor) AS orcado
    FROM orcamento
    GROUP BY ano_mes, conta_id
),
realizado AS (
    SELECT strftime('%Y-%m', data) AS ano_mes, conta_id, SUM(valor) AS realizado
    FROM lancamentos
    GROUP BY ano_mes, conta_id
)
SELECT
    o.ano_mes,
    pc.conta,
    ROUND(o.orcado, 2)                                  AS orcado,
    ROUND(r.realizado, 2)                               AS realizado,
    ROUND(r.realizado - o.orcado, 2)                    AS estouro,
    ROUND(100.0 * (r.realizado - o.orcado) / o.orcado, 1) AS estouro_pct
FROM orcado AS o
JOIN realizado AS r     USING (ano_mes, conta_id)
JOIN plano_contas AS pc USING (conta_id)
WHERE pc.grupo IN ('Despesas com Pessoal', 'Despesas Comerciais', 'Despesas Administrativas')
  AND r.realizado > o.orcado
ORDER BY estouro DESC
LIMIT 10;
