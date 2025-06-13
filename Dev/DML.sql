BEGIN;

-- ---------- Jogadores ----------
INSERT INTO jogadores (id, username, senha_hash) VALUES
  (1, 'user_2077',  'hash_placeholder_12345'),
  (2, 'user_aria',  'hash_placeholder_67890');

-- ---------- Salas ----------
INSERT INTO salas (id, nome, tipo, descricao) VALUES
  (1, 'Beco do Neon Enferrujado',        'normal',    'Beco úmido e mal-iluminado.'),
  (2, 'Mercado de Chips Clandestino',    'safe-zone', 'Feira de implantes fora da lei.'),
  (3, 'Data-Bank Abandonado da OmniCorp','dungeon',   'Servidor repleto de IAs renegadas.'),
  (4, 'Clínica "Deus Ex Machina"',       'safe-zone', 'Instala aprimoramentos sem perguntas.'),
  (5, 'O Ninho do Corvo',                'normal',    'Infohub de elite.'),
  (6, 'Templo do Núcleo',                'safe-zone', 'Refúgio tecno-xamã.'),
  (7, 'Estação de Recarga Abandonada',   'normal',    'Domínio de gangues.'),
  (8, 'Avenida dos Servidores',          'normal',    'Corredor de rumores e dados.'),
  (9, 'Fábrica Desativada da OmniCorp',  'dungeon',   'Ruínas industriais cheias de armadilhas.'),
  (10,'Laboratório de Testes Genéticos', 'dungeon',   'Experimentos biotecnológicos ativos.'),
  (11,'Refúgio Nômade',                  'safe-zone', 'Base móvel camuflada.');

-- ---------- Itens ----------
INSERT INTO itens (id, nome, tipo, descricao, raridade, valor) VALUES
  (1,  'Neuro-estimulante K-7',      'chip',         'Aumenta reflexos.',                    'Comum',    50),
  (2,  'Data-Knife',                'arma',         'Lâmina que rouba dados.',              'Incomum',  150),
  (3,  'Kit Sutura "TraumaZero"',   'consumivel',   'Cura emergencial.',                    'Comum',    75),
  (4,  'Chip "Fantasma"',           'chip',         'Camuflagem ótica.',                    'Raro',     500),
  (5,  'Braço Cibernético',         'aprimoramento','Força bruta extrema.',                 'Épico',   1200),
  (6,  'Cred-Stick',                'dado',         'Armazena créditos anônimos.',          'Variável', 100),
  (7,  'Ampola de Nanomeds',        'consumivel',   'Nanorrobôs de cura.',                  'Raro',     300),
  (8,  'Pulseira Jammer',           'chip',         'Bloqueia rastreamento.',               'Incomum',  180),
  (9,  'Espingarda de Pulso',       'arma',         'Projéteis de energia.',                'Raro',     700),
  (10, 'Implante Memória Expand.',  'aprimoramento','Mais armazenamento cerebral.',         'Épico',   1500),
  (11, 'Roupa Cibernética Nômade',  'aprimoramento','Fibra óptica tática.',                 'Épico',   1200),
  (12, 'Disco de Dados Misterioso', 'dado',         'Informação desconhecida.',             'Variável', 250);

-- ---------- Facções ----------
INSERT INTO faccoes (id, nome, descricao, reputacao) VALUES
  (1, 'Filhos de Turing', 'Hackers libertários.',                 100),
  (2, 'Vanguarda Cromada','Mercenários transumanistas.',           50),
  (3, 'Sindicato da Sucata','Engenheiros catadores.',              75),
  (4, 'Culto do Silício', 'Tecno-xamãs transcendentes.',          60),
  (5, 'Aliança Nômade',   'Sobreviventes urbanos móveis.',        80);

-- ---------- Classes ----------
INSERT INTO classe_personagem (id, nome) VALUES
  (1,'Hacker'), (2,'Mercenário'), (3,'Tecno-Xamã'), (4,'Nômade Urbano');

INSERT INTO classes_especiais (classe_id, titulo, poder_especial) VALUES
  (1,'Netrunner',        'Sobrecarrega sistemas robóticos.'),
  (2,'Soldado de Rua',   'Adrenalina: +dano por 3 turnos.'),
  (3,'Oráculo Digital',  'Ritual: +esquiva e crítico.'),
  (4,'Sobrevivente Urb.', 'Furtividade máxima.');

-- ---------- Personagens ----------
INSERT INTO personagens
  (id,jogador_id,classe_id,nivel,vida,experiencia,reputacao,carteira,ataque,defesa,faccao_id,sala_atual_id)
VALUES
  (1,1,1,1,100,0,0,250,10,10,NULL,1),
  (2,2,4,1,120,0,10,300,15,15,5,11);

-- ---------- Mobs ----------
INSERT INTO mobs
  (id,nome,vida,ataque,defesa,sala_id) VALUES
  (1,'Drone OmniCorp',          50,15,10,1),
  (2,'Rato Sucata',             30,20, 5,3),
  (3,'Segurança Ciborgue',     120,35,25,3),
  (4,'Unidade Expurgo K9',     500,60,40,3),
  (5,'Sentinela do Núcleo',     80,25,18,6),
  (6,'Gangue Plugada',          45,20,10,7),
  (7,'Híbrido Experimental',   200,50,30,10),
  (8,'Caçador Nômade',         100,32,18,11),
  (9,'Drone Predador',          65,22,15,9);

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
INSERT INTO itens_sala (id,sala_id,item_id,quantidade) VALUES
  (1,1,3,1),   -- TraumaZero no beco
  (2,2,6,5),   -- Cred-Sticks no mercado
  (3,4,1,3);   -- Neuro-est. na clínica

-- ---------- Inventário inicial ----------
INSERT INTO inventario (id,personagem_id,item_id,quantidade) VALUES
  (1,1,2,1),
  (2,1,6,2),
  (3,2,11,1),
  (4,2,12,1);

-- ---------- Missões ----------
INSERT INTO missoes (id,nome,descricao,recompensa,xp_requerido,tipo) VALUES
  (1,'Pacote de Dados','Entregue dados ao Fixer.','200 Credz + 50 XP',0,'Entrega'),
  (2,'Limpeza de IA','Desative IA defect.','Chip Fantasma + 150 XP',100,'Invasão'),
  (3,'Escolta ao Mercado','Proteja Filhos de Turing.','500 Credz + 120 XP',80,'Escolta'),
  (4,'Caçada ao Disco','Entregue o disco ao Templo.','700 Credz + 100 XP',50,'Entrega'),
  (5,'Roubo na Fábrica','Recupere peças raras.','Implante Memória + 200 XP',120,'Infiltração'),
  (6,'Proteja o Refúgio','Defenda base nômade.','500 Credz + 80 XP',60,'Defesa'),
  (7,'Ritual de Integração','Participe do ritual.','Nanomeds + 60 XP',40,'Evento');

-- ---------- Missões por personagem ----------
INSERT INTO missoes_jogador
  (id,personagem_id,missao_id,status,progresso) VALUES
  (1,1,1,'em_andamento',0),
  (2,2,4,'em_andamento',0);

COMMIT;
