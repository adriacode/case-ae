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

-- 1. Identifica falhas de unicidade em chaves primárias vindas da origem
SELECT employee_id, COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2. Detecta ausência de identificadores obrigatórios nos dados brutos
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL;

-- 3. Identifica campos com espaços residuais que exigirão tratamento de TRIM
SELECT *
FROM bronze.hr_corporate
WHERE department LIKE ' %' OR department LIKE '% '
   OR position LIKE ' %' OR position LIKE '% '
   OR employment_type LIKE ' %' OR employment_type LIKE '% ';

-- 4. Avalia a dispersão de valores para planejar a padronização categórica
SELECT DISTINCT department FROM bronze.hr_corporate;
SELECT DISTINCT position FROM bronze.hr_corporate;
SELECT DISTINCT employment_type FROM bronze.hr_corporate;

-- 5. Valida a compatibilidade de conversão do campo salário para numérico
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(salary AS FLOAT) IS NULL;

-- 6. Valida a compatibilidade de conversão do campo data de admissão
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(admission_date AS DATE) IS NULL;

-- 7. Identifica registros com nulidade em colunas essenciais para o negócio
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL
   OR department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;

-- 8. Analisa a integridade das regras de negócio entre Cargo e Contrato
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY position, employment_type
ORDER BY position;

-- 9. Mapeia a nomenclatura de estagiários para aplicação de regras de enriquecimento
SELECT 
    position, 
    department, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY position, department
ORDER BY position;