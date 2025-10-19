# Consultas SQL Úteis - Sistema de Oficina Mecânica

## 📊 Consultas Frequentes para o Sistema

### 1. 🔍 Consultas de Cliente e Veículos

```sql
-- Listar todos os clientes ativos e seus veículos
SELECT 
    c.nome AS cliente,
    c.telefone,
    c.email,
    v.placa,
    v.marca,
    v.modelo,
    v.ano_modelo,
    v.quilometragem
FROM cliente c
LEFT JOIN veiculo v ON c.id_cliente = v.id_cliente
WHERE c.status_ativo = TRUE
ORDER BY c.nome, v.placa;

-- Buscar cliente por CPF/CNPJ
SELECT 
    nome,
    telefone,
    email,
    tipo_cliente,
    CONCAT(endereco_rua, ', ', endereco_numero, ' - ', endereco_cidade, '/', endereco_estado) AS endereco_completo
FROM cliente 
WHERE cpf_cnpj = '123.456.789-10';

-- Veículos que precisam de revisão (baseado na quilometragem)
SELECT 
    v.placa,
    v.marca,
    v.modelo,
    v.quilometragem,
    c.nome AS proprietario,
    c.telefone
FROM veiculo v
JOIN cliente c ON v.id_cliente = c.id_cliente
WHERE v.quilometragem >= 10000 
    AND v.quilometragem % 10000 BETWEEN 0 AND 1000
ORDER BY v.quilometragem DESC;
```

### 2. 📋 Consultas de Ordens de Serviço

```sql
-- Listar todas as OSs pendentes de autorização
SELECT 
    os.numero_os,
    os.data_emissao,
    c.nome AS cliente,
    v.placa,
    os.descricao_problema,
    os.valor_total,
    e.nome_equipe
FROM ordem_de_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN equipe e ON os.id_equipe = e.id_equipe
WHERE os.status_os = 'Pendente' 
    AND os.autorizacao_cliente = FALSE
ORDER BY os.data_emissao;

-- OSs em andamento com detalhes dos serviços
SELECT 
    os.numero_os,
    c.nome AS cliente,
    v.placa,
    s.nome_servico,
    oss.status_execucao,
    m.nome AS mecanico_responsavel,
    oss.tempo_executado_horas
FROM ordem_de_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN os_servico oss ON os.numero_os = oss.numero_os
JOIN servico s ON oss.id_servico = s.id_servico
LEFT JOIN mecanico m ON oss.mecanico_responsavel = m.codigo_mecanico
WHERE os.status_os = 'Em Andamento'
ORDER BY os.numero_os, s.nome_servico;

-- Relatório de OSs por período
SELECT 
    DATE_FORMAT(os.data_emissao, '%Y-%m') AS mes_ano,
    COUNT(*) AS total_os,
    COUNT(CASE WHEN os.status_os = 'Concluída' THEN 1 END) AS os_concluidas,
    SUM(CASE WHEN os.status_os = 'Concluída' THEN os.valor_total ELSE 0 END) AS faturamento_mes
FROM ordem_de_servico os
WHERE os.data_emissao >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(os.data_emissao, '%Y-%m')
ORDER BY mes_ano DESC;
```

### 3. 👥 Consultas de Equipes e Mecânicos

