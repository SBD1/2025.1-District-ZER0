# District ZER0 - Makefile
# Cyberpunk Pocket MUD Database Management & CLI Application

# Configurações
POSTGRES_HOST = localhost
POSTGRES_PORT = 5432
POSTGRES_USER = district_zero_user
POSTGRES_PASSWORD = district_zero_pass
POSTGRES_DATABASE = district_zero
PYTHON_ENV = .venv
PYTHON = $(PYTHON_ENV)/bin/python
PIP = $(PYTHON_ENV)/bin/pip

# Cores para output
YELLOW = \033[1;33m
GREEN = \033[1;32m
RED = \033[1;31m
BLUE = \033[1;34m
MAGENTA = \033[1;35m
CYAN = \033[1;36m
NC = \033[0m # No Color

.PHONY: help setup setup-python start stop restart clean reset-db connect-db test status psql-cli logs install-deps venv play test-setup demo info backup restore dev docs-serve docs-build entrega all check-scripts validate-system force-rebuild debug-logs check-volumes clean-volumes verify-scripts prepare-sql

help: ## Mostra esta mensagem de ajuda
	@echo "$(YELLOW)District ZER0 - Cyberpunk Pocket MUD$(NC)"
	@echo "$(YELLOW)====================================$(NC)"
	@echo ""
	@echo "$(CYAN)🎮 JOGO:$(NC)"
	@echo "  $(GREEN)play$(NC)            Executa o jogo (setup automático)"
	@echo "  $(GREEN)demo$(NC)            Demonstração completa do sistema"
	@echo "  $(GREEN)test-setup$(NC)      Testa se o ambiente está configurado"
	@echo ""
	@echo "$(CYAN)🛠️  CONFIGURAÇÃO:$(NC)"
	@echo "  $(GREEN)setup$(NC)           Setup completo (banco + python)"
	@echo "  $(GREEN)setup-python$(NC)    Configura apenas ambiente Python"
	@echo "  $(GREEN)install-deps$(NC)    Instala dependências Python"
	@echo ""
	@echo "$(CYAN)🐘 BANCO DE DADOS:$(NC)"
	@echo "  $(GREEN)start$(NC)           Inicia PostgreSQL + Adminer"
	@echo "  $(GREEN)stop$(NC)            Para os serviços"
	@echo "  $(GREEN)restart$(NC)         Reinicia os serviços"
	@echo "  $(GREEN)reset-db$(NC)        Reinicia banco com dados limpos"
	@echo "  $(GREEN)force-rebuild$(NC)   Força reconstrução completa do banco"
	@echo "  $(GREEN)connect-db$(NC)      Conecta ao PostgreSQL"
	@echo "  $(GREEN)test$(NC)            Executa queries de validação"
	@echo ""
	@echo "$(CYAN)🔧 UTILITÁRIOS:$(NC)"
	@echo "  $(GREEN)status$(NC)          Status dos serviços"
	@echo "  $(GREEN)logs$(NC)            Mostra logs dos serviços"
	@echo "  $(GREEN)debug-logs$(NC)      Mostra logs detalhados para debug"
	@echo "  $(GREEN)health$(NC)          Verificação de saúde"
	@echo "  $(GREEN)clean$(NC)           Remove tudo (CUIDADO!)"
	@echo "  $(GREEN)verify-scripts$(NC)  Verifica se todos os scripts foram executados"
	@echo ""
	@echo "$(CYAN)🐛 DEBUG:$(NC)"
	@echo "  $(GREEN)check-volumes$(NC)   Verifica volumes Docker"
	@echo "  $(GREEN)clean-volumes$(NC)   Limpa volumes Docker"
	@echo "  $(GREEN)check-scripts$(NC)   Lista scripts SQL disponíveis"
	@echo "  $(GREEN)prepare-sql$(NC)     Prepara arquivos SQL para execução"

setup: ## Setup completo (banco + Python)
	@echo "$(YELLOW)Configurando ambiente District ZER0 completo...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker não está instalado$(NC)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)Docker Compose não está instalado$(NC)"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "$(RED)Python 3 não está instalado$(NC)"; exit 1; }
	@make setup-python
	@make prepare-sql
	@make start
	@echo "$(GREEN)Setup completo finalizado!$(NC)"

setup-python: ## Configura ambiente Python
	@echo "$(YELLOW)Configurando ambiente Python...$(NC)"
	@command -v python3 >/dev/null 2>&1 || { echo "$(RED)Python 3 não está instalado$(NC)"; exit 1; }
	@test -d $(PYTHON_ENV) || python3 -m venv $(PYTHON_ENV)
	@$(PIP) install --upgrade pip
	@make install-deps
	@echo "$(GREEN)Ambiente Python configurado!$(NC)"

install-deps: ## Instala dependências Python
	@echo "$(YELLOW)Instalando dependências Python...$(NC)"
	@test -f requirements.txt || { echo "$(RED)requirements.txt não encontrado$(NC)"; exit 1; }
	@$(PIP) install -r requirements.txt
	@echo "$(GREEN)Dependências instaladas!$(NC)"

venv: ## Ativa ambiente virtual (use: source .venv/bin/activate)
	@echo "$(YELLOW)Para ativar o ambiente virtual execute:$(NC)"
	@echo "$(CYAN)source .venv/bin/activate$(NC)"

start: ## Inicia os serviços (PostgreSQL + Adminer)
	@echo "$(YELLOW)Iniciando District ZER0 Database...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)Serviços iniciados!$(NC)"
	@echo "$(YELLOW)Aguardando PostgreSQL inicializar e executar scripts...$(NC)"
	@echo "$(BLUE)Scripts que serão executados automaticamente:$(NC)"
	@echo "  • 01_ddl_postgres.sql (Estrutura do banco)"
	@echo "  • 02_dml_postgres.sql (Dados iniciais)"
	@echo "  • 03_dql_postgres.sql (Queries de validação)"
	@echo "  • 04_correcoes_criticas.sql (Correções)"
	@echo "  • 05_triggers_basicas.sql (Triggers)"
	@echo "  • 06_procedures_basicas.sql (Procedures básicas)"
	@echo "  • 07_procedures_criticas.sql (Procedures críticas)"
	@echo "  • 08_procedures_faccoes.sql (Sistema de facções)"
	@echo "$(YELLOW)Aguardando health check...$(NC)"
	@timeout 60 sh -c 'until docker-compose ps | grep -q "healthy"; do echo "Aguardando inicialização..."; sleep 2; done' || echo "$(RED)Health check timeout - verifique os logs$(NC)"
	@echo "$(GREEN)PostgreSQL: http://localhost:5432$(NC)"
	@echo "$(GREEN)Adminer: http://localhost:8080$(NC)"
	@echo ""
	@echo "$(YELLOW)Credenciais de acesso:$(NC)"
	@echo "  Sistema: PostgreSQL"
	@echo "  Servidor: postgres"
	@echo "  Usuário: $(POSTGRES_USER)"
	@echo "  Senha: $(POSTGRES_PASSWORD)"
	@echo "  Base de dados: $(POSTGRES_DATABASE)"
	@echo ""
	@echo "$(CYAN)Para verificar se os scripts foram executados: make verify-scripts$(NC)"
	@echo "$(CYAN)Para jogar execute: make play$(NC)"

stop: ## Para os serviços
	@echo "$(YELLOW)Parando District ZER0 Database...$(NC)"
	@docker-compose down
	@echo "$(GREEN)Serviços parados!$(NC)"

restart: stop start ## Reinicia os serviços

clean: ## Remove containers e volumes (CUIDADO: apaga todos os dados!)
	@echo "$(RED)ATENÇÃO: Isso irá apagar TODOS os dados do banco!$(NC)"
	@read -p "Tem certeza? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker-compose down -v
	@docker volume prune -f
	@echo "$(GREEN)Limpeza concluída!$(NC)"

reset-db: ## Reinicia o banco de dados com dados limpos
	@echo "$(YELLOW)Reiniciando banco de dados...$(NC)"
	@docker-compose down
	@docker volume rm district_zero_postgres_data 2>/dev/null || true
	@docker-compose up -d
	@echo "$(GREEN)Banco de dados reiniciado!$(NC)"

force-rebuild: ## Força reconstrução completa do banco
	@echo "$(YELLOW)Forçando reconstrução completa do banco...$(NC)"
	@docker-compose down -v
	@docker volume rm district_zero_postgres_data 2>/dev/null || true
	@docker system prune -f
	@echo "$(YELLOW)Reconstruindo containers...$(NC)"
	@docker-compose up -d --force-recreate
	@echo "$(GREEN)Reconstrução completa finalizada!$(NC)"

connect-db: ## Conecta ao PostgreSQL via linha de comando
	@echo "$(YELLOW)Conectando ao PostgreSQL...$(NC)"
	@docker exec -it district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE)

psql-cli: ## Conecta ao PostgreSQL como usuário padrão
	@echo "$(YELLOW)Conectando ao PostgreSQL...$(NC)"
	@docker exec -it district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE)

test: ## Executa queries de validação do banco
	@echo "$(YELLOW)Executando queries de validação...$(NC)"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) < Dev/03_dql_postgres.sql
	@echo "$(GREEN)Validação do banco executada!$(NC)"

verify-scripts: ## Verifica se todos os scripts foram executados
	@echo "$(YELLOW)Verificando execução dos scripts SQL...$(NC)"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT 'DDL - Tabelas criadas: ' || COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT 'DML - Jogadores inseridos: ' || COUNT(*) FROM jogadores;"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT 'Triggers - Triggers criadas: ' || COUNT(*) FROM information_schema.triggers WHERE trigger_schema = 'public';"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT 'Procedures - Funções criadas: ' || COUNT(*) FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type = 'FUNCTION';"
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT 'Sistema - Configurações: ' || COUNT(*) FROM sistema_config;"
	@echo "$(GREEN)Verificação de scripts concluída!$(NC)"

# === COMANDOS DO JOGO ===

play: ## Executa o jogo (setup automático se necessário)
	@echo "$(MAGENTA)🎮 DISTRICT ZER0 - CYBERPUNK MUD$(NC)"
	@echo "$(MAGENTA)================================$(NC)"
	@echo ""
	@if [ ! -d "$(PYTHON_ENV)" ]; then \
		echo "$(YELLOW)Ambiente Python não encontrado. Configurando...$(NC)"; \
		make setup-python; \
	fi
	@if ! docker-compose ps | grep -q "healthy"; then \
		echo "$(YELLOW)Banco não está rodando ou não está saudável. Iniciando...$(NC)"; \
		make start; \
		echo "$(YELLOW)Aguardando estabilização...$(NC)"; \
		sleep 5; \
	fi
	@echo "$(GREEN)Iniciando District ZER0...$(NC)"
	@echo ""
	@$(PYTHON) run_game.py

test-setup: ## Testa se o ambiente está configurado
	@echo "$(YELLOW)Testando configuração do District ZER0...$(NC)"
	@if [ ! -d "$(PYTHON_ENV)" ]; then \
		echo "$(RED)❌ Ambiente Python não configurado$(NC)"; \
		echo "$(CYAN)Execute: make setup-python$(NC)"; \
		exit 1; \
	fi
	@if ! docker-compose ps | grep -q "healthy"; then \
		echo "$(RED)❌ Banco não está rodando ou não está saudável$(NC)"; \
		echo "$(CYAN)Execute: make start$(NC)"; \
		exit 1; \
	fi
	@$(PYTHON) test_setup.py

demo: ## Demonstração completa do sistema
	@echo "$(MAGENTA)🎮 DISTRICT ZER0 - DEMONSTRAÇÃO COMPLETA$(NC)"
	@echo "$(MAGENTA)=====================================$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Configurando ambiente...$(NC)"
	@make setup
	@echo ""
	@echo "$(YELLOW)2. Testando configuração...$(NC)"
	@make test-setup
	@echo ""
	@echo "$(YELLOW)3. Validando banco de dados...$(NC)"
	@make test
	@echo ""
	@echo "$(YELLOW)4. Verificando scripts executados...$(NC)"
	@make verify-scripts
	@echo ""
	@echo "$(GREEN)✅ Sistema pronto!$(NC)"
	@echo ""
	@echo "$(CYAN)🎯 ACESSO AO SISTEMA:$(NC)"
	@echo "  • Jogo: make play"
	@echo "  • Adminer: http://localhost:8080"
	@echo "  • Banco: localhost:5432"
	@echo ""
	@echo "$(YELLOW)Quer jogar agora? [s/N]$(NC)"
	@read -r play; \
	if [ "$$play" = "s" ] || [ "$$play" = "S" ]; then \
		make play; \
	fi

status: ## Mostra status dos serviços
	@echo "$(YELLOW)Status dos serviços District ZER0:$(NC)"
	@docker-compose ps

health: ## Executa verificação completa de saúde dos serviços
	@echo "$(YELLOW)Verificação de saúde dos serviços:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(YELLOW)Health check do PostgreSQL:$(NC)"
	@docker exec district_zero_postgres pg_isready -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) || echo "$(RED)PostgreSQL não está respondendo$(NC)"
	@echo ""
	@echo "$(YELLOW)Testando conexão com o banco:$(NC)"
	@docker exec district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) -c "SELECT version();" || echo "$(RED)Erro ao conectar no banco$(NC)"

logs: ## Mostra logs dos serviços
	@echo "$(YELLOW)Logs dos serviços District ZER0:$(NC)"
	@docker-compose logs -f

debug-logs: ## Mostra logs detalhados para debug
	@echo "$(YELLOW)Logs detalhados para debug:$(NC)"
	@echo "$(BLUE)Logs do PostgreSQL:$(NC)"
	@docker-compose logs postgres
	@echo ""
	@echo "$(BLUE)Logs do Adminer:$(NC)"
	@docker-compose logs adminer

check-volumes: ## Verifica volumes Docker
	@echo "$(YELLOW)Verificando volumes Docker:$(NC)"
	@docker volume ls | grep district || echo "$(RED)Nenhum volume encontrado$(NC)"
	@echo ""
	@echo "$(YELLOW)Detalhes dos volumes:$(NC)"
	@docker volume inspect district_zero_postgres_data 2>/dev/null || echo "$(RED)Volume principal não encontrado$(NC)"

clean-volumes: ## Limpa volumes Docker
	@echo "$(YELLOW)Limpando volumes Docker...$(NC)"
	@docker-compose down -v
	@docker volume prune -f
	@echo "$(GREEN)Volumes limpos!$(NC)"

check-scripts: ## Verifica quais scripts SQL serão executados
	@echo "$(YELLOW)Scripts SQL no diretório Dev/:$(NC)"
	@ls -la Dev/*.sql 2>/dev/null | while read -r line; do \
		file=$$(echo "$$line" | awk '{print $$NF}'); \
		if [ -f "$$file" ]; then \
			echo "  $(GREEN)✓$(NC) $$file"; \
		fi; \
	done
	@echo ""
	@echo "$(BLUE)Ordem de execução (alfabética):$(NC)"
	@ls Dev/*.sql 2>/dev/null | nl -v0 | sed 's/^/  /'
	@echo ""
	@echo "$(YELLOW)Verificando permissões dos arquivos:$(NC)"
	@ls -la Dev/*.sql | awk '{print "  " $$1 " " $$NF}'

prepare-sql: ## Prepara arquivos SQL para execução no Docker
	@echo "$(YELLOW)Preparando arquivos SQL para execução...$(NC)"
	@./scripts/prepare-sql-files.sh

validate-system: ## Valida se todo o sistema está funcionando
	@echo "$(YELLOW)Validando sistema District ZER0...$(NC)"
	@make check-scripts
	@echo ""
	@make status
	@echo ""
	@make health
	@echo ""
	@make verify-scripts

# Comandos avançados
backup: ## Cria backup do banco de dados
	@echo "$(YELLOW)Criando backup...$(NC)"
	@mkdir -p backups
	@docker exec district_zero_postgres pg_dump -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) > backups/district_zero_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup criado em backups/$(NC)"

restore: ## Restaura backup (especifique BACKUP_FILE=nome_do_arquivo.sql)
	@echo "$(YELLOW)Restaurando backup...$(NC)"
	@test -n "$(BACKUP_FILE)" || { echo "$(RED)Uso: make restore BACKUP_FILE=nome_do_arquivo.sql$(NC)"; exit 1; }
	@test -f "backups/$(BACKUP_FILE)" || { echo "$(RED)Arquivo de backup não encontrado$(NC)"; exit 1; }
	@docker exec -i district_zero_postgres psql -U$(POSTGRES_USER) -d$(POSTGRES_DATABASE) < backups/$(BACKUP_FILE)
	@echo "$(GREEN)Backup restaurado!$(NC)"

dev: ## Modo desenvolvedor (inicia + mostra logs)
	@make start
	@make logs

# Comandos para documentação
docs-serve: ## Serve a documentação do MkDocs
	@echo "$(YELLOW)Servindo documentação...$(NC)"
	@python -m venv .venv || true
	@source .venv/bin/activate && pip install -r requirements.txt
	@source .venv/bin/activate && mkdocs serve
	@echo "$(GREEN)Documentação disponível em http://localhost:8000$(NC)"

docs-build: ## Constrói a documentação
	@echo "$(YELLOW)Construindo documentação...$(NC)"
	@python -m venv .venv || true
	@source .venv/bin/activate && pip install -r requirements.txt
	@source .venv/bin/activate && mkdocs build
	@echo "$(GREEN)Documentação construída em site/$(NC)"

# Comandos para entrega
entrega: ## Prepara o projeto para entrega
	@echo "$(YELLOW)Preparando District ZER0 para entrega...$(NC)"
	@make clean
	@make start
	@sleep 15
	@make test
	@make verify-scripts
	@echo "$(GREEN)Projeto pronto para entrega!$(NC)"
	@echo ""
	@echo "$(YELLOW)Acesse:$(NC)"
	@echo "  • Adminer: http://localhost:8080"
	@echo "  • Documentação: make docs-serve"
	@echo ""
	@echo "$(YELLOW)Para demonstração:$(NC)"
	@echo "  1. make start"
	@echo "  2. Acesse http://localhost:8080"
	@echo "  3. make test (para executar queries)"

# === COMANDO PADRÃO ===
all: demo ## Executa demonstração completa

# === INFORMAÇÕES ÚTEIS ===
info: ## Mostra informações sobre o projeto
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)║                         DISTRICT ZER0 - CYBERPUNK MUD                       ║$(NC)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)📋 SISTEMA COMPLETO:$(NC)"
	@echo "  • PostgreSQL 15 com 18 tabelas"
	@echo "  • 50+ procedures e functions"
	@echo "  • 15+ triggers automáticas"
	@echo "  • Interface CLI Python completa"
	@echo "  • 15 salas interconectadas"
	@echo "  • 6 classes de personagem"
	@echo "  • 7 facções disponíveis"
	@echo "  • 12 missões implementadas"
	@echo ""
	@echo "$(YELLOW)🚀 COMANDOS PRINCIPAIS:$(NC)"
	@echo "  $(GREEN)make play$(NC)     - Jogar o MUD"
	@echo "  $(GREEN)make demo$(NC)     - Demonstração completa"
	@echo "  $(GREEN)make setup$(NC)    - Configurar tudo"
	@echo "  $(GREEN)make help$(NC)     - Ver todos os comandos"
	@echo ""
	@echo "$(YELLOW)🔗 ACESSO:$(NC)"
	@echo "  • Jogo: make play"
	@echo "  • Adminer: http://localhost:8080"
	@echo "  • PostgreSQL: localhost:5432" 