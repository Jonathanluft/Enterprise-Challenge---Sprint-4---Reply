CREATE DATABASE SistemaMonitoramento_ML_V4;
GO

USE SistemaMonitoramento_ML_V4;
GO

-- ================================================================
-- CRIAÇÃO DAS TABELAS SIMPLIFICADAS
-- ================================================================

-- Tabela FABRICANTE
CREATE TABLE FABRICANTE (
    id_fabricante INT PRIMARY KEY IDENTITY(1,1),
    nome_fabricante NVARCHAR(100) NOT NULL,
    pais_origem NVARCHAR(50),
    contato NVARCHAR(100)
);

-- Tabela MAQUINA
CREATE TABLE MAQUINA (
    id_maquina INT PRIMARY KEY IDENTITY(1,1),
    nome_maquina NVARCHAR(100) NOT NULL,
    modelo NVARCHAR(50),
    numero_serie NVARCHAR(50) NOT NULL,
    id_fabricante INT,
    data_instalacao DATE,
    localizacao NVARCHAR(100),
    status_operacional NVARCHAR(20) DEFAULT 'ATIVO',
    
    CONSTRAINT FK_maquina_fabricante 
        FOREIGN KEY (id_fabricante) REFERENCES FABRICANTE(id_fabricante),
    CONSTRAINT CHK_status_operacional 
        CHECK (status_operacional IN ('ATIVO', 'INATIVO', 'MANUTENCAO'))
);

-- Tabela LEITURA_SENSORES (todos os sensores em um registro)
CREATE TABLE LEITURA_SENSORES (
    id_leitura BIGINT PRIMARY KEY IDENTITY(1,1),
    id_maquina INT NOT NULL,
    data_hora_leitura DATETIME2 DEFAULT GETDATE(),
    
    -- Valores dos sensores (todos em um registro)
    corrente_eletrica DECIMAL(8,3) NULL,      -- Amperes (A)
    pressao DECIMAL(8,3) NULL,                -- Bar
    temperatura DECIMAL(6,2) NULL,            -- Celsius (°C)
    umidade DECIMAL(5,2) NULL,                -- Percentual (%)
    vibracao DECIMAL(8,4) NULL,               -- mm/s
    
    -- Metadados
    qualidade_sinal TINYINT DEFAULT 100,      -- 0-100%
    temperatura_ambiente DECIMAL(5,2),        -- °C
    turno NVARCHAR(10),                       -- MANHA, TARDE, NOITE
    
    CONSTRAINT FK_leitura_maquina 
        FOREIGN KEY (id_maquina) REFERENCES MAQUINA(id_maquina)
);

-- Tabela FALHA
CREATE TABLE FALHA (
    id_falha INT PRIMARY KEY IDENTITY(1,1),
    id_maquina INT NOT NULL,
    tipo_falha NVARCHAR(50),
    data_hora_falha DATETIME2 NOT NULL,
    gravidade NVARCHAR(20),
    tempo_inatividade_horas DECIMAL(6,2),
    descricao_falha NVARCHAR(500),
    resolvido BIT DEFAULT 0,
    
    CONSTRAINT FK_falha_maquina 
        FOREIGN KEY (id_maquina) REFERENCES MAQUINA(id_maquina),
    CONSTRAINT CHK_gravidade 
        CHECK (gravidade IN ('BAIXA', 'MEDIA', 'ALTA', 'CRITICA'))
);

-- ================================================================
-- CARGA DE DADOS BÁSICOS
-- ================================================================

-- Inserir fabricantes
INSERT INTO FABRICANTE (nome_fabricante, pais_origem, contato)
VALUES 
    ('Siemens Industrial', 'Alemanha', 'contato@siemens.com'),
    ('ABB Automação', 'Suíça', 'info@abb.com'),
    ('Schneider Electric', 'França', 'suporte@schneider.com'),
    ('WEG Motores', 'Brasil', 'vendas@weg.net');

-- Inserir máquinas
INSERT INTO MAQUINA (nome_maquina, modelo, numero_serie, id_fabricante, data_instalacao, localizacao)
VALUES 
    ('Compressor Principal A', 'CP-5000X', 'SN001234567', 1, '2023-01-15', 'Setor A - Linha 1'),
    ('Bomba Centrífuga B', 'BC-3000Y', 'SN007654321', 2, '2023-03-20', 'Setor B - Linha 2'),
    ('Motor Elétrico C', 'ME-1500Z', 'SN009876543', 3, '2023-02-10', 'Setor C - Linha 1'),
    ('Ventilador Industrial D', 'VI-2000W', 'SN012345678', 4, '2023-04-05', 'Setor D - Linha 3'),
    ('Esteira Transportadora E', 'ET-800V', 'SN098765432', 1, '2023-05-12', 'Setor A - Linha 2');

