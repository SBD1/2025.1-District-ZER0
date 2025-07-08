# Planejamento de Triggers e Procedures para District ZER0

Para prosseguir com o desenvolvimento do **District ZER0: Cyberpunk Pocket MUD**, é essencial planejar cuidadosamente as **triggers** (gatilhos) e **stored procedures** necessárias para implementar as mecânicas de jogo com as boas práticas. Com base nos módulos 1 e 2, já temos o banco de dados estruturado (tabelas de jogadores, personagens, salas, itens, mobs, missões etc.). Agora, vamos migrar para PostgreSQL, preparar a interface CLI em Python e detalhar os gatilhos/procedures para movimentação, combate, itens, missões, facções e reputação.

## Migração do MySQL para PostgreSQL

Conforme decidido, a implementação final será em **PostgreSQL** (o projeto já foi concebido usando PostgreSQL inicialmente). A migração do MySQL exigirá atenção para adaptar sintaxe e recursos específicos, mas trará benefícios como melhor suporte a **JSON** (útil para as drop tables de mobs) e um robusto sistema de triggers/procedures com PL/pgSQL. Algumas ações na migração:

- **Revisão do DDL**: Adaptar tipos de dados e auto-incrementos. Por exemplo, trocar `AUTO_INCREMENT` por **SEQUENCES** ou tipos serial em PostgreSQL. Verificar se todas as _constraints_ (PK, FK, UNIQUE, etc.) e heranças estão consistentes no novo SGBD (a estrutura de herança _Table-per-Subclass_ de classes de personagem e mobs deve ser recriada em PG conforme o modelo).
    
- **Procedures/Functions**: Em PostgreSQL, utilizaremos funções em PL/pgSQL (marcadas como `VOLATILE` ou `IMMUTABLE` conforme o caso) para implementar lógica de negócios. Diferente do MySQL, o PostgreSQL não tem `CREATE PROCEDURE` tradicional para lógica procedimental, então usaremos `CREATE FUNCTION ... LANGUAGE plpgsql` que pode retornar `VOID` ou algum resultado.
    
- **Triggers**: Reescrever os triggers considerando a sintaxe do PostgreSQL (usar `CREATE TRIGGER ... EXECUTE FUNCTION trigger_function()`). Lembrar que no PG as triggers podem ser _FOR EACH ROW_ ou _FOR EACH STATEMENT_; aqui provavelmente usaremos _ROW-level triggers_ para reagir a mudanças em linhas (ex.: mudança nos pontos de vida, atualização de status de missão, etc.).
    
- **Testes de integridade**: Após migrar os dados (usando scripts DML adaptados), rodar consultas de verificação para garantir que o banco migrou corretamente (contagem de registros, checagem de relacionamentos, etc.). Em especial, verificar se as 20+ salas interconectadas e demais entidades estão presentes, pois a movimentação depende da consistência do mapa.
    

## Interface de Linha de Comando (CLI) em Python

Implementaremos uma interface de texto em Python para o jogo, o que é viável e ágil para a equipe. A CLI será responsável por receber comandos do usuário (mover, atacar, pegar item, etc.) e interagir com o banco de dados via bibliotecas como **psycopg2** (ou outra interface PostgreSQL) para invocar procedures e consultar informações. Benefícios e considerações:

- **Facilidade de Implementação**: Python permite construir rapidamente um loop de jogo que lê comandos e executa ações correspondentes. A escolha de CLI simplifica a interface para esse protótipo (sem necessidade de GUI complexa).
    
- **Conexão com BD**: Vamos conectar o Python ao PostgreSQL e utilizar _prepared statements_ ou chamadas diretas de funções armazenadas. Por exemplo, um comando "`mover norte`" na CLI pode chamar a função SQL `mover_personagem(personagem_id, 'N')` que atualiza a sala do personagem, retornando talvez a descrição da nova sala para exibirmos.
    
- **Lógica no Banco**: Manter a lógica de jogo no banco (via triggers/procs) garante que mesmo múltiplos clientes ou situações concorrentes respeitem as regras. A CLI ficará responsável apenas por enviar comandos válidos e mostrar resultados, enquanto o BD executa as regras (por exemplo, cálculo de dano, verificação de inventário, progressão de missão, etc.). Isso também facilita testes diretos no BD.
    
- **Tratamento de Erros**: A interface Python deverá capturar exceções retornadas (por exemplo, tentar mover para uma direção inválida ou pegar um item inexistente deve resultar em uma mensagem amigável). Podemos lançar **EXCEPTION** nas functions PL/pgSQL quando alguma condição inválida ocorrer, e o Python exibirá a mensagem ao jogador.
    
- **Modularidade**: Organizar os comandos da CLI de acordo com as mecânicas (movimento, combate, itens, etc.), chamando a rotina correspondente. Isso facilita trabalhar com calma em cada recurso dentro das ~4 horas e ir testando passo a passo.
    

## Triggers e Procedures para Mecânicas do Jogo

Agora detalhamos as mecânicas de jogo que precisam ser implementadas. Usaremos uma combinação de **stored procedures** (funções) para operações atômicas mais complexas e **triggers** para garantir consistência automática em certos eventos (como mortes, ganhos de XP, conclusão de missão, etc.). Abaixo, organizamos por categoria:

### 1. Movimentação entre Salas

**Descrição**: Permitiremos que o personagem se desloque pelas salas interconectadas usando comandos de direção (N/S/L/O, isto é, Norte, Sul, Leste, Oeste). A localização atual do personagem é armazenada em `personagens.sala_atual_id`, que referencia a sala onde ele está.

**Procedure `mover_personagem(id_personagem, direcao)`**: Uma função PL/pgSQL que realiza a movimentação. Deverá:

- **Validar direção**: As direções permitidas são `'N','S','L','O'`. Se um comando inválido for passado, lançar exceção informando uso correto.
    
