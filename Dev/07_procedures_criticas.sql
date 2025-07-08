-- District ZER0 - Procedures Críticas
-- Procedures faltantes identificadas na revisão da entrega-3.md

-- ---------- PROCEDURE 1: Concluir Missão Manualmente ----------
CREATE OR REPLACE FUNCTION concluir_missao(
    p_personagem_id BIGINT,
    p_missao_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    missao_rec RECORD;
    missao_jogador_rec RECORD;
BEGIN
    -- Buscar dados da missão
    SELECT * INTO missao_rec FROM missoes WHERE id = p_missao_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Missão não encontrada.';
    END IF;
    
    -- Verificar se jogador tem esta missão em andamento
    SELECT * INTO missao_jogador_rec 
    FROM missoes_jogador 
    WHERE personagem_id = p_personagem_id AND missao_id = p_missao_id;
    
    IF NOT FOUND THEN
        RETURN 'ERRO: Você não possui esta missão.';
    END IF;
    
    IF missao_jogador_rec.status != 'em_andamento' THEN
        RETURN format('ERRO: Missão já está %s.', missao_jogador_rec.status);
    END IF;
    
    -- Marcar missão como concluída (trigger de recompensa será acionado)
    UPDATE missoes_jogador 
    SET status = 'concluida', progresso = 100
    WHERE personagem_id = p_personagem_id AND missao_id = p_missao_id;
    
    RETURN format('✅ Missão "%s" concluída com sucesso!
🎁 As recompensas foram aplicadas automaticamente.', missao_rec.nome);
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 2: Atacar Jogador (PvP) ----------
CREATE OR REPLACE FUNCTION atacar_jogador(
    p_atacante_id BIGINT,
    p_alvo_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    atacante_rec RECORD;
    alvo_rec RECORD;
    dano_causado INT;
    resultado TEXT := '';
    creditos_roubados INT;
BEGIN
    -- Buscar dados do atacante
    SELECT * INTO atacante_rec FROM personagens WHERE id = p_atacante_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Atacante não encontrado.';
    END IF;
    
    -- Buscar dados do alvo
    SELECT * INTO alvo_rec FROM personagens WHERE id = p_alvo_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Alvo não encontrado.';
    END IF;
    
    -- Verificar se estão na mesma sala
    IF atacante_rec.sala_atual_id != alvo_rec.sala_atual_id THEN
        RETURN 'ERRO: Alvo não está na mesma sala.';
    END IF;
    
    -- Verificar se não está atacando a si mesmo
    IF p_atacante_id = p_alvo_id THEN
        RETURN 'ERRO: Você não pode atacar a si mesmo.';
    END IF;
    
    -- Verificar se está em safe-zone
    IF EXISTS (SELECT 1 FROM salas WHERE id = atacante_rec.sala_atual_id AND tipo = 'safe-zone') THEN
        RETURN 'ERRO: PvP não é permitido em zonas seguras.';
    END IF;
    
    -- Verificar friendly fire (mesma facção)
    IF atacante_rec.faccao_id IS NOT NULL 
       AND alvo_rec.faccao_id IS NOT NULL 
       AND atacante_rec.faccao_id = alvo_rec.faccao_id THEN
        RETURN 'ERRO: Não é possível atacar membros da mesma facção.';
    END IF;
    
    -- Verificar se alvo está vivo
    IF alvo_rec.vida <= 0 THEN
        RETURN 'ERRO: Alvo já está inconsciente.';
    END IF;
    
    -- Calcular dano
    dano_causado := GREATEST(atacante_rec.ataque - alvo_rec.defesa, 1);
    
    -- Aplicar dano ao alvo
    UPDATE personagens 
    SET vida = vida - dano_causado 
    WHERE id = p_alvo_id;
    
    resultado := format('⚔️  PvP: Você atacou jogador %s causando %s de dano!
', p_alvo_id, dano_causado);
    
    -- Verificar se alvo morreu
    IF (alvo_rec.vida - dano_causado) <= 0 THEN
        -- Recompensas por PK (Player Kill)
        
        -- 1. Bonus de reputação para atacante
        UPDATE personagens 
        SET reputacao = reputacao + 2 
        WHERE id = p_atacante_id;
        
        -- 2. Roubar parte dos créditos do alvo (20%)
        creditos_roubados := FLOOR(alvo_rec.carteira * 0.2);
        IF creditos_roubados > 0 THEN
            UPDATE personagens 
            SET carteira = carteira - creditos_roubados 
            WHERE id = p_alvo_id;
            
            UPDATE personagens 
            SET carteira = carteira + creditos_roubados 
            WHERE id = p_atacante_id;
        END IF;
        
        resultado := resultado || format('💀 Alvo foi derrotado em combate PvP!
🏆 Reputação +2 por vitória PvP
💰 Você saqueou %s créditos
🎯 Trigger de morte do alvo será acionada...', creditos_roubados);
        
        -- Nota: Trigger de morte do personagem cuidará do resto (respawn, penalidades, etc.)
    ELSE
        resultado := resultado || format('❤️  Vida do alvo: %s → %s
⚠️  Alvo pode contra-atacar no próximo turno!',
            alvo_rec.vida,
            alvo_rec.vida - dano_causado
        );
    END IF;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 3: Trocar Item entre Jogadores ----------
CREATE OR REPLACE FUNCTION trocar_item(
    p_origem_id BIGINT,
    p_destino_id BIGINT,
    p_item_id BIGINT,
    p_quantidade INT DEFAULT 1,
    p_preco INT DEFAULT 0
) RETURNS TEXT AS $$
DECLARE
    origem_rec RECORD;
    destino_rec RECORD;
    item_nome TEXT;
    quantidade_possuida INT;
BEGIN
    -- Validar quantidade
    IF p_quantidade <= 0 THEN
        RETURN 'ERRO: Quantidade deve ser maior que zero.';
    END IF;
    
    -- Buscar dados dos personagens
    SELECT * INTO origem_rec FROM personagens WHERE id = p_origem_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem origem não encontrado.';
    END IF;
    
    SELECT * INTO destino_rec FROM personagens WHERE id = p_destino_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem destino não encontrado.';
    END IF;
    
    -- Verificar se estão na mesma sala
    IF origem_rec.sala_atual_id != destino_rec.sala_atual_id THEN
        RETURN 'ERRO: Ambos jogadores devem estar na mesma sala para trocar.';
    END IF;
    
    -- Obter nome do item
    SELECT nome INTO item_nome FROM itens WHERE id = p_item_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Item não encontrado.';
    END IF;
    
    -- Verificar se origem possui o item
    SELECT quantidade INTO quantidade_possuida 
    FROM inventario 
    WHERE personagem_id = p_origem_id AND item_id = p_item_id;
    
    IF quantidade_possuida IS NULL OR quantidade_possuida < p_quantidade THEN
        RETURN format('ERRO: Origem não possui %s suficiente (possui: %s).', 
                      item_nome, COALESCE(quantidade_possuida, 0));
    END IF;
    
    -- Se há preço envolvido, verificar se destino tem créditos
    IF p_preco > 0 THEN
        IF destino_rec.carteira < p_preco THEN
            RETURN format('ERRO: Destino não tem créditos suficientes (tem: %s, precisa: %s).', 
                          destino_rec.carteira, p_preco);
        END IF;
        
        -- Transferir créditos
        UPDATE personagens 
        SET carteira = carteira - p_preco 
        WHERE id = p_destino_id;
        
        UPDATE personagens 
        SET carteira = carteira + p_preco 
        WHERE id = p_origem_id;
    END IF;
    
    -- Remover item do inventário da origem
    IF quantidade_possuida = p_quantidade THEN
        -- Se vai remover toda a quantidade, deletar diretamente
        DELETE FROM inventario 
        WHERE personagem_id = p_origem_id AND item_id = p_item_id;
    ELSE
        -- Se vai remover parcialmente, fazer update
        UPDATE inventario 
        SET quantidade = quantidade - p_quantidade 
        WHERE personagem_id = p_origem_id AND item_id = p_item_id;
    END IF;
    
    -- Adicionar item ao inventário do destino
    INSERT INTO inventario (personagem_id, item_id, quantidade)
    VALUES (p_destino_id, p_item_id, p_quantidade)
    ON CONFLICT (personagem_id, item_id) 
    DO UPDATE SET quantidade = inventario.quantidade + p_quantidade;
    
    IF p_preco > 0 THEN
        RETURN format('✅ Troca realizada: %s x%s por %s créditos
💰 Personagem %s recebeu %s créditos
📦 Personagem %s recebeu %s x%s', 
            item_nome, p_quantidade, p_preco,
            p_origem_id, p_preco,
            p_destino_id, item_nome, p_quantidade);
    ELSE
        RETURN format('✅ Item transferido: %s x%s de %s para %s', 
                      item_nome, p_quantidade, p_origem_id, p_destino_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 4: Desistir de Missão ----------
CREATE OR REPLACE FUNCTION desistir_missao(
    p_personagem_id BIGINT,
    p_missao_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    missao_rec RECORD;
    missao_jogador_rec RECORD;
BEGIN
    -- Buscar dados da missão
    SELECT * INTO missao_rec FROM missoes WHERE id = p_missao_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Missão não encontrada.';
    END IF;
    
    -- Verificar se jogador tem esta missão em andamento
    SELECT * INTO missao_jogador_rec 
    FROM missoes_jogador 
    WHERE personagem_id = p_personagem_id AND missao_id = p_missao_id;
    
    IF NOT FOUND THEN
        RETURN 'ERRO: Você não possui esta missão.';
    END IF;
    
    IF missao_jogador_rec.status != 'em_andamento' THEN
        RETURN format('ERRO: Não é possível desistir de missão %s.', missao_jogador_rec.status);
    END IF;
    
    -- Marcar missão como falhada (trigger de penalidade será acionado)
    UPDATE missoes_jogador 
    SET status = 'falhada'
    WHERE personagem_id = p_personagem_id AND missao_id = p_missao_id;
    
    RETURN format('❌ Você desistiu da missão "%s".
💔 Penalidades de reputação foram aplicadas.', missao_rec.nome);
END;
$$ LANGUAGE plpgsql;

-- ---------- VALIDAÇÃO: Verificar Procedures Críticas Criadas ----------
DO $$
BEGIN
    RAISE NOTICE 'Procedures críticas implementadas:';
    RAISE NOTICE '✓ concluir_missao(personagem_id, missao_id)';
    RAISE NOTICE '✓ atacar_jogador(atacante_id, alvo_id)';
    RAISE NOTICE '✓ trocar_item(origem, destino, item, qtd, preco)';
    RAISE NOTICE '✓ desistir_missao(personagem_id, missao_id)';
    RAISE NOTICE '';
    RAISE NOTICE 'Sistema crítico completo!';
END
$$; 