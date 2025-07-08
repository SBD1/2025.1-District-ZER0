"""
UI Manager para District ZER0
Gerenciamento de interface de usuário e exibição
"""

import os
import sys
from typing import List, Dict, Any
from colorama import Fore, Back, Style

class UIManager:
    def __init__(self):
        self.width = 80
        
    def clear_screen(self):
        """Limpar tela"""
        os.system('cls' if os.name == 'nt' else 'clear')
        
    def show_banner(self):
        """Exibir banner do jogo"""
        self.clear_screen()
        banner = f"""
{Fore.CYAN}╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  {Fore.RED}██████{Fore.CYAN}  ██  {Fore.RED}███████{Fore.CYAN} ████████ {Fore.RED}███████{Fore.CYAN}  ██  {Fore.RED}██████{Fore.CYAN} ████████     {Fore.RED}███████{Fore.CYAN} ║
║  {Fore.RED}██   ██{Fore.CYAN} ██  {Fore.RED}██     {Fore.CYAN}    ██    {Fore.RED}██     {Fore.CYAN} ██  {Fore.RED}██      {Fore.CYAN}   ██        {Fore.RED}██     {Fore.CYAN} ║
║  {Fore.RED}██   ██{Fore.CYAN} ██  {Fore.RED}███████{Fore.CYAN}    ██    {Fore.RED}███████{Fore.CYAN} ██  {Fore.RED}██      {Fore.CYAN}   ██        {Fore.RED}███████{Fore.CYAN} ║
║  {Fore.RED}██   ██{Fore.CYAN} ██       {Fore.RED}██{Fore.CYAN}    ██    {Fore.RED}██  {Fore.CYAN}    ██  {Fore.RED}██      {Fore.CYAN}   ██             {Fore.RED}██{Fore.CYAN} ║
║  {Fore.RED}██████{Fore.CYAN}  ██  {Fore.RED}███████{Fore.CYAN}    ██    {Fore.RED}██      {Fore.CYAN} ██   {Fore.RED}██████{Fore.CYAN}    ██        {Fore.RED}███████{Fore.CYAN} ║
║                                                                              ║
║                     {Fore.YELLOW}░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░{Fore.CYAN}                   ║
║                     {Fore.YELLOW}░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░{Fore.CYAN}                   ║
║                     {Fore.YELLOW}░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░{Fore.CYAN}                   ║
║                                                                              ║
║               {Fore.MAGENTA}Sistema MUD Cyberpunk - Interface CLI{Fore.CYAN}                    ║
║                        {Fore.GREEN}Versão 1.0 - PostgreSQL{Fore.CYAN}                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝{Style.RESET_ALL}
"""
        print(banner)
        
    def show_title(self, title: str):
        """Exibir título formatado"""
        print(f"\n{Fore.CYAN}{'='*self.width}{Style.RESET_ALL}")
        print(f"{Fore.YELLOW}{title.center(self.width)}{Style.RESET_ALL}")
        print(f"{Fore.CYAN}{'='*self.width}{Style.RESET_ALL}\n")
        
    def show_menu(self, options: List[str]) -> str:
        """Exibir menu e retornar escolha"""
        print(f"{Fore.CYAN}┌{'─'*60}┐{Style.RESET_ALL}")
        for option in options:
            print(f"{Fore.CYAN}│{Style.RESET_ALL} {option:<58} {Fore.CYAN}│{Style.RESET_ALL}")
        print(f"{Fore.CYAN}└{'─'*60}┘{Style.RESET_ALL}")
        
        choice = input(f"\n{Fore.YELLOW}Escolha uma opção: {Style.RESET_ALL}")
        return choice.strip()
        
    def show_info(self, message: str):
        """Exibir informação"""
        print(f"{Fore.CYAN}ℹ️  {message}{Style.RESET_ALL}")
        
    def show_success(self, message: str):
        """Exibir sucesso"""
        print(f"{Fore.GREEN}✅ {message}{Style.RESET_ALL}")
        
    def show_error(self, message: str):
        """Exibir erro"""
        print(f"{Fore.RED}❌ {message}{Style.RESET_ALL}")
        
    def show_warning(self, message: str):
        """Exibir aviso"""
        print(f"{Fore.YELLOW}⚠️  {message}{Style.RESET_ALL}")
        
    def show_game_header(self, character: Dict[str, Any]):
        """Exibir cabeçalho do jogo com informações do personagem"""
        print(f"{Fore.CYAN}╔══════════════════════════════════════════════════════════════════════════════╗")
        print(f"║ {Fore.YELLOW}{character['username']:<20}{Fore.CYAN} │ {Fore.GREEN}Nível: {character['nivel']:<3}{Fore.CYAN} │ {Fore.RED}HP: {character['vida']:<3}{Fore.CYAN} │ {Fore.MAGENTA}Créditos: {character['carteira']:<10}{Fore.CYAN} ║")
        print(f"║ {Fore.CYAN}Classe: {character['classe']:<13}{Fore.CYAN} │ {Fore.YELLOW}XP: {character['experiencia']:<7}{Fore.CYAN} │ {Fore.BLUE}Rep: {character['reputacao']:<3}{Fore.CYAN} │ {Fore.WHITE}Sala: {character['sala_atual']:<12}{Fore.CYAN} ║")
        print(f"╚══════════════════════════════════════════════════════════════════════════════╝{Style.RESET_ALL}")
        
    def show_separator(self):
        """Exibir separador"""
        print(f"{Fore.CYAN}{'─'*self.width}{Style.RESET_ALL}")
        
    def show_box(self, title: str, content: str):
        """Exibir conteúdo em caixa"""
        lines = content.split('\n')
        max_len = max(len(line) for line in lines) if lines else 0
        box_width = max(max_len + 4, len(title) + 4, 40)
        
        print(f"{Fore.CYAN}╔{'═'*(box_width-2)}╗{Style.RESET_ALL}")
        print(f"{Fore.CYAN}║ {Fore.YELLOW}{title:<{box_width-4}}{Fore.CYAN} ║{Style.RESET_ALL}")
        print(f"{Fore.CYAN}╠{'═'*(box_width-2)}╣{Style.RESET_ALL}")
        
        for line in lines:
            print(f"{Fore.CYAN}║ {line:<{box_width-4}} ║{Style.RESET_ALL}")
            
        print(f"{Fore.CYAN}╚{'═'*(box_width-2)}╝{Style.RESET_ALL}")
        
    def format_table(self, headers: List[str], rows: List[List[str]]) -> str:
        """Formatar tabela"""
        if not rows:
            return "Nenhum dado para exibir"
            
        # Calcular largura das colunas
        col_widths = [len(header) for header in headers]
        for row in rows:
            for i, cell in enumerate(row):
                if i < len(col_widths):
                    col_widths[i] = max(col_widths[i], len(str(cell)))
                    
        # Construir tabela
        result = []
        
        # Cabeçalho
        header_line = "│ " + " │ ".join(f"{headers[i]:<{col_widths[i]}}" for i in range(len(headers))) + " │"
        separator = "├" + "┼".join("─" * (w + 2) for w in col_widths) + "┤"
        top_line = "┌" + "┬".join("─" * (w + 2) for w in col_widths) + "┐"
        bottom_line = "└" + "┴".join("─" * (w + 2) for w in col_widths) + "┘"
        
        result.append(f"{Fore.CYAN}{top_line}{Style.RESET_ALL}")
        result.append(f"{Fore.CYAN}{header_line}{Style.RESET_ALL}")
        result.append(f"{Fore.CYAN}{separator}{Style.RESET_ALL}")
        
        # Dados
        for row in rows:
            row_line = "│ " + " │ ".join(f"{str(row[i]):<{col_widths[i]}}" for i in range(len(row))) + " │"
            result.append(f"{Fore.CYAN}{row_line}{Style.RESET_ALL}")
            
        result.append(f"{Fore.CYAN}{bottom_line}{Style.RESET_ALL}")
        
        return "\n".join(result)
        
    def wait_for_input(self, message: str = "Pressione Enter para continuar..."):
        """Aguardar entrada do usuário"""
        input(f"{Fore.YELLOW}{message}{Style.RESET_ALL}")
        
    def get_input(self, prompt: str) -> str:
        """Obter entrada do usuário"""
        return input(f"{Fore.CYAN}{prompt}{Style.RESET_ALL}")
        
    def get_int_input(self, prompt: str, min_val: int = None, max_val: int = None) -> int:
        """Obter entrada numérica do usuário"""
        while True:
            try:
                value = int(input(f"{Fore.CYAN}{prompt}{Style.RESET_ALL}"))
                if min_val is not None and value < min_val:
                    self.show_error(f"Valor deve ser pelo menos {min_val}")
                    continue
                if max_val is not None and value > max_val:
                    self.show_error(f"Valor deve ser no máximo {max_val}")
                    continue
                return value
            except ValueError:
                self.show_error("Por favor, digite um número válido")
                
    def show_progress_bar(self, current: int, total: int, width: int = 50):
        """Exibir barra de progresso"""
        percent = current / total
        filled = int(width * percent)
        bar = "█" * filled + "░" * (width - filled)
        print(f"{Fore.CYAN}[{Fore.GREEN}{bar}{Fore.CYAN}] {percent:.1%} ({current}/{total}){Style.RESET_ALL}")
        
    def show_health_bar(self, current: int, maximum: int, width: int = 20):
        """Exibir barra de vida"""
        percent = current / maximum
        filled = int(width * percent)
        
        # Cor baseada na porcentagem
        if percent > 0.7:
            color = Fore.GREEN
        elif percent > 0.3:
            color = Fore.YELLOW
        else:
            color = Fore.RED
            
        bar = "█" * filled + "░" * (width - filled)
        print(f"{Fore.CYAN}HP: [{color}{bar}{Fore.CYAN}] {current}/{maximum}{Style.RESET_ALL}")
        
    def confirm(self, message: str) -> bool:
        """Confirmar ação"""
        response = input(f"{Fore.YELLOW}{message} (s/n): {Style.RESET_ALL}").lower()
        return response in ['s', 'sim', 'y', 'yes'] 