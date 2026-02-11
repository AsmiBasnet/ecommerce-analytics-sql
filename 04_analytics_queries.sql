-- ====================================
-- E-COMMERCE ANALYTICS SQL QUERIES
-- Showcasing Intermediate SQL Skills
-- ====================================

-- QUERY 1: Monthly Revenue Trends with Year-over-Year Comparison
-- Skills: CTEs, Window Functions, Date Functions, Aggregations
-- -------------------------------------------------------------
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        EXTRACT(YEAR FROM o.order_date) AS year,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_customers
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_TRUNC('month', o.order_date), EXTRACT(YEAR FROM o.order_date)
)
SELECT 
    month,
    year,
    total_revenue,
    total_orders,
    unique_customers,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        ((total_revenue - LAG(total_revenue) OVER (ORDER BY month)) / 
        LAG(total_revenue) OVER (ORDER BY month) * 100), 2
    ) AS month_over_month_growth_pct,
    LAG(total_revenue, 12) OVER (ORDER BY month) AS same_month_last_year,
    ROUND(
        ((total_revenue - LAG(total_revenue, 12) OVER (ORDER BY month)) / 
        LAG(total_revenue, 12) OVER (ORDER BY month) * 100), 2
    ) AS year_over_year_growth_pct
FROM monthly_revenue
ORDER BY month DESC;


-- QUERY 2: Customer Segmentation by Purchase Behavior (RFM Analysis)
-- Skills: CTEs, CASE WHEN, Subqueries, Ranking Functions
-- -------------------------------------------------------------
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS lifetime_value,
        MAX(o.order_date) AS last_order_date,
        JULIANDAY('2024-12-31') - JULIANDAY(MAX(o.order_date)) AS days_since_last_order,
        AVG(oi.quantity * oi.unit_price - oi.discount_amount) AS avg_order_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.customer_segment
),
rfm_scores AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY days_since_last_order) AS recency_score,
        NTILE(5) OVER (ORDER BY total_orders DESC) AS frequency_score,
        NTILE(5) OVER (ORDER BY lifetime_value DESC) AS monetary_score
    FROM customer_metrics
    WHERE total_orders > 0
)
SELECT 
    customer_id,
    customer_name,
    customer_segment,
    total_orders,
    ROUND(lifetime_value, 2) AS lifetime_value,
    ROUND(avg_order_value, 2) AS avg_order_value,
    days_since_last_order,
    recency_score,
    frequency_score,
    monetary_score,
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'Promising'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS customer_category
FROM rfm_scores
ORDER BY lifetime_value DESC
LIMIT 50;


-- QUERY 3: Product Performance Analysis with Profitability Metrics
-- Skills: Window Functions, CTEs, Joins, Aggregations
-- -------------------------------------------------------------
WITH product_sales AS (
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        p.price,
        p.cost,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        SUM(oi.quantity * p.cost) AS total_cost,
        COUNT(DISTINCT oi.order_id) AS order_count
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.cost
)
SELECT 
    product_id,
    product_name,
    category_name,
    total_units_sold,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_cost, 2) AS total_cost,
    ROUND(total_revenue - total_cost, 2) AS gross_profit,
    ROUND(((total_revenue - total_cost) / total_revenue * 100), 2) AS profit_margin_pct,
    ROUND(total_revenue / order_count, 2) AS avg_revenue_per_order,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY (total_revenue - total_cost) DESC) AS profit_rank,
    RANK() OVER (PARTITION BY category_name ORDER BY total_revenue DESC) AS category_rank
FROM product_sales
ORDER BY total_revenue DESC;


-- QUERY 4: Cohort Analysis - Customer Retention by Signup Month
-- Skills: CTEs, Self-Joins, Date Functions, Pivoting Logic
-- -------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', signup_date) AS cohort_month
    FROM customers
),
customer_orders AS (
    SELECT 
        o.customer_id,
        cc.cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month,
        (EXTRACT(YEAR FROM o.order_date) - EXTRACT(YEAR FROM cc.cohort_month)) * 12 + 
        (EXTRACT(MONTH FROM o.order_date) - EXTRACT(MONTH FROM cc.cohort_month)) AS months_since_signup
    FROM orders o
    JOIN customer_cohorts cc ON o.customer_id = cc.customer_id
    WHERE o.order_status = 'Completed'
)
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN months_since_signup = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN months_since_signup = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN months_since_signup = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN months_since_signup = 3 THEN customer_id END) AS month_3,
    COUNT(DISTINCT CASE WHEN months_since_signup = 6 THEN customer_id END) AS month_6,
    COUNT(DISTINCT CASE WHEN months_since_signup = 12 THEN customer_id END) AS month_12,
    ROUND(
        COUNT(DISTINCT CASE WHEN months_since_signup = 3 THEN customer_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN months_since_signup = 0 THEN customer_id END), 0), 
        2
    ) AS retention_3_month_pct
