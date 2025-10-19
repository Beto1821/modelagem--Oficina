# Glossário e Considerações Técnicas

## 📚 Glossário de Termos

### Termos do Negócio

| Termo | Definição | Observação |
|-------|-----------|------------|
| **OS (Ordem de Serviço)** | Documento que autoriza e controla a execução de serviços na oficina | Documento principal do sistema |
| **Cliente** | Proprietário do veículo que solicita serviços | Pode ser pessoa física ou jurídica |
| **Veículo** | Automóvel que recebe os serviços na oficina | Cada veículo pertence a um cliente |
| **Mecânico** | Profissional que executa os serviços mecânicos | Possui especialidade específica |
| **Equipe** | Grupo de mecânicos que trabalham juntos | Cada OS é atribuída a uma equipe |
| **Serviço** | Tipo de trabalho executado no veículo | Ex: troca de óleo, alinhamento |
| **Peça** | Componente físico utilizado nos serviços | Controlado por estoque |
| **Especialidade** | Área de conhecimento específico do mecânico | Motor, freios, suspensão, etc. |
| **Autorização** | Aprovação do cliente para execução dos serviços | Obrigatória antes do início |
| **Status** | Estado atual da OS | Pendente, aprovada, em andamento, etc. |

### Termos Técnicos de Banco de Dados

| Termo | Definição | Aplicação no Sistema |
|-------|-----------|---------------------|
| **Entidade** | Objeto do mundo real representado no BD | Cliente, Veículo, OS, etc. |
| **Atributo** | Propriedade de uma entidade | Nome, telefone, placa, etc. |
| **Relacionamento** | Associação entre entidades | Cliente possui Veículo |
| **Cardinalidade** | Quantificação do relacionamento | 1:N, N:M, 1:1 |
| **Chave Primária (PK)** | Identificador único da entidade | id_cliente, numero_os, etc. |
| **Chave Estrangeira (FK)** | Referência a outra entidade | id_cliente em veiculo |
| **Integridade Referencial** | Consistência entre tabelas relacionadas | FK deve existir na tabela pai |
| **Trigger** | Código executado automaticamente | Atualização de valores, controle estoque |
| **View** | Consulta salva como tabela virtual | Relatórios pré-definidos |
| **Procedure** | Rotina armazenada no banco | Operações complexas repetitivas |

## ⚙️ Considerações Técnicas de Implementação

### 1. Escolha do SGBD

**Recomendado**: MySQL 8.0+ ou PostgreSQL 13+

**Justificativas**:
- Suporte completo a transações ACID
- Recursos avançados de indexação
- Triggers e procedures armazenados
- Boa performance para aplicações de médio porte
- Ferramentas de backup e recuperação robustas

### 2. Normalização

O esquema foi projetado seguindo **3ª Forma Normal (3FN)**:

- ✅ **1FN**: Todos os atributos são atômicos
- ✅ **2FN**: Eliminação de dependências parciais
- ✅ **3FN**: Eliminação de dependências transitivas

**Benefícios**:
- Redução de redundância
- Consistência de dados
- Facilita manutenção
- Menor uso de espaço

### 3. Indexação Estratégica

**Índices Primários** (automáticos):
- Todas as chaves primárias

**Índices Secundários** (criados):
```sql
-- Busca de clientes
idx_cliente_cpf_cnpj
idx_cliente_nome

-- Busca de veículos
idx_veiculo_placa
idx_veiculo_cliente

-- Consultas de OS
idx_os_data_emissao
idx_os_status
idx_os_veiculo

-- Controle de estoque
idx_peca_codigo
idx_peca_estoque
```

### 4. Integridade de Dados

**Constraints Implementadas**:

