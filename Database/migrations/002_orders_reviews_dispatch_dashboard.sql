-- ============================================================
-- Migration 002: Orders, OrderItems, Dispatch, ProductReviews,
--                PasswordResetTokens + all stored procedures
-- Run against: tenzyuk_production
-- Depends on:  Migration 001 (Users, ProductCatalog, ProductInventory,
--              ProductPricing, Brand, Category must exist)
-- ============================================================

-- ============================================================
-- 1. ORDERS
--    Customer purchase orders
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Orders')
BEGIN
    CREATE TABLE Orders (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        OrderRef        NVARCHAR(30)   NOT NULL,   -- e.g. "ORD-20250001"
        UserId          UNIQUEIDENTIFIER NOT NULL,
        Status          NVARCHAR(20)   NOT NULL DEFAULT 'pending',
            -- pending | processing | dispatched | delivered | cancelled
        PaymentMethod   NVARCHAR(50)   NOT NULL,   -- e.g. "CocoPay"
        PaymentStatus   NVARCHAR(20)   NOT NULL DEFAULT 'pending',
            -- pending | paid | failed
        ShippingName    NVARCHAR(200)  NOT NULL,
        ShippingPhone   NVARCHAR(30)   NOT NULL,
        ShippingAddress NVARCHAR(500)  NOT NULL,
        ShippingCity    NVARCHAR(100)  NOT NULL,
        SubtotalLkr     DECIMAL(18,2)  NOT NULL,
        ShippingFee     DECIMAL(18,2)  NOT NULL DEFAULT 0,
        DiscountLkr     DECIMAL(18,2)  NOT NULL DEFAULT 0,
        TotalLkr        DECIMAL(18,2)  NOT NULL,
        Notes           NVARCHAR(1000) NULL,
        CreatedAt       DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2      NULL,
        CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId)
            REFERENCES Users(Id),
        CONSTRAINT CK_Orders_Status CHECK (
            Status IN ('pending','processing','dispatched','delivered','cancelled')),
        CONSTRAINT CK_Orders_PayStatus CHECK (
            PaymentStatus IN ('pending','paid','failed'))
    );
    CREATE UNIQUE INDEX UX_Orders_OrderRef  ON Orders(OrderRef);
    CREATE        INDEX IX_Orders_UserId    ON Orders(UserId);
    CREATE        INDEX IX_Orders_Status    ON Orders(Status);
    CREATE        INDEX IX_Orders_CreatedAt ON Orders(CreatedAt DESC);
    PRINT 'Created table Orders';
END

-- ============================================================
-- 2. ORDER ITEMS
--    Line items within a customer order
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'OrderItems')
BEGIN
    CREATE TABLE OrderItems (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        OrderId     INT           NOT NULL,
        ProductId   INT           NOT NULL,
        ProductName NVARCHAR(200) NOT NULL,   -- snapshot at time of purchase
        Qty         INT           NOT NULL,
        UnitPrice   DECIMAL(18,2) NOT NULL,   -- price at time of purchase
        LineTotal   DECIMAL(18,2) NOT NULL,   -- UnitPrice * Qty
        CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId)
            REFERENCES Orders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_OrderItems_ProductCatalog FOREIGN KEY (ProductId)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_OrderItems_OrderId   ON OrderItems(OrderId);
    CREATE INDEX IX_OrderItems_ProductId ON OrderItems(ProductId);
    PRINT 'Created table OrderItems';
END

-- ============================================================
-- 3. DISPATCH
--    Tracking info added when an order is dispatched
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Dispatch')
BEGIN
    CREATE TABLE Dispatch (
        Id                  INT IDENTITY(1,1) PRIMARY KEY,
        OrderId             INT            NOT NULL,
        TrackingId          NVARCHAR(100)  NULL,
        Courier             NVARCHAR(100)  NULL,
        DispatchedAt        DATETIME2      NULL,
        EstimatedDelivery   DATE           NULL,
        DeliveredAt         DATETIME2      NULL,
        Notes               NVARCHAR(500)  NULL,
        CreatedByUserId     UNIQUEIDENTIFIER NOT NULL,
        UpdatedAt           DATETIME2      NULL,
        CONSTRAINT FK_Dispatch_Orders FOREIGN KEY (OrderId)
            REFERENCES Orders(Id),
        CONSTRAINT FK_Dispatch_Users FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id),
        CONSTRAINT UQ_Dispatch_OrderId UNIQUE (OrderId)
    );
    CREATE INDEX IX_Dispatch_CreatedByUserId ON Dispatch(CreatedByUserId);
    PRINT 'Created table Dispatch';