FROM customer_orders
GROUP BY cohort_month
HAVING COUNT(DISTINCT CASE WHEN months_since_signup = 0 THEN customer_id END) > 0
ORDER BY cohort_month;


-- QUERY 5: Category Performance with Market Share Analysis
-- Skills: Window Functions, Aggregations, Percentage Calculations
-- -------------------------------------------------------------
WITH category_performance AS (
    SELECT 
        c.category_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        AVG(oi.quantity * oi.unit_price - oi.discount_amount) AS avg_order_value,
        SUM(oi.quantity) AS units_sold
    FROM categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY c.category_name
)
SELECT 
    category_name,
    total_orders,
    unique_customers,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    units_sold,
    ROUND(
        total_revenue * 100.0 / SUM(total_revenue) OVER (), 
        2
    ) AS revenue_market_share_pct,
    ROUND(
        total_orders * 100.0 / SUM(total_orders) OVER (), 
        2
    ) AS order_market_share_pct,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_performance
ORDER BY total_revenue DESC;


-- QUERY 6: Top Customers by Geography with Purchase Patterns
-- Skills: CTEs, Window Functions, Aggregations, String Functions
-- -------------------------------------------------------------
WITH customer_geography AS (
    SELECT 
        c.country,
        c.city,
        c.customer_id,
        c.customer_name,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        AVG(oi.quantity * oi.unit_price - oi.discount_amount) AS avg_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.country, c.city, c.customer_id, c.customer_name, c.customer_segment
    HAVING COUNT(DISTINCT o.order_id) > 0
)
SELECT 
    country,
    city,
    customer_name,
    customer_segment,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    first_order_date,
    last_order_date,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_revenue DESC) AS country_rank,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS global_rank
FROM customer_geography
WHERE ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_revenue DESC) <= 3
ORDER BY country, total_revenue DESC;


-- QUERY 7: Sales Trend Analysis with Moving Averages
-- Skills: Window Functions, Date Functions, CTEs
-- -------------------------------------------------------------
WITH daily_sales AS (
    SELECT 
        o.order_date,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS revenue,
        COUNT(DISTINCT o.customer_id) AS customers
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.order_date
)
SELECT 
    order_date,
    orders,
    ROUND(revenue, 2) AS daily_revenue,
    customers,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 
        2
    ) AS seven_day_avg_revenue,
    ROUND(
        AVG(revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ), 
        2
    ) AS thirty_day_avg_revenue,
    ROUND(
        revenue - AVG(revenue) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS deviation_from_7day_avg
FROM daily_sales
ORDER BY order_date DESC
LIMIT 90;


-- QUERY 8: Customer Lifetime Value Prediction
-- Skills: CTEs, Window Functions, Complex Calculations
-- -------------------------------------------------------------
WITH customer_history AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.signup_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        AVG(oi.quantity * oi.unit_price - oi.discount_amount) AS avg_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,
        JULIANDAY('2024-12-31') - JULIANDAY(c.signup_date) AS customer_age_days
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.signup_date
    HAVING COUNT(DISTINCT o.order_id) > 0
)
SELECT 
    customer_id,
    customer_name,
    total_orders,
    ROUND(total_revenue, 2) AS historical_ltv,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(customer_age_days / 30.0, 1) AS customer_age_months,
    ROUND(total_orders / NULLIF(customer_age_days / 30.0, 0), 2) AS orders_per_month,
    ROUND(
        (total_orders / NULLIF(customer_age_days / 30.0, 0)) * avg_order_value * 12,
        2
    ) AS predicted_annual_value,
    CASE 
        WHEN total_orders / NULLIF(customer_age_days / 30.0, 0) >= 2 THEN 'High Frequency'
        WHEN total_orders / NULLIF(customer_age_days / 30.0, 0) >= 0.5 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS purchase_frequency_segment
FROM customer_history
WHERE customer_age_days >= 30
ORDER BY predicted_annual_value DESC
LIMIT 50;


