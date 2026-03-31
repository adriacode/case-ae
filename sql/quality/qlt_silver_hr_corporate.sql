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

-- 1. Garante a unicidade dos registros e evita duplicados na chave primária
SELECT employee_id, COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- 2. Identifica registros sem o identificador obrigatório do funcionário
SELECT *
FROM silver.hr_corporate
WHERE employee_id IS NULL;

-- 3. Valida se a limpeza de espaços (TRIM) foi aplicada corretamente em campos de texto
SELECT *
FROM silver.hr_corporate
WHERE department LIKE ' %' OR department LIKE '% '
   OR position LIKE ' %' OR position LIKE '% '
   OR employment_type LIKE ' %' OR employment_type LIKE '% ';

-- 4. Permite validar visualmente a padronização e agrupamento dos valores categóricos
SELECT DISTINCT department FROM silver.hr_corporate ORDER BY department;
SELECT DISTINCT position FROM silver.hr_corporate ORDER BY position;
SELECT DISTINCT employment_type FROM silver.hr_corporate ORDER BY employment_type;

-- 5. Identifica a ausência de dados em colunas críticas para o processamento da folha
SELECT *
FROM silver.hr_corporate
WHERE department IS NULL
   OR position IS NULL
   OR salary IS NULL
   OR admission_date IS NULL;

-- 6. Garante a integridade financeira impedindo salários negativos ou zerados
SELECT *
FROM silver.hr_corporate
WHERE salary <= 0;

-- 7. Valida a consistência temporal das admissões (evita datas futuras ou muito antigas)
SELECT *
FROM silver.hr_corporate
WHERE admission_date > GETDATE()
   OR admission_date < '1990-01-01';

-- 8. Garante que os tipos de contrato estejam restritos ao domínio permitido (Upper Case)
SELECT *
FROM silver.hr_corporate
WHERE employment_type NOT IN ('CLT', 'INTERN', 'PJ', 'TEMPORARY');

-- 9. Valida se a regra de negócio de alinhamento entre Cargo e Contrato foi eficaz
SELECT 
    position, 
    employment_type, 
    COUNT(*) AS quantidade
FROM silver.hr_corporate
GROUP BY position, employment_type
ORDER BY position;

-- 10. Valida o enriquecimento dos nomes de cargos para a categoria de estagiários
SELECT 
    department,
    COUNT(*) AS total_interns
FROM silver.hr_corporate
WHERE position LIKE '%Intern%'
GROUP BY department
ORDER BY total_interns DESC;