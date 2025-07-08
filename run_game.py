#!/usr/bin/env python3
"""
District ZER0 - Script de Execução
Execute este arquivo para iniciar o jogo
"""

import os
import sys

# Adicionar diretório CLI ao path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'cli'))

# Executar o jogo
if __name__ == "__main__":
    from main import main
    main() 