END

-- ============================================================
-- 4. PRODUCT REVIEWS
--    Richer review table (replaces the minimal ProductReview entity)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductReviews')
BEGIN
    CREATE TABLE ProductReviews (
        Id                  INT IDENTITY(1,1) PRIMARY KEY,
        ProductId           INT              NOT NULL,
        UserId              UNIQUEIDENTIFIER NOT NULL,
        DisplayName         NVARCHAR(100)    NOT NULL,   -- snapshot at time of review
        Rate                TINYINT          NOT NULL,   -- 1-5
        Comment             NVARCHAR(2000)   NULL,
        IsVerifiedPurchase  BIT              NOT NULL DEFAULT 0,
        IsApproved          BIT              NOT NULL DEFAULT 1,
        CreatedAt           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductReviews_ProductCatalog FOREIGN KEY (ProductId)
            REFERENCES ProductCatalog(productid),
        CONSTRAINT FK_ProductReviews_Users FOREIGN KEY (UserId)
            REFERENCES Users(Id),
        CONSTRAINT CK_Reviews_Rate CHECK (Rate BETWEEN 1 AND 5)
    );
    CREATE INDEX IX_ProductReviews_ProductId  ON ProductReviews(ProductId);
    CREATE INDEX IX_ProductReviews_UserId     ON ProductReviews(UserId);
    CREATE INDEX IX_ProductReviews_IsApproved ON ProductReviews(IsApproved);
    CREATE INDEX IX_ProductReviews_CreatedAt  ON ProductReviews(CreatedAt DESC);
    PRINT 'Created table ProductReviews';
END

-- ============================================================
-- 5. PASSWORD RESET TOKENS
--    Supports the forgot-password / reset-password flow
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordResetTokens')
BEGIN
    CREATE TABLE PasswordResetTokens (
        Id          INT IDENTITY(1,1) PRIMARY KEY,
        UserId      UNIQUEIDENTIFIER NOT NULL,
        TokenHash   NVARCHAR(100)    NOT NULL,
        ExpiresAt   DATETIME2        NOT NULL,
        UsedAt      DATETIME2        NULL,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PasswordResetTokens_Users FOREIGN KEY (UserId)
            REFERENCES Users(Id)
    );
    CREATE UNIQUE INDEX UX_PasswordResetTokens_TokenHash ON PasswordResetTokens(TokenHash);
    CREATE        INDEX IX_PasswordResetTokens_UserId    ON PasswordResetTokens(UserId);
    PRINT 'Created table PasswordResetTokens';
END

-- ============================================================
-- 6. STORED PROCEDURES
-- ============================================================

-- ------------------------------------------------------------
-- 6a. Orders — Insert
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_Insert')
    DROP PROCEDURE spOrder_Insert;
GO
CREATE PROCEDURE spOrder_Insert
    @UserId          UNIQUEIDENTIFIER,
    @OrderRef        NVARCHAR(30),
    @PaymentMethod   NVARCHAR(50),
    @ShippingName    NVARCHAR(200),
    @ShippingPhone   NVARCHAR(30),
    @ShippingAddress NVARCHAR(500),
    @ShippingCity    NVARCHAR(100),
    @SubtotalLkr     DECIMAL(18,2),
    @ShippingFee     DECIMAL(18,2),
    @DiscountLkr     DECIMAL(18,2),
    @TotalLkr        DECIMAL(18,2),
    @Notes           NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Orders
        (OrderRef, UserId, Status, PaymentMethod, PaymentStatus,
         ShippingName, ShippingPhone, ShippingAddress, ShippingCity,
         SubtotalLkr, ShippingFee, DiscountLkr, TotalLkr, Notes, CreatedAt)
    VALUES
        (@OrderRef, @UserId, 'pending', @PaymentMethod, 'pending',
         @ShippingName, @ShippingPhone, @ShippingAddress, @ShippingCity,
         @SubtotalLkr, @ShippingFee, @DiscountLkr, @TotalLkr, @Notes, SYSUTCDATETIME());

    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ------------------------------------------------------------
