USE district_zero;

BEGIN;

-- ---------- Jogadores ----------
INSERT INTO jogadores (username, senha_hash, xCoord, yCoord) VALUES
  ('user_2077',  '$2b$12$hash_placeholder_12345', 0, 0),
  ('user_aria',  '$2b$12$hash_placeholder_67890', 0, 0);

-- ---------- Salas ----------
INSERT INTO salas (nome, tipo, xCoord, yCoord, descricao) VALUES
  ('Beco do Neon Enferrujado',        'normal',    0, 0, 'Beco úmido e mal-iluminado.'),
  ('Mercado de Chips Clandestino',    'safe-zone', 0, 1, 'Feira de implantes fora da lei.'),
  ('Data-Bank Abandonado da OmniCorp','dungeon',   1, 1, 'Servidor repleto de IAs renegadas.'),
  ('Clínica "Deus Ex Machina"',       'safe-zone', 1, 2, 'Instala aprimoramentos sem perguntas.'),
  ('O Ninho do Corvo',                'normal',    2, 2, 'Infohub de elite.'),
  ('Templo do Núcleo',                'safe-zone', 2, 3, 'Refúgio tecno-xamã.'),
  ('Estação de Recarga Abandonada',   'normal',    3, 3, 'Domínio de gangues.'),
  ('Avenida dos Servidores',          'normal',    3, 4, 'Corredor de rumores e dados.'),
  ('Fábrica Desativada da OmniCorp',  'dungeon',   4, 4, 'Ruínas industriais cheias de armadilhas.'),
  ('Laboratório de Testes Genéticos', 'dungeon',   4, 5, 'Experimentos biotecnológicos ativos.'),
  ('Refúgio Nômade',                  'safe-zone', 5, 5, 'Base móvel camuflada.');

-- ---------- Itens ----------
INSERT INTO itens (nome, tipo, descricao, raridade, valor) VALUES
  ('Neuro-estimulante K-7',      'chip',         'Aumenta reflexos.',                    'Comum',    50),
  ('Data-Knife',                'arma',         'Lâmina que rouba dados.',              'Incomum',  150),
  ('Kit Sutura "TraumaZero"',   'consumivel',   'Cura emergencial.',                    'Comum',    75),
  ('Chip "Fantasma"',           'chip',         'Camuflagem ótica.',                    'Raro',     500),
  ('Braço Cibernético',         'aprimoramento','Força bruta extrema.',                 'Épico',   1200),
  ('Cred-Stick',                'dado',         'Armazena créditos anônimos.',          'Variável', 100),
  ('Ampola de Nanomeds',        'consumivel',   'Nanorrobôs de cura.',                  'Raro',     300),
  ('Pulseira Jammer',           'chip',         'Bloqueia rastreamento.',               'Incomum',  180),
  ('Espingarda de Pulso',       'arma',         'Projéteis de energia.',                'Raro',     700),
  ('Implante Memória Expand.',  'aprimoramento','Mais armazenamento cerebral.',         'Épico',   1500),
  ('Roupa Cibernética Nômade',  'aprimoramento','Fibra óptica tática.',                 'Épico',   1200),
  ('Disco de Dados Misterioso', 'dado',         'Informação desconhecida.',             'Variável', 250);

-- ---------- Facções ----------
INSERT INTO faccoes (nome, descricao, reputacao) VALUES
  ('Filhos de Turing', 'Hackers libertários.',                 100),
  ('Vanguarda Cromada','Mercenários transumanistas.',           50),
  ('Sindicato da Sucata','Engenheiros catadores.',              75),
  ('Culto do Silício', 'Tecno-xamãs transcendentes.',          60),
  ('Aliança Nômade',   'Sobreviventes urbanos móveis.',        80);

-- ---------- Classes ----------
INSERT INTO classe_personagem (nome) VALUES
  ('Hacker'), ('Mercenário'), ('Tecno-Xamã'), ('Nômade Urbano');

