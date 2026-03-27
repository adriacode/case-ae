/*
===============================================================================
DDL Script: Criar Gold Views
===============================================================================
Propósito do script:
     Este script é responsável por criar as views para a camada Gold do banco de dados.
     A camada Gold representa as tabelas dimensionais e de fatos finais (Star Schema).

     Cada view realiza transformações e combina dados da camada Silver 
     para produzir um conjunto de dados limpo, enriquecido e pronto para análise.

Utilização:
    - Estas views podem ser consultadas diretamente para análises e relatórios.
===============================================================================
*/

-- =============================================================================
-- Criar: gold.view_salary_by_department
-- =============================================================================
IF OBJECT_ID('gold.view_salary_by_department', 'V') IS NOT NULL
    DROP VIEW gold.view_salary_by_department;
GO

CREATE VIEW gold.view_salary_by_department AS
WITH salary_calculations AS
(
SELECT DISTINCT department, position,
	   AVG(salary) OVER (PARTITION BY department,position) AS avg_salary,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department, position) AS median_salary,
	   STDEVP(salary) OVER (PARTITION BY department, position) AS stdev_salary,
	   (STDEVP(salary) OVER (PARTITION BY department, position) / AVG(salary) OVER(PARTITION BY department, position)) AS cv_salary,
	   MIN(salary) OVER (PARTITION BY department, position) AS min_salary,
	   MAX(salary) OVER (PARTITION BY department, position) AS max_salary,
	   COUNT(employee_id) OVER (PARTITION BY department, position) AS qtd_employee
FROM silver.hr_corporate
) 
SELECT *,
	   CASE WHEN max_salary > (avg_salary * 1.5) THEN 'High Outlier'
			WHEN min_salary < (avg_salary * 0.5) THEN 'Low Outlier'
			ELSE 'Normal'
	   END AS flag_salary
FROM salary_calculations;
GO

-- =============================================================================
-- Criar: gold.view_tenure
-- =============================================================================
IF OBJECT_ID('gold.view_tenure', 'V') IS NOT NULL
	DROP VIEW gold.view_tenure;
GO

CREATE VIEW gold.view_tenure AS
WITH tenure_calculation AS (
    SELECT DISTINCT
        employee_id, 
        department, 
        employment_type,
        DATEDIFF(day, admission_date, GETDATE()) AS tenure_days
    FROM silver.hr_corporate 
),
retention_bands AS (
    SELECT 
        *,
        CASE 
            WHEN tenure_days < 365 THEN '0-1 year'
            WHEN tenure_days >= 365 AND tenure_days < 365*3 THEN '1-3 years'
            WHEN tenure_days >= 365*3 AND tenure_days < 365*5 THEN '3-5 years'
            ELSE '5+ years'
        END AS retention_band
    FROM tenure_calculation
)
SELECT DISTINCT
    department,
    employment_type,
    retention_band,
    AVG(CAST(tenure_days AS FLOAT)) OVER (PARTITION BY department, employment_type) AS avg_tenure,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tenure_days) OVER (PARTITION BY department, employment_type) AS median_tenure,
    COUNT(employee_id) OVER (PARTITION BY department, employment_type, retention_band) AS headcount_in_band
FROM retention_bands;
GO

-- =============================================================================
-- Criar: gold.view_workforce_dashboard
-- =============================================================================
IF OBJECT_ID('gold.view_workforce_dashboard', 'V') IS NOT NULL
	DROP VIEW gold.view_workforce_dashboard;
GO

CREATE VIEW gold.view_workforce_dashboard AS
WITH base_employees AS
(
SELECT c.employee_id, 
       c.department, 
       c.position, 
       c.employment_type,
       c.is_employment_type_adjusted,
       c.salary,
       p.gender, 
       p.country,
       p.is_birth_date_suspect,
       DATEDIFF(year, p.birth_date, GETDATE()) AS age_years,
       DATEDIFF(day, c.admission_date, GETDATE()) AS tenure_days
FROM silver.hr_corporate c
INNER JOIN silver.hr_personal p ON p.personal_id = c.employee_id
),
reference_data AS
(
    SELECT *,
           CASE 
               WHEN is_birth_date_suspect = 1 THEN 'Unvalid Birth Date'
               WHEN age_years >= 16 AND age_years <= 25 THEN '16-25'
               WHEN age_years > 25 AND age_years <= 35 THEN '26-35'
               WHEN age_years > 35 AND age_years <= 45 THEN '36-45'
               WHEN age_years > 45 AND age_years <= 60 THEN '46-60'
               ELSE '60+'
           END AS age_band,
           CASE 
               WHEN tenure_days < 365 THEN '0-1 year'
               WHEN tenure_days >= 365 AND tenure_days < 365*3 THEN '1-3 years'
               WHEN tenure_days >= 365*3 AND tenure_days < 365*5 THEN '3-5 years'
               ELSE '5+ years'
           END AS retention_band
    FROM base_employees
),
cross_tab AS
(
SELECT r.*,
       vs.avg_salary,
       vs.median_salary,
       vs.stdev_salary,
       vs.cv_salary,
       vs.min_salary,
       vs.max_salary,
       vs.flag_salary,
       vt.avg_tenure,
       vt.median_tenure,
       vt.headcount_in_band
FROM reference_data r
LEFT JOIN gold.view_salary_by_department vs ON r.department = vs.department AND r.position = vs.position
LEFT JOIN gold.view_tenure vt ON r.department = vt.department AND r.employment_type = vt.employment_type AND r.retention_band = vt.retention_band
)
SELECT *
FROM cross_tab;
GO