- **Determinar sala destino**: Usar a sala atual do personagem e encontrar qual é a sala adjacente na direção solicitada. Aqui precisamos do **mapeamento do mundo**. Se já existir uma tabela de conexões (ex: `caminhos` com colunas `sala_origem, direcao, sala_destino`), faremos uma consulta para encontrar a sala vizinha. Caso contrário, se as salas e direções estiverem codificadas de outra forma (p.ex., colunas de adjacência na própria tabela `salas`), utilizamos esse relacionamento. _É importante garantir que o mundo esteja conectado logicamente; possivelmente no DML do módulo 2 foram inseridas 20+ salas e sua conectividade._
    
- **Mover se possível**: Se for encontrada uma sala vizinha naquela direção, atualizar `personagens.sala_atual_id` para o ID da nova sala. Se não houver saída naquela direção (nenhuma conexão encontrada), lançar erro ou simplesmente informar "Não é possível seguir para **{direção}**."
    
- **Triggers adicionais**: A princípio, movimentação em si não requer trigger, pois é uma ação direta. No entanto, podemos adicionar restrições via triggers para garantir integridade, por exemplo: um **trigger BEFORE UPDATE** em `personagens.sala_atual_id` que cheque se a nova sala é adjacente da anterior, evitando teleportes ilegais. Esse trigger consultaria a tabela de conexões válida. Se a mudança não for válida, ele poderia cancelar a operação (RAISE EXCEPTION).
    
- **Retorno de informação**: A função pode retornar informações da sala destino para a CLI exibir (por exemplo, descrição da sala, itens presentes e mobs no local). Isso economiza uma consulta extra. Podemos fazer um SELECT na tabela `salas` para pegar `nome` e `descricao` da nova sala e talvez listar itens (`itens_sala`) e mobs nela. Com isso, ao mover, o jogador já vê o ambiente.
    

_Boas práticas_: Garantir que a função de movimento faça commit atômico da mudança de sala. Utilizar transação curta para não segurar locks indevidamente (apenas o update do personagem). Opcionalmente, poderia-se implementar um sistema de **safe-zone**: se a sala destino for do tipo "safe-zone", poderíamos restaurar a vida do jogador ou impedir combates ali. Isso pode ser controlado por triggers ou logicamente na função de ataque (ver adiante).

### 2. Combate e Ataques (PvE e PvP)

**Descrição**: O sistema de combate é por turnos, envolvendo ataques contra mobs (NPCs) hostis ou até outros jogadores. Cada personagem e mob possui atributos de ataque, defesa e vida para calcular o resultado do combate. Vamos implementar funções para ataque e usar triggers para consequências (morte, XP, reputação).

**Procedure `atacar_mob(id_personagem, id_mob)`**: Realiza um turno de ataque do personagem contra um mob alvo:

- **Validações iniciais**: Verificar que o mob existe e está na **mesma sala** que o jogador (podemos comparar `personagens.sala_atual_id` com `mobs.sala_id`). Se não estiver no mesmo local, abortar (não pode atacar algo em outra sala). Também checar se o mob ainda está vivo (`mobs.vida > 0`).
    
- **Cálculo de dano**: Carregar os atributos do personagem (ataque, defesa) e do mob (ataque, defesa). Podemos calcular o dano do jogador no mob como, por exemplo, `dano = GREATEST(personagem.ataque - mob.defesa, 1)` para garantir pelo menos 1 de dano mínimo. Subtrair esse dano da vida do mob.
    
- **Aplicar dano ao Mob**: Atualizar `mobs.vida = mobs.vida - dano`. Use uma única atualização SQL dentro da função, garantindo que a operação esteja dentro de um bloco transaction do PL/pgSQL (o PostgreSQL já executa a função inteira atomicamente). Capture a vida resultante do mob.
    
- **Verificar morte do Mob**: Se após o dano a vida do mob `<= 0`, significa que o mob morreu. Então a procedure deve tratar a morte do mob:
    
    - Registrar a morte no log de combates: Inserir um registro em `combates` indicando `personagem_id` = id do jogador, `mob_id` = id do mob e `resultado` = 'vitória'. O timestamp pode ser default CURRENT_TIMESTAMP. Isso registra que o jogador X venceu o mob Y.
        
    - **Drop de itens do mob**: O mob morto deixa cair itens conforme sua **drop table** em formato JSON. Precisaremos interpretar o JSON (PostgreSQL permite funções JSON para isso). Suponha que no JSON tenhamos uma lista de possíveis itens e possivelmente probabilidades. Implementamos a lógica para sortear ou determinar os drops. Para cada item a ser dropado, inserir (ou atualizar) a entrada correspondente em `itens_sala` da sala em que o mob estava. Por exemplo, se o mob dropa 50 créditos e uma arma rara, adicionamos uma entrada de item (ou incrementamos quantidade se já existe aquela arma na sala). _Boa prática_: usar uma sub-função para processar o JSON de drop, deixando o código modular.
        
    - **Ganhar experiência**: Conceder **experiência** ao jogador pela vitória. A quantidade de XP ganha pode depender do mob (por exemplo, poderíamos armazenar um valor de XP no JSON de drop ou ter uma fórmula baseada no nível/dificuldade do mob). Não temos um campo explícito de XP do mob, então podemos definir manualmente (ex: mob normal = +50 XP, boss = +200 XP, etc.). Atualizar `personagens.experiencia` do jogador somando a XP obtida. _Isso acionará um gatilho de XP_ (veja seção de XP e nível).
        
    - **Reputação**: Se o mob for um **boss** (chefe), aumentar a **reputação** do personagem, já que derrotar um chefe aumenta seu prestígio. Por exemplo, +5 pontos de reputação para um boss. (Podemos identificar boss pelo campo `mobs.tipo` se existir, ou pela presença de registro em `mob_chefe` se seguirmos o modelo de especialização, ou até por um flag no drop_table). Também, se o personagem pertence a uma facção, possivelmente aumentar a reputação global da facção em X. Implementaremos o ajuste de reputação via trigger ou na própria função (detalhado em seção de reputação).
        
    - Remover/Resetar mob: Dependendo da mecânica, podemos remover o mob morto do mundo ou resetar sua vida após drop. Em um MUD persistente, talvez não queiramos deletar a linha (senão ele some permanentemente). Alternativa: marcar `mobs.vida` em 0 e ter um mecanismo de respawn (fora do escopo imediato das 4h) ou simplesmente reinicializar certos mobs periodicamente. No curto prazo, podemos deixar vida=0 significando morto; a função de ataque poderia rejeitar atacar mobs com vida 0. _(Não haverá trigger específico aqui, a lógica da função cobre a morte do mob.)_
        
