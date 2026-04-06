/*
===============================================================================
Stored Procedure: silver.load_silver_hr_corporate
===============================================================================
Descrição:
    Realiza o processo de carga da tabela 'silver.hr_corporate' a partir dos
    dados brutos da tabela 'bronze.hr_corporate'.

Objetivo:
    Aplicar transformações, padronizações e regras de negócio para garantir
    consistência e qualidade dos dados na camada Silver.

Fonte:
    bronze.hr_corporate

Destino:
    silver.hr_corporate

Transformações aplicadas:
    - Conversão de tipos (NVARCHAR → INT, DECIMAL, DATE)
    - Padronização de strings (TRIM, UPPER)
    - Enriquecimento de dados (posição de estágio por departamento)
    - Tratamento de valores inválidos (salários negativos)
    - Validação de consistência entre cargo e tipo de contrato
    - Criação de flag de ajuste (linhagem de dados)

Observações:
    - A tabela Silver é totalmente recarregada (TRUNCATE + INSERT)
    - Indicadores de qualidade são gerados durante a carga
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver_hr_corporate AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        PRINT '================================================';
        PRINT 'Iniciando carga: silver.hr_corporate';
        PRINT '================================================';

        SET @start_time = GETDATE();
        
        -- ============================================================================
        -- Etapa 1: Limpeza da tabela de destino
        -- ============================================================================
        PRINT '>> Truncando Tabela: silver.hr_corporate';
        TRUNCATE TABLE silver.hr_corporate;

        -- ============================================================================
        -- Etapa 2: Inserção com transformação e padronização
        -- ============================================================================
        PRINT '>> Inserindo dados na Tabela: silver.hr_corporate';

        INSERT INTO silver.hr_corporate (
            employee_id, 
            department, 
            position, 
            salary, 
            admission_date, 
            employment_type,
            is_employment_type_adjusted,
            create_date
        )
        SELECT
            -- Conversão de identificador para inteiro
            TRY_CAST(employee_id AS INT) AS employee_id,
            
            -- Padronização de texto
            TRIM(department) AS department,
            
            -- Enriquecimento de cargo para estagiários
            CASE
                WHEN UPPER(TRIM(position)) = 'INTERN' THEN CONCAT(TRIM(department), ' Intern')
                ELSE TRIM(position)
            END AS position,
            
            -- Tratamento de valores inválidos (salário negativo)
            CASE 
                WHEN TRY_CAST(salary AS DECIMAL(10, 2)) < 0 THEN 0 
                ELSE TRY_CAST(salary AS DECIMAL(10, 2)) 
            END AS salary,
            
            -- Conversão de data
            TRY_CAST(admission_date AS DATE) AS admission_date,
            
            -- Regra de consistência entre cargo e tipo de contrato
            CASE 
                WHEN UPPER(TRIM(position)) LIKE '%INTERN%' 
                     AND UPPER(TRIM(employment_type)) <> 'INTERN' THEN 'INTERN'
                
                WHEN UPPER(TRIM(position)) NOT LIKE '%INTERN%' 
                     AND UPPER(TRIM(employment_type)) = 'INTERN' THEN 'CLT'
                
                ELSE UPPER(TRIM(employment_type))
            END AS employment_type,
            
            -- Flag de ajuste (linhagem de dados)
            CASE 
                WHEN UPPER(TRIM(position)) LIKE '%INTERN%' 
                     AND UPPER(TRIM(employment_type)) <> 'INTERN' THEN 1
                
                WHEN UPPER(TRIM(position)) NOT LIKE '%INTERN%' 
                     AND UPPER(TRIM(employment_type)) = 'INTERN' THEN 1
                
                ELSE 0
            END AS is_employment_type_adjusted,
            
            create_date
        FROM bronze.hr_corporate;

        -- ============================================================================
        -- Etapa 3: Log de execução
        -- ============================================================================
        SET @end_time = GETDATE();

        PRINT '>> Duração do carregamento: ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' segundos';

        PRINT '>> -------------';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'OCORREU UM ERRO DURANTE O PROCESSO DE CARREGAMENTO';
        PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END