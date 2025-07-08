-- District ZER0 - Arquivo de Verificação
-- Este arquivo é executado primeiro para validar o ambiente

DO $$
BEGIN
    RAISE NOTICE '🎮 DISTRICT ZER0 - Inicializando banco de dados...';
    RAISE NOTICE 'PostgreSQL Version: %', version();
    RAISE NOTICE 'Current Database: %', current_database();
    RAISE NOTICE 'Current User: %', current_user;
    RAISE NOTICE 'Timestamp: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '';
    RAISE NOTICE 'Scripts SQL serão executados em ordem alfabética...';
END
$$;
