"""
Authentication Manager para District ZER0
Gerenciamento de autenticação e registro de usuários
"""

import bcrypt
import re
from typing import Optional, Dict
from database import DatabaseManager

class AuthManager:
    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
        
    def register(self, username: str, password: str) -> Dict[str, any]:
        """Registrar novo usuário"""
        try:
            # Validar username
            if not self._validate_username(username):
                return {
                    'success': False,
                    'error': 'Username deve ter 3-40 caracteres e conter apenas letras, números e underscore'
                }
                
            # Validar senha
            if not self._validate_password(password):
                return {
                    'success': False,
                    'error': 'Senha deve ter pelo menos 6 caracteres'
                }
                
            # Verificar se usuário já existe
            existing_user = self.db.execute_query(
                "SELECT id FROM jogadores WHERE username = %s",
                (username,)
            )
            
            if existing_user:
                return {
                    'success': False,
                    'error': 'Username já está em uso'
                }
                
            # Hashear senha
            password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
            
            # Inserir usuário
            user_id = self.db.execute_insert(
                "INSERT INTO jogadores (username, senha_hash) VALUES (%s, %s)",
                (username, password_hash.decode('utf-8'))
            )
            
            if user_id:
                return {
                    'success': True,
                    'user_id': user_id
                }
            else:
                return {
                    'success': False,
                    'error': 'Erro ao criar usuário'
                }
                
        except Exception as e:
            return {
                'success': False,
                'error': f'Erro interno: {str(e)}'
            }
            
    def login(self, username: str, password: str) -> Optional[Dict[str, any]]:
        """Fazer login"""
        try:
            # Buscar usuário
            user_data = self.db.execute_query(
                "SELECT id, username, senha_hash, is_active FROM jogadores WHERE username = %s",
                (username,)
            )
            
            if not user_data:
                return None
                
            user = user_data[0]
            
            # Verificar se usuário está ativo
            if not user['is_active']:
                return None
                
            # Verificar senha
            if bcrypt.checkpw(password.encode('utf-8'), user['senha_hash'].encode('utf-8')):
                # Atualizar último login
                self.db.execute_update(
                    "UPDATE jogadores SET last_login = CURRENT_TIMESTAMP WHERE id = %s",
                    (user['id'],)
                )
                
                return {
                    'id': user['id'],
                    'username': user['username']
                }
            else:
                return None
                
        except Exception as e:
            print(f"Erro no login: {e}")
            return None
            
    def _validate_username(self, username: str) -> bool:
        """Validar formato do username"""
        if not username or len(username) < 3 or len(username) > 40:
            return False
            
        # Apenas letras, números e underscore
        if not re.match(r'^[a-zA-Z0-9_]+$', username):
            return False
            
        return True
        
    def _validate_password(self, password: str) -> bool:
        """Validar formato da senha"""
        if not password or len(password) < 6:
            return False
            
        return True 