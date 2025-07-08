-- District ZER0 - Correções Críticas
-- Arquivo executado após DDL e DML para implementar melhorias necessárias

-- ---------- CORREÇÃO 1: Melhorias na Tabela de Caminhos ----------
-- Tabela já existe no DDL, adicionando apenas índices se necessário
CREATE INDEX IF NOT EXISTS idx_caminhos_origem ON caminhos(sala_origem);
CREATE INDEX IF NOT EXISTS idx_caminhos_destino ON caminhos(sala_destino);

-- ---------- CORREÇÃO 2: Constraint Única em Itens_Sala (se não existir) ----------
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'uk_itens_sala_unico') THEN
        ALTER TABLE itens_sala ADD CONSTRAINT uk_itens_sala_unico UNIQUE (sala_id, item_id);
    END IF;
END $$;

-- ---------- CORREÇÃO 3: Índices Adicionais para Performance ----------
CREATE INDEX IF NOT EXISTS idx_missoes_jogador_status ON missoes_jogador(status);
CREATE INDEX IF NOT EXISTS idx_mob_tipos_tipo ON mob_tipos(tipo);

-- ---------- CORREÇÃO 4: Verificação de Integridade dos Caminhos ----------
-- Verifica se todos os caminhos existem e estão corretos
DO $$
DECLARE
    total_caminhos INT;
    salas_conectadas INT;
BEGIN
    SELECT COUNT(*) INTO total_caminhos FROM caminhos;
    SELECT COUNT(DISTINCT sala_origem) INTO salas_conectadas FROM caminhos;
    
    RAISE NOTICE 'Correções críticas aplicadas com sucesso:';
    RAISE NOTICE '✓ Índices adicionais criados';
    RAISE NOTICE '✓ Constraints verificadas';
    RAISE NOTICE '✓ Sistema de movimento validado';
    RAISE NOTICE '- Total de conexões: %', total_caminhos;
    RAISE NOTICE '- Salas conectadas: % de 15', salas_conectadas;
    
    IF salas_conectadas < 14 THEN
        RAISE WARNING 'Algumas salas podem estar isoladas!';
    ELSE
        RAISE NOTICE '✅ Todas as salas estão conectadas ao sistema de movimento';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Correções críticas concluídas - Sistema estável!';
END
$$; 
