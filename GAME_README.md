# District ZER0 - Interface CLI

Interface de linha de comando para o jogo MUD cyberpunk District ZER0.

## 🚀 Instalação e Configuração

### 1. Pré-requisitos

- Python 3.8 ou superior
- Docker e Docker Compose
- Git

### 2. Instalação das Dependências

```bash
pip install -r requirements.txt
```

### 3. Configuração do Banco de Dados

1. Inicie os containers do banco:
```bash
docker-compose up -d
```

2. Verifique se o banco está funcionando:
```bash
docker-compose ps
```

O banco PostgreSQL estará disponível em `localhost:5432` e o Adminer em `localhost:8080`.

### 4. Executar o Jogo

```bash
python run_game.py
```

## 🎮 Como Jogar

### Primeiro Acesso

1. **Cadastro**: Crie uma conta com username único (3-40 caracteres)
2. **Login**: Entre com suas credenciais
3. **Personagem**: Escolha uma classe para seu personagem:
   - **Hacker**: Especialista em invasão de sistemas
   - **Mercenário**: Combatente profissional
   - **Tecno-Xamã**: Místico tecnológico
   - **Nômade Urbano**: Sobrevivente adaptável
   - **Netrunner**: Hacker de elite
   - **Soldado Corp**: Agente corporativo

### Comandos Principais

- **1. Olhar ao redor**: Examina a sala atual, mostra inimigos, itens e saídas
- **2. Mover (N/S/L/O)**: Move para Norte, Sul, Leste ou Oeste
- **3. Atacar inimigo**: Inicia combate com mobs na sala
- **4. Inventário**: Mostra seus itens
- **5. Status**: Exibe informações detalhadas do personagem
- **6. Missões**: Gerencia missões ativas e disponíveis
- **7. Facções**: Sistema de facções e alianças
- **8. Pegar item**: Coleta itens do chão
- **9. Dropar item**: Descarta itens do inventário

### Sistema de Combate

- **Ataque vs Defesa**: Dano = max(Ataque - Defesa, 1)
- **PvE**: Combate contra mobs e bosses
- **XP e Level Up**: Ganhe experiência para subir de nível
- **Drops**: Mobs podem dropar itens valiosos
- **Morte**: Personagens mortos revivem em safe-zones com penalidades

### Sistema de Missões

- **Missões Ativas**: Até 3 missões simultâneas
- **Dificuldades**: Fácil, Normal, Difícil, Épico, Lendário
- **Recompensas**: Créditos, XP, itens especiais
- **Pré-requisitos**: Algumas missões exigem nível ou XP mínimos

### Sistema de Facções

- **7 Facções Disponíveis**:
  - Filhos de Turing (Hackers libertários)
  - Vanguarda Cromada (Mercenários transumanistas)
  - Sindicato da Sucata (Engenheiros catadores)
  - Culto do Silício (Tecno-xamãs)
  - Aliança Nômade (Sobreviventes urbanos)
  - Consórcio OmniCorp (Corporação dominante)
  - Rede Fantasma (Espionagem secreta)

### Economia

- **Créditos**: Moeda do jogo para comércio
- **Itens**: 5 raridades (Comum, Incomum, Raro, Épico, Variável)
- **Tipos**: Armas, chips, consumíveis, aprimoramentos, dados, especiais

## 🗺️ Mundo do Jogo

O District ZER0 possui **15 salas interconectadas**:

### Salas Principais
- **Beco do Neon Enferrujado**: Área inicial urbana
- **Mercado de Chips Clandestino**: Safe-zone para comércio
- **Data-Bank Abandonado da OmniCorp**: Dungeon de alta dificuldade
- **Clínica "Deus Ex Machina"**: Safe-zone médica
- **O Ninho do Corvo**: Hub de informações

### Zonas Especiais
- **Safe-zones** (4): Áreas sem combate
- **Dungeons** (3): Áreas de alta dificuldade
- **Áreas Normais** (8): Combate permitido

## 🛠️ Estrutura Técnica

### Arquivos Principais

```
cli/
├── main.py          # Interface principal
├── database.py      # Gerenciamento do banco
├── auth.py          # Sistema de autenticação
├── game.py          # Lógica do jogo
├── ui.py            # Interface do usuário
└── __init__.py      # Pacote Python

Dev/                 # Scripts SQL
├── 01_ddl_postgres.sql      # Estrutura do banco
├── 02_dml_postgres.sql      # Dados iniciais
├── 03_dql_postgres.sql      # Queries de validação
├── 04_correcoes_criticas.sql # Correções
├── 05_triggers_basicas.sql   # Triggers do sistema
├── 06_procedures_basicas.sql # Procedures principais
├── 07_procedures_criticas.sql # Procedures avançadas
└── 08_procedures_faccoes.sql # Sistema de facções

run_game.py          # Script de execução
requirements.txt     # Dependências Python
docker-compose.yml   # Configuração do banco
```

### Banco de Dados

- **PostgreSQL 15**: Sistema principal
- **18 Tabelas**: Estrutura completa
- **50+ Procedures/Functions**: Lógica de negócio
- **15+ Triggers**: Automação e validação
- **Views**: Relatórios e consultas

## 🐛 Troubleshooting

### Problema: Erro de conexão com banco
```bash
# Verifique se os containers estão rodando
docker-compose ps

# Reinicie os containers
docker-compose down
docker-compose up -d
```

### Problema: Erro de dependências Python
```bash
# Reinstale as dependências
pip install --upgrade -r requirements.txt
```

### Problema: Personagem não criado
- Verifique se escolheu uma classe válida (1-6)
- Confirme que não existe personagem anterior para o usuário

## 📊 Funcionalidades Implementadas

- ✅ Sistema completo de autenticação
- ✅ Criação e gerenciamento de personagens
- ✅ Movimento entre salas com mapeamento
- ✅ Sistema de combate PvE
- ✅ Inventário e itens
- ✅ Sistema de missões
- ✅ Sistema de facções
- ✅ Triggers automáticas (morte, XP, level up)
- ✅ Interface colorida e intuitiva
- ✅ Persistência completa de dados

## 🎯 Gameplay Tips

1. **Explore todas as salas** para encontrar itens e missões
2. **Junte-se a uma facção** para ganhar benefícios
3. **Complete missões** para ganhar XP e recursos
4. **Evite morrer** - há penalidades significativas
5. **Use safe-zones** para descansar e se recuperar
6. **Colete itens** para melhorar seu equipamento

## 🚀 Versão

**Versão 1.0.0** - Interface CLI completa com todas as funcionalidades do MUD cyberpunk. 