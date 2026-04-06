/*
===============================================================================
Testes de Qualidade - Camada Silver (hr_personal)
===============================================================================

Objetivo:
    Validar a qualidade dos dados após o processo de transformação da camada 
    Bronze para a camada Silver, garantindo consistência, padronização e 
    aderência às regras de negócio.

Contexto:
    A camada Silver contém dados limpos, tipados e enriquecidos, preparados 
    para consumo analítico e construção da camada Gold.

Princípios:
    - Nenhuma modificação deve ser realizada nesta etapa (somente análise).
    - Todas as inconsistências identificadas na Bronze devem estar tratadas.
    - Este script atua como validação final das regras aplicadas.

Validações Aplicadas:

    1. Unicidade da chave primária (personal_id)
    2. Presença de identificadores obrigatórios
    3. Nulidade em campos críticos
    4. Remoção de espaços indesejados (TRIM)
    5. Domínio padronizado do campo gênero
    6. Consistência de datas de nascimento
    7. Estrutura mínima de e-mail
    8. Integridade de números de telefone
    9. Validação de coordenadas geográficas
    10. Consistência entre país e código do país
    11. Identificação de duplicidade lógica
    12. Validação de códigos postais
    13. Presença de número do logradouro
    14. Validação da regra de auditoria de idade (flag)
    15. Métrica de qualidade da flag de idade

Boas Práticas:
    - Executar após a carga da camada Silver.
    - Utilizar como checklist de validação do pipeline.
    - Garantir que os dados estejam prontos para uso analítico.

===============================================================================
*/

-- 1. Verificação de duplicidade na chave primária (personal_id)
-- Garante unicidade dos registros
SELECT 
    personal_id, 
    COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY personal_id
HAVING COUNT(*) > 1;


-- 2. Verificação de chave primária nula
-- Identifica registros sem identificador único
SELECT *
FROM silver.hr_personal
WHERE personal_id IS NULL;


-- 3. Verificação de nulidade em campos críticos
-- Campos essenciais para identificação e análise
SELECT *
FROM silver.hr_personal
WHERE first_name IS NULL 
   OR last_name IS NULL 
   OR email IS NULL
   OR gender IS NULL
   OR birth_date IS NULL
   OR city IS NULL
   OR country IS NULL;


-- 4. Validação de remoção de espaços (TRIM)
-- Confirma limpeza de campos textuais
SELECT *
FROM silver.hr_personal
WHERE first_name LIKE ' %' OR first_name LIKE '% '
   OR last_name LIKE ' %' OR last_name LIKE '% '
   OR email LIKE ' %' OR email LIKE '% '
   OR city LIKE ' %' OR city LIKE '% '
   OR country LIKE ' %' OR country LIKE '% ';


-- 5. Validação de domínio do gênero
-- Garante padronização (M, F, U)
SELECT *
FROM silver.hr_personal
WHERE gender NOT IN ('M', 'F', 'U');


-- 6. Validação de datas de nascimento
-- Evita datas futuras ou fora de intervalo plausível
SELECT *
FROM silver.hr_personal
WHERE birth_date > GETDATE()
   OR birth_date < '1900-01-01';


-- 7. Validação da estrutura mínima de e-mail
-- Garante formato básico de comunicação
SELECT *
FROM silver.hr_personal
WHERE email NOT LIKE '%_@_%._%';


-- 8. Validação de telefone
-- Garante presença apenas de caracteres numéricos
SELECT *
FROM silver.hr_personal
WHERE phone LIKE '%[^0-9]%';


-- 9. Validação de coordenadas geográficas
-- Verifica limites físicos válidos
SELECT *
FROM silver.hr_personal
WHERE latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180;


-- 10. Validação de consistência país x código do país
-- Um país não deve possuir múltiplos códigos distintos
SELECT 
    country, 
    COUNT(DISTINCT country_code) AS qtd_codigos
FROM silver.hr_personal
GROUP BY country
HAVING COUNT(DISTINCT country_code) > 1;


-- 11. Identificação de duplicidade lógica
-- Mesma pessoa cadastrada com IDs diferentes
SELECT 
    first_name, 
    last_name, 
    email, 
    COUNT(*) AS quantidade
FROM silver.hr_personal
GROUP BY first_name, last_name, email
HAVING COUNT(*) > 1;


-- 12. Validação de códigos postais
-- Verifica nulidade ou tamanho mínimo esperado
SELECT *
FROM silver.hr_personal
WHERE zipcode IS NULL
   OR LEN(zipcode) < 3;


-- 13. Verificação de número do logradouro
-- Campo relevante para localização
SELECT *
FROM silver.hr_personal
WHERE building_number IS NULL;


-- 14. Validação da regra de auditoria de idade
-- Garante consistência da flag is_birth_date_suspect
SELECT *
FROM silver.hr_personal
WHERE is_birth_date_suspect = 0 
  AND (
        DATEDIFF(YEAR, birth_date, GETDATE()) < 18 
     OR DATEDIFF(YEAR, birth_date, GETDATE()) > 95
  );


-- 15. Métrica de qualidade da flag de idade
-- Avalia distribuição de registros suspeitos
SELECT 
    is_birth_date_suspect, 
    COUNT(*) AS total
FROM silver.hr_personal
GROUP BY is_birth_date_suspect;