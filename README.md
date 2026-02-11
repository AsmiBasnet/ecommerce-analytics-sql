# 📊 E-Commerce Sales Analytics - SQL Project

> Advanced SQL analytics project demonstrating data analysis skills for Business Intelligence roles

[![SQL](https://img.shields.io/badge/SQL-Advanced-blue)](https://www.sqlite.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🎯 Project Overview

This project showcases **intermediate-to-advanced SQL skills** through comprehensive analysis of e-commerce sales data. Built to demonstrate real-world business intelligence capabilities including customer segmentation, revenue analysis, cohort analysis, and product performance metrics.

**Key Focus Areas:**
- 📈 Revenue & Sales Trend Analysis
- 👥 Customer Segmentation (RFM Analysis)
- 📦 Product Performance & Profitability
- 🔄 Cohort Analysis & Retention
- 🛒 Market Basket Analysis
- 📊 KPI Dashboard Metrics

## 💼 Business Value

This project answers critical business questions:
- Which customer segments drive the most revenue?
- What are our monthly revenue trends and growth rates?
- Which products are most profitable?
- How well do we retain customers over time?
- Which products are frequently bought together?
- What is our customer lifetime value?

## 🗄️ Database Schema

The database consists of 5 main tables with realistic e-commerce relationships:

```
customers (100 records)
├── customer_id (PK)
├── customer_name
├── email
├── country, city
├── signup_date
└── customer_segment (Premium, Standard, Basic)

products (40 records)
├── product_id (PK)
├── product_name
├── category_id (FK)
├── price
└── cost

categories (8 records)
├── category_id (PK)
└── category_name

orders (2,000 records)
├── order_id (PK)
├── customer_id (FK)
├── order_date
├── order_status
└── shipping_cost

order_items (6,000+ records)
├── order_item_id (PK)
├── order_id (FK)
├── product_id (FK)
├── quantity
├── unit_price
└── discount_amount
```

## 🛠️ Technical Skills Demonstrated

### SQL Techniques Used:
- ✅ **Common Table Expressions (CTEs)** - Modular query construction
- ✅ **Window Functions** - `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE()`, `LAG()`, `LEAD()`
- ✅ **Aggregate Functions** - `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()`
- ✅ **Subqueries** - Correlated and non-correlated
- ✅ **Joins** - `INNER`, `LEFT`, `SELF` joins
- ✅ **Date Functions** - `DATE_TRUNC()`, `EXTRACT()`, date arithmetic
- ✅ **CASE Statements** - Conditional logic and segmentation
- ✅ **String Functions** - Data manipulation and formatting
- ✅ **Index Creation** - Query optimization

## 📊 Key Analytics Queries

### 1. Monthly Revenue Trends with YoY Comparison
Tracks revenue over time with month-over-month and year-over-year growth percentages.
```sql
-- Uses: CTEs, LAG(), Window Functions, Date Functions
-- Output: Monthly revenue, growth rates, customer counts
```

### 2. RFM Customer Segmentation
Segments customers into behavioral groups (Champions, Loyal, At Risk, Lost) using Recency, Frequency, and Monetary analysis.
```sql
-- Uses: CTEs, NTILE(), CASE WHEN, Window Functions
-- Output: Customer scores and actionable segments
```

### 3. Product Performance & Profitability
Analyzes product sales with profit margins, rankings, and category performance.
```sql
-- Uses: Multiple JOINs, RANK(), PARTITION BY
-- Output: Revenue, profit margins, category rankings
```

### 4. Cohort Analysis - Customer Retention
Tracks customer retention by signup month to understand long-term engagement.
```sql
-- Uses: Self-joins, Date arithmetic, Cohort logic
-- Output: Retention rates at 1, 3, 6, and 12 months
```

### 5. Category Market Share Analysis
Compares category performance with market share percentages.
```sql
-- Uses: Window aggregations, Percentage calculations
-- Output: Revenue share, order volume by category
```

### 6. Geographic Customer Analysis
Identifies top customers by country and city with purchase patterns.
```sql
-- Uses: ROW_NUMBER(), PARTITION BY, Multiple aggregations
-- Output: Top 3 customers per country
```

### 7. Sales Trends with Moving Averages
Smooths daily fluctuations with 7-day and 30-day moving averages.
```sql
-- Uses: ROWS BETWEEN, Rolling calculations
-- Output: Daily revenue with trend indicators
```

### 8. Customer Lifetime Value Prediction
Estimates future customer value based on historical behavior.
```sql
-- Uses: Complex calculations, CTEs, Predictive metrics
-- Output: Predicted annual value, purchase frequency segments
```

### 9. Market Basket Analysis
Discovers product affinity - which items are frequently bought together.
```sql
-- Uses: Self-joins, Filtering, Attach rate calculations
-- Output: Product pairs with co-purchase frequency
```

### 10. Order Fulfillment Analysis
Tracks cancellations and returns with revenue impact.
```sql
-- Uses: CASE aggregations, Percentage calculations
-- Output: Cancellation rates, return rates, revenue loss
```

### 11. Customer Acquisition Funnel
Analyzes conversion from signup to first purchase.
```sql
-- Uses: LEFT JOINs, Conversion metrics, Date calculations
-- Output: Conversion rates, time-to-purchase, repeat rates
```

### 12. Revenue Attribution by Segment
Breaks down revenue contribution by customer segment.
```sql
-- Uses: Window functions, Revenue per customer metrics
-- Output: Segment performance, contribution percentages
```

## 🚀 Getting Started

### Prerequisites
- SQLite (or any SQL database: PostgreSQL, MySQL, etc.)
- Python 3.x (for data generation script)

### Installation & Setup

1. **Clone this repository**
```bash
git clone https://github.com/yourusername/ecommerce-analytics-sql.git
cd ecommerce-analytics-sql
```

2. **Create the database and schema**
```bash
sqlite3 ecommerce.db < 01_schema.sql
```

3. **Load sample data**
```bash
sqlite3 ecommerce.db < 02_sample_data.sql
```

4. **Generate order data**
```bash
python generate_data.py
sqlite3 ecommerce.db < 03_generate_orders.sql
```

5. **Run analytics queries**
```bash
sqlite3 ecommerce.db < 04_analytics_queries.sql
```

Or run individual queries interactively:
```bash
sqlite3 ecommerce.db
sqlite> .read 04_analytics_queries.sql
```

## 📁 Project Structure

```
ecommerce-analytics-sql/
├── 01_schema.sql              # Database schema with indexes
├── 02_sample_data.sql         # Categories, products, customers
├── 03_generate_orders.sql     # Generated orders & order items
├── generate_data.py           # Python script for data generation
├── 04_analytics_queries.sql   # 12 comprehensive analytics queries
└── README.md                  # This file
```

## 📈 Sample Insights

From running these queries on the sample dataset:

- **Revenue Growth**: 15-20% month-over-month growth in Q2 2024
- **Customer Segments**: Premium customers (30% of base) drive 60% of revenue
- **Top Category**: Electronics generates 35% of total revenue
- **Retention**: 65% of customers make a 2nd purchase within 3 months
- **Product Affinity**: Wireless headphones + smart watches purchased together 45% of the time
- **Average LTV**: $1,200 per customer over 12 months

## 🎓 Learning Outcomes

Through this project, I've demonstrated:
- Writing complex, production-ready SQL queries
- Understanding of business metrics and KPIs
- Data modeling for analytics use cases
- Query optimization with proper indexing
- Translating business questions into SQL logic
- Creating reusable, maintainable query patterns

## 🔮 Future Enhancements

- [ ] Add data visualization layer (Tableau/PowerBI integration)
- [ ] Implement stored procedures for automated reporting
- [ ] Create materialized views for performance
- [ ] Add customer churn prediction model
- [ ] Expand to include marketing campaign analysis

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Connect

**[Your Name]**
- LinkedIn: [your-linkedin-profile]
- Email: your.email@example.com
- Portfolio: [your-portfolio-website]

---

⭐ If you found this project helpful, please consider giving it a star!

*Built with SQL and data analytics best practices*
