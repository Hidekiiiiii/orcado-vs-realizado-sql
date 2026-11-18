-- 07 | Receita líquida realizada: variação contra o mês anterior
-- Conceitos: função de janela LAG(), cláusula WINDOW reutilizável

WITH receita AS (
    SELECT
        strftime('%Y-%m', l.data) AS ano_mes,
        SUM(CASE WHEN pc.grupo = 'Receita Bruta' THEN  l.valor
                 WHEN pc.grupo = 'Deduções'      THEN -l.valor
                 ELSE 0 END) AS receita_liquida
    FROM lancamentos AS l
    JOIN plano_contas AS pc ON pc.conta_id = l.conta_id
    GROUP BY ano_mes
)
SELECT
    ano_mes,
    ROUND(receita_liquida, 2)                         AS receita_liquida,
    ROUND(LAG(receita_liquida) OVER janela, 2)        AS mes_anterior,
    ROUND(100.0 * (receita_liquida - LAG(receita_liquida) OVER janela)
          / LAG(receita_liquida) OVER janela, 1)      AS variacao_pct
FROM receita
WINDOW janela AS (ORDER BY ano_mes)
ORDER BY ano_mes;