-- 6b. Orders — Insert OrderItem
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrderItem_Insert')
    DROP PROCEDURE spOrderItem_Insert;
GO
CREATE PROCEDURE spOrderItem_Insert
    @OrderId     INT,
    @ProductId   INT,
    @ProductName NVARCHAR(200),
    @Qty         INT,
    @UnitPrice   DECIMAL(18,2),
    @LineTotal   DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO OrderItems
        (OrderId, ProductId, ProductName, Qty, UnitPrice, LineTotal)
    VALUES
        (@OrderId, @ProductId, @ProductName, @Qty, @UnitPrice, @LineTotal);

    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ------------------------------------------------------------
-- 6c. Orders — Get by Id (two result sets: Order + OrderItems)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetById')
    DROP PROCEDURE spOrder_GetById;
GO
CREATE PROCEDURE spOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: order header + customer info
    SELECT
        o.Id, o.OrderRef, o.UserId,
        u.DisplayName  AS CustomerName,
        u.Email        AS CustomerEmail,
        o.Status, o.PaymentMethod, o.PaymentStatus,
        o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
        o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
        o.Notes, o.CreatedAt, o.UpdatedAt
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE o.Id = @Id;

    -- Result set 2: order items
    SELECT
        oi.Id, oi.OrderId, oi.ProductId, oi.ProductName,
        oi.Qty, oi.UnitPrice, oi.LineTotal
    FROM OrderItems oi
    WHERE oi.OrderId = @Id
    ORDER BY oi.Id;
END
GO

-- ------------------------------------------------------------
-- 6d. Orders — Get All (paged, filterable)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetAll')
    DROP PROCEDURE spOrder_GetAll;
