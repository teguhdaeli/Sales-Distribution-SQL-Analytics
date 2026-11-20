-- Query 1: Net Revenue & Gross Profit Margin by Product Category
SELECT 
    p.Category,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.Quantity) AS TotalUnitsSold,
    ROUND(SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)), 2) AS NetRevenue,
    ROUND(SUM(od.Quantity * p.UnitCost), 2) AS TotalCOGS,
    ROUND(SUM((od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) - (od.Quantity * p.UnitCost)), 2) AS GrossProfit,
    ROUND(
        (SUM((od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) - (od.Quantity * p.UnitCost)) / 
        NULLIF(SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)), 0)) * 100, 2
    ) AS GrossMarginPct
FROM Orders o
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE o.OrderStatus = 'Completed'
GROUP BY p.Category
ORDER BY NetRevenue DESC;

-- Query 2: Monthly Sales Target Attainment Evaluation (CTE + Conditional Business Logic)
WITH MonthlyActuals AS (
    SELECT 
        o.SalesRepID,
        CAST(strftime('%Y', o.OrderDate) AS INTEGER) AS SalesYear,
        CAST(strftime('%m', o.OrderDate) AS INTEGER) AS SalesMonth,
        SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) AS ActualRevenue
    FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.OrderStatus = 'Completed'
    GROUP BY o.SalesRepID, SalesYear, SalesMonth
)
SELECT 
    sr.FullName,
    sr.Region,
    st.TargetYear,
    st.TargetMonth,
    st.TargetAmount,
    ROUND(COALESCE(ma.ActualRevenue, 0), 2) AS ActualRevenue,
    ROUND((COALESCE(ma.ActualRevenue, 0) / st.TargetAmount) * 100, 2) AS AchievementPct,
    CASE 
        WHEN COALESCE(ma.ActualRevenue, 0) >= st.TargetAmount THEN 'Target Achieved'
        ELSE 'Below Target'
    END AS PerformanceStatus
FROM SalesTargets st
INNER JOIN SalesReps sr ON st.SalesRepID = sr.SalesRepID
LEFT JOIN MonthlyActuals ma 
    ON st.SalesRepID = ma.SalesRepID 
    AND st.TargetYear = ma.SalesYear 
    AND st.TargetMonth = ma.SalesMonth
ORDER BY st.TargetYear, st.TargetMonth, AchievementPct DESC;

-- Query 3: Month-over-Month (MoM) Revenue Growth Analysis (Window Function LAG)
WITH MonthlyRevenue AS (
    SELECT 
        strftime('%Y-%m', o.OrderDate) AS YearMonth,
        SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) AS Revenue
    FROM Orders o
    INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.OrderStatus = 'Completed'
    GROUP BY YearMonth
)
SELECT 
    YearMonth,
    ROUND(Revenue, 2) AS CurrentMonthRevenue,
    ROUND(LAG(Revenue) OVER (ORDER BY YearMonth), 2) AS PreviousMonthRevenue,
    ROUND(
        ((Revenue - LAG(Revenue) OVER (ORDER BY YearMonth)) / 
        NULLIF(LAG(Revenue) OVER (ORDER BY YearMonth), 0)) * 100, 2
    ) AS MoMGrowthPct
FROM MonthlyRevenue;

-- Query 4: Sales Representative Ranking by Total Revenue (DENSE_RANK)
SELECT 
    DENSE_RANK() OVER (ORDER BY SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) DESC) AS SalesRank,
    sr.FullName,
    sr.Region,
    COUNT(DISTINCT o.OrderID) AS CompletedOrders,
    ROUND(SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)), 2) AS TotalNetRevenue
FROM SalesReps sr
LEFT JOIN Orders o ON sr.SalesRepID = o.SalesRepID AND o.OrderStatus = 'Completed'
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
GROUP BY sr.SalesRepID, sr.FullName, sr.Region;

-- Query 5: Product Revenue Contribution Share (Pareto Analysis)
WITH ProductRev AS (
    SELECT 
        p.SKU,
        p.ProductName,
        SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) AS Revenue
    FROM Products p
    INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.OrderStatus = 'Completed'
    GROUP BY p.ProductID, p.SKU, p.ProductName
)
SELECT 
    SKU,
    ProductName,
    ROUND(Revenue, 2) AS NetRevenue,
    ROUND((Revenue / SUM(Revenue) OVER ()) * 100, 2) AS RevenueSharePct
FROM ProductRev
ORDER BY NetRevenue DESC;

-- Query 6: Customer Tier Purchasing Behavior & Average Order Value (AOV)
SELECT 
    c.CustomerTier,
    COUNT(DISTINCT c.CustomerID) AS ActiveStores,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    ROUND(SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)), 2) AS TotalSpend,
    ROUND(
        SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)) / 
        NULLIF(COUNT(DISTINCT o.OrderID), 0), 2
    ) AS AverageOrderValue
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'Completed'
GROUP BY c.CustomerTier
ORDER BY TotalSpend DESC;

-- Query 7: Inventory Reorder Alert & Stock Status Monitoring
SELECT 
    SKU,
    ProductName,
    Category,
    StockQuantity,
    CASE 
        WHEN StockQuantity <= 300 THEN 'CRITICAL - Reorder Immediately'
        WHEN StockQuantity <= 1000 THEN 'WARNING - Low Stock'
        ELSE 'HEALTHY'
    END AS InventoryAlertStatus
FROM Products
ORDER BY StockQuantity ASC;

-- Query 8: Pending Orders Revenue Pipeline
SELECT 
    o.OrderID,
    o.OrderDate,
    c.StoreName,
    sr.FullName AS SalesRep,
    ROUND(SUM(od.Quantity * od.UnitPriceAtSale * (1 - od.DiscountPct / 100.0)), 2) AS PendingOrderValue
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN SalesReps sr ON o.SalesRepID = sr.SalesRepID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.OrderStatus = 'Pending'
GROUP BY o.OrderID, o.OrderDate, c.StoreName, sr.FullName;