-- ================================================================
-- GERAÇÃO DE DADOS COM RELAÇÕES CLARAS ENTRE MÉTRICAS (4000 registros)
-- ================================================================

-- Limpar dados existentes se houver
TRUNCATE TABLE LEITURA_SENSORES;
DELETE FROM FALHA;

DECLARE @i INT = 1;
DECLARE @data_base DATETIME2 = DATEADD(day, -60, GETDATE());
DECLARE @timestamp DATETIME2;
DECLARE @id_maquina INT;
DECLARE @condicao_falha BIT;
DECLARE @fator_temporal DECIMAL(5,2);
DECLARE @fator_stress DECIMAL(5,2);

-- Valores base normais (mais realistas)
DECLARE @corrente_normal DECIMAL(8,3) = 22.0;
DECLARE @pressao_normal DECIMAL(8,3) = 12.0;
DECLARE @temp_normal DECIMAL(6,2) = 58.0;
DECLARE @umidade_normal DECIMAL(5,2) = 42.0;
DECLARE @vibracao_normal DECIMAL(8,4) = 2.8;

WHILE @i <= 4000
BEGIN
    -- Calcular timestamp
    SET @timestamp = DATEADD(minute, @i * 21.6, @data_base);
    
    -- Escolher máquina
    SET @id_maquina = (@i % 5) + 1;
    
    -- Fator temporal (mais stress durante horários de pico)
    DECLARE @hora INT = DATEPART(hour, @timestamp);
    SET @fator_temporal = 
        CASE 
            WHEN @hora BETWEEN 8 AND 11 THEN 1.3  -- Pico manhã
            WHEN @hora BETWEEN 13 AND 16 THEN 1.4  -- Pico tarde
            WHEN @hora BETWEEN 20 AND 22 THEN 1.2  -- Pico noite
            ELSE 0.8  -- Períodos mais calmos
        END;
    
    -- Fator de stress baseado em idade da máquina e desgaste
    SET @fator_stress = 0.9 + (@i * 0.000025);  -- Desgaste progressivo
    
    -- Determinar condição de falha com base em padrões realistas
    DECLARE @probabilidade_falha DECIMAL(5,3) = 0.0;
    
    -- Probabilidade base por máquina (algumas mais problemáticas)
    SET @probabilidade_falha = 
        CASE @id_maquina
            WHEN 1 THEN 0.18  -- Compressor (mais falhas)
            WHEN 2 THEN 0.22  -- Bomba (muito problemática)
            WHEN 3 THEN 0.15  -- Motor (médio)
            WHEN 4 THEN 0.12  -- Ventilador (menos falhas)
            ELSE 0.10         -- Esteira (mais confiável)
        END;
    
    -- Aumentar probabilidade em horários de stress
    SET @probabilidade_falha = @probabilidade_falha * @fator_temporal * @fator_stress;
    
    -- Determinar se haverá falha
    SET @condicao_falha = CASE WHEN RAND() < @probabilidade_falha THEN 1 ELSE 0 END;
    
    -- Calcular turno
    DECLARE @turno NVARCHAR(10) = 
        CASE 
            WHEN @hora BETWEEN 6 AND 13 THEN 'MANHA'
            WHEN @hora BETWEEN 14 AND 21 THEN 'TARDE'
            ELSE 'NOITE'
        END;
    
    -- ================================================================
    -- GERAR VALORES COM RELAÇÕES CLARAS ENTRE MÉTRICAS
    -- ================================================================
    
    DECLARE @corrente DECIMAL(8,3);
    DECLARE @pressao DECIMAL(8,3);
    DECLARE @temperatura DECIMAL(6,2);
    DECLARE @umidade DECIMAL(5,2);
    DECLARE @vibracao DECIMAL(8,4);
    
    -- Ruído base
    DECLARE @ruido DECIMAL(5,2) = 0.95 + (RAND() * 0.1);
    
    IF @condicao_falha = 1
    BEGIN
        -- ===== CONDIÇÃO DE FALHA - RELAÇÕES CLARAS =====
        
        -- Base elevada para falha
        SET @temperatura = 75.0 + (RAND() * 25.0);  -- 75-100°C
        
        -- RELAÇÃO 1: Temperatura alta → Corrente alta (equipamento trabalhando mais)
        SET @corrente = @corrente_normal + (@temperatura - @temp_normal) * 0.4 + (RAND() * 8.0);
        
        -- RELAÇÃO 2: Temperatura alta → Vibração alta (dilatação, desalinhamento)
        SET @vibracao = @vibracao_normal + (@temperatura - @temp_normal) * 0.15 + (RAND() * 3.0);
        
        -- RELAÇÃO 3: Corrente alta → Pressão alterada (bombas/compressores)
        IF @id_maquina IN (1, 2)  -- Compressor e Bomba
            SET @pressao = @pressao_normal + (@corrente - @corrente_normal) * 0.8 + (RAND() * 6.0);
        ELSE
            SET @pressao = @pressao_normal + (RAND() * 4.0 - 2.0);
        
        -- RELAÇÃO 4: Temperatura alta → Umidade baixa (evaporação) OU alta (condensação)
        IF RAND() < 0.6
            SET @umidade = @umidade_normal - (@temperatura - @temp_normal) * 0.3 + (RAND() * 10.0);  -- Evaporação
        ELSE
            SET @umidade = @umidade_normal + (@temperatura - @temp_normal) * 0.4 + (RAND() * 15.0);  -- Condensação
        
        -- RELAÇÃO 5: Vibração alta correlaciona com corrente alta
        SET @corrente = @corrente + (@vibracao - @vibracao_normal) * 2.0;
        
    END
    ELSE
    BEGIN
        -- ===== CONDIÇÃO NORMAL - VARIAÇÕES MENORES =====
        
        -- Temperatura normal com variação pequena
        SET @temperatura = @temp_normal + (RAND() * 16.0 - 8.0) * @ruido;  -- ±8°C
        
        -- Corrente proporcional à temperatura (relação mais suave)
        SET @corrente = @corrente_normal + (@temperatura - @temp_normal) * 0.15 + (RAND() * 4.0 - 2.0) * @ruido;
        
        -- Vibração normal com leve correlação com corrente
        SET @vibracao = @vibracao_normal + (@corrente - @corrente_normal) * 0.05 + (RAND() * 1.0 - 0.5) * @ruido;
        
        -- Pressão normal (mais estável em condições normais)
        SET @pressao = @pressao_normal + (RAND() * 4.0 - 2.0) * @ruido;
        
        -- Umidade normal (variação ambiental)
        SET @umidade = @umidade_normal + (RAND() * 20.0 - 10.0) * @ruido;
    END
    
    -- ================================================================
    -- AJUSTES ESPECÍFICOS POR MÁQUINA (características individuais)
    -- ================================================================
    
    IF @id_maquina = 1  -- Compressor
    BEGIN
        SET @corrente = @corrente * 1.3;
        SET @pressao = @pressao * 1.9;
        SET @vibracao = @vibracao * 0.9;
        -- Compressores: mais corrente e pressão, menos vibração
    END
    ELSE IF @id_maquina = 2  -- Bomba
    BEGIN
        SET @pressao = @pressao * 2.2;
        SET @temperatura = @temperatura * 0.95;
        SET @umidade = @umidade * 1.4;
        -- Bombas: muita pressão, umidade alta, temperatura menor
    END
    ELSE IF @id_maquina = 3  -- Motor
    BEGIN
        SET @corrente = @corrente * 1.6;
        SET @temperatura = @temperatura * 1.15;
        SET @vibracao = @vibracao * 1.3;
        -- Motores: corrente alta, temperatura e vibração elevadas
    END
    ELSE IF @id_maquina = 4  -- Ventilador
    BEGIN
        SET @corrente = @corrente * 0.7;
        SET @vibracao = @vibracao * 1.5;
        SET @umidade = @umidade * 0.7;
        -- Ventiladores: baixa corrente, vibração alta, umidade baixa
    END
    ELSE  -- Esteira
    BEGIN
        SET @corrente = @corrente * 0.6;
        SET @pressao = @pressao * 0.4;
        SET @vibracao = @vibracao * 1.8;
        -- Esteiras: baixa corrente e pressão, vibração muito alta
    END
    
    -- Garantir valores mínimos positivos
    SET @corrente = CASE WHEN @corrente < 5.0 THEN 5.0 + RAND() * 3.0 ELSE @corrente END;
    SET @pressao = CASE WHEN @pressao < 2.0 THEN 2.0 + RAND() * 2.0 ELSE @pressao END;
    SET @temperatura = CASE WHEN @temperatura < 25.0 THEN 25.0 + RAND() * 10.0 ELSE @temperatura END;
    SET @umidade = CASE WHEN @umidade < 15.0 THEN 15.0 + RAND() * 10.0 ELSE @umidade END;
    SET @vibracao = CASE WHEN @vibracao < 0.5 THEN 0.5 + RAND() * 0.5 ELSE @vibracao END;
    
    -- Inserir leitura completa
    INSERT INTO LEITURA_SENSORES (
        id_maquina, 
        data_hora_leitura, 
        corrente_eletrica, 
        pressao, 
        temperatura, 
        umidade, 
        vibracao,
        qualidade_sinal,
        temperatura_ambiente,
        turno
    )
    VALUES (
        @id_maquina,
        @timestamp,
        ROUND(@corrente, 3),
        ROUND(@pressao, 3),
        ROUND(@temperatura, 2),
        ROUND(@umidade, 2),
        ROUND(@vibracao, 4),
        85 + (RAND() * 15),  -- Qualidade do sinal entre 85-100%
        18 + (RAND() * 8),   -- Temperatura ambiente entre 18-26°C
        @turno
    );
    
    -- Gerar falhas quando há condição de falha
    IF @condicao_falha = 1 AND (RAND() < 0.25)  -- 25% de chance quando há anomalia
    BEGIN
        DECLARE @tipos_falha TABLE (tipo NVARCHAR(50), peso DECIMAL(3,2));
        
        -- Tipos de falha baseados nas métricas altas
        IF @temperatura > 80.0
            INSERT INTO @tipos_falha VALUES ('SUPERAQUECIMENTO', 0.4);
        IF @vibracao > 6.0
            INSERT INTO @tipos_falha VALUES ('VIBRACAO_EXCESSIVA', 0.3);
        IF @corrente > 35.0
            INSERT INTO @tipos_falha VALUES ('SOBRECARGA_ELETRICA', 0.3);
        IF @pressao > 20.0
            INSERT INTO @tipos_falha VALUES ('PRESSAO_ANORMAL', 0.2);
        
        -- Adicionar tipos genéricos se nenhum específico foi adicionado
        IF NOT EXISTS (SELECT 1 FROM @tipos_falha)
        BEGIN
            INSERT INTO @tipos_falha VALUES ('DESBALANCEAMENTO', 0.2);
            INSERT INTO @tipos_falha VALUES ('FALHA_LUBRIFICACAO', 0.1);
        END
        
        DECLARE @tipo_falha_selecionado NVARCHAR(50);
        SELECT TOP 1 @tipo_falha_selecionado = tipo FROM @tipos_falha ORDER BY NEWID();
        
        INSERT INTO FALHA (id_maquina, tipo_falha, data_hora_falha, gravidade, tempo_inatividade_horas, descricao_falha)
        VALUES (
            @id_maquina,
            @tipo_falha_selecionado,
            DATEADD(minute, 5 + (RAND() * 55), @timestamp),
            CASE 
                WHEN @temperatura > 90.0 OR @vibracao > 8.0 OR @corrente > 45.0 THEN 'CRITICA'
                WHEN @temperatura > 80.0 OR @vibracao > 6.0 OR @corrente > 35.0 THEN 'ALTA'
                WHEN @temperatura > 70.0 OR @vibracao > 4.5 OR @corrente > 28.0 THEN 'MEDIA'
                ELSE 'BAIXA'
            END,
            0.5 + (RAND() * 8.0),
            'Falha detectada por correlação entre métricas críticas'
        );
    END
    
    SET @i = @i + 1;
