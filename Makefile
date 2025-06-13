# District ZER0 - Makefile
# Cyberpunk Pocket MUD Database Management

# Configurações
MYSQL_HOST = localhost
MYSQL_PORT = 3306
MYSQL_USER = district_zero_user
MYSQL_PASSWORD = district_zero_pass
MYSQL_DATABASE = district_zero
MYSQL_ROOT_PASSWORD = district_zero_root

# Cores para output
YELLOW = \033[1;33m
GREEN = \033[1;32m
RED = \033[1;31m
NC = \033[0m # No Color

.PHONY: help setup start stop restart clean reset-db connect-db test status mysql-cli logs

help: ## Mostra esta mensagem de ajuda
	@echo "$(YELLOW)District ZER0 - Cyberpunk Pocket MUD$(NC)"
	@echo "$(YELLOW)====================================$(NC)"
	@echo ""
	@echo "Comandos disponíveis:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Instala dependências e prepara o ambiente
	@echo "$(YELLOW)Configurando ambiente District ZER0...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker não está instalado$(NC)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)Docker Compose não está instalado$(NC)"; exit 1; }
	@echo "$(GREEN)Ambiente configurado com sucesso!$(NC)"

start: ## Inicia os serviços (MySQL + Adminer)
	@echo "$(YELLOW)Iniciando District ZER0 Database...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)Serviços iniciados!$(NC)"
	@echo "$(YELLOW)Aguardando MySQL inicializar...$(NC)"
	@sleep 10
	@echo "$(GREEN)MySQL: http://localhost:3306$(NC)"
	@echo "$(GREEN)Adminer: http://localhost:8080$(NC)"
	@echo ""
	@echo "$(YELLOW)Credenciais de acesso:$(NC)"
	@echo "  Sistema: MySQL"
	@echo "  Servidor: mysql"
	@echo "  Usuário: $(MYSQL_USER)"
	@echo "  Senha: $(MYSQL_PASSWORD)"
	@echo "  Base de dados: $(MYSQL_DATABASE)"

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
	@docker volume rm $$(docker volume ls -q | grep district) 2>/dev/null || true
	@docker-compose up -d
	@echo "$(GREEN)Banco de dados reiniciado!$(NC)"

connect-db: ## Conecta ao MySQL via linha de comando
	@echo "$(YELLOW)Conectando ao MySQL...$(NC)"
	@docker exec -it district_zero_mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE)

mysql-cli: ## Conecta ao MySQL como root
	@echo "$(YELLOW)Conectando ao MySQL como root...$(NC)"
	@docker exec -it district_zero_mysql mysql -uroot -p$(MYSQL_ROOT_PASSWORD)

test: ## Executa queries de teste
	@echo "$(YELLOW)Executando queries de teste...$(NC)"
	@docker exec -i district_zero_mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < Dev/DQL_mysql.sql
	@echo "$(GREEN)Testes executados!$(NC)"

status: ## Mostra status dos serviços
	@echo "$(YELLOW)Status dos serviços District ZER0:$(NC)"
	@docker-compose ps

health: ## Executa verificação completa de saúde dos serviços
	@./scripts/health-check.sh

logs: ## Mostra logs dos serviços
	@echo "$(YELLOW)Logs dos serviços District ZER0:$(NC)"
	@docker-compose logs -f

# Comandos avançados
backup: ## Cria backup do banco de dados
	@echo "$(YELLOW)Criando backup...$(NC)"
	@mkdir -p backups
	@docker exec district_zero_mysql mysqldump -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) > backups/district_zero_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup criado em backups/$(NC)"

restore: ## Restaura backup (especifique BACKUP_FILE=nome_do_arquivo.sql)
	@echo "$(YELLOW)Restaurando backup...$(NC)"
	@test -n "$(BACKUP_FILE)" || { echo "$(RED)Uso: make restore BACKUP_FILE=nome_do_arquivo.sql$(NC)"; exit 1; }
	@test -f "backups/$(BACKUP_FILE)" || { echo "$(RED)Arquivo de backup não encontrado$(NC)"; exit 1; }
	@docker exec -i district_zero_mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < backups/$(BACKUP_FILE)
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

# Comando padrão
all: setup start test ## Executa setup completo 