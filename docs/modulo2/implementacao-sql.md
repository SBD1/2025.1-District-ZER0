# **Implementação SQL - Módulo 2**

A implementação SQL é uma etapa fundamental no desenvolvimento de sistemas de banco de dados, responsável por traduzir o modelo conceitual em comandos executáveis que criam e manipulam as estruturas de dados. Este documento apresenta a implementação completa do banco de dados District ZER0, incluindo a criação de tabelas, inserção de dados e consultas de exemplo.

## 📋 Arquivos Implementados

### Versões SQL Padrão

#### **DDL.sql** - Definição de Dados
Arquivo contendo a estrutura completa do banco de dados com todas as tabelas, relacionamentos e restrições do sistema District ZER0.

**Principais estruturas implementadas:**
- **Tabelas principais**: `jogadores`, `personagens`, `salas`, `itens`
- **Relacionamentos**: Implementação de chaves estrangeiras e integridade referencial
- **Herança de classes**: Sistema de especialização para classes de personagens
- **Índices**: Otimização de consultas frequentes
- **Constraints**: Validações de integridade de dados

#### **DML.sql** - Manipulação de Dados
Script responsável pela população inicial do banco com dados de exemplo.

**Dados inseridos:**
- **Jogadores**: Contas de usuários para teste
- **Personagens**: Avatares com diferentes classes e atributos
- **Salas**: Ambiente cyberpunk com locais interconectados
- **Itens**: Arsenal de equipamentos e consumíveis
- **Mobs**: NPCs hostis distribuídos pelo mundo
- **Missões**: Quests disponíveis para os jogadores

#### **DQL.sql** - Consultas de Exemplo
Conjunto de queries demonstrando as funcionalidades do sistema.

**Exemplos de consultas:**
- Listagem de personagens por classe
- Inventário completo de jogadores
- Ranking de jogadores por experiência
- Itens disponíveis por sala
- Histórico de combates
- Status de missões em andamento

### Versões MySQL (Implementação Docker)

#### **DDL_mysql.sql** - Estrutura MySQL
Adaptação do DDL original para compatibilidade com MySQL, incluindo:

**Principais adaptações:**
- **Tipos de dados**: Conversão de tipos PostgreSQL para MySQL
- **Auto-increment**: Uso de `AUTO_INCREMENT` em vez de `SERIAL`
- **Constraints**: Ajustes na sintaxe de restrições
- **JSON**: Utilização do tipo `JSON` nativo do MySQL para drop tables
- **Charset**: Configuração UTF-8 para suporte a caracteres especiais

#### **DML_mysql.sql** - Dados MySQL
População de dados adaptada para MySQL com:

**Características específicas:**
- **Inserções**: Sintaxe otimizada para MySQL
- **Transações**: Implementação de controle transacional
- **Validações**: Verificação de integridade durante inserção
- **Performance**: Otimização para carregamento em lote

#### **DQL_mysql.sql** - Consultas MySQL
Queries de exemplo adaptadas para MySQL incluindo:

**Funcionalidades demonstradas:**
- **Junções complexas**: Relacionamentos entre múltiplas tabelas
- **Agregações**: Estatísticas e rankings
- **Subconsultas**: Consultas aninhadas para análises avançadas
- **Views**: Criação de visões para consultas frequentes
- **Procedures**: Funcionalidades avançadas de MySQL

#### **00_init.sql** - Inicialização Automática
Script especial para inicialização automática do Docker, contendo:

**Funcionalidades:**
- **Criação de usuário**: Setup de usuário específico do projeto
- **Permissões**: Configuração de privilégios necessários
- **Charset**: Definição de codificação de caracteres
- **Validação**: Verificação de estrutura inicial

## 🔄 Diferenças entre PostgreSQL e MySQL

### Tipos de Dados
| PostgreSQL | MySQL | Observações |
|------------|-------|-------------|
| `SERIAL` | `AUTO_INCREMENT` | Campos incrementais |
| `TEXT` | `TEXT` | Texto longo |
| `VARCHAR` | `VARCHAR` | Texto variável |
| `JSON` | `JSON` | Dados estruturados |
| `TIMESTAMP` | `TIMESTAMP` | Data e hora |

