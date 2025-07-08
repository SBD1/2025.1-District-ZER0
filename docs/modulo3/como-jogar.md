# Como Jogar District ZER0

Guia completo para jogar o MUD cyberpunk District ZER0.

## 🚀 Começando

### Pré-requisitos

- **Docker** e **Docker Compose**
- **Python 3.8+**
- **Make**

### Iniciando o Jogo

#### Opção 1: Jogo Imediato (Recomendado)
```bash
make play
```
*Configura automaticamente Python, banco de dados e inicia o jogo*

#### Opção 2: Setup Completo
```bash
make setup
```
*Configura ambiente Python e banco de dados*

#### Opção 3: Demonstração Completa
```bash
make demo
```
*Setup + validação + opção de jogar*

### Verificação do Sistema

```bash
make validate-system  # Validação completa
make verify-scripts   # Verificar scripts executados
make check-scripts    # Listar scripts disponíveis
```

## 🎮 Primeiros Passos

### 1. Criando uma Conta

No primeiro acesso você precisará:

1. **Cadastro**: Crie uma conta com username único (3-40 caracteres)
2. **Login**: Entre com suas credenciais
3. **Personagem**: Escolha uma classe para seu personagem

### 2. Classes de Personagem

Escolha uma das 6 classes disponíveis:

| Classe | Descrição | Especialidade |
|--------|-----------|---------------|
| **1. Hacker** | Especialista em invasão de sistemas | Tecnologia e hacking |
| **2. Mercenário** | Combatente profissional | Combate e armas |
| **3. Tecno-Xamã** | Místico tecnológico | Magia e tecnologia |
| **4. Nômade Urbano** | Sobrevivente adaptável | Sobrevivência e adaptação |
| **5. Netrunner** | Hacker de elite | Redes e sistemas |
| **6. Soldado Corp** | Agente corporativo | Disciplina e táticas |

## 🕹️ Comandos Principais

### Comandos de Movimento
- **1. Olhar ao redor**: Examina a sala atual, mostra inimigos, itens e saídas
- **2. Mover (N/S/L/O)**: Move para Norte, Sul, Leste ou Oeste

### Comandos de Combate
- **3. Atacar inimigo**: Inicia combate com mobs na sala
- **Fugir**: Use durante combate para tentar escapar

### Comandos de Inventário
- **4. Inventário**: Mostra seus itens
- **8. Pegar item**: Coleta itens do chão
- **9. Dropar item**: Descarta itens do inventário

### Comandos de Informação
- **5. Status**: Exibe informações detalhadas do personagem
- **6. Missões**: Gerencia missões ativas e disponíveis
- **7. Facções**: Sistema de facções e alianças

## ⚔️ Sistema de Combate

### Mecânicas Básicas
- **Ataque vs Defesa**: Dano = max(Ataque - Defesa, 1)
- **PvE**: Combate contra mobs e bosses
- **XP e Level Up**: Ganhe experiência para subir de nível
- **Drops**: Mobs podem dropar itens valiosos

### Tipos de Resultado
- **Vitória**: Ganhe XP, loot e reputação
- **Derrota**: Perde vida, pode morrer
- **Fuga**: Escape para sala adjacente (baseado em probabilidade)

### Consequências da Morte
- **Respawn**: Revive em safe-zone com 50% de vida
- **Penalidades**: Perde 30% dos créditos e 3 pontos de reputação
- **Missões**: Missões em andamento são falhadas

## 📋 Sistema de Missões

### Características
- **Missões Ativas**: Até 3 missões simultâneas
- **Dificuldades**: Fácil, Normal, Difícil, Épico, Lendário
- **Recompensas**: Créditos, XP, itens especiais
- **Pré-requisitos**: Algumas missões exigem nível ou XP mínimos

### Comandos de Missão
- **Iniciar Missão**: Aceitar nova missão
- **Concluir Missão**: Finalizar missão ativa
- **Desistir de Missão**: Abandonar missão (com penalidades)

## 🏛️ Sistema de Facções

### 7 Facções Disponíveis

| Facção | Ideologia | Especialidade |
|--------|-----------|---------------|
| **Filhos de Turing** | Hackers libertários | Tecnologia e liberdade |
| **Vanguarda Cromada** | Mercenários transumanistas | Aprimoramento corporal |
| **Sindicato da Sucata** | Engenheiros catadores | Reciclagem e engenharia |
| **Culto do Silício** | Tecno-xamãs | Espiritualidade digital |
| **Aliança Nômade** | Sobreviventes urbanos | Sobrevivência e comunidade |
| **Consórcio OmniCorp** | Corporação dominante | Poder e controle |
| **Rede Fantasma** | Espionagem secreta | Inteligência e stealth |

