-- District ZER0 · Schema v2 (MySQL 8.0+)
DROP DATABASE IF EXISTS district_zero;
CREATE DATABASE district_zero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE district_zero;

-- ---------- ENUMs (MySQL usa CHECK constraints) ----------
CREATE TABLE enum_tipo_sala (
    value VARCHAR(20) PRIMARY KEY
);
INSERT INTO enum_tipo_sala VALUES ('normal'), ('safe-zone'), ('dungeon');

CREATE TABLE enum_raridade_item (
    value VARCHAR(20) PRIMARY KEY
);
INSERT INTO enum_raridade_item VALUES ('Comum'), ('Incomum'), ('Raro'), ('Épico'), ('Variável');

CREATE TABLE enum_status_missao (
    value VARCHAR(20) PRIMARY KEY
);
INSERT INTO enum_status_missao VALUES ('em_andamento'), ('concluida'), ('falhada');

CREATE TABLE enum_resultado_comb (
    value VARCHAR(10) PRIMARY KEY
);
INSERT INTO enum_resultado_comb VALUES ('vitoria'), ('derrota'), ('fugiu');

-- ---------- Tabelas ----------
CREATE TABLE jogadores (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(40)  NOT NULL UNIQUE,
    senha_hash  CHAR(60)     NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE salas (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    tipo      VARCHAR(20)  NOT NULL,
    descricao TEXT,
    CONSTRAINT fk_salas_tipo FOREIGN KEY (tipo) REFERENCES enum_tipo_sala(value)
);

CREATE TABLE itens (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120)  NOT NULL UNIQUE,
    tipo      VARCHAR(30)   NOT NULL,
    descricao TEXT,
    raridade  VARCHAR(20)   NOT NULL,
    valor     INT           NOT NULL CHECK (valor >= 0),
    CONSTRAINT fk_itens_raridade FOREIGN KEY (raridade) REFERENCES enum_raridade_item(value)
);

CREATE TABLE faccoes (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    descricao TEXT,
    reputacao INT DEFAULT 0
);

CREATE TABLE classe_personagem (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE classes_especiais (
    classe_id      BIGINT PRIMARY KEY,
    titulo         VARCHAR(120) NOT NULL,
    poder_especial TEXT         NOT NULL,
    CONSTRAINT fk_classes_especiais_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id) ON DELETE CASCADE
);

CREATE TABLE personagens (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_personagens_jogador FOREIGN KEY (jogador_id) REFERENCES jogadores(id) ON DELETE CASCADE,
    CONSTRAINT fk_personagens_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id),
    CONSTRAINT fk_personagens_faccao FOREIGN KEY (faccao_id) REFERENCES faccoes(id) ON DELETE SET NULL,
    CONSTRAINT fk_personagens_sala FOREIGN KEY (sala_atual_id) REFERENCES salas(id)
);

CREATE TABLE mobs (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
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
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    item_id       BIGINT NOT NULL,
    quantidade    INT    NOT NULL CHECK (quantidade >= 1),
    UNIQUE KEY uk_inventario_personagem_item (personagem_id, item_id),
    CONSTRAINT fk_inventario_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventario_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
);

CREATE TABLE itens_sala (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    sala_id    BIGINT NOT NULL,
    item_id    BIGINT NOT NULL,
    quantidade INT    NOT NULL CHECK (quantidade >= 1),
    CONSTRAINT fk_itens_sala_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_sala_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
);

CREATE TABLE missoes (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    descricao     TEXT,
    recompensa    TEXT,
    xp_requerido  INT NOT NULL DEFAULT 0 CHECK (xp_requerido >= 0),
    tipo          VARCHAR(40) NOT NULL
);

CREATE TABLE missoes_jogador (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    missao_id     BIGINT NOT NULL,
    status        VARCHAR(20) NOT NULL,
    progresso     INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_missoes_jogador_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_missoes_jogador_missao FOREIGN KEY (missao_id) REFERENCES missoes(id) ON DELETE CASCADE,
    CONSTRAINT fk_missoes_jogador_status FOREIGN KEY (status) REFERENCES enum_status_missao(value)
);

CREATE TABLE combates (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    mob_id        BIGINT,
    data_hora     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resultado     VARCHAR(10) NOT NULL,
    CONSTRAINT fk_combates_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_combates_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE SET NULL,
    CONSTRAINT fk_combates_resultado FOREIGN KEY (resultado) REFERENCES enum_resultado_comb(value)
);

-- ---------- Índices auxiliares ----------
CREATE INDEX idx_mobs_sala ON mobs(sala_id);
CREATE INDEX idx_pers_sala ON personagens(sala_atual_id);
CREATE INDEX idx_drops_item ON mob_drops(item_id);
CREATE INDEX idx_personagens_jogador ON personagens(jogador_id);
CREATE INDEX idx_inventario_personagem ON inventario(personagem_id);
CREATE INDEX idx_combates_data ON combates(data_hora); 