- **Contra-ataque do Mob**: Se o mob **não morreu** após o ataque do jogador (vida > 0), então o mob realiza seu ataque contra o jogador no mesmo turno (turnos simultâneos):
    
    - Calcular dano do mob no jogador: `dano_mob = GREATEST(mob.ataque - personagem.defesa, 1)`. Subtrair da vida do personagem.
        
    - Atualizar `personagens.vida = personagens.vida - dano_mob`. Em seguida, verificar se o personagem morreu (vida <= 0).
        
    - **Verificar morte do Personagem**: Se o jogador morreu devido ao contra-ataque:
        
        - Registrar combate: Inserir em `combates` um registro de derrota (`personagem_id` = id do jogador, `mob_id` = id do mob, resultado = 'derrota'). Assim sabemos que o jogador X foi derrotado pelo mob Y.
            
        - Acionar gatilho de morte do personagem (detalhado adiante na seção de morte): via trigger ou inline, realizar consequências como perder reputação, talvez perder parte dos créditos (ex.: o jogador dropa parte de seus **créditos** ou itens ao morrer) e marcar missões falhadas.
            
        - Opcional: Poderíamos teleportar o personagem para uma sala segura (ex.: uma enfermaria em uma safe-zone) ao morrer, para não ficar com 0 vida no meio do perigo. Isso pode ser feito aqui na função (atualizando `sala_atual_id` para uma sala de tipo "safe-zone") ou por um trigger After Update em personagens detectando vida 0.
            
    - Se **nenhum** morreu no turno (ambos ainda vivos): simplesmente salvar os novos valores de vida no banco e retornar. A batalha continua em outro turno se o jogador decidir atacar novamente. A interface deve informar os pontos de vida atuais de ambos pós-turno, para o jogador planejar o próximo passo.
        

**Procedure `atacar_jogador(id_atacante, id_alvo)`**: Ataque PvP entre dois jogadores (personagens). A lógica é semelhante ao ataque a mob, com algumas diferenças:

- Validar que ambos estão na mesma sala (não pode atacar jogador que não esteja presente).
    
- Calcular dano usando atributos dos personagens envolvido (atacante.ataque vs alvo.defesa).
    
- Atualizar vida do alvo. Não faremos contra-ataque automático aqui, pois no PvP real, o outro jogador decidirá se contra-ataca em seu turno (ou foge, etc.). Portanto, um comando de ataque em PvP realiza apenas a ação do atacante.
    
- Se o alvo morre (vida <= 0):
    
    - Registrar possivelmente um log. Nosso design atual de tabela `combates` não prevê diretamente PvP (ela vincula personagem contra mob). Poderíamos sobrecarregar a tabela usando `mob_id` nulo para indicar PvP, ou criar uma entrada especial. Mas para simplicidade, podemos registrar uma mensagem de combate separado ou apenas atualizar estatísticas. _(Como isso foge ao modelo original, podemos deixar o log PvP de lado inicialmente.)_
        
    - Consequências da morte do jogador alvo: similares às de morte em PvE – ele perde reputação, possivelmente dropa itens. Pelo fato de ter sido morto por outro **player**, poderíamos dar **recompensa** ao assassino:
        
        - Aumentar reputação do atacante (ex: +1 por um PK – player kill, se quisermos incentivar combates PvP).
            
        - Transferir uma parte dos créditos do alvo para o atacante (saque/loot do corpo). Ex: atacante rouba 20% do dinheiro do alvo morto, implementado como: reduzir `carteira` do alvo e aumentar a do atacante.
            
        - Item drop: podemos decidir que ao morrer, o jogador derruba um item aleatório do inventário na sala. Isso torna o PvP mais recompensador. Implementação: escolher um item do inventário do alvo e mover para `itens_sala` (ou até passar diretamente para o atacante, mas mais justo seria cair no chão para ser disputado). Esse tipo de lógica podemos implementar via trigger de morte do personagem, válido tanto se morreu para mob quanto para outro jogador – a diferença seria quem pega o drop.
            
    - Marcar missões falhadas para o jogador morto (ver seção missões).
        
- Se o alvo não morreu, apenas aplicar o dano. O alvo poderá reagir em seu turno subsequente via outro comando CLI.
    

**Gatilhos de integridade no combate**: Além das procedures, alguns gatilhos garantem as regras:

- _Safe-Zone:_ Um **trigger BEFORE INSERT** em `combates` poderia checar se a sala do personagem é do tipo "safe-zone" e, se for, impedir inserção de combate (ou seja, não se pode iniciar combate em área segura). Entretanto, como controlaremos isso pela lógica nas funções (não listar inimigos ou não permitir atacar em safe-zone), pode não ser necessário.
    
- _Proibição de Friendly Fire:_ Se quisermos impedir ataque entre membros da mesma facção (por lore), um trigger na função de atacar ou um check pode validar que `personagem.faccao_id` do atacante e alvo não sejam iguais (a menos que o design permita traição). Isso é uma regra de jogo que podemos implementar na lógica do procedimento ou via trigger on combates insert (cancelando se facções iguais).
    