END

-- ================================================================
-- CRIAÇÃO DE ÍNDICES PARA PERFORMANCE EM ML
-- ================================================================

CREATE INDEX IX_leitura_data_maquina ON LEITURA_SENSORES(data_hora_leitura, id_maquina);
CREATE INDEX IX_leitura_maquina ON LEITURA_SENSORES(id_maquina);
CREATE INDEX IX_falha_data_maquina ON FALHA(data_hora_falha, id_maquina);

-- ================================================================
-- VIEWS PARA FACILITAR ANÁLISES DE ML
-- ================================================================

-- View com dados normalizados para ML
CREATE VIEW VW_DADOS_ML AS
SELECT 
    ls.id_leitura,
    ls.id_maquina,
    m.nome_maquina,
    m.modelo,
    ls.data_hora_leitura,
    ls.corrente_eletrica,
    ls.pressao,
    ls.temperatura,
    ls.umidade,
    ls.vibracao,
    ls.qualidade_sinal,
    ls.temperatura_ambiente,
    ls.turno,
    -- Flag para indicar se houve falha nas próximas 2 horas (target para ML)
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM FALHA f 
            WHERE f.id_maquina = ls.id_maquina 
            AND f.data_hora_falha BETWEEN ls.data_hora_leitura 
            AND DATEADD(hour, 2, ls.data_hora_leitura)
        ) THEN 1 
        ELSE 0 
    END AS falha_proximas_2h,
    
    -- Gravidade da próxima falha (se houver)
    (SELECT TOP 1 f.gravidade FROM FALHA f 
     WHERE f.id_maquina = ls.id_maquina 
     AND f.data_hora_falha >= ls.data_hora_leitura
     ORDER BY f.data_hora_falha ASC) AS proxima_gravidade
