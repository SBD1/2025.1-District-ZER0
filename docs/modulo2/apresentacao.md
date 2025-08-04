# **Apresentação do Módulo 2**

Esta apresentação demonstra a implementação completa do módulo 2 do projeto District ZER0, incluindo a configuração Docker, implementação SQL e automação com Makefile. O vídeo apresenta o funcionamento prático do sistema e as principais funcionalidades desenvolvidas.

## **🎬 Vídeo de Apresentação**

Você pode acessar o vídeo de apresentação pelo link: [Apresentação do Módulo 2](https://www.youtube.com/watch?v=nXCT5-jN8FU)

Ou pode visualizar diretamente por aqui:
<iframe width="768" height="432" src="https://www.youtube.com/embed/nXCT5-jN8FU?si=zW_OCpZMoJJYoopJ" title="Entrega 3 - Sistema MUD Completo - Grupo 15" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## 🎯 Conteúdo da Apresentação

### **Parte 1: Visão Geral do Módulo 2**
- Objetivos da entrega
- Arquitetura implementada
- Tecnologias utilizadas (Docker, MySQL, Makefile)

### **Parte 2: Implementação SQL**
- Diferenças entre PostgreSQL e MySQL
- Adaptações necessárias nos scripts
- Estrutura dos arquivos DDL, DML e DQL
- Demonstração de queries complexas

### **Parte 3: Infraestrutura Docker**
- Configuração do docker-compose.yml
- Serviços MySQL e Adminer
- Volumes e persistência de dados
- Rede e comunicação entre containers

### **Parte 4: Automação com Makefile**
- Comandos principais (setup, start, test, health)
- Funcionalidades de backup e restore
- Scripts de verificação de saúde
- Demonstração do comando `make entrega`

### **Parte 5: Demonstração Prática**
- Inicialização completa do ambiente
- Acesso via Adminer (interface web)
- Execução de queries de exemplo
- Verificação de integridade dos dados
- Testes de funcionalidade

### **Parte 6: Vantagens da Solução**
- Facilidade de execução para o professor
- Ambiente isolado e consistente
- Documentação completa
- Comandos automatizados

## 📋 Roteiro da Demonstração

### **1. Setup Inicial (2 minutos)**
```bash
# Verificação de dependências
make setup

# Inicialização dos serviços
make start
```

### **2. Verificação de Saúde (1 minuto)**
```bash
# Verificar se tudo está funcionando
make health

# Visualizar status dos containers
docker-compose ps
```

### **3. Interface Web - Adminer (3 minutos)**
- Acesso a http://localhost:8080
- Login com credenciais do projeto
- Navegação pelas tabelas criadas
- Visualização da estrutura do banco

### **4. Execução de Queries (4 minutos)**
```bash
# Executar queries de exemplo
make test
```

Demonstração de consultas:
- Ranking de jogadores por experiência
- Inventário completo de personagens
- Itens disponíveis por sala
- Histórico de combates

### **5. Funcionalidades Avançadas (2 minutos)**
```bash
# Backup automático
make backup

# Logs em tempo real
make logs

# Conexão direta ao banco
make connect-db
```

### **6. Limpeza e Conclusão (1 minuto)**
```bash
# Parar serviços
make stop

# Comando completo de demonstração
make entrega
```

## 🛠️ Preparação para Demonstração

### **Pré-requisitos do Sistema**
- Docker Desktop instalado
- Docker Compose funcional
- Make disponível (ou uso direto do docker-compose)
- Porta 3306 e 8080 livres

### **Checklist Antes da Apresentação**
- [ ] Testar `make entrega` em ambiente limpo
- [ ] Verificar funcionamento do Adminer
- [ ] Confirmar execução das queries de exemplo
- [ ] Validar backup/restore
- [ ] Testar health check

### **Comandos de Emergência**
```bash
# Se algo der errado, reset completo
make clean
make entrega

# Verificação manual de serviços
docker-compose ps
docker logs district_zero_mysql
```

## 📊 Métricas de Sucesso

### **Indicadores de Funcionamento**
- ✅ Containers iniciados corretamente
- ✅ MySQL conectando sem erros
- ✅ Adminer acessível via navegador
- ✅ Queries executando com resultados
- ✅ Dados persistindo entre restarts

### **Benchmarks de Performance**
- **Tempo de inicialização**: ~30 segundos
- **Queries de exemplo**: <1 segundo cada
- **Backup completo**: ~5 segundos
- **Health check**: ~10 segundos

## 🎥 Estrutura do Vídeo (quando disponível)

### **Introdução (30 segundos)**
- Apresentação da equipe
- Objetivos do módulo 2
- Overview da solução

### **Demonstração Técnica (10 minutos)**
- Setup e inicialização
- Interface Adminer
- Execução de queries
- Funcionalidades do Makefile

### **Conclusão (30 segundos)**
- Resumo das vantagens
- Facilidade de uso
- Próximos passos

## 📚 Materiais de Apoio

### **Documentação Complementar**
- [Guia de Setup com Docker](setup-docker.md)
- [Implementação SQL](implementacao-sql.md)
- [Infraestrutura Docker](infraestrutura-docker.md)

### **Links Úteis**
- [Repositório no GitHub](https://github.com/SBD1/2025.1-District-ZER0)
- [Documentação Online](https://sbd1.github.io/2025.1-District-ZER0/)
- [README.md do Projeto](https://github.com/SBD1/2025.1-District-ZER0/blob/develop/README.md)

## Histórico de Versão

| Versão |    Data    |              Descrição              |                       Autor(es)                        |
| :----: | :--------: | :---------------------------------: | :----------------------------------------------------: |
| `1.0`  | 12/06/2025 | Criação da apresentação do módulo 2 | [Vinicius Vieira](https://github.com/viniciusvieira00) | 