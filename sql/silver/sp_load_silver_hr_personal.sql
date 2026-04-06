/*
===============================================================================
Stored Procedure: silver.load_silver_hr_personal
===============================================================================
Descrição:
    Realiza o processo de carga da tabela 'silver.hr_personal' a partir dos
    dados brutos da tabela 'bronze.hr_personal'.

Objetivo:
    Aplicar transformações, padronizações e regras de qualidade para garantir
    consistência e confiabilidade dos dados na camada Silver.

Fonte:
    bronze.hr_personal

Destino:
    silver.hr_personal

Transformações aplicadas:
    - Geração de chave surrogate (personal_id)
    - Padronização de strings (TRIM, LOWER, UPPER)
    - Criação de campo derivado (full_name)
    - Conversão de tipos (NVARCHAR → DATE, DECIMAL)
    - Normalização de domínio (gender → M/F/U)
    - Validação de qualidade de dados (idade suspeita)
    - Tratamento de coordenadas geográficas

Observações:
    - A tabela Silver é recarregada completamente (TRUNCATE + INSERT)
    - Flags de qualidade são geradas para auditoria e governança
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
        
        -- ============================================================================
        -- Etapa 1: Limpeza da tabela de destino (Full Load)
        -- ============================================================================
        PRINT '>> Truncando Tabela: silver.hr_personal';
        TRUNCATE TABLE silver.hr_personal;

        -- ============================================================================
        -- Etapa 2: Inserção com transformação e padronização
        -- ============================================================================
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
            -- Geração de identificador único sequencial (chave surrogate)
            ROW_NUMBER() OVER(ORDER BY create_date, firstname, lastname) AS personal_id,
            
            -- Padronização de nomes
            TRIM(firstname) AS first_name,
            TRIM(lastname) AS last_name,
            CONCAT(TRIM(firstname), ' ', TRIM(lastname)) AS full_name,
            
            -- Normalização de e-mail (lowercase)
            LOWER(TRIM(email)) AS email,
            
            TRIM(phone) AS phone,
            
            -- Conversão de data
            TRY_CAST(birthday AS DATE) AS birth_date,
            
            -- Regra de qualidade: idade suspeita
            CASE 
                WHEN DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) < 18 
                  OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) > 95
                  OR TRY_CAST(birthday AS DATE) > GETDATE()
                THEN 1
                ELSE 0
            END AS is_birth_date_suspect,
            
            -- Padronização de gênero
            CASE 
                WHEN UPPER(TRIM(gender)) IN ('MALE', 'M') THEN 'M'
                WHEN UPPER(TRIM(gender)) IN ('FEMALE', 'F') THEN 'F'
                ELSE 'U' 
            END AS gender,

            -- Endereço normalizado
            TRIM(street) AS street,
            TRIM(streetName) AS street_name,
            TRIM(buildingNumber) AS building_number,
            TRIM(city) AS city,
            TRIM(zipcode) AS zipcode,
            TRIM(country) AS country,
            TRIM(country_code) AS country_code,
            
            -- Conversão de coordenadas geográficas
            TRY_CAST(latitude AS DECIMAL(9, 6)) AS latitude,
            TRY_CAST(longitude AS DECIMAL(9, 6)) AS longitude,
            
            TRIM(website) AS website,
            TRIM(image) AS image_url,
            create_date
        FROM bronze.hr_personal;

        -- ============================================================================
        -- Etapa 3: Log de execução
        -- ============================================================================
        SET @end_time = GETDATE();

        PRINT '>> Duração do carregamento: ' 
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
            + ' segundos';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'OCORREU UM ERRO DURANTE O PROCESSO DE CARREGAMENTO';
        PRINT 'Mensagem de erro: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END