- _Transações isoladas:_ Conforme mencionado no enunciado, cada turno de combate deve ser tratado em isolamento. As funções PL/pgSQL já executam num contexto transacional; devemos garantir que antes de iniciar um ataque, não haja outras transações abertas no mesmo jogador para não haver conflitos (cada comando CLI chega sequencialmente por conexão normalmente, então estamos seguros). Se houvesse vários jogadores simultâneos, o SGDB lida com concorrência naturalmente, mas podemos usar nível de isolamento padrão (READ COMMITTED) e travas de update nas linhas de mob e personagem para impedir condições de corrida (ex.: dois jogadores tentando matar o mesmo mob simultaneamente – o primeiro a dar o golpe mortal dispara os triggers, o segundo ao tentar atualizar verá que o mob já está morto).
    

### 3. Itens: Coleta, Drop e Trocas

A manipulação de itens envolve pegar itens do chão (sala), largar itens no chão, e trocas entre personagens. Já temos tabelas apropriadas: `itens_sala` para itens presentes nas salas e `inventario` para itens carregados pelo personagem. Precisamos garantir que essas ações mantenham os dados coerentes.

**Procedure `pegar_item(id_personagem, id_item, quantidade)`**: Permite ao jogador coletar um item que esteja na sala atual:

- **Localizar item na sala**: Verificar em `itens_sala` se existe registro do `item_id` desejado naquela sala (`sala_id = personagens.sala_atual_id` do jogador). Se não encontrar ou a quantidade disponível for menor que a solicitada, abortar com erro "Item não disponível".
    
- **Remover da sala**: Deduzir a quantidade do item na `itens_sala`. Se a quantidade chegar a 0, podemos deletar a linha para limpar. _(Poderíamos ter um trigger AFTER UPDATE em `itens_sala` que deleta a linha se `quantidade` for 0, para manter a tabela sem registros de quantidade zero.)_.
    
- **Adicionar ao inventário**: Verificar se o personagem já tem esse item no inventário (`inventario` com mesmo `item_id` e `personagem_id` ou jogador_id).
    
    - Se já tem, simplesmente somar a quantidade pegada.
        
    - Se não tem, inserir um novo registro no inventário com essa quantidade.
        
- **Registrar origem (opcional)**: O campo `inventario.mob_id` permite guardar a origem do item (se foi drop de um mob). Se o item que está sendo coletado provém de um drop recente, poderíamos identificar de qual mob veio. No momento, `itens_sala` não armazena referência ao mob que dropou. Uma ideia: no momento do drop (quando o mob morre), ao inserir em `itens_sala` poderíamos colocar uma indicação na descrição do item ou ter uma coluna adicional (não prevista inicialmente) para origem. Porém, para não alterar o esquema agora, poderíamos simplesmente ao pegar item conferir se há um combate recente naquela sala envolvendo um drop e atribuir o mob_id correspondente. Isso fica complicado; então, possivelmente, usaremos `mob_id` no inventário apenas se a função de drop de mob entregar diretamente ao jogador (o que não estamos fazendo). Portanto, podemos deixar `mob_id` nulo ao pegar do chão, ou preencher se conseguir inferir a origem. O importante é que o jogador agora possui o item em seu inventário.
    
- **Feedback**: A função pode retornar uma mensagem ou booleano de sucesso, e a interface então pode listar os itens na mochila do jogador (opcional: podemos ter uma função `listar_inventario(id_personagem)` ou simplesmente uma query).
    

**Procedure `dropar_item(id_personagem, id_item, quantidade)`**: Permite ao jogador largar (deixar) um item de seu inventário na sala atual:

- **Validar posse**: Conferir no inventário que o personagem tem ao menos aquela quantidade do item. Senão, erro "Você não tem esse item/quantidade.".
    
- **Remover do inventário**: Diminuir a quantidade ou remover o item do inventário do jogador. Novamente, um trigger poderia remover automaticamente linhas de inventário que cheguem a 0 quantidade, se não tratarmos via código.
    
- **Adicionar à sala**: Atualizar/Inserir em `itens_sala` na sala atual. Se já existe uma entrada daquele item na sala, somar a quantidade dropada; senão, criar nova entrada com a quantidade informada.
    
- **Triggers de consistência**: Poderíamos ter um **trigger AFTER INSERT** em `inventario` que impeça `quantidade` negativa e um **AFTER INSERT/UPDATE** em `itens_sala` semelhante. No entanto, como as procedures controlarão isso, a necessidade de triggers automáticos é mínima aqui. Um cuidado: garantir que chave composta (sala_id, item_id) seja única em `itens_sala` para não termos duplicatas – podemos definir uma constraint UNIQUE(sala_id, item_id) para facilitar e usar `ON CONFLICT ... DO UPDATE` na inserção. Similarmente, no inventário poderíamos ter UNIQUE(personagem_id, item_id) para evitar duplicados para o mesmo item, mas como o modelo atual permite possivelmente entradas múltiplas (embora não desejável), podemos controlar via aplicação.
    

**Procedure `trocar_item(id_personagem_origem, id_personagem_dest, id_item, quant, preco_opcional)`**: Facilitária trocas entre jogadores:

- **Validações**: Verificar se ambos os personagens estão na mesma sala (não faz sentido troca à distância). Checar se o personagem de origem possui o item e quantidade solicitada.
    
- **Transação de troca**: Idealmente, essa procedure executa atomicamente a retirada do item do primeiro jogador e a adição ao segundo. Se houver envolvimento de créditos (por exemplo, venda de item), podemos debitar o comprador e creditar o vendedor na mesma transação.
    
    - Se `preco_opcional` for usado: verificar se o destino tem créditos suficientes em `personagens.carteira`. Então: `carteira_dest -= preco; carteira_origem += preco`.
        
    - Transferir item: similar ao dropar/pegar, remover do inventário do primeiro e adicionar ao inventário do segundo.
        
