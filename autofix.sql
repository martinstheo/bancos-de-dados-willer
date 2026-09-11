
-- Tabela de clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de mecânicos
CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    valor_hora DECIMAL(10,2) NOT NULL CHECK (valor_hora > 0)
);

-- Tabela de veículos
CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    placa CHAR(7) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INTEGER NOT NULL CHECK (ano >= 1900),

    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES clientes(id)
);

-- Tabela de ordens de serviço
CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INTEGER NOT NULL,
    mecanico_id INTEGER NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra DECIMAL(10,2) NOT NULL CHECK (valor_mao_obra >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Em Aberto',

    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (veiculo_id)
        REFERENCES veiculos(id),

    CONSTRAINT fk_os_mecanico
        FOREIGN KEY (mecanico_id)
        REFERENCES mecanicos(id),

    CONSTRAINT check_status
        CHECK (status IN (
            'Em Aberto',
            'Em Andamento',
            'Concluida',
            'Cancelada'
        ))
);

-- Tabela de peças utilizadas nas OS
CREATE TABLE pecas_os (
    id SERIAL PRIMARY KEY,
    os_id INTEGER NOT NULL,
    nome_peca VARCHAR(100) NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    valor_unitario DECIMAL(10,2) NOT NULL CHECK (valor_unitario > 0),

    CONSTRAINT fk_peca_os
        FOREIGN KEY (os_id)
        REFERENCES ordens_servico(id)
);

--clientes
INSERT INTO clientes (nome, email, telefone, cpf)
VALUES
('Fernanda Lima', 'fernanda.lima@email.com', '(48) 99911-2233', '12345678901'),
('Carlos Souza', 'carlos.souza@email.com', '(48) 99822-3344', '23456789012'),
('Mariana Oliveira', 'mariana.oliveira@email.com', '(48) 99733-4455', '34567890123');

--mecanicos
INSERT INTO mecanicos (nome, especialidade, valor_hora)
VALUES
('João Pereira', 'Motor', 120.00),
('Rafael Santos', 'Suspensão', 85.00),
('Lucas Almeida', 'Injeção Eletrônica', 110.00);

--veiculos
INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano)
VALUES
(1, 'ABC1D23', 'Civic', 'Honda', 2020),
(2, 'DEF4E56', 'Onix', 'Chevrolet', 2022),
(3, 'GHI7F89', 'Corolla', 'Toyota', 2019);

--ordens de serviço
INSERT INTO ordens_servico
    (veiculo_id, mecanico_id, valor_mao_obra, status)
VALUES
(1, 1, 450.00, 'Concluida'),
(2, 2, 300.00, 'Em Andamento'),
(3, 3, 500.00, 'Concluida'),
(1, 3, 250.00, 'Em Aberto');

--peças/insumos
INSERT INTO pecas_os
    (os_id, nome_peca, quantidade, valor_unitario)
VALUES
(1, 'Filtro de Óleo', 1, 45.00),
(1, 'Óleo do Motor', 4, 35.00),
(2, 'Pastilha de Freio', 1, 180.00),
(3, 'Amortecedor', 2, 350.00);

--q1
SELECT
    v.modelo,
    v.marca,
    v.placa,
    c.nome AS proprietario,
    c.telefone
FROM veiculos v
INNER JOIN clientes c
    ON v.cliente_id = c.id
ORDER BY v.marca, v.modelo;

--q2
SELECT
    os.id AS id_os,
    v.placa,
    v.modelo,
    os.data_abertura,
    m.nome AS mecanico,
    os.status
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.veiculo_id = v.id
INNER JOIN clientes c
    ON v.cliente_id = c.id
INNER JOIN mecanicos m
    ON os.mecanico_id = m.id
WHERE c.nome = 'Fernanda Lima'
ORDER BY os.data_abertura;

--q3
SELECT
    os.id AS id_os,
    v.placa,
    m.nome AS mecanico,
    os.valor_mao_obra,
    COALESCE(
        SUM(p.quantidade * p.valor_unitario),
        0
    ) AS valor_pecas,
    os.valor_mao_obra +
    COALESCE(
        SUM(p.quantidade * p.valor_unitario),
        0
    ) AS valor_total
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.veiculo_id = v.id
INNER JOIN mecanicos m
    ON os.mecanico_id = m.id
LEFT JOIN pecas_os p
    ON os.id = p.os_id
GROUP BY
    os.id,
    v.placa,
    m.nome,
    os.valor_mao_obra
ORDER BY os.id;

--q4
SELECT
    id,
    nome,
    especialidade,
    valor_hora
FROM mecanicos
WHERE valor_hora > 90.00
ORDER BY valor_hora DESC;

--q5
SELECT
    m.especialidade,
    SUM(os.valor_mao_obra) AS total_faturado
FROM ordens_servico os
INNER JOIN mecanicos m
    ON os.mecanico_id = m.id
WHERE os.status = 'Concluida'
GROUP BY m.especialidade
ORDER BY total_faturado DESC;