INSERT INTO classes_especiais (classe_id, titulo, poder_especial) VALUES
  (1,'Netrunner',        'Sobrecarrega sistemas robóticos.'),
  (2,'Soldado de Rua',   'Adrenalina: +dano por 3 turnos.'),
  (3,'Oráculo Digital',  'Ritual: +esquiva e crítico.'),
  (4,'Sobrevivente Urb.', 'Furtividade máxima.');

-- ---------- Personagens ----------
INSERT INTO personagens
  (jogador_id,classe_id,nivel,vida,experiencia,reputacao,carteira,ataque,defesa,faccao_id,sala_atual_id)
VALUES
  (1,1,1,100,0,0,250,10,10,NULL,1),
  (2,4,1,120,0,10,300,15,15,5,11);

-- ---------- Mobs ----------
INSERT INTO mobs
  (nome,vida,ataque,defesa,sala_id) VALUES
  ('Drone OmniCorp',          50,15,10,1),
  ('Rato Sucata',             30,20, 5,3),
  ('Segurança Ciborgue',     120,35,25,3),
  ('Unidade Expurgo K9',     500,60,40,3),
  ('Sentinela do Núcleo',     80,25,18,6),
  ('Gangue Plugada',          45,20,10,7),
  ('Híbrido Experimental',   200,50,30,10),
  ('Caçador Nômade',         100,32,18,11),
  ('Drone Predador',          65,22,15,9);

-- ---------- Tipos de Mob ----------
INSERT INTO mob_tipos (mob_id,tipo,poder_especial) VALUES
  (1,'normal',NULL), (2,'normal',NULL), (3,'normal',NULL),
  (5,'normal',NULL), (6,'normal',NULL), (7,'normal',NULL),
  (8,'normal',NULL), (9,'normal',NULL),
  (4,'chefe','Canhão de Plasma: ignora defesa.');

-- ---------- Drops ----------
INSERT INTO mob_drops (mob_id,item_id,chance) VALUES
  (1,1 ,0.30),
  (2,6 ,0.10),
  (3,2 ,0.20),
  (4,5 ,1.00),
  (5,7 ,0.40),
  (6,8 ,0.30),
  (7,10,0.50),
  (8,11,0.70),
  (9,9 ,0.30);

-- ---------- Itens em salas ----------
INSERT INTO itens_sala (sala_id,item_id,quantidade) VALUES
  (1,3,1),   -- TraumaZero no beco
  (2,6,5),   -- Cred-Sticks no mercado
  (4,1,3);   -- Neuro-est. na clínica

-- ---------- Inventário inicial ----------
INSERT INTO inventario (personagem_id,item_id,quantidade) VALUES
  (1,2,1),
  (1,6,2),
  (2,11,1),
  (2,12,1);

-- ---------- Missões ----------
INSERT INTO missoes (nome,descricao,recompensa,xp_requerido,tipo) VALUES
  ('Pacote de Dados','Entregue dados ao Fixer.','200 Credz + 50 XP',0,'Entrega'),
  ('Limpeza de IA','Desative IA defect.','Chip Fantasma + 150 XP',100,'Invasão'),
  ('Escolta ao Mercado','Proteja Filhos de Turing.','500 Credz + 120 XP',80,'Escolta'),
  ('Caçada ao Disco','Entregue o disco ao Templo.','700 Credz + 100 XP',50,'Entrega'),
  ('Roubo na Fábrica','Recupere peças raras.','Implante Memória + 200 XP',120,'Infiltração'),
  ('Proteja o Refúgio','Defenda base nômade.','500 Credz + 80 XP',60,'Defesa'),
  ('Ritual de Integração','Participe do ritual.','Nanomeds + 60 XP',40,'Evento');

-- ---------- Missões por personagem ----------
INSERT INTO missoes_jogador
  (personagem_id,missao_id,status,progresso) VALUES
  (1,1,'em_andamento',0),
  (2,4,'em_andamento',0);

COMMIT; 