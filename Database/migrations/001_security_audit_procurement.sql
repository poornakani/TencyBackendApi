-- ============================================================
-- Migration 001: Security, Audit Logging, Procurement
-- Run against: tenzyuk_production
-- ============================================================

-- ============================================================
-- 1. ADMIN AUDIT LOG
--    Tracks every admin API mutation (who, what, when, before/after)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AdminAuditLog')
BEGIN
    CREATE TABLE AdminAuditLog (
        Id           BIGINT IDENTITY(1,1) PRIMARY KEY,
        AdminUserId  UNIQUEIDENTIFIER  NOT NULL,
        Action       NVARCHAR(100)     NOT NULL,   -- e.g. "Product.Update", "Brand.Delete"
        EntityType   NVARCHAR(100)     NULL,        -- e.g. "Product", "Brand"
        EntityId     NVARCHAR(100)     NULL,        -- PK of the changed row
        OldValues    NVARCHAR(MAX)     NULL,        -- JSON snapshot before change
        NewValues    NVARCHAR(MAX)     NULL,        -- JSON snapshot after change
        IpAddress    NVARCHAR(50)      NULL,
        UserAgent    NVARCHAR(500)     NULL,
        CreatedAt    DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AdminAuditLog_Users FOREIGN KEY (AdminUserId)
            REFERENCES Users(Id)
    );
    CREATE INDEX IX_AdminAuditLog_AdminUserId ON AdminAuditLog(AdminUserId);
    CREATE INDEX IX_AdminAuditLog_CreatedAt   ON AdminAuditLog(CreatedAt DESC);
    PRINT 'Created table AdminAuditLog';
END

