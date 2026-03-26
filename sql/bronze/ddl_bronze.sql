/*
===============================================================================
DDL Script: Criar Tabelas Bronze
===============================================================================
Propósito do script:
    Este script é responsável por criar as tabelas na camada Bronze, excluindo as tabelas existentes caso já existam.
    Rode este script para redefinir a estrutura DDL das tabelas da camada 'bronze'.
===============================================================================
*/

IF OBJECT_ID('bronze.hr_personal', 'U') IS NOT NULL
    DROP TABLE bronze.hr_personal;
GO

CREATE TABLE bronze.hr_personal (
    id INT,
    firstname NVARCHAR(100),
    lastname NVARCHAR(100),
    email NVARCHAR(150),
    phone NVARCHAR(20),
    birthday NVARCHAR(50),
    gender NVARCHAR(20),
    street NVARCHAR(255),
    streetName NVARCHAR(255),
    buildingNumber NVARCHAR(50),
    city NVARCHAR(100),
    zipcode NVARCHAR(50),
    country NVARCHAR(100),
    country_code NVARCHAR(10),
    latitude NVARCHAR(50),
    longitude NVARCHAR(50),
    website NVARCHAR(255),
    image NVARCHAR(255),
    create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('bronze.hr_corporate', 'U') IS NOT NULL
	DROP TABLE bronze.hr_corporate;
GO

CREATE TABLE bronze.hr_corporate (
	employee_id INT,
	department NVARCHAR(50),
	position NVARCHAR(50),
	salary NVARCHAR(50),
	admission_date NVARCHAR(50),
	employment_type NVARCHAR(50),
    create_date DATETIME2 DEFAULT GETDATE()
);
GO