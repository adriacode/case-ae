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
SELECT DISTINCT department, position,
	   AVG(salary) OVER (PARTITION BY department) AS avg_salary,
	   PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) AS q1,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) AS median_salary,
	   PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) OVER (PARTITION BY department) AS q3,
	   STDEVP(salary) OVER (PARTITION BY department) AS stdev_salary,
	   COUNT(employee_id) OVER (PARTITION BY department, position) AS qtd_employee
FROM silver.hr_corporate
ORDER BY department;

-- =============================================================================
-- Criar: gold.view_tenure_days
-- =============================================================================

-- =============================================================================
-- Criar: gold.view_salary_by_department
-- =============================================================================