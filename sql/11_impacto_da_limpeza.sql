-- 11 | Impacto da limpeza: o ano com e sem os lançamentos duplicados
-- Conceitos: deduplicação com ROW_NUMBER() OVER (PARTITION BY ...), UNION ALL de visões

WITH numerados AS (
    -- Lançamentos idênticos recebem 1, 2, 3...; só o primeiro (ordem = 1) é legítimo
    SELECT
        l.*,
        ROW_NUMBER() OVER (
            PARTITION BY data, conta_id, cc_id, descricao, valor
            ORDER BY lancamento_id
        ) AS ordem
    FROM lancamentos AS l
),
visoes AS (
    SELECT 1 AS ordem_visao, 'orçado' AS visao, o.conta_id, pc.natureza, o.valor
    FROM orcamento AS o JOIN plano_contas AS pc ON pc.conta_id = o.conta_id

    UNION ALL
    SELECT 2, 'realizado (bruto)', n.conta_id, pc.natureza, n.valor
    FROM numerados AS n JOIN plano_contas AS pc ON pc.conta_id = n.conta_id

    UNION ALL
    SELECT 3, 'realizado (sem duplicidades)', n.conta_id, pc.natureza, n.valor
    FROM numerados AS n JOIN plano_contas AS pc ON pc.conta_id = n.conta_id
    WHERE n.ordem = 1
)
SELECT
    visao,
    ROUND(SUM(CASE WHEN conta_id = '3.1.01' THEN valor ELSE 0 END), 2)          AS venda_mercadorias,
    ROUND(SUM(CASE WHEN natureza = 'receita' THEN valor ELSE -valor END), 2)    AS resultado_antes_ir
FROM visoes
GROUP BY ordem_visao, visao
ORDER BY ordem_visao;
