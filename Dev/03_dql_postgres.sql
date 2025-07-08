-- District ZER0 - Queries de Demonstração e Validação (PostgreSQL)
-- Este arquivo é executado automaticamente após DDL, DML e correções durante a inicialização do container

-- ========================================
-- SEÇÃO 1: VALIDAÇÃO BÁSICA DO MUNDO
-- ========================================

-- Query 1: Mapeamento completo do mundo
SELECT 
    s.id,
    s.nome AS sala,
    s.tipo,
    s.max_players,
    COALESCE(STRING_AGG(
        CASE c.direcao 
            WHEN 'N' THEN 'Norte→' || s2.nome
            WHEN 'S' THEN 'Sul→' || s2.nome  
            WHEN 'L' THEN 'Leste→' || s2.nome
            WHEN 'O' THEN 'Oeste→' || s2.nome
        END, ' | '
    ), 'Sem saídas') AS conexoes
FROM salas s
LEFT JOIN caminhos c ON s.id = c.sala_origem
LEFT JOIN salas s2 ON c.sala_destino = s2.id
GROUP BY s.id, s.nome, s.tipo, s.max_players
ORDER BY s.id;

-- Query 2: População atual e distribuição por salas
SELECT 
    s.nome AS sala,
    s.tipo,
    COUNT(p.id) AS personagens_presentes,
    s.max_players,
    ROUND(COUNT(p.id) * 100.0 / s.max_players, 1) AS ocupacao_percentual,
    COALESCE(STRING_AGG(j.username, ', '), 'Vazio') AS usuarios_presentes
FROM salas s
LEFT JOIN personagens p ON s.id = p.sala_atual_id
LEFT JOIN jogadores j ON p.jogador_id = j.id
GROUP BY s.id, s.nome, s.tipo, s.max_players
ORDER BY ocupacao_percentual DESC, s.nome;

-- Query 3: Inventário de itens por sala (mundo persistente)
SELECT 
    s.nome AS sala,
    COUNT(its.id) AS tipos_de_itens,
    SUM(its.quantidade) AS total_itens,
    STRING_AGG(
        i.nome || ' (' || its.quantidade || ')', 
        ', ' ORDER BY i.raridade DESC, i.valor DESC
    ) AS itens_disponiveis
FROM salas s
LEFT JOIN itens_sala its ON s.id = its.sala_id
LEFT JOIN itens i ON its.item_id = i.id
GROUP BY s.id, s.nome
HAVING COUNT(its.id) > 0
ORDER BY total_itens DESC;

-- ========================================
-- SEÇÃO 2: SISTEMA DE COMBATE E MOBS
-- ========================================

-- Query 4: Status detalhado dos mobs e distribuição
SELECT 
    s.nome AS sala,
    m.nome AS mob,
    mt.tipo,
    m.vida || '/' || m.vida_max AS vida_status,
    m.ataque,
    m.defesa,
    m.xp_reward,
    CASE WHEN m.vida > 0 THEN '🟢 Vivo' ELSE '💀 Morto' END AS status,
    COUNT(md.item_id) AS itens_dropados,
    mt.poder_especial
FROM mobs m
JOIN salas s ON m.sala_id = s.id
LEFT JOIN mob_tipos mt ON m.id = mt.mob_id
LEFT JOIN mob_drops md ON m.id = md.mob_id
GROUP BY s.nome, m.id, m.nome, mt.tipo, m.vida, m.vida_max, m.ataque, m.defesa, m.xp_reward, mt.poder_especial
ORDER BY s.nome, mt.tipo DESC, m.xp_reward DESC;

-- Query 5: Sistema de drops e economia de itens
SELECT 
    m.nome AS mob,
    i.nome AS item_drop,
    i.raridade,
    i.valor,
    md.chance * 100 AS chance_percentual,
    md.quantidade_min || '-' || md.quantidade_max AS quantidade_range,
    i.valor * ((md.quantidade_min + md.quantidade_max) / 2) * md.chance AS valor_esperado
FROM mob_drops md
JOIN mobs m ON md.mob_id = m.id
JOIN itens i ON md.item_id = i.id
ORDER BY valor_esperado DESC, m.nome;

-- ========================================
-- SEÇÃO 3: PERSONAGENS E PROGRESSÃO
-- ========================================

-- Query 6: Ranking completo de personagens
SELECT 
    ROW_NUMBER() OVER (ORDER BY p.experiencia DESC, p.reputacao DESC) AS ranking,
    j.username,
    cp.nome AS classe,
    p.nivel,
    p.experiencia,
    calcular_xp_necessaria(p.nivel + 1) - p.experiencia AS xp_para_proximo,
    p.reputacao,
    p.carteira,
    f.nome AS faccao,
    s.nome AS localizacao_atual,
    CASE WHEN j.is_active THEN '🟢 Ativo' ELSE '🔴 Inativo' END AS status_jogador
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
JOIN classe_personagem cp ON p.classe_id = cp.id
LEFT JOIN faccoes f ON p.faccao_id = f.id
JOIN salas s ON p.sala_atual_id = s.id
ORDER BY ranking;