FROM LEITURA_SENSORES ls
INNER JOIN MAQUINA m ON ls.id_maquina = m.id_maquina;

-- ================================================================
-- VERIFICAÇÃO DOS DADOS COM ESTATÍSTICAS DETALHADAS
-- ================================================================

SELECT 'FABRICANTES' as Tabela, COUNT(*) as Registros FROM FABRICANTE
UNION ALL
SELECT 'MAQUINAS', COUNT(*) FROM MAQUINA
UNION ALL
SELECT 'LEITURAS_SENSORES', COUNT(*) FROM LEITURA_SENSORES
UNION ALL
SELECT 'FALHAS', COUNT(*) FROM FALHA;

-- Estatísticas por condição (Normal vs Falha)
WITH dados_ml AS (
    SELECT 
        corrente_eletrica, pressao, temperatura, umidade, vibracao,
        falha_proximas_2h as target
    FROM VW_DADOS_ML
)
SELECT 
    'CONDIÇÃO NORMAL' as Condicao,
    COUNT(*) as Qtd_Registros,
    ROUND(AVG(temperatura), 2) as Temp_Media,
    ROUND(AVG(vibracao), 3) as Vibr_Media,
    ROUND(AVG(corrente_eletrica), 2) as Corr_Media,
    ROUND(AVG(pressao), 2) as Press_Media,
    ROUND(AVG(umidade), 2) as Umid_Media
