# Esquema Conceitual - Sistema de Oficina Mecânica

## 📋 Modelo Conceitual Detalhado

### 🏢 Entidades e Atributos

#### 1. CLIENTE
```
CLIENTE {
    id_cliente (PK)          - Identificador único do cliente
    nome                     - Nome completo do cliente
    cpf_cnpj                 - CPF (pessoa física) ou CNPJ (pessoa jurídica)
    telefone                 - Número de contato
    email                    - Endereço de e-mail
    endereco_rua             - Logradouro
    endereco_numero          - Número do endereço
    endereco_cidade          - Cidade
    endereco_estado          - Estado/UF
    endereco_cep             - Código postal
    tipo_cliente             - Pessoa Física ou Jurídica
    data_cadastro            - Data de cadastro no sistema
    status_ativo             - Se o cliente está ativo
}
```

#### 2. VEÍCULO
```
VEÍCULO {
    id_veiculo (PK)          - Identificador único do veículo
    placa                    - Placa do veículo (único)
    marca                    - Marca do veículo
    modelo                   - Modelo do veículo
    ano_fabricacao           - Ano de fabricação
    ano_modelo               - Ano do modelo
    cor                      - Cor do veículo
    quilometragem            - Quilometragem atual
    numero_chassi            - Número do chassi
    combustivel              - Tipo de combustível
    id_cliente (FK)          - Referência ao proprietário
    data_cadastro            - Data de cadastro do veículo
}
```

#### 3. MECÂNICO
```
MECÂNICO {
    codigo_mecanico (PK)     - Código único do mecânico
    nome                     - Nome completo do mecânico
    cpf                      - CPF do mecânico
    telefone                 - Número de contato
    endereco_rua             - Logradouro
    endereco_numero          - Número do endereço
    endereco_cidade          - Cidade
    endereco_estado          - Estado/UF
    endereco_cep             - Código postal
    especialidade            - Área de especialização
    salario                  - Salário do mecânico
    data_contratacao         - Data de contratação
    status_ativo             - Se o mecânico está ativo
}
```

#### 4. EQUIPE
```
EQUIPE {
    id_equipe (PK)           - Identificador único da equipe
    nome_equipe              - Nome da equipe
    descricao                - Descrição da equipe
    data_formacao            - Data de formação da equipe
    lider_equipe (FK)        - Mecânico líder da equipe
    status_ativa             - Se a equipe está ativa
}
```

#### 5. ORDEM_DE_SERVIÇO
```
ORDEM_DE_SERVIÇO {
    numero_os (PK)           - Número único da ordem de serviço
    data_emissao             - Data de emissão da OS
    data_prevista_conclusao  - Data prevista para conclusão
    data_conclusao_real      - Data real de conclusão
    valor_mao_obra           - Valor total da mão-de-obra
    valor_pecas              - Valor total das peças
    valor_total              - Valor total da OS
    descricao_problema       - Descrição do problema relatado
    observacoes              - Observações gerais
    status_os                - Status da ordem de serviço
    autorizacao_cliente      - Se o cliente autorizou a execução
    data_autorizacao         - Data da autorização do cliente
    id_veiculo (FK)          - Referência ao veículo
    id_equipe (FK)           - Referência à equipe responsável
}
```

#### 6. SERVIÇO
```
SERVIÇO {
    id_servico (PK)          - Identificador único do serviço
    nome_servico             - Nome do serviço
    descricao                - Descrição detalhada do serviço
    categoria                - Categoria do serviço
    tempo_estimado_horas     - Tempo estimado em horas
    valor_referencia         - Valor de referência do serviço
    complexidade             - Nível de complexidade (1-5)
    requer_especializacao    - Se requer especialização específica
    status_ativo             - Se o serviço está ativo no catálogo
}
```

#### 7. PEÇA
```
PEÇA {
    id_peca (PK)             - Identificador único da peça
    codigo_peca              - Código da peça (pode ser do fornecedor)
    nome_peca                - Nome da peça
    descricao                - Descrição da peça
    marca                    - Marca da peça
    modelo_compativel        - Modelos de veículos compatíveis
    valor_unitario           - Valor unitário da peça
    estoque_atual            - Quantidade atual em estoque
    estoque_minimo           - Estoque mínimo para reposição
    unidade_medida           - Unidade de medida (pç, kg, m, etc.)
    localizacao_estoque      - Localização no estoque
    status_ativo             - Se a peça está ativa no catálogo
}
```

#### 8. TABELA_REFERENCIA_MAO_OBRA
```
TABELA_REFERENCIA_MAO_OBRA {
    id_referencia (PK)       - Identificador único da referência
    tipo_servico             - Tipo/categoria do serviço
    especialidade_requerida  - Especialidade necessária
    valor_hora_base          - Valor base por hora
    multiplicador_complexidade - Multiplicador baseado na complexidade
    tempo_padrao_horas       - Tempo padrão para execução
    data_vigencia_inicio     - Data de início da vigência do valor
    data_vigencia_fim        - Data de fim da vigência do valor
    status_ativo             - Se a referência está ativa
}
```

### 🔗 Entidades Associativas (Relacionamentos N:M)

