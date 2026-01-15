# sql_data_warehouse_project
Designing and implementing a modern data warehouse using SQL Server, covering ETL workflows, data modeling, and analytical reporting.
# Data Warehouse & Analytics Project

Welcome to the **Data Warehouse & Analytics Project** repository.  
This portfolio project presents an end-to-end data warehousing and analytics solution, covering warehouse design, ETL development, data modeling, and analytical reporting. It is structured to reflect real-world data engineering and analytics practices.

---

## Data Architecture

The solution follows the **Medallion Architecture**, organised into **Bronze**, **Silver**, and **Gold** layers.

### Bronze Layer
Raw data ingested directly from source systems. CSV files are loaded into a SQL Server database without transformation.

### Silver Layer
Data is cleaned, standardised, and normalised to improve consistency and analytical usability.

### Gold Layer
Business-ready data structured into a **star schema**, optimised for reporting and analytical queries.

---

## Project Summary

This project covers the full lifecycle of a modern data warehouse, including:

- **Data Architecture** – Designing a scalable warehouse using the Bronze–Silver–Gold pattern  
- **ETL Pipelines** – Extracting, transforming, and loading data from multiple source systems  
- **Data Modeling** – Building fact and dimension tables for analytics  
- **Analytics & Reporting** – Writing SQL-based queries to generate actionable insights  

---

## Skills Demonstrated

This repository showcases experience in:

- SQL Development  
- Data Architecture  
- Data Engineering  
- ETL Pipeline Design  
- Dimensional Data Modeling  
- Data Analytics  

---

## 🛠️ Tools & Resources

All tools used in this project are free and openly available:

- **Datasets** – CSV files used as source systems  
- **SQL Server Express** – Database engine for hosting the warehouse  
- **SQL Server Management Studio (SSMS)** – Database management and query interface  
- **GitHub** – Version control and collaboration  
- **Draw.io** – Architecture, data flow, and data modeling diagrams  
- **Notion** – Project templates and task breakdowns  

---

## Project Requirements

### Data Engineering – Building the Data Warehouse

**Objective**  
Design and implement a SQL Server–based data warehouse to consolidate sales data and support analytical reporting.

**Specifications**

- **Data Sources**: Two source systems (ERP and CRM) provided as CSV files  
- **Data Quality**: Resolve data quality issues before analysis  
- **Integration**: Merge both sources into a single analytical data model  
- **Scope**: Focus on the latest snapshot of data; historisation is not required  
- **Documentation**: Clearly document the data model for technical and business users  

---

### Analytics & Reporting – Business Insights

**Objective**  
Develop SQL-based analytics to deliver insights into:

- Customer behaviour  
- Product performance  
- Sales trends  

These outputs support data-driven decision-making through clear and reliable business metrics.

For further details, see `docs/requirements.md`.

---
## Credit 

- Credit to Data with Baraa for availing the datasets used in this project
---

## License

This project is released under the **MIT License**. You are free to use, modify, and distribute this work with appropriate attribution.

---

## 🌟 About Me

I am **Finbar Kizito**, a data engineer and analyst with a strong interest in data architecture, analytics, and decision-focused reporting.

Feel free to connect with me through the platforms linked in this repository.
