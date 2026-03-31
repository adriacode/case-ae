/*
===============================================================================
Stored Procedure: Carregar Tabela: hr_corporate
Camada Silver (Bronze -> Silver)
===============================================================================
Objetivo do Script:
    Esta stored procedure executa o processo de ETL (Extração, Transformação e Carga) para
    popular as tabelas do esquema 'silver.hr_corporate' a partir do esquema 'bronze.hr_corporate'. 
    Ações Executadas:
        - Trunca as tabelas da camada Silver. 
        - Insere dados transformados e limpos, provenientes da camada Bronze, nas tabelas Silver.
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
        
        PRINT '>> Truncando Tabela: silver.hr_corporate';
        TRUNCATE TABLE silver.hr_corporate;

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
            -- Tipagem de identificador para formato inteiro
            TRY_CAST(employee_id AS INT) AS employee_id,
            
            -- Padronização de strings para consistência em filtros
            TRIM(department) AS department,
            
            -- Enriquecimento: Detalha o cargo de estagiário conforme o departamento
            CASE
                WHEN UPPER(TRIM(position)) = 'INTERN' THEN CONCAT(TRIM(department), ' Intern')
                ELSE TRIM(position)
            END AS position,
            
            -- Sanidade: Impede que valores negativos corrompam cálculos salariais
            CASE 
                WHEN TRY_CAST(salary AS DECIMAL(10, 2)) < 0 THEN 0 
                ELSE TRY_CAST(salary AS DECIMAL(10, 2)) 
            END AS salary,
            
            -- Conversão de texto bruto para o tipo relacional DATE
            TRY_CAST(admission_date AS DATE) AS admission_date,
            
            -- Regra de Negócio: Validação cruzada para alinhar cargo e tipo de contrato
            CASE 
                WHEN UPPER(TRIM(position)) LIKE '%INTERN%' AND UPPER(TRIM(employment_type)) <> 'INTERN' THEN 'INTERN'
                WHEN UPPER(TRIM(position)) NOT LIKE '%INTERN%' AND UPPER(TRIM(employment_type)) = 'INTERN' THEN 'CLT'
                ELSE UPPER(TRIM(employment_type))
            END AS employment_type,
            
            -- Linhagem: Flag que rastreia se o registro sofreu ajuste no pipeline
            CASE 
                WHEN UPPER(TRIM(position)) LIKE '%INTERN%' AND UPPER(TRIM(employment_type)) <> 'INTERN' THEN 1
                 WHEN UPPER(TRIM(position)) NOT LIKE '%INTERN%' AND UPPER(TRIM(employment_type)) = 'INTERN' THEN 1
                 ELSE 0
            END AS is_employment_type_adjusted,
            
            create_date
        FROM bronze.hr_corporate;  

        SET @end_time = GETDATE();
        PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'OCORREU UM ERRO DURANTE O PROCESSO DE CARREGAMENTO';
        PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END