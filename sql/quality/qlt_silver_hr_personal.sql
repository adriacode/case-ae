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

-- 1. Garante a unicidade dos registros e a integridade da chave primária
SELECT personal_id, COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY personal_id
HAVING COUNT(*) > 1;

-- 2. Identifica registros sem o identificador obrigatório do funcionário
SELECT *
FROM silver.hr_personal
WHERE personal_id IS NULL;

-- 3. Identifica a ausência de dados em colunas críticas para identificação
SELECT *
FROM silver.hr_personal
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR email IS NULL
   OR gender IS NULL
   OR birth_date IS NULL
   OR city IS NULL
   OR country IS NULL;

-- 4. Valida se a limpeza de espaços (TRIM) foi aplicada corretamente nos campos demográficos
SELECT *
FROM silver.hr_personal
WHERE first_name LIKE ' %' OR first_name LIKE '% '
   OR last_name LIKE ' %' OR last_name LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR city LIKE ' %' OR city LIKE '% '
   OR country LIKE ' %' OR country LIKE '% ';

-- 5. Garante que o gênero esteja restrito ao domínio padronizado (M/F/U)
SELECT *
FROM silver.hr_personal
WHERE gender NOT IN ('M', 'F', 'U');

-- 6. Valida a consistência da data de nascimento (impede datas futuras ou irreais)
SELECT *
FROM silver.hr_personal
WHERE birth_date > GETDATE()
   OR birth_date < '1900-01-01';

-- 7. Garante a integridade mínima da estrutura de comunicação (e-mail)
SELECT *
FROM silver.hr_personal
WHERE email NOT LIKE '%_@_%._%';

-- 8. Valida se o campo de telefone contém apenas caracteres numéricos
SELECT *
FROM silver.hr_personal
WHERE phone LIKE '%[^0-9]%';

-- 9. Valida se as coordenadas geográficas estão dentro dos limites físicos reais
SELECT *
FROM silver.hr_personal
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180;

-- 10. Valida a integridade referencial entre o nome do país e seu respectivo código
SELECT country, COUNT(DISTINCT country_code) AS qtd_codigos
FROM silver.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;

-- 11. Identifica duplicidade lógica (mesma pessoa cadastrada com IDs diferentes)
SELECT first_name, last_name, email, COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;

-- 12. Valida a obrigatoriedade e o formato mínimo do código postal (zipcode)
SELECT *
FROM silver.hr_personal
WHERE zipcode IS NULL
   OR LEN(zipcode) < 3;

-- 13. Identifica ausência de dados no número do logradouro (building_number)
SELECT *
FROM silver.hr_personal
WHERE building_number IS NULL;

-- 14. Valida se a flag de auditoria de idade foi aplicada corretamente (>95 ou <18)
SELECT *
FROM silver.hr_personal
WHERE is_birth_date_suspect = 0 
  AND (DATEDIFF(YEAR, birth_date, GETDATE()) < 18 
       OR DATEDIFF(YEAR, birth_date, GETDATE()) > 95);

-- 15. Fornece métrica de impacto sobre a saúde dos dados carregados (Informativo)
SELECT is_birth_date_suspect, COUNT(*) AS total
FROM silver.hr_personal
GROUP BY is_birth_date_suspect;