```sql
-- Datas lógicas
CHECK (data_prevista_conclusao >= data_emissao)
CHECK (data_conclusao_real >= data_emissao OR data_conclusao_real IS NULL)

-- Valores financeiros
CHECK (valor_total = valor_mao_obra + valor_pecas)
CHECK (quantidade > 0)
CHECK (valor_unitario >= 0)

-- Estoque
CHECK (estoque_atual >= 0)
CHECK (estoque_minimo >= 0)

-- Autorização
CHECK (autorizacao_cliente = FALSE OR data_autorizacao IS NOT NULL)
```

### 5. Controle de Concorrência

**Estratégias Implementadas**:

1. **Controle de Estoque**:
   ```sql
   -- Trigger previne estoque negativo
   IF (SELECT estoque_atual FROM peca WHERE id_peca = NEW.id_peca) < 0 THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente';
   END IF;
   ```

2. **Bloqueio de Registros**:
   - Usar `SELECT ... FOR UPDATE` em operações críticas
   - Transações curtas para minimizar bloqueios

### 6. Performance e Escalabilidade

**Otimizações Implementadas**:

1. **Particionamento** (para grandes volumes):
   ```sql
   -- Particionamento por data da OS
   PARTITION BY RANGE (YEAR(data_emissao)) (
       PARTITION p2023 VALUES LESS THAN (2024),
       PARTITION p2024 VALUES LESS THAN (2025),
       PARTITION p2025 VALUES LESS THAN (2026)
   );
   ```

2. **Arquivamento de Dados**:
   - OSs antigas (> 2 anos) movidas para tabela de histórico
   - Manter apenas dados operacionais ativos

3. **Cache de Consultas**:
   - Views materializadas para relatórios
   - Cache em aplicação para dados estáticos

### 7. Backup e Recuperação

**Estratégia Recomendada**:

1. **Backup Completo**: Semanal
2. **Backup Incremental**: Diário
3. **Log de Transações**: Contínuo
4. **Teste de Recuperação**: Mensal

```bash
# Exemplo de backup MySQL
mysqldump --single-transaction --routines --triggers \
  --databases oficina_mecanica > backup_oficina.sql

# Backup incremental com binlog
mysqlbinlog --start-datetime="2025-10-19 00:00:00" \
  mysql-bin.000001 > backup_incremental.sql
```

## 🔒 Considerações de Segurança

### 1. Controle de Acesso

**Perfis de Usuário Sugeridos**:

```sql
-- Administrador (acesso total)
CREATE USER 'admin_oficina'@'localhost' IDENTIFIED BY 'senha_forte';
GRANT ALL PRIVILEGES ON oficina_mecanica.* TO 'admin_oficina'@'localhost';

-- Atendente (consulta e criação de OS)
CREATE USER 'atendente'@'localhost' IDENTIFIED BY 'senha_forte';
GRANT SELECT, INSERT ON oficina_mecanica.cliente TO 'atendente'@'localhost';
GRANT SELECT, INSERT ON oficina_mecanica.veiculo TO 'atendente'@'localhost';
GRANT SELECT, INSERT, UPDATE ON oficina_mecanica.ordem_de_servico TO 'atendente'@'localhost';

-- Mecânico (atualização de serviços)
CREATE USER 'mecanico'@'localhost' IDENTIFIED BY 'senha_forte';
GRANT SELECT ON oficina_mecanica.* TO 'mecanico'@'localhost';
GRANT UPDATE ON oficina_mecanica.os_servico TO 'mecanico'@'localhost';
GRANT UPDATE ON oficina_mecanica.os_peca TO 'mecanico'@'localhost';

-- Relatórios (apenas consulta)
CREATE USER 'relatorio'@'localhost' IDENTIFIED BY 'senha_forte';
GRANT SELECT ON oficina_mecanica.* TO 'relatorio'@'localhost';
```

### 2. Auditoria

**Log de Alterações** (implementação sugerida):

