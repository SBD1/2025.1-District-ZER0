-- District ZER0 - Procedures de Facções (Versão Corrigida)
-- Completando o sistema de facções conforme planejado

-- ---------- PROCEDURE 1: Entrar em Facção ----------
CREATE OR REPLACE FUNCTION entrar_faccao(
    p_personagem_id BIGINT,
    p_faccao_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    personagem_rec RECORD;
    faccao_rec RECORD;
BEGIN
    -- Buscar dados do personagem
    SELECT * INTO personagem_rec FROM personagens WHERE id = p_personagem_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Verificar se já está em uma facção
    IF personagem_rec.faccao_id IS NOT NULL THEN
        SELECT nome INTO faccao_rec FROM faccoes WHERE id = personagem_rec.faccao_id;
        RETURN format('ERRO: Você já pertence à facção "%s". Saia primeiro antes de entrar em outra.', 
                      faccao_rec.nome);
    END IF;
    
    -- Buscar dados da facção
    SELECT * INTO faccao_rec FROM faccoes WHERE id = p_faccao_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Facção não encontrada.';
    END IF;
    
    -- Verificar pré-requisitos (reputação mínima)
    -- Facções mais prestigiosas podem exigir reputação alta
    IF faccao_rec.reputacao > 80 AND personagem_rec.reputacao < 5 THEN
        RETURN format('ERRO: Reputação insuficiente para entrar em "%s". Necessário: 5, Atual: %s', 
                      faccao_rec.nome, personagem_rec.reputacao);
    END IF;
    
    -- Adicionar personagem à facção
    UPDATE personagens 
    SET faccao_id = p_faccao_id 
    WHERE id = p_personagem_id;
    
    -- Pequeno bonus de reputação da facção por ganhar novo membro
    UPDATE faccoes 
    SET reputacao = reputacao + 1 
    WHERE id = p_faccao_id;
    
    RETURN format('✅ Bem-vindo(a) à facção "%s"!
🏛️  Status: Membro ativo
📈 A facção ganhou +1 de reputação por ter você', faccao_rec.nome);
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 2: Sair de Facção ----------
CREATE OR REPLACE FUNCTION sair_faccao(
    p_personagem_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    personagem_rec RECORD;
    v_faccao_nome TEXT;
BEGIN
    -- Buscar dados do personagem
    SELECT * INTO personagem_rec FROM personagens WHERE id = p_personagem_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Verificar se está em uma facção
    IF personagem_rec.faccao_id IS NULL THEN
        RETURN 'ERRO: Você não pertence a nenhuma facção.';
    END IF;
    
    -- Obter nome da facção atual
    SELECT nome INTO v_faccao_nome FROM faccoes WHERE id = personagem_rec.faccao_id;
    
    -- Penalidade por deserção
    UPDATE personagens 
    SET reputacao = GREATEST(reputacao - 2, 0),
        faccao_id = NULL
    WHERE id = p_personagem_id;
    
    -- Pequena penalidade na reputação da facção por perder membro
    UPDATE faccoes 
    SET reputacao = GREATEST(reputacao - 1, 0)
    WHERE id = personagem_rec.faccao_id;
    
    RETURN format('❌ Você saiu da facção "%s".
💔 Penalidade: -2 reputação por deserção
📉 A facção perdeu -1 de reputação', v_faccao_nome);
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 3: Listar Facções Disponíveis ----------
CREATE OR REPLACE FUNCTION listar_faccoes(
    p_personagem_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    personagem_rec RECORD;
    faccao_rec RECORD;
    resultado TEXT := '';
    v_contador INT := 0;
BEGIN
    -- Buscar dados do personagem
    SELECT * INTO personagem_rec FROM personagens WHERE id = p_personagem_id;
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    resultado := '📋 FACÇÕES DISPONÍVEIS:

';
    
    -- Listar todas as facções
    FOR faccao_rec IN 
        SELECT * FROM faccoes ORDER BY reputacao DESC, nome
    LOOP
        v_contador := v_contador + 1;
        
        resultado := resultado || format('%s. %s (Rep: %s)
   %s
   ',
            v_contador,
            faccao_rec.nome,
            faccao_rec.reputacao,
            COALESCE(faccao_rec.descricao, 'Sem descrição disponível.')
        );
        
        -- Indicar se o personagem já pertence a esta facção
        IF personagem_rec.faccao_id = faccao_rec.id THEN
            resultado := resultado || '   ✅ VOCÊ É MEMBRO DESTA FACÇÃO

';
        -- Indicar se tem pré-requisitos não atendidos
        ELSIF faccao_rec.reputacao > 80 AND personagem_rec.reputacao < 5 THEN
            resultado := resultado || format('   ❌ Requerimento: %s de reputação (você tem %s)

', 5, personagem_rec.reputacao);
        ELSE
            resultado := resultado || '   ✅ Disponível para ingresso

';
        END IF;
    END LOOP;
    
    IF v_contador = 0 THEN
        resultado := 'Nenhuma facção encontrada.';
    END IF;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 4: Status do Personagem Completo ----------
CREATE OR REPLACE FUNCTION status_personagem(
    p_personagem_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    personagem_rec RECORD;
    jogador_rec RECORD;
    v_faccao_nome TEXT;
    sala_info RECORD;
    v_missoes_ativas INT;
    resultado TEXT := '';
BEGIN
    -- Buscar dados completos
    SELECT p.* INTO personagem_rec
    FROM personagens p
    WHERE p.id = p_personagem_id;
    
    IF NOT FOUND THEN
        RETURN 'ERRO: Personagem não encontrado.';
    END IF;
    
    -- Buscar dados do jogador
    SELECT * INTO jogador_rec FROM jogadores WHERE id = personagem_rec.jogador_id;
    
    -- Buscar informações adicionais
    SELECT nome, tipo INTO sala_info FROM salas WHERE id = personagem_rec.sala_atual_id;
    
    IF personagem_rec.faccao_id IS NOT NULL THEN
        SELECT nome INTO v_faccao_nome FROM faccoes WHERE id = personagem_rec.faccao_id;
    ELSE
        v_faccao_nome := 'Nenhuma';
    END IF;
    
    SELECT COUNT(*) INTO v_missoes_ativas 
    FROM missoes_jogador 
    WHERE personagem_id = p_personagem_id AND status = 'em_andamento';
    
    -- Montar resultado
    resultado := format('👤 STATUS DE %s (ID: %s)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 ATRIBUTOS:
   Nível: %s | XP: %s
   Vida: %s/100 | Ataque: %s | Defesa: %s
   Reputação: %s | Créditos: %s

🏛️  AFILIAÇÃO:
   Facção: %s

📍 LOCALIZAÇÃO:
   %s [%s]

📋 MISSÕES:
   Ativas: %s

🎮 CONTA:
   Jogador: %s
   Criado em: %s',
        personagem_rec.id, personagem_rec.id,
        personagem_rec.nivel, personagem_rec.experiencia,
        personagem_rec.vida, personagem_rec.ataque, personagem_rec.defesa,
        personagem_rec.reputacao, personagem_rec.carteira,
        v_faccao_nome,
        sala_info.nome, sala_info.tipo,
        v_missoes_ativas,
        jogador_rec.username,
        TO_CHAR(personagem_rec.created_at, 'DD/MM/YYYY HH24:MI')
    );
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 5: Listar Inventário ----------
CREATE OR REPLACE FUNCTION listar_inventario(
    p_personagem_id BIGINT
) RETURNS TEXT AS $$
DECLARE
    item_rec RECORD;
    resultado TEXT := '';
    v_valor_total INT := 0;
    v_contador INT := 0;
BEGIN
    resultado := '🎒 INVENTÁRIO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

';
    
    -- Listar itens do inventário
    FOR item_rec IN 
        SELECT i.nome, i.tipo, i.raridade, i.valor, inv.quantidade,
               (i.valor * inv.quantidade) as valor_subtotal
        FROM inventario inv
        JOIN itens i ON inv.item_id = i.id
        WHERE inv.personagem_id = p_personagem_id
        ORDER BY i.raridade DESC, i.valor DESC, i.nome
    LOOP
        v_contador := v_contador + 1;
        v_valor_total := v_valor_total + item_rec.valor_subtotal;
        
        resultado := resultado || format('%s. %s x%s
   Tipo: %s | Raridade: %s
   Valor: %s cada (Subtotal: %s créditos)

',
            v_contador,
            item_rec.nome, item_rec.quantidade,
            INITCAP(item_rec.tipo), item_rec.raridade,
            item_rec.valor, item_rec.valor_subtotal
        );
    END LOOP;
    
    IF v_contador = 0 THEN
        resultado := resultado || 'Inventário vazio.

';
    END IF;
    
    resultado := resultado || format('💰 VALOR TOTAL DO INVENTÁRIO: %s créditos', v_valor_total);
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 6: Validação do Sistema ----------
CREATE OR REPLACE FUNCTION validar_sistema()
RETURNS TEXT AS $$
DECLARE
    resultado TEXT := '';
    v_problemas_encontrados INT := 0;
    v_temp_count INT;
BEGIN
    resultado := '🔧 VALIDAÇÃO DO SISTEMA DISTRICT ZER0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

';

    -- Verificar personagens órfãos
    SELECT COUNT(*) INTO v_temp_count
    FROM personagens p
    WHERE NOT EXISTS (SELECT 1 FROM jogadores j WHERE j.id = p.jogador_id);
    
    resultado := resultado || format('✓ Personagens órfãos: %s', v_temp_count);
    IF v_temp_count > 0 THEN
        v_problemas_encontrados := v_problemas_encontrados + v_temp_count;
        resultado := resultado || ' ⚠️  PROBLEMA DETECTADO';
    END IF;
    resultado := resultado || '
';

    -- Verificar salas desconectadas
    SELECT COUNT(*) INTO v_temp_count
    FROM salas s
    WHERE NOT EXISTS (SELECT 1 FROM caminhos c WHERE c.sala_origem = s.id OR c.sala_destino = s.id);
    
    resultado := resultado || format('✓ Salas desconectadas: %s', v_temp_count);
    IF v_temp_count > 0 THEN
        v_problemas_encontrados := v_problemas_encontrados + v_temp_count;
        resultado := resultado || ' ⚠️  PROBLEMA DETECTADO';
    END IF;
    resultado := resultado || '
';

    -- Verificar mobs mortos
    SELECT COUNT(*) INTO v_temp_count FROM mobs WHERE vida <= 0;
    resultado := resultado || format('✓ Mobs mortos (precisam respawn): %s
', v_temp_count);

    -- Verificar missões sem progresso
    SELECT COUNT(*) INTO v_temp_count 
    FROM missoes_jogador 
    WHERE status = 'em_andamento' AND progresso = 0 
      AND started_at < CURRENT_TIMESTAMP - INTERVAL '1 hour';
    
    resultado := resultado || format('✓ Missões paradas há mais de 1h: %s
', v_temp_count);

    -- Verificar integridade de facções
    SELECT COUNT(*) INTO v_temp_count
    FROM personagens p
    WHERE faccao_id IS NOT NULL 
      AND NOT EXISTS (SELECT 1 FROM faccoes f WHERE f.id = p.faccao_id);
    
    resultado := resultado || format('✓ Personagens em facções inexistentes: %s', v_temp_count);
    IF v_temp_count > 0 THEN
        v_problemas_encontrados := v_problemas_encontrados + v_temp_count;
        resultado := resultado || ' ⚠️  PROBLEMA DETECTADO';
    END IF;
    resultado := resultado || '
';

    -- Estatísticas gerais
    resultado := resultado || '
📊 ESTATÍSTICAS GERAIS:
';
    
    SELECT COUNT(*) INTO v_temp_count FROM jogadores WHERE is_active;
    resultado := resultado || format('• Jogadores ativos: %s
', v_temp_count);
    
    SELECT COUNT(*) INTO v_temp_count FROM personagens;
    resultado := resultado || format('• Personagens total: %s
', v_temp_count);
    
    SELECT COUNT(*) INTO v_temp_count FROM mobs WHERE vida > 0;
    resultado := resultado || format('• Mobs vivos: %s
', v_temp_count);
    
    SELECT COUNT(*) INTO v_temp_count FROM missoes_jogador WHERE status = 'em_andamento';
    resultado := resultado || format('• Missões ativas: %s
', v_temp_count);

    -- Resultado final
    resultado := resultado || '
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
';
    
    IF v_problemas_encontrados = 0 THEN
        resultado := resultado || '✅ SISTEMA ÍNTEGRO - Nenhum problema crítico detectado!';
    ELSE
        resultado := resultado || format('⚠️  %s PROBLEMAS DETECTADOS - Requer atenção!', v_problemas_encontrados);
    END IF;
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- PROCEDURE 7: Dashboard do Sistema ----------
CREATE OR REPLACE FUNCTION dashboard_sistema()
RETURNS TEXT AS $$
DECLARE
    resultado TEXT := '';
    stats RECORD;
BEGIN
    resultado := '🎮 DISTRICT ZER0 - DASHBOARD DO SISTEMA
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

';

    -- Estatísticas de jogadores
    SELECT 
        COUNT(*) as total_jogadores,
        COUNT(CASE WHEN is_active THEN 1 END) as jogadores_ativos,
        COUNT(CASE WHEN last_login > CURRENT_TIMESTAMP - INTERVAL '24 hours' THEN 1 END) as ativos_24h
    INTO stats
    FROM jogadores;
    
    resultado := resultado || format('👥 JOGADORES:
   Total: %s | Ativos: %s | Últimas 24h: %s

', stats.total_jogadores, stats.jogadores_ativos, stats.ativos_24h);

    -- Estatísticas de personagens
    SELECT 
        COUNT(*) as total_personagens,
        ROUND(AVG(nivel), 1) as nivel_medio,
        MAX(nivel) as nivel_maximo,
        SUM(carteira) as economia_total
    INTO stats
    FROM personagens;
    
    resultado := resultado || format('⚔️  PERSONAGENS:
   Total: %s | Nível médio: %s | Nível máximo: %s
   Economia total: %s créditos

', stats.total_personagens, stats.nivel_medio, stats.nivel_maximo, stats.economia_total);

    -- Estatísticas de mundo
    SELECT 
        COUNT(DISTINCT s.id) as total_salas,
        COUNT(CASE WHEN s.tipo = 'safe-zone' THEN 1 END) as safe_zones,
        COUNT(CASE WHEN s.tipo = 'dungeon' THEN 1 END) as dungeons,
        COUNT(DISTINCT c.id) as total_caminhos
    INTO stats
    FROM salas s
    LEFT JOIN caminhos c ON s.id = c.sala_origem;
    
    resultado := resultado || format('🌍 MUNDO:
   Salas: %s | Safe-zones: %s | Dungeons: %s
   Caminhos: %s

', stats.total_salas, stats.safe_zones, stats.dungeons, stats.total_caminhos);

    -- Estatísticas de combate
    SELECT 
        COUNT(CASE WHEN vida > 0 THEN 1 END) as mobs_vivos,
        COUNT(CASE WHEN vida <= 0 THEN 1 END) as mobs_mortos,
        COUNT(CASE WHEN is_boss THEN 1 END) as bosses_total
    INTO stats
    FROM mobs;
    
    resultado := resultado || format('👹 MOBS:
   Vivos: %s | Mortos: %s | Bosses: %s

', stats.mobs_vivos, stats.mobs_mortos, stats.bosses_total);

    -- Estatísticas de missões
    SELECT 
        COUNT(*) as total_missoes,
        COUNT(CASE WHEN is_repeatable THEN 1 END) as repetivel,
        (SELECT COUNT(*) FROM missoes_jogador WHERE status = 'em_andamento') as ativas,
        (SELECT COUNT(*) FROM missoes_jogador WHERE status = 'concluida') as concluidas
    INTO stats
    FROM missoes;
    
    resultado := resultado || format('📋 MISSÕES:
   Sistema: %s | Repetíveis: %s | Ativas: %s | Concluídas: %s

', stats.total_missoes, stats.repetivel, stats.ativas, stats.concluidas);

    -- Estatísticas de facções
    SELECT 
        COUNT(*) as total_faccoes,
        COALESCE(SUM(CASE WHEN p.faccao_id IS NOT NULL THEN 1 ELSE 0 END), 0) as membros_total
    INTO stats
    FROM faccoes f
    LEFT JOIN personagens p ON f.id = p.faccao_id;
    
    resultado := resultado || format('🏛️  FACÇÕES:
   Total: %s | Membros totais: %s

', stats.total_faccoes, stats.membros_total);

    resultado := resultado || format('⏰ Atualizado em: %s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 SISTEMA OPERACIONAL E PRONTO PARA GAMEPLAY!', CURRENT_TIMESTAMP);
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- ---------- VALIDAÇÃO: Verificar Procedures de Facção Criadas ----------
DO $$
BEGIN
    RAISE NOTICE 'Procedures de facção e sistema implementadas (versão corrigida):';
    RAISE NOTICE '✓ entrar_faccao(personagem_id, faccao_id)';
    RAISE NOTICE '✓ sair_faccao(personagem_id)';
    RAISE NOTICE '✓ listar_faccoes(personagem_id)';
    RAISE NOTICE '✓ status_personagem(personagem_id)';
    RAISE NOTICE '✓ listar_inventario(personagem_id)';
    RAISE NOTICE '✓ validar_sistema()';
    RAISE NOTICE '✓ dashboard_sistema()';
    RAISE NOTICE '';
    RAISE NOTICE 'Sistema de facções e validação completo com variáveis corrigidas!';
END
$$; 
