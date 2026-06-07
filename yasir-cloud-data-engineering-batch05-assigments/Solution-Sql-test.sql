--Question no  01
SELECT TOP 5
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM Customer c
INNER JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC;



--Question No 02
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT pod.ProductID) AS ProductCount
FROM Supplier s
INNER JOIN PurchaseOrder po
    ON s.SupplierID = po.SupplierID
INNER JOIN PurchaseOrderDetail pod
    ON po.OrderID = pod.OrderID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(DISTINCT pod.ProductID) > 10;






--Question No_03
SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM Product p
INNER JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID
    FROM ReturnDetail
)
GROUP BY p.ProductID, p.Name;






--Question No_04
SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM Product p
INNER JOIN Category c
    ON p.CategoryID = c.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM Product p2
    WHERE p2.CategoryID = p.CategoryID
);




--Question No_05
SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM SalesOrder so
INNER JOIN Customer c
    ON so.CustomerID = c.CustomerID
INNER JOIN SalesOrderDetail sod
    ON so.OrderID = sod.OrderID
INNER JOIN Product p
    ON sod.ProductID = p.ProductID
INNER JOIN Category cat
    ON p.CategoryID = cat.CategoryID
INNER JOIN PurchaseOrderDetail pod
    ON p.ProductID = pod.ProductID
INNER JOIN PurchaseOrder po
    ON pod.OrderID = po.OrderID
INNER JOIN Supplier s
    ON po.SupplierID = s.SupplierID;




    --Question No_06
    SELECT
    sh.ShipmentID,
    l.Name AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    sd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM Shipment sh
INNER JOIN Warehouse w
    ON sh.WarehouseID = w.WarehouseID
INNER JOIN Location l
    ON w.LocationID = l.LocationID
INNER JOIN Employee e
    ON w.ManagerID = e.EmployeeID
INNER JOIN ShipmentDetail sd
    ON sh.ShipmentID = sd.ShipmentID
INNER JOIN Product p
    ON sd.ProductID = p.ProductID;





    --Question No_07
    WITH RankedOrders AS
(
    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER
        (
            PARTITION BY c.CustomerID
            ORDER BY so.TotalAmount DESC
        ) AS OrderRank
    FROM Customer c
    INNER JOIN SalesOrder so
        ON c.CustomerID = so.CustomerID
)
SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM RankedOrders
WHERE OrderRank <= 3;




--Question No_08
SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,

    LAG(sod.Quantity) OVER
    (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS PrevQuantity,

    LEAD(sod.Quantity) OVER
    (
        PARTITION BY p.ProductID
        ORDER BY so.OrderDate
    ) AS NextQuantity

FROM Product p
INNER JOIN SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
INNER JOIN SalesOrder so
    ON sod.OrderID = so.OrderID;



--Question No_09
    CREATE VIEW vw_CustomerOrderSummary
AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    SUM(so.TotalAmount) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM Customer c
LEFT JOIN SalesOrder so
    ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name;
GO




--Question No_10
CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT
        @SupplierID AS SupplierID,
        SUM(sod.TotalAmount) AS TotalSalesAmount
    FROM Supplier s
    INNER JOIN PurchaseOrder po
        ON s.SupplierID = po.SupplierID
    INNER JOIN PurchaseOrderDetail pod
        ON po.OrderID = pod.OrderID
    INNER JOIN SalesOrderDetail sod
        ON pod.ProductID = sod.ProductID
    WHERE s.SupplierID = @SupplierID;
END;
GO