```sql
-- Tabela de auditoria
CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50),
    operacao ENUM('INSERT', 'UPDATE', 'DELETE'),
    usuario VARCHAR(50),
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valores_antigos JSON,
    valores_novos JSON
);

-- Trigger de auditoria (exemplo para cliente)
DELIMITER $$
CREATE TRIGGER tr_audit_cliente_update
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabela_afetada, operacao, usuario, valores_antigos, valores_novos)
    VALUES ('cliente', 'UPDATE', USER(), 
            JSON_OBJECT('nome', OLD.nome, 'telefone', OLD.telefone),
            JSON_OBJECT('nome', NEW.nome, 'telefone', NEW.telefone));
END$$
DELIMITER ;
```

### 3. Criptografia

**Dados Sensíveis**:
- CPF/CNPJ: Criptografia reversível (AES-256)
- Senhas: Hash irreversível (bcrypt)
- Dados PCI se cartão: Tokenização

## 📊 Métricas e Monitoramento

### 1. KPIs de Negócio

```sql
-- Tempo médio de conclusão de OS
SELECT AVG(DATEDIFF(data_conclusao_real, data_emissao)) as tempo_medio_dias
FROM ordem_de_servico 
WHERE status_os = 'Concluída';

-- Taxa de conversão (autorização)
SELECT 
    (COUNT(CASE WHEN autorizacao_cliente = TRUE THEN 1 END) * 100.0 / COUNT(*)) as taxa_conversao
FROM ordem_de_servico;

-- Faturamento por mecânico
SELECT 
    m.nome,
    SUM(oss.valor_total) as faturamento_gerado
FROM mecanico m
JOIN os_servico oss ON m.codigo_mecanico = oss.mecanico_responsavel
JOIN ordem_de_servico os ON oss.numero_os = os.numero_os
WHERE os.status_os = 'Concluída'
GROUP BY m.codigo_mecanico, m.nome;
```

### 2. Métricas Técnicas

**Monitoramento Sugerido**:
- Tempo de resposta das consultas principais
- Uso de CPU e memória do SGBD
- Espaço em disco utilizado
- Número de conexões ativas
- Taxa de cache hits

```sql
-- Consultas lentas (MySQL)
SELECT 
    sql_text,
    avg_timer_wait/1000000000 as avg_time_sec,
    count_star as executions
FROM performance_schema.events_statements_summary_by_digest
ORDER BY avg_timer_wait DESC
LIMIT 10;
```

## 🚀 Próximas Etapas de Implementação

### Fase 1: Implementação Base
- [ ] Criação do banco de dados
- [ ] Implementação das tabelas principais
- [ ] Triggers básicos
- [ ] Dados de teste

### Fase 2: Funcionalidades Avançadas
- [ ] Procedures armazenadas
- [ ] Views de relatórios
- [ ] Sistema de auditoria
- [ ] Controle de usuários

### Fase 3: Otimização
- [ ] Análise de performance
- [ ] Ajuste de índices
- [ ] Implementação de cache
- [ ] Estratégia de backup

### Fase 4: Integração
- [ ] API REST para aplicação
- [ ] Sistema de notificações
- [ ] Integração com sistemas externos
- [ ] Dashboard de métricas

## 📋 Checklist de Implementação

### ✅ Pré-Produção
- [ ] Validação do modelo com usuários
- [ ] Testes de carga
- [ ] Plano de contingência
- [ ] Documentação completa
- [ ] Treinamento da equipe

### ✅ Produção
- [ ] Deploy em ambiente controlado
- [ ] Monitoramento ativo
- [ ] Backup configurado
- [ ] Suporte técnico disponível
- [ ] Plano de rollback

### ✅ Pós-Implementação
- [ ] Coleta de métricas
- [ ] Feedback dos usuários
- [ ] Otimizações necessárias
- [ ] Planejamento de evoluções
- [ ] Documentação de lições aprendidas

---

Este documento serve como guia técnico para a implementação e manutenção do sistema de banco de dados da oficina mecânica, garantindo robustez, performance e escalabilidade.