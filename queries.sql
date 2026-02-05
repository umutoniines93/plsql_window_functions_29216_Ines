-- TechWorld Retail Electronics Store
-- Schema, sample data, JOINs, and Window Functions

-- Drop tables if they already exist (order matters due to FKs)
DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

-- 1) Tables
CREATE TABLE Customers (
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Region       VARCHAR(50)  NOT NULL
);

CREATE TABLE Products (
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(120) NOT NULL,
    Category    VARCHAR(80)  NOT NULL,
    Price       DECIMAL(10,2) NOT NULL
);

CREATE TABLE Sales (
    SaleID      INT PRIMARY KEY,
    SaleDate    DATE NOT NULL,
    CustomerID  INT  NOT NULL,
    ProductID   INT  NOT NULL,
    Quantity    INT  NOT NULL,
    TotalAmount DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_sales_customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_sales_products  FOREIGN KEY (ProductID)  REFERENCES Products(ProductID)
);

-- 2) Sample data
INSERT INTO Customers (CustomerID, CustomerName, Region) VALUES
(1, 'Ava Patel', 'North'),
(2, 'Noah Kim', 'South'),
(3, 'Liam Chen', 'East'),
(4, 'Mia Santos', 'West'),
(5, 'Sophia Nguyen', 'North'),
(6, 'Ethan Brown', 'South'),
(7, 'Isabella Rossi', 'East'),
(8, 'Lucas Silva', 'West'),
(9, 'Amelia Johnson', 'North'),
(10, 'Oliver Garcia', 'South');

INSERT INTO Products (ProductID, ProductName, Category, Price) VALUES
(101, 'Smartphone X1', 'Mobile', 799.00),
(102, 'Smartphone X1 Pro', 'Mobile', 999.00),
(103, 'NoiseCancel Headphones', 'Audio', 199.00),
(104, '4K OLED TV 55"', 'TV', 1299.00),
(105, 'Gaming Laptop G5', 'Computers', 1499.00),
(106, 'Wireless Speaker S3', 'Audio', 149.00),
(107, 'Smartwatch Active', 'Wearables', 249.00),
(108, 'Tablet Plus 11', 'Tablets', 549.00),
(109, 'Router AX6000', 'Networking', 299.00),
(110, 'Smart Home Hub', 'SmartHome', 179.00);

INSERT INTO Sales (SaleID, SaleDate, CustomerID, ProductID, Quantity, TotalAmount) VALUES
(1001, '2025-10-05', 1, 101, 1, 799.00),
(1002, '2025-10-12', 2, 103, 2, 398.00),
(1003, '2025-10-20', 3, 104, 1, 1299.00),
(1004, '2025-11-02', 4, 106, 3, 447.00),
(1005, '2025-11-10', 5, 105, 1, 1499.00),
(1006, '2025-11-15', 1, 107, 1, 249.00),
(1007, '2025-12-01', 6, 102, 1, 999.00),
(1008, '2025-12-07', 7, 108, 2, 1098.00),
(1009, '2025-12-18', 8, 109, 1, 299.00),
(1010, '2026-01-05', 9, 104, 1, 1299.00),
(1011, '2026-01-12', 10, 103, 1, 199.00),
(1012, '2026-01-20', 2, 110, 1, 179.00),
(1013, '2026-02-02', 3, 105, 1, 1499.00),
(1014, '2026-02-14', 5, 108, 1, 549.00);

-- 3) JOINs (Part A)

-- ======================================================================
-- A1. INNER JOIN: All completed sales with customer and product details
-- ======================================================================
-- Business Purpose: Retrieve all valid transactions that have both customer and product information
-- Use Case: Generate sales reports showing who bought what, when, and for how much
SELECT
    s.SaleID,
    s.SaleDate,
    c.CustomerName,
    c.Region,
    p.ProductName,
    s.Quantity,
    s.TotalAmount
FROM Sales s
INNER JOIN Customers c ON s.CustomerID = c.CustomerID
INNER JOIN Products p ON s.ProductID = p.ProductID
ORDER BY s.SaleDate, s.SaleID;

-- Business Interpretation: 
-- This query shows all 14 completed transactions in the system. 
-- It confirms that every sale has valid customer and product relationships,
-- essential for accurate revenue reporting and customer analytics.

-- ======================================================================
-- A2. LEFT JOIN: Identify customers who have never made a purchase
-- ======================================================================
-- Business Purpose: Find inactive customers for targeted re-engagement campaigns
-- Use Case: Marketing can reach out to customers who registered but never purchased
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    s.SaleID
FROM Customers c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
WHERE s.SaleID IS NULL
ORDER BY c.CustomerID;

