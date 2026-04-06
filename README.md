# 🎲👨‍💼 People Data Platform

![Python](https://img.shields.io/badge/Python-3.13-blue)
![Azure](https://img.shields.io/badge/Azure-Data%20Platform-0078D4)
![SQL](https://img.shields.io/badge/SQL-Database-orange)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📌 Visão Geral

Este projeto implementa uma plataforma de dados para consolidação e tratamento de informações de Recursos Humanos da **DataPeople Corp.**

A solução integra dados provenientes de múltiplas fontes (API e arquivos CSV), aplicando processos estruturados de ingestão, padronização, validação e enriquecimento.

O principal objetivo é garantir que os dados estejam consistentes, confiáveis e prontos para análise, apoiando decisões estratégicas relacionadas à força de trabalho.

A arquitetura foi construída seguindo o modelo **Medalhão (Bronze → Silver → Gold)**, promovendo organização, escalabilidade e governança dos dados.

---

## 🏗️ Arquitetura

![Arquitetura do Projeto](docs/architecture.jpg)

A solução utiliza serviços em nuvem da Azure para garantir escalabilidade e orquestração eficiente:

- Azure Storage Account → armazenamento dos dados brutos (Data Lake)
- Azure Data Factory → orquestração e automação do pipeline
- Azure SQL Database → processamento, modelagem e camada analítica
---

## 🔄 Fluxo do Pipeline

O pipeline foi estruturado para garantir rastreabilidade e qualidade em todas as etapas:

1. Extração dos dados da API via Python
2. Transformação inicial (normalização de endereço)
3. Ingestão no Data Lake (camada Bronze)
4. Processamento, padronização e aplicação de regras (camada Silver)
5. Criação de estruturas analíticas para consumo (camada Gold)

Cada etapa foi projetada para isolar responsabilidades, facilitando manutenção e evolução do pipeline.

---

## 📁 Estrutura do Projeto
```
case-ae/
│
├── data/
│
├── docs/
│   ├── data_dictionary.md
│   └── architecture.jpg
│
├── python/
│   ├── extract_hr_personal_data.py
│   ├── ingest_data_blob_storage.py
│   ├── transform_address.py
│   └── main.py
│
├── sql/
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── quality/
│
├── .env
└── README.md
```

A estrutura foi organizada para separar claramente ingestão, transformação, modelagem e validação dos dados.

---

## 📘 Data Dictionary

A documentação detalhada das tabelas (Bronze, Silver e Gold) está disponível em:

👉 [Data Dictionary](docs/data_dictionary.md)

O dicionário de dados garante padronização, entendimento das estruturas e rastreabilidade das transformações.

---

## 📥 Fontes de Dados

### API (dados pessoais)

- employee_id  
- first_name  
- last_name  
- email  
- phone_number  
- birth_date  
- gender  
- address  

### CSV (dados corporativos)

- employee_id  
- department  
- position  
- salary  
- admission_date  
- employment_type  

As diferentes fontes refletem cenários reais de integração de dados em ambientes corporativos.

---

## 🥉 Camada Bronze

Responsável por armazenar os dados brutos exatamente como são recebidos das fontes.

- Nenhuma transformação é aplicada
- Mantém fidelidade total à origem
- Permite rastreabilidade e auditoria

📂 Implementação:
- `python/extract_hr_personal_data.py` → extração da API  
- `python/ingest_data_blob_storage.py` → ingestão no Data Lake  
- `data/` → arquivos de entrada  
- `sql/bronze/` → estrutura das tabelas

---

## 🥈 Camada Silver

Camada responsável pelo tratamento e padronização dos dados.

Principais processos aplicados:

- Conversão de tipos de dados
- Padronização de valores categóricos
- Remoção de inconsistências e espaços indevidos
- Aplicação de regras de negócio
- Enriquecimento dos dados 

📂 Implementação:
- `sql/silver/` → scripts SQL com transformações e regras

---

## 🥇 Camada Gold

Camada analítica com dados consolidados e preparados para consumo.

Inclui:

- Métricas salariais por departamento
- Tempo de empresa (tenure)
- Visão integrada da força de trabalho

Essa camada facilita o consumo por ferramentas de BI e análises estratégicas.

📂 Implementação:
- `sql/gold/` → views analíticas para consumo em BI 

---

## 🧠 Modelo de Dados

<p align="center">
  <img src="docs/data_model.png" alt="Modelo de Dados" width="700"/>
</p>

O modelo de dados representa a estrutura relacional da camada Silver, onde os dados pessoais e corporativos são integrados, servindo como base para a construção das views analíticas na camada Gold.

---

## ✅ Qualidade de Dados

A qualidade dos dados é garantida por um conjunto de validações implementadas ao longo do pipeline:

- Verificação de valores nulos em campos críticos
- Detecção de duplicidade de registros
- Validação de formatos (datas, numéricos, e-mails)
- Identificação de inconsistências entre campos relacionados

📂 Implementação:
- `sql/quality/` → regras de validação e consistência dos dados  

---

## 🔄 Pipeline (Azure Data Factory)

<p align="center">
  <img src="docs/adf_pipeline.png" alt="Pipeline do Data Factory" width="700"/>
</p>

O pipeline é orquestrado pelo Azure Data Factory, garantindo execução automatizada e organizada das etapas de ingestão, transformação e carga.

A orquestração permite:

- Execução controlada das etapas
- Facilidade de monitoramento
- Escalabilidade do processo

📂 Implementação:
- Azure Data Factory → orquestração do pipeline  
- `docs/adf_pipeline.png` → representação visual do fluxo

---

## 🚀 Melhorias Futuras

- Implementação de cargas incrementais para otimizar o processamento e reduzir custo
- Orquestração completa do pipeline via Azure Data Factory (remoção da execução manual em Python)
- Monitoramento e alertas para falhas no pipeline

---

## ⚙️ Tecnologias Utilizadas

- Python  
- Azure Data Factory  
- Azure Storage  
- Azure SQL Database  

---

## 🎯 Objetivo

Disponibilizar uma base de dados confiável, padronizada e escalável, capaz de suportar análises estratégicas e auxiliar na tomada de decisão da **DataPeople Corp.**

---
