-- Create Global Schema
CREATE DATABASE IF NOT EXISTS GlobalDB;
USE GlobalDB;

-- Drop tables in reverse dependency order
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Delivery_Tracking, Delivery_Assignments, Packages, Shipments, 
Inventory_Stock, OrderDetails, Payments, Orders, Products, PromoCodes, Discounts, 
Categories, Addresses, Customers, Vehicles, Warehouses, Employees;
SET FOREIGN_KEY_CHECKS = 1;

-- Employees (Base Table)
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);

-- Warehouses (Depends on Employees)
CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY AUTO_INCREMENT,
    location VARCHAR(255) NOT NULL,
    capacity DECIMAL(10,2) NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES Employees(employee_id)
);

-- Customers (Base Table)
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    home_address VARCHAR(255)  -- For Shoppo compatibility
);

-- Addresses (Depends on Customers)
CREATE TABLE Addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    address VARCHAR(255) NOT NULL,
    additional_info TEXT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Categories (Base Table)
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_title VARCHAR(255) UNIQUE NOT NULL
);

-- Discounts (Base Table)
CREATE TABLE Discounts (
    discount_id INT PRIMARY KEY AUTO_INCREMENT,
    discount_name VARCHAR(255),
    discount_type ENUM('amount', 'percentage') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- PromoCodes (Depends on Discounts)
CREATE TABLE PromoCodes (
    promo_code VARCHAR(50) PRIMARY KEY,
    discount_id INT NOT NULL,
    minimum_purchase DECIMAL(10,2),
    start_date DATE,
    end_date DATE,
    redeemed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);

-- Products (Depends on Categories/Discounts)
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    weight DECIMAL(10,2) NOT NULL,
    category_id INT NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    discount_id INT,
    shipping_fee DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (discount_id) REFERENCES Discounts(discount_id)
);

-- Orders (Depends on Customers/PromoCodes)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    shipping_cost DECIMAL(10,2) NOT NULL,
    promo_code VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (promo_code) REFERENCES PromoCodes(promo_code)
);

-- OrderDetails (Depends on Orders/Products)
CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Payments (Depends on Orders)
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_date DATETIME NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Inventory_Stock (Depends on Products/Warehouses)
CREATE TABLE Inventory_Stock (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity_available INT NOT NULL CHECK (quantity_available >= 0),
    restock_date DATE,
    minimum_stock_level INT,
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses(warehouse_id)
);

-- Shipments (Depends on Warehouses)
CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    origin_warehouse_id INT NOT NULL,
    destination_warehouse_id INT NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    departure_time DATETIME,
    arrival_time DATETIME,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY (origin_warehouse_id) REFERENCES Warehouses(warehouse_id),
    FOREIGN KEY (destination_warehouse_id) REFERENCES Warehouses(warehouse_id)
);

