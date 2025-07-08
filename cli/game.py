"""
Game Manager para District ZER0
Lógica principal do jogo e integração com banco de dados
"""

from typing import Optional, Dict, List, Any
from database import DatabaseManager

class GameManager:
    def __init__(self, db_manager: DatabaseManager):
        self.db = db_manager
        
    def get_character_by_user(self, user_id: int) -> Optional[Dict[str, Any]]:
        """Buscar personagem por ID do usuário"""
        try:
            result = self.db.execute_query("""
                SELECT p.id, j.username, cp.nome as classe, p.nivel, p.vida, p.vida_max,
                       p.experiencia, p.reputacao, p.carteira, p.ataque, p.defesa,
                       p.sala_atual_id, s.nome as sala_atual, f.nome as faccao
                FROM personagens p
                JOIN jogadores j ON p.jogador_id = j.id
                JOIN classe_personagem cp ON p.classe_id = cp.id
                JOIN salas s ON p.sala_atual_id = s.id
                LEFT JOIN faccoes f ON p.faccao_id = f.id
                WHERE j.id = %s
            """, (user_id,))
            
            return result[0] if result else None
            
        except Exception as e:
            print(f"Erro ao buscar personagem: {e}")
            return None
            
    def get_available_classes(self) -> List[Dict[str, Any]]:
        """Buscar classes disponíveis"""
        try:
            result = self.db.execute_query("""
                SELECT id, nome, descricao, vida_base, ataque_base, defesa_base
                FROM classe_personagem
                ORDER BY nome
            """)
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar classes: {e}")
            return []
            
    def create_character(self, user_id: int, class_id: int) -> Dict[str, Any]:
        """Criar novo personagem"""
        try:
            # Buscar dados da classe
            class_data = self.db.execute_query("""
                SELECT vida_base, ataque_base, defesa_base
                FROM classe_personagem
                WHERE id = %s
            """, (class_id,))
            
            if not class_data:
                return {'success': False, 'error': 'Classe não encontrada'}
                
            classe = class_data[0]
            
            # Buscar sala inicial (primeira safe-zone)
            initial_room = self.db.execute_query("""
                SELECT id FROM salas WHERE tipo = 'safe-zone' ORDER BY id LIMIT 1
            """)
            
            if not initial_room:
                return {'success': False, 'error': 'Sala inicial não encontrada'}
                
            room_id = initial_room[0]['id']
            
            # Criar personagem
            character_id = self.db.execute_insert("""
                INSERT INTO personagens (
                    jogador_id, classe_id, nivel, vida, vida_max, experiencia,
                    reputacao, carteira, ataque, defesa, sala_atual_id
                ) VALUES (%s, %s, 1, %s, %s, 0, 0, 300, %s, %s, %s)
            """, (
                user_id, class_id, classe['vida_base'], classe['vida_base'],
                classe['ataque_base'], classe['defesa_base'], room_id
            ))
            
            if character_id:
                return {'success': True, 'character_id': character_id}
            else:
                return {'success': False, 'error': 'Erro ao criar personagem'}
                
        except Exception as e:
            return {'success': False, 'error': f'Erro interno: {str(e)}'}
            
    def look_around(self, character_id: int) -> str:
        """Olhar ao redor da sala atual"""
        try:
            # Buscar dados da sala atual
            character = self.db.execute_query("""
                SELECT sala_atual_id FROM personagens WHERE id = %s
            """, (character_id,))
            
            if not character:
                return "Erro: Personagem não encontrado."
                
            room_id = character[0]['sala_atual_id']
            
            # Buscar informações da sala
            room_info = self.db.execute_query("""
                SELECT nome, descricao, tipo FROM salas WHERE id = %s
            """, (room_id,))
            
            if not room_info:
                return "Erro: Sala não encontrada."
                
            room = room_info[0]
            
            # Buscar mobs na sala
            mobs = self.db.execute_query("""
                SELECT nome, vida, vida_max, is_boss
                FROM mobs
                WHERE sala_id = %s AND vida > 0
            """, (room_id,))
            
            # Buscar itens na sala
            items = self.db.execute_query("""
                SELECT i.nome, its.quantidade
                FROM itens_sala its
                JOIN itens i ON its.item_id = i.id
                WHERE its.sala_id = %s
            """, (room_id,))
            
            # Buscar outros jogadores na sala
            players = self.db.execute_query("""
                SELECT j.username
                FROM personagens p
                JOIN jogadores j ON p.jogador_id = j.id
                WHERE p.sala_atual_id = %s AND p.id != %s
            """, (room_id, character_id))
            
            # Buscar saídas
            exits = self.db.execute_query("""
                SELECT c.direcao, s.nome
                FROM caminhos c
                JOIN salas s ON c.sala_destino = s.id
                WHERE c.sala_origem = %s
            """, (room_id,))
            
            # Montar descrição
            result = f"🏙️  {room['nome']} [{room['tipo'].upper()}]\n"
            result += f"{room['descricao']}\n\n"
            
            if mobs:
                result += "🤖 Inimigos presentes:\n"
                for mob in mobs:
                    boss_mark = " [BOSS]" if mob['is_boss'] else ""
                    result += f"   • {mob['nome']} (HP: {mob['vida']}/{mob['vida_max']}){boss_mark}\n"
                result += "\n"
            else:
                result += "🤖 Nenhum inimigo visível.\n\n"
                
            if items:
                result += "💎 Itens no chão:\n"
                for item in items:
                    result += f"   • {item['nome']} ({item['quantidade']})\n"
                result += "\n"
            else:
                result += "💎 Nenhum item no chão.\n\n"
                
            if players:
                result += "👥 Outros jogadores:\n"
                for player in players:
                    result += f"   • {player['username']}\n"
                result += "\n"
            else:
                result += "👥 Você está sozinho aqui.\n\n"
                
            if exits:
                result += "🧭 Saídas disponíveis:\n"
                for exit in exits:
                    direction_name = {
                        'N': 'Norte', 'S': 'Sul', 'L': 'Leste', 'O': 'Oeste'
                    }.get(exit['direcao'], exit['direcao'])
                    result += f"   • {direction_name} → {exit['nome']}\n"
            else:
                result += "🧭 Nenhuma saída disponível.\n"
                
            return result
            
        except Exception as e:
            return f"Erro ao olhar ao redor: {str(e)}"
            
    def move_character(self, character_id: int, direction: str) -> str:
        """Mover personagem"""
        try:
            result = self.db.execute_function('mover_personagem', (character_id, direction))
            return result if result else "Erro ao mover personagem."
            
        except Exception as e:
            return f"Erro no movimento: {str(e)}"
            
    def attack_mob(self, character_id: int, mob_id: int) -> str:
        """Atacar mob"""
        try:
            result = self.db.execute_function('atacar_mob', (character_id, mob_id))
            return result if result else "Erro no combate."
            
        except Exception as e:
            return f"Erro no combate: {str(e)}"
            
    def show_inventory(self, character_id: int) -> str:
        """Mostrar inventário"""
        try:
            result = self.db.execute_function('listar_inventario', (character_id,))
            return result if result else "Erro ao buscar inventário."
            
        except Exception as e:
            return f"Erro no inventário: {str(e)}"
            
    def show_status(self, character_id: int) -> str:
        """Mostrar status do personagem"""
        try:
            result = self.db.execute_function('status_personagem', (character_id,))
            return result if result else "Erro ao buscar status."
            
        except Exception as e:
            return f"Erro no status: {str(e)}"
            
    def get_mobs_in_room(self, room_id: int) -> List[Dict[str, Any]]:
        """Buscar mobs na sala"""
        try:
            result = self.db.execute_query("""
                SELECT id, nome, vida, vida_max, ataque, defesa, is_boss
                FROM mobs
                WHERE sala_id = %s AND vida > 0
                ORDER BY is_boss DESC, nome
            """, (room_id,))
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar mobs: {e}")
            return []
            
    def get_items_in_room(self, room_id: int) -> List[Dict[str, Any]]:
        """Buscar itens na sala"""
        try:
            result = self.db.execute_query("""
                SELECT i.id, i.nome, its.quantidade
                FROM itens_sala its
                JOIN itens i ON its.item_id = i.id
                WHERE its.sala_id = %s
                ORDER BY i.nome
            """, (room_id,))
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar itens: {e}")
            return []
            
    def get_inventory_items(self, character_id: int) -> List[Dict[str, Any]]:
        """Buscar itens do inventário"""
        try:
            result = self.db.execute_query("""
                SELECT i.id, i.nome, inv.quantidade, i.tipo, i.raridade
                FROM inventario inv
                JOIN itens i ON inv.item_id = i.id
                WHERE inv.personagem_id = %s
                ORDER BY i.raridade DESC, i.nome
            """, (character_id,))
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar inventário: {e}")
            return []
            
    def take_item(self, character_id: int, item_id: int, quantity: int) -> str:
        """Pegar item"""
        try:
            result = self.db.execute_function('pegar_item', (character_id, item_id, quantity))
            return result if result else "Erro ao pegar item."
            
        except Exception as e:
            return f"Erro ao pegar item: {str(e)}"
            
    def drop_item(self, character_id: int, item_id: int, quantity: int) -> str:
        """Dropar item"""
        try:
            result = self.db.execute_function('dropar_item', (character_id, item_id, quantity))
            return result if result else "Erro ao dropar item."
            
        except Exception as e:
            return f"Erro ao dropar item: {str(e)}"
            
    def show_active_missions(self, character_id: int) -> str:
        """Mostrar missões ativas"""
        try:
            result = self.db.execute_query("""
                SELECT m.nome, m.descricao, mj.progresso, m.recompensa
                FROM missoes_jogador mj
                JOIN missoes m ON mj.missao_id = m.id
                WHERE mj.personagem_id = %s AND mj.status = 'em_andamento'
                ORDER BY m.nome
            """, (character_id,))
            
            if not result:
                return "Você não possui missões ativas."
                
            output = "📋 MISSÕES ATIVAS:\n\n"
            for mission in result:
                output += f"🎯 {mission['nome']}\n"
                output += f"   Progresso: {mission['progresso']}%\n"
                output += f"   Descrição: {mission['descricao']}\n"
                output += f"   Recompensa: {mission['recompensa']}\n\n"
                
            return output
            
        except Exception as e:
            return f"Erro ao buscar missões: {str(e)}"
            
    def show_available_missions(self, character_id: int) -> str:
        """Mostrar missões disponíveis"""
        try:
            result = self.db.execute_query("""
                SELECT m.id, m.nome, m.descricao, m.dificuldade, m.recompensa,
                       m.xp_requerido, m.nivel_requerido
                FROM missoes m
                WHERE NOT EXISTS (
                    SELECT 1 FROM missoes_jogador mj 
                    WHERE mj.personagem_id = %s AND mj.missao_id = m.id
                )
                ORDER BY m.dificuldade, m.nome
            """, (character_id,))
            
            if not result:
                return "Nenhuma missão disponível."
                
            output = "📋 MISSÕES DISPONÍVEIS:\n\n"
            for mission in result:
                output += f"🎯 {mission['nome']} [{mission['dificuldade']}]\n"
                output += f"   Descrição: {mission['descricao']}\n"
                output += f"   Recompensa: {mission['recompensa']}\n"
                output += f"   Requisitos: XP {mission['xp_requerido']}, Nível {mission['nivel_requerido']}\n\n"
                
            return output
            
        except Exception as e:
            return f"Erro ao buscar missões: {str(e)}"
            
    def get_available_missions_list(self, character_id: int) -> List[Dict[str, Any]]:
        """Buscar lista de missões disponíveis"""
        try:
            result = self.db.execute_query("""
                SELECT m.id, m.nome, m.dificuldade
                FROM missoes m
                WHERE NOT EXISTS (
                    SELECT 1 FROM missoes_jogador mj 
                    WHERE mj.personagem_id = %s AND mj.missao_id = m.id
                )
                ORDER BY m.dificuldade, m.nome
            """, (character_id,))
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar missões: {e}")
            return []
            
    def get_active_missions_list(self, character_id: int) -> List[Dict[str, Any]]:
        """Buscar lista de missões ativas"""
        try:
            result = self.db.execute_query("""
                SELECT m.id, m.nome, mj.progresso
                FROM missoes_jogador mj
                JOIN missoes m ON mj.missao_id = m.id
                WHERE mj.personagem_id = %s AND mj.status = 'em_andamento'
                ORDER BY m.nome
            """, (character_id,))
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar missões: {e}")
            return []
            
    def start_mission(self, character_id: int, mission_id: int) -> str:
        """Iniciar missão"""
        try:
            result = self.db.execute_function('iniciar_missao', (character_id, mission_id))
            return result if result else "Erro ao iniciar missão."
            
        except Exception as e:
            return f"Erro ao iniciar missão: {str(e)}"
            
    def complete_mission(self, character_id: int, mission_id: int) -> str:
        """Concluir missão"""
        try:
            result = self.db.execute_function('concluir_missao', (character_id, mission_id))
            return result if result else "Erro ao concluir missão."
            
        except Exception as e:
            return f"Erro ao concluir missão: {str(e)}"
            
    def list_factions(self, character_id: int) -> str:
        """Listar facções"""
        try:
            result = self.db.execute_function('listar_faccoes', (character_id,))
            return result if result else "Erro ao buscar facções."
            
        except Exception as e:
            return f"Erro ao buscar facções: {str(e)}"
            
    def get_factions_list(self) -> List[Dict[str, Any]]:
        """Buscar lista de facções"""
        try:
            result = self.db.execute_query("""
                SELECT id, nome, reputacao, descricao
                FROM faccoes
                ORDER BY reputacao DESC, nome
            """)
            
            return result if result else []
            
        except Exception as e:
            print(f"Erro ao buscar facções: {e}")
            return []
            
    def join_faction(self, character_id: int, faction_id: int) -> str:
        """Entrar em facção"""
        try:
            result = self.db.execute_function('entrar_faccao', (character_id, faction_id))
            return result if result else "Erro ao entrar na facção."
            
        except Exception as e:
            return f"Erro ao entrar na facção: {str(e)}"
            
    def leave_faction(self, character_id: int) -> str:
        """Sair da facção"""
        try:
            result = self.db.execute_function('sair_faccao', (character_id,))
            return result if result else "Erro ao sair da facção."
            
        except Exception as e:
            return f"Erro ao sair da facção: {str(e)}" 