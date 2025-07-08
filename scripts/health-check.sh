#!/bin/bash

# District ZER0 - Health Check Script
# Verifica se todos os serviços estão funcionando corretamente

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}District ZER0 - Health Check${NC}"
echo "================================"

# Verifica se Docker está rodando
echo -n "Verificando Docker... "
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}ERRO${NC}"
    echo "Docker não está rodando ou não está acessível."
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# Verifica se os containers estão rodando
echo -n "Verificando containers... "
if ! docker-compose ps | grep -q "district_zero_postgres.*Up"; then
    echo -e "${RED}ERRO${NC}"
    echo "Container PostgreSQL não está rodando."
    echo "Execute: make start"
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# Verifica conexão com PostgreSQL
echo -n "Verificando conexão PostgreSQL... "
if ! docker exec district_zero_postgres pg_isready -U district_zero_user -d district_zero > /dev/null 2>&1; then
    echo -e "${RED}ERRO${NC}"
    echo "Não foi possível conectar ao PostgreSQL."
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# Verifica se o banco de dados existe
echo -n "Verificando banco de dados... "
if ! docker exec district_zero_postgres psql -U district_zero_user -d district_zero -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${RED}ERRO${NC}"
    echo "Banco de dados district_zero não existe ou não está acessível."
    exit 1
else
    echo -e "${GREEN}OK${NC}"
fi

# Verifica se as tabelas existem
echo -n "Verificando tabelas... "
TABLE_COUNT=$(docker exec district_zero_postgres psql -U district_zero_user -d district_zero -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | xargs)
if [ "$TABLE_COUNT" -lt 10 ]; then
    echo -e "${RED}ERRO${NC}"
    echo "Número insuficiente de tabelas encontradas ($TABLE_COUNT)."
    exit 1
else
    echo -e "${GREEN}OK (${TABLE_COUNT} tabelas)${NC}"
fi

# Verifica se há dados nas tabelas
echo -n "Verificando dados... "
JOGADOR_COUNT=$(docker exec district_zero_postgres psql -U district_zero_user -d district_zero -t -c "SELECT COUNT(*) FROM jogadores;" 2>/dev/null | xargs)
if [ "$JOGADOR_COUNT" -lt 1 ]; then
    echo -e "${RED}ERRO${NC}"
    echo "Não há dados nas tabelas."
    exit 1
else
    echo -e "${GREEN}OK (${JOGADOR_COUNT} jogadores)${NC}"
fi

# Verifica se Adminer está acessível
echo -n "Verificando Adminer... "
if ! curl -s http://localhost:8080 > /dev/null 2>&1; then
    echo -e "${YELLOW}AVISO${NC}"
    echo "Adminer pode não estar acessível em http://localhost:8080"
else
    echo -e "${GREEN}OK${NC}"
fi

echo ""
echo -e "${GREEN}✓ Todos os serviços estão funcionando!${NC}"
echo ""
echo "Acesse:"
echo "  • Adminer: http://localhost:8080"
echo "  • PostgreSQL: localhost:5432"
echo ""
echo "Credenciais:"
echo "  • Usuário: district_zero_user"
echo "  • Senha: district_zero_pass"
echo "  • Database: district_zero" 