
-- p1 ddl part (database)
CREATE DATABASE DressShopDB;
GO

USE DressShopDB;
GO

--p2 tables design 

/* i created seperate table for roles to apply normalization so will not be redundent data in users table (i did it instead of adding role coloumn in users table)*/
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME 
);
/*the relation between users table and roles table is (m-1) so i linked them using a foreign key role id in users table referenced to role id from roles table */
CREATE TABLE Users (
    UserID INT  PRIMARY KEY IDENTITY(1,1),
    RoleID INT,
    FullName NVARCHAR(120) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    UserPassword NVARCHAR(60) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
/* my database is for dressShop platform so i created categories table to link categories with products */
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1) ,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    IsDeleted BIT NOT NULL DEFAULT 0
);
/* the relation is (category 1-m products) so i linked it using foreign key category id in products table */
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1) ,
    CategoryID INT ,
    ProductName NVARCHAR(120) NOT NULL,
    Description NVARCHAR(600) NULL,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
/*the relation between orders table and products is m-m so i created a table to link between them (orderItems table)*/
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1) ,
    UserID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0 ,
    OrderStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
    IsDeleted BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE OrderItems (
    OrderItemID INT  PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1) ,
    OrderID INT NOT NULL UNIQUE, 
    PaymentMethod NVARCHAR(50) NOT NULL CHECK (PaymentMethod IN ('credit card', 'cash on delivery')),
    PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed')),
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount >= 0),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),/* to rate the product in stars 1to5*/
    Comment NVARCHAR(1000),
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Wishlist (
    WishlistID INT PRIMARY KEY IDENTITY(1,1) ,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE() ,
    UpdatedAt DATETIME ,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    -- i added this Constraint to prevent user to add same product to wishlist more than one time 
    CONSTRAINT userProductWishlist UNIQUE (UserID, ProductID)
);
GO

--p3 i described all relations above each Table 

-- p4

INSERT INTO Roles (RoleName) VALUES 
('Admin'),
('Customer');

INSERT INTO Users (RoleID, FullName, Email, UserPassword, PhoneNumber) VALUES 
(1, 'Ahmad Salameh', 'ahmad@example.com', 'pass123', '0791234567'),
(2, 'Sara Hassan', 'sara@example.com', 'pass456', '0787654321'),
(2, 'Lina Ali', 'lina@example.com', 'pass789', '0771122334'),
(2, 'Mona Khaled', 'mona@example.com', 'pass000', '0799887766');


INSERT INTO Categories (CategoryName) VALUES 
('Evening Dresses'),
('Casual Dresses'),
('Bridal Dresses');

INSERT INTO Products (CategoryID, ProductName, Description, Price, StockQuantity) VALUES 
(1, 'Red Silk Evening Dress', 'Elegant long red silk dress', 150.00, 10),
(1, 'Black Velvet Party Dress', 'Short black velvet dress', 95.00, 15),
(2, 'Floral Summer Dress', 'Cotton floral casual dress', 45.00, 25),
(2, 'White Linen Dress', 'Simple casual white linen dress', 60.00, 20),
(3, 'Lace Bridal Gown', 'Luxury white lace bridal gown', 850.00, 3);

INSERT INTO Orders (UserID, TotalAmount, OrderStatus) VALUES 
(2, 245.00, 'Delivered'),
(3, 60.00, 'Pending'),
(2, 150.00, 'Processing');

INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES 
(1, 1, 1, 150.00),
(1, 2, 1, 95.00),
(2, 4, 1, 60.00),
(3, 1, 1, 150.00);

INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus, Amount) VALUES 
(1, 'credit card', 'Completed', 245.00),
(2, 'cash on delivery', 'Pending', 60.00),
(3, 'credit card', 'Completed', 150.00);

INSERT INTO Reviews (UserID, ProductID, Rating, Comment) VALUES 
(2, 1, 5, 'Amazing dress! Excellent quality.'),
(3, 1, 4, 'Very nice fit.'),
(2, 4, 3, 'Good quality but slightly loose.');

INSERT INTO Wishlist (UserID, ProductID) VALUES 
(2, 1),
(2, 3),
(3, 5);

/*for example i updated price for a product because in real life the price changes*/
UPDATE Products 
SET Price = 135.00, UpdatedAt = GETDATE()
WHERE ProductID = 1;

/* here i pretended that i  deleted a product but actually just i changes is deleted value instead of actual delete */
UPDATE Products
SET IsDeleted = 1, UpdatedAt = GETDATE()
WHERE ProductID = 2;
GO

--p5 select queries based on scenarios

--1
SELECT o.OrderID,u.FullName,u.Email,o.OrderDate,o.TotalAmount,o.OrderStatus
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID
WHERE o.IsDeleted = 0;

--2
SELECT ProductID,ProductName,Price,StockQuantity
FROM Products
WHERE IsDeleted = 0
ORDER BY Price ASC;

--3
SELECT p.ProductID,p.ProductName,AVG(CAST(r.Rating AS DECIMAL(3,2))) AS AverageRating, COUNT(r.ReviewID) AS TotalReviews
FROM Products p
LEFT JOIN Reviews r ON p.ProductID = r.ProductID AND r.IsDeleted = 0
WHERE p.IsDeleted = 0
GROUP BY p.ProductID, p.ProductName;
--4
SELECT u.FullName,p.ProductName,p.Price,w.CreatedAt AS AddedToWishlist
FROM Wishlist w
INNER JOIN Users u ON w.UserID = u.UserID
INNER JOIN Products p ON w.ProductID = p.ProductID
WHERE w.UserID = 2 AND w.IsDeleted = 0 AND p.IsDeleted = 0;
--5
SELECT u.UserID,u.FullName, COUNT(o.OrderID) AS TotalOrders,SUM(o.TotalAmount) AS TotalSpent
FROM Users u
LEFT JOIN Orders o ON u.UserID = o.UserID AND o.IsDeleted = 0
WHERE u.IsDeleted = 0
GROUP BY u.UserID, u.FullName;
--6
SELECT ProductID,ProductName,Price
FROM Products
WHERE Price BETWEEN 50.00 AND 200.00 AND IsDeleted = 0
ORDER BY Price DESC;
--7
SELECT TOP 5 o.OrderID,u.FullName,o.OrderDate,o.TotalAmount,o.OrderStatus
FROM Orders o
INNER JOIN Users u ON o.UserID = u.UserID
WHERE o.IsDeleted = 0
ORDER BY o.OrderDate DESC;
GO
