-- District ZER0 - Dados de Inicialização Expandidos (PostgreSQL)
-- Este arquivo é executado automaticamente após o DDL durante a inicialização do container

-- ---------- Jogadores de Teste ----------
INSERT INTO jogadores (username, senha_hash, is_active) VALUES
  ('user_2077',    '$2b$12$hash_placeholder_12345', true),
  ('user_aria',    '$2b$12$hash_placeholder_67890', true),
  ('cyberpunk_90', '$2b$12$hash_placeholder_11111', true),
  ('netrunner_01', '$2b$12$hash_placeholder_22222', true),
  ('street_sam',   '$2b$12$hash_placeholder_33333', true),
  ('data_miner',   '$2b$12$hash_placeholder_44444', false); -- Usuário inativo para teste

-- ---------- Salas do Mundo Cyberpunk ----------
INSERT INTO salas (nome, tipo, descricao, max_players) VALUES
  ('Beco do Neon Enferrujado',        'normal',    'Beco úmido e mal-iluminado onde os néons piscam irregularmente.', 20),
  ('Mercado de Chips Clandestino',    'safe-zone', 'Feira de implantes fora da lei, protegida por hologramas de segurança.', 50),
  ('Data-Bank Abandonado da OmniCorp','dungeon',   'Servidor repleto de IAs renegadas e sistemas de defesa ativos.', 10),
  ('Clínica "Deus Ex Machina"',       'safe-zone', 'Instala aprimoramentos sem perguntas, santuário médico neutro.', 30),
  ('O Ninho do Corvo',                'normal',    'Infohub de elite onde dados valem mais que créditos.', 15),
  ('Templo do Núcleo',                'safe-zone', 'Refúgio tecno-xamã onde tecnologia e espiritualidade se fundem.', 25),
  ('Estação de Recarga Abandonada',   'normal',    'Domínio de gangues, energia elétrica instável e perigos ocultos.', 20),
  ('Avenida dos Servidores',          'normal',    'Corredor de rumores e dados, coração da rede neural urbana.', 30),
  ('Fábrica Desativada da OmniCorp',  'dungeon',   'Ruínas industriais cheias de armadilhas e experimentos abandonados.', 8),
  ('Laboratório de Testes Genéticos', 'dungeon',   'Experimentos biotecnológicos ativos, zona de contenção comprometida.', 5),
  ('Refúgio Nômade',                  'safe-zone', 'Base móvel camuflada dos sobreviventes urbanos.', 40),
  ('Torre de Transmissão Central',    'dungeon',   'Centro neural da cidade, guardado por sistemas de IA hostis.', 6),
  ('Zona de Quarentena Digital',      'normal',    'Área infectada por vírus de realidade aumentada.', 12),
  ('Porto de Dados Subterrâneo',     'normal',    'Terminal de transferência de informações do submundo.', 25),
  ('Cemitério de Androides',          'normal',    'Local onde robôs obsoletos são descartados, alguns ainda funcionais.', 18);

