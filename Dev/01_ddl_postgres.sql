-- District ZER0 · Schema v2 (PostgreSQL 15+)
-- Este arquivo é executado automaticamente durante a inicialização do container
-- O banco de dados 'district_zero' já existe e está sendo usado

-- ---------- ENUMs ----------
CREATE TYPE tipo_sala AS ENUM ('normal', 'safe-zone', 'dungeon');
CREATE TYPE raridade_item AS ENUM ('Comum', 'Incomum', 'Raro', 'Épico', 'Variável');
CREATE TYPE status_missao AS ENUM ('em_andamento', 'concluida', 'falhada');
CREATE TYPE resultado_comb AS ENUM ('vitoria', 'derrota', 'fugiu');

-- ---------- Tabelas ----------
CREATE TABLE jogadores (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(40)  NOT NULL UNIQUE,
    senha_hash  CHAR(60)     NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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

CREATE TABLE classes_especiais (
    classe_id      BIGINT PRIMARY KEY,
    titulo         VARCHAR(120) NOT NULL,
    poder_especial TEXT         NOT NULL,
    CONSTRAINT fk_classes_especiais_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id) ON DELETE CASCADE
);

CREATE TABLE personagens (
    id            BIGSERIAL PRIMARY KEY,
    jogador_id    BIGINT NOT NULL,
    classe_id     BIGINT NOT NULL,
    nivel         INT    NOT NULL DEFAULT 1 CHECK (nivel >= 1),
    vida          INT    NOT NULL DEFAULT 100,
    experiencia   INT    NOT NULL DEFAULT 0,
    reputacao     INT    NOT NULL DEFAULT 0,
    carteira      INT    NOT NULL DEFAULT 0,
    ataque        INT    NOT NULL,
    defesa        INT    NOT NULL,
    faccao_id     BIGINT,
    sala_atual_id BIGINT NOT NULL,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_personagens_jogador FOREIGN KEY (jogador_id) REFERENCES jogadores(id) ON DELETE CASCADE,
    CONSTRAINT fk_personagens_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id),
    CONSTRAINT fk_personagens_faccao FOREIGN KEY (faccao_id) REFERENCES faccoes(id) ON DELETE SET NULL,
    CONSTRAINT fk_personagens_sala FOREIGN KEY (sala_atual_id) REFERENCES salas(id)
);

CREATE TABLE mobs (
    id      BIGSERIAL PRIMARY KEY,
    nome    VARCHAR(120) NOT NULL UNIQUE,
    vida    INT NOT NULL,
    ataque  INT NOT NULL,
    defesa  INT NOT NULL,
    sala_id BIGINT NOT NULL,
    CONSTRAINT fk_mobs_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE
);

CREATE TABLE mob_tipos (
    mob_id         BIGINT PRIMARY KEY,
    tipo           VARCHAR(10) NOT NULL CHECK (tipo IN ('normal','chefe')),
    poder_especial TEXT,
    CONSTRAINT fk_mob_tipos_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE CASCADE
);

CREATE TABLE mob_drops (
    mob_id  BIGINT,
    item_id BIGINT,
    chance  DECIMAL(4,3) NOT NULL CHECK (chance BETWEEN 0 AND 1),
    PRIMARY KEY (mob_id, item_id),
    CONSTRAINT fk_mob_drops_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE CASCADE,
    CONSTRAINT fk_mob_drops_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
);

CREATE TABLE inventario (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    item_id       BIGINT NOT NULL,
    quantidade    INT    NOT NULL CHECK (quantidade >= 1),
    CONSTRAINT uk_inventario_personagem_item UNIQUE (personagem_id, item_id),
    CONSTRAINT fk_inventario_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventario_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
);

CREATE TABLE itens_sala (
    id         BIGSERIAL PRIMARY KEY,
    sala_id    BIGINT NOT NULL,
    item_id    BIGINT NOT NULL,
    quantidade INT    NOT NULL CHECK (quantidade >= 1),
    CONSTRAINT fk_itens_sala_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_sala_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
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
    personagem_id BIGINT NOT NULL,
    missao_id     BIGINT NOT NULL,
    status        status_missao NOT NULL,
    progresso     INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_missoes_jogador_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_missoes_jogador_missao FOREIGN KEY (missao_id) REFERENCES missoes(id) ON DELETE CASCADE
);

CREATE TABLE combates (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    mob_id        BIGINT,
    data_hora     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resultado     resultado_comb NOT NULL,
    CONSTRAINT fk_combates_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_combates_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE SET NULL
);

-- ---------- Índices auxiliares ----------
CREATE INDEX idx_mobs_sala ON mobs(sala_id);
CREATE INDEX idx_pers_sala ON personagens(sala_atual_id);
CREATE INDEX idx_drops_item ON mob_drops(item_id);
CREATE INDEX idx_personagens_jogador ON personagens(jogador_id);
CREATE INDEX idx_inventario_personagem ON inventario(personagem_id);
CREATE INDEX idx_combates_data ON combates(data_hora); 