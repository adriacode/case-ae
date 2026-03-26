/*
===============================================================================
Stored Procedure: Carregar Tabela: hr_personal
Camada Silver (Bronze -> Silver)
===============================================================================
Objetivo do Script:
    Esta stored procedure executa o processo de ETL (Extração, Transformação e Carga) para
    popular as tabelas do esquema 'silver.hr_personal' a partir do esquema 'bronze.hr_personal'. 
    Ações Executadas:
        - Trunca as tabelas da camada Silver. 
        - Insere dados transformados e limpos, provenientes da camada Bronze, nas tabelas Silver.

Parâmetros:
    Nenhum.
        Esta stored procedure não aceita parâmetros nem retorna valores.

Exemplo de Uso:
EXEC silver.load_silver_hr_personal;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver_hr_personal AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Iniciando carga: silver.hr_personal';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Carregando tabela hr_personal';
		PRINT '------------------------------------------------'; 

        -- Carregando silver.hr_personal
        SET @start_time = GETDATE();
        PRINT '>> Truncando Tabela: silver.hr_personal';
        TRUNCATE TABLE silver.hr_personal;
        PRINT '>> Inserindo dados na Tabela: silver.hr_personal';
        INSERT INTO silver.hr_personal (
            personal_id,
            first_name,
            last_name,
            full_name,
            email,
            phone,
            birth_date,
            gender,
            street,
            street_name,
            building_number,
            city,
            zipcode,
            country,
            country_code,
            latitude,
            longitude,
            create_date
        )
        SELECT 
            ROW_NUMBER() OVER(ORDER BY create_date) AS personal_id,
            TRIM(firstname) AS first_name,
            TRIM(lastname) AS last_name,
            CONCAT(TRIM(firstname), ' ', TRIM(lastname)) AS full_name,
            LOWER(TRIM(email)) AS email,
            TRIM(phone) AS phone,
            TRY_CAST(birthday AS DATE) AS birth_date,
            CASE 
                WHEN UPPER(TRIM(gender)) IN ('MALE', 'M') THEN 'M'
                WHEN UPPER(TRIM(gender)) IN ('FEMALE', 'F') THEN 'F'
                ELSE NULL
            END AS gender,
            TRIM(street) AS street,
            TRIM(streetName) AS street_name,
            TRIM(buildingNumber) AS building_number,
            TRIM(city) AS city,
            TRIM(zipcode) AS zipcode,
            TRIM(country) AS country,
            TRIM(country_code) AS country_code,
            TRY_CAST(latitude AS FLOAT) AS latitude,
            TRY_CAST(longitude AS FLOAT) AS longitude,
            create_date
        FROM bronze.hr_personal;
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