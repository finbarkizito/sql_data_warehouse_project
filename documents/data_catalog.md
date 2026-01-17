# **Gold Layer Data Catalog**

## Overview
The Gold Layer represents the curated, business-facing layer of the data warehouse. It is designed to support analytics, dashboards, and reporting by exposing clean **dimension** and **fact** structures aligned to a star schema.

---

## 1. **gold.dim_customers**

**Description:**  
Contains consolidated customer information enriched with demographic and geographic attributes. This dimension is used to analyse customer behaviour, segmentation, and sales performance.

### Columns

| Column Name      | Data Type     | Description |
|------------------|---------------|-------------|
| customer_key     | INT           | Warehouse-generated surrogate key that uniquely identifies each customer record. |
| customer_id      | INT           | Source-system numeric identifier for the customer. |
| customer_number  | NVARCHAR(50)  | Business-facing alphanumeric customer reference used for tracking and joins. |
| first_name       | NVARCHAR(50)  | Customer’s given name as captured in the source system. |
| last_name        | NVARCHAR(50)  | Customer’s family or surname. |
| country          | NVARCHAR(50)  | Country associated with the customer’s primary location. |
| marital_status   | NVARCHAR(50)  | Customer’s marital status (e.g. Single, Married). |
| gender           | NVARCHAR(50)  | Customer’s gender value, standardised across sources. |
| birthdate        | DATE          | Customer’s date of birth stored in `YYYY-MM-DD` format. |
| create_date      | DATE          | Date the customer record was originally created in the source system. |

---

## 2. **gold.dim_products**

**Description:**  
Stores descriptive attributes for products, including classification, pricing, and lifecycle details. This dimension supports product-level analysis across sales and performance metrics.

### Columns

| Column Name          | Data Type     | Description |
|----------------------|---------------|-------------|
| product_key          | INT           | Surrogate key uniquely identifying each product record. |
| product_id           | INT           | Source-system identifier assigned to the product. |
| product_number       | NVARCHAR(50)  | Business-defined alphanumeric product reference code. |
| product_name         | NVARCHAR(50)  | Human-readable product name including key distinguishing attributes. |
| category_id          | NVARCHAR(50)  | Identifier representing the product’s high-level category. |
| category             | NVARCHAR(50)  | Broad product grouping used for reporting and aggregation. |
| subcategory          | NVARCHAR(50)  | Detailed product classification within a category. |
| maintenance_required | NVARCHAR(50)  | Flag indicating whether ongoing maintenance is required. |
| cost                 | INT           | Base cost of the product expressed in whole currency units. |
| product_line         | NVARCHAR(50)  | Product line or series associated with the item. |
| start_date           | DATE          | Date the product became active or available for sale. |

---

## 3. **gold.fact_sales**

**Description:**  
Captures transactional sales records at the order-line level. This fact table links to customer and product dimensions to enable time-based, customer-based, and product-based analysis.

### Columns

| Column Name   | Data Type     | Description |
|---------------|---------------|-------------|
| order_number  | NVARCHAR(50)  | Unique sales order reference identifying each transaction. |
| product_key   | INT           | Foreign key linking to `gold.dim_products`. |
| customer_key  | INT           | Foreign key linking to `gold.dim_customers`. |
| order_date    | DATE          | Date the sales order was placed. |
| shipping_date | DATE          | Date the order was dispatched to the customer. |
| due_date      | DATE          | Date payment for the order was due. |
| sales_amount  | INT           | Total monetary value of the sales line item. |
| quantity      | INT           | Number of product units sold for the line item. |
| price         | INT           | Unit price applied to the product for the transaction. |

---