-- Packages (Depends on Shipments/Orders)
CREATE TABLE Packages (
    package_id INT PRIMARY KEY AUTO_INCREMENT,
    shipment_id INT NOT NULL,
    order_id INT NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    dimensions VARCHAR(50),
    fragile_flag BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (shipment_id) REFERENCES Shipments(shipment_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Vehicles (Depends on Employees)
CREATE TABLE Vehicles (
    vehicle_id INT PRIMARY KEY AUTO_INCREMENT,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    capacity DECIMAL(10,2) NOT NULL,
    assigned_driver_id INT,
    FOREIGN KEY (assigned_driver_id) REFERENCES Employees(employee_id)
);

-- Delivery_Assignments (Depends on Employees/Packages)
CREATE TABLE Delivery_Assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_id INT NOT NULL,
    package_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    delivery_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (package_id) REFERENCES Packages(package_id)
);

-- Delivery_Tracking (Depends on Packages)
CREATE TABLE Delivery_Tracking (
    tracking_id INT PRIMARY KEY AUTO_INCREMENT,
    package_id INT NOT NULL,
    status_update_time DATETIME NOT NULL,
    location VARCHAR(255) NOT NULL,
    status_note TEXT,
    FOREIGN KEY (package_id) REFERENCES Packages(package_id)
);

-- Temporary Tables for ID Mapping
CREATE TEMPORARY TABLE CustomerMapping (old_id INT, new_id INT, source_db VARCHAR(20));
CREATE TEMPORARY TABLE ProductMapping (old_id INT, new_id INT, source_db VARCHAR(20));
CREATE TEMPORARY TABLE OrderMapping (old_id INT, new_id INT, source_db VARCHAR(20));
CREATE TEMPORARY TABLE DiscountMapping (old_id INT, new_id INT, source_db VARCHAR(20));
CREATE TEMPORARY TABLE CategoryMapping (old_id INT, new_id INT, source_db VARCHAR(20));
CREATE TEMPORARY TABLE WarehouseMapping (old_id INT, new_id INT, source_db VARCHAR(20));

/* ---------- Migrate NeverReach Data ---------- */
INSERT INTO Employees (name, position, email, phone_number)
SELECT name, position, email, phone_number
FROM neverreach_db.Employees;

INSERT INTO Warehouses (location, capacity, manager_id)
SELECT location, capacity, manager_id
FROM neverreach_db.Warehouses;

/* FIXED: Warehouse mapping */
SET @warehouse_count = (SELECT COUNT(*) FROM neverreach_db.Warehouses);
SET @sql := CONCAT(
  'INSERT INTO WarehouseMapping (old_id, new_id, source_db) ',
  'SELECT w.warehouse_id, w.warehouse_id, ''NeverReach'' ',
  'FROM Warehouses w ORDER BY w.warehouse_id DESC LIMIT ', @warehouse_count
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

INSERT INTO Vehicles (license_plate, type, capacity, assigned_driver_id)
SELECT license_plate, type, capacity, assigned_driver_id
FROM neverreach_db.Vehicles;

INSERT INTO Shipments (origin_warehouse_id, destination_warehouse_id, delivery_address, departure_time, arrival_time, status)
SELECT 
    w1.new_id, 
    w2.new_id, 
    s.address, 
    s.departure_time, 
    s.arrival_time, 
    s.status
FROM neverreach_db.Shipments s
JOIN WarehouseMapping w1 ON s.origin_warehouse_id = w1.old_id AND w1.source_db = 'NeverReach'
JOIN WarehouseMapping w2 ON s.destination_warehouse_id = w2.old_id AND w2.source_db = 'NeverReach';

/* ---------- Migrate Shoppo Data ---------- */
INSERT INTO Customers (customer_name, email, phone_number, home_address)
SELECT full_name, email, phone_number, home_address
FROM shoppo_db.Customers;

/* FIXED: Customer mapping (Shoppo) */
SET @customer_count_shoppo = (SELECT COUNT(*) FROM shoppo_db.Customers);
SET @sql := CONCAT(
  'INSERT INTO CustomerMapping (old_id, new_id, source_db) ',
  'SELECT c.customer_id, c.customer_id, ''Shoppo'' ',
  'FROM Customers c ORDER BY c.customer_id DESC LIMIT ', @customer_count_shoppo
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Categories from Shoppo */
INSERT IGNORE INTO Categories (category_title)
SELECT DISTINCT product_category 
FROM shoppo_db.Products 
WHERE product_category IS NOT NULL;

/* Migrate discounts */
INSERT INTO Discounts (discount_type, discount_value, start_date, end_date)
SELECT 
    CASE 
        WHEN discount_amount > 0 THEN 'amount'
        ELSE 'percentage'
    END,
    COALESCE(discount_amount, discount_percentage),
    start_date,
    end_date
FROM shoppo_db.Discounts;

/* FIXED: Discount mapping (Shoppo) */
SET @discount_count_shoppo = (SELECT COUNT(*) FROM shoppo_db.Discounts);
SET @sql := CONCAT(
  'INSERT INTO DiscountMapping (old_id, new_id, source_db) ',
  'SELECT d.discount_id, d.discount_id, ''Shoppo'' ',
  'FROM Discounts d ORDER BY d.discount_id DESC LIMIT ', @discount_count_shoppo
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate products */
INSERT INTO Products (product_name, description, weight, category_id, base_price, discount_id, shipping_fee)
SELECT 
    p.name,
    p.description,
    p.weight_kg,
    (SELECT category_id FROM Categories WHERE category_title = p.product_category),
    p.base_price,
    dm.new_id,
    0
FROM shoppo_db.Products p
LEFT JOIN DiscountMapping dm ON p.discount_id = dm.old_id AND dm.source_db = 'Shoppo';

/* FIXED: Product mapping (Shoppo) */
SET @product_count_shoppo = (SELECT COUNT(*) FROM shoppo_db.Products);
SET @sql := CONCAT(
  'INSERT INTO ProductMapping (old_id, new_id, source_db) ',
  'SELECT p.product_id, p.product_id, ''Shoppo'' ',
  'FROM Products p ORDER BY p.product_id DESC LIMIT ', @product_count_shoppo
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate orders */
INSERT INTO Orders (customer_id, order_date, total_amount, shipping_cost)
SELECT 
    cm.new_id,
    o.order_date,
    o.total_amount,
    o.shipping_cost
FROM shoppo_db.Orders o
JOIN CustomerMapping cm ON o.customer_id = cm.old_id AND cm.source_db = 'Shoppo';

/* FIXED: Order mapping (Shoppo) */
SET @order_count_shoppo = (SELECT COUNT(*) FROM shoppo_db.Orders);
SET @sql := CONCAT(
  'INSERT INTO OrderMapping (old_id, new_id, source_db) ',
  'SELECT o.order_id, o.order_id, ''Shoppo'' ',
  'FROM Orders o ORDER BY o.order_id DESC LIMIT ', @order_count_shoppo
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate order details */
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price)
SELECT 
    om.new_id,
    pm.new_id,
    od.quantity,
    od.price_per_unit
FROM shoppo_db.OrderDetails od
JOIN OrderMapping om ON od.order_id = om.old_id AND om.source_db = 'Shoppo'
JOIN ProductMapping pm ON od.product_id = pm.old_id AND pm.source_db = 'Shoppo';

/* Migrate payments */
INSERT INTO Payments (order_id, payment_method, payment_date, amount_paid)
SELECT 
    om.new_id,
    p.payment_method,
    p.paid_date,
    p.total_paid
FROM shoppo_db.Payments p
JOIN OrderMapping om ON p.order_id = om.old_id AND om.source_db = 'Shoppo';

/* Migrate inventory */
INSERT INTO Inventory_Stock (product_id, warehouse_id, quantity_available, minimum_stock_level)
SELECT 
    pm.new_id,
    wm.new_id,
    isk.quantity_available,
    isk.reorder_threshold
FROM shoppo_db.inventory_stock isk
JOIN ProductMapping pm ON isk.product_id = pm.old_id AND pm.source_db = 'Shoppo'
JOIN WarehouseMapping wm ON isk.warehouse_id = wm.old_id AND wm.source_db = 'NeverReach';

/* ---------- Migrate LaLaZa Data ---------- */
INSERT INTO Customers (customer_name, email, phone_number)
SELECT name, email_address, mobile
FROM lalaza_db.Users;

/* FIXED: Customer mapping (LaLaZa) */
SET @customer_count_lalaza = (SELECT COUNT(*) FROM lalaza_db.Users);
SET @sql := CONCAT(
  'INSERT INTO CustomerMapping (old_id, new_id, source_db) ',
  'SELECT c.customer_id, c.customer_id, ''LaLaZa'' ',
  'FROM Customers c ORDER BY c.customer_id DESC LIMIT ', @customer_count_lalaza
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate addresses */
INSERT INTO Addresses (customer_id, address, additional_info)
SELECT 
    cm.new_id,
    a.address,
    a.additional_info
FROM lalaza_db.Address a
JOIN CustomerMapping cm ON a.user_id = cm.old_id AND cm.source_db = 'LaLaZa';

/* Categories (ignore duplicates) */
INSERT IGNORE INTO Categories (category_title)
SELECT category_title 
FROM lalaza_db.Categories;

/* Category mapping (LaLaZa) */
INSERT INTO CategoryMapping (old_id, new_id, source_db)
SELECT 
    lc.category_id, 
    gc.category_id,
    'LaLaZa'
FROM lalaza_db.Categories lc
JOIN Categories gc ON lc.category_title = gc.category_title;

/* Promotions as discounts */
INSERT INTO Discounts (discount_name, discount_type, discount_value)
SELECT 
    promo_name,
    LOWER(discount_type),
    discount_value
FROM lalaza_db.Promotions;

/* FIXED: Discount mapping (LaLaZa) */
SET @discount_count_lalaza = (SELECT COUNT(*) FROM lalaza_db.Promotions);
SET @sql := CONCAT(
  'INSERT INTO DiscountMapping (old_id, new_id, source_db) ',
  'SELECT d.discount_id, d.discount_id, ''LaLaZa'' ',
  'FROM Discounts d ORDER BY d.discount_id DESC LIMIT ', @discount_count_lalaza
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Insert PromoCodes from LaLaZa
INSERT INTO PromoCodes (promo_code, discount_id, minimum_purchase, start_date, end_date, redeemed)
SELECT 
    pc.promo_code,
    dm.new_id,
    pc.minimum_purchase,
    pc.start_date,
    pc.end_date,
    pc.redeemed
FROM lalaza_db.PromoCodes pc
JOIN DiscountMapping dm ON pc.promo_id = dm.old_id AND dm.source_db = 'LaLaZa';

/* Migrate products */
INSERT INTO Products (product_name, description, weight, category_id, base_price, shipping_fee)
SELECT 
    i.title,
    i.summary,
    i.weight,
    cm.new_id,
    i.unit_price,
    i.shipping_fee
FROM lalaza_db.Items i
JOIN CategoryMapping cm ON i.category_id = cm.old_id AND cm.source_db = 'LaLaZa';

/* FIXED: Product mapping (LaLaZa) */
SET @product_count_lalaza = (SELECT COUNT(*) FROM lalaza_db.Items);
SET @sql := CONCAT(
  'INSERT INTO ProductMapping (old_id, new_id, source_db) ',
  'SELECT p.product_id, p.product_id, ''LaLaZa'' ',
  'FROM Products p ORDER BY p.product_id DESC LIMIT ', @product_count_lalaza
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate orders */
INSERT INTO Orders (customer_id, order_date, total_amount, shipping_cost, promo_code)
SELECT 
    cm.new_id,
    p.purchase_timestamp,
    p.subtotal + p.delivery_charge,
    p.delivery_charge,
    p.promo_code
FROM lalaza_db.Purchases p
JOIN CustomerMapping cm ON p.user_id = cm.old_id AND cm.source_db = 'LaLaZa';

/* FIXED: Order mapping (LaLaZa) */
SET @order_count_lalaza = (SELECT COUNT(*) FROM lalaza_db.Purchases);
SET @sql := CONCAT(
  'INSERT INTO OrderMapping (old_id, new_id, source_db) ',
  'SELECT o.order_id, o.order_id, ''LaLaZa'' ',
  'FROM Orders o ORDER BY o.order_id DESC LIMIT ', @order_count_lalaza
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

/* Migrate order details */
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price)
SELECT 
    om.new_id,
    pm.new_id,
    c.qty,
    i.unit_price
FROM lalaza_db.Cart c
JOIN OrderMapping om ON c.purchase_id = om.old_id AND om.source_db = 'LaLaZa'
JOIN ProductMapping pm ON c.item_id = pm.old_id AND pm.source_db = 'LaLaZa'
JOIN lalaza_db.Items i ON c.item_id = i.item_id;

/* Migrate payments */
INSERT INTO Payments (order_id, payment_method, payment_date, amount_paid)
SELECT 
    om.new_id,
    t.payment_method,
    t.txn_date,
    t.amount
FROM lalaza_db.Transactions t
JOIN OrderMapping om ON t.purchase_ref = om.old_id AND om.source_db = 'LaLaZa';

/* Migrate inventory */
INSERT INTO Inventory_Stock (product_id, warehouse_id, quantity_available)
SELECT 
    pm.new_id,
    1,
    i.quantity_available
FROM lalaza_db.Items i
JOIN ProductMapping pm ON i.item_id = pm.old_id AND pm.source_db = 'LaLaZa';

/* ---------- Dummy customer & orphaned orders (NeverReach) ---------- */
INSERT INTO Customers (customer_name, email) 
VALUES ('Dummy Customer', 'dummy@globaldb.com');

SET @dummy_customer_id = LAST_INSERT_ID();

INSERT INTO Orders (customer_id, order_date, total_amount, shipping_cost)
SELECT @dummy_customer_id, NOW(), 0, 0
FROM neverreach_db.Packages
WHERE order_id NOT IN (
    SELECT old_id FROM OrderMapping WHERE source_db = 'Shoppo'
    UNION
    SELECT old_id FROM OrderMapping WHERE source_db = 'LaLaZa'
)
GROUP BY order_id;

/* FIXED: Order mapping (NeverReach) */
SET @order_count_neverreach = (SELECT COUNT(DISTINCT order_id) FROM neverreach_db.Packages 
                               WHERE order_id NOT IN (
                                   SELECT old_id FROM OrderMapping WHERE source_db = 'Shoppo'
                                   UNION
                                   SELECT old_id FROM OrderMapping WHERE source_db = 'LaLaZa'
                               ));

INSERT INTO OrderMapping (old_id, new_id, source_db)
SELECT nr.order_id, g.order_id, 'NeverReach'
FROM neverreach_db.Packages nr
JOIN Orders g ON g.customer_id = @dummy_customer_id
WHERE nr.order_id NOT IN (
    SELECT old_id FROM OrderMapping WHERE source_db = 'Shoppo'
    UNION
    SELECT old_id FROM OrderMapping WHERE source_db = 'LaLaZa'
)
GROUP BY nr.order_id;

/* Migrate packages (NeverReach) */
INSERT INTO Packages (shipment_id, order_id, weight, dimensions, fragile_flag)
SELECT 
    s.shipment_id,
    COALESCE(om.new_id, (SELECT new_id FROM OrderMapping WHERE old_id = p.order_id AND source_db = 'NeverReach' LIMIT 1)),
    p.weight,
    p.dimensions,
    p.fragile_flag
FROM neverreach_db.Packages p
JOIN Shipments s ON p.shipment_id = s.shipment_id
LEFT JOIN OrderMapping om ON p.order_id = om.old_id AND om.source_db IN ('Shoppo', 'LaLaZa');

/* Migrate delivery assignments */
INSERT INTO Delivery_Assignments (driver_id, package_id, assigned_date, delivery_status)
SELECT 
    da.driver_id,
    p.package_id,
    da.assigned_date,
    da.delivery_status
FROM neverreach_db.Delivery_Assignments da
JOIN Packages p ON da.package_id = p.package_id;

/* Migrate tracking data */
INSERT INTO Delivery_Tracking (package_id, status_update_time, location, status_note)
SELECT 
    p.package_id,
    dt.status_update_time,
    dt.location,
    dt.status_note
FROM neverreach_db.Delivery_Tracking dt
JOIN Packages p ON dt.package_id = p.package_id;

/* ---------- Data Integrity Verification Views ---------- */
CREATE VIEW CustomerConsistency AS
SELECT 'Global' AS source, COUNT(*) AS customer_count FROM Customers
UNION
SELECT 'Shoppo', COUNT(*) FROM shoppo_db.Customers
UNION
SELECT 'LaLaZa', COUNT(*) FROM lalaza_db.Users;

CREATE VIEW ProductConsistency AS
SELECT 'Global' AS source, COUNT(*) AS product_count FROM Products
UNION
SELECT 'Shoppo', COUNT(*) FROM shoppo_db.Products
UNION
SELECT 'LaLaZa', COUNT(*) FROM lalaza_db.Items;

CREATE VIEW OrderConsistency AS
SELECT 'Global' AS source, COUNT(*) AS order_count FROM Orders
UNION
SELECT 'Shoppo', COUNT(*) FROM shoppo_db.Orders
UNION
SELECT 'LaLaZa', COUNT(*) FROM lalaza_db.Purchases;

/* Cleanup temporary tables */
DROP TEMPORARY TABLE IF EXISTS CustomerMapping;
DROP TEMPORARY TABLE IF EXISTS ProductMapping;
DROP TEMPORARY TABLE IF EXISTS OrderMapping;
DROP TEMPORARY TABLE IF EXISTS DiscountMapping;
DROP TEMPORARY TABLE IF EXISTS CategoryMapping;
DROP TEMPORARY TABLE IF EXISTS WarehouseMapping;





-- Verify record counts in GlobalDB
SELECT COUNT(*) AS Employees_Count FROM Employees;
SELECT COUNT(*) AS Warehouses_Count FROM Warehouses;
SELECT COUNT(*) AS Customers_Count FROM Customers;
SELECT COUNT(*) AS Addresses_Count FROM Addresses;
SELECT COUNT(*) AS Categories_Count FROM Categories;
SELECT COUNT(*) AS Discounts_Count FROM Discounts;
SELECT COUNT(*) AS PromoCodes_Count FROM PromoCodes;
SELECT COUNT(*) AS Products_Count FROM Products;
SELECT COUNT(*) AS Orders_Count FROM Orders;
SELECT COUNT(*) AS OrderDetails_Count FROM OrderDetails;
SELECT COUNT(*) AS Payments_Count FROM Payments;
SELECT COUNT(*) AS Inventory_Stock_Count FROM Inventory_Stock;
SELECT COUNT(*) AS Shipments_Count FROM Shipments;
SELECT COUNT(*) AS Packages_Count FROM Packages;
SELECT COUNT(*) AS Vehicles_Count FROM Vehicles;
SELECT COUNT(*) AS Delivery_Assignments_Count FROM Delivery_Assignments;
SELECT COUNT(*) AS Delivery_Tracking_Count FROM Delivery_Tracking;

-- Sample data checks
SELECT * FROM Employees LIMIT 5;
SELECT * FROM Warehouses LIMIT 5;
SELECT * FROM Customers LIMIT 5;
SELECT * FROM Addresses LIMIT 5;
SELECT * FROM Categories LIMIT 5;
SELECT * FROM Discounts LIMIT 5;
SELECT * FROM PromoCodes LIMIT 5;
SELECT * FROM Products LIMIT 5;
SELECT * FROM Orders LIMIT 5;
SELECT * FROM OrderDetails LIMIT 5;
SELECT * FROM Payments LIMIT 5;
SELECT * FROM Inventory_Stock LIMIT 5;
SELECT * FROM Shipments LIMIT 5;
SELECT * FROM Packages LIMIT 5;
SELECT * FROM Vehicles LIMIT 5;
SELECT * FROM Delivery_Assignments LIMIT 5;
SELECT * FROM Delivery_Tracking LIMIT 5;
