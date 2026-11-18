-- Esquema do banco da Atlas Distribuidora (empresa fictícia)
-- Valores são sempre positivos; a coluna "natureza" diz se a conta soma ou subtrai na DRE.

CREATE TABLE plano_contas (
    conta_id  TEXT PRIMARY KEY,   -- ex.: '4.3.01'
    conta     TEXT NOT NULL,      -- ex.: 'Marketing e publicidade'
    grupo     TEXT NOT NULL,      -- linha da DRE: 'Receita Bruta', 'CMV', ...
    natureza  TEXT NOT NULL CHECK (natureza IN ('receita', 'despesa'))
);

CREATE TABLE centros_custo (
    cc_id         INTEGER PRIMARY KEY,
    centro_custo  TEXT NOT NULL
);

-- Orçamento mensal por conta e centro de custo
CREATE TABLE orcamento (
    ano_mes   TEXT NOT NULL,      -- 'AAAA-MM'
    conta_id  TEXT NOT NULL REFERENCES plano_contas (conta_id),
    cc_id     INTEGER NOT NULL REFERENCES centros_custo (cc_id),
    valor     REAL NOT NULL,
    PRIMARY KEY (ano_mes, conta_id, cc_id)
);

-- Razão contábil: cada linha é um lançamento realizado
CREATE TABLE lancamentos (
    lancamento_id  INTEGER PRIMARY KEY,
    data           TEXT NOT NULL,     -- 'AAAA-MM-DD'
    conta_id       TEXT NOT NULL REFERENCES plano_contas (conta_id),
    cc_id          INTEGER REFERENCES centros_custo (cc_id),  -- pode vir vazio (erro de cadastro)
    descricao      TEXT,
    valor          REAL NOT NULL
);