-- ---------- Itens Expandidos ----------
INSERT INTO itens (nome, tipo, descricao, raridade, valor, peso, max_stack, is_unique) VALUES
  ('Neuro-estimulante K-7',      'consumivel', 'Aumenta reflexos e velocidade de processamento neural.',          'Comum',    50,   0.1,  10, false),
  ('Data-Knife',                'arma',       'Lâmina que rouba dados ao cortar sistemas de segurança.',       'Incomum',  150,  0.5,  1,  false),
  ('Kit Sutura "TraumaZero"',   'consumivel', 'Cura emergencial com nanobots médicos avançados.',              'Comum',    75,   0.3,  5,  false),
  ('Chip "Fantasma"',           'chip',       'Camuflagem ótica que torna o usuário quase invisível.',         'Raro',     500,  0.1,  1,  false),
  ('Braço Cibernético Titan',   'aprimoramento','Substituto de braço com força sobre-humana.',                'Épico',   1200,  5.0,  1,  false),
  ('Cred-Stick Universal',      'dado',       'Armazena créditos anônimos em formato digital.',               'Variável', 100,  0.1,  20, false),
  ('Ampola de Nanomeds Alpha',  'consumivel', 'Nanorrobôs de cura de última geração.',                        'Raro',     300,  0.2,  3,  false),
  ('Pulseira Jammer Mk-III',    'chip',       'Bloqueia rastreamento e sinais de comunicação.',               'Incomum',  180,  0.2,  1,  false),
  ('Espingarda de Pulso X9',    'arma',       'Projéteis de energia concentrada de alta potência.',           'Raro',     700,  3.0,  1,  false),
  ('Implante Memória Quantum',  'aprimoramento','Expande armazenamento cerebral usando tecnologia quântica.', 'Épico',   1500,  0.1,  1,  false),
  ('Roupa Tática Nômade',       'aprimoramento','Traje com fibra óptica e camuflagem adaptativa.',            'Épico',   1200,  2.0,  1,  false),
  ('Disco de Dados Misterioso', 'dado',       'Informação criptografada de origem desconhecida.',             'Variável', 250,  0.1,  1,  true),
  ('Stimpak Militar',           'consumivel', 'Estimulante médico de combate para recuperação rápida.',       'Incomum',  120,  0.2,  8,  false),
  ('Interface Neural Direta',   'chip',       'Permite conexão direta com sistemas de IA.',                   'Épico',    800,  0.3,  1,  false),
  ('Bateria de Íons Compacta',  'especial',   'Fonte de energia para equipamentos eletrônicos.',              'Comum',     40,  0.4,  15, false),
  ('Chave Digital Mestra',      'especial',   'Abre portas eletrônicas de segurança padrão.',                 'Raro',     350,  0.1,  1,  false),
  ('Seringa de Adrenalina',     'consumivel', 'Injeta adrenalina sintética para combate.',                    'Incomum',   90,  0.1,  6,  false),
  ('Óculos de Visão Térmica',   'chip',       'Permite enxergar através do calor corporal.',                  'Raro',     450,  0.3,  1,  false),
  ('Tablet de Hacking',         'especial',   'Ferramenta portátil para invasão de sistemas.',                'Incomum',  220,  0.8,  1,  false),
  ('Protetor de Pulso',         'aprimoramento','Armadura leve para proteção dos braços.',                    'Comum',    110,  1.2,  1,  false);

-- ---------- Facções Expandidas ----------
INSERT INTO faccoes (nome, descricao, reputacao, max_members) VALUES
  ('Filhos de Turing',    'Hackers libertários que lutam pela liberdade digital.',           100, 50),
  ('Vanguarda Cromada',   'Mercenários transumanistas em busca da perfeição cibernética.',   50, 75),
  ('Sindicato da Sucata', 'Engenheiros e catadores que reciclam tecnologia abandonada.',     75, 60),
  ('Culto do Silício',    'Tecno-xamãs que buscam transcendência através da tecnologia.',    60, 40),
  ('Aliança Nômade',      'Sobreviventes urbanos móveis que rejeitam a vida corporativa.',   80, 80),
  ('Consórcio OmniCorp',  'Corporação que domina a infraestrutura tecnológica da cidade.',   30, 200),
  ('Rede Fantasma',       'Organização secreta de espionagem e contra-inteligência.',        20, 25);

-- ---------- Classes de Personagem ----------
INSERT INTO classe_personagem (nome, descricao, vida_base, ataque_base, defesa_base) VALUES
  ('Hacker',         'Especialista em invasão de sistemas e manipulação digital.',    90, 8,  12),
  ('Mercenário',     'Combatente profissional especializado em conflitos urbanos.',  110, 15, 10),
  ('Tecno-Xamã',     'Místico tecnológico que mescla magia e cibernética.',          100, 10, 14),
  ('Nômade Urbano',  'Sobrevivente adaptável especializado em mobilidade.',          120, 12, 11),
  ('Netrunner',      'Hacker de elite capaz de navegar no ciberespaço.',             85,  9,  13),
  ('Soldado Corp',   'Agente corporativo treinado para missões de segurança.',       115, 14, 12);

INSERT INTO classes_especiais (classe_id, titulo, poder_especial, bonus_ataque, bonus_defesa, bonus_vida) VALUES
  (1, 'Netrunner Elite',        'Sobrecarrega sistemas robóticos causando dano extra.',  2, 3, 0),
  (2, 'Soldado de Rua',         'Adrenalina: +50% dano por 3 turnos de combate.',       3, 0, 10),
  (3, 'Oráculo Digital',        'Ritual: +30% esquiva e chance de crítico.',            1, 4, 5),
  (4, 'Sobrevivente Urbano',    'Furtividade máxima: pode evitar combates.',            2, 2, 15),
  (5, 'Ghost in the Shell',     'Imunidade a ataques de ICE e vírus digitais.',         3, 4, 0),
  (6, 'Agente de Campo',        'Acesso a equipamento corporativo avançado.',           4, 3, 5);

