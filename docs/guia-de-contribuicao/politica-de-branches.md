# Política de Branches

## Introdução

Este documento descreve as regras para a criação e gerenciamento de branches no repositório.

## Fluxo de Branches

O projeto seguirá o modelo GitFlow, com as seguintes branches principais:

- `main`: versão estável do projeto
- `develop`: versão de desenvolvimento do projeto
- `docs`: branch para documentação
- Branches de features: criadas a partir da develop para desenvolvimento de novas funcionalidades
- Branches de release: preparação para uma nova versão de produção
- Branches de hotfix: correções urgentes em produção

## Nomenclatura das Branches

As branches devem seguir o seguinte padrão de nomenclatura:

- Features: `feature/nome-da-feature`
- Correções: `fix/nome-da-correcao`
- Documentação: `doc/nome-da-documentacao`
- Releases: `release/versao`
- Hotfixes: `hotfix/nome-do-hotfix`

## Exemplo

```
feature/cadastro-usuario
fix/correcao-login
doc/manual-usuario
release/v1.0.0
hotfix/correcao-seguranca
``` 