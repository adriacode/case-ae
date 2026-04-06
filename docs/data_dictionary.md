# 📘 Data Dictionary — People Data Platform

## 📌 Visão Geral

Este documento descreve a estrutura de dados do projeto **People Data Platform**, organizado segundo a arquitetura **Medalhão (Bronze → Silver → Gold)**.

Cada camada possui um papel específico no pipeline:

- **Bronze:** dados brutos, sem tratamento  
- **Silver:** dados tratados, padronizados e validados  
- **Gold:** dados analíticos prontos para consumo  

---

# 🥉 Camada Bronze (Raw Data)

## 📄 Tabela: `bronze.hr_personal`

**Descrição:**  
Armazena dados pessoais dos colaboradores conforme recebidos da API, sem qualquer transformação.

| Campo | Tipo | Descrição |
|------|------|----------|
| id | INT | Identificador do colaborador |
| firstname | NVARCHAR(100) | Primeiro nome |
| lastname | NVARCHAR(100) | Sobrenome |
| email | NVARCHAR(150) | Email |
| phone | NVARCHAR(20) | Telefone |
| birthday | NVARCHAR(50) | Data de nascimento em formato texto |
| gender | NVARCHAR(20) | Gênero sem padronização |
| street | NVARCHAR(255) | Endereço completo |
| streetName | NVARCHAR(255) | Nome da rua |
| buildingNumber | NVARCHAR(50) | Número do endereço |
| city | NVARCHAR(100) | Cidade |
| zipcode | NVARCHAR(50) | CEP |
| country | NVARCHAR(100) | País |
| country_code | NVARCHAR(10) | Código do país |
| latitude | NVARCHAR(50) | Latitude em formato texto |
| longitude | NVARCHAR(50) | Longitude em formato texto |
| website | NVARCHAR(255) | Website |
| image | NVARCHAR(255) | URL da imagem |
| create_date | DATETIME2 | Data de ingestão do registro |

---

## 📄 Tabela: `bronze.hr_corporate`

**Descrição:**  
Armazena dados corporativos dos colaboradores provenientes de arquivos CSV, sem tratamento.

| Campo | Tipo | Descrição |
|------|------|----------|
| employee_id | INT | Identificador do colaborador |
| department | NVARCHAR(50) | Departamento |
| position | NVARCHAR(50) | Cargo |
| salary | NVARCHAR(50) | Salário em formato texto |
| admission_date | NVARCHAR(50) | Data de admissão em formato texto |
| employment_type | NVARCHAR(50) | Tipo de contrato |
| create_date | DATETIME2 | Data de ingestão |

---

# 🥈 Camada Silver (Clean & Standardized)

## 📄 Tabela: `silver.hr_personal`

**Descrição:**  
Tabela com dados pessoais tratados, tipados corretamente e padronizados.

**Principais transformações:**
- Conversão de tipos (texto → data/número)
- Padronização de nomes de colunas (snake_case)
- Criação de colunas derivadas
- Identificação de inconsistências

| Campo | Tipo | Descrição |
|------|------|----------|
| personal_id | INT | Identificador único do colaborador (PK) |
| first_name | NVARCHAR(100) | Primeiro nome |
| last_name | NVARCHAR(100) | Sobrenome |
| full_name | NVARCHAR(200) | Nome completo (derivado) |
| email | NVARCHAR(150) | Email |
| phone | NVARCHAR(20) | Telefone |
| birth_date | DATE | Data de nascimento |
| is_birth_date_suspect | BIT | Indica possível inconsistência na data |
| gender | NVARCHAR(1) | Gênero padronizado (M/F) |
| street | NVARCHAR(255) | Endereço |
| street_name | NVARCHAR(255) | Nome da rua |
| building_number | NVARCHAR(50) | Número |
| city | NVARCHAR(100) | Cidade |
| zipcode | NVARCHAR(50) | CEP |
| country | NVARCHAR(100) | País |
| country_code | NVARCHAR(10) | Código do país |
| latitude | DECIMAL(9,6) | Latitude |
| longitude | DECIMAL(9,6) | Longitude |
| website | NVARCHAR(255) | Website |
| image_url | NVARCHAR(255) | URL da imagem |
| create_date | DATETIME2 | Data de carga |

---

## 📄 Tabela: `silver.hr_corporate`

**Descrição:**  
Tabela com dados corporativos tratados e validados.

**Principais transformações:**
- Conversão de salário para numérico
- Conversão de datas
- Padronização do tipo de contrato
- Aplicação de regras de negócio

