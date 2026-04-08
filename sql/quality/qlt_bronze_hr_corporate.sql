/*
===============================================================================
Testes de Qualidade - Camada Bronze (hr_corporate)
===============================================================================

Objetivo:
    Realizar validações de qualidade nos dados brutos da tabela 
    bronze.hr_corporate, garantindo visibilidade sobre possíveis inconsistências 
    antes do processo de transformação para a camada Silver.

Descrição:
    A camada Bronze representa dados ingeridos da origem sem tratamento.
    Portanto, este script tem caráter exclusivamente analítico, não devendo 
    realizar qualquer tipo de alteração nos dados.

Validações Aplicadas:

    1. Unicidade de chave primária (employee_id)
    2. Presença de identificadores obrigatórios
    3. Detecção de espaços indesejados em campos textuais
    4. Análise de domínio de valores categóricos
    5. Validação de conversão de tipos (salário → numérico)
    6. Validação de conversão de tipos (datas)
    7. Identificação de nulidade em campos críticos
    8. Consistência entre cargo (position) e tipo de contrato (employment_type)
    9. Identificação de padrões relacionados a estagiários (Intern)

Boas Práticas:
    - Executar este script antes da carga da camada Silver.
    - Não realizar UPDATE/DELETE nesta camada.
    - Utilizar os resultados para tratamento, padronização e enriquecimento na Silver.

===============================================================================
*/

-- 1. Verificação de duplicidade na chave primária (employee_id)
-- Identifica registros com possíveis problemas de unicidade
SELECT 
    employee_id, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;


-- 2. Verificação de chave primária nula
-- Identifica registros sem identificador único
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL;


-- 3. Detecção de espaços em branco indesejados (leading/trailing)
-- Indica necessidade de aplicação de TRIM na camada Silver
SELECT *
FROM bronze.hr_corporate
WHERE department LIKE ' %' OR department LIKE '% '
   OR position LIKE ' %' OR position LIKE '% '
   OR employment_type LIKE ' %' OR employment_type LIKE '% ';


-- 4. Análise de campos categóricos
SELECT DISTINCT department FROM bronze.hr_corporate;
SELECT DISTINCT position FROM bronze.hr_corporate;
SELECT DISTINCT employment_type FROM bronze.hr_corporate;


-- 5. Validação de conversão do campo salary para tipo numérico
-- Identifica valores inválidos ou inconsistentes
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(salary AS FLOAT) IS NULL;


-- 6. Validação de conversão do campo admission_date para tipo DATE
-- Identifica formatos inválidos de data
SELECT *
FROM bronze.hr_corporate
WHERE TRY_CAST(admission_date AS DATE) IS NULL;


-- 7. Verificação de nulidade em campos críticos
-- Identifica registros incompletos para uso analítico
SELECT *
FROM bronze.hr_corporate
WHERE employee_id IS NULL
   OR department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;


-- 8. Análise de consistência entre cargo e tipo de contrato
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
GROUP BY position, employment_type
ORDER BY position;


-- 9. Identificação de padrões de estagiários (Intern)
SELECT 
    position, 
    department, 
    COUNT(*) AS quantidade
FROM bronze.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY position, department
ORDER BY position;