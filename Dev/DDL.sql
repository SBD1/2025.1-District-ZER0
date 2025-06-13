-- District ZER0 · Schema v2 (PostgreSQL 14+)
-- DROP SCHEMA IF EXISTS dz CASCADE;
CREATE SCHEMA IF NOT EXISTS dz;
SET search_path TO dz;

-- ---------- ENUMs ----------
CREATE TYPE tipo_sala      AS ENUM ('normal','safe-zone','dungeon');
CREATE TYPE raridade_item  AS ENUM ('Comum','Incomum','Raro','Épico','Variável');
CREATE TYPE status_missao  AS ENUM ('em_andamento','concluida','falhada');
CREATE TYPE resultado_comb AS ENUM ('vitoria','derrota','fugiu');

-- ---------- Tabelas ----------
CREATE TABLE jogadores (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(40)  NOT NULL UNIQUE,
    senha_hash  CHAR(60)     NOT NULL
);

CREATE TABLE salas (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    tipo      tipo_sala    NOT NULL,
    descricao TEXT
);

CREATE TABLE itens (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120)  NOT NULL UNIQUE,
    tipo      VARCHAR(30)   NOT NULL,
    descricao TEXT,
    raridade  raridade_item NOT NULL,
    valor     INT           NOT NULL CHECK (valor >= 0)
);

CREATE TABLE faccoes (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    descricao TEXT,
    reputacao INT DEFAULT 0
);

CREATE TABLE classe_personagem (
    id   BIGSERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE classes_especiais (          -- consolida Hacker, Mercenário…
    classe_id      BIGINT PRIMARY KEY REFERENCES classe_personagem(id) ON DELETE CASCADE,
    titulo         VARCHAR(120) NOT NULL,
    poder_especial TEXT        NOT NULL
);

CREATE TABLE personagens (
    id            BIGSERIAL PRIMARY KEY,
    jogador_id    BIGINT NOT NULL REFERENCES jogadores(id) ON DELETE CASCADE,
    classe_id     BIGINT NOT NULL REFERENCES classe_personagem(id),
    nivel         INT    NOT NULL DEFAULT 1 CHECK (nivel >= 1),
    vida          INT    NOT NULL DEFAULT 100,
    experiencia   INT    NOT NULL DEFAULT 0,
    reputacao     INT    NOT NULL DEFAULT 0,
    carteira      INT    NOT NULL DEFAULT 0,
    ataque        INT    NOT NULL,
    defesa        INT    NOT NULL,
    faccao_id     BIGINT REFERENCES faccoes(id)        ON DELETE SET NULL,
    sala_atual_id BIGINT NOT NULL REFERENCES salas(id)
);

CREATE TABLE mobs (
    id      BIGSERIAL PRIMARY KEY,
    nome    VARCHAR(120) NOT NULL UNIQUE,
    vida    INT NOT NULL,
    ataque  INT NOT NULL,
    defesa  INT NOT NULL,
    sala_id BIGINT NOT NULL REFERENCES salas(id) ON DELETE CASCADE
);

CREATE TABLE mob_tipos (                  -- normal  | chefe
    mob_id         BIGINT PRIMARY KEY REFERENCES mobs(id) ON DELETE CASCADE,
    tipo           VARCHAR(10) NOT NULL CHECK (tipo IN ('normal','chefe')),
    poder_especial TEXT
);

CREATE TABLE mob_drops (                  -- tabela normalizada de drops
    mob_id  BIGINT REFERENCES mobs(id)  ON DELETE CASCADE,
    item_id BIGINT REFERENCES itens(id) ON DELETE CASCADE,
    chance  NUMERIC(4,3) NOT NULL CHECK (chance BETWEEN 0 AND 1),
    PRIMARY KEY (mob_id, item_id)
);

CREATE TABLE inventario (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL REFERENCES personagens(id) ON DELETE CASCADE,
    item_id       BIGINT NOT NULL REFERENCES itens(id)       ON DELETE CASCADE,
    quantidade    INT    NOT NULL CHECK (quantidade >= 1),
    UNIQUE (personagem_id, item_id)
);

CREATE TABLE itens_sala (
    id         BIGSERIAL PRIMARY KEY,
    sala_id    BIGINT NOT NULL REFERENCES salas(id)  ON DELETE CASCADE,
    item_id    BIGINT NOT NULL REFERENCES itens(id)  ON DELETE CASCADE,
    quantidade INT    NOT NULL CHECK (quantidade >= 1)
);

CREATE TABLE missoes (
    id            BIGSERIAL PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    descricao     TEXT,
    recompensa    TEXT,
    xp_requerido  INT NOT NULL DEFAULT 0 CHECK (xp_requerido >= 0),
    tipo          VARCHAR(40) NOT NULL
);

CREATE TABLE missoes_jogador (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL REFERENCES personagens(id) ON DELETE CASCADE,
    missao_id     BIGINT NOT NULL REFERENCES missoes(id)     ON DELETE CASCADE,
    status        status_missao NOT NULL,
    progresso     INT NOT NULL DEFAULT 0
);

CREATE TABLE combates (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL REFERENCES personagens(id) ON DELETE CASCADE,
    mob_id        BIGINT       REFERENCES mobs(id)           ON DELETE SET NULL,
    data_hora     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    resultado     resultado_comb NOT NULL
);

-- ---------- Índices auxiliares ----------
CREATE INDEX idx_mobs_sala ON mobs(sala_id);
CREATE INDEX idx_pers_sala ON personagens(sala_atual_id);
CREATE INDEX idx_drops_item ON mob_drops(item_id);