GO
CREATE PROCEDURE spOrder_GetAll
    @PageSize INT,
    @Offset   INT,
    @Status   NVARCHAR(20)      = NULL,
    @UserId   UNIQUEIDENTIFIER  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        o.Id, o.OrderRef, o.UserId,
        u.DisplayName  AS CustomerName,
        u.Email        AS CustomerEmail,
        o.Status, o.PaymentMethod, o.PaymentStatus,
        o.ShippingCity,
        o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
        o.CreatedAt, o.UpdatedAt,
        (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE (@Status IS NULL OR o.Status = @Status)
      AND (@UserId IS NULL OR o.UserId = @UserId)
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ------------------------------------------------------------
-- 6e. Orders — Update Status
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_UpdateStatus')
    DROP PROCEDURE spOrder_UpdateStatus;
GO
CREATE PROCEDURE spOrder_UpdateStatus
    @Id     INT,
    @Status NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders
    SET Status    = @Status,
        UpdatedAt = SYSUTCDATETIME()
    WHERE Id = @Id;

    SELECT @@ROWCOUNT;
END
GO

-- ------------------------------------------------------------
-- 6f. Orders — Get by UserId (user's own order history, paged)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetByUserId')
    DROP PROCEDURE spOrder_GetByUserId;
GO
CREATE PROCEDURE spOrder_GetByUserId
    @UserId   UNIQUEIDENTIFIER,
    @PageSize INT,
    @Offset   INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        o.Id, o.OrderRef,
        o.Status, o.PaymentMethod, o.PaymentStatus,
        o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
        o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
        o.Notes, o.CreatedAt, o.UpdatedAt,
        (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM Orders o
    WHERE o.UserId = @UserId
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ------------------------------------------------------------
-- 6g. Dispatch — Upsert
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDispatch_Upsert')
    DROP PROCEDURE spDispatch_Upsert;
GO
CREATE PROCEDURE spDispatch_Upsert
    @OrderId           INT,
    @TrackingId        NVARCHAR(100)    = NULL,
    @Courier           NVARCHAR(100)    = NULL,
    @EstimatedDelivery DATE             = NULL,
    @Notes             NVARCHAR(500)    = NULL,
    @CreatedByUserId   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Dispatch WHERE OrderId = @OrderId)
    BEGIN
        UPDATE Dispatch
        SET TrackingId        = @TrackingId,
            Courier           = @Courier,
            EstimatedDelivery = @EstimatedDelivery,
            Notes             = @Notes,
            UpdatedAt         = SYSUTCDATETIME()
        WHERE OrderId = @OrderId;

        SELECT Id FROM Dispatch WHERE OrderId = @OrderId;
    END
    ELSE
    BEGIN
        INSERT INTO Dispatch
            (OrderId, TrackingId, Courier, DispatchedAt,
             EstimatedDelivery, Notes, CreatedByUserId)
        VALUES
            (@OrderId, @TrackingId, @Courier, SYSUTCDATETIME(),
             @EstimatedDelivery, @Notes, @CreatedByUserId);

        -- Automatically advance order to 'dispatched'
        UPDATE Orders
        SET Status    = 'dispatched',
            UpdatedAt = SYSUTCDATETIME()
        WHERE Id = @OrderId
          AND Status NOT IN ('delivered', 'cancelled');

        SELECT CAST(SCOPE_IDENTITY() AS INT);
    END
END
GO

-- ------------------------------------------------------------
-- 6h. Dispatch — Mark Delivered
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDispatch_MarkDelivered')
    DROP PROCEDURE spDispatch_MarkDelivered;
GO
CREATE PROCEDURE spDispatch_MarkDelivered
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Dispatch
    SET DeliveredAt = SYSUTCDATETIME(),
        UpdatedAt   = SYSUTCDATETIME()
    WHERE OrderId = @OrderId;

    UPDATE Orders
    SET Status    = 'delivered',
        UpdatedAt = SYSUTCDATETIME()
    WHERE Id = @OrderId;

    SELECT @@ROWCOUNT;
END
GO

-- ------------------------------------------------------------
-- 6i. Dispatch — Get Pending (orders in 'processing' awaiting dispatch)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDispatch_GetPending')
    DROP PROCEDURE spDispatch_GetPending;
GO
CREATE PROCEDURE spDispatch_GetPending
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        o.Id           AS OrderId,
        o.OrderRef,
        o.UserId,
        u.DisplayName  AS CustomerName,
        u.Email        AS CustomerEmail,
        o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
        o.TotalLkr, o.CreatedAt AS OrderCreatedAt,
        d.Id           AS DispatchId,
        d.TrackingId,
        d.Courier,
        d.DispatchedAt,
        d.EstimatedDelivery,
        d.DeliveredAt,
        d.Notes        AS DispatchNotes
    FROM Orders o
    INNER JOIN Users u        ON u.Id      = o.UserId
    LEFT  JOIN Dispatch d     ON d.OrderId = o.Id
    WHERE o.Status = 'processing'
    ORDER BY o.CreatedAt ASC;
END
GO

-- ------------------------------------------------------------
-- 6j. Product Reviews — Insert
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_Insert')
    DROP PROCEDURE spProductReview_Insert;
GO
CREATE PROCEDURE spProductReview_Insert
    @ProductId          INT,
    @UserId             UNIQUEIDENTIFIER,
    @DisplayName        NVARCHAR(100),
    @Rate               TINYINT,
    @Comment            NVARCHAR(2000) = NULL,
    @IsVerifiedPurchase BIT            = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductReviews
        (ProductId, UserId, DisplayName, Rate, Comment,
         IsVerifiedPurchase, IsApproved, CreatedAt)
    VALUES
        (@ProductId, @UserId, @DisplayName, @Rate, @Comment,
         @IsVerifiedPurchase, 1, SYSUTCDATETIME());

    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ------------------------------------------------------------
-- 6k. Product Reviews — Get by Product (public, approved only)
--     Returns two result sets: reviews + aggregate stats
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_GetByProduct')
    DROP PROCEDURE spProductReview_GetByProduct;
GO
CREATE PROCEDURE spProductReview_GetByProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: approved reviews
    SELECT
        r.Id, r.ProductId, r.UserId, r.DisplayName,
        r.Rate, r.Comment, r.IsVerifiedPurchase, r.CreatedAt
    FROM ProductReviews r
    WHERE r.ProductId  = @ProductId
      AND r.IsApproved = 1
    ORDER BY r.CreatedAt DESC;

    -- Result set 2: aggregate
    SELECT
        COUNT(*)        AS ReviewCount,
        AVG(CAST(Rate AS DECIMAL(5,2))) AS AvgRate
    FROM ProductReviews
    WHERE ProductId  = @ProductId
      AND IsApproved = 1;
END
GO

-- ------------------------------------------------------------
-- 6l. Product Reviews — Get All (admin, paged, filterable)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_GetAll')
    DROP PROCEDURE spProductReview_GetAll;
GO
CREATE PROCEDURE spProductReview_GetAll
    @PageSize   INT,
    @Offset     INT,
    @IsApproved BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        r.Id, r.ProductId,
        p.name         AS ProductName,
        r.UserId, r.DisplayName,
        r.Rate, r.Comment,
        r.IsVerifiedPurchase, r.IsApproved, r.CreatedAt
    FROM ProductReviews r
    INNER JOIN ProductCatalog p ON p.productid = r.ProductId
    WHERE (@IsApproved IS NULL OR r.IsApproved = @IsApproved)
    ORDER BY r.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ------------------------------------------------------------
-- 6m. Product Reviews — Moderate (approve / reject)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_Moderate')
    DROP PROCEDURE spProductReview_Moderate;
GO
CREATE PROCEDURE spProductReview_Moderate
    @Id         INT,
    @IsApproved BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductReviews
    SET IsApproved = @IsApproved
    WHERE Id = @Id;

    SELECT @@ROWCOUNT;
END
GO

-- ------------------------------------------------------------
-- 6n. Dashboard — Get Stats (single summary row)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetStats')
    DROP PROCEDURE spDashboard_GetStats;
GO
CREATE PROCEDURE spDashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now          DATETIME2 = SYSUTCDATETIME();
    DECLARE @MonthStart   DATETIME2 = DATEFROMPARTS(YEAR(@Now), MONTH(@Now), 1);
    DECLARE @LastMonStart DATETIME2 = DATEADD(MONTH, -1, @MonthStart);
    DECLARE @LastMonEnd   DATETIME2 = @MonthStart;

    SELECT
        -- Revenue
        ISNULL((SELECT SUM(TotalLkr) FROM Orders WHERE PaymentStatus = 'paid'), 0)
            AS TotalRevenue,

        -- Order counts by status
        (SELECT COUNT(*) FROM Orders)                                     AS TotalOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'pending')            AS PendingOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'processing')         AS ProcessingOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'dispatched')         AS DispatchedOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'delivered')          AS DeliveredOrders,

        -- Unique customers who have ordered
        (SELECT COUNT(DISTINCT UserId) FROM Orders)                       AS TotalCustomers,

        -- Product inventory stats
        (SELECT COUNT(*) FROM ProductCatalog WHERE insale = 1)            AS TotalProducts,
        (SELECT COUNT(*) FROM ProductInventory WHERE stock < 10 AND stock > 0)
            AS LowStockProducts,
        (SELECT COUNT(*) FROM ProductInventory WHERE stock = 0)           AS OutOfStockProducts,

        -- Revenue this month vs last month
        ISNULL((SELECT SUM(TotalLkr)
                FROM Orders
                WHERE PaymentStatus = 'paid'
                  AND CreatedAt >= @MonthStart), 0)
            AS RevenueThisMonth,

        ISNULL((SELECT SUM(TotalLkr)
                FROM Orders
                WHERE PaymentStatus = 'paid'
                  AND CreatedAt >= @LastMonStart
                  AND CreatedAt  < @LastMonEnd), 0)
            AS RevenueLastMonth,

        -- Orders this month vs last month
        (SELECT COUNT(*)
         FROM Orders
         WHERE CreatedAt >= @MonthStart)
            AS OrdersThisMonth,

        (SELECT COUNT(*)
         FROM Orders
         WHERE CreatedAt >= @LastMonStart
           AND CreatedAt  < @LastMonEnd)
            AS OrdersLastMonth;
