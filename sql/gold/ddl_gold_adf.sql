/*
===============================================================================
DDL Script: Camada Gold (Business Views) - Azure Data Factory
===============================================================================
Descrição:
    Script adaptado para execução no Azure Data Factory (Script Activity),
    responsável por criar as views analíticas da camada Gold.

Objetivo:
    Consolidar dados tratados da camada Silver em métricas analíticas prontas
    para consumo em ferramentas de BI, como Power BI.

Características:
    - Não utiliza comandos 'GO' (compatível com ADF)
    - Utiliza EXEC para criação dinâmica das views
    - Inclui métricas estatísticas, retenção, demografia e qualidade de dados

Fonte:
    silver.hr_personal
    silver.hr_corporate

Observações:
    - As views são recriadas a cada execução 
===============================================================================
*/


-- =============================================================================
-- 1. View: gold.view_salary_by_dept
-- Objetivo:
--     Analisar distribuição salarial por departamento e cargo,
--     identificando tendência central, dispersão e outliers.
-- =============================================================================

IF OBJECT_ID('gold.view_salary_by_dept', 'V') IS NOT NULL 
    DROP VIEW gold.view_salary_by_dept;

EXEC('
CREATE VIEW gold.view_salary_by_dept AS

-- ============================================================================
-- Etapa 1: Cálculo de métricas salariais
-- ============================================================================
WITH salary_calculations AS
(
    SELECT DISTINCT department, position,

           AVG(salary) OVER (PARTITION BY department, position) AS avg_salary,

           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)
           OVER (PARTITION BY department, position) AS median_salary,

           STDEVP(salary) OVER (PARTITION BY department, position) AS stdev_salary,

           (STDEVP(salary) OVER (PARTITION BY department, position) /
            NULLIF(AVG(salary) OVER(PARTITION BY department, position), 0)) AS cv_salary,

           MIN(salary) OVER (PARTITION BY department, position) AS min_salary,
           MAX(salary) OVER (PARTITION BY department, position) AS max_salary,
           COUNT(employee_id) OVER (PARTITION BY department, position) AS qtd_employee

    FROM silver.hr_corporate
)

-- ============================================================================
-- Etapa 2: Classificação de outliers
-- ============================================================================
SELECT *,

       CASE 
            WHEN max_salary > (avg_salary * 1.5) THEN ''High Outlier''
            WHEN min_salary < (avg_salary * 0.5) THEN ''Low Outlier''
            ELSE ''Normal''
       END AS flag_salary

FROM salary_calculations
');


-- =============================================================================
-- 2. View: gold.view_tenure
-- Objetivo:
--     Monitorar tempo de empresa e classificar colaboradores em faixas de retenção.
-- =============================================================================

IF OBJECT_ID('gold.view_tenure', 'V') IS NOT NULL 
    DROP VIEW gold.view_tenure;

EXEC('
CREATE VIEW gold.view_tenure AS

-- ============================================================================
-- Etapa 1: Cálculo do tempo de empresa
-- ============================================================================
WITH tenure_calculation AS (
    SELECT 
        employee_id,
        department,
        employment_type,

        DATEDIFF(day, admission_date, GETDATE()) AS tenure_days

    FROM silver.hr_corporate
),

-- ============================================================================
-- Etapa 2: Classificação em faixas de retenção
-- ============================================================================
retention_bands AS (
    SELECT *,

        CASE 
            WHEN tenure_days < 365 THEN ''0-1 year''
            WHEN tenure_days BETWEEN 365 AND 1094 THEN ''1-3 years''
            WHEN tenure_days BETWEEN 1095 AND 1824 THEN ''3-5 years''
            ELSE ''5+ years''
        END AS retention_band

    FROM tenure_calculation
)

-- ============================================================================
-- Etapa 3: Métricas analíticas
-- ============================================================================
SELECT 
    employee_id,
    department,
    employment_type,
    tenure_days,
    retention_band,

    AVG(CAST(tenure_days AS FLOAT))
        OVER (PARTITION BY department, employment_type) AS avg_tenure,

    PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY tenure_days)
        OVER (PARTITION BY department, employment_type) AS median_tenure,

    COUNT(employee_id)
        OVER (PARTITION BY department, employment_type, retention_band) AS headcount_in_band

FROM retention_bands
');


-- =============================================================================
-- 3. View: gold.view_workforce_dashboard
-- Objetivo:
--     Consolidar KPIs de RH, incluindo demografia, retenção, salários,
--     headcount e qualidade de dados.
-- =============================================================================

IF OBJECT_ID('gold.view_workforce_dashboard', 'V') IS NOT NULL 
    DROP VIEW gold.view_workforce_dashboard;

