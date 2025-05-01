# **Modelo Entidade-Relacionamentos - MER**

O Modelo Entidade-Relacionamentos (MER) é uma ferramenta essencial na modelagem de dados, permitindo a representação gráfica de entidades, atributos e relacionamentos em um sistema. Ele serve como base para o desenvolvimento de bancos de dados relacionais, garantindo uma estrutura lógica e eficiente para o armazenamento e recuperação de informações. Neste documento, exploraremos os conceitos fundamentais do MER e sua aplicação prática.


# Modelo Entidade-Relacionamento — *District ZER0*

## Entidades e Atributos

### 1. **Jogador**
- `id` (PK, inteiro): Identificador único do jogador  
- `username` (varchar): Nome de usuário  
- `senha_hash` (varchar): Hash da senha  

---

### 2. **Personagem**
- `id` (PK, inteiro): Identificador único do personagem  
- `jogador_id` (FK → Jogador): Dono do personagem  
- `nivel` (inteiro): Nível  
- `vida` (inteiro): Pontos de vida  
- `experiencia` (inteiro): Pontos de experiência  
- `reputacao` (inteiro): Reputação  
- `carteira` (inteiro): Créditos  
- `ataque` (inteiro): Poder de ataque  
- `defesa` (inteiro): Poder de defesa  
- `faccao_id` (FK → Faccao): Facção (opcional)  
- `sala_atual_id` (FK → Sala): Sala atual  

---

### 3. **Sala**
- `id` (PK, inteiro): Identificador único  
- `nome` (varchar): Nome da sala  
- `tipo` (varchar): Tipo da sala (normal, safe-zone, boss-room...)  
- `descricao` (texto): Descrição  

---

### 4. **Item**
- `id` (PK, inteiro): Identificador único  
- `nome` (varchar): Nome do item  
- `tipo` (varchar): Tipo (chip, arma, dado...)  
- `descricao` (texto): Descrição  
- `raridade` (varchar): Grau de raridade  
- `valor` (inteiro): Valor monetário/utilidade  

---

### 5. **Inventário (ItemInventário)**
- `id` (PK, inteiro): Identificador único  
- `jogador_id` (FK → Jogador): Dono do item  
- `mob_id` (FK → Mob, opcional): Origem do item  
- `item_id` (FK → Item): Item  
- `quantidade` (inteiro): Quantidade  

---

### 6. **Item na Sala (ItemSala)**
- `id` (PK, inteiro): Identificador único  
- `sala_id` (FK → Sala): Localização  
- `item_id` (FK → Item): Item disponível  
- `quantidade` (inteiro): Quantidade  

---

### 7. **Mob**
- `id` (PK, inteiro): Identificador único  
- `nome` (varchar): Nome do mob  
- `tipo` (varchar): Tipo (mob ou boss)  
- `vida` (inteiro): Vida  
- `ataque` (inteiro): Ataque  
- `defesa` (inteiro): Defesa  
- `sala_id` (FK → Sala): Sala onde está  
- `drop_table` (JSON): Tabela de drops  

---

### 8. **Missão**
- `id` (PK, inteiro): Identificador único  
- `nome` (varchar): Nome  
- `descricao` (texto): Descrição  
- `recompensa` (varchar): Tipo de recompensa  
- `pre_requisito_missao` (inteiro): XP mínimo  
- `tipo` (varchar): Tipo de missão  

---

### 9. **Missão por Jogador (MissaoJogador)**
- `id` (PK, inteiro): Identificador único  
- `jogador_id` (FK → Jogador): Dono da missão  
- `missao_id` (FK → Missao): Missão  
- `status` (varchar): Estado (em andamento, completada, falhada)  
- `progresso` (inteiro): Percentual (0–100)  

---

### 10. **Facção (Faccao)**
- `id` (PK, inteiro): Identificador único  
- `nome` (varchar): Nome  
- `descricao` (texto): Descrição  
- `reputacao` (inteiro): Reputação global  

---

### 11. **Combate**
- `id` (PK, inteiro): Identificador único  
- `personagem_id` (FK → Personagem): Participante  
- `mob_id` (FK → Mob, opcional): Inimigo  
- `data_hora` (timestamp): Data/hora  
- `resultado` (varchar): Resultado (vitória, derrota)  

---

## Relacionamentos

| Entidade Origem     | Relacionamento                         | Entidade Destino      | Tipo de Relacionamento      |
|---------------------|----------------------------------------|------------------------|------------------------------|
| **Personagem**      | pertence a                             | **Jogador**            | N:1                          |
| **Personagem**      | está na                                | **Sala**               | N:1                          |
| **Personagem**      | pertence a (opcional)                  | **Facção**             | N:1 (opcional)               |
| **ItemInventário**      | pertence a                             | **Jogador**            | N:1                          |
| **Item**      | contém                                 | **ItemInventário**               | N:1                          |
| **Item**      | pertence a (opcional)                 | **Mob**                | N:1 (opcional)               |
| **ItemSala**        | está em                                | **Sala**               | N:1                          |
| **ItemSala**        | contém                                 | **Item**               | N:1                          |
| **Mob**             | está em                                | **Sala**               | N:1                          |
| **MissaoJogador**   | pertence a                             | **Jogador**            | N:1                          |
| **MissaoJogador**   | refere-se a                            | **Missão**             | N:1                          |
| **Combate**         | envolve                                | **Personagem**         | N:1                          |
| **Combate**         | contra (opcional)                      | **Mob**                | N:1 (opcional)               |

---


## Histórico de Versão
| Versão | Data | Descrição | Autor(es) |
| :-: | :-: | :-: | :-: | 
| `1.0`  | 30/04/2025 | Adição do Modelo Relacional | [Guilherme Basílio](https://github.com/GuilhermeBES) 
`1.1`  | 30/04/2025 | Modifica Modelo Entidade Relacionamento | [Mateus Levy](https://github.com/mateus9levy) |
