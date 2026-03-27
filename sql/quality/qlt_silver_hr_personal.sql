/*
===============================================================================
Testes de Qualidade - Camada Silver (hr_personal)
===============================================================================

Objetivo:
    Validar a qualidade dos dados após transformação da Bronze.

Regras:
    - Dados devem estar limpos, tipados e padronizados
    - Nenhuma alteração deve ser feita aqui

===============================================================================
*/

-- 1. Verificar duplicidade de personal_id
SELECT personal_id, COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY personal_id
HAVING COUNT(*) > 1;

-- 2. Verificar personal_id nulos
SELECT *
FROM silver.hr_personal
WHERE personal_id IS NULL;

-- 3. Verificar campos obrigatórios nulos
SELECT *
FROM silver.hr_personal
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR email IS NULL
   OR gender IS NULL
   OR birth_date IS NULL
   OR city IS NULL
   OR country IS NULL;

-- 4. Verificar espaços indesejados
SELECT *
FROM silver.hr_personal
WHERE first_name LIKE ' %' OR first_name LIKE '% '
   OR last_name LIKE ' %' OR last_name LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR city LIKE ' %' OR city LIKE '% '
   OR country LIKE ' %' OR country LIKE '% ';

-- 5. Validar domínio de gender
SELECT *
FROM silver.hr_personal
WHERE gender NOT IN ('M', 'F');

-- 6. Validar birth_date
SELECT *
FROM silver.hr_personal
WHERE birth_date > GETDATE()
   OR birth_date < '1900-01-01';

-- 7. Validar email (estrutura básica ainda válida)
SELECT *
FROM silver.hr_personal
WHERE email NOT LIKE '%_@_%._%';

-- 8. Validar telefone (somente números)
SELECT *
FROM silver.hr_personal
WHERE phone LIKE '%[^0-9]%';

-- 9. Validar latitude e longitude
SELECT *
FROM silver.hr_personal
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180;

-- 10. Consistência país vs código
SELECT country, COUNT(DISTINCT country_code) AS qtd_codigos
FROM silver.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;

-- 11. Duplicidade lógica (mesma pessoa)
SELECT first_name, last_name, email, COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- 12. Validar zipcode
SELECT *
FROM silver.hr_personal
WHERE zipcode IS NULL
   OR LEN(zipcode) < 3;

-- 13. Validar building_number
SELECT *
FROM silver.hr_personal
WHERE building_number IS NULL;

-- 14. Validar se a flag de suspeita de idade está correta
-- O teste deve retornar 0 linhas se a lógica da Procedure estiver certa.
SELECT *
FROM silver.hr_personal
WHERE is_birth_date_suspect = 0 
  AND (DATEDIFF(YEAR, birth_date, GETDATE()) < 16 
       OR DATEDIFF(YEAR, birth_date, GETDATE()) > 90);

-- 15. Verificar o impacto da qualidade (Informativo)
SELECT is_birth_date_suspect, COUNT(*) AS total
FROM silver.hr_personal
GROUP BY is_birth_date_suspect;