# **Guia de Setup com Docker - District ZER0**

O Docker é uma plataforma de containerização que permite empacotar aplicações e suas dependências em containers leves, portáteis e consistentes. Este documento apresenta o guia completo para configuração e execução do projeto District ZER0 utilizando Docker, proporcionando um ambiente de desenvolvimento padronizado e de fácil replicação.

## 📋 Pré-requisitos

### Windows

1. **Docker Desktop**: Baixe e instale em https://docker.com/products/docker-desktop
2. **Git**: Baixe em https://git-scm.com/
3. **Make** (opcional): Instale via Chocolatey `choco install make` ou use os comandos docker-compose diretamente

### macOS

```bash
# Instalar Docker Desktop
# Baixe em https://docker.com/products/docker-desktop

# Instalar Make (se não tiver)
xcode-select --install

# Ou via Homebrew
brew install make
```

### Linux (Ubuntu/Debian)

```bash
# Instalar Docker
sudo apt update
sudo apt install docker.io docker-compose

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Fazer logout e login novamente
```

## 🚀 Instalação Rápida

### 1. Clone do Repositório

```bash
git clone <url-do-repositório>
cd 2025.1-District-ZER0
```

### 2. Executar com Make (Recomendado)

```bash
# Verificar dependências
make setup

# Iniciar serviços
make start

# Executar testes
make test

# Verificar saúde dos serviços
make health
```

### 3. Executar Manualmente (Sem Make)

```bash
# Iniciar serviços
docker-compose up -d

# Aguardar inicialização (30 segundos)
sleep 30

# Executar queries de teste
docker exec -i district_zero_mysql mysql -u district_zero_user -p district_zero_pass district_zero < Dev/DQL_mysql.sql

# Verificar status
docker-compose ps
```

## 🔧 Configuração Avançada

### Personalizar Portas

Crie um arquivo `.env` baseado no `.env.example`:

```bash
cp .env.example .env
```

Edite as portas conforme necessário:

```env
MYSQL_PORT=3307        # Se 3306 estiver em uso
ADMINER_PORT=8081      # Se 8080 estiver em uso
```

### Usar Docker Compose Override

Crie `docker-compose.override.yml` para configurações locais:

```yaml
version: "3.8"
services:
  mysql:
    ports:
      - "3307:3306" # Porta customizada
    environment:
      MYSQL_ROOT_PASSWORD: minha_senha_personalizada
```

## 🔍 Verificação e Troubleshooting

### Verificar se Tudo Está Funcionando

```bash
# Comando completo de verificação
make health

# Ou manualmente
docker-compose ps
docker exec district_zero_mysql mysql -u district_zero_user -p district_zero_pass -e "SELECT 'Conexão OK' as status;"
```

### Problemas Comuns

#### 1. Porta 3306 já em uso

```bash
# Ver o que está usando a porta
sudo lsof -i :3306

# Parar MySQL local
sudo service mysql stop

# Ou usar porta diferente no .env
echo "MYSQL_PORT=3307" >> .env
```

#### 2. Permissões no Linux

```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Fazer logout e login
# Ou usar newgrp
newgrp docker
```

#### 3. Container não inicia

```bash
# Ver logs detalhados
docker-compose logs mysql

# Reiniciar tudo
docker-compose down -v
docker-compose up -d
```

#### 4. Banco não inicializa

```bash
# Verificar se os arquivos SQL estão no lugar
ls -la Dev/

# Reiniciar com limpeza completa
make clean  # CUIDADO: apaga todos os dados
make start
```

## 📊 Comandos Úteis

### Desenvolvimento

```bash
# Logs em tempo real
make logs

# Conectar ao MySQL
make connect-db

# Backup
make backup

# Restaurar backup
make restore BACKUP_FILE=district_zero_20250101_120000.sql
```

### Manutenção

```bash
# Parar serviços
make stop

# Reiniciar
make restart

# Limpeza completa (CUIDADO!)
make clean
```

### Monitoramento

```bash
# Status dos containers
docker-compose ps

# Uso de recursos
docker stats

# Logs específicos
docker logs district_zero_mysql
docker logs district_zero_adminer
```

## 🌐 Acessos

Depois de iniciar os serviços:

### Adminer (Interface Web)

- **URL**: http://localhost:8080
- **Sistema**: MySQL
- **Servidor**: mysql
- **Usuário**: district_zero_user
- **Senha**: district_zero_pass
- **Base de dados**: district_zero

### MySQL Direto

- **Host**: localhost
- **Porta**: 3306
- **Usuário**: district_zero_user
- **Senha**: district_zero_pass
- **Database**: district_zero

### Cliente MySQL

```bash
mysql -h localhost -P 3306 -u district_zero_user -p district_zero
# Senha: district_zero_pass
```

## 🎯 Para Demonstração

Execute estes comandos para uma demonstração completa:

```bash
# 1. Setup completo
make entrega

# 2. Verificar se tudo está OK
make health

# 3. Mostrar dados
make test
```

Depois acesse http://localhost:8080 e execute algumas queries do arquivo `Dev/DQL_mysql.sql`.

## 📚 Arquivos Importantes

```
2025.1-District-ZER0/
├── docker-compose.yml      # Configuração principal
├── .env.example           # Configurações de exemplo
├── Makefile              # Automação
├── scripts/
│   └── health-check.sh   # Script de verificação
└── Dev/
    ├── 00_init.sql       # Executado automaticamente
    ├── DDL_mysql.sql     # Estrutura do banco
    ├── DML_mysql.sql     # Dados iniciais
    └── DQL_mysql.sql     # Queries de exemplo
    └── DDL.sql           # Dicionário de Dados
    └── DML.sql           # Dados iniciais
    └── DQL.sql           # Queries de exemplo
```

## ⚠️ Notas Importantes

1. **Primeira execução**: O MySQL demora ~30 segundos para inicializar completamente
2. **Dados persistentes**: Os dados ficam no volume Docker `mysql_data`
3. **Limpeza**: `make clean` apaga TODOS os dados permanentemente
4. **Backups**: Use `make backup` regularmente em desenvolvimento
5. **Portas**: Certifique-se que as portas 3306 e 8080 estão livres

## 🆘 Suporte

Se tiver problemas:

1. Execute `make health` para diagnóstico
2. Verifique os logs com `make logs`
3. Tente reiniciar com `make restart`
4. Em último caso, use `make clean` e `make start` (perde dados!)

## Histórico de Versão

| Versão |    Data    |              Descrição              |                       Autor(es)                        |
| :----: | :--------: | :---------------------------------: | :----------------------------------------------------: |
| `1.0`  | 12/06/2025 | Criação do Guia de Setup com Docker | [Vinicius Vieira](https://github.com/viniciusvieira00) |
