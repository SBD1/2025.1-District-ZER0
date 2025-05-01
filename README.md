# District ZER0

Documentação oficial do projeto **District ZER0: Cyberpunk Pocket MUD**.

GRUPO 15 DE SISTEMAS DE BANCOS DE DADOS 1 - 2025.1 - UnB

## Sobre o Projeto

**District ZER0** é um Multi-User Dungeon (MUD) com temática cyberpunk desenvolvido como projeto para a disciplina de Sistemas de Bancos de Dados 1 (SBD1) no semestre 2025.1. O jogo é implementado utilizando PostgreSQL como sistema de banco de dados principal, garantindo persistência, consistência e escalabilidade dos dados.

## Documentação

A documentação do projeto é gerenciada com [MkDocs](https://www.mkdocs.org/) e está disponível em: 
**[https://sbd1.github.io/2025.1-District-ZER0/](https://sbd1.github.io/2025.1-District-ZER0/)**

### Branch `docs`

A branch `docs` é dedicada exclusivamente para desenvolvimento e atualização da documentação do projeto. 

- Todas as alterações na documentação devem ser feitas nesta branch
- PRs relacionados à documentação devem ter `doc` como branch alvo

### Workflow de Deploy

O projeto utiliza GitHub Actions para automatizar o deploy da documentação:

- O workflow é acionado automaticamente quando:
  - Ocorre um push para a branch `docs` (afetando arquivos em `docs/` ou `mkdocs.yml`)
  - Um PR é aberto/atualizado para a branch `docs` (afetando arquivos em `docs/` ou `mkdocs.yml`)
  - Acionado manualmente através da interface do GitHub (Actions → Workflows → Deploy Documentação → Run workflow)

- O resultado do deploy é publicado na branch `gh-pages` e disponibilizado através do GitHub Pages

## Executando a Documentação Localmente

Para visualizar a documentação em seu ambiente local:

1. Clone o repositório:
   ```bash
   git clone https://github.com/SBD1/2025.1-District-ZER0/
   cd 2025.1-District-ZER0
   git checkout docs
   git pull
   ```

2. Crie e ative um ambiente virtual:
   ```bash
   # No Linux/macOS
   python -m venv .venv
   source .venv/bin/activate

   # No Windows
   python -m venv .venv
   .venv\Scripts\activate
   ```

3. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```

4. Execute o servidor MkDocs:
   ```bash
   mkdocs serve
   ```
   
5. O terminal fornecerá um link (geralmente http://127.0.0.1:8000). Clique nele ou copie para seu navegador.

## Contribuição

Para contribuir com a documentação:

1. Crie um branch a partir de `docs`:
   ```bash
   git checkout docs
   git pull
   git checkout -b doc/sua-alteracao
   ```

2. Faça suas alterações e commit:
   ```bash
   git add .
   git commit -m "docs: descrição da alteração"
   git push origin doc/sua-alteracao
   ```

3. Abra um Pull Request para a branch `docs`

