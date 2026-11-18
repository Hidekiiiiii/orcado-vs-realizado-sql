-- 08 | Em cada centro de custo, as 2 contas com maior variação desfavorável no ano
-- Conceitos: RANK() OVER (PARTITION BY ...) — ranking dentro de cada grupo

WITH orcado AS (
    SELECT cc_id, conta_id, SUM(valor) AS orcado
    FROM orcamento
    GROUP BY cc_id, conta_id
),
realizado AS (
    SELECT cc_id, conta_id, SUM(valor) AS realizado
    FROM lancamentos
    WHERE cc_id IS NOT NULL
    GROUP BY cc_id, conta_id
),
variacoes AS (
    SELECT
        cc.centro_custo,
        pc.conta,
        o.orcado,
        r.realizado,
        r.realizado - o.orcado AS variacao,
        RANK() OVER (PARTITION BY o.cc_id ORDER BY r.realizado - o.orcado DESC) AS posicao
    FROM orcado AS o
    JOIN realizado AS r      ON r.cc_id = o.cc_id AND r.conta_id = o.conta_id
    JOIN plano_contas AS pc  ON pc.conta_id = o.conta_id
    JOIN centros_custo AS cc ON cc.cc_id = o.cc_id
    WHERE pc.natureza = 'despesa'
)
SELECT
    centro_custo,
    posicao,
    conta,
    ROUND(orcado, 2)    AS orcado,
    ROUND(realizado, 2) AS realizado,
    ROUND(variacao, 2)  AS variacao
FROM variacoes
WHERE posicao <= 2
ORDER BY centro_custo, posicao;