-- Query 7: Análise de inventários e patrimônio
SELECT 
    j.username,
    p.nivel,
    p.carteira,
    COUNT(inv.id) AS tipos_de_itens,
    SUM(inv.quantidade) AS total_itens,
    SUM(i.valor * inv.quantidade) AS valor_inventario,
    p.carteira + SUM(i.valor * inv.quantidade) AS patrimonio_total,
    ROUND(SUM(i.peso * inv.quantidade), 2) AS peso_total
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
LEFT JOIN inventario inv ON p.id = inv.personagem_id
LEFT JOIN itens i ON inv.item_id = i.id
GROUP BY j.username, p.id, p.nivel, p.carteira
ORDER BY patrimonio_total DESC;

-- Query 8: Estatísticas de combate detalhadas
SELECT 
    j.username,
    p.nivel,
    COUNT(c.id) AS total_combates,
    COUNT(CASE WHEN c.resultado = 'vitoria' THEN 1 END) AS vitorias,
    COUNT(CASE WHEN c.resultado = 'derrota' THEN 1 END) AS derrotas,
    COUNT(CASE WHEN c.resultado = 'fugiu' THEN 1 END) AS fugas,
    ROUND(
        COUNT(CASE WHEN c.resultado = 'vitoria' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(c.id), 0), 1
    ) AS taxa_vitoria,
    SUM(c.xp_ganho) AS xp_total_ganho,
    COUNT(CASE WHEN c.mob_id IN (SELECT mob_id FROM mob_tipos WHERE tipo = 'chefe') THEN 1 END) AS bosses_derrotados
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
LEFT JOIN combates c ON p.id = c.personagem_id
GROUP BY j.username, p.id, p.nivel
ORDER BY taxa_vitoria DESC, vitorias DESC;

-- ========================================
-- SEÇÃO 4: SISTEMA DE MISSÕES
-- ========================================

-- Query 9: Status completo das missões
SELECT 
    j.username,
    m.nome AS missao,
    m.tipo,
    m.dificuldade,
    mj.status,
    mj.progresso || '%' AS progresso,
    m.recompensa,
    CASE 
        WHEN mj.status = 'em_andamento' THEN 
            EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - mj.started_at)) / 3600 || ' horas'
        WHEN mj.status = 'concluida' THEN
            EXTRACT(EPOCH FROM (mj.completed_at - mj.started_at)) / 3600 || ' horas'
        ELSE 'N/A'
    END AS tempo_missao,
    CASE 
        WHEN p.experiencia >= m.xp_requerido AND p.nivel >= m.nivel_requerido 
        THEN '✅ Qualificado' 
        ELSE '❌ Não qualificado' 
    END AS status_pre_requisitos
FROM missoes_jogador mj
JOIN personagens p ON mj.personagem_id = p.id
JOIN jogadores j ON p.jogador_id = j.id
JOIN missoes m ON mj.missao_id = m.id
ORDER BY j.username, mj.status, m.dificuldade DESC;

-- Query 10: Missões disponíveis por personagem
SELECT 
    j.username,
    p.nivel,
    p.experiencia,
    COUNT(m.id) AS missoes_disponiveis,
    STRING_AGG(
        m.nome || ' (' || m.dificuldade || ')', 
        ', ' ORDER BY m.dificuldade DESC
    ) AS missoes_podem_fazer
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
CROSS JOIN missoes m
WHERE p.experiencia >= m.xp_requerido 
  AND p.nivel >= m.nivel_requerido
  AND NOT EXISTS (
      SELECT 1 FROM missoes_jogador mj 
      WHERE mj.personagem_id = p.id AND mj.missao_id = m.id
  )
GROUP BY j.username, p.id, p.nivel, p.experiencia
ORDER BY missoes_disponiveis DESC;

-- ========================================
-- SEÇÃO 5: SISTEMA DE FACÇÕES
-- ========================================

-- Query 11: Análise completa das facções
SELECT 
    f.nome AS faccao,
    f.reputacao,
    COUNT(p.id) AS membros_atuais,
    f.max_members,
    ROUND(COUNT(p.id) * 100.0 / f.max_members, 1) AS ocupacao_percentual,
    AVG(p.nivel) AS nivel_medio_membros,
    AVG(p.reputacao) AS reputacao_media_membros,
    SUM(p.carteira) AS riqueza_total_faccao,
    STRING_AGG(j.username, ', ' ORDER BY p.nivel DESC) AS membros