-- ---------- Personagens de Teste ----------
INSERT INTO personagens 
  (jogador_id, classe_id, nivel, vida, vida_max, experiencia, reputacao, carteira, ataque, defesa, faccao_id, sala_atual_id)
VALUES
  (1, 1, 2, 100, 100, 1200, 5,  350,  10, 15, 1,  1),  -- user_2077: Hacker nível 2
  (2, 4, 1, 120, 120, 0,   10, 300,  14, 13, 5,  11), -- user_aria: Nômade nível 1  
  (3, 2, 3, 130, 130, 2500, 8,  500,  18, 12, 2,  2),  -- cyberpunk_90: Mercenário nível 3
  (4, 5, 4, 105, 105, 3800, 15, 750,  14, 18, 1,  8),  -- netrunner_01: Netrunner nível 4
  (5, 6, 2, 125, 125, 1500, 3,  200,  16, 15, 6,  4);  -- street_sam: Soldado Corp nível 2

-- ---------- Mobs Expandidos ----------
INSERT INTO mobs (nome, vida, vida_max, ataque, defesa, sala_id, xp_reward, is_boss) VALUES
  ('Drone OmniCorp',           50,  50,  15, 10, 1,  50,  false),
  ('Rato de Sucata',           30,  30,  20,  5, 3,  30,  false),
  ('Segurança Ciborgue',      120, 120,  35, 25, 3,  80,  false),
  ('Unidade Expurgo K9',      500, 500,  60, 40, 3,  200, true),   -- Boss
  ('Sentinela do Núcleo',      80,  80,  25, 18, 6,  60,  false),
  ('Gangue Plugada',           45,  45,  20, 10, 7,  40,  false),
  ('Híbrido Experimental',    200, 200,  50, 30, 10, 120, false),
  ('Caçador Nômade',          100, 100,  32, 18, 11, 70,  false),
  ('Drone Predador',           65,  65,  22, 15, 9,  55,  false),
  ('IA Renegada Alpha',       300, 300,  45, 35, 12, 150, true),   -- Boss
  ('Vírus Manifestado',        40,  40,  30,  8, 13, 45,  false),
  ('Android Maluco',           90,  90,  28, 20, 15, 65,  false),
  ('Firewall Vivo',           180, 180,  40, 45, 12, 100, false),
  ('Soldado Corp Elite',      150, 150,  38, 28, 14, 90,  false),
  ('Sistema de Defesa',       250, 250,  55, 50, 12, 180, true);   -- Boss

-- ---------- Tipos de Mob ----------
INSERT INTO mob_tipos (mob_id, tipo, poder_especial, modificador_dano) VALUES
  (1,  'normal', NULL, 1.0),
  (2,  'normal', NULL, 1.0),
  (3,  'normal', NULL, 1.0),
  (4,  'chefe',  'Canhão de Plasma: ignora 50% da defesa do alvo.', 1.5),
  (5,  'normal', NULL, 1.0),
  (6,  'normal', NULL, 1.0),
  (7,  'normal', NULL, 1.0),
  (8,  'normal', NULL, 1.0),
  (9,  'normal', NULL, 1.0),
  (10, 'chefe',  'Sobrecarga Neural: causa dano contínuo por 3 turnos.', 1.3),
  (11, 'normal', NULL, 1.2),
  (12, 'normal', NULL, 1.0),
  (13, 'normal', NULL, 1.0),
  (14, 'normal', NULL, 1.1),
  (15, 'chefe',  'Auto-Reparação: regenera 10% de vida por turno.', 1.4);