FROM dados_ml 
WHERE target = 0

UNION ALL

SELECT 
    'CONDIÇÃO FALHA' as Condicao,
    COUNT(*) as Qtd_Registros,
    ROUND(AVG(temperatura), 2) as Temp_Media,
    ROUND(AVG(vibracao), 3) as Vibr_Media,
    ROUND(AVG(corrente_eletrica), 2) as Corr_Media,
    ROUND(AVG(pressao), 2) as Press_Media,
    ROUND(AVG(umidade), 2) as Umid_Media
FROM dados_ml 
WHERE target = 1;

-- Correlações esperadas
WITH correlacoes AS (
    SELECT 
        temperatura, vibracao, corrente_eletrica, pressao, umidade,
        falha_proximas_2h as target
    FROM VW_DADOS_ML
    WHERE temperatura IS NOT NULL AND vibracao IS NOT NULL
)
SELECT 
    'ESTATÍSTICAS DE CORRELAÇÃO' as Analise,
    COUNT(*) as Total_Registros,
    ROUND(AVG(CASE WHEN target = 1 THEN temperatura ELSE NULL END) - 
          AVG(CASE WHEN target = 0 THEN temperatura ELSE NULL END), 2) as Diff_Temp_Falha_Normal,
    ROUND(AVG(CASE WHEN target = 1 THEN vibracao ELSE NULL END) - 
          AVG(CASE WHEN target = 0 THEN vibracao ELSE NULL END), 3) as Diff_Vibr_Falha_Normal,
    ROUND(AVG(CASE WHEN target = 1 THEN corrente_eletrica ELSE NULL END) - 
          AVG(CASE WHEN target = 0 THEN corrente_eletrica ELSE NULL END), 2) as Diff_Corr_Falha_Normal
FROM correlacoes;

-- Amostra dos dados para verificação
SELECT TOP 20 
    id_maquina,
    FORMAT(data_hora_leitura, 'dd/MM HH:mm') as DataHora,
    temperatura,
    vibracao,
    corrente_eletrica,
    pressao,
    umidade,
    falha_proximas_2h as Target
FROM VW_DADOS_ML 
ORDER BY data_hora_leitura DESC;

PRINT 'Base de dados V3 criada com RELAÇÕES CLARAS entre métricas!';
PRINT 'Padrões implementados:';
PRINT '• Temperatura alta → Corrente alta → Vibração alta';
PRINT '• Pressão anormal quando temperatura/corrente elevadas';
PRINT '• Umidade varia inversamente com temperatura (evaporação/condensação)';
PRINT '• Máquinas diferentes têm perfis específicos de falha';
PRINT '• Falhas ocorrem mais em horários de stress operacional';
PRINT 'Execute o script Python para ver as correlações nos gráficos!';