EXEC('
CREATE VIEW gold.view_workforce_dashboard AS

-- ============================================================================
-- Etapa 1: Base integrada (join personal + corporate)
-- ============================================================================
WITH base_data AS (
    SELECT 
        c.employee_id,
        c.department,
        c.position,
        c.employment_type,
        c.salary,
        c.admission_date,

        p.gender,
        p.country,
        p.birth_date,

        DATEDIFF(DAY, c.admission_date, GETDATE()) AS tenure_days,
        DATEDIFF(YEAR, p.birth_date, GETDATE()) AS age_years,

        c.is_employment_type_adjusted,
        p.is_birth_date_suspect

    FROM silver.hr_corporate c
    INNER JOIN silver.hr_personal p 
        ON p.personal_id = c.employee_id
),

-- ============================================================================
-- Etapa 2: Enriquecimento (faixas + qualidade)
-- ============================================================================
enriched_data AS (
    SELECT *,

        CASE 
            WHEN is_birth_date_suspect = 1 OR age_years < 18 THEN ''Unknown / Review''
            WHEN age_years BETWEEN 18 AND 24 THEN ''18-24''
            WHEN age_years BETWEEN 25 AND 34 THEN ''25-34''
            WHEN age_years BETWEEN 35 AND 44 THEN ''35-44''
            WHEN age_years BETWEEN 45 AND 54 THEN ''45-54''
            ELSE ''55+''
        END AS age_band,

        CASE 
            WHEN tenure_days < 365 THEN ''0-1 Year''
            WHEN tenure_days BETWEEN 365 AND 1094 THEN ''1-3 Years''
            WHEN tenure_days BETWEEN 1095 AND 1824 THEN ''3-5 Years''
            ELSE ''5+ Years''
        END AS retention_band,

        CASE 
            WHEN tenure_days > 365 THEN 1 ELSE 0 
        END AS is_retained_gt_365d,

        CASE
             WHEN is_employment_type_adjusted = 1 
                  OR is_birth_date_suspect = 1 
                  OR country IS NULL OR country = '''' 
                  OR admission_date > GETDATE()
             THEN ''Requires Review''
             ELSE ''Clean Data''
        END AS data_quality_status

    FROM base_data
),

-- ============================================================================
-- Etapa 3: Métricas analíticas
-- ============================================================================
metrics_step AS (
    SELECT *,

        COUNT(*) OVER(PARTITION BY department, position) AS group_headcount,
        COUNT(*) OVER(PARTITION BY department) AS total_dept_headcount,
        COUNT(*) OVER() AS total_company_headcount,

        AVG(CAST(salary AS FLOAT)) OVER(PARTITION BY department, position) AS avg_salary_role,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary)
            OVER(PARTITION BY department, position) AS median_salary_role,
        STDEVP(salary) OVER(PARTITION BY department, position) AS stddev_salary_role,

        AVG(CAST(tenure_days AS FLOAT)) OVER(PARTITION BY department) AS avg_tenure_days_dept,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tenure_days)
            OVER(PARTITION BY department) AS median_tenure_days_dept,
        SUM(is_retained_gt_365d) OVER(PARTITION BY department) AS total_retained_gt_365d_dept

    FROM enriched_data
)

-- ============================================================================
-- Etapa 4: Saída final (camada de consumo BI)
-- ============================================================================
SELECT 
    employee_id,
    country,
    gender,
    age_band,
    department,
    position,
    employment_type,

    tenure_days,
    retention_band,
    CAST(avg_tenure_days_dept AS INT) AS avg_tenure_days_dept,
    CAST(median_tenure_days_dept AS INT) AS median_tenure_days_dept,
    CAST(total_retained_gt_365d_dept * 100.0 / NULLIF(total_dept_headcount, 0) AS DECIMAL(5,2)) AS pct_tenure_gt_365d,

    salary,
    CAST(avg_salary_role AS DECIMAL(10,2)) AS avg_salary_role,
    CAST(median_salary_role AS DECIMAL(10,2)) AS median_salary_role,
    CAST(stddev_salary_role AS DECIMAL(10,2)) AS stddev_salary_role,
    CAST(stddev_salary_role / NULLIF(avg_salary_role, 0) AS DECIMAL(5,4)) AS cv_salary,

    group_headcount AS headcount,
    total_dept_headcount,
    total_company_headcount,
    CAST(group_headcount * 100.0 / NULLIF(total_company_headcount, 0) AS DECIMAL(5,2)) AS pct_share_global,
    CAST(group_headcount * 100.0 / NULLIF(total_dept_headcount, 0) AS DECIMAL(5,2)) AS pct_share_within_department,

    data_quality_status,
    is_birth_date_suspect,
    is_employment_type_adjusted,

    DENSE_RANK() OVER(PARTITION BY department ORDER BY group_headcount DESC) AS position_rank_in_department

FROM metrics_step
');