# Guia de estudo: SQL para quem vem do Excel

Objetivo: você precisa conseguir **explicar e reescrever** cada consulta deste projeto numa entrevista técnica.
Este guia liga cada conceito de SQL a algo que você já faz no Excel e termina com exercícios.

> Como estudar: abra o banco `dados/atlas.db` num editor SQL (sugestão: [DB Browser for SQLite](https://sqlitebrowser.org/), gratuito, ou a extensão "SQLite Viewer" do VS Code). Rode cada consulta, **mude algo nela** e veja o que acontece.

---

## 1. O mapa Excel → SQL

| No Excel você faz... | Em SQL é... | Onde aparece |
|---|---|---|
| Filtrar linhas da planilha | `WHERE` | 04, 05, 08 |
| `SOMASES` / `CONT.SES` | `SUM()` / `COUNT()` + `GROUP BY` | todas |
| `PROCV` / `PROCX` para trazer o nome da conta | `JOIN` | todas |
| `PROCV` que pode não achar (`SEERRO`) | `LEFT JOIN` + `COALESCE` | 02, 04 |
| Coluna com `SE(...)` | `CASE WHEN ... THEN ... ELSE ... END` | 02, 03, 06 |
| Tabela dinâmica com meses nas colunas | `SUM(CASE WHEN ...)` (pivot manual) | 03 |
| Filtro em cima do resultado da dinâmica | `HAVING` | 09, 10 |
| Classificar e pegar os 10 primeiros | `ORDER BY ... LIMIT 10` | 05 |
| Abas auxiliares com cálculos intermediários | CTE (`WITH nome AS (...)`) | 02 em diante |
| Soma acumulada `=SOMA($B$2:B2)` | `SUM() OVER (ORDER BY ...)` | 06 |
| Referenciar a linha de cima `=B3-B2` | `LAG() OVER (ORDER BY ...)` | 07 |
| `ORDEM()` dentro de cada grupo | `RANK() OVER (PARTITION BY ...)` | 08 |
| Remover duplicatas | `ROW_NUMBER() OVER (PARTITION BY ...)` + `WHERE ordem = 1` | 11 |

**A grande diferença mental:** no Excel você pensa em *células*; em SQL você pensa em *conjuntos de linhas*. Você descreve **o que** quer, e o banco decide **como** calcular.

---

## 2. Ordem de execução (cai em toda entrevista)

Você escreve nesta ordem: `SELECT → FROM → WHERE → GROUP BY → HAVING → ORDER BY → LIMIT`

O banco executa nesta ordem:

```
1. FROM / JOIN   → monta a tabela base
2. WHERE         → filtra LINHAS (antes de agrupar)
3. GROUP BY      → agrupa
4. HAVING        → filtra GRUPOS (depois de agrupar)
5. SELECT        → calcula as colunas (e as funções de janela)
6. ORDER BY      → ordena
7. LIMIT         → corta
```

Consequências práticas:
- Não dá para usar `SUM()` no `WHERE` (a soma ainda não existe). Para isso existe o `HAVING`.
- Funções de janela (`OVER`) rodam depois do `WHERE`. Por isso, para filtrar pelo resultado de um `RANK()`, a consulta 08 coloca o ranking numa CTE e filtra fora dela.

---

## 3. Consulta por consulta

### 01: Realizado por grupo
`JOIN` liga cada lançamento ao plano de contas (como um `PROCV` pela coluna `conta_id`). `GROUP BY grupo` junta todas as linhas do mesmo grupo e aplica `SUM` e `COUNT`.
**Pergunte-se:** o que acontece se eu tirar o `GROUP BY`? (Erro, ou uma linha só, dependendo do banco.)

### 02: Orçado × realizado por conta
Duas CTEs somam orçado e realizado **separadamente** e só depois se juntam.
**Por que não juntar as tabelas direto e somar?** Porque cada conta tem 12 linhas de orçamento e dezenas de lançamentos. Um `JOIN` direto multiplicaria as linhas (cada lançamento repetido 12 vezes) e o total sairia errado. Esse é o **erro de fan-out**, um dos mais comuns em SQL. Agregue antes, junte depois.
`CASE WHEN` aplica a regra de controladoria: receita acima do orçado é favorável; despesa acima, desfavorável.

### 03: DRE mensal
`strftime('%Y-%m', data)` transforma `2025-03-17` em `2025-03` (como `TEXTO(data;"aaaa-mm")`).
O "pivot" `SUM(CASE WHEN grupo = 'CMV' THEN valor ELSE 0 END)` soma só as linhas daquele grupo: é um `SOMASES` com uma condição.
As margens usam `100.0 *`: com `100` (inteiro), alguns bancos fazem divisão inteira e o resultado vira 0.

### 04: Por centro de custo
`LEFT JOIN` mantém os lançamentos **sem** centro de custo, que aparecem como `NULL`, e o `COALESCE` troca o `NULL` por um texto legível.
`NULL` não é zero nem vazio: é "desconhecido". `NULL = NULL` não é verdadeiro. Por isso existe `IS NULL`.

### 05: Top 10 estouros
`USING (ano_mes, conta_id)` é um atalho para `ON a.ano_mes = b.ano_mes AND a.conta_id = b.conta_id`.
O filtro de grupos deixa de fora Deduções e CMV, que acompanham o volume de vendas, para focar no que a gestão controla.

### 06: Resultado acumulado (YTD)
`SUM(x) OVER (ORDER BY ano_mes)` é a soma acumulada, exatamente o `=SOMA($B$2:B2)` arrastado para baixo.
Diferença para o `GROUP BY`: a função de janela **não reduz as linhas**. Cada mês continua na tabela, com o acumulado ao lado.

### 07: Mês contra mês
`LAG(x) OVER (ORDER BY ano_mes)` busca o valor da linha anterior. Em janeiro não há anterior, então volta `NULL`.
A cláusula `WINDOW janela AS (...)` evita repetir a mesma definição três vezes.

### 08: Ranking por centro de custo
`PARTITION BY cc_id` reinicia o ranking em cada centro de custo, como fazer um `ORDEM()` separado para cada grupo.
`RANK` × `ROW_NUMBER` × `DENSE_RANK`: em empates, `RANK` repete a posição e pula a seguinte (1, 1, 3); `DENSE_RANK` não pula (1, 1, 2); `ROW_NUMBER` nunca empata (1, 2, 3).

### 09: Qualidade dos dados
`GROUP BY` em **todas** as colunas descritivas + `HAVING COUNT(*) > 1` encontra linhas idênticas.
`UNION ALL` empilha dois resultados com as mesmas colunas (como colar uma tabela embaixo da outra). `UNION`, sem o `ALL`, também removeria as linhas repetidas.

### 10: Estouros em meses seguidos ("gaps and islands")
Truque: para meses consecutivos, `mes − ROW_NUMBER()` dá sempre o mesmo número.

| mes | ROW_NUMBER | mes − ROW_NUMBER |
|---|---|---|
| 7 | 1 | 6 |
| 8 | 2 | 6 |
| 9 | 3 | 6 |
| 11 | 4 | **7** ← quebrou a sequência |

Agrupando por esse número, cada sequência vira um grupo, e `COUNT(*)` dá o tamanho dela.

### 11: Impacto da limpeza
`ROW_NUMBER() OVER (PARTITION BY <todas as colunas>)` numera as cópias idênticas: 1, 2... Manter só `ordem = 1` remove as duplicatas sem apagar nada do banco.
**Esta é a consulta mais importante para contar na entrevista:** ela mostra que você valida os dados antes de concluir.

---

## 4. Perguntas prováveis em entrevista

1. Qual a diferença entre `WHERE` e `HAVING`?
2. Qual a diferença entre `INNER JOIN` e `LEFT JOIN`? Quando o `LEFT` é necessário neste projeto?
3. Por que você agregou o orçado e o realizado em CTEs separadas antes de juntar? (fan-out)
4. Qual a diferença entre `GROUP BY` e uma função de janela?
5. Como você encontraria e removeria duplicatas?
6. Como o `NULL` se comporta em comparações e em `SUM`/`COUNT`? (`COUNT(*)` conta linhas; `COUNT(coluna)` ignora `NULL`.)
7. O que você recomendaria à diretoria com base nesta análise?

---

## 5. Exercícios (faça sem olhar as respostas prontas)

1. **Básico:** quanto foi gasto com **Viagens** em cada trimestre? (dica: `CASE` sobre o mês ou `(mes - 1) / 3 + 1`)
2. **Básico:** liste os 5 maiores lançamentos individuais de despesa do ano, com nome da conta.
3. **Intermediário:** refaça a consulta 02 **só para o 1º semestre**. Onde entra o filtro: no `WHERE` de qual CTE?
4. **Intermediário:** calcule a participação (%) de cada centro de custo no total de despesas realizadas.
5. **Avançado:** para cada conta, mostre o mês com o maior realizado (dica: `ROW_NUMBER` + `PARTITION BY conta_id`).
6. **Avançado:** refaça a DRE mensal (03) **sem as duplicidades**, reaproveitando a CTE `numerados` da consulta 11.
7. **Desafio:** monte a consulta 02 com média móvel de 3 meses do realizado por conta (`AVG() OVER (... ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`).

Quando terminar, peça ao ORION para corrigir as suas respostas.