```sql
-- Listar mecânicos por especialidade
SELECT 
    especialidade,
    COUNT(*) as total_mecanicos,
    GROUP_CONCAT(nome SEPARATOR ', ') as mecanicos
FROM mecanico 
WHERE status_ativo = TRUE
GROUP BY especialidade
ORDER BY especialidade;

-- Produtividade dos mecânicos (OSs concluídas no último mês)
SELECT 
    m.nome,
    m.especialidade,
    COUNT(oss.numero_os) as servicos_executados,
    SUM(oss.tempo_executado_horas) as horas_trabalhadas,
    AVG(oss.valor_total) as valor_medio_servico
FROM mecanico m
LEFT JOIN os_servico oss ON m.codigo_mecanico = oss.mecanico_responsavel
LEFT JOIN ordem_de_servico os ON oss.numero_os = os.numero_os
WHERE os.data_conclusao_real >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
    AND m.status_ativo = TRUE
GROUP BY m.codigo_mecanico, m.nome, m.especialidade
ORDER BY servicos_executados DESC;

-- Equipes e seus membros ativos
SELECT 
    e.nome_equipe,
    m.nome AS mecanico,
    m.especialidade,
    me.funcao_na_equipe,
    me.data_entrada_equipe
FROM equipe e
JOIN mecanico_equipe me ON e.id_equipe = me.id_equipe
JOIN mecanico m ON me.id_mecanico = m.codigo_mecanico
WHERE e.status_ativa = TRUE 
    AND me.status_ativo = TRUE
    AND m.status_ativo = TRUE
ORDER BY e.nome_equipe, m.nome;
```

### 4. 📦 Consultas de Estoque e Peças

```sql
-- Relatório de estoque crítico
SELECT 
    p.codigo_peca,
    p.nome_peca,
    p.marca,
    p.estoque_atual,
    p.estoque_minimo,
    p.valor_unitario,
    (p.estoque_minimo - p.estoque_atual) AS quantidade_repor,
    (p.estoque_minimo - p.estoque_atual) * p.valor_unitario AS valor_reposicao
FROM peca p
WHERE p.estoque_atual <= p.estoque_minimo
    AND p.status_ativo = TRUE
ORDER BY (p.estoque_minimo - p.estoque_atual) DESC;

-- Peças mais utilizadas no último trimestre
SELECT 
    p.nome_peca,
    p.marca,
    SUM(op.quantidade_utilizada) as total_utilizado,
    COUNT(DISTINCT op.numero_os) as numero_os_utilizadas,
    AVG(op.valor_unitario) as valor_medio
FROM peca p
JOIN os_peca op ON p.id_peca = op.id_peca
JOIN ordem_de_servico os ON op.numero_os = os.numero_os
WHERE os.data_emissao >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
GROUP BY p.id_peca, p.nome_peca, p.marca
ORDER BY total_utilizado DESC
LIMIT 10;

-- Valor total do estoque por categoria
SELECT 
    SUBSTRING_INDEX(p.nome_peca, ' ', 1) AS categoria,
    COUNT(*) as quantidade_itens,
    SUM(p.estoque_atual * p.valor_unitario) as valor_total_estoque
FROM peca p
WHERE p.status_ativo = TRUE
GROUP BY categoria
ORDER BY valor_total_estoque DESC;
```

### 5. 💰 Consultas Financeiras

```sql
-- Faturamento mensal detalhado
SELECT 
    YEAR(os.data_conclusao_real) as ano,
    MONTH(os.data_conclusao_real) as mes,
    MONTHNAME(os.data_conclusao_real) as nome_mes,
    COUNT(*) as total_os,
    SUM(os.valor_mao_obra) as total_mao_obra,
    SUM(os.valor_pecas) as total_pecas,
    SUM(os.valor_total) as faturamento_total
FROM ordem_de_servico os
WHERE os.status_os = 'Concluída'
    AND os.data_conclusao_real >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
GROUP BY YEAR(os.data_conclusao_real), MONTH(os.data_conclusao_real)
ORDER BY ano DESC, mes DESC;

-- Top 10 clientes por faturamento
SELECT 
    c.nome,
    c.telefone,
    COUNT(os.numero_os) as total_os,
    SUM(os.valor_total) as faturamento_total,
    AVG(os.valor_total) as ticket_medio
FROM cliente c
JOIN veiculo v ON c.id_cliente = v.id_cliente
JOIN ordem_de_servico os ON v.id_veiculo = os.id_veiculo
WHERE os.status_os = 'Concluída'
    AND os.data_conclusao_real >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
GROUP BY c.id_cliente, c.nome, c.telefone
ORDER BY faturamento_total DESC
LIMIT 10;

-- Margem de lucro por tipo de serviço
SELECT 
    s.categoria,
    s.nome_servico,
    COUNT(oss.numero_os) as vezes_executado,
    AVG(oss.valor_unitario) as valor_medio_cobrado,
    AVG(s.valor_referencia) as valor_referencia,
    AVG(oss.valor_unitario - s.valor_referencia) as margem_media
FROM servico s
JOIN os_servico oss ON s.id_servico = oss.id_servico
JOIN ordem_de_servico os ON oss.numero_os = os.numero_os
WHERE os.status_os = 'Concluída'
    AND os.data_conclusao_real >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY s.id_servico, s.categoria, s.nome_servico
ORDER BY margem_media DESC;
```

