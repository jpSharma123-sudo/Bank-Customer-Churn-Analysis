# 🏦 Bank Customer Churn Analysis

**SQL | MySQL | Power BI | Customer Analytics**

An end-to-end banking analytics project focused on understanding customer churn, analyzing customer behavior, and identifying opportunities to improve customer retention using SQL and Power BI.

---

## 📌 Project Overview

Customer churn is a major challenge for banks because losing customers can affect customer relationships and long-term business growth.

This project analyzes banking customer data to explore churn patterns across demographics, geography, credit scores, account balances, and banking product usage.

SQL is used to query and analyze customer data, while Power BI provides visual insights to support business analysis and decision-making.

## 🎯 Business Objectives

- Analyze customer churn and retention patterns.
- Evaluate customer behavior across geographic and demographic segments.
- Investigate relationships between credit scores, account activity, and customer churn.
- Compare customer characteristics across different customer groups.
- Develop actionable recommendations to support customer retention.

## 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| SQL | Customer data analysis and business queries |
| MySQL | Database creation, data loading, and query execution |
| Power BI | Interactive dashboards and data visualization |
| Microsoft Word | Project documentation |
| Microsoft PowerPoint | Project presentation |

## 📂 Repository Structure

```text
Bank-Customer-Churn-Analysis/
│
├── SQL/
│   ├── 01_Bank_Customer_Churn_Data_Load.sql
│   └── 02_Bank_Customer_churn_QA.sql
│
├── PowerBI/
│   └── Bank_Customer_Churn.pbix
│
├── Documentation/
│   └── Bank_Customer_Churn_Analysis_Report.docx
│
├── Presentation/
│   └── Bank_Customer_Churn_Analysis_Presentation_v3.pptx
│
├── Dashboard Screenshots/
│   ├── 01_Overview.jpg
│   ├── 02_Churn Analysis.jpg
│   ├── 03_Customer Insights or Risk Analysis.jpg
│   ├── 04_Recommendations.jpg
│   └── 05_Executive Dashboard.jpg
│
└── README.md
```

## 🔍 SQL Analysis

The project includes SQL scripts for database setup, data loading, and customer churn analysis.

Key areas of analysis include:

- Customer churn and retention patterns.
- Geographic and demographic comparisons.
- Customer credit score analysis.
- Account balance comparisons.
- Customer activity and banking product usage.
- Business questions answered using SQL queries.

### SQL Concepts Applied

- JOINs
- GROUP BY and ORDER BY
- Aggregate functions
- CASE statements
- Subqueries
- Filtering and conditional logic

## 📊 Power BI Dashboard

The Power BI report is designed to present customer churn patterns and customer characteristics through interactive visualizations.

The dashboard screenshots provide a preview of the project's reporting pages.

### Dashboard Preview

**1. Overview**

![Overview Dashboard](<Dashboard Screenshots/01_Overview.jpg>)

**2. Churn Analysis**

![Churn Analysis](<Dashboard Screenshots/02_Churn Analysis.jpg>)

**3. Customer Insights and Risk Analysis**

![Customer Insights](<Dashboard Screenshots/03_Customer Insights or Risk Analysis.jpg>)

**4. Recommendations**

![Recommendations](<Dashboard Screenshots/04_Recommendations.jpg>)

**5. Executive Dashboard**

![Executive Dashboard](<Dashboard Screenshots/05_Executive Dashboard.jpg>)

## 💡 Business Insights

The project investigates customer churn from multiple perspectives, including:

- **Geographic patterns:** Compare customer counts, balances, and churn across regions.
- **Demographic patterns:** Examine differences in churn across customer groups.
- **Credit score analysis:** Investigate whether churn patterns differ across credit score ranges.
- **Customer activity:** Explore how account activity relates to customer retention.
- **Product usage:** Compare churn patterns based on banking product ownership.

The findings can help identify customer segments that warrant further investigation. Actual numerical findings should be interpreted from the SQL query results and dashboard.

## 📈 Business Recommendations

Based on the patterns identified in the analysis, banks can consider the following strategies:

1. **Targeted retention campaigns:** Investigate customer segments with higher observed churn rates and test tailored retention initiatives.
2. **Customer engagement:** Evaluate ways to improve engagement among inactive customers.
3. **Segment-based analysis:** Monitor churn patterns across geographic and demographic groups.
4. **Product engagement:** Investigate whether banking product usage is associated with customer retention.
5. **Continuous monitoring:** Track churn-related KPIs over time to identify emerging trends.

These recommendations are intended to support investigation and testing rather than assume that any single customer characteristic causes churn.

## ⚙️ How to Run the Project

### Step 1: Set Up MySQL

Install MySQL Server and MySQL Workbench.

### Step 2: Create the Database and Load Data

Open and execute:

`SQL/01_Bank_Customer_Churn_Data_Load.sql`

**Important:** Review the script before executing it. It drops and recreates the `bank_crm` database, so do not run it against a database containing information you need to preserve.

### Step 3: Run the Analysis

Open and execute:

`SQL/02_Bank_Customer_churn_QA.sql`

Review the query results to understand the business questions and their findings.

### Step 4: Open the Power BI Report

Open `PowerBI/Bank_Customer_Churn.pbix` in Power BI Desktop.

Configure the data source if required, then refresh the report.

## 📁 Project Deliverables

- SQL database setup and data-loading scripts.
- SQL customer churn analysis queries.
- Power BI dashboard.
- Project analysis report.
- Project presentation.
- Dashboard screenshots.

## 🏁 Conclusion

This project demonstrates how SQL and Power BI can be used to investigate customer churn, analyze customer behavior, and communicate business insights.

It showcases practical skills in SQL querying, relational data analysis, business intelligence, dashboard development, and data-driven decision-making.

---

**Project Category:** Data Analytics | Customer Analytics | Banking

**Author:** Jaiprakash Sharma
