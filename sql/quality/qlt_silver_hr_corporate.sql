/*
===============================================================================
Testes de Qualidade - Camada Silver (hr_corporate)
===============================================================================

Objetivo:
    Validar a qualidade dos dados após transformação da camada Bronze para Silver.

Regras:
    - A Silver deve conter dados limpos e padronizados
    - Nenhuma alteração deve ser feita aqui, apenas análise

===============================================================================
*/

-- 1. Verificar duplicidade de employee_id
SELECT employee_id, COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2. Verificar employee_id nulos
SELECT *
FROM silver.hr_corporate
WHERE employee_id IS NULL;

-- 3. Verificar espaços indesejados
SELECT *
FROM silver.hr_corporate
WHERE department LIKE ' %'
   OR department LIKE '% '
   OR position LIKE ' %'
   OR position LIKE '% '
   OR employment_type LIKE ' %'
   OR employment_type LIKE '% ';

-- 4. Padronização de valores categóricos
SELECT DISTINCT department FROM silver.hr_corporate ORDER BY department;
SELECT DISTINCT position FROM silver.hr_corporate ORDER BY position;
SELECT DISTINCT employment_type FROM silver.hr_corporate ORDER BY employment_type;

-- 5. Verificar valores nulos em campos críticos
SELECT *
FROM silver.hr_corporate
WHERE employee_id IS NULL
   OR department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;

-- 6. Validar salary (não pode ser negativo ou zero)
SELECT *
FROM silver.hr_corporate
WHERE salary <= 0;

-- 7. Validar admission_date
SELECT *
FROM silver.hr_corporate
WHERE admission_date > GETDATE()
   OR admission_date < '1990-01-01';

-- 8. Validar domínio de employment_type
SELECT *
FROM silver.hr_corporate
WHERE employment_type NOT IN ('CLT', 'INTERN', 'PJ', 'TEMPORARY');

-- 9. Consistência entre cargo e tipo de contrato
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY position, employment_type
ORDER BY position;

-- 10. Interns por departamento
SELECT 
    department,
    COUNT(*) AS total_interns
FROM silver.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY department
ORDER BY total_interns DESC;