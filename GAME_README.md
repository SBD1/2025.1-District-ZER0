# District ZER0 - Interface CLI

Interface de linha de comando para o jogo MUD cyberpunk District ZER0.

## 🚀 Instalação e Configuração

### 1. Pré-requisitos

- Python 3.8 ou superior
- Docker e Docker Compose
- Git
- Make

### 2. Configuração Automática (Recomendado)

#### Opção 1: Jogo Imediato
```bash
make play
```
*Configura automaticamente Python, banco de dados e inicia o jogo*

#### Opção 2: Setup Completo
```bash
make setup
```
*Configura ambiente Python e banco de dados*

#### Opção 3: Demonstração Completa
```bash
make demo
```
*Setup + validação + opção de jogar*

### 3. Configuração Manual

#### 3.1. Ambiente Python
```bash
make setup-python    # Cria ambiente virtual e instala dependências
```

#### 3.2. Banco de Dados
```bash
make start           # Inicia PostgreSQL + Adminer
make verify-scripts  # Verifica se scripts foram executados
```

### 4. Comandos Disponíveis

#### 🎮 Comandos de Jogo
```bash
make play          # Jogar o MUD (setup automático)
make demo          # Demonstração completa
make test-setup    # Testar se está tudo configurado
```

#### 🛠️ Comandos de Configuração
```bash
make setup         # Setup completo (banco + python)
make setup-python  # Configurar apenas Python
make install-deps  # Instalar dependências Python
```

#### 🐘 Comandos de Banco
```bash
make start         # Iniciar PostgreSQL + Adminer
make stop          # Parar serviços
make restart       # Reiniciar serviços
make reset-db      # Reiniciar banco com dados limpos
make force-rebuild # Reconstrução completa
make connect-db    # Conectar ao PostgreSQL
make test          # Executar queries de validação
```

#### 🔧 Comandos Utilitários
```bash
make status        # Status dos serviços
make logs          # Logs dos serviços
make health        # Verificação de saúde
make clean         # Limpar tudo (CUIDADO!)
make backup        # Criar backup do banco
make help          # Ver todos os comandos
```

### 5. Verificação do Sistema

```bash
make validate-system  # Validação completa
make verify-scripts   # Verificar scripts executados
make check-scripts    # Listar scripts disponíveis
```

### 6. Acesso ao Sistema

- **Jogo**: `make play`
- **Adminer**: http://localhost:8080
- **PostgreSQL**: localhost:5432

#### Credenciais de Acesso:
- **Sistema**: PostgreSQL
- **Servidor**: postgres
- **Usuário**: district_zero_user
- **Senha**: district_zero_pass
- **Base**: district_zero

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
# Verificar status dos serviços
make status

# Verificar saúde do sistema
make health

# Reiniciar serviços
make restart

# Se persistir, reconstruir completamente
make force-rebuild
```

### Problema: Erro de dependências Python
```bash
# Reconfigurar ambiente Python
make setup-python

# Verificar se está tudo configurado
make test-setup
```

### Problema: Scripts SQL não executados
```bash
# Verificar execução dos scripts
make verify-scripts

# Preparar scripts para execução
make prepare-sql

# Verificar quais scripts estão disponíveis
make check-scripts
```

### Problema: Personagem não criado
- Verifique se escolheu uma classe válida (1-6)
- Confirme que não existe personagem anterior para o usuário
- Execute `make test` para validar o banco

### Problema: Containers não inicializam
```bash
# Verificar logs detalhados
make debug-logs

# Verificar volumes Docker
make check-volumes

# Limpar volumes se necessário
make clean-volumes

# Reconstruir sistema
make force-rebuild
```

### Problema: Banco não responde
```bash
# Conectar diretamente ao banco
make connect-db

# Verificar configuração
make validate-system

# Executar queries de validação
make test
```

### Comandos de Diagnóstico
```bash
make help           # Ver todos os comandos
make info           # Informações do projeto
make status         # Status dos serviços
make health         # Verificação completa
make debug-logs     # Logs detalhados
make validate-system # Validação completa
```

## 📊 Funcionalidades Implementadas

### ✅ Sistema de Banco de Dados
- **18 tabelas** estruturadas com relacionamentos
- **24 procedures/functions** de lógica de negócio
- **6 triggers automáticas** (morte, XP, level up, missões)
- **3 views** para relatórios e consultas
- **Índices otimizados** para performance

### ✅ Interface e Autenticação
- **Sistema completo de autenticação** com bcrypt
- **Interface CLI colorida** com ASCII art cyberpunk
- **Validação robusta** de dados de entrada
- **Mensagens informativas** e feedback visual

### ✅ Sistema de Personagens
- **6 classes únicas** com atributos específicos
- **Sistema de level up** automático por XP
- **Criação e gerenciamento** de personagens
- **Classes especiais** com poderes únicos

### ✅ Mundo e Movimento
- **15 salas interconectadas** no mundo cyberpunk
- **Sistema de caminhos** com direções (N/S/L/O)
- **3 tipos de salas**: normal, safe-zone, dungeon
- **Mapeamento dinânico** das conexões

### ✅ Sistema de Combate
- **Combate PvE** contra 15 tipos de mobs
- **Mobs especiais** com poderes únicos
- **Sistema de drops** com chances configuráveis
- **Mecânica de fuga** com cálculo de probabilidade
- **Triggers de morte** com penalidades e respawn

### ✅ Economia e Itens
- **20 tipos de itens** com 5 raridades
- **Sistema de inventário** com stackable items
- **Economia de créditos** com valores dinâmicos
- **Drops de loot** baseado em probabilidade
- **Sistema de peso** e limitações

### ✅ Sistema de Missões
- **12 missões** implementadas com progressão
- **5 níveis de dificuldade** (Fácil a Lendário)
- **Sistema de recompensas** automático
- **Pré-requisitos** de nível e XP
- **Até 3 missões simultâneas**

### ✅ Sistema de Facções
- **7 facções** com características únicas
- **Sistema de reputação** individual e de facção
- **Benefícios por facção** 
- **Mecânicas de entrada e saída**

### ✅ Automação e Triggers
- **Trigger de morte** com respawn automático
- **Trigger de XP** com level up automático
- **Trigger de missões** com recompensas
- **Validações automáticas** de integridade
- **Sistema de logs** para auditoria

### ✅ Comandos e Makefile
- **30+ comandos Make** para gerenciamento
- **Setup automático** de ambiente
- **Validação de sistema** completa
- **Backup e restore** de dados
- **Logs e debugging** facilitados

## 🎯 Gameplay Tips

1. **Use `make play`** para iniciar rapidamente
2. **Explore todas as salas** para encontrar itens e missões
3. **Junte-se a uma facção** para ganhar benefícios
4. **Complete missões** para ganhar XP e recursos
5. **Evite morrer** - há penalidades significativas (perde 30% dos créditos)
6. **Use safe-zones** para descansar e se recuperar
7. **Colete itens** para melhorar seu equipamento
8. **Verifique `make help`** para todos os comandos disponíveis

## 🚀 Status do Sistema

**Versão 2.0.0** - Sistema MUD Cyberpunk Completo
- ✅ **18 tabelas** criadas e funcionais
- ✅ **6 jogadores** de teste inseridos
- ✅ **6 triggers** ativas e testadas
- ✅ **24 procedures** implementadas
- ✅ **8 configurações** do sistema ativas
- ✅ **Interface CLI** completa e funcional
- ✅ **Makefile** com 30+ comandos utilitários
- ✅ **Sistema 100% operacional** e pronto para produção