### Sintaxe Específica
- **PostgreSQL**: Uso de `"` para identificadores
- **MySQL**: Uso de `` ` `` para identificadores
- **Constraints**: Sintaxe ligeiramente diferente
- **Functions**: Funções específicas de cada SGBD

## 📊 Estrutura de Classes (Herança)

O sistema implementa herança de classes através do padrão **Table-per-Subclass**:

### Classe Base
```sql
classe_personagem (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
)
```

### Especializações
- **mercenarios**: Combatentes especializados
- **engenheiros**: Especialistas em tecnologia
- **ciborgues**: Híbridos homem-máquina
- **hackers**: Especialistas em invasões digitais
- **medicos**: Suporte e cura

Cada especialização possui atributos únicos mantendo relacionamento 1:1 com a classe base.

## 🎯 Exemplos de Queries Importantes

### Ranking de Jogadores
```sql
SELECT p.nome, j.username, p.experiencia, p.nivel
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
ORDER BY p.experiencia DESC
LIMIT 10;
```

### Inventário Completo
```sql
SELECT j.username, i.nome, inv.quantidade, i.raridade
FROM inventario inv
JOIN jogadores j ON inv.jogador_id = j.id
JOIN itens i ON inv.item_id = i.id
ORDER BY j.username, i.raridade;
```

### Salas com Itens Disponíveis
```sql
SELECT s.nome as sala, i.nome as item, 
       its.quantidade, i.valor, i.raridade
FROM salas s
JOIN itens_sala its ON s.id = its.sala_id
JOIN itens i ON its.item_id = i.id
WHERE its.quantidade > 0;
```

## ⚡ Otimizações Implementadas

### Índices
- **Primary Keys**: Índices automáticos em todas as PKs
- **Foreign Keys**: Índices em FKs para joins eficientes
- **Busca por nome**: Índices em campos de nome frequentemente consultados
- **Ordenação**: Índices compostos para rankings

### Constraints
- **Integridade Referencial**: Todos os relacionamentos validados
- **Validações de Domínio**: Restrições em valores permitidos
- **Not Null**: Campos obrigatórios devidamente marcados
- **Unique**: Prevenção de duplicações

## 🔧 Comandos de Teste

### Verificação de Estrutura
```sql
-- PostgreSQL
\dt

-- MySQL
SHOW TABLES;
```

### Validação de Dados
```sql
SELECT COUNT(*) FROM jogadores;
SELECT COUNT(*) FROM personagens;
SELECT COUNT(*) FROM itens;
SELECT COUNT(*) FROM salas;
```

### Teste de Relacionamentos
```sql
-- Verificar integridade referencial
SELECT p.nome, j.username, s.nome as sala_atual
FROM personagens p
JOIN jogadores j ON p.jogador_id = j.id
JOIN salas s ON p.sala_atual_id = s.id;
```

## 📈 Estatísticas do Banco

### Resumo de Dados Inseridos
- **Jogadores**: 10+ contas de exemplo
- **Personagens**: 15+ avatares de diferentes classes
- **Salas**: 20+ locais interconectados
- **Itens**: 50+ equipamentos e consumíveis
- **Mobs**: 30+ NPCs hostis
- **Missões**: 10+ quests disponíveis

### Complexidade do Modelo
- **Tabelas**: 15+ entidades
- **Relacionamentos**: 20+ foreign keys
- **Herança**: 5 especializações de classe
- **Constraints**: 50+ validações

## Histórico de Versão

| Versão |    Data    |                     Descrição                      |                       Autor(es)                        |
| :----: | :--------: | :-------------------------------------------------: | :----------------------------------------------------: |
| `1.0`  | 12/06/2025 | Criação da documentação de implementação SQL       | [Vinicius Vieira](https://github.com/viniciusvieira00) | 