### Benefícios das Facções
- **Reputação**: Ganhe reputação para sua facção
- **Missões Especiais**: Acesso a missões exclusivas
- **Bônus**: Benefícios únicos por facção
- **Comunidade**: Interação com outros membros

## 💰 Economia e Itens

### Sistema de Itens
- **5 Raridades**: Comum, Incomum, Raro, Épico, Variável
- **6 Tipos**: Armas, chips, consumíveis, aprimoramentos, dados, especiais
- **Sistema de Peso**: Limitações de inventário
- **Stack**: Alguns itens podem ser empilhados

### Economia
- **Créditos**: Moeda do jogo para comércio
- **Valores Dinâmicos**: Preços baseados em raridade
- **Drops**: Loot baseado em probabilidade
- **Comércio**: Sistema de troca entre jogadores

## 🗺️ Mundo do District ZER0

### 15 Salas Interconectadas

#### Tipos de Salas
- **Safe-zones (4)**: Áreas sem combate
  - Mercado de Chips Clandestino
  - Clínica "Deus Ex Machina"
  - Templo do Silício Sagrado
  - Refúgio dos Nômades
- **Dungeons (3)**: Áreas de alta dificuldade
  - Data-Bank Abandonado da OmniCorp
  - Fábrica de Chips Desativada
  - Porto de Dados Corrompidos
- **Áreas Normais (8)**: Combate permitido

### Navegação
- **Direções**: Norte (N), Sul (S), Leste (L), Oeste (O)
- **Mapeamento**: Sistema de caminhos interconectados
- **Custo de Movimento**: Algumas conexões podem ter custos

## 🎯 Dicas de Gameplay

### Para Iniciantes
1. **Use `make play`** para iniciar rapidamente
2. **Comece em safe-zones** para se familiarizar
3. **Leia as descrições** das salas e itens
4. **Experimente todos os comandos** disponíveis

### Estratégias Avançadas
1. **Explore todas as salas** para encontrar itens e missões
2. **Junte-se a uma facção** para ganhar benefícios
3. **Complete missões** para ganhar XP e recursos
4. **Evite morrer** - há penalidades significativas
5. **Use safe-zones** para descansar e se recuperar
6. **Colete itens** para melhorar seu equipamento
7. **Gerencie seu inventário** eficientemente
8. **Planeje sua progressão** de personagem

### Comandos Úteis do Sistema
```bash
make help           # Ver todos os comandos
make status         # Status dos serviços
make health         # Verificação de saúde
make logs           # Ver logs do sistema
make backup         # Backup dos dados
```

## 🚨 Troubleshooting

### Problemas Comuns

#### Erro de Conexão com Banco
```bash
make status         # Verificar serviços
make health         # Verificar saúde
make restart        # Reiniciar serviços
make force-rebuild  # Reconstrução completa
```

#### Personagem Não Criado
- Verifique se escolheu uma classe válida (1-6)
- Execute `make test` para validar o banco
- Confirme que não existe personagem anterior

#### Scripts SQL Não Executados
```bash
make verify-scripts  # Verificar execução
make prepare-sql     # Preparar scripts
make check-scripts   # Listar scripts disponíveis
```

### Comandos de Diagnóstico
```bash
make validate-system # Validação completa
make debug-logs      # Logs detalhados
make check-volumes   # Verificar volumes Docker
```

## 📊 Sistema de Progressão

### Experiência e Níveis
- **XP por Combate**: 50 XP (mobs normais), 200 XP (bosses)
- **XP por Missão**: Varia conforme dificuldade
- **Level Up**: Automático ao atingir XP necessária
- **Benefícios**: +1 ataque/defesa por nível

### Reputação
- **Missões Concluídas**: +2 reputação
- **Derrotar Bosses**: +5 reputação
- **Morte**: -3 reputação
- **Missões Falhadas**: -1 reputação

### Economia Pessoal
- **Créditos Iniciais**: Varia por classe
- **Ganhos**: Missões, vendas, loot
- **Perdas**: Morte (30%), compras, penalidades

---

**Desenvolvido por Grupo 15 - SBD1 2025.1 - UnB**

## Histórico de Versão
| Versão |    Data    |      Descrição       |                       Autor(es)                        |
| :----: | :--------: | :------------------: | :----------------------------------------------------: |
| `1.0`  | 07/01/2025 | Criação do Documento | [Vinicius Vieira](https://github.com/viniciusvieira00) |