-- ---------- Sistema de Drops ----------
INSERT INTO mob_drops (mob_id, item_id, chance, quantidade_min, quantidade_max) VALUES
  (1,  1,  0.40, 1, 2),  -- Drone: Neuro-estimulante
  (1,  15, 0.30, 1, 3),  -- Drone: Bateria
  (2,  6,  0.25, 1, 2),  -- Rato: Cred-Stick
  (2,  15, 0.50, 1, 4),  -- Rato: Bateria
  (3,  2,  0.35, 1, 1),  -- Segurança: Data-Knife
  (3,  13, 0.25, 1, 2),  -- Segurança: Stimpak
  (4,  5,  1.00, 1, 1),  -- Boss K9: Braço Cibernético
  (4,  14, 0.80, 1, 1),  -- Boss K9: Interface Neural
  (4,  6,  0.90, 5, 10), -- Boss K9: Cred-Sticks
  (5,  7,  0.45, 1, 2),  -- Sentinela: Nanomeds
  (6,  8,  0.35, 1, 1),  -- Gangue: Jammer
  (7,  10, 0.60, 1, 1),  -- Híbrido: Implante Memória
  (8,  11, 0.70, 1, 1),  -- Caçador: Roupa Nômade
  (9,  9,  0.40, 1, 1),  -- Predador: Espingarda
  (10, 14, 1.00, 1, 1),  -- Boss IA: Interface Neural
  (10, 4,  0.70, 1, 1),  -- Boss IA: Chip Fantasma
  (11, 1,  0.30, 1, 3),  -- Vírus: Neuro-estimulante
  (12, 15, 0.60, 2, 5),  -- Android: Bateria
  (13, 19, 0.50, 1, 1),  -- Firewall: Tablet Hacking
  (14, 13, 0.40, 1, 3),  -- Soldado: Stimpak
  (15, 16, 1.00, 1, 1),  -- Boss Sistema: Chave Digital
  (15, 18, 0.80, 1, 1);  -- Boss Sistema: Óculos Térmicos

-- ---------- Itens Espalhados pelas Salas ----------
INSERT INTO itens_sala (sala_id, item_id, quantidade) VALUES
  (1,  3,  2),   -- Beco: Kit Sutura
  (1,  15, 3),   -- Beco: Baterias
  (2,  6,  8),   -- Mercado: Cred-Sticks
  (2,  1,  5),   -- Mercado: Neuro-estimulantes
  (3,  19, 1),   -- Data-Bank: Tablet Hacking
  (4,  1,  4),   -- Clínica: Neuro-estimulantes
  (4,  7,  2),   -- Clínica: Nanomeds
  (5,  12, 1),   -- Ninho: Disco Misterioso
  (6,  3,  3),   -- Templo: Kit Sutura
  (7,  15, 6),   -- Estação: Baterias
  (8,  6,  4),   -- Avenida: Cred-Sticks
  (9,  20, 2),   -- Fábrica: Protetor de Pulso
  (11, 11, 1),   -- Refúgio: Roupa Nômade
  (13, 17, 2),   -- Quarentena: Adrenalina
  (14, 19, 1),   -- Porto: Tablet Hacking
  (15, 15, 4);   -- Cemitério: Baterias

-- ---------- Inventários Iniciais ----------
INSERT INTO inventario (personagem_id, item_id, quantidade) VALUES
  (1, 2,  1),  -- user_2077: Data-Knife
  (1, 6,  3),  -- user_2077: Cred-Sticks
  (1, 19, 1),  -- user_2077: Tablet Hacking
  (2, 11, 1),  -- user_aria: Roupa Nômade
  (2, 12, 1),  -- user_aria: Disco Misterioso
  (2, 3,  2),  -- user_aria: Kit Sutura
  (3, 9,  1),  -- cyberpunk_90: Espingarda
  (3, 13, 3),  -- cyberpunk_90: Stimpaks
  (3, 17, 2),  -- cyberpunk_90: Adrenalina
  (4, 4,  1),  -- netrunner_01: Chip Fantasma
  (4, 14, 1),  -- netrunner_01: Interface Neural
  (4, 1,  4),  -- netrunner_01: Neuro-estimulantes
  (5, 20, 1),  -- street_sam: Protetor de Pulso
  (5, 13, 2),  -- street_sam: Stimpaks
  (5, 15, 5);  -- street_sam: Baterias

