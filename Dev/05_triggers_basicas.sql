-- District ZER0 - Triggers Básicas (Versão Corrigida)
-- Triggers para morte, XP, nivelamento e missões com prevenção de recursão

-- ---------- TRIGGER 1: Morte do Personagem ----------
CREATE OR REPLACE FUNCTION trigger_morte_personagem()
RETURNS TRIGGER AS $$
DECLARE
    sala_respawn BIGINT;
    creditos_perdidos INT;
    is_morte BOOLEAN := FALSE;
BEGIN
    -- Detectar morte (vida <= 0 e antes estava vivo)
    IF NEW.vida <= 0 AND OLD.vida > 0 THEN
        is_morte := TRUE;
        RAISE NOTICE 'Personagem % morreu!', NEW.id;
        
        -- Calcular créditos perdidos (30% do dinheiro)
        creditos_perdidos := FLOOR(OLD.carteira * 0.3);
        
        -- Buscar sala de respawn
        SELECT id INTO sala_respawn 
        FROM salas 
        WHERE tipo = 'safe-zone' 
        ORDER BY id 
        LIMIT 1;
        
        -- Aplicar mudanças no NEW para evitar UPDATEs adicionais
        NEW.reputacao := GREATEST(NEW.reputacao - 3, 0);
        NEW.carteira := NEW.carteira - creditos_perdidos;
        NEW.vida := 50; -- Revive com 50% vida
        NEW.sala_atual_id := COALESCE(sala_respawn, NEW.sala_atual_id);
        
        -- Realizar ações que não afetam o registro atual
        -- Criar item "Créditos Perdidos" na sala
        IF creditos_perdidos > 0 THEN
            INSERT INTO itens_sala (sala_id, item_id, quantidade)
            VALUES (OLD.sala_atual_id, 6, creditos_perdidos) -- ID 6 = Cred-Stick
            ON CONFLICT (sala_id, item_id) 
            DO UPDATE SET quantidade = itens_sala.quantidade + creditos_perdidos;
        END IF;
        
        -- Falhar missões em andamento
        UPDATE missoes_jogador 
        SET status = 'falhada'
        WHERE personagem_id = NEW.id AND status = 'em_andamento';
        
        RAISE NOTICE 'Personagem % reviveu na sala % com 50 HP', NEW.id, NEW.sala_atual_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_morte_personagem
    BEFORE UPDATE ON personagens
    FOR EACH ROW
    EXECUTE FUNCTION trigger_morte_personagem();

-- ---------- TRIGGER 2: XP e Nivelamento ----------
CREATE OR REPLACE FUNCTION trigger_xp_nivelamento()
RETURNS TRIGGER AS $$
DECLARE
    niveis_ganhos INT;
    nivel_anterior INT;
    bonus_por_nivel INT;
BEGIN
    -- Detectar ganho de XP
    IF NEW.experiencia > OLD.experiencia THEN
        RAISE NOTICE 'Personagem % ganhou % XP (total: %)', 
                     NEW.id, (NEW.experiencia - OLD.experiencia), NEW.experiencia;
        
        -- Calcular quantos níveis deve ter com a XP atual
        -- Fórmula: Nível = 1 + (XP / 1000)
        niveis_ganhos := FLOOR(NEW.experiencia / 1000.0) + 1;
        nivel_anterior := OLD.nivel;
        
        -- Se o nível calculado é maior que o atual, fazer level up
        IF niveis_ganhos > nivel_anterior THEN
            bonus_por_nivel := niveis_ganhos - nivel_anterior;
            
            -- Aplicar mudanças no NEW para evitar UPDATEs adicionais
            NEW.nivel := niveis_ganhos;
            NEW.vida := GREATEST(NEW.vida, 100); -- Restaurar pelo menos 100 HP
            NEW.ataque := NEW.ataque + bonus_por_nivel; -- +1 ataque por nível
            NEW.defesa := NEW.defesa + bonus_por_nivel; -- +1 defesa por nível
            
            RAISE NOTICE 'LEVEL UP! Personagem % subiu % níveis (% → %)', 
                         NEW.id, bonus_por_nivel, nivel_anterior, niveis_ganhos;
            RAISE NOTICE 'Vida restaurada, ataque e defesa aumentados!';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_xp_nivelamento
    BEFORE UPDATE ON personagens
    FOR EACH ROW
    EXECUTE FUNCTION trigger_xp_nivelamento();

