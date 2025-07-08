-- District ZER0 - Procedures Básicas (Versão Aprimorada)
-- Procedures para movimento, combate e manipulação de itens com transações explícitas

-- ---------- PROCEDURE 1: Movimentação entre Salas ----------
CREATE OR REPLACE FUNCTION mover_personagem(
    p_personagem_id INTEGER,
    p_direcao TEXT
) RETURNS TEXT AS $$
DECLARE
    sala_atual INTEGER;
    sala_destino INTEGER;
    info_sala RECORD;
    mobs_na_sala TEXT := '';
    itens_na_sala TEXT := '';
    personagem_nome TEXT;
BEGIN
    -- Validar direção
    IF UPPER(TRIM(p_direcao)) NOT IN ('N', 'S', 'L', 'O') THEN
        RETURN 'ERRO: Direção inválida. Use N, S, L ou O.';
    END IF;
    
    -- Normalizar direção
    p_direcao := UPPER(TRIM(p_direcao));
    
    -- Obter sala atual e nome do personagem
    SELECT p.sala_atual_id, j.username INTO sala_atual, personagem_nome
    FROM personagens p
    JOIN jogadores j ON p.jogador_id = j.id
    WHERE p.id = p_personagem_id;
    
    IF sala_atual IS NULL THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Buscar sala destino
    SELECT c.sala_destino INTO sala_destino 
    FROM caminhos c 
    WHERE c.sala_origem = sala_atual AND c.direcao = p_direcao;
    
    IF sala_destino IS NULL THEN
        RETURN 'Não é possível seguir para ' || p_direcao || '. Caminho bloqueado.';
    END IF;
    
    -- Mover personagem (transação automática da função)
    UPDATE personagens 
    SET sala_atual_id = sala_destino 
    WHERE id = p_personagem_id;
    
    -- Obter informações da nova sala
    SELECT nome, descricao, tipo INTO info_sala 
    FROM salas 
    WHERE id = sala_destino;
    
    -- Listar mobs na sala
    SELECT STRING_AGG(m.nome || ' (HP: ' || m.vida || ')', ', ') INTO mobs_na_sala 
    FROM mobs m 
    WHERE m.sala_id = sala_destino AND m.vida > 0;
    
    -- Listar itens na sala
    SELECT STRING_AGG(i.nome || ' (' || its.quantidade || ')', ', ') INTO itens_na_sala
    FROM itens_sala its
    JOIN itens i ON its.item_id = i.id
    WHERE its.sala_id = sala_destino;
    
    -- Retornar descrição da nova sala
    RETURN format('
🚶 %s moveu-se para %s

🏙️  %s [%s]
%s

%s🤖 Inimigos: %s
💎 Itens: %s

🧭 Direções disponíveis: %s',
        personagem_nome, 
        CASE p_direcao 
            WHEN 'N' THEN 'Norte'
            WHEN 'S' THEN 'Sul'
            WHEN 'L' THEN 'Leste'
            WHEN 'O' THEN 'Oeste'
        END,
        info_sala.nome,
        UPPER(info_sala.tipo),
        COALESCE(info_sala.descricao, 'Área sem descrição.'),
        CASE 
            WHEN info_sala.tipo = 'safe-zone' THEN '🛡️  [ZONA SEGURA] - Sem combate permitido aqui.

' 
            ELSE '' 
        END,
        COALESCE(mobs_na_sala, 'Nenhum'),
        COALESCE(itens_na_sala, 'Nenhum'),
        (SELECT STRING_AGG(direcao || '→' || s.nome, ', ') 
         FROM caminhos c 
         JOIN salas s ON c.sala_destino = s.id 
         WHERE c.sala_origem = sala_destino)
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha ao mover personagem: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 2: Combate contra Mobs ----------
CREATE OR REPLACE FUNCTION atacar_mob(
    p_personagem_id INTEGER,
    p_mob_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    pers_rec RECORD;
    mob_rec RECORD;
    dano_no_mob INTEGER;
    dano_no_pers INTEGER;
    resultado TEXT := '';
    loot_info TEXT := '';
    xp_ganho INTEGER := 0;
    eh_boss BOOLEAN := FALSE;
    items_dropados INTEGER := 0;
BEGIN
    -- Iniciar transação implícita (função PL/pgSQL já tem transação automática)
    
    -- Buscar dados do personagem
    SELECT p.*, j.username INTO pers_rec 
    FROM personagens p 
    JOIN jogadores j ON p.jogador_id = j.id 
    WHERE p.id = p_personagem_id;
    
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Verificar se personagem está vivo
    IF pers_rec.vida <= 0 THEN
        RETURN 'ERRO: Você está inconsciente e não pode atacar.';
    END IF;
    
    -- Buscar dados do mob
    SELECT * INTO mob_rec FROM mobs WHERE id = p_mob_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Inimigo não encontrado.';
    END IF;
    
    -- Verificar se estão na mesma sala
    IF pers_rec.sala_atual_id != mob_rec.sala_id THEN
        RETURN 'ERRO: Inimigo não está na mesma sala.';
    END IF;
    
    -- Verificar se mob está vivo
    IF mob_rec.vida <= 0 THEN
        RETURN 'ERRO: Este inimigo já foi derrotado.';
    END IF;
    
    -- Verificar se está em safe-zone
    IF EXISTS (SELECT 1 FROM salas WHERE id = pers_rec.sala_atual_id AND tipo = 'safe-zone') THEN
        RETURN 'ERRO: Combate não é permitido em zonas seguras.';
    END IF;
    
    -- Calcular dano do personagem no mob
    dano_no_mob := GREATEST(pers_rec.ataque - mob_rec.defesa, 1);
    
    -- Aplicar dano ao mob
    UPDATE mobs 
    SET vida = vida - dano_no_mob 
    WHERE id = p_mob_id;
    
    resultado := format('⚔️  %s atacou %s causando %s de dano!
', pers_rec.username, mob_rec.nome, dano_no_mob);
    
    -- Verificar se mob morreu
    IF (mob_rec.vida - dano_no_mob) <= 0 THEN
        -- Registrar vitória
        INSERT INTO combates (personagem_id, mob_id, resultado, data_hora)
        VALUES (p_personagem_id, p_mob_id, 'vitoria', CURRENT_TIMESTAMP);
        
        -- Verificar se é boss
        SELECT (tipo = 'chefe') INTO eh_boss 
        FROM mob_tipos 
        WHERE mob_id = p_mob_id;
        
        IF eh_boss IS NULL THEN
            eh_boss := FALSE;
        END IF;
        
        -- Calcular XP ganho
        xp_ganho := CASE 
            WHEN eh_boss THEN 200 
            ELSE 50 
        END;
        
        -- Dar XP (trigger de XP cuidará do level up)
        UPDATE personagens 
        SET experiencia = experiencia + xp_ganho 
        WHERE id = p_personagem_id;
        
        -- Processar drops
        INSERT INTO itens_sala (sala_id, item_id, quantidade)
        SELECT mob_rec.sala_id, md.item_id, 1
        FROM mob_drops md
        WHERE md.mob_id = p_mob_id 
        AND RANDOM() <= md.chance
        ON CONFLICT (sala_id, item_id) 
        DO UPDATE SET quantidade = itens_sala.quantidade + 1;
        
        -- Contar itens dropados
        GET DIAGNOSTICS items_dropados = ROW_COUNT;
        
        -- Obter informações dos itens dropados
        SELECT STRING_AGG(i.nome, ', ') INTO loot_info
        FROM mob_drops md
        JOIN itens i ON md.item_id = i.id
        WHERE md.mob_id = p_mob_id AND RANDOM() <= md.chance;
        
        -- Bonus de reputação para boss
        IF eh_boss THEN
            UPDATE personagens 
            SET reputacao = reputacao + 5 
            WHERE id = p_personagem_id;
            
            -- Bonus para facção
            UPDATE faccoes 
            SET reputacao = reputacao + 3 
            WHERE id = pers_rec.faccao_id
            AND pers_rec.faccao_id IS NOT NULL;
        END IF;
        
        resultado := resultado || format('💀 %s foi derrotado!
🎯 XP ganho: %s%s
🏆 Reputação: %s
💰 Loot: %s (%s itens dropados)',
            mob_rec.nome,
            xp_ganho,
            CASE WHEN eh_boss THEN ' (BOSS BONUS!)' ELSE '' END,
            CASE WHEN eh_boss THEN '+5' ELSE '+0' END,
            COALESCE(loot_info, 'Nenhum item dropado'),
            items_dropados
        );
    ELSE
        -- Mob ainda vivo, contra-ataque
        dano_no_pers := GREATEST(mob_rec.ataque - pers_rec.defesa, 1);
        
        -- Aplicar dano ao personagem
        UPDATE personagens 
        SET vida = vida - dano_no_pers 
        WHERE id = p_personagem_id;
        
        resultado := resultado || format('🔥 %s contra-atacou causando %s de dano!
❤️  Sua vida: %s → %s
👹 Vida do inimigo: %s → %s',
            mob_rec.nome,
            dano_no_pers,
            pers_rec.vida,
            pers_rec.vida - dano_no_pers,
            mob_rec.vida,
            mob_rec.vida - dano_no_mob
        );
        
        -- Verificar se personagem morreu
        IF (pers_rec.vida - dano_no_pers) <= 0 THEN
            -- Registrar derrota
            INSERT INTO combates (personagem_id, mob_id, resultado, data_hora)
            VALUES (p_personagem_id, p_mob_id, 'derrota', CURRENT_TIMESTAMP);
            
            resultado := resultado || '

💀 Você foi derrotado... (Trigger de morte será acionada)';
        END IF;
    END IF;
    
    RETURN resultado;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha durante o combate: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 3: Pegar Item ----------
CREATE OR REPLACE FUNCTION pegar_item(
    p_personagem_id INTEGER,
    p_item_id INTEGER,
    p_quantidade INTEGER DEFAULT 1
) RETURNS TEXT AS $$
DECLARE
    sala_atual INTEGER;
    item_nome TEXT;
    quantidade_disponivel INTEGER;
    valor_item INTEGER;
    personagem_nome TEXT;
BEGIN
    -- Validar quantidade
    IF p_quantidade <= 0 THEN
        RETURN 'ERRO: Quantidade deve ser maior que zero.';
    END IF;
    
    -- Obter dados do personagem
    SELECT p.sala_atual_id, j.username INTO sala_atual, personagem_nome
    FROM personagens p
    JOIN jogadores j ON p.jogador_id = j.id
    WHERE p.id = p_personagem_id;
    
    IF sala_atual IS NULL THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Obter dados do item
    SELECT nome, valor INTO item_nome, valor_item FROM itens WHERE id = p_item_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Item não encontrado.';
    END IF;
    
    -- Verificar se item está disponível na sala
    SELECT quantidade INTO quantidade_disponivel 
    FROM itens_sala 
    WHERE sala_id = sala_atual AND item_id = p_item_id;
    
    IF quantidade_disponivel IS NULL OR quantidade_disponivel < p_quantidade THEN
        RETURN format('ERRO: %s não está disponível na sala (disponível: %s).', 
                      item_nome, COALESCE(quantidade_disponivel, 0));
    END IF;
    
    -- Remover item da sala
    UPDATE itens_sala 
    SET quantidade = quantidade - p_quantidade 
    WHERE sala_id = sala_atual AND item_id = p_item_id;
    
    -- Remover entrada se quantidade chegou a zero
    DELETE FROM itens_sala 
    WHERE sala_id = sala_atual AND item_id = p_item_id AND quantidade <= 0;
    
    -- Adicionar ao inventário
    INSERT INTO inventario (personagem_id, item_id, quantidade)
    VALUES (p_personagem_id, p_item_id, p_quantidade)
    ON CONFLICT (personagem_id, item_id) 
    DO UPDATE SET quantidade = inventario.quantidade + p_quantidade;
    
    RETURN format('✅ %s pegou %s x%s (valor: %s créditos cada)', 
                  personagem_nome, item_nome, p_quantidade, valor_item);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha ao pegar item: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 4: Dropar Item ----------
CREATE OR REPLACE FUNCTION dropar_item(
    p_personagem_id INTEGER,
    p_item_id INTEGER,
    p_quantidade INTEGER DEFAULT 1
) RETURNS TEXT AS $$
DECLARE
    sala_atual INTEGER;
    item_nome TEXT;
    quantidade_possuida INTEGER;
    personagem_nome TEXT;
BEGIN
    -- Validar quantidade
    IF p_quantidade <= 0 THEN
        RETURN 'ERRO: Quantidade deve ser maior que zero.';
    END IF;
    
    -- Obter dados do personagem
    SELECT p.sala_atual_id, j.username INTO sala_atual, personagem_nome
    FROM personagens p
    JOIN jogadores j ON p.jogador_id = j.id
    WHERE p.id = p_personagem_id;
    
    IF sala_atual IS NULL THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Obter nome do item
    SELECT nome INTO item_nome FROM itens WHERE id = p_item_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Item não encontrado.';
    END IF;
    
    -- Verificar se personagem possui o item
    SELECT quantidade INTO quantidade_possuida 
    FROM inventario 
    WHERE personagem_id = p_personagem_id AND item_id = p_item_id;
    
    IF quantidade_possuida IS NULL OR quantidade_possuida < p_quantidade THEN
        RETURN format('ERRO: %s não possui %s suficiente (possui: %s).', 
                      personagem_nome, item_nome, COALESCE(quantidade_possuida, 0));
    END IF;
    
    -- Remover do inventário
    UPDATE inventario 
    SET quantidade = quantidade - p_quantidade 
    WHERE personagem_id = p_personagem_id AND item_id = p_item_id;
    
    -- Remover entrada se quantidade chegou a zero
    DELETE FROM inventario 
    WHERE personagem_id = p_personagem_id AND item_id = p_item_id AND quantidade <= 0;
    
    -- Adicionar à sala
    INSERT INTO itens_sala (sala_id, item_id, quantidade)
    VALUES (sala_atual, p_item_id, p_quantidade)
    ON CONFLICT (sala_id, item_id) 
    DO UPDATE SET quantidade = itens_sala.quantidade + p_quantidade;
    
    RETURN format('✅ %s dropou %s x%s', personagem_nome, item_nome, p_quantidade);
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha ao dropar item: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 5: Iniciar Missão ----------
CREATE OR REPLACE FUNCTION iniciar_missao(
    p_personagem_id INTEGER,
    p_missao_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    missao_rec RECORD;
    xp_atual INTEGER;
    missoes_ativas INTEGER;
    personagem_nome TEXT;
BEGIN
    -- Buscar dados da missão
    SELECT * INTO missao_rec FROM missoes WHERE id = p_missao_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Missão não encontrada.';
    END IF;
    
    -- Verificar XP atual e nome do personagem
    SELECT p.experiencia, j.username INTO xp_atual, personagem_nome
    FROM personagens p
    JOIN jogadores j ON p.jogador_id = j.id
    WHERE p.id = p_personagem_id;
    
    IF xp_atual IS NULL THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Verificar pré-requisitos
    IF xp_atual < missao_rec.xp_requerido THEN
        RETURN format('ERRO: XP insuficiente. Necessário: %s, Atual: %s', 
                      missao_rec.xp_requerido, xp_atual);
    END IF;
    
    -- Verificar se já está fazendo esta missão
    IF EXISTS (SELECT 1 FROM missoes_jogador 
               WHERE personagem_id = p_personagem_id AND missao_id = p_missao_id) THEN
        RETURN 'ERRO: Você já possui esta missão.';
    END IF;
    
    -- Verificar limite de missões simultâneas (máximo 3)
    SELECT COUNT(*) INTO missoes_ativas 
    FROM missoes_jogador 
    WHERE personagem_id = p_personagem_id AND status = 'em_andamento';
    
    IF missoes_ativas >= 3 THEN
        RETURN 'ERRO: Você já possui o máximo de 3 missões ativas.';
    END IF;
    
    -- Iniciar missão
    INSERT INTO missoes_jogador (personagem_id, missao_id, status, progresso)
    VALUES (p_personagem_id, p_missao_id, 'em_andamento', 0);
    
    RETURN format('✅ %s iniciou a missão "%s"!
📋 Descrição: %s
🎁 Recompensa: %s
📊 Tipo: %s
🔧 Missões ativas: %s/3',
        personagem_nome,
        missao_rec.nome,
        COALESCE(missao_rec.descricao, 'Sem descrição.'),
        COALESCE(missao_rec.recompensa, 'Indefinida'),
        missao_rec.tipo,
        missoes_ativas + 1
    );
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha ao iniciar missão: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 6: Fugir do Combate ----------
CREATE OR REPLACE FUNCTION fugir_combate(
    p_personagem_id INTEGER,
    p_mob_id INTEGER
) RETURNS TEXT AS $$
DECLARE
    pers_rec RECORD;
    mob_rec RECORD;
    sala_fuga INTEGER;
    direcao_fuga CHAR(1);
    chance_fuga DECIMAL;
    nome_sala_fuga TEXT;
BEGIN
    -- Buscar dados do personagem
    SELECT p.*, j.username INTO pers_rec 
    FROM personagens p 
    JOIN jogadores j ON p.jogador_id = j.id 
    WHERE p.id = p_personagem_id;
    
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Buscar dados do mob
    SELECT * INTO mob_rec FROM mobs WHERE id = p_mob_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Inimigo não encontrado.';
    END IF;
    
    -- Verificar se estão na mesma sala
    IF pers_rec.sala_atual_id != mob_rec.sala_id THEN
        RETURN 'ERRO: Você não está em combate com este inimigo.';
    END IF;
    
    -- Calcular chance de fuga (baseada na diferença de atributos)
    chance_fuga := 0.7 + (pers_rec.defesa - mob_rec.ataque) * 0.02;
    chance_fuga := GREATEST(0.3, LEAST(0.95, chance_fuga));
    
    -- Tentar fugir
    IF RANDOM() <= chance_fuga THEN
        -- Sucesso na fuga - mover para sala adjacente aleatória
        SELECT c.sala_destino, c.direcao INTO sala_fuga, direcao_fuga
        FROM caminhos c
        WHERE c.sala_origem = pers_rec.sala_atual_id
        ORDER BY RANDOM()
        LIMIT 1;
        
        IF sala_fuga IS NOT NULL THEN
            -- Mover personagem
            UPDATE personagens 
            SET sala_atual_id = sala_fuga 
            WHERE id = p_personagem_id;
            
            -- Obter nome da nova sala
            SELECT nome INTO nome_sala_fuga FROM salas WHERE id = sala_fuga;
            
            -- Registrar fuga
            INSERT INTO combates (personagem_id, mob_id, resultado, data_hora)
            VALUES (p_personagem_id, p_mob_id, 'fugiu', CURRENT_TIMESTAMP);
            
            RETURN format('🏃 %s fugiu com sucesso!
🚪 Você correu para %s (%s)
📊 Chance de fuga: %s%%',
                pers_rec.username, 
                nome_sala_fuga,
                CASE direcao_fuga 
                    WHEN 'N' THEN 'Norte'
                    WHEN 'S' THEN 'Sul'
                    WHEN 'L' THEN 'Leste'
                    WHEN 'O' THEN 'Oeste'
                END,
                ROUND(chance_fuga * 100)
            );
        ELSE
            RETURN 'ERRO: Não há saída para fugir!';
        END IF;
    ELSE
        -- Falha na fuga - sofrer ataque do mob
        DECLARE
            dano_mob INTEGER;
        BEGIN
            dano_mob := GREATEST(mob_rec.ataque - pers_rec.defesa, 1);
            
            UPDATE personagens 
            SET vida = vida - dano_mob 
            WHERE id = p_personagem_id;
            
            RETURN format('❌ %s falhou ao tentar fugir!
🔥 %s aproveitou para atacar causando %s de dano!
📊 Chance de fuga era: %s%%',
                pers_rec.username,
                mob_rec.nome,
                dano_mob,
                ROUND(chance_fuga * 100)
            );
        END;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERRO: Falha ao tentar fugir: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ---------- VALIDAÇÃO: Verificar Procedures Criadas ----------
DO $$
BEGIN
    RAISE NOTICE 'Procedures básicas criadas com sucesso (versão aprimorada):';
    RAISE NOTICE '✓ mover_personagem(personagem_id, direcao)';
    RAISE NOTICE '✓ atacar_mob(personagem_id, mob_id)';
    RAISE NOTICE '✓ pegar_item(personagem_id, item_id, quantidade)';
    RAISE NOTICE '✓ dropar_item(personagem_id, item_id, quantidade)';
    RAISE NOTICE '✓ iniciar_missao(personagem_id, missao_id)';
    RAISE NOTICE '✓ fugir_combate(personagem_id, mob_id)';
    RAISE NOTICE '';
    RAISE NOTICE 'Sistema de procedures básicas ativo com transações e validações!';
END
$$; 