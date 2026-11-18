-- 01 | Quanto foi realizado em cada grupo da DRE no ano?
-- Conceitos: SELECT, JOIN, GROUP BY, COUNT, SUM, ORDER BY

SELECT
    pc.grupo,
    COUNT(*)               AS qtd_lancamentos,
    ROUND(SUM(l.valor), 2) AS realizado
FROM lancamentos AS l
JOIN plano_contas AS pc
    ON pc.conta_id = l.conta_id
GROUP BY pc.grupo
ORDER BY MIN(l.conta_id);   -- mantém a ordem natural da DRE (3.x, 4.x, 5.x)
