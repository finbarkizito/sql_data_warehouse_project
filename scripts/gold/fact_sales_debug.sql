-- =====================================================
-- GOLD LAYER (fact_sales build) — CHECK QUERIES
-- Extracted SELECT statements used to validate the fact grain, dimension joins, and post-build integrity
-- =====================================================


-- =====================================================
-- CHECK 1: Baseline inspection of the sales transactions (silver)
-- Purpose: Confirm fact-source fields and raw transaction volume before joining dimensions
SELECT
    sd.sls_ord_num,
    sd.sls_prd_key,
    sd.sls_cust_id,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales,
    sd.sls_quantity,
    sd.sls_price
FROM silver.crm_sales_details sd;


-- =====================================================
-- CHECK 2: Surrogate key join coverage (sales ➜ dim_product + dim_customers)
-- Purpose: Confirm sales rows can resolve to product_key and customer dimension (via business keys)
-- Expectation: product_key and customer mapping should populate; NULLs indicate broken joins
SELECT
    sd.sls_ord_num,
    pr.product_key,
    sd.sls_cust_id,
    sd.sls_order_dt,
    sd.sls_ship_dt,
    sd.sls_due_dt,
    sd.sls_sales,
    sd.sls_quantity,
    sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;


-- =====================================================
-- CHECK 3: Post-build inspection of the fact table
-- Purpose: Confirm fact_sales exists and data loaded
SELECT *
FROM gold.fact_sales;


-- =====================================================
-- CHECK 4: Orphan fact rows (fact_sales ➜ dim_customers)
-- Purpose: Detect transactions whose customer_key does not resolve to dim_customers
-- Expectation: No rows (rows returned = broken customer join)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;


-- =====================================================
-- NOTE: This check indicates you have NULLs / orphans:
-- The query above returns many rows, meaning many fact_sales.customer_key values
-- do not have a matching record in gold.dim_customers.
-- =====================================================


-- =====================================================
-- CHECK 5: Inspect dim_customers (context for the nulls)
-- Purpose: Review customer dimension contents/keys to diagnose join mismatch
SELECT *
FROM gold.dim_customers;


-- =====================================================
-- CHECK 6: Final re-check of fact_sales (after diagnosis)
-- Purpose: Quick scan of the fact table while debugging
SELECT *
FROM gold.fact_sales;
