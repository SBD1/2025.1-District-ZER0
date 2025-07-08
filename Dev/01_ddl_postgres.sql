-- District ZER0 · Schema v2 (PostgreSQL 15+) - Versão Aprimorada
-- Este arquivo é executado automaticamente durante a inicialização do container
-- O banco de dados 'district_zero' já existe e está sendo usado

-- ---------- ENUMs ----------
CREATE TYPE tipo_sala AS ENUM ('normal', 'safe-zone', 'dungeon');
CREATE TYPE raridade_item AS ENUM ('Comum', 'Incomum', 'Raro', 'Épico', 'Variável');
CREATE TYPE status_missao AS ENUM ('em_andamento', 'concluida', 'falhada');
CREATE TYPE resultado_comb AS ENUM ('vitoria', 'derrota', 'fugiu');

-- ---------- Tabelas Principais ----------
CREATE TABLE jogadores (
    id          BIGSERIAL PRIMARY KEY,
    username    VARCHAR(40)  NOT NULL UNIQUE,
    senha_hash  CHAR(60)     NOT NULL,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login  TIMESTAMP WITH TIME ZONE,
    is_active   BOOLEAN DEFAULT TRUE,
    
    -- Constraints
    CONSTRAINT chk_username_length CHECK (LENGTH(username) >= 3),
    CONSTRAINT chk_username_format CHECK (username ~ '^[a-zA-Z0-9_]+$')
);

CREATE TABLE salas (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    tipo      tipo_sala    NOT NULL,
    descricao TEXT,
    max_players INT DEFAULT 50,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_max_players CHECK (max_players > 0)
);

CREATE TABLE itens (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120)  NOT NULL UNIQUE,
    tipo      VARCHAR(30)   NOT NULL,
    descricao TEXT,
    raridade  raridade_item NOT NULL,
    valor     INT           NOT NULL CHECK (valor >= 0),
    peso      DECIMAL(5,2)  DEFAULT 1.0,
    max_stack INT           DEFAULT 1,
    is_unique BOOLEAN       DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_peso CHECK (peso >= 0),
    CONSTRAINT chk_max_stack CHECK (max_stack > 0),
    CONSTRAINT chk_tipo_valido CHECK (tipo IN ('arma', 'chip', 'consumivel', 'aprimoramento', 'dado', 'especial'))
);

CREATE TABLE faccoes (
    id        BIGSERIAL PRIMARY KEY,
    nome      VARCHAR(120) NOT NULL UNIQUE,
    descricao TEXT,
    reputacao INT DEFAULT 0,
    max_members INT DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_reputacao_faccao CHECK (reputacao >= 0),
    CONSTRAINT chk_max_members CHECK (max_members > 0)
);

CREATE TABLE classe_personagem (
    id   BIGSERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE,
    descricao TEXT,
    vida_base INT DEFAULT 100,
    ataque_base INT DEFAULT 10,
    defesa_base INT DEFAULT 10,
    
    -- Constraints
    CONSTRAINT chk_vida_base CHECK (vida_base > 0),
    CONSTRAINT chk_ataque_base CHECK (ataque_base > 0),
    CONSTRAINT chk_defesa_base CHECK (defesa_base > 0)
);

CREATE TABLE classes_especiais (
    classe_id      BIGINT PRIMARY KEY,
    titulo         VARCHAR(120) NOT NULL,
    poder_especial TEXT         NOT NULL,
    bonus_ataque   INT DEFAULT 0,
    bonus_defesa   INT DEFAULT 0,
    bonus_vida     INT DEFAULT 0,
    
    CONSTRAINT fk_classes_especiais_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id) ON DELETE CASCADE,
    CONSTRAINT chk_bonus_ataque CHECK (bonus_ataque >= 0),
    CONSTRAINT chk_bonus_defesa CHECK (bonus_defesa >= 0),
    CONSTRAINT chk_bonus_vida CHECK (bonus_vida >= 0)
);