### 6. 📈 Consultas de Análise e KPIs

```sql
-- Tempo médio de execução por tipo de serviço
SELECT 
    s.nome_servico,
    s.tempo_estimado_horas,
    AVG(oss.tempo_executado_horas) as tempo_medio_real,
    (AVG(oss.tempo_executado_horas) - s.tempo_estimado_horas) as diferenca_estimativa,
    COUNT(*) as total_execucoes
FROM servico s
JOIN os_servico oss ON s.id_servico = oss.id_servico
WHERE oss.tempo_executado_horas IS NOT NULL
    AND oss.status_execucao = 'Concluído'
GROUP BY s.id_servico, s.nome_servico, s.tempo_estimado_horas
ORDER BY total_execucoes DESC;

-- Taxa de autorização de OSs por equipe
SELECT 
    e.nome_equipe,
    COUNT(*) as total_os_criadas,
    COUNT(CASE WHEN os.autorizacao_cliente = TRUE THEN 1 END) as os_autorizadas,
    ROUND(
        (COUNT(CASE WHEN os.autorizacao_cliente = TRUE THEN 1 END) * 100.0 / COUNT(*)), 2
    ) as taxa_autorizacao_pct
FROM equipe e
JOIN ordem_de_servico os ON e.id_equipe = os.id_equipe
WHERE os.data_emissao >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
GROUP BY e.id_equipe, e.nome_equipe
ORDER BY taxa_autorizacao_pct DESC;

-- Análise de prazo de entrega
SELECT 
    CASE 
        WHEN DATEDIFF(os.data_conclusao_real, os.data_prevista_conclusao) <= 0 THEN 'No Prazo'
        WHEN DATEDIFF(os.data_conclusao_real, os.data_prevista_conclusao) <= 2 THEN 'Atraso Pequeno'
        ELSE 'Atraso Grande'
    END as categoria_prazo,
    COUNT(*) as quantidade,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ordem_de_servico WHERE status_os = 'Concluída')), 2) as percentual
FROM ordem_de_servico os
WHERE os.status_os = 'Concluída' 
    AND os.data_conclusao_real IS NOT NULL
GROUP BY categoria_prazo
ORDER BY quantidade DESC;
```

### 7. 🔍 Consultas de Auditoria e Controle

```sql
-- OSs sem autorização há mais de 7 dias
SELECT 
    os.numero_os,
    os.data_emissao,
    DATEDIFF(CURRENT_DATE, os.data_emissao) as dias_pendente,
    c.nome AS cliente,
    c.telefone,
    v.placa,
    os.valor_total
FROM ordem_de_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
WHERE os.autorizacao_cliente = FALSE
    AND os.status_os = 'Pendente'
    AND DATEDIFF(CURRENT_DATE, os.data_emissao) > 7
ORDER BY dias_pendente DESC;

-- Verificar consistência de valores nas OSs
SELECT 
    numero_os,
    valor_mao_obra,
    valor_pecas,
    valor_total,
    (valor_mao_obra + valor_pecas) as soma_calculada,
    CASE 
        WHEN ABS(valor_total - (valor_mao_obra + valor_pecas)) > 0.01 THEN 'INCONSISTENTE'
        ELSE 'OK'
    END as status_consistencia
FROM ordem_de_servico
WHERE status_os IN ('Concluída', 'Em Andamento')
HAVING status_consistencia = 'INCONSISTENTE';

-- Mecânicos sem atividade nos últimos 30 dias
SELECT 
    m.codigo_mecanico,
    m.nome,
    m.especialidade,
    m.data_contratacao,
    MAX(os.data_emissao) as ultima_os_participada
FROM mecanico m
LEFT JOIN os_servico oss ON m.codigo_mecanico = oss.mecanico_responsavel
LEFT JOIN ordem_de_servico os ON oss.numero_os = os.numero_os
WHERE m.status_ativo = TRUE
GROUP BY m.codigo_mecanico, m.nome, m.especialidade, m.data_contratacao
HAVING ultima_os_participada IS NULL 
    OR ultima_os_participada < DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
ORDER BY ultima_os_participada;
```