- **Confirmação mútua**: Numa CLI single-player não teremos a confirmação do outro jogador, mas supõe-se que ambos concordaram (talvez comando pré-acordado). Em contexto multiusuário real, isso exigiria um handshake (fora do escopo imediato).
    
- **Garantir atomicidade**: Usando PL/pgSQL, todas as alterações ocorrem dentro da função, garantindo que ou tudo é efetivado ou nada (rollback em caso de falha). Assim evitamos cenários de item sumir do jogador A sem aparecer para B.
    
- **Triggers**: Não são necessários triggers adicionais se a função for bem controlada. Apenas mantemos as mesmas restrições de integridade mencionadas (ex.: triggers gerais que impeçam dados inválidos como inventário negativo, etc., mas isso normalmente não ocorre se a lógica está correta).
    

### 4. Morte de Personagem e Consequências

Quando um personagem morre (seja por mob ou PvP), há uma série de efeitos colaterais importantes para o jogo. Vamos implementar a maior parte via **triggers** automáticos ao detectar a condição de morte, para garantir que a lógica seja aplicada independentemente de onde a morte for causada (combate PvE, PvP, ou até algum comando de suicídio/teste).

**Trigger de Morte em `personagens`**: Um gatilho _AFTER UPDATE_ ou _AFTER INSERT_ (no caso improvável de inserir um personagem já morto) em `personagens` que detecte quando `vida` passa a ser **0 ou menos**:

- **Condição**: `WHEN NEW.vida <= 0 AND OLD.vida > 0` (ou seja, acabou de morrer agora). Assim só dispara no momento exato da morte.
    
- **Efeitos**:
    
    - **Reputação**: Reduzir a reputação individual do personagem como punição pela morte. Podemos diminuir, por exemplo, uma quantidade fixa (ex: -2 pontos) ou percentual. Isso reflete que “morrer tem consequências na sua fama”. _Exceção_: talvez não penalizar se a morte foi em PvP contra um jogador de reputação alta? (Complexidade extra, podemos ignorar por agora e aplicar penalidade fixa).
        
    - **Drop de ítens do jogador**: Decidir se ao morrer o personagem larga algum item do inventário na sala. Em muitos MUDs, o jogador pode perder alguns itens ou uma parte do ouro na morte. Podemos implementar assim: selecionar certos itens valiosos ou aleatórios do `inventario` do jogador e movê-los para `itens_sala` da sala onde ele morreu. Outra abordagem é dropar uma porcentagem dos **créditos** (moeda) que ele carregava, representando saque fácil. Por simplicidade, podemos: dropar, por exemplo, 30% do dinheiro (atualizar `carteira` do jogador para 70% e criar um item "Créditos" no chão com 30%, se tivermos item representando dinheiro, senão, diretamente reduzir).
        
    - **Missões em andamento**: Marcar como **falhadas** quaisquer missões que o personagem tinha em andamento (`missoes_jogador.status = 'em_andamento'` → 'falhada'). Presume-se que a morte impede a conclusão da missão atual. Implementação: executar um UPDATE em `missoes_jogador` onde `personagem_id = X` e `status = 'em_andamento'` alterando para `status = 'falhada'`. Isso vai acionar possivelmente outro trigger de falha de missão (ver adiante) para penalidades adicionais.
        
    - **Localização (respawn)**: Podemos automaticamente mover o personagem para uma sala de ressurgimento (por ex., sala inicial ou safe-zone). Se definirmos uma sala especial de respawn (ex: "Clínica Médica"), podemos atualizar `sala_atual_id` do personagem para essa sala. _No entanto, cuidado:_ Isso _mesmo_ sendo After Update trigger, se tentarmos atualizar a mesma linha de personagem dentro dele, geraria recursão infinita. Solução: usar um trigger _AFTER_ mas _FOR EACH ROW_ e dentro dele usar um comando diferido ou marcar em outra tabela. Alternativamente, fazer isso na própria procedure de morte em vez do trigger. Para simplificar, podemos optar por não teletransportar automaticamente, e deixar o jogador reviver manualmente (talvez com um comando de "respawn" que o leva a um local seguro).
        
- **Combate log**: Se por algum motivo não logamos a morte no combates (por exemplo, PvP não logado), o trigger poderia inserir um registro de combate genérico "personagem X morreu". Porém, como estamos tratando nos procedures de ataque, o log PvE já está sendo inserido. PvP ainda fica fora. Talvez omitimos log duplicado para evitar inconsistências.
    

**Trigger de Morte em `mobs`**: Similarmente, um gatilho _AFTER UPDATE_ em `mobs` detectando `vida <= 0`:

- Na prática, as consequências da morte do mob (loot, XP, etc.) já foram tratadas dentro da procedure de ataque. Se quiséssemos tornar isso 100% trigger-driven, poderíamos mover essa lógica para um trigger: por exemplo, _AFTER UPDATE ON mobs_ quando vida <= 0, buscar na tabela `combates` quem foi o último a atacar esse mob (difícil de saber sem algum log de dano) ou talvez guardar temporariamente o atacante via sessão. Isso é complexo, então manteremos dentro da função de ataque. Assim, o trigger de mobs poderia não ser necessário.
    
- O que podemos fazer via trigger: garantir que quando um mob morre, seu campo `vida` não fique negativo (apenas 0). Um _BEFORE UPDATE_ poderia truncar valores negativos para 0, só para manter consistência (evitar ter vida -5, por exemplo). Isso é opcional.
    

### 5. Experiência e Nivelamento

