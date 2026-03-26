/*
===============================================================================
Testes de Qualidade - Camada Bronze (hr_corporate)
===============================================================================

Este script realiza verificações de qualidade nos dados da camada Bronze,
com o objetivo de identificar inconsistências antes da transformação para a
camada Silver.

As validações incluem:
    
- Verificação de chaves primárias nulas ou duplicadas.
- Identificação de espaços indesejados em campos de texto.
- Análise de padronização de valores categóricos.
- Validação de tipos de dados (numéricos e datas).
- Identificação de valores nulos em campos críticos.
- Análise de consistência entre cargo e tipo de contrato.

Notas de uso:
- Execute este script antes da construção da camada Silver.
- Os dados na Bronze NÃO devem ser alterados, apenas analisados.
- As inconsistências identificadas devem ser tratadas ou sinalizadas na Silver.

===============================================================================
*/

-- 1. Verificar duplicidade de employee_id
SELECT employee_id, COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2. Verificar employee_id nulos
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL;

-- 3. Verificar espaços indesejados (início ou fim)
SELECT *
FROM bronze.hr_corporate
WHERE department LIKE ' %'
   OR department LIKE '% '
   OR position LIKE ' %'
   OR position LIKE '% '
   OR employment_type LIKE ' %'
   OR employment_type LIKE '% ';

-- 4. Analisar valores distintos (padronização)
SELECT DISTINCT department FROM bronze.hr_corporate;
SELECT DISTINCT position FROM bronze.hr_corporate;
SELECT DISTINCT employment_type FROM bronze.hr_corporate;

-- 5. Verificar valores inválidos em salary (deve ser numérico)
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(salary AS FLOAT) IS NULL;

-- 6. Verificar valores inválidos em admission_date (deve ser data)
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(admission_date AS DATE) IS NULL;

-- 7. Verificar valores nulos em campos críticos
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL
   OR department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;

-- 8. Analisar relação entre cargo e tipo de contrato (consistência de negócio)
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY position, employment_type
ORDER BY position;

-- 9. Analisar padronização de cargos de estágio por departamento
SELECT 
    position, 
    department, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY position, department
ORDER BY position;