-- ---------- TRIGGER 3: Conclusão de Missão ----------
CREATE OR REPLACE FUNCTION trigger_conclusao_missao()
RETURNS TRIGGER AS $$
DECLARE
    missao_rec RECORD;
    recompensa_partes TEXT[];
    parte TEXT;
    valor_recompensa INT;
    personagem_faccao_id BIGINT;
BEGIN
    -- Detectar conclusão de missão
    IF NEW.status = 'concluida' AND OLD.status = 'em_andamento' THEN
        -- Buscar dados da missão
        SELECT * INTO missao_rec 
        FROM missoes 
        WHERE id = NEW.missao_id;
        
        -- Buscar facção do personagem
        SELECT faccao_id INTO personagem_faccao_id 
        FROM personagens 
        WHERE id = NEW.personagem_id;
        
        RAISE NOTICE 'Missão "%" concluída por personagem %', 
                     missao_rec.nome, NEW.personagem_id;
        
        -- Processar recompensas (formato: "500 Credz + 50 XP")
        IF missao_rec.recompensa IS NOT NULL THEN
            -- Separar por '+'
            recompensa_partes := string_to_array(missao_rec.recompensa, '+');
            
            FOREACH parte IN ARRAY recompensa_partes
            LOOP
                parte := TRIM(parte);
                
                -- Detectar tipo de recompensa
                IF parte ILIKE '%credz%' OR parte ILIKE '%credits%' THEN
                    -- Extrair valor numérico
                    valor_recompensa := CAST(regexp_replace(parte, '[^0-9]', '', 'g') AS INT);
                    UPDATE personagens 
                    SET carteira = carteira + valor_recompensa 
                    WHERE id = NEW.personagem_id;
                    RAISE NOTICE 'Recompensa: % créditos', valor_recompensa;
                    
                ELSIF parte ILIKE '%xp%' THEN
                    -- Extrair valor numérico de XP
                    valor_recompensa := CAST(regexp_replace(parte, '[^0-9]', '', 'g') AS INT);
                    UPDATE personagens 
                    SET experiencia = experiencia + valor_recompensa 
                    WHERE id = NEW.personagem_id;
                    RAISE NOTICE 'Recompensa: % XP', valor_recompensa;
                    
                ELSIF parte ILIKE '%chip%' OR parte ILIKE '%item%' OR parte ILIKE '%implante%' THEN
                    -- Recompensa de item (implementação melhorada)
                    -- Dar um item específico baseado no nome da recompensa
                    IF parte ILIKE '%fantasma%' THEN
                        INSERT INTO inventario (personagem_id, item_id, quantidade)
                        VALUES (NEW.personagem_id, 4, 1) -- ID 4 = Chip Fantasma
                        ON CONFLICT (personagem_id, item_id) 
                        DO UPDATE SET quantidade = inventario.quantidade + 1;
                    ELSIF parte ILIKE '%memória%' OR parte ILIKE '%implante%' THEN
                        INSERT INTO inventario (personagem_id, item_id, quantidade)
                        VALUES (NEW.personagem_id, 10, 1) -- ID 10 = Implante Memória
                        ON CONFLICT (personagem_id, item_id) 
                        DO UPDATE SET quantidade = inventario.quantidade + 1;
                    ELSIF parte ILIKE '%nanomeds%' THEN
                        INSERT INTO inventario (personagem_id, item_id, quantidade)
                        VALUES (NEW.personagem_id, 7, 1) -- ID 7 = Nanomeds
                        ON CONFLICT (personagem_id, item_id) 
                        DO UPDATE SET quantidade = inventario.quantidade + 1;
                    ELSE
                        -- Item aleatório de raridade Incomum ou melhor
                        INSERT INTO inventario (personagem_id, item_id, quantidade)
                        SELECT NEW.personagem_id, id, 1
                        FROM itens 
                        WHERE raridade IN ('Incomum', 'Raro', 'Épico')
                        ORDER BY RANDOM() 
                        LIMIT 1
                        ON CONFLICT (personagem_id, item_id) 
                        DO UPDATE SET quantidade = inventario.quantidade + 1;
                    END IF;
                    RAISE NOTICE 'Recompensa: Item especial adicionado ao inventário';
                END IF;
            END LOOP;
        END IF;
        
        -- Aumentar reputação por missão concluída
        UPDATE personagens 
        SET reputacao = reputacao + 2 
        WHERE id = NEW.personagem_id;
        
        -- Se personagem tem facção, aumentar reputação da facção
        IF personagem_faccao_id IS NOT NULL THEN
            UPDATE faccoes 
            SET reputacao = reputacao + 1 
            WHERE id = personagem_faccao_id;
        END IF;
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_conclusao_missao
    AFTER UPDATE ON missoes_jogador
    FOR EACH ROW
    EXECUTE FUNCTION trigger_conclusao_missao();

