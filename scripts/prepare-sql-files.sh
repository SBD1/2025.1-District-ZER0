#!/bin/bash
# District ZER0 - Script para preparar arquivos SQL
# Garante que os arquivos SQL tenham as configurações corretas para execução no PostgreSQL Docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEV_DIR="$PROJECT_ROOT/Dev"

echo "🔧 Preparando arquivos SQL para execução no PostgreSQL Docker..."
echo "Diretório: $DEV_DIR"
echo ""

# Verificar se diretório Dev existe
if [ ! -d "$DEV_DIR" ]; then
    echo "❌ Erro: Diretório Dev não encontrado em $DEV_DIR"
    exit 1
fi

# Contador de arquivos processados
FILES_PROCESSED=0
ERRORS=0

# Processar todos os arquivos .sql no diretório Dev
for sql_file in "$DEV_DIR"/*.sql; do
    if [ -f "$sql_file" ]; then
        filename=$(basename "$sql_file")
        echo "📄 Processando: $filename"
        
        # 1. Converter terminações de linha para Unix (LF)
        if command -v dos2unix >/dev/null 2>&1; then
            dos2unix "$sql_file" 2>/dev/null || true
        else
            # Alternativa caso dos2unix não esteja disponível
            sed -i 's/\r$//' "$sql_file" 2>/dev/null || true
        fi
        
        # 2. Garantir que o arquivo termine com quebra de linha
        if [ -s "$sql_file" ] && [ "$(tail -c1 "$sql_file")" != "" ]; then
            echo "" >> "$sql_file"
        fi
        
        # 3. Definir permissões corretas (legível para todos)
        chmod 644 "$sql_file"
        
        # 4. Verificar se arquivo não está vazio
        if [ ! -s "$sql_file" ]; then
            echo "   ⚠️  Aviso: Arquivo vazio!"
            ERRORS=$((ERRORS + 1))
        else
            # 5. Verificar encoding UTF-8
            if command -v file >/dev/null 2>&1; then
                encoding=$(file -bi "$sql_file" | cut -d'=' -f2)
                if [ "$encoding" != "utf-8" ] && [ "$encoding" != "us-ascii" ]; then
                    echo "   ⚠️  Aviso: Encoding pode não ser UTF-8 ($encoding)"
                fi
            fi
            
            # 6. Verificar sintaxe básica SQL
            if grep -q "CREATE\|INSERT\|SELECT\|UPDATE\|DELETE" "$sql_file"; then
                echo "   ✅ Contém comandos SQL válidos"
            else
                echo "   ⚠️  Aviso: Pode não conter comandos SQL válidos"
                ERRORS=$((ERRORS + 1))
            fi
        fi
        
        FILES_PROCESSED=$((FILES_PROCESSED + 1))
        echo ""
    fi
done

# Verificar ordem de execução
echo "📋 Verificando ordem de execução dos scripts:"
echo ""
ls -1 "$DEV_DIR"/*.sql 2>/dev/null | while read -r file; do
    filename=$(basename "$file")
    echo "   $filename"
done
echo ""

# Verificar se todos os arquivos esperados estão presentes
EXPECTED_FILES=(
    "01_ddl_postgres.sql"
    "02_dml_postgres.sql"
    "03_dql_postgres.sql"
    "04_correcoes_criticas.sql"
    "05_triggers_basicas.sql"
    "06_procedures_basicas.sql"
    "07_procedures_criticas.sql"
    "08_procedures_faccoes.sql"
)

echo "🔍 Verificando arquivos esperados:"
MISSING_FILES=0
for expected_file in "${EXPECTED_FILES[@]}"; do
    if [ -f "$DEV_DIR/$expected_file" ]; then
        echo "   ✅ $expected_file"
    else
        echo "   ❌ $expected_file (FALTANDO)"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done
echo ""

# Criar arquivo de verificação para o Docker
VERIFICATION_FILE="$DEV_DIR/00_verification.sql"
cat > "$VERIFICATION_FILE" << 'EOF'
-- District ZER0 - Arquivo de Verificação
-- Este arquivo é executado primeiro para validar o ambiente

DO $$
BEGIN
    RAISE NOTICE '🎮 DISTRICT ZER0 - Inicializando banco de dados...';
    RAISE NOTICE 'PostgreSQL Version: %', version();
    RAISE NOTICE 'Current Database: %', current_database();
    RAISE NOTICE 'Current User: %', current_user;
    RAISE NOTICE 'Timestamp: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '';
    RAISE NOTICE 'Scripts SQL serão executados em ordem alfabética...';
END
$$;
EOF

chmod 644 "$VERIFICATION_FILE"
echo "📝 Criado arquivo de verificação: 00_verification.sql"
echo ""

# Resumo final
echo "📊 RESUMO DA PREPARAÇÃO:"
echo "   Arquivos processados: $FILES_PROCESSED"
echo "   Arquivos faltando: $MISSING_FILES"
echo "   Avisos/Erros: $ERRORS"
echo ""

if [ $MISSING_FILES -eq 0 ] && [ $ERRORS -eq 0 ]; then
    echo "✅ Todos os arquivos SQL estão prontos para execução!"
    echo ""
    echo "🚀 Próximos passos:"
    echo "   1. Execute: make force-rebuild"
    echo "   2. Execute: make verify-scripts"
    echo "   3. Execute: make play"
elif [ $MISSING_FILES -gt 0 ]; then
    echo "❌ Arquivos SQL faltando! Verifique o diretório Dev/"
    exit 1
elif [ $ERRORS -gt 0 ]; then
    echo "⚠️  Arquivos preparados com avisos. Verifique os arquivos indicados."
else
    echo "✅ Preparação concluída!"
fi 