#### 9. MECANICO_EQUIPE
```
MECANICO_EQUIPE {
    id_mecanico (PK, FK)     - Referência ao mecânico
    id_equipe (PK, FK)       - Referência à equipe
    data_entrada_equipe      - Data que entrou na equipe
    data_saida_equipe        - Data que saiu da equipe (pode ser nula)
    funcao_na_equipe         - Função específica na equipe
    status_ativo             - Se está ativo na equipe
}
```

#### 10. OS_SERVIÇO
```
OS_SERVIÇO {
    numero_os (PK, FK)       - Referência à ordem de serviço
    id_servico (PK, FK)      - Referência ao serviço
    quantidade               - Quantidade do serviço
    valor_unitario           - Valor unitário cobrado
    valor_total              - Valor total do item
    tempo_executado_horas    - Tempo real de execução
    observacoes              - Observações específicas do serviço
    status_execucao          - Status da execução do serviço
    mecanico_responsavel (FK) - Mecânico responsável pela execução
}
```

#### 11. OS_PEÇA
```
OS_PEÇA {
    numero_os (PK, FK)       - Referência à ordem de serviço
    id_peca (PK, FK)         - Referência à peça
    quantidade_utilizada     - Quantidade utilizada da peça
    valor_unitario           - Valor unitário da peça na OS
    valor_total              - Valor total das peças
    data_aplicacao           - Data de aplicação da peça
    mecanico_aplicador (FK)  - Mecânico que aplicou a peça
    observacoes              - Observações sobre a aplicação
}
```

## 🔗 Relacionamentos e Cardinalidades

### Relacionamentos 1:N (Um para Muitos)

1. **CLIENTE → VEÍCULO** (1:N)
   - Um cliente pode possuir vários veículos
   - Cada veículo pertence a apenas um cliente

2. **VEÍCULO → ORDEM_DE_SERVIÇO** (1:N)
   - Um veículo pode ter várias ordens de serviço
   - Cada OS refere-se a apenas um veículo

3. **EQUIPE → ORDEM_DE_SERVIÇO** (1:N)
   - Uma equipe pode atender várias ordens de serviço
   - Cada OS é atendida por apenas uma equipe

4. **MECÂNICO → EQUIPE** (Líder) (1:N)
   - Um mecânico pode ser líder de várias equipes
   - Cada equipe tem apenas um líder

### Relacionamentos N:M (Muitos para Muitos)

1. **MECÂNICO ↔ EQUIPE** (N:M)
   - Um mecânico pode participar de várias equipes
   - Uma equipe pode ter vários mecânicos
   - **Entidade Associativa**: MECANICO_EQUIPE

2. **ORDEM_DE_SERVIÇO ↔ SERVIÇO** (N:M)
   - Uma OS pode conter vários serviços
   - Um serviço pode estar presente em várias OSs
   - **Entidade Associativa**: OS_SERVIÇO

3. **ORDEM_DE_SERVIÇO ↔ PEÇA** (N:M)
   - Uma OS pode utilizar várias peças
   - Uma peça pode ser utilizada em várias OSs
   - **Entidade Associativa**: OS_PEÇA

### Relacionamentos 1:1 (Um para Um)

1. **SERVIÇO → TABELA_REFERENCIA_MAO_OBRA** (1:1)
   - Cada serviço tem uma referência de mão-de-obra correspondente
   - Cada referência se aplica a um tipo específico de serviço

## 📋 Regras de Integridade e Restrições

### Restrições de Domínio
- `status_os`: ('Pendente', 'Aprovada', 'Em Andamento', 'Concluída', 'Cancelada')
- `tipo_cliente`: ('Pessoa Física', 'Pessoa Jurídica')
- `especialidade`: ('Motor', 'Suspensão', 'Freios', 'Elétrica', 'Pintura', 'Funilaria', 'Ar Condicionado')
- `combustivel`: ('Gasolina', 'Álcool', 'Flex', 'Diesel', 'GNV', 'Elétrico', 'Híbrido')
- `complexidade`: (1, 2, 3, 4, 5)

### Restrições de Integridade Referencial
- Todas as chaves estrangeiras devem referenciar registros existentes
- Não é permitido excluir registros que possuam dependências

### Restrições de Negócio
- `data_conclusao_real` deve ser maior que `data_emissao`
- `valor_total` deve ser igual à soma de `valor_mao_obra` + `valor_pecas`
- `estoque_atual` não pode ser negativo
- `quilometragem` não pode diminuir entre registros do mesmo veículo
- Uma OS só pode ser marcada como 'Em Andamento' se `autorizacao_cliente` = true

## 📊 Índices Sugeridos

```sql
-- Índices para otimização de consultas
CREATE INDEX idx_veiculo_placa ON VEÍCULO(placa);
CREATE INDEX idx_cliente_cpf_cnpj ON CLIENTE(cpf_cnpj);
CREATE INDEX idx_os_data_emissao ON ORDEM_DE_SERVIÇO(data_emissao);
CREATE INDEX idx_os_status ON ORDEM_DE_SERVIÇO(status_os);
CREATE INDEX idx_peca_codigo ON PEÇA(codigo_peca);
CREATE INDEX idx_mecanico_especialidade ON MECÂNICO(especialidade);
```

---

Este esquema conceitual serve como base para a implementação física do banco de dados e pode ser refinado conforme necessidades específicas do negócio.