END
GO

-- ------------------------------------------------------------
-- 6o. Dashboard — Revenue Monthly (last 12 months)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetRevenueMonthly')
    DROP PROCEDURE spDashboard_GetRevenueMonthly;
GO
CREATE PROCEDURE spDashboard_GetRevenueMonthly
AS
BEGIN
    SET NOCOUNT ON;

    -- Generate the last 12 calendar months (inclusive of current)
    WITH Months AS (
        SELECT
            DATEADD(MONTH, -n, DATEFROMPARTS(YEAR(SYSUTCDATETIME()), MONTH(SYSUTCDATETIME()), 1))
                AS MonthStart
        FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) AS T(n)
    ),
    OrderStats AS (
        SELECT
            DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt), 1) AS MonthStart,
            COUNT(*)                                             AS OrderCount,
            ISNULL(SUM(CASE WHEN PaymentStatus = 'paid' THEN TotalLkr ELSE 0 END), 0)
                AS Revenue
        FROM Orders
        GROUP BY DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt), 1)
    ),
    NewCustomers AS (
        SELECT
            DATEFROMPARTS(YEAR(MIN(o.CreatedAt)), MONTH(MIN(o.CreatedAt)), 1) AS MonthStart,
            COUNT(*) AS NewCount
        FROM (
            SELECT UserId, MIN(CreatedAt) AS CreatedAt
            FROM Orders
            GROUP BY UserId
        ) o
        GROUP BY DATEFROMPARTS(YEAR(o.CreatedAt), MONTH(o.CreatedAt), 1)
    )
    SELECT
        FORMAT(m.MonthStart, 'MMM yyyy')    AS MonthLabel,
        m.MonthStart,
        ISNULL(os.Revenue, 0)               AS Revenue,
        ISNULL(os.OrderCount, 0)            AS OrderCount,
        ISNULL(nc.NewCount, 0)              AS NewCustomers
    FROM Months m
    LEFT JOIN OrderStats   os ON os.MonthStart = m.MonthStart
    LEFT JOIN NewCustomers nc ON nc.MonthStart = m.MonthStart
    ORDER BY m.MonthStart ASC;
