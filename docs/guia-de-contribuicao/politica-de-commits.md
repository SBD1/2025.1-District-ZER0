# Política de Commits

## Introdução

Este documento define as regras para a criação de commits no repositório, visando padronizar as mensagens e facilitar a identificação das alterações realizadas.

## Estrutura das Mensagens de Commit

As mensagens de commit devem seguir o seguinte formato:

```
<tipo>: <descrição>

[corpo]

[rodapé]
```

### Tipos

- `feat`: nova funcionalidade
- `fix`: correção de bug
- `docs`: alterações na documentação
- `style`: formatação, falta de ponto e vírgula, etc; sem alteração de código
- `refactor`: refatoração de código
- `test`: adição de testes
- `chore`: atualizações de tarefas de build, configurações, pacotes, etc

### Descrição

- Deve ser clara e objetiva
- Usar verbos no imperativo (ex: "adiciona", "corrige", "implementa")
- Não deve terminar com ponto final

### Corpo

- Opcional
- Deve conter detalhes sobre as alterações realizadas
- Explicar o "porquê" em vez do "como"

### Rodapé

- Opcional
- Referência a issues (ex: "Closes #123")
- Notas importantes (ex: "BREAKING CHANGE: ...")

## Exemplos

```
feat: adiciona função de login com Google

fix: corrige validação de formulário

docs: atualiza documentação da API

style: formata código conforme padrão

refactor: simplifica lógica de autenticação

test: adiciona testes para componente de carrinho

chore: atualiza dependências
``` 