-- ---------- Missões Expandidas ----------
INSERT INTO missoes (nome, descricao, recompensa, xp_requerido, nivel_requerido, tipo, dificuldade, is_repeatable) VALUES
  ('Pacote de Dados Urgente',   'Entregue dados confidenciais ao Fixer no Mercado.',               '200 Credz + 50 XP',           0,   1, 'Entrega',      'Fácil',     false),
  ('Limpeza de IA Renegada',    'Desative a IA defeituosa no Data-Bank da OmniCorp.',             'Chip Fantasma + 150 XP',     100, 2, 'Invasão',      'Normal',    false),
  ('Escolta Diplomática',       'Proteja representantes dos Filhos de Turing no trajeto.',        '500 Credz + 120 XP',         80,  2, 'Escolta',      'Normal',    true),
  ('Caçada ao Disco Perdido',   'Recupere o disco de dados roubado e entregue ao Templo.',        '700 Credz + 100 XP',         50,  2, 'Entrega',      'Normal',    false),
  ('Infiltração na Fábrica',    'Recupere protótipos de tecnologia da fábrica abandonada.',       'Implante Memória + 200 XP',  120, 3, 'Infiltração',  'Difícil',   false),
  ('Defesa do Refúgio',         'Proteja a base nômade de ataques corporativos.',                 '500 Credz + 80 XP',          60,  2, 'Defesa',       'Normal',    true),
  ('Ritual de Integração',      'Participe do ritual tecno-espiritual no Templo.',                'Nanomeds + 60 XP',           40,  1, 'Evento',       'Fácil',     false),
  ('Sabotagem Corporativa',     'Desative sistemas de segurança da Torre de Transmissão.',       '1000 Credz + 300 XP',        200, 4, 'Sabotagem',    'Épico',     false),
  ('Resgate de Dados',          'Salve informações críticas antes da destruição do servidor.',   '800 Credz + 180 XP',         150, 3, 'Resgate',      'Difícil',   true),
  ('Caça ao Tesouro Digital',   'Encontre fragmentos de código espalhados pela cidade.',         'Interface Neural + 250 XP',  300, 4, 'Exploração',   'Épico',     false),
  ('Eliminação de Alvo',        'Elimine o líder de uma gangue rival no território inimigo.',    '1200 Credz + 400 XP',        400, 5, 'Assassinato',  'Lendário',  false),
  ('Coleta de Recursos',        'Colete componentes eletrônicos no Cemitério de Androides.',     '300 Credz + 80 XP',          20,  1, 'Coleta',       'Fácil',     true);

-- ---------- Missões Ativas dos Jogadores ----------
INSERT INTO missoes_jogador (personagem_id, missao_id, status, progresso) VALUES
  (1, 1, 'em_andamento', 0),   -- user_2077: Pacote de Dados
  (2, 7, 'em_andamento', 30),  -- user_aria: Ritual (30% completo)
  (3, 5, 'em_andamento', 70),  -- cyberpunk_90: Infiltração (70% completo)
  (4, 2, 'concluida',   100),  -- netrunner_01: Limpeza IA (concluída)
  (4, 8, 'em_andamento', 20),  -- netrunner_01: Sabotagem (20% completo)
  (5, 6, 'em_andamento', 50);  -- street_sam: Defesa (50% completo)

-- ---------- Mapeamento Completo do Mundo (Caminhos) ----------
-- Layout expandido do District ZER0:
--
--    [3-DataBank] - [12-Torre] - [10-Lab.Genético]
--         |            |             |
--    [1-Beco] - [2-Mercado] - [4-Clínica] - [5-Ninho]
--         |         |             |           |
--    [7-Estação] - [8-Avenida] - [6-Templo] - [9-Fábrica]
--         |         |             |           |
--    [13-Quarent.] [14-Porto] - [11-Refúgio] [15-Cemitério]

