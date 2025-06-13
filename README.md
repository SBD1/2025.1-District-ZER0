# District ZER0

Documentação oficial do projeto **District ZER0: Cyberpunk Pocket MUD**.

GRUPO 15 DE SISTEMAS DE BANCOS DE DADOS 1 - 2025.1 - UnB

## Sobre o Projeto

**District ZER0** é um Multi-User Dungeon (MUD) com temática cyberpunk desenvolvido como projeto para a disciplina de Sistemas de Bancos de Dados 1 (SBD1) no semestre 2025.1. O jogo é implementado utilizando MySQL como sistema de banco de dados principal, garantindo persistência, consistência e escalabilidade dos dados.

## 🚀 Início Rápido

### Pré-requisitos
- Docker
- Docker Compose
- Make (opcional, mas recomendado)

### Instalação e Execução

1. **Clone o repositório:**
```bash
git clone <url-do-repositório>
cd 2025.1-District-ZER0
```

2. **Execute o projeto:**
```bash
# Com Make (recomendado)
make help          # Veja todos os comandos disponíveis
make setup         # Verifica dependências
make start         # Inicia o banco de dados
make test          # Executa queries de teste

# Ou manualmente com Docker Compose
docker-compose up -d
```

3. **Acesse os serviços:**
- **Adminer (Interface Web)**: http://localhost:8080
- **MySQL Database**: localhost:3306

### Credenciais de Acesso

- **Sistema**: MySQL
- **Servidor**: mysql (para Adminer) ou localhost (para clientes externos)
- **Usuário**: district_zero_user
- **Senha**: district_zero_pass
- **Base de dados**: district_zero

## O Mundo de District ZER0

Em um futuro distópico onde megacorporações controlam todas as esferas da sociedade, existe uma zona conhecida apenas como "District ZER0" - um submundo digital onde hackers, mercenários e rebeldes lutam pela sobrevivência e reputação. Como jogador, você navegará por este ambiente hostil, coletará itens, enfrentará inimigos e construirá sua lenda neste universo cibernético.

## Mecânicas de Jogo

- **Exploração**: Navegue por salas interconectadas em um mapa urbano cyberpunk usando comandos de direção (N/S/L/O)
- **Coleta de Itens**: Encontre e utilize chips, armas e dados criptografados para melhorar seu personagem
- **Combate**: Enfrente NPCs hostis (mobs) em combates baseados em turnos com sistema de transações isoladas
- **Persistência Total**: Todos os dados do mundo são armazenados no banco de dados
- **Sistema de Reputação**: Suas ações afetam como o mundo virtual reage a você e sua posição no ranking global

## 📋 Comandos Disponíveis

O projeto inclui um Makefile completo para facilitar o desenvolvimento:

```bash
make help          # Mostra todos os comandos disponíveis
make setup         # Configura o ambiente
make start         # Inicia os serviços
make stop          # Para os serviços
make restart       # Reinicia os serviços
make test          # Executa queries de teste
make connect-db    # Conecta ao MySQL via CLI
make clean         # Remove todos os dados (cuidado!)
make backup        # Cria backup do banco
make logs          # Mostra logs dos serviços
make entrega       # Prepara para entrega/demonstração
```

## 🗂️ Estrutura do Projeto

```
2025.1-District-ZER0/
├── Dev/
│   ├── DDL_mysql.sql     # Definição das tabelas (MySQL)
│   ├── DML_mysql.sql     # Dados iniciais (MySQL)
│   ├── DQL_mysql.sql     # Queries de exemplo (MySQL)
│   ├── 00_init.sql       # Script de inicialização automática
│   ├── DDL.sql          # Versão original (PostgreSQL)
│   ├── DML.sql          # Versão original (PostgreSQL)
│   └── DQL.sql          # Versão original (PostgreSQL)
├── docker-compose.yml    # Configuração dos serviços
├── Makefile             # Automação de comandos
├── README.md            # Este arquivo
└── requirements.txt     # Dependências do MkDocs
```

## 🔧 Desenvolvimento

### Conectando ao Banco

**Via Adminer (Recomendado):**
1. Acesse http://localhost:8080
2. Use as credenciais listadas acima

**Via CLI:**
```bash
make connect-db    # Conecta como usuário normal
make mysql-cli     # Conecta como root
```

**Via Cliente MySQL:**
```bash
mysql -h localhost -P 3306 -u district_zero_user -p district_zero
```

### Executando Queries

```bash
# Queries de teste incluídas
make test

# Ou execute manualmente
docker exec -i district_zero_mysql mysql -u district_zero_user -p district_zero_pass district_zero < Dev/DQL_mysql.sql
```

### Backup e Restore

```bash
# Criar backup
make backup

# Restaurar backup
make restore BACKUP_FILE=district_zero_20250101_120000.sql
```

## 📊 Modelo de Dados

O banco de dados implementa um modelo completo para um MUD cyberpunk:

- **Jogadores**: Contas de usuários
- **Personagens**: Avatares dos jogadores com atributos
- **Salas**: Locais do mundo virtual
- **Itens**: Objetos coletáveis com raridades
- **Mobs**: NPCs hostis
- **Combates**: Histórico de batalhas
- **Missões**: Quests para os jogadores
- **Facções**: Organizações do mundo

## 🚀 Para Demonstração

Execute os seguintes comandos para uma demonstração completa:

```bash
# 1. Preparar ambiente
make entrega

# 2. Acessar interface web
# Abra http://localhost:8080 no navegador

# 3. Executar queries de exemplo
make test
```

## 🔍 Troubleshooting

### Problemas Comuns

**Porta 3306 já em uso:**
```bash
# Pare outros serviços MySQL
sudo service mysql stop
# Ou mude a porta no docker-compose.yml
```

**Erro de permissão no Docker:**
```bash
# Adicione seu usuário ao grupo docker
sudo usermod -aG docker $USER
# Faça logout e login novamente
```

**Container não inicia:**
```bash
# Verifique os logs
make logs

# Reinicie tudo
make clean
make start
```

## 📚 Documentação Adicional

- **Documentação Completa**: [sbd1.github.io/2025.1-District-ZER0/](https://sbd1.github.io/2025.1-District-ZER0/)
- **Servir documentação localmente**: `make docs-serve`

## 🎯 Equipe

- **VINICIUS ANGELO DE BRITO VIEIRA** - 190118059
- **MATEUS LEVY AVELANS BOQUADY** - 190113901  
- **GUILHERME BASILIO DO ESPÍRITO SANTO** - 160007615

---

*Desenvolvido para SBD1 - 2025.1 - Universidade de Brasília*