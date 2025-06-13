USE district_zero;

-- Exemplo: salas e mobs (verifique resultados)
SELECT s.nome                               AS sala,
       COALESCE(GROUP_CONCAT(m.nome SEPARATOR ', '), '-') AS mobs
FROM salas s
LEFT JOIN mobs m ON m.sala_id = s.id
GROUP BY s.id, s.nome
ORDER BY s.nome;

-- Top-5 itens mais comuns nos inventários
SELECT i.nome, SUM(inv.quantidade) AS total
FROM inventario inv
JOIN itens i ON i.id = inv.item_id
GROUP BY i.id, i.nome
ORDER BY total DESC
LIMIT 5;

-- Ranking de riqueza por jogador
SELECT j.username, SUM(p.carteira) AS total_credz
FROM jogadores j
JOIN personagens p ON p.jogador_id = j.id
GROUP BY j.id, j.username
ORDER BY total_credz DESC;

-- Personagens em dungeons + nº de mobs na sala
SELECT p.id, j.username, s.nome AS dungeon, COUNT(m.id) AS mobs_na_sala
FROM personagens p
JOIN jogadores j ON j.id = p.jogador_id
JOIN salas s     ON s.id = p.sala_atual_id
LEFT JOIN mobs m ON m.sala_id = s.id
WHERE s.tipo = 'dungeon'
GROUP BY p.id, j.username, s.nome;

-- Query adicional: Personagens com seus itens e valores totais
SELECT 
    j.username,
    p.id as personagem_id,
    p.nivel,
    p.carteira,
    SUM(i.valor * inv.quantidade) as valor_inventario,
    p.carteira + COALESCE(SUM(i.valor * inv.quantidade), 0) as patrimonio_total
FROM jogadores j
JOIN personagens p ON j.id = p.jogador_id
LEFT JOIN inventario inv ON p.id = inv.personagem_id
LEFT JOIN itens i ON inv.item_id = i.id
GROUP BY j.id, j.username, p.id, p.nivel, p.carteira
ORDER BY patrimonio_total DESC;

-- Query adicional: Status das missões por jogador
SELECT 
    j.username,
    m.nome as missao,
    m.tipo,
    mj.status,
    mj.progresso,
    m.recompensa
FROM jogadores j
JOIN personagens p ON j.id = p.jogador_id
JOIN missoes_jogador mj ON p.id = mj.personagem_id
JOIN missoes m ON mj.missao_id = m.id
ORDER BY j.username, mj.status, m.nome; 