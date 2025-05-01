# **Dicionário de Dados - DD**

O Dicionário de Dados é um registro detalhado que documenta os elementos de um banco de dados, incluindo tabelas, colunas, tipos de dados, restrições e relacionamentos. Ele é essencial para assegurar consistência, padronização e clareza, servindo como uma referência confiável durante o desenvolvimento, manutenção e evolução do sistema. Além disso, auxilia na comunicação entre equipes técnicas e de negócios, promovendo uma melhor compreensão do modelo de dados.

Abaixo segue o **Dicionário de Dados** completo — um inventário formal com todas as tabelas, colunas, tipos, restrições e descrições do seu DER “District ZER0”.  
Use-o como referência para documentação, geração de scripts SQL, mapeamento ORM ou qualquer auditoria futura.

> **Legenda de abreviações**  
> • **PK** = Primary Key • **FK** = Foreign Key • **NN** = NOT NULL • **AI** = Auto-Increment  
> • “(FK → tbl.col)” indica a tabela/coluna de destino.

---

## 1 · Núcleo de Jogadores e Personagens

| Tabela | Coluna | Tipo | Restrições | Descrição |
|--------|--------|------|------------|-----------|
| **jogadores** | id | int | PK, AI, NN | Identificador único do jogador |
|  | username | varchar | NN, UNIQUE | Nome de usuário |
|  | senha_hash | varchar | NN | Hash da senha |
| **classe_personagem** | id | int | PK, AI, NN | Identificador da classe-pai |
|  | nome | varchar | NN, UNIQUE | Nome da classe (ex.: Mercenário) |
| **personagens** | id | int | PK, AI, NN | Identificador do personagem |
|  | jogador_id | int | FK → jogadores.id, NN | Dono do personagem |
|  | classe_id | int | FK → classe_personagem.id, NN | Classe/base do personagem |
|  | nivel | int |  | Nível atual |
|  | vida | int |  | Pontos de vida |
|  | experiencia | int |  | XP acumulada |
|  | reputacao | int |  | Reputação individual |
|  | carteira | int |  | Créditos (moeda) |
|  | ataque | int |  | Poder de ataque |
|  | defesa | int |  | Poder de defesa |
|  | faccao_id | int | FK → faccoes.id | Facção (opcional) |
|  | sala_atual_id | int | FK → salas.id, NN | Sala em que está |

---

## 2 · Especializações de Classe (HERANÇA T,E)

Cada subtipo tem **PK = FK** para `classe_personagem.id`, garantindo relação 1:1.

| Tabela subtipo | Coluna | Tipo | Restrições | Descrição |
|----------------|--------|------|------------|-----------|
| **mercenarios** | id | int | PK, FK → classe_personagem.id, NN | Identificador da sub-classe |
|  | nome | varchar | NN | Nome da especialização |
|  | poder_especial | varchar |  | Descrição do poder |
| **engenheiros** | … | … | … | Mesmo padrão |
| **ciborgues** | … | … | … |  |
| **hackers** | … | … | … |  |
| **medicos** | … | … | … |  |

*(Todos contêm `id`, `nome`, `poder_especial` com as mesmas restrições.)*

---

## 3 · Ambiente e Itens

| Tabela | Coluna | Tipo | Restrições | Descrição |
|--------|--------|------|------------|-----------|
| **salas** | id | int | PK, AI, NN | Identificador da sala |
|  | nome | varchar | NN | Nome |
|  | tipo | varchar | NN | Categoria (normal, safe-zone…) |
|  | descricao | text |  | Descrição |
| **itens** | id | int | PK, AI, NN | Identificador do item |
|  | nome | varchar | NN | Nome |
|  | tipo | varchar | NN | Tipo (arma, chip…) |
|  | descricao | text |  | Descrição |
|  | raridade | varchar |  | Grau de raridade |
|  | valor | int |  | Valor monetário |
| **itens_sala** | id | int | PK, AI, NN | Identificador |
|  | sala_id | int | FK → salas.id, NN | Localização |
|  | item_id | int | FK → itens.id, NN | Item disponível |
|  | quantidade | int |  | Quantidade |
| **inventario** | id | int | PK, AI, NN | Identificador |
|  | jogador_id | int | FK → jogadores.id, NN | Dono do item |
|  | mob_id | int | FK → mobs.id | Origem (drop) |
|  | item_id | int | FK → itens.id, NN | Item |
|  | quantidade | int |  | Quantidade |

