/*
===============================================================================
DDL Script: Camada Silver
===============================================================================
Descrição:
    Criação das tabelas da camada Silver responsáveis por armazenar dados
    tratados, padronizados e validados a partir da camada Bronze.

Observações:
    - Os dados passam por transformação e tipagem adequada
    - Aplicação de regras de qualidade e padronização
    - Criação de campos derivados
===============================================================================
*/

-- Garantir existência do schema
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO

-- ============================================================================
-- Tabela: silver.hr_personal
-- Origem: bronze.hr_personal
-- ============================================================================

IF OBJECT_ID('silver.hr_personal', 'U') IS NOT NULL
    DROP TABLE silver.hr_personal;
GO

CREATE TABLE silver.hr_personal (
    personal_id INT NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    full_name NVARCHAR(200) NOT NULL,
    email NVARCHAR(150),
    phone NVARCHAR(20),
    birth_date DATE NOT NULL,
    is_birth_date_suspect BIT NOT NULL DEFAULT 0,
    gender NVARCHAR(1) NOT NULL,
    street NVARCHAR(255),
    street_name NVARCHAR(255),
    building_number NVARCHAR(50),
    city NVARCHAR(100) NOT NULL,
    zipcode NVARCHAR(50),
    country NVARCHAR(100) NOT NULL,
    country_code NVARCHAR(10) NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    website NVARCHAR(255),
    image_url NVARCHAR(255),
    create_date DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_hr_personal PRIMARY KEY (personal_id)
);
GO

-- ============================================================================
-- Tabela: silver.hr_corporate
-- Origem: bronze.hr_corporate
-- ============================================================================

IF OBJECT_ID('silver.hr_corporate', 'U') IS NOT NULL
    DROP TABLE silver.hr_corporate;
GO

CREATE TABLE silver.hr_corporate (
    employee_id INT NOT NULL,
    department NVARCHAR(100) NOT NULL,
    position NVARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    admission_date DATE NOT NULL,
    employment_type NVARCHAR(20) NOT NULL,
    is_employment_type_adjusted BIT NOT NULL DEFAULT 0,
    create_date DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_hr_corporate PRIMARY KEY (employee_id)
);
GO