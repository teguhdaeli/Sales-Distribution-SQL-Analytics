PRAGMA foreign_keys = ON;

-- 1. Sales Representatives Table
CREATE TABLE SalesReps (
    SalesRepID INTEGER PRIMARY KEY AUTOINCREMENT,
    FullName TEXT NOT NULL,
    Region TEXT NOT NULL,
    HireDate TEXT NOT NULL,
    IsActive INTEGER DEFAULT 1
);

-- 2. Monthly Sales Targets Table
CREATE TABLE SalesTargets (
    TargetID INTEGER PRIMARY KEY AUTOINCREMENT,
    SalesRepID INTEGER NOT NULL,
    TargetYear INTEGER NOT NULL,
    TargetMonth INTEGER NOT NULL CHECK (TargetMonth BETWEEN 1 AND 12),
    TargetAmount REAL NOT NULL CHECK (TargetAmount > 0),
    FOREIGN KEY (SalesRepID) REFERENCES SalesReps(SalesRepID)
);

-- 3. B2B Customers Table
CREATE TABLE Customers (
    CustomerID INTEGER PRIMARY KEY AUTOINCREMENT,
    StoreName TEXT NOT NULL,
    City TEXT NOT NULL,
    CustomerTier TEXT NOT NULL CHECK (CustomerTier IN ('Gold', 'Silver', 'Bronze')),
    RegisteredDate TEXT NOT NULL
);

-- 4. Products Inventory Table
CREATE TABLE Products (
    ProductID INTEGER PRIMARY KEY AUTOINCREMENT,
    SKU TEXT UNIQUE NOT NULL,
    ProductName TEXT NOT NULL,
    Category TEXT NOT NULL,
    UnitCost REAL NOT NULL CHECK (UnitCost >= 0),
    UnitPrice REAL NOT NULL CHECK (UnitPrice > 0),
    StockQuantity INTEGER NOT NULL DEFAULT 0 CHECK (StockQuantity >= 0)
);

-- 5. Sales Orders Header Table
CREATE TABLE Orders (
    OrderID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderDate TEXT NOT NULL,
    CustomerID INTEGER NOT NULL,
    SalesRepID INTEGER NOT NULL,
    OrderStatus TEXT NOT NULL CHECK (OrderStatus IN ('Completed', 'Pending', 'Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SalesRepID) REFERENCES SalesReps(SalesRepID)
);

-- 6. Order Line Items Table
CREATE TABLE OrderDetails (
    OrderDetailID INTEGER PRIMARY KEY AUTOINCREMENT,
    OrderID INTEGER NOT NULL,
    ProductID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    UnitPriceAtSale REAL NOT NULL CHECK (UnitPriceAtSale >= 0),
    DiscountPct REAL DEFAULT 0 CHECK (DiscountPct BETWEEN 0 AND 100),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Performance Indexes
CREATE INDEX idx_orders_date ON Orders(OrderDate);
CREATE INDEX idx_orders_salesrep ON Orders(SalesRepID);
CREATE INDEX idx_orderdetails_order ON OrderDetails(OrderID);
CREATE INDEX idx_orderdetails_product ON OrderDetails(ProductID);

-- Trigger 1: Prevent Order If Stock Is Insufficient
CREATE TRIGGER trg_ValidateStockBeforeInsert
BEFORE INSERT ON OrderDetails
BEGIN
    SELECT CASE
        WHEN (SELECT StockQuantity FROM Products WHERE ProductID = NEW.ProductID) < NEW.Quantity
        THEN RAISE(ABORT, 'Insufficient inventory stock for the requested product SKU.')
    END;
END;

-- Trigger 2: Automatically Deduct Warehouse Inventory Upon Order Entry
CREATE TRIGGER trg_DeductStockAfterInsert
AFTER INSERT ON OrderDetails
BEGIN
    UPDATE Products
    SET StockQuantity = StockQuantity - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END;