END
GO

-- ------------------------------------------------------------
-- 6p. Dashboard — Order Status Breakdown
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetOrderStatusBreakdown')
    DROP PROCEDURE spDashboard_GetOrderStatusBreakdown;
GO
CREATE PROCEDURE spDashboard_GetOrderStatusBreakdown
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        Status,
        COUNT(*) AS OrderCount
    FROM Orders
    GROUP BY Status
    ORDER BY
        CASE Status
            WHEN 'pending'     THEN 1
            WHEN 'processing'  THEN 2
            WHEN 'dispatched'  THEN 3
            WHEN 'delivered'   THEN 4
            WHEN 'cancelled'   THEN 5
            ELSE 6
        END;
END
GO

-- ------------------------------------------------------------
-- 6q. Dashboard — Category Sales
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetCategorySales')
    DROP PROCEDURE spDashboard_GetCategorySales;
GO
CREATE PROCEDURE spDashboard_GetCategorySales
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.catagoryID                       AS CategoryId,
        c.categorytype                     AS CategoryName,
        COUNT(DISTINCT o.Id)               AS OrderCount,
        SUM(oi.Qty)                        AS UnitsSold,
        SUM(CASE WHEN o.PaymentStatus = 'paid' THEN oi.LineTotal ELSE 0 END)
                                           AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders         o  ON o.Id        = oi.OrderId
    INNER JOIN ProductCatalog p  ON p.productid = oi.ProductId
    INNER JOIN Category       c  ON c.catagoryID = p.categoryid
    GROUP BY c.catagoryID, c.categorytype
    ORDER BY Revenue DESC;
END
GO

-- ------------------------------------------------------------
-- 6r. Dashboard — Top Products
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetTopProducts')
    DROP PROCEDURE spDashboard_GetTopProducts;
GO
CREATE PROCEDURE spDashboard_GetTopProducts
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
        oi.ProductId,
        oi.ProductName,
        SUM(oi.Qty)      AS UnitsSold,
        SUM(CASE WHEN o.PaymentStatus = 'paid' THEN oi.LineTotal ELSE 0 END)
                         AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders o ON o.Id = oi.OrderId
    GROUP BY oi.ProductId, oi.ProductName
    ORDER BY Revenue DESC;
END
GO

-- ------------------------------------------------------------
-- 6s. Dashboard — Recent Orders
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetRecentOrders')
    DROP PROCEDURE spDashboard_GetRecentOrders;
GO
CREATE PROCEDURE spDashboard_GetRecentOrders
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
        o.Id, o.OrderRef,
        o.UserId,
        u.DisplayName  AS CustomerName,
        u.Email        AS CustomerEmail,
        o.Status, o.PaymentStatus,
        o.TotalLkr, o.CreatedAt
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    ORDER BY o.CreatedAt DESC;
END
GO

-- ------------------------------------------------------------
-- 6t. Reports — Revenue by date range, grouped by day/week/month
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_Revenue')
    DROP PROCEDURE spReport_Revenue;
