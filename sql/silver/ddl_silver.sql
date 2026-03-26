/*
===============================================================================
DDL Script: Criar Tabelas Silver
===============================================================================
Propósito do script:
    Este script é responsável por criar as tabelas na camada Silver, excluindo as tabelas existentes caso já existam.
    Rode este script para redefinir a estrutura DDL das tabelas da camada 'silver'.
===============================================================================
*/


IF OBJECT_ID('silver.hr_personal', 'U') IS NOT NULL
    DROP TABLE silver.hr_personal;
GO

CREATE TABLE silver.hr_personal (
    personal_id INT PRIMARY KEY,
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    full_name NVARCHAR(200),
    email NVARCHAR(150),
    phone NVARCHAR(20),
    birth_date DATE,
    gender NVARCHAR(1),
    street NVARCHAR(255),
    street_name NVARCHAR(255),
    building_number NVARCHAR(50),
    city NVARCHAR(100),
    zipcode NVARCHAR(50),
    country NVARCHAR(100),
    country_code NVARCHAR(10),
    latitude FLOAT,
    longitude FLOAT,
    create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.hr_corporate', 'U') IS NOT NULL
	DROP TABLE silver.hr_corporate;
GO

CREATE TABLE silver.hr_corporate (
	employee_id INT PRIMARY KEY,
	department NVARCHAR(50),
	position NVARCHAR(50),
	salary DECIMAL(10, 2),
	admission_date DATE,
	employment_type NVARCHAR(50),
    create_date DATETIME2 DEFAULT GETDATE()
);
GO