Conforme os personagens ganham experiência (`personagens.experiencia`) ao derrotar inimigos e completar missões, devemos gerir aumento de **nível** e desbloqueio de conteúdo (missões) automaticamente. Usaremos triggers para isso:

**Trigger de XP (Level Up)**: _AFTER UPDATE ON personagens_ observando mudanças em `experiencia`:

- **Level Up**: Definir critérios de nível. Por exemplo, poderíamos estipular que a cada 1000 XP o personagem sobe de nível, ou usar uma curva. Suponha algo simples: nível aumenta em 1 a cada vez que XP acumulada >= `nivel_atual * 1000` (exemplo). O trigger verificará: `IF NEW.experiencia >= threshold AND NEW.nivel < novo_nivel`. Caso atinja o próximo nível:
    
    - Incrementar `NEW.nivel` (ou realizar um UPDATE separado no personagem para subir nível). Poderíamos até setar NEW.nivel = NEW.nivel + 1 no próprio trigger (se BEFORE UPDATE) para já salvar incrementado. Em AFTER, precisaríamos outro UPDATE. Talvez melhor usar BEFORE UPDATE: assim que a XP ultrapassa limiar, já ajustar o valor de nível antes de salvar.
        
    - **Recompensa de nível**: Poderíamos restaurar a vida do jogador ou conceder pontos de atributo, mas isso é extra não obrigatório. Comentar como possibilidade de evolução futura.
        
- **Desbloqueio de Missões**: Novas missões ficam disponíveis quando o jogador atinge certa XP (campo `missoes.pre_requisito_missao` indica XP mínima). Quando um jogador atinge um desses patamares:
    
    - Em vez de inserir automaticamente missões, podemos simplesmente notificar ou marcar como disponíveis. Uma ideia: criar registros em `missoes_jogador` com status "disponível". Mas nosso modelo atual de status não contempla "disponível" explicitamente (apenas andamento, completada, falhada). Poderíamos então:
        
        - Notificação: usar `RAISE NOTICE` ou até `pg_notify` para avisar a aplicação que uma nova missão pode ser iniciada. A CLI ao ouvir isso pode listar a missão desbloqueada. `pg_notify('novo_conteudo', payload)` poderia ser usado e o Python ouvir em um thread, mas isso é sofisticado para agora. Simplesmente, talvez basta que ao jogador usar um comando "listar missões disponíveis", a query ao banco filtre as missões com `pre_requisito_missao <= xp_atual` e que não tenham registro em missoes_jogador ainda. Isso não requer trigger de fato, apenas uma consulta.
            
        - Caso queiramos marcação automática: poderíamos no trigger de XP, para cada missão cujo `pre_requisito_missao` foi cruzado agora (entre OLD e NEW xp), inserir em `missoes_jogador` um registro com `status = 'em_andamento'` ou simplesmente informar que está disponível. Auto-iniciar missão pode não ser desejável sem o jogador aceitar. Então, talvez melhor não inserir automaticamente, deixar para o jogador escolher.
            
- **Garantir limites**: Se por design o nível tem um máximo ou XP é resetado de alguma forma, o trigger deve considerar. Mas provavelmente não há limite explícito informado.
    

Em resumo, o trigger de XP principalmente cuida do level up. O desbloqueio de missão vamos deixar a cargo de consulta manual para evitar automatismo confuso, mas podemos incluir uma mensagem no log ou aviso quando atinge certo XP (ex.: "Nova missão disponível!").

### 6. Missões: Início, Conclusão e Falha

O sistema de missões envolve aceitar missões (`missoes_jogador` registra quais missões o jogador tem e seu status), completar objetivos para concluí-las, e receber recompensas ou punições por falhar. Já preparamos alguns pontos como falha automática ao morrer. Vamos definir procedures para início/conclusão e triggers para recompensas/punicoes:

**Procedure `iniciar_missao(id_personagem, id_missao)`**: Quando o jogador decide aceitar uma missão disponível:

- **Pre-requisitos**: Conferir se o personagem atende à XP mínima da missão (`personagem.experiencia >= missoes.pre_requisito_missao`). Ver também se ele já completou essa missão antes (podemos impedir repetição se for único, consultando `missoes_jogador` existente) ou se já está em andamento.
    
- **Marcar como em andamento**: Inserir um registro em `missoes_jogador` com personagem, missão, `status = 'em_andamento'` e `progresso = 0`. Poderíamos também registrar a data de início se precisássemos (não há campo, mas progresso 0 e status já indicam).
    
- **Missões exclusivas**: Talvez limitar quantas missões simultâneas um personagem pode ter (não especificado, podemos assumir algumas simultâneas ok ou apenas uma? Não dito; deixamos livre ou mencione limitar a 1 simultânea para simplicidade). Se for limitar a uma ativa por vez, checar se já existe alguma em_andamento e negar outra até terminar.
    
- **Triggers**: Poderíamos ter um _AFTER INSERT ON missoes_jogador_ para garantir integridade, mas iniciar_missao em si cuida disso. Um possível trigger: se por algum motivo alguém insere manual com XP insuficiente, um BEFORE INSERT poderia validar o pré-requisito. Como estamos usando procedure, não obrigatório.
    

**Procedure `concluir_missao(id_personagem, id_missao)`**: Chamado quando o jogador atingiu os objetivos da missão:

- **Validação**: Verificar se existe registro em `missoes_jogador` com status 'em_andamento' para esse personagem e missão. E se os critérios de conclusão foram alcançados. (No nosso modelo, poderíamos usar o campo `progresso` que vai de 0 a 100%. Suponha que para missoes simples, definiremos manualmente quando completa. Se `progresso` está 100, ou se a missão era derrotar um boss e já ocorreu, etc.)
    
- **Atualizar status**: Dar `UPDATE missoes_jogador SET status = 'completada', progresso = 100` (ou conforme aplicável). Isso acionará um **trigger de conclusão de missão**.
    
