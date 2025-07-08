#!/usr/bin/env python3
"""
District ZER0 - Interface CLI
Sistema de jogo MUD cyberpunk com interface de linha de comando
"""

import os
import sys
import time
from colorama import init, Fore, Back, Style
from database import DatabaseManager
from auth import AuthManager
from game import GameManager
from ui import UIManager

# Inicializar colorama para cores no terminal
init(autoreset=True)

class DistrictZeroGame:
    def __init__(self):
        self.db_manager = DatabaseManager()
        self.auth_manager = AuthManager(self.db_manager)
        self.game_manager = GameManager(self.db_manager)
        self.ui_manager = UIManager()
        self.current_user = None
        self.current_character = None
        self.running = True
        
    def start(self):
        """Inicializar o jogo"""
        self.ui_manager.show_banner()
        
        # Verificar conexão com banco
        if not self.db_manager.test_connection():
            self.ui_manager.show_error("Erro: Não foi possível conectar ao banco de dados!")
            self.ui_manager.show_info("Verifique se o Docker está rodando: docker-compose up -d")
            return
            
        self.ui_manager.show_success("Conectado ao District ZER0 Database!")
        self.main_loop()
        
    def main_loop(self):
        """Loop principal do jogo"""
        while self.running:
            if not self.current_user:
                self.show_login_menu()
            elif not self.current_character:
                self.show_character_menu()
            else:
                self.show_game_menu()
                
    def show_login_menu(self):
        """Menu de login/cadastro"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("ACESSO AO SISTEMA")
        
        options = [
            "1. Login",
            "2. Cadastrar novo usuário",
            "3. Sair"
        ]
        
        choice = self.ui_manager.show_menu(options)
        
        if choice == "1":
            self.handle_login()
        elif choice == "2":
            self.handle_register()
        elif choice == "3":
            self.quit_game()
        else:
            self.ui_manager.show_error("Opção inválida!")
            time.sleep(1)
            
    def handle_login(self):
        """Processar login"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("LOGIN")
        
        username = input(f"{Fore.CYAN}Username: {Style.RESET_ALL}")
        password = input(f"{Fore.CYAN}Senha: {Style.RESET_ALL}")
        
        user = self.auth_manager.login(username, password)
        if user:
            self.current_user = user
            self.ui_manager.show_success(f"Bem-vindo, {username}!")
            time.sleep(1)
        else:
            self.ui_manager.show_error("Credenciais inválidas!")
            time.sleep(2)
            
    def handle_register(self):
        """Processar cadastro"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("CADASTRO")
        
        username = input(f"{Fore.CYAN}Username (3-40 caracteres): {Style.RESET_ALL}")
        password = input(f"{Fore.CYAN}Senha: {Style.RESET_ALL}")
        password_confirm = input(f"{Fore.CYAN}Confirmar senha: {Style.RESET_ALL}")
        
        if password != password_confirm:
            self.ui_manager.show_error("Senhas não coincidem!")
            time.sleep(2)
            return
            
        result = self.auth_manager.register(username, password)
        if result['success']:
            self.ui_manager.show_success(f"Usuário {username} criado com sucesso!")
            time.sleep(2)
        else:
            self.ui_manager.show_error(f"Erro: {result['error']}")
            time.sleep(2)
            
    def show_character_menu(self):
        """Menu de seleção/criação de personagem"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("SELEÇÃO DE PERSONAGEM")
        
        character = self.game_manager.get_character_by_user(self.current_user['id'])
        
        if character:
            self.ui_manager.show_info(f"Personagem encontrado: {character['username']}")
            self.ui_manager.show_info(f"Classe: {character['classe']} | Nível: {character['nivel']}")
            
            choice = input(f"{Fore.YELLOW}Entrar no jogo? (s/n): {Style.RESET_ALL}").lower()
            if choice == 's':
                self.current_character = character
                self.ui_manager.show_success("Entrando no mundo...")
                time.sleep(1)
            else:
                self.current_user = None
        else:
            self.ui_manager.show_info("Nenhum personagem encontrado. Criando personagem...")
            self.create_character()
            
    def create_character(self):
        """Criar novo personagem"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("CRIAÇÃO DE PERSONAGEM")
        
        # Listar classes disponíveis
        classes = self.game_manager.get_available_classes()
        
        self.ui_manager.show_info("Classes disponíveis:")
        for i, classe in enumerate(classes, 1):
            print(f"{Fore.CYAN}{i}. {classe['nome']}{Style.RESET_ALL}")
            print(f"   {classe['descricao']}")
            print(f"   Vida: {classe['vida_base']} | Ataque: {classe['ataque_base']} | Defesa: {classe['defesa_base']}")
            print()
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha uma classe (1-{len(classes)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(classes):
                selected_class = classes[choice - 1]
                
                result = self.game_manager.create_character(self.current_user['id'], selected_class['id'])
                if result['success']:
                    self.ui_manager.show_success("Personagem criado com sucesso!")
                    self.current_character = self.game_manager.get_character_by_user(self.current_user['id'])
                    time.sleep(2)
                else:
                    self.ui_manager.show_error(f"Erro: {result['error']}")
                    time.sleep(2)
            else:
                self.ui_manager.show_error("Opção inválida!")
                time.sleep(1)
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            time.sleep(1)
            
    def show_game_menu(self):
        """Menu principal do jogo"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_game_header(self.current_character)
        
        options = [
            "1. Olhar ao redor",
            "2. Mover (N/S/L/O)",
            "3. Atacar inimigo",
            "4. Inventário",
            "5. Status",
            "6. Missões",
            "7. Facções",
            "8. Pegar item",
            "9. Dropar item",
            "0. Sair do jogo"
        ]
        
        choice = self.ui_manager.show_menu(options)
        
        if choice == "1":
            self.handle_look_around()
        elif choice == "2":
            self.handle_movement()
        elif choice == "3":
            self.handle_combat()
        elif choice == "4":
            self.handle_inventory()
        elif choice == "5":
            self.handle_status()
        elif choice == "6":
            self.handle_missions()
        elif choice == "7":
            self.handle_factions()
        elif choice == "8":
            self.handle_take_item()
        elif choice == "9":
            self.handle_drop_item()
        elif choice == "0":
            self.quit_game()
        else:
            self.ui_manager.show_error("Opção inválida!")
            time.sleep(1)
            
    def handle_look_around(self):
        """Olhar ao redor"""
        result = self.game_manager.look_around(self.current_character['id'])
        self.ui_manager.show_info(result)
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_movement(self):
        """Processar movimento"""
        direction = input(f"{Fore.CYAN}Direção (N/S/L/O): {Style.RESET_ALL}").upper()
        
        if direction in ['N', 'S', 'L', 'O']:
            result = self.game_manager.move_character(self.current_character['id'], direction)
            self.ui_manager.show_info(result)
            
            # Atualizar dados do personagem
            self.current_character = self.game_manager.get_character_by_user(self.current_user['id'])
        else:
            self.ui_manager.show_error("Direção inválida! Use N, S, L ou O.")
            
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_combat(self):
        """Processar combate"""
        mobs = self.game_manager.get_mobs_in_room(self.current_character['sala_atual_id'])
        
        if not mobs:
            self.ui_manager.show_info("Nenhum inimigo encontrado nesta sala.")
            time.sleep(2)
            return
            
        self.ui_manager.show_info("Inimigos disponíveis:")
        for i, mob in enumerate(mobs, 1):
            print(f"{Fore.RED}{i}. {mob['nome']} (HP: {mob['vida']}/{mob['vida_max']}){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha um inimigo (1-{len(mobs)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(mobs):
                selected_mob = mobs[choice - 1]
                result = self.game_manager.attack_mob(self.current_character['id'], selected_mob['id'])
                self.ui_manager.show_info(result)
                
                # Atualizar dados do personagem
                self.current_character = self.game_manager.get_character_by_user(self.current_user['id'])
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_inventory(self):
        """Mostrar inventário"""
        result = self.game_manager.show_inventory(self.current_character['id'])
        self.ui_manager.show_info(result)
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_status(self):
        """Mostrar status do personagem"""
        result = self.game_manager.show_status(self.current_character['id'])
        self.ui_manager.show_info(result)
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_missions(self):
        """Gerenciar missões"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("MISSÕES")
        
        submenu = [
            "1. Missões ativas",
            "2. Missões disponíveis",
            "3. Iniciar missão",
            "4. Concluir missão",
            "5. Voltar"
        ]
        
        choice = self.ui_manager.show_menu(submenu)
        
        if choice == "1":
            result = self.game_manager.show_active_missions(self.current_character['id'])
            self.ui_manager.show_info(result)
        elif choice == "2":
            result = self.game_manager.show_available_missions(self.current_character['id'])
            self.ui_manager.show_info(result)
        elif choice == "3":
            self.start_mission()
        elif choice == "4":
            self.complete_mission()
        elif choice == "5":
            return
            
        if choice != "5":
            input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
            
    def handle_factions(self):
        """Gerenciar facções"""
        self.ui_manager.clear_screen()
        self.ui_manager.show_title("FACÇÕES")
        
        submenu = [
            "1. Listar facções",
            "2. Entrar em facção",
            "3. Sair da facção",
            "4. Voltar"
        ]
        
        choice = self.ui_manager.show_menu(submenu)
        
        if choice == "1":
            result = self.game_manager.list_factions(self.current_character['id'])
            self.ui_manager.show_info(result)
        elif choice == "2":
            self.join_faction()
        elif choice == "3":
            result = self.game_manager.leave_faction(self.current_character['id'])
            self.ui_manager.show_info(result)
        elif choice == "4":
            return
            
        if choice != "4":
            input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
            
    def handle_take_item(self):
        """Pegar item"""
        items = self.game_manager.get_items_in_room(self.current_character['sala_atual_id'])
        
        if not items:
            self.ui_manager.show_info("Nenhum item encontrado nesta sala.")
            time.sleep(2)
            return
            
        self.ui_manager.show_info("Itens disponíveis:")
        for i, item in enumerate(items, 1):
            print(f"{Fore.GREEN}{i}. {item['nome']} ({item['quantidade']}){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha um item (1-{len(items)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(items):
                selected_item = items[choice - 1]
                quantity = input(f"{Fore.CYAN}Quantidade (max {selected_item['quantidade']}): {Style.RESET_ALL}")
                
                result = self.game_manager.take_item(self.current_character['id'], selected_item['id'], int(quantity))
                self.ui_manager.show_info(result)
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def handle_drop_item(self):
        """Dropar item"""
        inventory = self.game_manager.get_inventory_items(self.current_character['id'])
        
        if not inventory:
            self.ui_manager.show_info("Seu inventário está vazio.")
            time.sleep(2)
            return
            
        self.ui_manager.show_info("Seu inventário:")
        for i, item in enumerate(inventory, 1):
            print(f"{Fore.CYAN}{i}. {item['nome']} ({item['quantidade']}){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha um item (1-{len(inventory)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(inventory):
                selected_item = inventory[choice - 1]
                quantity = input(f"{Fore.CYAN}Quantidade (max {selected_item['quantidade']}): {Style.RESET_ALL}")
                
                result = self.game_manager.drop_item(self.current_character['id'], selected_item['id'], int(quantity))
                self.ui_manager.show_info(result)
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
        input(f"{Fore.YELLOW}Pressione Enter para continuar...{Style.RESET_ALL}")
        
    def start_mission(self):
        """Iniciar missão"""
        missions = self.game_manager.get_available_missions_list(self.current_character['id'])
        
        if not missions:
            self.ui_manager.show_info("Nenhuma missão disponível.")
            return
            
        self.ui_manager.show_info("Missões disponíveis:")
        for i, mission in enumerate(missions, 1):
            print(f"{Fore.YELLOW}{i}. {mission['nome']} ({mission['dificuldade']}){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha uma missão (1-{len(missions)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(missions):
                selected_mission = missions[choice - 1]
                result = self.game_manager.start_mission(self.current_character['id'], selected_mission['id'])
                self.ui_manager.show_info(result)
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
    def complete_mission(self):
        """Concluir missão"""
        missions = self.game_manager.get_active_missions_list(self.current_character['id'])
        
        if not missions:
            self.ui_manager.show_info("Nenhuma missão ativa.")
            return
            
        self.ui_manager.show_info("Missões ativas:")
        for i, mission in enumerate(missions, 1):
            print(f"{Fore.YELLOW}{i}. {mission['nome']} ({mission['progresso']}%){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha uma missão (1-{len(missions)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(missions):
                selected_mission = missions[choice - 1]
                result = self.game_manager.complete_mission(self.current_character['id'], selected_mission['id'])
                self.ui_manager.show_info(result)
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
    def join_faction(self):
        """Entrar em facção"""
        factions = self.game_manager.get_factions_list()
        
        if not factions:
            self.ui_manager.show_info("Nenhuma facção disponível.")
            return
            
        self.ui_manager.show_info("Facções disponíveis:")
        for i, faction in enumerate(factions, 1):
            print(f"{Fore.MAGENTA}{i}. {faction['nome']} (Rep: {faction['reputacao']}){Style.RESET_ALL}")
            
        try:
            choice = int(input(f"{Fore.YELLOW}Escolha uma facção (1-{len(factions)}): {Style.RESET_ALL}"))
            if 1 <= choice <= len(factions):
                selected_faction = factions[choice - 1]
                result = self.game_manager.join_faction(self.current_character['id'], selected_faction['id'])
                self.ui_manager.show_info(result)
                
                # Atualizar dados do personagem
                self.current_character = self.game_manager.get_character_by_user(self.current_user['id'])
            else:
                self.ui_manager.show_error("Opção inválida!")
        except ValueError:
            self.ui_manager.show_error("Digite um número válido!")
            
    def quit_game(self):
        """Sair do jogo"""
        self.ui_manager.show_info("Saindo do District ZER0...")
        self.running = False
        
def main():
    """Função principal"""
    try:
        game = DistrictZeroGame()
        game.start()
    except KeyboardInterrupt:
        print(f"\n{Fore.RED}Jogo interrompido pelo usuário.{Style.RESET_ALL}")
    except Exception as e:
        print(f"\n{Fore.RED}Erro fatal: {e}{Style.RESET_ALL}")
    finally:
        print(f"{Fore.CYAN}Obrigado por jogar District ZER0!{Style.RESET_ALL}")

if __name__ == "__main__":
    main() 