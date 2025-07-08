# District ZER0 - Cyberpunk Pocket MUD

Sistema MUD (Multi-User Dungeon) cyberpunk completo com banco PostgreSQL e interface CLI Python.

## 🚀 Início Rápido

### Opção 1: Um Comando (Recomendado)
```bash
make play
```
*Configura tudo automaticamente e inicia o jogo*

### Opção 2: Script de Inicialização
```bash
./start.sh
```

### Opção 3: Demonstração Completa
```bash
make demo
```

## 🎮 Sistema Completo

- **PostgreSQL 15** com 18 tabelas interconectadas
- **50+ procedures e functions** para lógica de negócio
- **15+ triggers automáticas** (morte, XP, level up)
- **Interface CLI Python** colorida e intuitiva
- **15 salas interconectadas** no mundo cyberpunk
- **6 classes de personagem** únicas
- **7 facções** com benefícios especiais
- **12 missões** com progressão
- **Sistema completo de combate** PvE
- **Inventário e economia** de itens

## 🛠️ Comandos Principais

```bash
# JOGO
make play          # Jogar o MUD (setup automático)
make demo          # Demonstração completa
make test-setup    # Testar configuração

# CONFIGURAÇÃO
make setup         # Setup completo (banco + Python)
make setup-python  # Configurar apenas Python
make help          # Ver todos os comandos

# BANCO DE DADOS
make start         # Iniciar PostgreSQL + Adminer
make stop          # Parar serviços
make test          # Validar banco de dados

# UTILITÁRIOS
make status        # Status dos serviços
make info          # Informações do projeto
make clean         # Limpar tudo (CUIDADO!)
```

## 📋 Pré-requisitos

- **Docker** e **Docker Compose**
- **Python 3.8+**
- **Make**

## 🎯 Estrutura do Projeto

```
District ZER0/
├── cli/                     # Interface Python
│   ├── main.py              # Interface principal
│   ├── database.py          # Conexão PostgreSQL
│   ├── auth.py              # Autenticação
│   ├── game.py              # Lógica do jogo
│   └── ui.py                # Interface visual
├── Dev/                     # Scripts SQL (executados automaticamente)
│   ├── 01_ddl_postgres.sql  # Estrutura do banco
│   ├── 02_dml_postgres.sql  # Dados iniciais
│   ├── 03_dql_postgres.sql  # Queries de validação
│   ├── 04_correcoes_criticas.sql
│   ├── 05_triggers_basicas.sql
│   ├── 06_procedures_basicas.sql
│   ├── 07_procedures_criticas.sql
│   └── 08_procedures_faccoes.sql
├── Makefile                 # Centro de controle
├── docker-compose.yml       # Configuração do banco
├── run_game.py              # Executor do jogo
├── start.sh                 # Script de inicialização
└── requirements.txt         # Dependências Python
```

## 🌍 Mundo do Jogo

O **District ZER0** possui **15 salas interconectadas**:

- **4 Safe-zones**: Áreas protegidas sem combate
- **3 Dungeons**: Áreas de alta dificuldade
- **8 Áreas normais**: Combate e exploração

### Classes de Personagem
1. **Hacker** - Especialista em invasão de sistemas
2. **Mercenário** - Combatente profissional  
3. **Tecno-Xamã** - Místico tecnológico
4. **Nômade Urbano** - Sobrevivente adaptável
5. **Netrunner** - Hacker de elite
6. **Soldado Corp** - Agente corporativo

### Facções Disponíveis
- **Filhos de Turing** (Hackers libertários)
- **Vanguarda Cromada** (Mercenários transumanistas)
- **Sindicato da Sucata** (Engenheiros catadores)
- **Culto do Silício** (Tecno-xamãs)
- **Aliança Nômade** (Sobreviventes urbanos)
- **Consórcio OmniCorp** (Corporação dominante)
- **Rede Fantasma** (Espionagem secreta)

## 🔗 Acesso ao Sistema

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Jogo CLI** | `make play` | Criar conta no jogo |
| **Adminer** | http://localhost:8080 | Ver abaixo |
| **PostgreSQL** | localhost:5432 | Ver abaixo |

### Credenciais do Banco
- **Sistema**: PostgreSQL
- **Servidor**: postgres
- **Usuário**: district_zero_user
- **Senha**: district_zero_pass
- **Base**: district_zero

## 🐛 Troubleshooting

```bash
# Verificar status
make status

# Validar sistema
make check-scripts

# Reiniciar tudo
make restart

# Ver logs
make logs

# Limpar e reconfigurar
make clean
make setup
```

## 📊 Funcionalidades

- ✅ **Sistema completo de autenticação** com bcrypt
- ✅ **Criação e gerenciamento de personagens**
- ✅ **Movimento entre salas** com mapeamento
- ✅ **Sistema de combate PvE** com triggers automáticas
- ✅ **Inventário e itens** (5 raridades)
- ✅ **Sistema de missões** com progressão
- ✅ **Sistema de facções** com benefícios
- ✅ **Interface colorida** com ASCII art
- ✅ **Persistência completa** de dados
- ✅ **Sistema de level up** automático
- ✅ **Economia de créditos** e itens

## 🎯 Para Começar

1. **Clone o repositório**
2. **Execute**: `make play`
3. **Crie uma conta** no jogo
4. **Escolha sua classe**
5. **Explore o mundo cyberpunk!**

---

**Versão**: 1.0.0  
**Stack**: PostgreSQL 15 + Python 3.9+ + Docker  
**Tipo**: MUD Cyberpunk com Interface CLI