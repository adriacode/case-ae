/*
===============================================================================
Testes de Qualidade - Camada Bronze (hr_personal)
===============================================================================

Objetivo:
    Executar validações de qualidade sobre os dados brutos da tabela 
    bronze.hr_personal, identificando inconsistências antes do processo 
    de transformação para a camada Silver.

Contexto:
    Os dados são provenientes de uma API externa, podendo conter variações 
    de formato, inconsistências estruturais e problemas de padronização.

Princípios:
    - A camada Bronze é imutável (somente leitura).
    - Este script possui caráter exclusivamente analítico.
    - Nenhuma correção deve ser aplicada nesta etapa.
    - Os problemas identificados devem ser tratados na camada Silver.

Validações Aplicadas:

    1. Unicidade da chave primária (id)
    2. Presença de identificadores obrigatórios
    3. Nulidade em campos críticos de identificação e localização
    4. Detecção de espaços indesejados em campos textuais
    5. Validação estrutural de e-mails
    6. Verificação de integridade em números de telefone
    7. Consistência e validade de datas de nascimento
    8. Análise de domínio do campo gênero
    9. Validação de caracteres em campos nominais
    10. Validação de coordenadas geográficas
    11. Consistência entre país e código do país
    12. Validação de URLs (website e image)
    13. Identificação de duplicidade lógica de pessoas
    14. Validação de códigos postais
    15. Presença de número do logradouro (buildingNumber)

Boas Práticas:
    - Executar antes da carga da camada Silver.
    - Utilizar os resultados como base para regras de limpeza e enriquecimento.
    - Documentar inconsistências relevantes para rastreabilidade.

===============================================================================
*/

-- 1. Verificação de duplicidade na chave primária (id)
-- Identifica registros com possíveis conflitos de unicidade
SELECT 
    id, 
    COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY id
HAVING COUNT(*) > 1;


-- 2. Verificação de chave primária nula
-- Identifica registros sem identificador único
SELECT *
FROM bronze.hr_personal
WHERE id IS NULL;


-- 3. Verificação de nulidade em campos críticos
-- Campos essenciais para identificação e localização
SELECT *
FROM bronze.hr_personal
WHERE firstname IS NULL 
   OR lastname IS NULL 
   OR email IS NULL 
   OR gender IS NULL 
   OR birthday IS NULL 
   OR city IS NULL 
   OR zipcode IS NULL 
   OR country IS NULL 
   OR latitude IS NULL 
   OR longitude IS NULL;


-- 4. Detecção de espaços em branco indesejados (leading/trailing)
-- Indica necessidade de TRIM na camada Silver
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE ' %' OR firstname LIKE '% '
   OR lastname LIKE ' %' OR lastname LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR phone LIKE ' %' OR phone LIKE '% '
   OR country LIKE ' %' OR country LIKE '% ';


-- 5. Validação da estrutura de e-mails
-- Identifica formatos inválidos antes da normalização (LOWER)
SELECT email
FROM bronze.hr_personal
WHERE email NOT LIKE '%@%.%' 
   OR email LIKE '%@%@%';


-- 6. Verificação de caracteres não numéricos em telefone
-- Identifica inconsistências no padrão esperado
SELECT phone
FROM bronze.hr_personal
WHERE phone LIKE '%[^0-9]%';


-- 7. Validação de datas de nascimento
-- Identifica datas inválidas e idades fora do padrão (<18 ou >95)
SELECT 
    id, 
    birthday, 
    DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) AS age_calculated
FROM bronze.hr_personal
WHERE TRY_CAST(birthday AS DATE) IS NULL
   OR TRY_CAST(birthday AS DATE) > GETDATE()
   OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) < 18
   OR DATEDIFF(YEAR, TRY_CAST(birthday AS DATE), GETDATE()) > 95;


-- 8. Análise de domínio do campo gender
-- Suporte à padronização (ex: M, F, U)
SELECT DISTINCT gender 
FROM bronze.hr_personal;


-- 9. Validação de caracteres em nomes
-- Detecta presença de números ou caracteres inválidos
SELECT *
FROM bronze.hr_personal
WHERE firstname LIKE '%[^a-zA-Z ''-]%' 
   OR lastname LIKE '%[^a-zA-Z ''-]%';


-- 10. Validação de coordenadas geográficas
-- Verifica conversão e limites válidos (latitude: -90 a 90 / longitude: -180 a 180)
SELECT *
FROM bronze.hr_personal
WHERE TRY_CAST(latitude AS FLOAT) NOT BETWEEN -90 AND 90
   OR TRY_CAST(longitude AS FLOAT) NOT BETWEEN -180 AND 180;


-- 11. Validação de consistência entre país e código do país
-- Um país não deve possuir múltiplos códigos distintos
SELECT 
    country, 
    COUNT(DISTINCT country_code) AS qtd_codigos
FROM bronze.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;


-- 12. Validação de URLs (website e image)
-- Verifica presença de protocolo HTTP/HTTPS
SELECT *
FROM bronze.hr_personal
WHERE website NOT LIKE 'http%' 
   OR image NOT LIKE 'http%';


-- 13. Identificação de duplicidade lógica
-- Mesma pessoa cadastrada com IDs diferentes
SELECT 
    firstname, 
    lastname, 
    email, 
    COUNT(*) AS quantidade
FROM bronze.hr_personal
GROUP BY firstname, lastname, email
HAVING COUNT(*) > 1;


-- 14. Validação de códigos postais
-- Verifica nulidade ou tamanho mínimo esperado
SELECT *
FROM bronze.hr_personal
WHERE zipcode IS NULL 
   OR LEN(zipcode) < 3;


-- 15. Verificação de número do logradouro
-- Campo importante para localização
SELECT *
FROM bronze.hr_personal
WHERE buildingNumber IS NULL;