GO
CREATE PROCEDURE spReport_Revenue
    @StartDate DATE,
    @EndDate   DATE,
    @GroupBy   NVARCHAR(10) = 'month'   -- 'day' | 'week' | 'month'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start DATETIME2 = CAST(@StartDate AS DATETIME2);
    DECLARE @End   DATETIME2 = DATEADD(DAY, 1, CAST(@EndDate AS DATETIME2));

    IF @GroupBy = 'day'
    BEGIN
        SELECT
            FORMAT(CAST(CreatedAt AS DATE), 'yyyy-MM-dd') AS DateLabel,
            CAST(CreatedAt AS DATE)                        AS DateValue,
            COUNT(*)                                       AS OrderCount,
            ISNULL(SUM(CASE WHEN PaymentStatus = 'paid' THEN TotalLkr ELSE 0 END), 0)
                                                           AS Revenue
        FROM Orders
        WHERE CreatedAt >= @Start AND CreatedAt < @End
        GROUP BY CAST(CreatedAt AS DATE)
        ORDER BY DateValue;
    END
    ELSE IF @GroupBy = 'week'
    BEGIN
        SELECT
            CONCAT('W', DATEPART(ISO_WEEK, CreatedAt), ' ',
                   YEAR(DATEADD(DAY, 1 - DATEPART(WEEKDAY, CreatedAt), CAST(CreatedAt AS DATE))))
                AS DateLabel,
            DATEADD(DAY, 1 - DATEPART(WEEKDAY, CAST(CreatedAt AS DATE)),
                    CAST(CreatedAt AS DATE))               AS DateValue,
            COUNT(*)                                       AS OrderCount,
            ISNULL(SUM(CASE WHEN PaymentStatus = 'paid' THEN TotalLkr ELSE 0 END), 0)
                                                           AS Revenue
        FROM Orders
        WHERE CreatedAt >= @Start AND CreatedAt < @End
        GROUP BY
            DATEADD(DAY, 1 - DATEPART(WEEKDAY, CAST(CreatedAt AS DATE)),
                    CAST(CreatedAt AS DATE)),
            CONCAT('W', DATEPART(ISO_WEEK, CreatedAt), ' ',
                   YEAR(DATEADD(DAY, 1 - DATEPART(WEEKDAY, CreatedAt), CAST(CreatedAt AS DATE))))
        ORDER BY DateValue;
    END
    ELSE  -- default: month
    BEGIN
        SELECT
            FORMAT(DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt), 1), 'MMM yyyy')
                AS DateLabel,
            DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt), 1)
                AS DateValue,
            COUNT(*)                                       AS OrderCount,
            ISNULL(SUM(CASE WHEN PaymentStatus = 'paid' THEN TotalLkr ELSE 0 END), 0)
                                                           AS Revenue
        FROM Orders
        WHERE CreatedAt >= @Start AND CreatedAt < @End
        GROUP BY DATEFROMPARTS(YEAR(CreatedAt), MONTH(CreatedAt), 1)
        ORDER BY DateValue;
    END
END
GO

-- ------------------------------------------------------------
-- 6u. Reports — Sales by Category
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_SalesByCategory')
    DROP PROCEDURE spReport_SalesByCategory;
GO
CREATE PROCEDURE spReport_SalesByCategory
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start DATETIME2 = CAST(@StartDate AS DATETIME2);
    DECLARE @End   DATETIME2 = DATEADD(DAY, 1, CAST(@EndDate AS DATETIME2));

    SELECT
        c.catagoryID   AS CategoryId,
        c.categorytype AS CategoryName,
        SUM(oi.Qty)    AS UnitsSold,
        ISNULL(SUM(CASE WHEN o.PaymentStatus = 'paid' THEN oi.LineTotal ELSE 0 END), 0)
                       AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders         o  ON o.Id         = oi.OrderId
    INNER JOIN ProductCatalog p  ON p.productid  = oi.ProductId
    INNER JOIN Category       c  ON c.catagoryID = p.categoryid
    WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End
    GROUP BY c.catagoryID, c.categorytype
    ORDER BY Revenue DESC;
END
GO

-- ------------------------------------------------------------
-- 6v. Reports — Top Customers
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_TopCustomers')
    DROP PROCEDURE spReport_TopCustomers;
