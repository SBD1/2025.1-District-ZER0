-- District ZER0 - Script de Inicialização
-- Este arquivo é executado automaticamente pelo MySQL quando o container é iniciado pela primeira vez

-- Executa o DDL primeiro
SOURCE /docker-entrypoint-initdb.d/DDL_mysql.sql;

-- Depois executa o DML
SOURCE /docker-entrypoint-initdb.d/DML_mysql.sql; 