| Campo | Tipo | Descrição |
|------|------|----------|
| employee_id | INT | Identificador do colaborador (PK) |
| department | NVARCHAR(100) | Departamento |
| position | NVARCHAR(100) | Cargo |
| salary | DECIMAL(10,2) | Salário |
| admission_date | DATE | Data de admissão |
| employment_type | NVARCHAR(20) | Tipo de contrato padronizado |
| is_employment_type_adjusted | BIT | Indica ajuste aplicado |
| create_date | DATETIME2 | Data de carga |

---

# 🥇 Camada Gold (Analytics)

## 📊 View: `gold.view_salary_by_dept`

**Descrição:**  
Apresenta métricas salariais por departamento e cargo, incluindo medidas de tendência central, dispersão e identificação de outliers.

| Campo | Descrição |
|------|----------|
| department | Departamento |
| position | Cargo |
| avg_salary | Média salarial |
| median_salary | Mediana salarial |
| stdev_salary | Desvio padrão |
| cv_salary | Coeficiente de variação (dispersão relativa) |
| min_salary | Salário mínimo |
| max_salary | Salário máximo |
| qtd_employee | Quantidade de colaboradores |
| flag_salary | Classificação de outliers (High Outlier / Low Outlier / Normal) |

---

## 📊 View: `gold.view_tenure`

**Descrição:**  
Apresenta o tempo de empresa dos colaboradores e métricas de retenção por departamento e tipo de contrato.

| Campo | Descrição |
|------|----------|
| employee_id | Identificador do colaborador |
| department | Departamento |
| employment_type | Tipo de contrato |
| tenure_days | Tempo de empresa em dias |
| retention_band | Faixa de retenção (0-1, 1-3, 3-5, 5+ anos) |
| avg_tenure | Média de tempo de empresa |
| median_tenure | Mediana do tempo de empresa |
| headcount_in_band | Quantidade de colaboradores por faixa |

---

## 📊 View: `gold.view_workforce_dashboard`

**Descrição:**  
Visão consolidada dos dados pessoais e corporativos, com métricas de demografia, salário, retenção e qualidade dos dados, utilizada para dashboards analíticos.

### 🔹 Dimensões (Filtros)

| Campo | Descrição |
|------|----------|
| employee_id | Identificador do colaborador |
| country | País |
| gender | Gênero |
| age_band | Faixa etária |
| department | Departamento |
| position | Cargo |
| employment_type | Tipo de contrato |

---

### 🔹 Tempo e Retenção

| Campo | Descrição |
|------|----------|
| tenure_days | Tempo de empresa em dias |
| retention_band | Faixa de retenção |
| avg_tenure_days_dept | Média de tempo de empresa por departamento |
| median_tenure_days_dept | Mediana de tempo por departamento |
| pct_tenure_gt_365d | Percentual de colaboradores com mais de 1 ano |

---

### 🔹 Métricas Salariais

| Campo | Descrição |
|------|----------|
| salary | Salário |
| avg_salary_role | Média salarial por cargo |
| median_salary_role | Mediana salarial por cargo |
| stddev_salary_role | Desvio padrão salarial |
| cv_salary | Coeficiente de variação salarial |

---

### 🔹 Headcount e Representatividade

| Campo | Descrição |
|------|----------|
| headcount | Quantidade de colaboradores no grupo |
| total_dept_headcount | Total de colaboradores no departamento |
| total_company_headcount | Total geral da empresa |
| pct_share_global | Participação percentual no total da empresa |
| pct_share_within_department | Participação dentro do departamento |

---

### 🔹 Qualidade de Dados e Governança

| Campo | Descrição |
|------|----------|
| data_quality_status | Status de qualidade dos dados |
| is_birth_date_suspect | Indicador de data de nascimento suspeita |
| is_employment_type_adjusted | Indicador de ajuste no tipo de contrato |

---

### 🔹 Ranking

| Campo | Descrição |
|------|----------|
| position_rank_in_department | Ranking de cargos dentro do departamento |

---

# ⚙️ Padronizações e Regras Gerais

As seguintes padronizações foram aplicadas na camada Silver:

- Conversão de nomes de colunas para `snake_case`
- Remoção de espaços em branco (TRIM)
- Normalização de valores categóricos (ex: male/female → M/F)
- Conversão de tipos (texto → DATE / DECIMAL)
- Criação de colunas derivadas
- Implementação de flags de qualidade de dados

---

# 🎯 Objetivo do Data Dictionary

Este dicionário de dados tem como objetivo:

- Facilitar o entendimento da estrutura de dados  
- Garantir padronização e governança  
- Apoiar a manutenção e evolução do pipeline  
- Servir como referência para analistas e desenvolvedores  

---