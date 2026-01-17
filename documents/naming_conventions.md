# **Naming Standards**

This document defines the standard naming approach applied across schemas, tables, views, columns, and procedural objects within the data warehouse. The goal is consistency, clarity, and alignment with analytical best practices.

---

## **Contents**

1. [Core Principles](#core-principles)
2. [Table Naming Standards](#table-naming-standards)
   - [Bronze Layer](#bronze-layer)
   - [Silver Layer](#silver-layer)
   - [Gold Layer](#gold-layer)
3. [Column Naming Standards](#column-naming-standards)
   - [Surrogate Keys](#surrogate-keys)
   - [System / Technical Columns](#system--technical-columns)
4. [Stored Procedure Standards](#stored-procedure-standards)

---

## **Core Principles**

- **Format**: Use `snake_case` with lowercase characters and underscores (`_`) between words.
- **Language**: All object names must be written in English.
- **SQL Compatibility**: Avoid SQL reserved keywords for any database object.

---

## **Table Naming Standards**

### **Bronze Layer**

- Table names must retain their original source-system naming.
- Each table must be prefixed with the originating system name.
- **Pattern:**  
  **`<source_system>_<entity>`**

  - `<source_system>`: Name of the upstream system (e.g. `crm`, `erp`)
  - `<entity>`: Original table name from the source

- **Example:**  
  `crm_customer_info` — Raw customer data ingested from the CRM system.

---

### **Silver Layer**

- Naming mirrors the Bronze layer to preserve lineage and traceability.
- Source system prefixes are mandatory.
- **Pattern:**  
  **`<source_system>_<entity>`**

- **Example:**  
  `erp_product_master` — Cleaned and standardized product data originating from ERP.

---

### **Gold Layer**

- Table names must be business-facing and descriptive.
- Each table must begin with a role-based prefix indicating its analytical purpose.
- **Pattern:**  
  **`<role>_<entity>`**

  - `<role>`: Analytical classification (`dim`, `fact`, `report`)
  - `<entity>`: Business-aligned subject area

- **Examples:**
  - `dim_customers` — Customer dimension
  - `fact_sales` — Sales transaction fact table

#### **Role Prefix Reference**

| Prefix     | Description                      | Example(s)                                  |
|------------|----------------------------------|---------------------------------------------|
| `dim_`     | Dimension table                  | `dim_customers`, `dim_products`             |
| `fact_`    | Fact table                       | `fact_sales`                                |
| `report_`  | Reporting / aggregated table     | `report_sales_monthly`, `report_customers` |

---

## **Column Naming Standards**

### **Surrogate Keys**

- All dimension tables must use surrogate primary keys.
- Surrogate keys must end with the suffix `_key`.
- **Pattern:**  
  **`<entity>_key`**

- **Example:**  
  `customer_key` — Surrogate key in `dim_customers`.

---

### **System / Technical Columns**

- Columns used for warehouse metadata must be clearly identifiable.
- All technical fields must start with the prefix `dwh_`.
- **Pattern:**  
  **`dwh_<description>`**

- **Example:**  
  `dwh_load_date` — Date the record was loaded into the warehouse.

---

## **Stored Procedure Standards**

- Stored procedures responsible for data loading must reflect the target layer.
- **Pattern:**  
  **`load_<layer>`**

  - `<layer>`: Target layer (`bronze`, `silver`, `gold`)

- **Examples:**
  - `load_bronze` — Ingest raw source data
  - `load_silver` — Transform and cleanse data
  - `load_gold` — Populate analytical views and tables

---