-- QUERY 9: Product Affinity Analysis (Market Basket)
-- Skills: Self-Joins, Aggregations, CTEs
-- -------------------------------------------------------------
WITH product_pairs AS (
    SELECT 
        oi1.product_id AS product_a,
        oi2.product_id AS product_b,
        COUNT(DISTINCT oi1.order_id) AS times_bought_together
    FROM order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id 
        AND oi1.product_id < oi2.product_id
    JOIN orders o ON oi1.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY oi1.product_id, oi2.product_id
    HAVING COUNT(DISTINCT oi1.order_id) >= 5
)
SELECT 
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    pp.times_bought_together,
    ROUND(
        pp.times_bought_together * 100.0 / 
        (SELECT COUNT(DISTINCT order_id) FROM order_items WHERE product_id = pp.product_a),
        2
    ) AS product_a_attach_rate_pct
FROM product_pairs pp
JOIN products p1 ON pp.product_a = p1.product_id
JOIN products p2 ON pp.product_b = p2.product_id
ORDER BY pp.times_bought_together DESC
LIMIT 20;


-- QUERY 10: Order Cancellation and Return Analysis
-- Skills: CASE statements, CTEs, Aggregations
-- -------------------------------------------------------------
WITH order_analysis AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'Completed' THEN o.order_id END) AS completed_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'Cancelled' THEN o.order_id END) AS cancelled_orders,
        COUNT(DISTINCT CASE WHEN o.order_status = 'Returned' THEN o.order_id END) AS returned_orders,
        SUM(CASE WHEN o.order_status = 'Completed' THEN oi.quantity * oi.unit_price - oi.discount_amount ELSE 0 END) AS completed_revenue,
        SUM(CASE WHEN o.order_status = 'Cancelled' THEN oi.quantity * oi.unit_price - oi.discount_amount ELSE 0 END) AS lost_revenue_cancelled,
        SUM(CASE WHEN o.order_status = 'Returned' THEN oi.quantity * oi.unit_price - oi.discount_amount ELSE 0 END) AS lost_revenue_returned
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
)
SELECT 
    month,
    total_orders,
    completed_orders,
    cancelled_orders,
    returned_orders,
    ROUND(completed_revenue, 2) AS completed_revenue,
    ROUND(lost_revenue_cancelled, 2) AS lost_revenue_cancelled,
    ROUND(lost_revenue_returned, 2) AS lost_revenue_returned,
    ROUND(cancelled_orders * 100.0 / total_orders, 2) AS cancellation_rate_pct,
    ROUND(returned_orders * 100.0 / completed_orders, 2) AS return_rate_pct,
    ROUND((lost_revenue_cancelled + lost_revenue_returned) * 100.0 / 
          (completed_revenue + lost_revenue_cancelled + lost_revenue_returned), 2) AS revenue_loss_pct
FROM order_analysis
ORDER BY month DESC;


-- QUERY 11: Customer Acquisition Funnel Analysis
-- Skills: Window Functions, Date Logic, CTEs
-- -------------------------------------------------------------
WITH customer_journey AS (
    SELECT 
        c.customer_id,
        c.signup_date,
        MIN(o.order_date) AS first_order_date,
        JULIANDAY(MIN(o.order_date)) - JULIANDAY(c.signup_date) AS days_to_first_purchase,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.signup_date
)
SELECT 
    DATE_TRUNC('month', signup_date) AS signup_month,
    COUNT(*) AS signups,
    COUNT(first_order_date) AS converted_customers,
    COUNT(*) - COUNT(first_order_date) AS non_converted,
    ROUND(COUNT(first_order_date) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
    ROUND(AVG(CASE WHEN first_order_date IS NOT NULL THEN days_to_first_purchase END), 1) AS avg_days_to_convert,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,
    ROUND(COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / 
          NULLIF(COUNT(first_order_date), 0), 2) AS repeat_purchase_rate_pct
FROM customer_journey
GROUP BY DATE_TRUNC('month', signup_date)
ORDER BY signup_month DESC;


-- QUERY 12: Revenue Attribution by Customer Segment
-- Skills: CTEs, Window Functions, Aggregations, Ranking
-- -------------------------------------------------------------
WITH segment_performance AS (
    SELECT 
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS total_revenue,
        AVG(oi.quantity * oi.unit_price - oi.discount_amount) AS avg_order_value,
        SUM(oi.quantity * oi.unit_price - oi.discount_amount) / 
            NULLIF(COUNT(DISTINCT c.customer_id), 0) AS revenue_per_customer
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_segment
)
SELECT 
    customer_segment,
    total_customers,
    total_orders,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    ROUND(revenue_per_customer, 2) AS revenue_per_customer,
    ROUND(total_orders * 1.0 / NULLIF(total_customers, 0), 2) AS orders_per_customer,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS revenue_contribution_pct,
    ROUND(total_customers * 100.0 / SUM(total_customers) OVER (), 2) AS customer_base_pct
FROM segment_performance
ORDER BY total_revenue DESC;