FROM faccoes f
LEFT JOIN personagens p ON f.id = p.faccao_id
LEFT JOIN jogadores j ON p.jogador_id = j.id
GROUP BY f.id, f.nome, f.reputacao, f.max_members
ORDER BY f.reputacao DESC, membros_atuais DESC;

-- Query 12: Comparação de força entre facções
SELECT 
    f.nome AS faccao,
    COUNT(p.id) AS membros,
    AVG(p.ataque) AS ataque_medio,
    AVG(p.defesa) AS defesa_medio,
    AVG(p.nivel) AS nivel_medio,
    SUM(p.ataque + p.defesa) AS poder_total,
    COUNT(CASE WHEN p.nivel >= 3 THEN 1 END) AS veteranos,
    RANK() OVER (ORDER BY SUM(p.ataque + p.defesa) DESC) AS ranking_poder
FROM faccoes f
LEFT JOIN personagens p ON f.id = p.faccao_id
GROUP BY f.id, f.nome
HAVING COUNT(p.id) > 0
ORDER BY poder_total DESC;

-- ========================================
-- SEÇÃO 6: SISTEMA ECONÔMICO E ITENS
-- ========================================

-- Query 13: Economia de itens e raridade
SELECT 
    i.raridade,
    COUNT(i.id) AS tipos_disponveis,
    AVG(i.valor) AS valor_medio,
    MIN(i.valor) AS valor_minimo,
    MAX(i.valor) AS valor_maximo,
    SUM(COALESCE(inv.quantidade, 0) + COALESCE(its.quantidade, 0)) AS quantidade_total_mundo,
    COUNT(DISTINCT inv.personagem_id) AS jogadores_possuem,
    COUNT(DISTINCT its.sala_id) AS salas_contem
FROM itens i
LEFT JOIN inventario inv ON i.id = inv.item_id
LEFT JOIN itens_sala its ON i.id = its.item_id
GROUP BY i.raridade
ORDER BY 
    CASE i.raridade 
        WHEN 'Comum' THEN 1
        WHEN 'Incomum' THEN 2
        WHEN 'Raro' THEN 3
        WHEN 'Épico' THEN 4
        WHEN 'Variável' THEN 5
    END;

-- Query 14: Itens mais valiosos e sua distribuição
SELECT 
    i.nome,
    i.raridade,
    i.tipo,
    i.valor,
    COALESCE(SUM(inv.quantidade), 0) AS em_inventarios,
    COALESCE(SUM(its.quantidade), 0) AS em_salas,
    COALESCE(SUM(inv.quantidade), 0) + COALESCE(SUM(its.quantidade), 0) AS total_mundo,
    i.valor * (COALESCE(SUM(inv.quantidade), 0) + COALESCE(SUM(its.quantidade), 0)) AS valor_total_economia
FROM itens i
LEFT JOIN inventario inv ON i.id = inv.item_id
LEFT JOIN itens_sala its ON i.id = its.item_id
GROUP BY i.id, i.nome, i.raridade, i.tipo, i.valor
HAVING COALESCE(SUM(inv.quantidade), 0) + COALESCE(SUM(its.quantidade), 0) > 0
ORDER BY valor_total_economia DESC
LIMIT 10;

-- ========================================
-- SEÇÃO 7: LOGS E AUDITORIA
-- ========================================

-- Query 15: Atividade recente no mundo
SELECT 
    la.timestamp,
    j.username,
    la.acao,
    CASE 
        WHEN la.acao = 'login' THEN '🚪 Entrou no jogo'
        WHEN la.acao = 'combate' THEN '⚔️ Combate realizado'
        WHEN la.acao = 'movimento' THEN '🚶 Movimentação'
        WHEN la.acao = 'missao_completa' THEN '✅ Missão concluída'
        WHEN la.acao = 'item_pego' THEN '📦 Item coletado'
        ELSE '❓ ' || la.acao
    END AS acao_formatada,
    la.detalhes::TEXT AS detalhes
FROM log_acoes la
LEFT JOIN personagens p ON la.personagem_id = p.id
LEFT JOIN jogadores j ON p.jogador_id = j.id
ORDER BY la.timestamp DESC
LIMIT 20;

-- ========================================
-- SEÇÃO 8: VIEWS ÚTEIS E RELATÓRIOS
-- ========================================

-- Query 16: Usando as views criadas para relatórios
SELECT 'Personagens Completos' AS relatorio;
SELECT * FROM view_personagens_completos ORDER BY nivel DESC, experiencia DESC;

SELECT 'Ranking de Reputação' AS relatorio;
SELECT * FROM view_ranking_reputacao LIMIT 10;

SELECT 'Estatísticas de Combate' AS relatorio;
SELECT * FROM view_estatisticas_combate WHERE total_combates > 0 ORDER BY taxa_vitoria DESC;

