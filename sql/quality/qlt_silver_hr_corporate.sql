/*
===============================================================================
Testes de Qualidade - Camada Silver (hr_corporate)
===============================================================================

Objetivo:
    Validar a qualidade dos dados após o processo de transformação da camada 
    Bronze para a camada Silver, garantindo consistência, padronização e aderência 
    às regras de negócio.

Contexto:
    A camada Silver contém dados tratados, limpos e enriquecidos, prontos para 
    consumo analítico ou posterior modelagem (Gold).

Princípios:
    - Nenhuma modificação deve ser realizada nesta camada (somente análise).
    - Todas as regras de qualidade devem estar resolvidas a partir da transformação.
    - Este script valida se as regras aplicadas na Silver foram eficazes.

Validações Aplicadas:

    1. Unicidade da chave primária (employee_id)
    2. Presença de identificadores obrigatórios
    3. Remoção de espaços indesejados (TRIM)
    4. Padronização de valores categóricos
    5. Nulidade em campos críticos
    6. Validação de regras financeiras (salário)
    7. Consistência temporal (datas de admissão)
    8. Domínio controlado de tipos de contrato
    9. Consistência entre cargo e tipo de contrato
    10. Validação de enriquecimento para estagiários

Boas Práticas:
    - Executar após a carga da camada Silver.
    - Utilizar como checklist de validação do pipeline.
    - Garantir que nenhuma inconsistência da Bronze permaneça.

===============================================================================
*/

-- 1. Verificação de duplicidade na chave primária (employee_id)
-- Garante unicidade dos registros
SELECT 
    employee_id, 
    COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;


-- 2. Verificação de chave primária nula
-- Identifica registros sem identificador único
SELECT *
FROM silver.hr_corporate
WHERE employee_id IS NULL;


-- 3. Validação de remoção de espaços (TRIM)
-- Confirma que não há espaços no início/fim dos campos textuais
SELECT *
FROM silver.hr_corporate
WHERE department LIKE ' %' OR department LIKE '% '
   OR position LIKE ' %' OR position LIKE '% '
   OR employment_type LIKE ' %' OR employment_type LIKE '% ';


-- 4. Análise de domínio dos campos categóricos
-- Permite validação visual da padronização aplicada
SELECT DISTINCT department FROM silver.hr_corporate ORDER BY department;
SELECT DISTINCT position FROM silver.hr_corporate ORDER BY position;
SELECT DISTINCT employment_type FROM silver.hr_corporate ORDER BY employment_type;


-- 5. Verificação de nulidade em campos críticos
SELECT *
FROM silver.hr_corporate
WHERE department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;


-- 6. Validação de regras financeiras
-- Garante que salários sejam positivos
SELECT *
FROM silver.hr_corporate
WHERE salary <= 0;


-- 7. Validação de consistência temporal
-- Evita datas futuras ou fora do intervalo esperado
SELECT *
FROM silver.hr_corporate
WHERE admission_date > GETDATE()
   OR admission_date < '1990-01-01';


-- 8. Validação do tipo de contrato
-- Garante padronização em UPPER CASE e valores permitidos
SELECT *
FROM silver.hr_corporate
WHERE employment_type NOT IN ('CLT', 'INTERN', 'PJ', 'TEMPORARY');


-- 9. Análise de consistência entre cargo e tipo de contrato
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY position, employment_type
ORDER BY position;


-- 10. Validação de enriquecimento para estagiários
-- Confirma categorização adequada dos registros "Intern"
SELECT 
    department,
    COUNT(*) AS total_interns
FROM silver.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY department
ORDER BY total_interns DESC;

-- 11. Quantidade de colaboradores por tipo de contrato
SELECT 
    employment_type, 
    COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY employment_type
ORDER BY quantidade DESC;

-- 12. Total de registros que precisaram de ajuste no tipo de contrato
SELECT 
    is_employment_type_adjusted, 
    COUNT(*) AS total
FROM silver.hr_corporate
GROUP BY is_employment_type_adjusted;

-- 13. Total de registros com data de nascimento suspeita
SELECT 
    is_birth_date_suspect, 
    COUNT(*) AS total
FROM silver.hr_personal
GROUP BY is_birth_date_suspect;