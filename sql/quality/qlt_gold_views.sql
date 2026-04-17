/*
===============================================================================
Validação de Negócio e Consistência Final - Camada Gold
===============================================================================

Objetivo:
    Garantir que os KPIs apresentados para a diretoria (Headcount, Salários 
    e Retenção) estão consistentes e sem duplicidades.

Validações Aplicadas:
    1. Integridade de Headcount entre camadas (Bronze vs Silver vs Gold)
    2. Auditoria de Status Salarial (Normal vs Outlier)
    3. Distribuição de Retenção (Contagem de indivíduos únicos)

===============================================================================
*/

-- 1. Verificação de Consistência de Headcount (Total de Funcionários)
-- O objetivo é garantir que o pipeline não perdeu nenhum registro (Total esperado: 3000)
SELECT 'Bronze (Raw)' AS camada, COUNT(*) AS total FROM bronze.hr_personal
UNION ALL
SELECT 'Silver (Tratado)' AS camada, COUNT(*) AS total FROM silver.hr_personal
UNION ALL
SELECT 'Gold (Painel Geral)' AS camada, COUNT(*) AS total FROM gold.view_workforce_dashboard;


-- 2. Validação de Outliers Salariais 
-- Confirma se todos os colaboradores estão dentro da faixa 'Normal'
SELECT 
    flag_salary, 
    SUM(qtd_employee) AS total_colaboradores,
    FORMAT(SUM(qtd_employee) * 1.0 / 3000, 'P') AS percentual_conformidade
FROM gold.view_salary_by_dept
GROUP BY flag_salary;


-- 3. Contagem de Colaboradores por Faixa de Retenção 
-- Utiliza COUNT(DISTINCT) para evitar duplicidade de soma em views agregadas
SELECT 
    retention_band, 
    COUNT(DISTINCT employee_id) AS total
FROM gold.view_tenure
GROUP BY retention_band
ORDER BY total DESC;


-- 4. Monitoramento de Qualidade Final (Data Quality Status)
-- Objetivo: Identificar o percentual de dados prontos (Clean Data) vs dados que precisam de atenção (Requires Review)
-- Baseado na visualização consolidada do workforce dashboard.

SELECT 
    data_quality_status, 
    COUNT(*) AS total,
    FORMAT(COUNT(*) * 1.0 / 3000, 'P') AS percentual
FROM gold.view_workforce_dashboard
GROUP BY data_quality_status
ORDER BY total DESC;

-- 5. Distribuição por Faixa Etária (Age Band)
-- Objetivo: Validar o headcount total distribuído por demografia etária.
-- Esta métrica apoia estudos de diversidade e planejamento de sucessão.

SELECT 
    age_band, 
    COUNT(*) AS total_colaboradores,
    FORMAT(COUNT(*) * 1.0 / 3000, 'P') AS percentual_representatividade
FROM gold.view_workforce_dashboard
GROUP BY age_band
ORDER BY total_colaboradores DESC;