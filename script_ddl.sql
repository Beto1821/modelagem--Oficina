-- ====================================================
-- SCRIPT DDL - SISTEMA DE OFICINA MECÂNICA
-- ====================================================
-- Autor: Sistema de Gerenciamento de Oficina
-- Data: Outubro 2025
-- Objetivo: Criação da estrutura física do banco de dados
-- SGBD: MySQL/PostgreSQL (compatível)
-- ====================================================

-- Configurações iniciais
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- ====================================================
-- CRIAÇÃO DO SCHEMA
-- ====================================================
CREATE SCHEMA IF NOT EXISTS oficina_mecanica DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE oficina_mecanica;

-- ====================================================
-- TABELA: CLIENTE
-- ====================================================
CREATE TABLE IF NOT EXISTS cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(18) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    endereco_rua VARCHAR(150) NOT NULL,
    endereco_numero VARCHAR(10) NOT NULL,
    endereco_cidade VARCHAR(50) NOT NULL,
    endereco_estado CHAR(2) NOT NULL,
    endereco_cep VARCHAR(10) NOT NULL,
    tipo_cliente ENUM('Pessoa Física', 'Pessoa Jurídica') NOT NULL DEFAULT 'Pessoa Física',
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    INDEX idx_cliente_cpf_cnpj (cpf_cnpj),
    INDEX idx_cliente_nome (nome),
    INDEX idx_cliente_status (status_ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: VEÍCULO
-- ====================================================
CREATE TABLE IF NOT EXISTS veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(30) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano_fabricacao YEAR NOT NULL,
    ano_modelo YEAR NOT NULL,
    cor VARCHAR(20) NOT NULL,
    quilometragem INT NOT NULL DEFAULT 0,
    numero_chassi VARCHAR(17) UNIQUE,
    combustivel ENUM('Gasolina', 'Álcool', 'Flex', 'Diesel', 'GNV', 'Elétrico', 'Híbrido') NOT NULL,
    id_cliente INT NOT NULL,
    data_cadastro DATE NOT NULL DEFAULT (CURRENT_DATE),
    
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    INDEX idx_veiculo_placa (placa),
    INDEX idx_veiculo_cliente (id_cliente),
    INDEX idx_veiculo_marca_modelo (marca, modelo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: MECÂNICO
-- ====================================================
CREATE TABLE IF NOT EXISTS mecanico (
    codigo_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(15) NOT NULL,
    endereco_rua VARCHAR(150) NOT NULL,
    endereco_numero VARCHAR(10) NOT NULL,
    endereco_cidade VARCHAR(50) NOT NULL,
    endereco_estado CHAR(2) NOT NULL,
    endereco_cep VARCHAR(10) NOT NULL,
    especialidade ENUM('Motor', 'Suspensão', 'Freios', 'Elétrica', 'Pintura', 'Funilaria', 'Ar Condicionado') NOT NULL,
    salario DECIMAL(8,2) NOT NULL,
    data_contratacao DATE NOT NULL,
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    INDEX idx_mecanico_cpf (cpf),
    INDEX idx_mecanico_especialidade (especialidade),
    INDEX idx_mecanico_status (status_ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: EQUIPE
-- ====================================================
CREATE TABLE IF NOT EXISTS equipe (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(50) NOT NULL,
    descricao TEXT,
    data_formacao DATE NOT NULL,
    lider_equipe INT,
    status_ativa BOOLEAN NOT NULL DEFAULT TRUE,
    
    FOREIGN KEY (lider_equipe) REFERENCES mecanico(codigo_mecanico) ON DELETE SET NULL ON UPDATE CASCADE,
    
    INDEX idx_equipe_lider (lider_equipe),
    INDEX idx_equipe_status (status_ativa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: TABELA_REFERENCIA_MAO_OBRA
-- ====================================================
CREATE TABLE IF NOT EXISTS tabela_referencia_mao_obra (
    id_referencia INT AUTO_INCREMENT PRIMARY KEY,
    tipo_servico VARCHAR(50) NOT NULL,
    especialidade_requerida ENUM('Motor', 'Suspensão', 'Freios', 'Elétrica', 'Pintura', 'Funilaria', 'Ar Condicionado') NOT NULL,
    valor_hora_base DECIMAL(8,2) NOT NULL,
    multiplicador_complexidade DECIMAL(3,2) NOT NULL DEFAULT 1.00,
    tempo_padrao_horas DECIMAL(4,2) NOT NULL,
    data_vigencia_inicio DATE NOT NULL,
    data_vigencia_fim DATE,
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    INDEX idx_referencia_tipo_servico (tipo_servico),
    INDEX idx_referencia_especialidade (especialidade_requerida),
    INDEX idx_referencia_vigencia (data_vigencia_inicio, data_vigencia_fim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: SERVIÇO
-- ====================================================
CREATE TABLE IF NOT EXISTS servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    nome_servico VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    categoria VARCHAR(30) NOT NULL,
    tempo_estimado_horas DECIMAL(4,2) NOT NULL,
    valor_referencia DECIMAL(8,2) NOT NULL,
    complexidade TINYINT NOT NULL CHECK (complexidade BETWEEN 1 AND 5),
    requer_especializacao BOOLEAN NOT NULL DEFAULT FALSE,
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    id_referencia_mao_obra INT,
    
    FOREIGN KEY (id_referencia_mao_obra) REFERENCES tabela_referencia_mao_obra(id_referencia) ON DELETE SET NULL ON UPDATE CASCADE,
    
    INDEX idx_servico_categoria (categoria),
    INDEX idx_servico_complexidade (complexidade),
    INDEX idx_servico_status (status_ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: PEÇA
-- ====================================================
CREATE TABLE IF NOT EXISTS peca (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    codigo_peca VARCHAR(20) NOT NULL UNIQUE,
    nome_peca VARCHAR(100) NOT NULL,
    descricao TEXT,
    marca VARCHAR(30) NOT NULL,
    modelo_compativel TEXT,
    valor_unitario DECIMAL(10,2) NOT NULL,
    estoque_atual INT NOT NULL DEFAULT 0,
    estoque_minimo INT NOT NULL DEFAULT 0,
    unidade_medida VARCHAR(10) NOT NULL DEFAULT 'pç',
    localizacao_estoque VARCHAR(20),
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    INDEX idx_peca_codigo (codigo_peca),
    INDEX idx_peca_nome (nome_peca),
    INDEX idx_peca_marca (marca),
    INDEX idx_peca_estoque (estoque_atual),
    INDEX idx_peca_status (status_ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA: ORDEM_DE_SERVIÇO
-- ====================================================
CREATE TABLE IF NOT EXISTS ordem_de_servico (
    numero_os INT AUTO_INCREMENT PRIMARY KEY,
    data_emissao DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_prevista_conclusao DATE NOT NULL,
    data_conclusao_real DATE,
    valor_mao_obra DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_pecas DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    descricao_problema TEXT NOT NULL,
    observacoes TEXT,
    status_os ENUM('Pendente', 'Aprovada', 'Em Andamento', 'Concluída', 'Cancelada') NOT NULL DEFAULT 'Pendente',
    autorizacao_cliente BOOLEAN NOT NULL DEFAULT FALSE,
    data_autorizacao DATE,
    id_veiculo INT NOT NULL,
    id_equipe INT NOT NULL,
    
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe) ON DELETE RESTRICT ON UPDATE CASCADE,
    
    CHECK (data_prevista_conclusao >= data_emissao),
    CHECK (data_conclusao_real IS NULL OR data_conclusao_real >= data_emissao),
    CHECK (valor_total = valor_mao_obra + valor_pecas),
    CHECK (autorizacao_cliente = FALSE OR data_autorizacao IS NOT NULL),
    
    INDEX idx_os_data_emissao (data_emissao),
    INDEX idx_os_status (status_os),
    INDEX idx_os_veiculo (id_veiculo),
    INDEX idx_os_equipe (id_equipe),
    INDEX idx_os_autorizacao (autorizacao_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA ASSOCIATIVA: MECANICO_EQUIPE
-- ====================================================
CREATE TABLE IF NOT EXISTS mecanico_equipe (
    id_mecanico INT NOT NULL,
    id_equipe INT NOT NULL,
    data_entrada_equipe DATE NOT NULL DEFAULT (CURRENT_DATE),
    data_saida_equipe DATE,
    funcao_na_equipe VARCHAR(30) NOT NULL DEFAULT 'Mecânico',
    status_ativo BOOLEAN NOT NULL DEFAULT TRUE,
    
    PRIMARY KEY (id_mecanico, id_equipe),
    
    FOREIGN KEY (id_mecanico) REFERENCES mecanico(codigo_mecanico) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES equipe(id_equipe) ON DELETE CASCADE ON UPDATE CASCADE,
    
    CHECK (data_saida_equipe IS NULL OR data_saida_equipe >= data_entrada_equipe),
    
    INDEX idx_mecanico_equipe_data_entrada (data_entrada_equipe),
    INDEX idx_mecanico_equipe_status (status_ativo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA ASSOCIATIVA: OS_SERVIÇO
-- ====================================================
CREATE TABLE IF NOT EXISTS os_servico (
    numero_os INT NOT NULL,
    id_servico INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(8,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    tempo_executado_horas DECIMAL(4,2),
    observacoes TEXT,
    status_execucao ENUM('Pendente', 'Em Andamento', 'Concluído', 'Cancelado') NOT NULL DEFAULT 'Pendente',
    mecanico_responsavel INT,
    
    PRIMARY KEY (numero_os, id_servico),
    
    FOREIGN KEY (numero_os) REFERENCES ordem_de_servico(numero_os) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES servico(id_servico) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (mecanico_responsavel) REFERENCES mecanico(codigo_mecanico) ON DELETE SET NULL ON UPDATE CASCADE,
    
    CHECK (quantidade > 0),
    CHECK (valor_unitario >= 0),
    CHECK (valor_total = quantidade * valor_unitario),
    CHECK (tempo_executado_horas IS NULL OR tempo_executado_horas >= 0),
    
    INDEX idx_os_servico_status (status_execucao),
    INDEX idx_os_servico_mecanico (mecanico_responsavel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TABELA ASSOCIATIVA: OS_PEÇA
-- ====================================================
CREATE TABLE IF NOT EXISTS os_peca (
    numero_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade_utilizada INT NOT NULL,
    valor_unitario DECIMAL(8,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    data_aplicacao DATE,
    mecanico_aplicador INT,
    observacoes TEXT,
    
    PRIMARY KEY (numero_os, id_peca),
    
    FOREIGN KEY (numero_os) REFERENCES ordem_de_servico(numero_os) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_peca) REFERENCES peca(id_peca) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (mecanico_aplicador) REFERENCES mecanico(codigo_mecanico) ON DELETE SET NULL ON UPDATE CASCADE,
    
    CHECK (quantidade_utilizada > 0),
    CHECK (valor_unitario >= 0),
    CHECK (valor_total = quantidade_utilizada * valor_unitario),
    
    INDEX idx_os_peca_data_aplicacao (data_aplicacao),
    INDEX idx_os_peca_mecanico (mecanico_aplicador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================
-- TRIGGERS PARA CONTROLE AUTOMÁTICO
-- ====================================================

-- Trigger para atualizar valor total da OS automaticamente
DELIMITER $$
CREATE TRIGGER tr_atualizar_valor_os_servico
AFTER INSERT ON os_servico
FOR EACH ROW
BEGIN
    UPDATE ordem_de_servico 
    SET valor_mao_obra = (
        SELECT COALESCE(SUM(valor_total), 0) 
        FROM os_servico 
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
END$$

CREATE TRIGGER tr_atualizar_valor_os_peca
AFTER INSERT ON os_peca
FOR EACH ROW
BEGIN
    UPDATE ordem_de_servico 
    SET valor_pecas = (
        SELECT COALESCE(SUM(valor_total), 0) 
        FROM os_peca 
        WHERE numero_os = NEW.numero_os
    ),
    valor_total = valor_mao_obra + valor_pecas
    WHERE numero_os = NEW.numero_os;
END$$

-- Trigger para controlar estoque das peças
CREATE TRIGGER tr_controlar_estoque_peca
AFTER INSERT ON os_peca
FOR EACH ROW
BEGIN
    UPDATE peca 
    SET estoque_atual = estoque_atual - NEW.quantidade_utilizada
    WHERE id_peca = NEW.id_peca;
    
    -- Verificar se estoque ficou negativo
    IF (SELECT estoque_atual FROM peca WHERE id_peca = NEW.id_peca) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente para a peça solicitada';
    END IF;
END$$
DELIMITER ;

-- ====================================================
-- VIEWS PARA RELATÓRIOS
-- ====================================================

-- View para resumo de ordens de serviço
CREATE OR REPLACE VIEW vw_resumo_os AS
SELECT 
    os.numero_os,
    os.data_emissao,
    os.data_prevista_conclusao,
    os.status_os,
    c.nome AS cliente_nome,
    v.placa,
    v.marca,
    v.modelo,
    e.nome_equipe,
    os.valor_total,
    os.autorizacao_cliente
FROM ordem_de_servico os
JOIN veiculo v ON os.id_veiculo = v.id_veiculo
JOIN cliente c ON v.id_cliente = c.id_cliente
JOIN equipe e ON os.id_equipe = e.id_equipe;

-- View para mecânicos e suas especialidades
CREATE OR REPLACE VIEW vw_mecanicos_ativos AS
SELECT 
    m.codigo_mecanico,
    m.nome,
    m.especialidade,
    m.telefone,
    GROUP_CONCAT(eq.nome_equipe SEPARATOR ', ') AS equipes
FROM mecanico m
LEFT JOIN mecanico_equipe me ON m.codigo_mecanico = me.id_mecanico AND me.status_ativo = TRUE
LEFT JOIN equipe eq ON me.id_equipe = eq.id_equipe
WHERE m.status_ativo = TRUE
GROUP BY m.codigo_mecanico, m.nome, m.especialidade, m.telefone;

-- View para controle de estoque
CREATE OR REPLACE VIEW vw_controle_estoque AS
SELECT 
    p.codigo_peca,
    p.nome_peca,
    p.marca,
    p.estoque_atual,
    p.estoque_minimo,
    p.valor_unitario,
    CASE 
        WHEN p.estoque_atual <= p.estoque_minimo THEN 'CRÍTICO'
        WHEN p.estoque_atual <= (p.estoque_minimo * 1.5) THEN 'BAIXO'
        ELSE 'OK'
    END AS status_estoque
FROM peca p
WHERE p.status_ativo = TRUE
ORDER BY p.estoque_atual ASC;

-- ====================================================
-- INSERÇÃO DE DADOS INICIAIS DE EXEMPLO
-- ====================================================

-- Inserir especialidades na tabela de referência
INSERT INTO tabela_referencia_mao_obra (tipo_servico, especialidade_requerida, valor_hora_base, multiplicador_complexidade, tempo_padrao_horas, data_vigencia_inicio) VALUES
('Troca de Óleo', 'Motor', 45.00, 1.0, 0.5, '2025-01-01'),
('Alinhamento', 'Suspensão', 60.00, 1.2, 1.0, '2025-01-01'),
('Troca de Pastilha de Freio', 'Freios', 55.00, 1.1, 1.5, '2025-01-01'),
('Revisão Sistema Elétrico', 'Elétrica', 65.00, 1.3, 2.0, '2025-01-01'),
('Pintura Completa', 'Pintura', 50.00, 1.8, 8.0, '2025-01-01');

-- Inserir alguns serviços básicos
INSERT INTO servico (nome_servico, descricao, categoria, tempo_estimado_horas, valor_referencia, complexidade, requer_especializacao, id_referencia_mao_obra) VALUES
('Troca de Óleo e Filtro', 'Substituição do óleo do motor e filtro de óleo', 'Manutenção', 0.5, 22.50, 1, FALSE, 1),
('Alinhamento e Balanceamento', 'Alinhamento das rodas e balanceamento dos pneus', 'Suspensão', 1.0, 72.00, 2, TRUE, 2),
('Troca de Pastilhas de Freio', 'Substituição das pastilhas de freio dianteiras', 'Freios', 1.5, 82.50, 2, TRUE, 3),
('Revisão do Sistema Elétrico', 'Verificação completa do sistema elétrico do veículo', 'Elétrica', 2.0, 130.00, 3, TRUE, 4),
('Pintura Completa do Veículo', 'Pintura completa da carroceria', 'Estética', 8.0, 400.00, 5, TRUE, 5);

-- Inserir algumas peças básicas
INSERT INTO peca (codigo_peca, nome_peca, descricao, marca, valor_unitario, estoque_atual, estoque_minimo) VALUES
('OL001', 'Óleo Motor 5W30', 'Óleo lubrificante sintético para motor', 'Mobil', 45.90, 50, 10),
('FL001', 'Filtro de Óleo', 'Filtro de óleo para motores 1.0 a 2.0', 'Mann', 18.50, 30, 5),
('PF001', 'Pastilha Freio Dianteira', 'Pastilha de freio cerâmica dianteira', 'Bosch', 89.90, 20, 4),
('PF002', 'Pastilha Freio Traseira', 'Pastilha de freio cerâmica traseira', 'Bosch', 75.50, 15, 3),
('VL001', 'Vela de Ignição', 'Vela de ignição iridium', 'NGK', 32.90, 40, 8);

-- ====================================================
-- PROCEDIMENTOS ARMAZENADOS
-- ====================================================

DELIMITER $$

-- Procedure para criar nova OS
CREATE PROCEDURE sp_criar_os(
    IN p_id_veiculo INT,
    IN p_id_equipe INT,
    IN p_descricao_problema TEXT,
    IN p_data_prevista_conclusao DATE
)
BEGIN
    DECLARE v_numero_os INT;
    
    INSERT INTO ordem_de_servico (id_veiculo, id_equipe, descricao_problema, data_prevista_conclusao)
    VALUES (p_id_veiculo, p_id_equipe, p_descricao_problema, p_data_prevista_conclusao);
    
    SET v_numero_os = LAST_INSERT_ID();
    
    SELECT v_numero_os AS numero_os_criada;
END$$

-- Procedure para autorizar OS
CREATE PROCEDURE sp_autorizar_os(
    IN p_numero_os INT
)
BEGIN
    UPDATE ordem_de_servico 
    SET autorizacao_cliente = TRUE,
        data_autorizacao = CURRENT_DATE,
        status_os = 'Aprovada'
    WHERE numero_os = p_numero_os;
    
    SELECT 'OS autorizada com sucesso' AS resultado;
END$$

DELIMITER ;

-- ====================================================
-- RESTAURAR CONFIGURAÇÕES
-- ====================================================
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- ====================================================
-- COMENTÁRIOS FINAIS
-- ====================================================
/*
Este script DDL cria a estrutura completa do banco de dados para o sistema de oficina mecânica.

CARACTERÍSTICAS IMPLEMENTADAS:
1. Todas as entidades identificadas no modelo conceitual
2. Relacionamentos com integridade referencial
3. Triggers para automação de cálculos e controle de estoque
4. Views para relatórios comuns
5. Procedimentos armazenados para operações frequentes
6. Índices para otimização de consultas
7. Constraints para garantir consistência dos dados
8. Dados iniciais de exemplo

PRÓXIMOS PASSOS:
1. Executar este script em um SGBD MySQL/MariaDB
2. Configurar usuários e permissões
3. Implementar rotinas de backup
4. Desenvolver aplicação frontend para interação
5. Criar relatórios adicionais conforme necessidade

MANUTENÇÃO:
- Revisar periodicamente os valores da tabela de referência de mão-de-obra
- Monitorar performance das consultas e ajustar índices se necessário
- Implementar arquivamento de OSs antigas para manter performance
*/