- **Trigger de conclusão (`AFTER UPDATE ON missoes_jogador` para status completada)**: Neste gatilho implementamos as **recompensas** da missão automaticamente:
    
    - Consultar a tabela `missoes` para obter a recompensa definida (campo `recompensa`) e possivelmente o tipo da missão. Como `recompensa` é um texto, precisamos interpretar. Pode estar escrito algo como "XP:500" ou "Item:ID" ou "Credits:300".
        
    - Aplicar a recompensa:
        
        - Se for XP, adicionar essa XP ao personagem (e então o trigger de XP cuidará de nível).
            
        - Se for item, inserir no inventário do jogador (ou `itens_sala` se for entregue no mundo).
            
        - Se for créditos, atualizar `carteira` do personagem.
            
        - Se envolver reputação (algumas missões podem conceder fama), aumentar `personagens.reputacao`.
            
        - _Exemplo:_ Uma missão de tipo "caçar boss" poderia ter recompensa "reputacao:10, item:42" significando +10 de reputação e o item de id 42 (talvez um troféu). Teríamos que padronizar o formato para parsear facilmente no trigger (poderíamos usar JSON aqui também, mas pelo tempo, assumir formatos simples delimitados por vírgula).
            
    - Atualizar reputação global da facção, se for uma missão storyline relacionada à facção (não temos essa ligação explícita, mas se quisermos: ex. missão de facção poderia aumentar `faccoes.reputacao`).
        
    - Marcar algum log de "missão X concluída por Y" se necessário (poderia inserir numa tabela de histórico de missões, não existe atualmente – ignorar por agora ou reutilizar combates com tipo 'missão'? Provavelmente não, manter simples).
        
- **Remover restrições/itens de missão**: Se a missão envolvia coletar itens ou matar certo mob, possivelmente o jogador teve que entregar algo. Se sim, este seria o momento de remover itens entregues ou marcar o mob como realmente morto. Esses detalhes dependem do design de cada missão e talvez sejam manuais. Como não temos modelagem específica para requisitos, não detalharemos – assumiremos que se chegou aqui é porque objetivos cumpridos e nada específico a retirar.
    

**Procedure/Trigger de Falha de Missão**:

- A falha pode acontecer de duas formas: (1) explicitamente pelo jogador desistindo ou não conseguindo, ou (2) automaticamente por algum evento (como morrer, tempo esgotado, etc.). Já cobrimos uma automática: morte aciona trigger que faila missões ativas.
    
- Podemos ter um comando `desistir_missao(id_personagem, id_missao)` que simplesmente faz `UPDATE missoes_jogador SET status='falhada'`.
    
- **Trigger de falha (`AFTER UPDATE ON missoes_jogador` para status falhada)**: Aplica penalidades:
    
    - Reduzir reputação do personagem (ex: -1 ou -2, menor do que morrer talvez, já que falhar missão pega mal mas não tanto quanto morrer).
        
    - Opcional: se a missão era da facção, reduzir reputação global da facção levemente (ex: -1) para refletir fracasso.
        
    - Se a missão tinha algum custo (por exemplo, o jogador investiu dinheiro para iniciá-la), poderíamos não reembolsar – porém não temos esse conceito explicitamente.
        
    - Marcar progresso = 0 ou algum valor final (mas já está falhada, progresso talvez irrelevante, poderíamos deixar como estava ou 0).
        
- Esse trigger assegura que independente de falha manual ou por morte, as consequências são aplicadas uniformemente.
    

### 7. Facções e Sistema de Reputação

Por fim, integrando com o sistema de **Facções** e **Reputação**:

**Entrar/Sair de Facção**:

- **Procedure `entrar_faccao(id_personagem, id_faccao)`**: Adiciona o personagem a uma facção:
    
    - Verificar se `personagens.faccao_id` já está preenchido (não permitir entrar se já tem – talvez exigir sair primeiro).
        
    - Atualizar `personagens.faccao_id = id_faccao`. Poderia também definir alguma reputação inicial na facção ou vantagem (não especificado, possivelmente não).
        
    - Poderíamos aumentar ligeiramente `faccoes.reputacao` ao ganhar um novo membro, mas não necessariamente – reputação global parece mais ligada a feitos do grupo.
        
- **Procedure `sair_faccao(id_personagem)`**: Remove o personagem de sua facção atual:
    
    - Definir `personagens.faccao_id = NULL`.
        
    - Talvez diminuir facção.reputacao (ex: -1) se quisermos indicar perda de membro. Mas pode não ser significativo no contexto de reputação global, então podemos ignorar.
        
    - Se o jogo impõe penalidade por deserção, poderíamos reduzir reputação do personagem ao sair. Novamente, não requerido a menos que seja design desejado.
        

**Reputação Global de Facção**:  
Como mencionado, vamos ajustar `faccoes.reputacao` com base em ações dos membros:

- **Trigger em Combate (boss derrotado)**: Quando um boss é derrotado pelo jogador, além de aumentar reputação individual, podemos aumentar a reputação da facção do jogador. Implementação: No momento da vitória sobre boss (essa lógica estava no procedure de ataque ao mob boss), podemos dentro da função mesmo verificar `personagem.faccao_id` e fazer `UPDATE faccoes SET reputacao = reputacao + X WHERE id = personagem.faccao_id`. X pode ser proporcional à importância do boss (ex: +5 para boss forte). Se quisermos centralizar essa lógica em triggers:
    
    - Poderíamos fazer: _AFTER INSERT ON combates_ onde `resultado='vitória'` e combates.mob_id refere um mob do tipo boss. Nesse trigger, identificar o personagem (combates.personagem_id) e sua facção, e fazer o update na facção. Como já temos o combates inserido no procedimento, o trigger cuidaria do resto. Isso desacopla um pouco do procedimento.
        
    - Idem para missões: _AFTER UPDATE ON missoes_jogador_ onde status 'completada' – podemos verificar se a missão é de um certo tipo importante (talvez missões de tipo "facção" ou "principal") e aumentar reputação da facção do personagem.
        