---

## 4 · Mobs e Combate

| Tabela | Coluna | Tipo | Restrições | Descrição |
|--------|--------|------|------------|-----------|
| **mobs** | id | int | PK, AI, NN | Identificador geral |
|  | nome | varchar | NN | Nome do mob |
|  | vida | int |  | Vida |
|  | ataque | int |  | Ataque |
|  | defesa | int |  | Defesa |
|  | sala_id | int | FK → salas.id, NN | Onde aparece |
|  | drop_table | json |  | Tabela de drops em JSON |
| **mob_normal** | id | int | PK, FK → mobs.id, NN | Subtipo normal |
| **mob_chefe** | id | int | PK, FK → mobs.id, NN | Subtipo chefe |
|  | poder_especial | varchar |  | Poder/habilidade especial |
| **combates** | id | int | PK, AI, NN | Identificador |
|  | personagem_id | int | FK → personagens.id, NN | Participante |
|  | mob_id | int | FK → mobs.id | Inimigo (opcional) |
|  | data_hora | timestamp |  | Data e hora |
|  | resultado | varchar | NN | Resultado (vitória/derrota) |

---

## 5 · Missões e Facções

| Tabela | Coluna | Tipo | Restrições | Descrição |
|--------|--------|------|------------|-----------|
| **faccoes** | id | int | PK, AI, NN | Identificador |
|  | nome | varchar | NN | Nome |
|  | descricao | text |  | Descrição |
|  | reputacao | int |  | Reputação global |
| **missoes** | id | int | PK, AI, NN | Identificador |
|  | nome | varchar | NN | Nome |
|  | descricao | text |  | Descrição |
|  | recompensa | varchar |  | Recompensa |
|  | pre_requisito_missao | int |  | XP mínima |
|  | tipo | varchar |  | Tipo de missão |
| **missoes_jogador** | id | int | PK, AI, NN | Identificador |
|  | jogador_id | int | FK → jogadores.id, NN | Jogador |
|  | missao_id | int | FK → missoes.id, NN | Missão |
|  | status | varchar | NN | em_andamento / completada / falhada |
|  | progresso | int |  | Percentual (0-100) |

---

### Observações Gerais

1. **Herança (Table-per-Subclass):**  
   As especializações de `classe_personagem` e de `mobs` são TOTAL + EXCLUSIVAS; o **id** da sub-tabela duplica a PK da super-tabela (garante relação 1:1).

2. **Cardinalidades & Optionalidades:**  
   * (1,N) *Jogador → Personagem*, *Sala → Personagem*, etc.  
   * FKs marcadas como opcional recebem `NULL` (por exemplo `faccao_id`, `mob_id` em Combate).

3. **Tipos de Dados:**  
   Ajuste livremente (ex.: `varchar(255)`, `numeric`) conforme políticas do seu banco; aqui mantivemos tipos genéricos PostgreSQL.

4. **Naming Convention:**  
   Todos os nomes estão em *snake_case* minúsculo; chaves primárias usam `id` único por tabela.


## Histórico de Versão
| Versão | Data | Descrição | Autor(es) |
| :-: | :-: | :-: | :-: | 
| `1.0`  | 30/04/2025 | Adição do Dicionário de Dados| [Guilherme Basílio](https://github.com/GuilhermeBES) |
| `1.1`  | 01/05/2025 | Criação do Dicionário de Dados para o Projeto| [Vinicius Vieira](https://github.com/viniciusvieira00) |