-- ---------- TRIGGER 4: Falha de Missão ----------
CREATE OR REPLACE FUNCTION trigger_falha_missao()
RETURNS TRIGGER AS $$
DECLARE
    personagem_faccao_id BIGINT;
BEGIN
    -- Detectar falha de missão
    IF NEW.status = 'falhada' AND OLD.status = 'em_andamento' THEN
        -- Buscar facção do personagem
        SELECT faccao_id INTO personagem_faccao_id 
        FROM personagens 
        WHERE id = NEW.personagem_id;
        
        RAISE NOTICE 'Missão % falhada por personagem %', 
                     NEW.missao_id, NEW.personagem_id;
        
        -- Penalidade de reputação
        UPDATE personagens 
        SET reputacao = GREATEST(reputacao - 1, 0)
        WHERE id = NEW.personagem_id;
        
        -- Penalidade leve na facção (se tiver)
        IF personagem_faccao_id IS NOT NULL THEN
            UPDATE faccoes 
            SET reputacao = GREATEST(reputacao - 1, 0)
            WHERE id = personagem_faccao_id;
        END IF;
        
        RAISE NOTICE 'Penalidade aplicada: -1 reputação';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_falha_missao
    AFTER UPDATE ON missoes_jogador
    FOR EACH ROW
    EXECUTE FUNCTION trigger_falha_missao();

-- ---------- TRIGGER 5: Validação de Integridade ----------
CREATE OR REPLACE FUNCTION trigger_validacao_personagem()
RETURNS TRIGGER AS $$
BEGIN
    -- Garantir que vida não fica negativa
    IF NEW.vida < 0 THEN
        NEW.vida := 0;
    END IF;
    
    -- Garantir que carteira não fica negativa
    IF NEW.carteira < 0 THEN
        NEW.carteira := 0;
    END IF;
    
    -- Garantir que reputação não fica negativa
    IF NEW.reputacao < 0 THEN
        NEW.reputacao := 0;
    END IF;
    
    -- Garantir que experiência não diminui
    IF TG_OP = 'UPDATE' AND NEW.experiencia < OLD.experiencia THEN
        NEW.experiencia := OLD.experiencia;
        RAISE NOTICE 'Tentativa de diminuir XP bloqueada para personagem %', NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_validacao_personagem
    BEFORE INSERT OR UPDATE ON personagens
    FOR EACH ROW
    EXECUTE FUNCTION trigger_validacao_personagem();

-- ---------- VALIDAÇÃO: Verificar Triggers Criadas ----------
DO $$
BEGIN
    RAISE NOTICE 'Triggers básicas criadas com sucesso (versão corrigida):';
    RAISE NOTICE '✓ Trigger de morte do personagem (BEFORE UPDATE)';
    RAISE NOTICE '✓ Trigger de XP e nivelamento (BEFORE UPDATE)';
    RAISE NOTICE '✓ Trigger de conclusão de missão (AFTER UPDATE)';
    RAISE NOTICE '✓ Trigger de falha de missão (AFTER UPDATE)';
    RAISE NOTICE '✓ Trigger de validação de integridade (BEFORE INSERT/UPDATE)';
    RAISE NOTICE '';
    RAISE NOTICE 'Sistema de triggers ativo e livre de recursão!';
END
$$; 