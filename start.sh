#!/bin/bash

# District ZER0 - Script de Inicialização Rápida
# Execute este script para jogar rapidamente

echo "🎮 District ZER0 - Cyberpunk MUD"
echo "================================="
echo ""

# Verificar se Make está disponível
if ! command -v make >/dev/null 2>&1; then
    echo "❌ Make não está instalado"
    echo "💡 Instale make ou execute os comandos manualmente"
    exit 1
fi

# Verificar se existe Makefile
if [ ! -f "Makefile" ]; then
    echo "❌ Makefile não encontrado"
    echo "💡 Execute este script no diretório raiz do projeto"
    exit 1
fi

echo "🚀 Iniciando District ZER0..."
make play 