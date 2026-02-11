# Quick Start Guide

## 🚀 5-Minute Setup

### Option 1: SQLite (Recommended for Quick Start)

```bash
# Install SQLite (if not already installed)
# MacOS: brew install sqlite
# Linux: sudo apt-get install sqlite3
# Windows: Download from https://www.sqlite.org/download.html

# Create database
sqlite3 ecommerce.db

# In SQLite prompt, run:
.read 01_schema.sql
.read 02_sample_data.sql
.exit

# Generate orders data
python generate_data.py

# Load orders
sqlite3 ecommerce.db < 03_generate_orders.sql

# Run analytics
sqlite3 ecommerce.db
.mode column
.headers on
.read 04_analytics_queries.sql
```

### Option 2: PostgreSQL

```bash
# Create database
createdb ecommerce_analytics

# Load schema and data
psql ecommerce_analytics < 01_schema.sql
psql ecommerce_analytics < 02_sample_data.sql

# Generate and load orders
python generate_data.py
psql ecommerce_analytics < 03_generate_orders.sql

# Run analytics
psql ecommerce_analytics < 04_analytics_queries.sql
```

### Option 3: MySQL

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE ecommerce_analytics;"

# Load schema and data
mysql -u root -p ecommerce_analytics < 01_schema.sql
mysql -u root -p ecommerce_analytics < 02_sample_data.sql

# Generate and load orders
python generate_data.py
mysql -u root -p ecommerce_analytics < 03_generate_orders.sql

# Run analytics
mysql -u root -p ecommerce_analytics < 04_analytics_queries.sql
```

## 📊 Running Individual Queries

To run specific queries instead of all at once:

```bash
sqlite3 ecommerce.db

# Enable nice output formatting
.mode column
.headers on
.width 20 15 15 15

# Run a specific query (copy-paste from 04_analytics_queries.sql)
# Example: Monthly Revenue Trends
SELECT ...;
```

## 💡 Tips for Best Results

1. **Formatting Output**: Use `.mode` commands in SQLite for readable results
   ```sql
   .mode markdown  -- For markdown-formatted tables
   .mode csv       -- For CSV export
   .mode column    -- For aligned columns
   ```

2. **Exporting Results**: Save query results to CSV
   ```bash
   sqlite3 ecommerce.db
   .mode csv
   .output monthly_revenue.csv
   .read 04_analytics_queries.sql
   .output stdout
   ```

3. **Running in Python**: Use pandas for analysis
   ```python
   import sqlite3
   import pandas as pd
   
   conn = sqlite3.connect('ecommerce.db')
   query = "SELECT * FROM ..."
   df = pd.read_sql_query(query, conn)
   print(df)
   ```

## 🎯 Common Issues & Solutions

### Issue: "table already exists" error
**Solution**: Drop existing tables first
```sql
DROP TABLE IF EXISTS order_items, orders, products, customers, categories;
```

### Issue: Python script not found
**Solution**: Ensure you're in the correct directory
```bash
cd ecommerce-analytics-sql
ls -la  # Should see generate_data.py
```

### Issue: Date function errors
**Solution**: Check your SQL dialect
- SQLite: `DATE()`, `JULIANDAY()`
- PostgreSQL: `DATE_TRUNC()`, `EXTRACT()`
- MySQL: `DATE_FORMAT()`, `TIMESTAMPDIFF()`

## 📖 Next Steps

1. ✅ Set up the database
2. ✅ Run all queries to verify everything works
3. 📝 Pick 2-3 queries that best showcase your skills
4. 📊 Create visualizations in Tableau/PowerBI (optional)
5. 🚀 Upload to GitHub
6. 💼 Add to LinkedIn and resume

## 🎓 Understanding the Queries

Each query in `04_analytics_queries.sql` has:
- **Header comment** explaining what it does
- **Skills demonstrated** (CTEs, window functions, etc.)
- **Business value** (what question it answers)

Start with queries 1, 2, and 3 - they're the most impressive for interviews!
