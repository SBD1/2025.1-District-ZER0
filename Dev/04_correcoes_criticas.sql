-- District ZER0 - Correções Críticas
-- Arquivo executado após DDL e DML para implementar melhorias necessárias

-- ---------- CORREÇÃO 1: Tabela de Caminhos para Sistema de Movimento ----------
CREATE TABLE caminhos (
    sala_origem BIGINT NOT NULL,
    direcao CHAR(1) NOT NULL CHECK (direcao IN ('N','S','L','O')),
    sala_destino BIGINT NOT NULL,
    PRIMARY KEY (sala_origem, direcao),
    CONSTRAINT fk_caminhos_origem FOREIGN KEY (sala_origem) REFERENCES salas(id) ON DELETE CASCADE,
    CONSTRAINT fk_caminhos_destino FOREIGN KEY (sala_destino) REFERENCES salas(id) ON DELETE CASCADE
);

-- ---------- CORREÇÃO 2: Constraint Única em Itens_Sala ----------
ALTER TABLE itens_sala 
ADD CONSTRAINT uk_itens_sala_unico UNIQUE (sala_id, item_id);

-- ---------- CORREÇÃO 3: Índices para Performance ----------
CREATE INDEX idx_caminhos_origem ON caminhos(sala_origem);
CREATE INDEX idx_missoes_jogador_status ON missoes_jogador(status);
CREATE INDEX idx_mob_tipos_tipo ON mob_tipos(tipo);

-- ---------- DADOS: Mapeamento das Salas (Mundo Cyberpunk) ----------
-- Criando um mapa navegável das 11 salas existentes
-- Layout do mundo District ZER0:
--
--    [3-DataBank]     [10-Lab.Genético]
--         |                 |
--    [1-Beco] - [2-Mercado] - [4-Clínica] - [5-Ninho]
--         |         |                        |
--    [7-Estação] - [8-Avenida] - [6-Templo] - [9-Fábrica]
--                                    |
--                               [11-Refúgio]

INSERT INTO caminhos (sala_origem, direcao, sala_destino) VALUES
    -- Conexões do Beco do Neon (sala 1)
    (1, 'N', 3),  -- Norte: Data-Bank
    (1, 'L', 2),  -- Leste: Mercado
    (1, 'S', 7),  -- Sul: Estação
    
    -- Conexões do Mercado (sala 2)
    (2, 'O', 1),  -- Oeste: Beco
    (2, 'L', 4),  -- Leste: Clínica
    (2, 'S', 8),  -- Sul: Avenida
    
    -- Conexões do Data-Bank (sala 3)
    (3, 'S', 1),  -- Sul: Beco
    (3, 'L', 10), -- Leste: Lab Genético
    
    -- Conexões da Clínica (sala 4)
    (4, 'O', 2),  -- Oeste: Mercado
    (4, 'L', 5),  -- Leste: Ninho
    
    -- Conexões do Ninho (sala 5)
    (5, 'O', 4),  -- Oeste: Clínica
    (5, 'S', 9),  -- Sul: Fábrica
    
    -- Conexões do Templo (sala 6)
    (6, 'N', 8),  -- Norte: Avenida
    (6, 'L', 9),  -- Leste: Fábrica
    (6, 'S', 11), -- Sul: Refúgio
    
    -- Conexões da Estação (sala 7)
    (7, 'N', 1),  -- Norte: Beco
    (7, 'L', 8),  -- Leste: Avenida
    
    -- Conexões da Avenida (sala 8)
    (8, 'N', 2),  -- Norte: Mercado
    (8, 'O', 7),  -- Oeste: Estação
    (8, 'S', 6),  -- Sul: Templo
    
    -- Conexões da Fábrica (sala 9)
    (9, 'N', 5),  -- Norte: Ninho
    (9, 'O', 6),  -- Oeste: Templo
    
    -- Conexões do Lab Genético (sala 10)
    (10, 'O', 3), -- Oeste: Data-Bank
    
    -- Conexões do Refúgio (sala 11)
    (11, 'N', 6); -- Norte: Templo

-- ---------- VALIDAÇÃO: Verificar Conexões Criadas ----------
DO $$
DECLARE
    total_conexoes INT;
    salas_conectadas INT;
BEGIN
    SELECT COUNT(*) INTO total_conexoes FROM caminhos;
    SELECT COUNT(DISTINCT sala_origem) INTO salas_conectadas FROM caminhos;
    
    RAISE NOTICE 'Sistema de movimento criado:';
    RAISE NOTICE '- Total de conexões: %', total_conexoes;
    RAISE NOTICE '- Salas conectadas: % de 11', salas_conectadas;
    
    IF salas_conectadas < 10 THEN
        RAISE WARNING 'Algumas salas podem estar isoladas!';
    END IF;
END
$$; 