## 📋 Procedures Úteis para Operações Frequentes

```sql
-- Procedure para busca rápida de cliente
DELIMITER $$
CREATE PROCEDURE sp_buscar_cliente(IN p_criterio VARCHAR(100))
BEGIN
    SELECT 
        c.*,
        COUNT(v.id_veiculo) as total_veiculos
    FROM cliente c
    LEFT JOIN veiculo v ON c.id_cliente = v.id_cliente
    WHERE c.nome LIKE CONCAT('%', p_criterio, '%')
        OR c.cpf_cnpj LIKE CONCAT('%', p_criterio, '%')
        OR c.telefone LIKE CONCAT('%', p_criterio, '%')
    GROUP BY c.id_cliente
    ORDER BY c.nome;
END$$

-- Procedure para relatório completo da OS
CREATE PROCEDURE sp_relatorio_os(IN p_numero_os INT)
BEGIN
    -- Dados principais da OS
    SELECT 
        os.*,
        c.nome as cliente_nome,
        c.telefone as cliente_telefone,
        v.placa,
        v.marca,
        v.modelo,
        e.nome_equipe
    FROM ordem_de_servico os
    JOIN veiculo v ON os.id_veiculo = v.id_veiculo
    JOIN cliente c ON v.id_cliente = c.id_cliente
    JOIN equipe e ON os.id_equipe = e.id_equipe
    WHERE os.numero_os = p_numero_os;
    
    -- Serviços da OS
    SELECT 
        s.nome_servico,
        oss.quantidade,
        oss.valor_unitario,
        oss.valor_total,
        oss.status_execucao,
        m.nome as mecanico_responsavel
    FROM os_servico oss
    JOIN servico s ON oss.id_servico = s.id_servico
    LEFT JOIN mecanico m ON oss.mecanico_responsavel = m.codigo_mecanico
    WHERE oss.numero_os = p_numero_os;
    
    -- Peças utilizadas
    SELECT 
        p.nome_peca,
        p.marca,
        op.quantidade_utilizada,
        op.valor_unitario,
        op.valor_total
    FROM os_peca op
    JOIN peca p ON op.id_peca = p.id_peca
    WHERE op.numero_os = p_numero_os;
END$$
DELIMITER ;
```

## 🎯 Dicas de Performance

1. **Utilize sempre os índices criados** nas consultas com WHERE, JOIN e ORDER BY
2. **Para relatórios de grandes períodos**, considere criar tabelas de resumo
3. **Use LIMIT** em consultas que podem retornar muitos registros
4. **Para consultas frequentes**, considere criar views materializadas
5. **Monitore o plano de execução** das consultas mais utilizadas

## 📊 Exemplos de Uso das Views

```sql
-- Usando a view de resumo de OS
SELECT * FROM vw_resumo_os 
WHERE status_os = 'Em Andamento' 
ORDER BY data_emissao DESC;

-- Usando a view de mecânicos ativos
SELECT * FROM vw_mecanicos_ativos 
WHERE especialidade = 'Motor';

-- Usando a view de controle de estoque
SELECT * FROM vw_controle_estoque 
WHERE status_estoque IN ('CRÍTICO', 'BAIXO');
```

---

Essas consultas cobrem os principais cenários de uso do sistema de oficina mecânica e servem como base para desenvolvimento de relatórios e funcionalidades da aplicação.