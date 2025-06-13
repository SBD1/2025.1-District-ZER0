SET search_path TO dz;

-- Exemplo: salas e mobs (verifique resultados)
SELECT s.nome                               AS sala,
       COALESCE(STRING_AGG(m.nome, ', '), '-') AS mobs
FROM salas s
LEFT JOIN mobs m ON m.sala_id = s.id
GROUP BY s.id
ORDER BY s.nome;

-- Top-5 itens mais comuns nos inventários
SELECT i.nome, SUM(inv.quantidade) AS total
FROM inventario inv
JOIN itens i ON i.id = inv.item_id
GROUP BY i.id
ORDER BY total DESC
LIMIT 5;

-- Ranking de riqueza por jogador
SELECT j.username, SUM(p.carteira) AS total_credz
FROM jogadores j
JOIN personagens p ON p.jogador_id = j.id
GROUP BY j.username
ORDER BY total_credz DESC;

-- Personagens em dungeons + nº de mobs na sala
SELECT p.id, j.username, s.nome AS dungeon, COUNT(m.id) AS mobs_na_sala
FROM personagens p
JOIN jogadores j ON j.id = p.jogador_id
JOIN salas s     ON s.id = p.sala_atual_id
LEFT JOIN mobs m ON m.sala_id = s.id
WHERE s.tipo = 'dungeon'
GROUP BY p.id, j.username, s.nome;