CREATE TABLE personagens (
    id            BIGSERIAL PRIMARY KEY,
    jogador_id    BIGINT NOT NULL,
    classe_id     BIGINT NOT NULL,
    nivel         INT    NOT NULL DEFAULT 1 CHECK (nivel >= 1 AND nivel <= 100),
    vida          INT    NOT NULL DEFAULT 100,
    vida_max      INT    NOT NULL DEFAULT 100,
    experiencia   BIGINT NOT NULL DEFAULT 0,
    reputacao     INT    NOT NULL DEFAULT 0,
    carteira      BIGINT NOT NULL DEFAULT 0,
    ataque        INT    NOT NULL,
    defesa        INT    NOT NULL,
    faccao_id     BIGINT,
    sala_atual_id BIGINT NOT NULL,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_action   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_personagens_jogador FOREIGN KEY (jogador_id) REFERENCES jogadores(id) ON DELETE CASCADE,
    CONSTRAINT fk_personagens_classe FOREIGN KEY (classe_id) REFERENCES classe_personagem(id),
    CONSTRAINT fk_personagens_faccao FOREIGN KEY (faccao_id) REFERENCES faccoes(id) ON DELETE SET NULL,
    CONSTRAINT fk_personagens_sala FOREIGN KEY (sala_atual_id) REFERENCES salas(id),
    
    -- Constraints de integridade
    CONSTRAINT chk_vida CHECK (vida >= 0 AND vida <= vida_max),
    CONSTRAINT chk_vida_max CHECK (vida_max > 0),
    CONSTRAINT chk_experiencia CHECK (experiencia >= 0),
    CONSTRAINT chk_carteira CHECK (carteira >= 0),
    CONSTRAINT chk_ataque CHECK (ataque > 0),
    CONSTRAINT chk_defesa CHECK (defesa > 0),
    CONSTRAINT chk_reputacao CHECK (reputacao >= 0),
    
    -- Limite de um personagem por jogador (pode ser removido se múltiplos permitidos)
    CONSTRAINT uk_personagem_por_jogador UNIQUE (jogador_id)
);

CREATE TABLE mobs (
    id      BIGSERIAL PRIMARY KEY,
    nome    VARCHAR(120) NOT NULL UNIQUE,
    vida    INT NOT NULL,
    vida_max INT NOT NULL,
    ataque  INT NOT NULL,
    defesa  INT NOT NULL,
    sala_id BIGINT NOT NULL,
    xp_reward INT DEFAULT 50,
    respawn_time INTERVAL DEFAULT '5 minutes',
    last_death TIMESTAMP WITH TIME ZONE,
    is_boss BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT fk_mobs_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT chk_vida_mob CHECK (vida >= 0 AND vida <= vida_max),
    CONSTRAINT chk_vida_max_mob CHECK (vida_max > 0),
    CONSTRAINT chk_ataque_mob CHECK (ataque > 0),
    CONSTRAINT chk_defesa_mob CHECK (defesa > 0),
    CONSTRAINT chk_xp_reward CHECK (xp_reward >= 0)
);

CREATE TABLE mob_tipos (
    mob_id         BIGINT PRIMARY KEY,
    tipo           VARCHAR(10) NOT NULL CHECK (tipo IN ('normal','chefe')),
    poder_especial TEXT,
    modificador_dano DECIMAL(3,2) DEFAULT 1.0,
    
    CONSTRAINT fk_mob_tipos_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE CASCADE,
    CONSTRAINT chk_modificador_dano CHECK (modificador_dano > 0)
);

CREATE TABLE mob_drops (
    mob_id  BIGINT,
    item_id BIGINT,
    chance  DECIMAL(4,3) NOT NULL CHECK (chance BETWEEN 0 AND 1),
    quantidade_min INT DEFAULT 1,
    quantidade_max INT DEFAULT 1,
    
    PRIMARY KEY (mob_id, item_id),
    CONSTRAINT fk_mob_drops_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE CASCADE,
    CONSTRAINT fk_mob_drops_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE,
    CONSTRAINT chk_quantidade_min CHECK (quantidade_min > 0),
    CONSTRAINT chk_quantidade_max CHECK (quantidade_max >= quantidade_min)
);

CREATE TABLE inventario (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    item_id       BIGINT NOT NULL,
    quantidade    INT    NOT NULL CHECK (quantidade >= 0),
    
    CONSTRAINT uk_inventario_personagem_item UNIQUE (personagem_id, item_id),
    CONSTRAINT fk_inventario_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventario_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE
);

