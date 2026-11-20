-- 1. Insert Sales Representatives
INSERT INTO SalesReps (FullName, Region, HireDate, IsActive) VALUES
('Andi Pratama', 'North Medan', '2024-03-15', 1),
('Siti Rahmawati', 'South Medan', '2024-06-01', 1),
('Budi Santoso', 'West Medan', '2025-01-10', 1),
('Rina Marlina', 'East Medan', '2025-04-20', 1),
('Dedi Kurniawan', 'Deli Serdang', '2025-08-05', 1);

-- 2. Insert Monthly Sales Targets (Aug - Oct 2026)
INSERT INTO SalesTargets (SalesRepID, TargetYear, TargetMonth, TargetAmount) VALUES
(1, 2026, 8, 50000000), (2, 2026, 8, 45000000), (3, 2026, 8, 40000000), (4, 2026, 8, 35000000), (5, 2026, 8, 30000000),
(1, 2026, 9, 55000000), (2, 2026, 9, 48000000), (3, 2026, 9, 42000000), (4, 2026, 9, 38000000), (5, 2026, 9, 33000000),
(1, 2026, 10, 60000000), (2, 2026, 10, 50000000), (3, 2026, 10, 45000000), (4, 2026, 10, 40000000), (5, 2026, 10, 35000000);

-- 3. Insert B2B Retail Customers
INSERT INTO Customers (StoreName, City, CustomerTier, RegisteredDate) VALUES
('Toko Makmur Jaya', 'Medan', 'Gold', '2024-04-10'),
('Minimarket Berkah Abadi', 'Medan', 'Gold', '2024-05-22'),
('Grosir Sumber Rezeki', 'Deli Serdang', 'Gold', '2024-07-15'),
('Warung Sembako Maju', 'Medan', 'Silver', '2025-02-01'),
('Toko Kelontong Sejahtera', 'Medan', 'Silver', '2025-03-18'),
('Swalayan Bintang Timur', 'Binjai', 'Gold', '2025-05-12'),
('Kios Harapan Baru', 'Deli Serdang', 'Bronze', '2025-09-09'),
('Toko Sinar Pagi', 'Medan', 'Bronze', '2026-01-14');

-- 4. Insert FMCG Products (Initial Stock: 2,000 units per SKU)
INSERT INTO Products (SKU, ProductName, Category, UnitCost, UnitPrice, StockQuantity) VALUES
('BEV-001', 'Teh Botol Kemasan Karton (24 pcs)', 'Beverages', 42000, 60000, 2000),
('BEV-002', 'Kopi Instan Mix Box (100 sachets)', 'Beverages', 85000, 115000, 2000),
('SNK-001', 'Wafer Cokelat Karton (20 packs)', 'Snacks', 58000, 82000, 2000),
('SNK-002', 'Keripik Kentang Balado Dus', 'Snacks', 68000, 95000, 2000),
('HPC-001', 'Sabun Cuci Piring Jeruk Nipis 800ml (12 pcs)', 'Home Care', 105000, 145000, 2000),
('HPC-002', 'Deterjen Bubuk 1kg (10 pcs)', 'Home Care', 130000, 175000, 2000);

-- 5. Insert Orders (Aug - Oct 2026)
INSERT INTO Orders (OrderDate, CustomerID, SalesRepID, OrderStatus) VALUES
('2026-08-05', 1, 1, 'Completed'),
('2026-08-12', 2, 1, 'Completed'),
('2026-08-18', 4, 2, 'Completed'),
('2026-08-25', 5, 3, 'Completed'),
('2026-09-04', 1, 1, 'Completed'),
('2026-09-10', 3, 5, 'Completed'),
('2026-09-16', 2, 2, 'Completed'),
('2026-09-24', 6, 4, 'Completed'),
('2026-10-03', 1, 1, 'Completed'),
('2026-10-11', 3, 5, 'Completed'),
('2026-10-19', 2, 2, 'Completed'),
('2026-10-27', 7, 3, 'Pending');

-- 6. Insert Order Line Items (Triggers automatically deduct stock from 2,000)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPriceAtSale, DiscountPct) VALUES
(1, 1, 350, 60000, 5.0),
(1, 5, 180, 145000, 3.0),
(2, 2, 200, 115000, 4.0),
(2, 6, 80, 175000, 0.0),
(3, 1, 300, 60000, 2.0),
(3, 3, 350, 82000, 1.0),
(4, 4, 300, 95000, 0.0),
(4, 5, 100, 145000, 5.0),
(5, 2, 320, 115000, 5.0),
(5, 6, 300, 175000, 3.0),
(6, 1, 400, 60000, 4.0),
(6, 4, 150, 95000, 2.0),
(7, 3, 280, 82000, 3.0),
(7, 5, 220, 145000, 4.0),
(8, 2, 250, 115000, 2.0),
(8, 6, 80, 175000, 1.0),
(9, 1, 420, 60000, 5.0),
(9, 5, 340, 145000, 4.0),
(10, 2, 280, 115000, 3.0),
(10, 4, 350, 95000, 2.0),
(11, 3, 260, 82000, 2.0),
(11, 6, 130, 175000, 1.0),
(12, 1, 300, 60000, 0.0),
(12, 4, 150, 95000, 0.0);