GO
CREATE PROCEDURE spReport_TopCustomers
    @Top       INT  = 20,
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start DATETIME2 = CASE WHEN @StartDate IS NOT NULL
                                    THEN CAST(@StartDate AS DATETIME2)
                                    ELSE CAST('2000-01-01' AS DATETIME2) END;
    DECLARE @End   DATETIME2 = CASE WHEN @EndDate IS NOT NULL
                                    THEN DATEADD(DAY, 1, CAST(@EndDate AS DATETIME2))
                                    ELSE CAST('9999-12-31' AS DATETIME2) END;

    SELECT TOP (@Top)
        o.UserId,
        u.DisplayName                   AS CustomerName,
        u.Email                         AS CustomerEmail,
        COUNT(DISTINCT o.Id)            AS OrderCount,
        ISNULL(SUM(CASE WHEN o.PaymentStatus = 'paid' THEN o.TotalLkr ELSE 0 END), 0)
                                        AS TotalSpent
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End
    GROUP BY o.UserId, u.DisplayName, u.Email
    ORDER BY TotalSpent DESC;
END
GO

-- ------------------------------------------------------------
-- 6w. Reports — Sales by Product
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_SalesByProduct')
    DROP PROCEDURE spReport_SalesByProduct;
GO
CREATE PROCEDURE spReport_SalesByProduct
    @StartDate DATE,
    @EndDate   DATE,
    @Top       INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Start DATETIME2 = CAST(@StartDate AS DATETIME2);
    DECLARE @End   DATETIME2 = DATEADD(DAY, 1, CAST(@EndDate AS DATETIME2));

    SELECT TOP (@Top)
        oi.ProductId,
        oi.ProductName,
        SUM(oi.Qty)    AS UnitsSold,
        ISNULL(SUM(CASE WHEN o.PaymentStatus = 'paid' THEN oi.LineTotal ELSE 0 END), 0)
                       AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders o ON o.Id = oi.OrderId
    WHERE o.CreatedAt >= @Start AND o.CreatedAt < @End
    GROUP BY oi.ProductId, oi.ProductName
    ORDER BY Revenue DESC;
END
GO

-- ------------------------------------------------------------
-- 6x. Forgot Password — Insert Token
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordResetToken_Insert')
    DROP PROCEDURE spPasswordResetToken_Insert;
GO
CREATE PROCEDURE spPasswordResetToken_Insert
    @UserId    UNIQUEIDENTIFIER,
    @TokenHash NVARCHAR(100),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO PasswordResetTokens
        (UserId, TokenHash, ExpiresAt, CreatedAt)
    VALUES
        (@UserId, @TokenHash, @ExpiresAt, SYSUTCDATETIME());

    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

-- ------------------------------------------------------------
-- 6y. Forgot Password — Validate Token
--     Returns UserId if token is valid (not used, not expired)
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordResetToken_Validate')
    DROP PROCEDURE spPasswordResetToken_Validate;
GO
CREATE PROCEDURE spPasswordResetToken_Validate
    @TokenHash NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId
    FROM PasswordResetTokens
    WHERE TokenHash = @TokenHash
      AND UsedAt    IS NULL
      AND ExpiresAt  > SYSUTCDATETIME();
END
GO

-- ------------------------------------------------------------
-- 6z. Forgot Password — Mark Token Used
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordResetToken_MarkUsed')
    DROP PROCEDURE spPasswordResetToken_MarkUsed;
GO
CREATE PROCEDURE spPasswordResetToken_MarkUsed
    @TokenHash NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PasswordResetTokens
    SET UsedAt = SYSUTCDATETIME()
    WHERE TokenHash = @TokenHash
      AND UsedAt    IS NULL;

    SELECT @@ROWCOUNT;
END
GO

-- ------------------------------------------------------------
-- 6aa. Forgot Password — Update User Password
-- ------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUser_UpdatePassword')
    DROP PROCEDURE spUser_UpdatePassword;
GO
CREATE PROCEDURE spUser_UpdatePassword
    @UserId          UNIQUEIDENTIFIER,
    @NewPasswordHash NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PasswordCredentials
    SET PasswordHash      = @NewPasswordHash,
        PasswordUpdatedAt = SYSUTCDATETIME(),
        FailedAttempts    = 0
    WHERE UserId = @UserId;

    SELECT @@ROWCOUNT;
END
GO

-- ============================================================
PRINT 'Migration 002 complete.';