-- Business Interpretation:
-- This query reveals customers without any purchase history (if any exist).
-- These customers are prime candidates for welcome offers or promotional campaigns
-- to convert them from registered users to active buyers.

-- ======================================================================
-- A3. RIGHT JOIN: Products with no sales activity
-- ======================================================================
-- Business Purpose: Detect products in inventory that have never been sold
-- Use Case: Identify slow-moving inventory for clearance sales or discontinuation
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.Price,
    s.SaleID
FROM Sales s
RIGHT JOIN Products p ON s.ProductID = p.ProductID
WHERE s.SaleID IS NULL
ORDER BY p.ProductID;

-- Business Interpretation:
-- This query identifies products with zero sales activity.
-- These items may need promotional pricing, better marketing, or removal from inventory
-- to free up capital and warehouse space.

-- ======================================================================
-- A4. FULL OUTER JOIN: Compare all customers and products including unmatched records
-- ======================================================================
-- Business Purpose: Get a complete view of both customers and products, including those without sales
-- Use Case: Comprehensive audit to see the full scope of registered entities vs. active transactions
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    p.ProductID,
    p.ProductName,
    s.SaleID,
    s.TotalAmount
FROM Customers c
FULL OUTER JOIN Sales s ON c.CustomerID = s.CustomerID
FULL OUTER JOIN Products p ON s.ProductID = p.ProductID
ORDER BY c.CustomerID, p.ProductID, s.SaleID;

-- Business Interpretation:
-- This query provides a comprehensive view showing all customers, products, and sales.
-- It reveals both active and inactive entities, helping management understand
-- the gap between registered resources (customers/products) and actual sales activity.

-- ======================================================================
-- A5. SELF JOIN: Compare sales within the same region
-- ======================================================================
-- Business Purpose: Analyze price variations for different products sold in the same region
-- Use Case: Understand regional pricing dynamics and identify cross-selling opportunities
-- ======================================================================
-- A5. SELF JOIN: Compare sales within the same region
-- ======================================================================
-- Business Purpose: Analyze price variations for different products sold in the same region
-- Use Case: Understand regional pricing dynamics and identify cross-selling opportunities
SELECT
    s1.SaleID AS SaleID_1,
    s2.SaleID AS SaleID_2,
    c1.Region,
    p1.ProductName AS Product_1,
    p2.ProductName AS Product_2,
    s1.TotalAmount AS Total_1,
    s2.TotalAmount AS Total_2,
    (s1.TotalAmount - s2.TotalAmount) AS PriceDiff
FROM Sales s1
INNER JOIN Sales s2 ON s1.SaleID < s2.SaleID
INNER JOIN Customers c1 ON s1.CustomerID = c1.CustomerID
INNER JOIN Customers c2 ON s2.CustomerID = c2.CustomerID AND c1.Region = c2.Region
INNER JOIN Products p1 ON s1.ProductID = p1.ProductID
INNER JOIN Products p2 ON s2.ProductID = p2.ProductID
ORDER BY c1.Region, s1.SaleID, s2.SaleID;

-- Business Interpretation:
-- This self-join compares pairs of sales within the same region.
-- It reveals which products are commonly purchased together in the same region
-- and highlights price differences that could inform bundling strategies.

-- ======================================================================
-- PART B: WINDOW FUNCTIONS
-- ======================================================================

-- ======================================================================
-- B1. RANKING FUNCTIONS: ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK
-- ======================================================================
-- Business Purpose: Rank products by revenue performance in each region
-- Use Case: Identify top performers for inventory prioritization and marketing focus

-- Step 1: Calculate total revenue per product per region
WITH product_revenue AS (
    SELECT
        c.Region,
        p.ProductID,
        p.ProductName,
        SUM(s.TotalAmount) AS Revenue
    FROM Sales s
    INNER JOIN Customers c ON s.CustomerID = c.CustomerID
    INNER JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY c.Region, p.ProductID, p.ProductName
)
-- Step 2: Apply all ranking functions for comprehensive analysis
SELECT
    Region,
    ProductID,
    ProductName,
    Revenue,
    ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS RowNum,
    RANK() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS Rank,
    DENSE_RANK() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS DenseRank,
    PERCENT_RANK() OVER (PARTITION BY Region ORDER BY Revenue DESC) AS PercentRank
FROM product_revenue
ORDER BY Region, Revenue DESC;

-- Business Interpretation:
-- ROW_NUMBER provides unique sequential rankings even for ties.
-- RANK creates gaps after ties (e.g., 1, 2, 2, 4).
-- DENSE_RANK has no gaps (e.g., 1, 2, 2, 3).
-- PERCENT_RANK shows relative standing (0 = top performer, 1 = bottom).
-- Use DENSE_RANK for top N products per region to ensure all top performers are included.