- **Trigger em Falha**: Analogamente, se status 'falhada' ou combates derrota em boss, podemos diminuir reputação da facção. Por exemplo, se um membro fracassa uma missão crucial, facção perde um pouco de prestígio.
    
- _Nota:_ Reputação global serve para ranking de facções; com esses gatilhos, as facções com jogadores mais ativos e bem-sucedidos subirão.
    

**Reputação Individual**: Já abordamos parcialmente:

- Gatilhos de vitória (boss/mission) aumentam `personagens.reputacao`; gatilhos de derrota/falha diminuem.
    
- Podemos consolidar isso:
    
    - _After combate vitória (boss):_ `personagens.reputacao += Y`.
        
    - _After missão completada:_ `personagens.reputacao += Z` (Z dependendo da missão, ou default +1).
        
    - _After combate derrota:_ `personagens.reputacao -= Y'` (pequeno).
        
    - _After missão falhada:_ `personagens.reputacao -= Z'`.
        
- Esse sistema de reputação alimenta o "ranking global" citado – podemos criar uma view ou query ordenando personagens por reputação (ou XP) para mostrar ranking.
    

### 8. Resumo das Ações e Prioridades (Próximas 4 horas)

Tendo planejado cada aspecto, é importante gerenciar bem o tempo e implementar passo a passo, com calma e atenção:

1. **Configurar Ambiente PostgreSQL**: Criar o banco no Postgres e rodar os scripts DDL e DML migrados do módulo 2. Verificar se todas as tabelas (jogadores, personagens, salas, itens, etc.) e dados básicos estão presentes e consistentes. Essa base é necessária para testar os gatilhos.
    
2. **Escrever Functions PL/pgSQL**: Implementar as stored functions uma a uma, testando isoladamente:
    
    - `mover_personagem`,
        
    - `atacar_mob` (essa é mais complexa; testar com um mob fraco e um personagem para verificar se vida diminui corretamente, se loot dropa, etc.),
        
    - `atacar_jogador`,
        
    - `pegar_item` / `dropar_item`,
        
    - `trocar_item`,
        
    - `iniciar_missao` / `concluir_missao` (podemos simular missões simples para teste),
        
    - `entrar_faccao` / `sair_faccao`.
        
3. **Implementar Triggers**: Criar os gatilhos declarados:
    
    - Trigger AFTER UPDATE em personagens (vida <= 0) -> morte do personagem,
        
    - Trigger AFTER UPDATE em personagens (experiencia) -> level up (antes ou after conforme a lógica escolhida),
        
    - Trigger AFTER UPDATE em missoes_jogador -> se completada, dar recompensa; se falhada, penalizar,
        
    - Trigger AFTER INSERT combates -> se vitória contra boss, ajustar reputações; se derrota, possivelmente ajustar também (embora derrota de jogador já foi cuidada no trigger de morte, então pode não precisar duplicar aqui),
        
    - (Opcional) Trigger BEFORE UPDATE em mobs (evitar vida negativa),
        
    - (Opcional) Trigger AFTER UPDATE em itens_sala/inventario para limpar zeros (manutenção).
        
    - Garantir que cada trigger chama uma função trigger separada (uma boa prática é não colocar lógica inline no CREATE TRIGGER, mas sim referenciar uma função criada com `CREATE OR REPLACE FUNCTION func_name() RETURNS trigger AS $$ BEGIN ... END; $$ LANGUAGE plpgsql;`).
        
4. **Testes Integrados**: Utilizar a CLI Python para orquestrar cenários de teste:
    
    - Criar um personagem de teste, movê-lo entre salas, verificar se esbarra em limites apropriadamente.
        
    - Colocar um mob e executar um combate turno a turno, ver se morrendo o mob dropa item e dá XP, e se morrendo o player perde rep e missão falha.
        
    - Testar pegar e dropar itens, trocando entre dois personagens (pode simular dois players alternando comandos).
        
    - Testar aceitar missão, completar (talvez forçar condições) e falhar, observando se recompensas/penalidades aplicam.
        
    - Avaliar também estados inesperados, como tentar ações em ordem errada (ex: atacar sem inimigo, pegar item inexistente) para ver se os erros são manejados.
        
5. **Ajustes Finais e Boas Práticas**: Refinar conforme necessário:
    
    - Ver logs de triggers para pegar quaisquer erros lógicos.
        
    - Garantir que nenhum trigger cause _loop infinito_ (por exemplo, ao atualizar personagem dentro de trigger de personagem – evitamos isso ajustando design).
        
    - Manter **consistência**: todas as atualizações críticas estão ocorrendo via triggers/procs para evitar dados inválidos. Por exemplo, nunca devemos ter item em sala sem sala válida ou missões completadas sem recompensa dada – os triggers cuidam disso imediatamente.
        
    - Documentar brevemente cada trigger/proc (no código ou doc) para futura manutenção.
        

Com esse planejamento, cobrimos os principais pontos pedidos: movimento, ataque (mobs e PvP), drops de itens (de mobs e de jogadores em sala), morte, trocas, ganho de XP e nível, facções, reputação global e individual, missões (início/conclusão/falha) – integrando tudo na base de dados PostgreSQL do jogo. Assim, estaremos prontos para implementar nas próximas horas e deixar o **District ZER0** funcional e consistente!

**Referências:** Estrutura de tabelas e conceitos extraídos da documentação do projeto (Módulos 1 e 2), garantindo que os gatilhos e procedures atuem sobre os campos corretos de acordo com o modelo de dados.