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

-- 1. Identifica falhas de unicidade nos IDs gerados pela API de origem
SELECT id, COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY id
HAVING COUNT(*) > 1;

-- 2. Detecta ausência de identificadores obrigatórios nos dados brutos
SELECT *
FROM bronze.hr_personal
WHERE id IS NULL;

-- 3. Identifica registros com nulidade em colunas essenciais de identificação e localização
SELECT *
FROM bronze.hr_personal
WHERE firstname IS NULL OR lastname IS NULL OR email IS NULL OR gender IS NULL OR birthday IS NULL 
   OR city IS NULL OR zipcode IS NULL OR country IS NULL OR latitude IS NULL OR longitude IS NULL;

-- 4. Identifica campos com espaços residuais que exigirão tratamento de TRIM na Silver
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE ' %' OR firstname LIKE '% '
   OR lastname LIKE ' %' OR lastname LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR phone LIKE ' %' OR phone LIKE '% '
   OR country LIKE ' %' OR country LIKE '% ';

-- 5. Valida a integridade da estrutura de e-mail antes da normalização (LOWER)
SELECT email
FROM bronze.hr_personal
WHERE email NOT LIKE '%@%.%' OR email LIKE '%@%@%';

-- 6. Verifica a presença de caracteres não numéricos em campos de telefone
SELECT phone
FROM bronze.hr_personal
WHERE phone LIKE '%[^0-9]%';

-- 7. Avalia a compatibilidade de conversão e consistência das datas de nascimento
-- Identifica idades fora do padrão corporativo (< 18 ou > 95)
SELECT id, birthday, DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) AS age_calculated
FROM bronze.hr_personal
WHERE TRY_CAST(birthday AS DATE) IS NULL
   OR TRY_CAST(birthday AS DATE) > GETDATE()
   OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) < 18
   OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) > 95;

-- 8. Analisa a dispersão de valores de gênero para planejar a padronização (M/F/U)
SELECT DISTINCT gender FROM bronze.hr_personal;

-- 9. Detecta caracteres especiais ou números em campos nominais
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE '%[^a-zA-Z ''-]%' OR lastname LIKE '%[^a-zA-Z ''-]%';

-- 10. Valida se as coordenadas geográficas podem ser convertidas para FLOAT e estão em limites reais
SELECT *
FROM bronze.hr_personal
WHERE TRY_CAST(latitude AS FLOAT) NOT BETWEEN -90 AND 90
   OR TRY_CAST(longitude AS FLOAT) NOT BETWEEN -180 AND 180;

-- 11. Valida a integridade referencial entre o nome do país e seu código na origem
SELECT country, COUNT(DISTINCT country_code) AS qtd_codigos
FROM bronze.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;

-- 12. Verifica a validade dos prefixos de protocolos em campos de URL
SELECT *
FROM bronze.hr_personal
WHERE website NOT LIKE 'http%' OR image NOT LIKE 'http%';

-- 13. Identifica duplicidade lógica (mesma pessoa com IDs diferentes) na fonte
SELECT firstname, lastname, email, COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY firstname, lastname, email
HAVING COUNT(*) > 1;

-- 14. Valida a presença e o formato mínimo esperado para códigos postais
SELECT *
FROM bronze.hr_personal
WHERE zipcode IS NULL OR LEN(zipcode) < 3;

-- 15. Detecta ausência de dados no número do logradouro nos dados brutos
SELECT *
FROM bronze.hr_personal
WHERE buildingNumber IS NULL;