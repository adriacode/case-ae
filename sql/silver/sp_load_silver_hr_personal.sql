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
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver_hr_personal AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '================================================';
        PRINT 'Iniciando carga: silver.hr_personal';
        PRINT '================================================';

        SET @start_time = GETDATE();
        
        -- Limpeza para garantir a integridade da carga (Full Load)
        PRINT '>> Truncando Tabela: silver.hr_personal';
        TRUNCATE TABLE silver.hr_personal;

        PRINT '>> Inserindo dados transformados';
        INSERT INTO silver.hr_personal (
            personal_id,
            first_name,
            last_name,
            full_name,
            email,
            phone,
            birth_date,
            is_birth_date_suspect,
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
            website,
            image_url,
            create_date
        )
        SELECT 
            -- Garante ID único e sequencial para integridade da camada Silver
            ROW_NUMBER() OVER(ORDER BY create_date, firstname, lastname) AS personal_id,
            
            -- Padronização de strings e remoção de espaços para consistência no BI
            TRIM(firstname) AS first_name,
            TRIM(lastname) AS last_name,
            CONCAT(TRIM(firstname), ' ', TRIM(lastname)) AS full_name,
            
            -- Normalização para letras minúsculas para evitar duplicidade lógica
            LOWER(TRIM(email)) AS email,
            
            TRIM(phone) AS phone,
            
            -- Conversão do dado bruto (NVARCHAR) para o tipo relacional correto (DATE)
            TRY_CAST(birthday AS DATE) AS birth_date,
            
            -- Flag de auditoria para identificar inconsistências na idade (< 18, > 95 ou Data Futura)
            CASE 
                WHEN DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) < 18 
                  OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) > 95
                  OR TRY_CAST(birthday AS DATE) > GETDATE()
                THEN 1
                ELSE 0
            END AS is_birth_date_suspect,
            
            -- Padronização de domínio para o formato simplificado M/F/U
            CASE 
                WHEN UPPER(TRIM(gender)) IN ('MALE', 'M') THEN 'M'
                WHEN UPPER(TRIM(gender)) IN ('FEMALE', 'F') THEN 'F'
                ELSE 'U' 
            END AS gender,

            TRIM(street) AS street,
            TRIM(streetName) AS street_name,
            TRIM(buildingNumber) AS building_number,
            TRIM(city) AS city,
            TRIM(zipcode) AS zipcode,
            TRIM(country) AS country,
            TRIM(country_code) AS country_code,
            
            -- Conversão de coordenadas para precisão decimal
            TRY_CAST(latitude AS DECIMAL(9, 6)) AS latitude,
            TRY_CAST(longitude AS DECIMAL(9, 6)) AS longitude,
            
            TRIM(website) AS website,
            TRIM(image) AS image_url,
            create_date
        FROM bronze.hr_personal;

        SET @end_time = GETDATE();
        PRINT '>> Duração: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'OCORREU UM ERRO DURANTE O PROCESSO DE CARREGAMENTO';
        PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END