-- ========================================
-- SEÇÃO 9: VALIDAÇÕES DE INTEGRIDADE
-- ========================================

-- Query 17: Verificações de integridade do sistema
SELECT 'Verificações de Integridade do Sistema' AS relatorio;

-- Personagens órfãos (sem jogador)
SELECT 'Personagens Órfãos' AS verificacao, COUNT(*) AS problemas
FROM personagens p
WHERE NOT EXISTS (SELECT 1 FROM jogadores j WHERE j.id = p.jogador_id);

-- Personagens em salas inexistentes
SELECT 'Personagens em Salas Inexistentes' AS verificacao, COUNT(*) AS problemas
FROM personagens p
WHERE NOT EXISTS (SELECT 1 FROM salas s WHERE s.id = p.sala_atual_id);

-- Itens em inventários sem referência válida
SELECT 'Itens Inválidos em Inventários' AS verificacao, COUNT(*) AS problemas
FROM inventario inv
WHERE NOT EXISTS (SELECT 1 FROM itens i WHERE i.id = inv.item_id)
   OR NOT EXISTS (SELECT 1 FROM personagens p WHERE p.id = inv.personagem_id);

-- Mobs em salas inexistentes
SELECT 'Mobs em Salas Inexistentes' AS verificacao, COUNT(*) AS problemas
FROM mobs m
WHERE NOT EXISTS (SELECT 1 FROM salas s WHERE s.id = m.sala_id);

-- Caminhos com salas inexistentes
SELECT 'Caminhos Inválidos' AS verificacao, COUNT(*) AS problemas
FROM caminhos c
WHERE NOT EXISTS (SELECT 1 FROM salas s WHERE s.id = c.sala_origem)
   OR NOT EXISTS (SELECT 1 FROM salas s WHERE s.id = c.sala_destino);

-- ========================================
-- SEÇÃO 10: ESTATÍSTICAS GERAIS DO SISTEMA
-- ========================================

-- Query 18: Dashboard geral do District ZER0
SELECT 
    'DASHBOARD DISTRICT ZER0' AS relatorio,
    CURRENT_TIMESTAMP AS timestamp_relatorio;

SELECT 
    'Jogadores Registrados' AS metrica,
    COUNT(*) AS valor,
    COUNT(CASE WHEN is_active THEN 1 END) || ' ativos' AS detalhes
FROM jogadores
UNION ALL
SELECT 
    'Personagens Criados' AS metrica,
    COUNT(*) AS valor,
    'Nível médio: ' || ROUND(AVG(nivel), 1) AS detalhes
FROM personagens
UNION ALL
SELECT 
    'Salas no Mundo' AS metrica,
    COUNT(*) AS valor,
    COUNT(CASE WHEN tipo = 'safe-zone' THEN 1 END) || ' zonas seguras' AS detalhes
FROM salas
UNION ALL
SELECT 
    'Mobs Ativos' AS metrica,
    COUNT(CASE WHEN vida > 0 THEN 1 END) AS valor,
    COUNT(CASE WHEN vida <= 0 THEN 1 END) || ' mortos' AS detalhes
FROM mobs
UNION ALL
SELECT 
    'Missões no Sistema' AS metrica,
    COUNT(*) AS valor,
    COUNT(CASE WHEN is_repeatable THEN 1 END) || ' repetíveis' AS detalhes
FROM missoes
UNION ALL
SELECT 
    'Itens na Economia' AS metrica,
    SUM(COALESCE(inv.total, 0) + COALESCE(sala.total, 0)) AS valor,
    'Em ' || COUNT(DISTINCT i.id) || ' tipos diferentes' AS detalhes
FROM itens i
LEFT JOIN (SELECT item_id, SUM(quantidade) as total FROM inventario GROUP BY item_id) inv ON i.id = inv.item_id
LEFT JOIN (SELECT item_id, SUM(quantidade) as total FROM itens_sala GROUP BY item_id) sala ON i.id = sala.item_id;

-- Query Final: Confirmação do sistema operacional
SELECT 
    '🎮 DISTRICT ZER0 SISTEMA OPERACIONAL 🎮' AS status,
    COUNT(DISTINCT j.id) || ' jogadores registrados' AS jogadores,
    COUNT(DISTINCT p.id) || ' personagens ativos' AS personagens,
    COUNT(DISTINCT s.id) || ' salas interconectadas' AS mundo,
    COUNT(DISTINCT f.id) || ' facções disponíveis' AS faccoes,
    COUNT(DISTINCT m.id) || ' missões implementadas' AS missoes,
    'Sistema pronto para gameplay completo!' AS mensagem
FROM jogadores j, personagens p, salas s, faccoes f, missoes m; 
