/*
===============================================================================
Testes de Qualidade - Camada Bronze (hr_personal)
===============================================================================

Objetivo:
    Este script realiza verificações de qualidade nos dados da camada Bronze,
    com o objetivo de identificar inconsistências antes da transformação para a
    camada Silver.

Princípios:
    - A camada Bronze NÃO deve ser alterada.
    - Apenas análise e identificação de problemas.
    - As correções serão aplicadas na camada Silver.

===============================================================================
*/

-- Visualização geral
SELECT * FROM bronze.hr_personal;

-- 1. Verificar duplicidade de ID
SELECT id, COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY id
HAVING COUNT(*) > 1;

-- 2. Verificar ID nulo
SELECT *
FROM bronze.hr_personal
WHERE id IS NULL;

-- 3. Verificar campos obrigatórios nulos
SELECT *
FROM bronze.hr_personal
WHERE firstname IS NULL 
   OR lastname IS NULL 
   OR email IS NULL
   OR gender IS NULL
   OR birthday IS NULL
   OR street IS NULL
   OR streetName IS NULL
   OR buildingNumber IS NULL
   OR city IS NULL
   OR zipcode IS NULL
   OR country IS NULL
   OR country_code IS NULL
   OR latitude IS NULL
   OR longitude IS NULL;

-- 4. Verificar espaços indesejados (trim)
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE ' %' OR firstname LIKE '% '
   OR lastname LIKE ' %' OR lastname LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR phone LIKE ' %' OR phone LIKE '% '
   OR gender LIKE ' %' OR gender LIKE '% '
   OR street LIKE ' %' OR street LIKE '% '
   OR streetName LIKE ' %' OR streetName LIKE '% '
   OR buildingNumber LIKE ' %' OR buildingNumber LIKE '% '
   OR zipcode LIKE ' %' OR zipcode LIKE '% '
   OR country LIKE ' %' OR country LIKE '% '
   OR country_code LIKE ' %' OR country_code LIKE '% ';

-- 5. Validar formato de email
SELECT email
FROM bronze.hr_personal
WHERE email NOT LIKE '%_@_%._%';

-- 6. Validar telefone (apenas números)
SELECT phone
FROM bronze.hr_personal
WHERE phone LIKE '%[^0-9]%';

-- 7. Validar datas (birthday)
SELECT *
FROM bronze.hr_personal
WHERE TRY_CAST(birthday AS DATE) IS NULL
   OR birthday > GETDATE()
   OR birthday < '1900-01-01';

-- 8. Validar valores de gênero
SELECT DISTINCT gender
FROM bronze.hr_personal;

SELECT *
FROM bronze.hr_personal
WHERE LOWER(gender) NOT IN ('male', 'female');

-- 9. Validar caracteres inválidos em nomes
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE '%[^a-zA-Z ''-]%'
   OR lastname LIKE '%[^a-zA-Z ''-]%';

-- 10. Validar latitude e longitude
SELECT *
FROM bronze.hr_personal
WHERE TRY_CAST(latitude AS FLOAT) IS NULL
   OR TRY_CAST(longitude AS FLOAT) IS NULL
   OR TRY_CAST(latitude AS FLOAT) NOT BETWEEN -90 AND 90
   OR TRY_CAST(longitude AS FLOAT) NOT BETWEEN -180 AND 180;

-- 11. Consistência país vs código do país
SELECT country, COUNT(DISTINCT country_code) AS qtd_codigos
FROM bronze.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;

-- 12. Validar estrutura de URLs (website e image)
SELECT *
FROM bronze.hr_personal
WHERE website NOT LIKE 'http%'
   OR image NOT LIKE 'http%';

-- 13. Verificar duplicidade de registros (além do ID)
SELECT firstname, lastname, email, COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY firstname, lastname, email
HAVING COUNT(*) > 1;

-- 14. Verificar zipcode inválido (tratado como string)
SELECT *
FROM bronze.hr_personal
WHERE zipcode IS NULL
   OR LEN(zipcode) < 3;

-- 15. Verificar buildingNumber inválido
SELECT *
FROM bronze.hr_personal
WHERE buildingNumber IS NULL;