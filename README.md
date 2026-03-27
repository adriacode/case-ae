# HR Data Pipeline

## Visão Geral

Este projeto implementa um pipeline de dados para consolidação de informações de Recursos Humanos da DataPeople Corp., integrando dados de uma API e de arquivos CSV.

O objetivo é centralizar, tratar e disponibilizar os dados de forma confiável para análise, utilizando a arquitetura Bronze, Silver e Gold.

---

## Arquitetura

A solução utiliza:

* Azure Storage Account (armazenamento dos dados brutos)
* Azure Data Factory (orquestração do pipeline)
* Azure SQL Database (camadas tratadas e analíticas)

Fluxo geral:

1. Extração dos dados da API via Python
2. Transformação dos dados em memória (incluindo normalização de endereço)
3. Ingestão dos dados no Data Lake (Bronze)
4. Transformações e carga no banco (Silver)
5. Criação de views analíticas (Gold)

---

## Estrutura do Projeto

```id="4o8kwu"
case-ae/
│
├── data/
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
└── .env
```

---

## Fontes de Dados

**API (dados cadastrais):**

* employee_id
* first_name
* last_name
* email
* phone_number
* birth_date
* gender
* address

**CSV (dados corporativos):**

* employee_id
* department
* position
* salary
* admission_date
* employment_type

---

## Camadas de Dados

### Bronze

Armazena os dados brutos sem qualquer transformação.

Arquivos relacionados:

* `python/extract_hr_personal_data.py`
* `python/ingest_data_blob_storage.py`
* `data/`
* `sql/bronze/`

---

### Silver

Responsável pela padronização e limpeza dos dados.

Inclui:

* Conversão de tipos
* Padronização de campos
* Tratamento de inconsistências
* Validação entre tabelas

Arquivos relacionados:

* `sql/silver/`

---

### Gold

Camada de consumo com views voltadas para análise.

Inclui:

* métricas salariais por departamento
* tempo de casa
* visão consolidada da força de trabalho

Arquivos relacionados:

* `sql/gold/`

---

## Qualidade de Dados

Validações implementadas:

* valores nulos
* duplicidade
* inconsistências de formato
* dados inválidos

Arquivos:

* `sql/quality/`

---

## Tecnologias

* Python
* Azure Data Factory
* Azure Storage
* Azure SQL Database
