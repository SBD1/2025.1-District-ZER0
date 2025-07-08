"""
Database Manager para District ZER0
Gerenciamento de conexão e operações com PostgreSQL
"""

import psycopg2
import psycopg2.extras
import os
from typing import Optional, Dict, List, Any

class DatabaseManager:
    def __init__(self):
        self.connection = None
        self.host = os.getenv('DB_HOST', 'localhost')
        self.port = os.getenv('DB_PORT', '5432')
        self.database = os.getenv('DB_NAME', 'district_zero')
        self.username = os.getenv('DB_USER', 'district_zero_user')
        self.password = os.getenv('DB_PASS', 'district_zero_pass')
        
    def connect(self) -> bool:
        """Conectar ao banco de dados"""
        try:
            self.connection = psycopg2.connect(
                host=self.host,
                port=self.port,
                database=self.database,
                user=self.username,
                password=self.password
            )
            self.connection.autocommit = True
            return True
        except psycopg2.Error as e:
            print(f"Erro ao conectar ao banco: {e}")
            return False
            
    def disconnect(self):
        """Desconectar do banco"""
        if self.connection:
            self.connection.close()
            self.connection = None
            
    def test_connection(self) -> bool:
        """Testar conexão com banco"""
        try:
            if not self.connection:
                if not self.connect():
                    return False
                    
            cursor = self.connection.cursor()
            cursor.execute("SELECT 1")
            cursor.close()
            return True
        except psycopg2.Error:
            return False
            
    def execute_query(self, query: str, params: tuple = None) -> Optional[List[Dict]]:
        """Executar query SELECT e retornar resultados"""
        try:
            if not self.connection:
                if not self.connect():
                    return None
                    
            cursor = self.connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
            if params:
                cursor.execute(query, params)
            else:
                cursor.execute(query)
            results = cursor.fetchall()
            cursor.close()
            
            # Converter para lista de dicionários
            return [dict(row) for row in results]
            
        except psycopg2.Error as e:
            print(f"Erro ao executar query: {e}")
            return None
            
    def execute_function(self, function_name: str, params: tuple = None) -> Optional[str]:
        """Executar função PostgreSQL e retornar resultado"""
        try:
            if not self.connection:
                if not self.connect():
                    return None
                    
            cursor = self.connection.cursor()
            
            # Construir chamada da função
            if params:
                placeholders = ', '.join(['%s'] * len(params))
                query = f"SELECT {function_name}({placeholders})"
                cursor.execute(query, params)
            else:
                query = f"SELECT {function_name}()"
                cursor.execute(query)
                
            result = cursor.fetchone()
            cursor.close()
            
            return result[0] if result else None
            
        except psycopg2.Error as e:
            print(f"Erro ao executar função: {e}")
            return None
            
    def execute_insert(self, query: str, params: tuple = None) -> Optional[int]:
        """Executar INSERT e retornar ID inserido"""
        try:
            if not self.connection:
                if not self.connect():
                    return None
                    
            cursor = self.connection.cursor()
            cursor.execute(query + " RETURNING id", params)
            result = cursor.fetchone()
            cursor.close()
            
            return result[0] if result else None
            
        except psycopg2.Error as e:
            print(f"Erro ao executar insert: {e}")
            return None
            
    def execute_update(self, query: str, params: tuple = None) -> bool:
        """Executar UPDATE/DELETE"""
        try:
            if not self.connection:
                if not self.connect():
                    return False
                    
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            cursor.close()
            
            return True
            
        except psycopg2.Error as e:
            print(f"Erro ao executar update: {e}")
            return False
            
    def __del__(self):
        """Destrutor - fechar conexão"""
        self.disconnect() 