-- ======================================================================
-- B2. AGGREGATE WINDOW FUNCTIONS: SUM, AVG, MIN, MAX with ROWS/RANGE
-- ======================================================================
-- Business Purpose: Calculate running totals and moving averages for trend analysis
-- Use Case: Track cumulative revenue and 3-sale moving average for sales performance monitoring

SELECT
    SaleDate,
    SaleID,
    TotalAmount,
    -- Running total (cumulative sum)
    SUM(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS UNBOUNDED PRECEDING) AS RunningTotal,
    -- 3-row moving average using ROWS
    AVG(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg_3Sales,
    -- Minimum and maximum in current and previous 2 sales
    MIN(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Min_3Sales,
    MAX(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Max_3Sales,
    -- Range-based sum (all sales on same date or earlier)
    SUM(TotalAmount) OVER (ORDER BY SaleDate RANGE UNBOUNDED PRECEDING) AS RangeBasedSum
FROM Sales
ORDER BY SaleDate, SaleID;

-- Business Interpretation:
-- RunningTotal shows cumulative revenue growth over time, reaching the total company revenue.
-- MovingAvg_3Sales smooths out fluctuations to reveal underlying trends.
-- ROWS frame counts exact number of rows (physical boundaries).
-- RANGE frame includes all rows with same ORDER BY value (logical boundaries).
-- Use RANGE when you want all sales on the same date included together.

-- ======================================================================
-- B3. NAVIGATION FUNCTIONS: LAG and LEAD
-- ======================================================================
-- Business Purpose: Compare current period performance with previous/next periods
-- Use Case: Calculate month-over-month sales growth and identify trends

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', SaleDate) AS SaleMonth,
        SUM(TotalAmount) AS MonthTotal
    FROM Sales
    GROUP BY DATE_TRUNC('month', SaleDate)
)
SELECT
    SaleMonth,
    MonthTotal,
    -- Previous month's total using LAG
    LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth) AS PrevMonthTotal,
    -- Next month's total using LEAD
    LEAD(MonthTotal, 1) OVER (ORDER BY SaleMonth) AS NextMonthTotal,
    -- Month-over-month growth amount
    (MonthTotal - LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth)) AS MonthGrowth,
    -- Month-over-month growth percentage
    ROUND(
        ((MonthTotal - LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth)) / 
        NULLIF(LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth), 0) * 100), 2
    ) AS GrowthPercent
FROM monthly_sales
ORDER BY SaleMonth;

-- Business Interpretation:
-- LAG accesses previous row values without self-joins, simplifying trend analysis.
-- Growth calculations reveal which months saw increases or decreases in sales.
-- Negative growth indicates declining sales requiring management attention.
-- This analysis helps forecast future performance and adjust sales strategies accordingly.

-- ======================================================================
-- B4. DISTRIBUTION FUNCTIONS: NTILE and CUME_DIST
-- ======================================================================
-- Business Purpose: Segment customers into spending tiers for targeted marketing
-- Use Case: Create Gold/Silver/Bronze/Basic customer segments based on total spending

WITH customer_spend AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Region,
        COALESCE(SUM(s.TotalAmount), 0) AS TotalSpend
    FROM Customers c
    LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
    GROUP BY c.CustomerID, c.CustomerName, c.Region
)
SELECT
    CustomerID,
    CustomerName,
    Region,
    TotalSpend,
    -- Divide into 4 equal groups (quartiles)
    NTILE(4) OVER (ORDER BY TotalSpend DESC) AS SpendQuartile,
    -- Cumulative distribution (percentage of customers with equal or lower spend)
    ROUND(CUME_DIST() OVER (ORDER BY TotalSpend DESC), 4) AS CumulativeDistribution,
    -- Assign tier labels based on quartile
    CASE 
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 1 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 2 THEN 'Silver'
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 3 THEN 'Bronze'
        ELSE 'Basic'
    END AS CustomerTier
FROM customer_spend
ORDER BY TotalSpend DESC;

-- Business Interpretation:
-- NTILE(4) divides customers into four equal-sized groups for fair segmentation.
-- Quartile 1 (Gold) = top 25% of spenders, ideal for VIP programs and exclusive offers.
-- Quartile 4 (Basic) = bottom 25%, candidates for engagement campaigns to increase spending.
-- CUME_DIST shows what percentage of customers have spent equal or less.
-- This segmentation enables personalized marketing with appropriate messaging per tier.
