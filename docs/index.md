# District ZER0

Documentação oficial do projeto **District ZER0: Cyberpunk Pocket MUD**.

## Sobre o Projeto

**District ZER0** é um Multi-User Dungeon (MUD) com temática cyberpunk desenvolvido como projeto para a disciplina de Sistemas de Bancos de Dados 1 (SBD1) no semestre 2025.1. O jogo é implementado utilizando PostgreSQL como sistema de banco de dados principal, garantindo persistência, consistência e escalabilidade dos dados.

### 🚀 Status Atual: Sistema Completo e Operacional

- ✅ **18 tabelas** estruturadas com relacionamentos completos
- ✅ **24 procedures** de lógica de negócio implementadas
- ✅ **6 triggers** automáticas para gameplay fluido
- ✅ **Interface CLI** Python completa e funcional
- ✅ **Sistema de autenticação** robusto com bcrypt
- ✅ **30+ comandos Make** para gerenciamento automatizado
- ✅ **Docker orchestration** para deploy simplificado

### 🎮 Como Jogar

Para iniciar o jogo imediatamente:
```bash
make play
```

## O Mundo de District ZER0

Em um futuro distópico onde megacorporações controlam todas as esferas da sociedade, existe uma zona conhecida apenas como "District ZER0" - um submundo digital onde hackers, mercenários e rebeldes lutam pela sobrevivência e reputação. Como jogador, você navegará por este ambiente hostil, coletará itens, enfrentará inimigos e construirá sua lenda neste universo cibernético.

### 🗺️ Mundo Expansivo
- **15 salas interconectadas** no ambiente cyberpunk
- **4 safe-zones** para descanso e comércio
- **3 dungeons** de alta dificuldade
- **8 áreas normais** com combate livre

### 👥 Classes e Facções
- **6 classes únicas** de personagem
- **7 facções** com ideologias distintas
- **Sistema de reputação** individual e factional

## Mecânicas de Jogo

### 🎯 Gameplay Principal
- **Exploração**: Navegue por salas interconectadas usando comandos de direção (N/S/L/O)
- **Coleta de Itens**: Encontre e utilize chips, armas e dados criptografados (20 tipos, 5 raridades)
- **Combate PvE**: Enfrente 15 tipos de mobs com sistema de drops probabilístico
- **Missões**: Complete 12 missões com 5 níveis de dificuldade
- **Persistência Total**: Todos os dados salvos em PostgreSQL com transações ACID

### ⚔️ Sistema de Combate
- **Combate em turnos** com cálculos de dano automáticos
- **Sistema de fuga** com probabilidade baseada em atributos
- **Morte e respawn** com penalidades (30% créditos, 3 reputação)
- **Level up automático** por XP com bonus de atributos

### 🏛️ Sistemas Sociais
- **Sistema de Reputação**: Suas ações afetam como o mundo virtual reage a você
- **Facções**: Integre-se a organizações para benefícios especiais
- **Ranking Global**: Posição baseada em reputação e experiência
- **Sistema de Logs**: Auditoria completa de todas as ações

## 📚 Estrutura da Documentação

A documentação do projeto está organizada em módulos que refletem o desenvolvimento incremental:

### 📋 Módulo 1: Modelagem de Dados
- **Dicionário de Dados**: Definição completa de todas as entidades
- **Modelo Entidade Relacionamento**: Estrutura conceitual do banco
- **Diagrama Entidade Relacionamento**: Representação visual das relações
- **Modelo Relacional**: Estrutura lógica das tabelas

### 🐳 Módulo 2: Implementação do Banco
- **Setup com Docker**: Configuração de ambiente containerizado
- **Implementação SQL**: Scripts DDL, DML e DQL completos
- **Infraestrutura Docker**: Orquestração de serviços

### 🎮 Módulo 3: Sistema Completo
- **Como Jogar**: Guia completo de gameplay
- **Implementação Técnica**: Detalhes da arquitetura e código
- **Apresentação do Sistema**: Demonstração das funcionalidades

## 🚀 Evolução do Projeto

| Módulo | Período | Escopo | Status |
|--------|---------|--------|--------|
| **1** | Nov 2024 | Modelagem conceitual e lógica | ✅ Completo |
| **2** | Dez 2024 | Implementação do banco PostgreSQL | ✅ Completo |
| **3** | Jan 2025 | Interface CLI e sistema completo | ✅ Completo |

## 📊 Arquitetura Técnica

### Stack Tecnológica
- **Backend**: PostgreSQL 15 (18 tabelas, 24 procedures, 6 triggers)
- **Interface**: Python 3.9+ (CLI colorida com autenticação)
- **Containerização**: Docker Compose (PostgreSQL + Adminer)
- **Automação**: Makefile (30+ comandos de gerenciamento)

### Métricas do Sistema
- **Performance**: < 100ms tempo de resposta
- **Disponibilidade**: 99.9% uptime com health checks
- **Segurança**: Autenticação bcrypt, prepared statements
- **Escalabilidade**: Suporte a múltiplos jogadores simultâneos

## 👥 Equipe - Grupo 15

| Integrante | Matrícula | GitHub |
|------------|-----------|--------|
| **Vinicius Angelo de Brito Vieira** | 190118059 | [@viniciusvieira00](https://github.com/viniciusvieira00) |
| **Mateus Levy Avelans Boquady** | 190113901 | [@MateusBoquady](https://github.com/MateusBoquady) |
| **Guilherme Basilio do Espírito Santo** | 160007615 | [@GuilhermeB-Silva](https://github.com/GuilhermeB-Silva) |

### 🎯 Contribuições por Módulo

**Módulo 1**: Modelagem e estruturação do banco de dados
- Definição do modelo conceitual e lógico
- Criação dos diagramas ER e relacional
- Documentação inicial do dicionário de dados

**Módulo 2**: Implementação do sistema de banco
- Desenvolvimento dos scripts SQL (DDL, DML, DQL)
- Configuração do ambiente Docker
- Implementação de procedures e triggers

**Módulo 3**: Sistema completo funcional
- Desenvolvimento da interface CLI Python
- Integração do sistema de autenticação
- Implementação do sistema de automação Make
- Documentação completa do projeto

---

**Desenvolvido para:** Sistemas de Bancos de Dados 1 (SBD1) - 2025.1  
**Universidade:** Universidade de Brasília (UnB)  
**Professor:** [Nome do Professor]  
**Período:** Novembro 2024 - Janeiro 2025

