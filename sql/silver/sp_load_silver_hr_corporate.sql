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

Parâmetros:
    Nenhum.
        Esta stored procedure não aceita parâmetros nem retorna valores.

Exemplo de Uso:
EXEC silver.load_silver_hr_corporate;
===============================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver_hr_corporate AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Iniciando carga: silver.hr_corporate';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Carregando tabela hr_corporate';
		PRINT '------------------------------------------------';       

        -- Carregando silver.hr_corporate
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
            create_date
        )
        SELECT
            TRY_CAST(employee_id AS INT) AS employee_id,
            TRIM(department) AS department,
            CASE
                WHEN UPPER(TRIM(position)) = 'INTERN' THEN CONCAT(TRIM(department), ' Intern')
                ELSE TRIM(position)
            END AS position,
            TRY_CAST(salary AS DECIMAL(10, 2)) AS salary,
            TRY_CAST(admission_date AS DATE) AS admission_date,
            CASE 
                WHEN UPPER(TRIM(position)) LIKE '%INTERN%' THEN 'INTERN'
                WHEN UPPER(TRIM(position)) NOT LIKE '%INTERN%' 
                    AND UPPER(TRIM(employment_type)) = 'INTERN' 
                    THEN 'CLT'
                ELSE UPPER(TRIM(employment_type))
            END AS employment_type,
            create_date
        FROM bronze.hr_corporate;  
        SET @end_time = GETDATE();
        PRINT '>> Duração do carregamento: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'OCORREU UM ERRO DURANTE O PROCESSO DE CARREGAMENTO DA CAMADA SILVER';
        PRINT 'Mensagem de erro:' + ERROR_MESSAGE();
        PRINT 'Código de erro:' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Estado de erro:' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END