CREATE TABLE itens_sala (
    id         BIGSERIAL PRIMARY KEY,
    sala_id    BIGINT NOT NULL,
    item_id    BIGINT NOT NULL,
    quantidade INT    NOT NULL CHECK (quantidade >= 0),
    dropped_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    dropped_by BIGINT, -- ID do personagem que dropou (opcional)
    
    CONSTRAINT uk_itens_sala_unico UNIQUE (sala_id, item_id),
    CONSTRAINT fk_itens_sala_sala FOREIGN KEY (sala_id) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_sala_item FOREIGN KEY (item_id) REFERENCES itens(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_sala_personagem FOREIGN KEY (dropped_by) REFERENCES personagens(id) ON DELETE SET NULL
);

CREATE TABLE missoes (
    id            BIGSERIAL PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    descricao     TEXT,
    recompensa    TEXT,
    xp_requerido  INT NOT NULL DEFAULT 0 CHECK (xp_requerido >= 0),
    nivel_requerido INT DEFAULT 1,
    tipo          VARCHAR(40) NOT NULL,
    dificuldade   VARCHAR(20) DEFAULT 'Normal',
    tempo_limite  INTERVAL,
    is_repeatable BOOLEAN DEFAULT FALSE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_nivel_requerido CHECK (nivel_requerido >= 1),
    CONSTRAINT chk_dificuldade CHECK (dificuldade IN ('Fácil', 'Normal', 'Difícil', 'Épico', 'Lendário'))
);

CREATE TABLE missoes_jogador (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    missao_id     BIGINT NOT NULL,
    status        status_missao NOT NULL,
    progresso     INT NOT NULL DEFAULT 0,
    started_at    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at  TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT fk_missoes_jogador_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_missoes_jogador_missao FOREIGN KEY (missao_id) REFERENCES missoes(id) ON DELETE CASCADE,
    CONSTRAINT chk_progresso CHECK (progresso >= 0 AND progresso <= 100),
    CONSTRAINT uk_missoes_jogador UNIQUE (personagem_id, missao_id)
);

CREATE TABLE combates (
    id            BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT NOT NULL,
    mob_id        BIGINT,
    oponente_id   BIGINT, -- Para PvP
    data_hora     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resultado     resultado_comb NOT NULL,
    dano_causado  INT DEFAULT 0,
    dano_recebido INT DEFAULT 0,
    xp_ganho      INT DEFAULT 0,
    
    CONSTRAINT fk_combates_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE CASCADE,
    CONSTRAINT fk_combates_mob FOREIGN KEY (mob_id) REFERENCES mobs(id) ON DELETE SET NULL,
    CONSTRAINT fk_combates_oponente FOREIGN KEY (oponente_id) REFERENCES personagens(id) ON DELETE SET NULL,
    CONSTRAINT chk_dano_causado CHECK (dano_causado >= 0),
    CONSTRAINT chk_dano_recebido CHECK (dano_recebido >= 0),
    CONSTRAINT chk_xp_ganho CHECK (xp_ganho >= 0),
    CONSTRAINT chk_combate_valido CHECK ((mob_id IS NOT NULL) OR (oponente_id IS NOT NULL))
);

-- ---------- Tabela de Caminhos (Sistema de Movimento) ----------
CREATE TABLE caminhos (
    sala_origem BIGINT NOT NULL,
    direcao CHAR(1) NOT NULL CHECK (direcao IN ('N','S','L','O')),
    sala_destino BIGINT NOT NULL,
    is_bidirectional BOOLEAN DEFAULT TRUE,
    custo_movimento INT DEFAULT 1,
    requer_chave BIGINT, -- Item necessário para passar
    
    PRIMARY KEY (sala_origem, direcao),
    CONSTRAINT fk_caminhos_origem FOREIGN KEY (sala_origem) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_caminhos_destino FOREIGN KEY (sala_destino) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_caminhos_chave FOREIGN KEY (requer_chave) REFERENCES itens(id) ON DELETE SET NULL,
    CONSTRAINT chk_custo_movimento CHECK (custo_movimento > 0),
    CONSTRAINT chk_caminho_diferente CHECK (sala_origem != sala_destino)
);

-- ---------- Tabelas de Log e Auditoria ----------
CREATE TABLE log_acoes (
    id         BIGSERIAL PRIMARY KEY,
    personagem_id BIGINT,
    acao       VARCHAR(50) NOT NULL,
    detalhes   JSONB,
    timestamp  TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    
    CONSTRAINT fk_log_personagem FOREIGN KEY (personagem_id) REFERENCES personagens(id) ON DELETE SET NULL
);

CREATE TABLE sistema_config (
    chave VARCHAR(50) PRIMARY KEY,
    valor TEXT NOT NULL,
    descricao TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ---------- Índices para Performance ----------
CREATE INDEX idx_mobs_sala ON mobs(sala_id);
CREATE INDEX idx_mobs_vivo ON mobs(sala_id) WHERE vida > 0;
CREATE INDEX idx_pers_sala ON personagens(sala_atual_id);
CREATE INDEX idx_pers_faccao ON personagens(faccao_id) WHERE faccao_id IS NOT NULL;
CREATE INDEX idx_drops_item ON mob_drops(item_id);
CREATE INDEX idx_personagens_jogador ON personagens(jogador_id);
CREATE INDEX idx_inventario_personagem ON inventario(personagem_id);
CREATE INDEX idx_combates_data ON combates(data_hora);
CREATE INDEX idx_combates_personagem ON combates(personagem_id);
CREATE INDEX idx_caminhos_origem ON caminhos(sala_origem);
CREATE INDEX idx_missoes_jogador_status ON missoes_jogador(status);
CREATE INDEX idx_missoes_jogador_personagem ON missoes_jogador(personagem_id);
CREATE INDEX idx_mob_tipos_tipo ON mob_tipos(tipo);
CREATE INDEX idx_itens_sala_sala ON itens_sala(sala_id);
CREATE INDEX idx_log_acoes_timestamp ON log_acoes(timestamp);
CREATE INDEX idx_log_acoes_personagem ON log_acoes(personagem_id);

-- ---------- Views Úteis ----------
CREATE VIEW view_personagens_completos AS
SELECT 
    p.id,
    j.username,
    cp.nome as classe,
    p.nivel,
    p.vida,
    p.vida_max,
    p.experiencia,
    p.reputacao,
    p.carteira,
    p.ataque,
    p.defesa,
    f.nome as faccao,
    s.nome as sala_atual,
    s.tipo as tipo_sala
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
JOIN classe_personagem cp ON p.classe_id = cp.id
LEFT JOIN faccoes f ON p.faccao_id = f.id
JOIN salas s ON p.sala_atual_id = s.id;

CREATE VIEW view_ranking_reputacao AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY p.reputacao DESC, p.experiencia DESC) as posicao,
    j.username,
    p.reputacao,
    p.experiencia,
    p.nivel,
    f.nome as faccao
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
LEFT JOIN faccoes f ON p.faccao_id = f.id
ORDER BY p.reputacao DESC, p.experiencia DESC;

CREATE VIEW view_estatisticas_combate AS
SELECT 
    p.id,
    j.username,
    COUNT(c.id) as total_combates,
    COUNT(CASE WHEN c.resultado = 'vitoria' THEN 1 END) as vitorias,
    COUNT(CASE WHEN c.resultado = 'derrota' THEN 1 END) as derrotas,
    COUNT(CASE WHEN c.resultado = 'fugiu' THEN 1 END) as fugas,
    ROUND(
        COUNT(CASE WHEN c.resultado = 'vitoria' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(c.id), 0), 2
    ) as taxa_vitoria
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
LEFT JOIN combates c ON p.id = c.personagem_id
GROUP BY p.id, j.username;

-- ---------- Configurações Iniciais do Sistema ----------
INSERT INTO sistema_config (chave, valor, descricao) VALUES 
    ('max_nivel', '100', 'Nível máximo de personagens'),
    ('xp_por_nivel', '1000', 'XP necessária por nível'),
    ('taxa_respawn_mobs', '300', 'Tempo de respawn em segundos'),
    ('max_inventario', '50', 'Máximo de tipos de itens no inventário'),
    ('safe_zones_combat', 'false', 'Permitir combate em safe zones'),
    ('pvp_enabled', 'true', 'Sistema PvP habilitado'),
    ('auto_save', '60', 'Auto-save a cada X segundos'),
    ('mundo_ativo', 'true', 'Mundo está ativo para jogadores');

-- ---------- Funções de Utilidade ----------
CREATE OR REPLACE FUNCTION calcular_nivel_por_xp(xp BIGINT) 
RETURNS INT AS $$
BEGIN
    RETURN GREATEST(1, FLOOR(xp / 1000.0) + 1);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION calcular_xp_necessaria(nivel INT) 
RETURNS BIGINT AS $$
BEGIN
    RETURN (nivel - 1) * 1000;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ---------- Validação: Verificar DDL Criado ----------
DO $$
DECLARE
    table_count INT;
    index_count INT;
    view_count INT;
BEGIN
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
    
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public';
    
    SELECT COUNT(*) INTO view_count 
    FROM information_schema.views 
    WHERE table_schema = 'public';
    
    RAISE NOTICE 'DDL Aprimorado criado com sucesso:';
    RAISE NOTICE '✓ Tabelas: %', table_count;
    RAISE NOTICE '✓ Índices: %', index_count;
    RAISE NOTICE '✓ Views: %', view_count;
    RAISE NOTICE '✓ Constraints e validações implementadas';
    RAISE NOTICE '✓ Sistema de auditoria e logs';
    RAISE NOTICE '✓ Configurações do sistema';
    RAISE NOTICE '';
    RAISE NOTICE 'Database District ZER0 estruturado e otimizado!';
END
$$; 