INSERT INTO caminhos (sala_origem, direcao, sala_destino, is_bidirectional) VALUES
    -- Conexões do Beco (1)
    (1, 'N', 3, true),   -- Norte: Data-Bank
    (1, 'L', 2, true),   -- Leste: Mercado
    (1, 'S', 7, true),   -- Sul: Estação
    
    -- Conexões do Mercado (2)
    (2, 'O', 1, true),   -- Oeste: Beco
    (2, 'L', 4, true),   -- Leste: Clínica
    (2, 'S', 8, true),   -- Sul: Avenida
    (2, 'N', 12, true),  -- Norte: Torre
    
    -- Conexões do Data-Bank (3)
    (3, 'S', 1, true),   -- Sul: Beco
    (3, 'L', 12, true),  -- Leste: Torre
    
    -- Conexões da Clínica (4)
    (4, 'O', 2, true),   -- Oeste: Mercado
    (4, 'L', 5, true),   -- Leste: Ninho
    (4, 'S', 6, true),   -- Sul: Templo
    
    -- Conexões do Ninho (5)
    (5, 'O', 4, true),   -- Oeste: Clínica
    (5, 'S', 9, true),   -- Sul: Fábrica
    (5, 'N', 10, true),  -- Norte: Lab Genético
    
    -- Conexões do Templo (6)
    (6, 'N', 4, true),   -- Norte: Clínica
    (6, 'O', 8, true),   -- Oeste: Avenida
    (6, 'L', 9, true),   -- Leste: Fábrica
    (6, 'S', 11, true),  -- Sul: Refúgio
    
    -- Conexões da Estação (7)
    (7, 'N', 1, true),   -- Norte: Beco
    (7, 'L', 8, true),   -- Leste: Avenida
    (7, 'S', 13, true),  -- Sul: Quarentena
    
    -- Conexões da Avenida (8)
    (8, 'N', 2, true),   -- Norte: Mercado
    (8, 'O', 7, true),   -- Oeste: Estação
    (8, 'S', 14, true),  -- Sul: Porto
    (8, 'L', 6, true),   -- Leste: Templo
    
    -- Conexões da Fábrica (9)
    (9, 'N', 5, true),   -- Norte: Ninho
    (9, 'O', 6, true),   -- Oeste: Templo
    (9, 'S', 15, true),  -- Sul: Cemitério
    
    -- Conexões do Lab Genético (10)
    (10, 'S', 5, true),  -- Sul: Ninho
    (10, 'O', 12, true), -- Oeste: Torre
    
    -- Conexões do Refúgio (11)
    (11, 'N', 6, true),  -- Norte: Templo
    (11, 'O', 14, true), -- Oeste: Porto
    
    -- Conexões da Torre (12)
    (12, 'S', 2, true),  -- Sul: Mercado
    (12, 'O', 3, true),  -- Oeste: Data-Bank
    (12, 'L', 10, true), -- Leste: Lab Genético
    
    -- Conexões da Quarentena (13)
    (13, 'N', 7, true),  -- Norte: Estação
    
    -- Conexões do Porto (14)
    (14, 'N', 8, true),  -- Norte: Avenida
    (14, 'L', 11, true), -- Leste: Refúgio
    
    -- Conexões do Cemitério (15)
    (15, 'N', 9, true);  -- Norte: Fábrica

-- ---------- Dados de Auditoria Exemplo ----------
INSERT INTO log_acoes (personagem_id, acao, detalhes) VALUES
  (1, 'login', '{"timestamp": "2024-01-15T10:30:00Z", "sala": 1}'),
  (2, 'combate', '{"mob_id": 8, "resultado": "vitoria", "dano": 45}'),
  (3, 'movimento', '{"de": 1, "para": 2, "direcao": "L"}'),
  (4, 'missao_completa', '{"missao_id": 2, "recompensa": "Chip Fantasma + 150 XP"}'),
  (5, 'item_pego', '{"item_id": 13, "quantidade": 2, "sala": 4}');

-- ---------- Validação dos Dados Inseridos ----------
DO $$
DECLARE
    jogadores_count INT;
    personagens_count INT;
    mobs_count INT;
    missoes_count INT;
    caminhos_count INT;
BEGIN
    SELECT COUNT(*) INTO jogadores_count FROM jogadores;
    SELECT COUNT(*) INTO personagens_count FROM personagens;
    SELECT COUNT(*) INTO mobs_count FROM mobs;
    SELECT COUNT(*) INTO missoes_count FROM missoes;
    SELECT COUNT(*) INTO caminhos_count FROM caminhos;
    
    RAISE NOTICE 'Dados expandidos inseridos com sucesso:';
    RAISE NOTICE '✓ Jogadores: %', jogadores_count;
    RAISE NOTICE '✓ Personagens: %', personagens_count;
    RAISE NOTICE '✓ Salas: 15 (mundo completo)';
    RAISE NOTICE '✓ Itens: 20 (equipamentos diversos)';
    RAISE NOTICE '✓ Mobs: %', mobs_count;
    RAISE NOTICE '✓ Missões: %', missoes_count;
    RAISE NOTICE '✓ Caminhos: %', caminhos_count;
    RAISE NOTICE '✓ Facções: 7 (ecossistema completo)';
    RAISE NOTICE '';
    RAISE NOTICE 'District ZER0 pronto para gameplay completo!';
END
$$; 
