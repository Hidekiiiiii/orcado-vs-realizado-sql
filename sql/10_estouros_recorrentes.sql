-- 10 | Alerta: despesas que estouraram mais de 10% em meses CONSECUTIVOS
-- Conceitos: técnica "gaps and islands" com ROW_NUMBER() para achar sequências

WITH orcado AS (
    SELECT ano_mes, conta_id, SUM(valor) AS orcado
    FROM orcamento
    GROUP BY ano_mes, conta_id
),
realizado AS (
    SELECT strftime('%Y-%m', data) AS ano_mes, conta_id, SUM(valor) AS realizado
    FROM lancamentos
    GROUP BY ano_mes, conta_id
),
estouros AS (
    SELECT o.conta_id, CAST(substr(o.ano_mes, 6, 2) AS INTEGER) AS mes
    FROM orcado AS o
    JOIN realizado AS r     USING (ano_mes, conta_id)
    JOIN plano_contas AS pc USING (conta_id)
    WHERE pc.natureza = 'despesa'
      AND r.realizado > o.orcado * 1.10
),
ilhas AS (
    -- Em meses seguidos, (mes - posição na sequência) é constante: isso identifica cada "ilha"
    SELECT
        conta_id,
        mes,
        mes - ROW_NUMBER() OVER (PARTITION BY conta_id ORDER BY mes) AS ilha
    FROM estouros
)
SELECT
    pc.conta,
    COUNT(*)  AS meses_seguidos,
    MIN(mes)  AS mes_inicio,
    MAX(mes)  AS mes_fim
FROM ilhas
JOIN plano_contas AS pc USING (conta_id)
GROUP BY ilhas.conta_id, ilha
HAVING COUNT(*) >= 2
ORDER BY meses_seguidos DESC, pc.conta;
