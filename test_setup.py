#!/usr/bin/env python3
"""
Teste de Configuração do District ZER0
Verifica se o ambiente está pronto para executar o jogo
"""

import sys
import os

def test_imports():
    """Testar importações das dependências"""
    print("🔧 Testando dependências...")
    
    try:
        import psycopg2
        print("  ✅ psycopg2 - OK")
    except ImportError as e:
        print(f"  ❌ psycopg2 - ERRO: {e}")
        return False
        
    try:
        import colorama
        print("  ✅ colorama - OK")
    except ImportError as e:
        print(f"  ❌ colorama - ERRO: {e}")
        return False
        
    try:
        import bcrypt
        print("  ✅ bcrypt - OK")
    except ImportError as e:
        print(f"  ❌ bcrypt - ERRO: {e}")
        return False
        
    try:
        import tabulate
        print("  ✅ tabulate - OK")
    except ImportError as e:
        print(f"  ❌ tabulate - ERRO: {e}")
        return False
        
    try:
        from dotenv import load_dotenv
        print("  ✅ python-dotenv - OK")
    except ImportError as e:
        print(f"  ❌ python-dotenv - ERRO: {e}")
        return False
        
    return True

def test_cli_modules():
    """Testar módulos da CLI"""
    print("\n🎮 Testando módulos da CLI...")
    
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'cli'))
    
    try:
        from database import DatabaseManager
        print("  ✅ DatabaseManager - OK")
    except ImportError as e:
        print(f"  ❌ DatabaseManager - ERRO: {e}")
        return False
        
    try:
        from auth import AuthManager
        print("  ✅ AuthManager - OK")
    except ImportError as e:
        print(f"  ❌ AuthManager - ERRO: {e}")
        return False
        
    try:
        from game import GameManager
        print("  ✅ GameManager - OK")
    except ImportError as e:
        print(f"  ❌ GameManager - ERRO: {e}")
        return False
        
    try:
        from ui import UIManager
        print("  ✅ UIManager - OK")
    except ImportError as e:
        print(f"  ❌ UIManager - ERRO: {e}")
        return False
        
    return True

def test_database_connection():
    """Testar conexão com banco"""
    print("\n🐘 Testando conexão com PostgreSQL...")
    
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'cli'))
    
    try:
        from database import DatabaseManager
        
        db = DatabaseManager()
        if db.test_connection():
            print("  ✅ Conexão com PostgreSQL - OK")
            
            # Testar uma query simples
            result = db.execute_query("SELECT COUNT(*) as total FROM jogadores")
            if result:
                print(f"  ✅ Query de teste - OK (jogadores: {result[0]['total']})")
            else:
                print("  ⚠️  Query de teste falhou - banco pode não estar inicializado")
                
            return True
        else:
            print("  ❌ Conexão com PostgreSQL - FALHOU")
            print("  💡 Certifique-se de que o Docker está rodando: docker-compose up -d")
            return False
            
    except Exception as e:
        print(f"  ❌ Erro ao testar banco: {e}")
        return False

def main():
    """Executar todos os testes"""
    print("🚀 DISTRICT ZER0 - TESTE DE CONFIGURAÇÃO\n")
    
    tests = [
        ("Dependências Python", test_imports),
        ("Módulos CLI", test_cli_modules),
        ("Banco de Dados", test_database_connection)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            success = test_func()
            results.append((test_name, success))
        except Exception as e:
            print(f"  ❌ Erro inesperado em {test_name}: {e}")
            results.append((test_name, False))
    
    print("\n" + "="*50)
    print("📊 RESULTADOS DOS TESTES:")
    print("="*50)
    
    all_passed = True
    for test_name, success in results:
        status = "✅ PASSOU" if success else "❌ FALHOU"
        print(f"  {test_name:<20} {status}")
        if not success:
            all_passed = False
    
    print("\n" + "="*50)
    if all_passed:
        print("🎉 TODOS OS TESTES PASSARAM!")
        print("🎮 Você pode executar o jogo com: python run_game.py")
    else:
        print("⚠️  ALGUNS TESTES FALHARAM!")
        print("🔧 Corrija os problemas antes de executar o jogo.")
        
    print("="*50)

if __name__ == "__main__":
    main() 