-- ============================================================
-- 2. USER LOGIN HISTORY
--    Tracks all login attempts (success + failure) per user
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserLoginHistory')
BEGIN
    CREATE TABLE UserLoginHistory (
        Id           BIGINT IDENTITY(1,1) PRIMARY KEY,
        UserId       UNIQUEIDENTIFIER  NULL,    -- NULL if email not found
        Email        NVARCHAR(256)     NOT NULL,
        IsSuccess    BIT               NOT NULL DEFAULT 0,
        FailReason   NVARCHAR(200)     NULL,    -- e.g. "InvalidPassword", "AccountLocked"
        IpAddress    NVARCHAR(50)      NULL,
        UserAgent    NVARCHAR(500)     NULL,
        AttemptedAt  DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_UserLoginHistory_Email       ON UserLoginHistory(Email);
    CREATE INDEX IX_UserLoginHistory_UserId      ON UserLoginHistory(UserId);
    CREATE INDEX IX_UserLoginHistory_AttemptedAt ON UserLoginHistory(AttemptedAt DESC);
    PRINT 'Created table UserLoginHistory';
END

-- ============================================================
-- 3. PROCUREMENT ORDERS
--    International stock purchase orders (GBP priced, rate-locked)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementOrders')
BEGIN
    CREATE TABLE ProcurementOrders (
        Id              INT IDENTITY(1,1) PRIMARY KEY,
        OrderReference  NVARCHAR(50)      NOT NULL,   -- e.g. "PO-2025-001"
        SupplierName    NVARCHAR(200)     NOT NULL,
        OrderDate       DATE              NOT NULL,
        GbpToLkr        DECIMAL(12,4)     NOT NULL,   -- rate locked at time of entry
        CourierCharges  DECIMAL(18,2)     NOT NULL DEFAULT 0,
        CustomsDuty     DECIMAL(18,2)     NOT NULL DEFAULT 0,
        OtherCharges    DECIMAL(18,2)     NOT NULL DEFAULT 0,
        Notes           NVARCHAR(1000)    NULL,
        Status          NVARCHAR(20)      NOT NULL DEFAULT 'ordered',
            -- ordered | in_transit | arrived | approved
        CreatedByUserId UNIQUEIDENTIFIER  NOT NULL,
        ApprovedByUserId UNIQUEIDENTIFIER NULL,
        ApprovedAt      DATETIME2         NULL,
        CreatedAt       DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2         NULL,
        CONSTRAINT FK_ProcurementOrders_CreatedBy  FOREIGN KEY (CreatedByUserId)  REFERENCES Users(Id),
        CONSTRAINT FK_ProcurementOrders_ApprovedBy FOREIGN KEY (ApprovedByUserId) REFERENCES Users(Id),
        CONSTRAINT CK_ProcurementOrders_Status CHECK (Status IN ('ordered','in_transit','arrived','approved'))
    );
    CREATE INDEX IX_ProcurementOrders_Status    ON ProcurementOrders(Status);
    CREATE INDEX IX_ProcurementOrders_CreatedAt ON ProcurementOrders(CreatedAt DESC);
    PRINT 'Created table ProcurementOrders';
END

-- ============================================================
-- 4. PROCUREMENT ITEMS
--    Line items within a procurement order
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementItems')
BEGIN
    CREATE TABLE ProcurementItems (
        Id                  INT IDENTITY(1,1) PRIMARY KEY,
        ProcurementOrderId  INT               NOT NULL,
        ProductId           INT               NULL,    -- NULL if product not yet in catalog
        ProductName         NVARCHAR(200)     NOT NULL,-- snapshot name at time of order
        Quantity            INT               NOT NULL,
        UnitPriceGbp        DECIMAL(18,4)     NOT NULL,
        CONSTRAINT FK_ProcurementItems_Order FOREIGN KEY (ProcurementOrderId)
            REFERENCES ProcurementOrders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_ProcurementItems_Product FOREIGN KEY (ProductId)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_ProcurementItems_OrderId ON ProcurementItems(ProcurementOrderId);
    PRINT 'Created table ProcurementItems';
END

-- ============================================================
-- 5. STORED PROCEDURES
-- ============================================================

-- 5a. Log admin action
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spAdminAuditLog_Insert')
    DROP PROCEDURE spAdminAuditLog_Insert;
GO
CREATE PROCEDURE spAdminAuditLog_Insert
    @AdminUserId  UNIQUEIDENTIFIER,
    @Action       NVARCHAR(100),
    @EntityType   NVARCHAR(100) = NULL,
    @EntityId     NVARCHAR(100) = NULL,
    @OldValues    NVARCHAR(MAX) = NULL,
    @NewValues    NVARCHAR(MAX) = NULL,
    @IpAddress    NVARCHAR(50)  = NULL,
    @UserAgent    NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AdminAuditLog
        (AdminUserId, Action, EntityType, EntityId, OldValues, NewValues, IpAddress, UserAgent, CreatedAt)
    VALUES
        (@AdminUserId, @Action, @EntityType, @EntityId, @OldValues, @NewValues, @IpAddress, @UserAgent, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS BIGINT);
END
GO

-- 5b. Log login attempt
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUserLoginHistory_Insert')
    DROP PROCEDURE spUserLoginHistory_Insert;
GO
CREATE PROCEDURE spUserLoginHistory_Insert
    @UserId      UNIQUEIDENTIFIER = NULL,
    @Email       NVARCHAR(256),
    @IsSuccess   BIT,
    @FailReason  NVARCHAR(200) = NULL,
    @IpAddress   NVARCHAR(50)  = NULL,
    @UserAgent   NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserLoginHistory
        (UserId, Email, IsSuccess, FailReason, IpAddress, UserAgent, AttemptedAt)
    VALUES
        (@UserId, @Email, @IsSuccess, @FailReason, @IpAddress, @UserAgent, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS BIGINT);
END
GO

-- 5c. Procurement Order insert
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProcurementOrder_Insert')
    DROP PROCEDURE spProcurementOrder_Insert;
GO
CREATE PROCEDURE spProcurementOrder_Insert
    @OrderReference  NVARCHAR(50),
    @SupplierName    NVARCHAR(200),
    @OrderDate       DATE,
    @GbpToLkr        DECIMAL(12,4),
    @CourierCharges  DECIMAL(18,2),
    @CustomsDuty     DECIMAL(18,2),
    @OtherCharges    DECIMAL(18,2),
    @Notes           NVARCHAR(1000) = NULL,
    @CreatedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProcurementOrders
        (OrderReference, SupplierName, OrderDate, GbpToLkr,
         CourierCharges, CustomsDuty, OtherCharges, Notes, Status, CreatedByUserId, CreatedAt)
    VALUES
        (@OrderReference, @SupplierName, @OrderDate, @GbpToLkr,
         @CourierCharges, @CustomsDuty, @OtherCharges, @Notes, 'ordered', @CreatedByUserId, SYSUTCDATETIME());
    SELECT SCOPE_IDENTITY();
END
GO

-- 5d. Procurement Order status update + approval
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProcurementOrder_UpdateStatus')
    DROP PROCEDURE spProcurementOrder_UpdateStatus;
GO
CREATE PROCEDURE spProcurementOrder_UpdateStatus
    @Id               INT,
    @Status           NVARCHAR(20),
    @ApprovedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProcurementOrders
    SET Status           = @Status,
        UpdatedAt        = SYSUTCDATETIME(),
        ApprovedByUserId = CASE WHEN @Status = 'approved' THEN @ApprovedByUserId ELSE ApprovedByUserId END,
        ApprovedAt       = CASE WHEN @Status = 'approved' THEN SYSUTCDATETIME() ELSE ApprovedAt END
    WHERE Id = @Id;

    -- When approved: bump inventory for all items that have a ProductId
    IF @Status = 'approved'
    BEGIN
        UPDATE pi2
        SET pi2.StockQuantity = pi2.StockQuantity + pi.Quantity,
            pi2.LastUpdated   = SYSUTCDATETIME()
        FROM ProductInventory pi2
        INNER JOIN ProcurementItems pi ON pi.ProductId = pi2.productid
        WHERE pi.ProcurementOrderId = @Id
          AND pi.ProductId IS NOT NULL;
    END

    SELECT @@ROWCOUNT;
END
GO

-- 5e. Get all procurement orders (with totals computed in app)
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProcurementOrder_GetAll')
    DROP PROCEDURE spProcurementOrder_GetAll;
GO
CREATE PROCEDURE spProcurementOrder_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.Id, po.OrderReference, po.SupplierName, po.OrderDate,
           po.GbpToLkr, po.CourierCharges, po.CustomsDuty, po.OtherCharges,
           po.Notes, po.Status, po.CreatedByUserId, po.ApprovedByUserId,
           po.ApprovedAt, po.CreatedAt, po.UpdatedAt
    FROM ProcurementOrders po
    ORDER BY po.CreatedAt DESC;
END
GO

-- 5f. Get single procurement order + items
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProcurementOrder_GetById')
    DROP PROCEDURE spProcurementOrder_GetById;
GO
CREATE PROCEDURE spProcurementOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.Id, po.OrderReference, po.SupplierName, po.OrderDate,
           po.GbpToLkr, po.CourierCharges, po.CustomsDuty, po.OtherCharges,
           po.Notes, po.Status, po.CreatedByUserId, po.ApprovedByUserId,
           po.ApprovedAt, po.CreatedAt, po.UpdatedAt
    FROM ProcurementOrders po
    WHERE po.Id = @Id;

    SELECT pi.Id, pi.ProcurementOrderId, pi.ProductId, pi.ProductName,
           pi.Quantity, pi.UnitPriceGbp
    FROM ProcurementItems pi
    WHERE pi.ProcurementOrderId = @Id;
END
GO

-- 5g. Insert procurement item
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProcurementItem_Insert')
    DROP PROCEDURE spProcurementItem_Insert;
GO
CREATE PROCEDURE spProcurementItem_Insert
    @ProcurementOrderId INT,
    @ProductId          INT = NULL,
    @ProductName        NVARCHAR(200),
    @Quantity           INT,
    @UnitPriceGbp       DECIMAL(18,4)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProcurementItems
        (ProcurementOrderId, ProductId, ProductName, Quantity, UnitPriceGbp)
    VALUES
        (@ProcurementOrderId, @ProductId, @ProductName, @Quantity, @UnitPriceGbp);
    SELECT SCOPE_IDENTITY();
END
GO

-- 5h. Get admin audit log (paged)
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spAdminAuditLog_GetPaged')
    DROP PROCEDURE spAdminAuditLog_GetPaged;
GO
CREATE PROCEDURE spAdminAuditLog_GetPaged
    @PageSize INT = 50,
    @Offset   INT = 0,
    @AdminUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT al.Id, al.AdminUserId, u.DisplayName AS AdminName,
           al.Action, al.EntityType, al.EntityId,
           al.OldValues, al.NewValues,
           al.IpAddress, al.UserAgent, al.CreatedAt
    FROM AdminAuditLog al
    INNER JOIN Users u ON u.Id = al.AdminUserId
    WHERE (@AdminUserId IS NULL OR al.AdminUserId = @AdminUserId)
    ORDER BY al.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- 5i. Product catalog CRUD (completing missing stored procs)
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_GetAll')
    DROP PROCEDURE spProductCatalog_GetAll;
GO
CREATE PROCEDURE spProductCatalog_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.productid, p.name, p.brandid, b.name AS BrandName,
           p.categoryid, c.name AS CategoryName,
           p.description, p.weight, p.insale, p.createdate, p.lastupdated,
           inv.StockQuantity, pr.SellingPrice, pr.OriginalPrice
    FROM ProductCatalog p
    LEFT JOIN Brand b       ON b.BrandId      = p.brandid
    LEFT JOIN Category c    ON c.CategoryId   = p.categoryid
    LEFT JOIN ProductInventory inv ON inv.productid = p.productid
    LEFT JOIN ProductPricing pr    ON pr.productid  = p.productid
    WHERE p.insale = 1
    ORDER BY p.createdate DESC;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_GetById')
    DROP PROCEDURE spProductCatalog_GetById;
GO
CREATE PROCEDURE spProductCatalog_GetById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.productid, p.name, p.brandid, b.name AS BrandName,
           p.categoryid, c.name AS CategoryName,
           p.description, p.weight, p.insale, p.createdate, p.lastupdated,
           inv.StockQuantity, pr.SellingPrice, pr.OriginalPrice
    FROM ProductCatalog p
    LEFT JOIN Brand b       ON b.BrandId      = p.brandid
    LEFT JOIN Category c    ON c.CategoryId   = p.categoryid
    LEFT JOIN ProductInventory inv ON inv.productid = p.productid
    LEFT JOIN ProductPricing pr    ON pr.productid  = p.productid
    WHERE p.productid = @ProductId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_Insert')
    DROP PROCEDURE spProductCatalog_Insert;
GO
CREATE PROCEDURE spProductCatalog_Insert
    @Name         NVARCHAR(200),
    @BrandId      INT,
    @CategoryId   INT,
    @Description  NVARCHAR(MAX) = NULL,
    @Weight       DECIMAL(18,3) = NULL,
    @InSale       BIT = 1,
    @SellingPrice DECIMAL(18,2) = 0,
    @OriginalPrice DECIMAL(18,2) = 0,
    @StockQuantity INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewId INT;

    INSERT INTO ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
    VALUES (@Name, @BrandId, @CategoryId, @Description, @Weight, @InSale, SYSUTCDATETIME());

    SET @NewId = SCOPE_IDENTITY();

    INSERT INTO ProductInventory (productid, StockQuantity, LastUpdated)
    VALUES (@NewId, @StockQuantity, SYSUTCDATETIME());

    INSERT INTO ProductPricing (productid, SellingPrice, OriginalPrice)
    VALUES (@NewId, @SellingPrice, @OriginalPrice);

    SELECT @NewId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_Update')
    DROP PROCEDURE spProductCatalog_Update;
GO
CREATE PROCEDURE spProductCatalog_Update
    @ProductId    INT,
    @Name         NVARCHAR(200),
    @BrandId      INT,
    @CategoryId   INT,
    @Description  NVARCHAR(MAX) = NULL,
    @Weight       DECIMAL(18,3) = NULL,
    @InSale       BIT = 1,
    @SellingPrice DECIMAL(18,2) = NULL,
    @OriginalPrice DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductCatalog
    SET name        = @Name,
        brandid     = @BrandId,
        categoryid  = @CategoryId,
        description = @Description,
        weight      = @Weight,
        insale      = @InSale,
        lastupdated = SYSUTCDATETIME()
    WHERE productid = @ProductId;

    IF @SellingPrice IS NOT NULL OR @OriginalPrice IS NOT NULL
        UPDATE ProductPricing
        SET SellingPrice  = COALESCE(@SellingPrice, SellingPrice),
            OriginalPrice = COALESCE(@OriginalPrice, OriginalPrice)
        WHERE productid = @ProductId;

    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_Deactivate')
    DROP PROCEDURE spProductCatalog_Deactivate;
GO
CREATE PROCEDURE spProductCatalog_Deactivate
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductCatalog
    SET insale = 0, lastupdated = SYSUTCDATETIME()
    WHERE productid = @ProductId;
    SELECT @@ROWCOUNT;
END
GO

PRINT 'Migration 001 complete.';
