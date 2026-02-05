DROP TABLE IF EXISTS Sales;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
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

INSERT INTO Customers (CustomerID, CustomerName, Region) VALUES
(1, 'Aline Mukamana', 'Gasabo'),
(2, 'Jean Nkurunziza', 'Kicukiro'),
(3, 'Eric Habimana', 'Rwamagana'),
(4, 'Diane Uwimana', 'Rubavu'),
(5, 'Patrick Habyarimana', 'Rusizi'),
(6, 'Chantal Niyonzima', 'Gasabo'),
(7, 'Samuel Ndahiro', 'Kicukiro'),
(8, 'Beata Ingabire', 'Rwamagana'),
(9, 'Emmanuel Mugisha', 'Rubavu'),
(10, 'Grace Uwamahoro', 'Rusizi');

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

-- INNER JOIN
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

-- LEFT JOIN
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Region,
    s.SaleID
FROM Customers c
LEFT JOIN Sales s ON c.CustomerID = s.CustomerID
WHERE s.SaleID IS NULL
ORDER BY c.CustomerID;

-- RIGHT JOIN
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

-- FULL OUTER JOIN
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

-- SELF JOIN
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

-- RANKING FUNCTIONS
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
-- Step 2: Apply ranking functions
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

-- AGGREGATE WINDOW FUNCTIONS
SELECT
    SaleDate,
    SaleID,
    TotalAmount,
    -- Running total
    SUM(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS UNBOUNDED PRECEDING) AS RunningTotal,
    -- 3-row moving average
    AVG(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg_3Sales,
    -- Min and max in 3 sales
    MIN(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Min_3Sales,
    MAX(TotalAmount) OVER (ORDER BY SaleDate, SaleID ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Max_3Sales,
    SUM(TotalAmount) OVER (ORDER BY SaleDate RANGE UNBOUNDED PRECEDING) AS RangeBasedSum
FROM Sales
ORDER BY SaleDate, SaleID;

-- NAVIGATION FUNCTIONSWITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', SaleDate) AS SaleMonth,
        SUM(TotalAmount) AS MonthTotal
    FROM Sales
    GROUP BY DATE_TRUNC('month', SaleDate)
)
SELECT
    SaleMonth,
    MonthTotal,
    -- Previous month using LAG
    LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth) AS PrevMonthTotal,
    -- Next month using LEAD
    LEAD(MonthTotal, 1) OVER (ORDER BY SaleMonth) AS NextMonthTotal,
    -- Growth amount
    (MonthTotal - LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth)) AS MonthGrowth,
    -- Growth percentage
    ROUND(
        ((MonthTotal - LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth)) / 
        NULLIF(LAG(MonthTotal, 1) OVER (ORDER BY SaleMonth), 0) * 100), 2
    ) AS GrowthPercent
FROM monthly_sales
ORDER BY SaleMonth;

-- DISTRIBUTION FUNCTIONSWITH customer_spend AS (
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
    -- Quartiles
    NTILE(4) OVER (ORDER BY TotalSpend DESC) AS SpendQuartile,
    -- Cumulative distribution
    ROUND(CUME_DIST() OVER (ORDER BY TotalSpend DESC), 4) AS CumulativeDistribution,
    -- Tier labels
    CASE 
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 1 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 2 THEN 'Silver'
        WHEN NTILE(4) OVER (ORDER BY TotalSpend DESC) = 3 THEN 'Bronze'
        ELSE 'Basic'
    END AS CustomerTier
FROM customer_spend
ORDER BY TotalSpend DESC;
