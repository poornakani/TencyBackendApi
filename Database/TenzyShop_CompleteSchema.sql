-- ================================================================
-- TenzyShop — COMPLETE DATABASE SCHEMA
-- All tables (normalized) + all stored procedures
-- Run on SQL Server database: tenzyuk_production
-- Idempotent: safe to run multiple times (IF NOT EXISTS / DROP+CREATE)
-- All objects use dbo schema prefix
-- ================================================================
-- TABLE ORDER (parent → child, respects all FKs):
--   1.  Users               2.  UserRoles
--   3.  PasswordCredentials 4.  RefreshSessions
--   5.  PasswordResetTokens 6.  Brand
--   7.  Category            8.  ConcernType
--   9.  PaymentType         10. ProductCatalog
--   11. ProductInventory    12. ProductPricing
--   13. ProductImages       14. ProductFAQ
--   15. ProductConcerns     16. ProductPaymentOptions
--   17. ProductReviews      18. AdminAuditLog
--   19. UserLoginHistory    20. ProcurementOrders
--   21. ProcurementItems    22. Orders
--   23. OrderItems          24. Dispatch
-- ================================================================

USE [tenzyuk_production];
GO

-- ================================================================
-- 1. dbo.Users
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Users' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Users (
        Id            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        Email         NVARCHAR(256)    NOT NULL,
        EmailVerified BIT              NOT NULL DEFAULT 0,
        DisplayName   NVARCHAR(200)    NOT NULL,
        Status        INT              NOT NULL DEFAULT 1,
        CreatedAt     DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        LastLoginAt   DATETIME2        NULL
    );
    CREATE UNIQUE INDEX UX_Users_Email ON dbo.Users(Email);
    PRINT 'Created table: dbo.Users';
END
GO

-- ================================================================
-- 2. dbo.UserRoles  (RoleId: 1=Admin, 2=Customer)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserRoles' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.UserRoles (
        UserId     UNIQUEIDENTIFIER NOT NULL,
        RoleId     INT              NOT NULL,
        AssignedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_UserRoles PRIMARY KEY (UserId, RoleId),
        CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    PRINT 'Created table: dbo.UserRoles';
END
GO

-- ================================================================
-- 3. dbo.PasswordCredentials
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordCredentials' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.PasswordCredentials (
        UserId       UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        PasswordHash NVARCHAR(512)    NOT NULL,
        CreatedAt    DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt    DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PasswordCredentials_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    PRINT 'Created table: dbo.PasswordCredentials';
END
GO

-- ================================================================
-- 4. dbo.RefreshSessions
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RefreshSessions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.RefreshSessions (
        Id           INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UserId       UNIQUEIDENTIFIER NOT NULL,
        TokenHash    NVARCHAR(512)    NOT NULL,
        ExpiresAt    DATETIME2        NOT NULL,
        RevokedAt    DATETIME2        NULL,
        CreatedAt    DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        DeviceInfo   NVARCHAR(500)    NULL,
        CONSTRAINT FK_RefreshSessions_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_RefreshSessions_TokenHash ON dbo.RefreshSessions(TokenHash);
    CREATE INDEX IX_RefreshSessions_UserId    ON dbo.RefreshSessions(UserId);
    PRINT 'Created table: dbo.RefreshSessions';
END
GO

-- ================================================================
-- 5. dbo.PasswordResetTokens
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordResetTokens' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.PasswordResetTokens (
        Id          INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UserId      UNIQUEIDENTIFIER NOT NULL,
        TokenHash   NVARCHAR(512)    NOT NULL,
        ExpiresAt   DATETIME2        NOT NULL,
        UsedAt      DATETIME2        NULL,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PasswordResetTokens_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_PasswordResetTokens_TokenHash ON dbo.PasswordResetTokens(TokenHash);
    PRINT 'Created table: dbo.PasswordResetTokens';
END
GO

-- ================================================================
-- 6. dbo.Brand
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Brand' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Brand (
        BrandId     INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        BrandName   NVARCHAR(200) NOT NULL,
        Description NVARCHAR(500) NULL,
        LogoUrl     NVARCHAR(500) NULL,
        Status      INT           NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    PRINT 'Created table: dbo.Brand';
END
GO

-- ================================================================
-- 7. dbo.Category  (PK column: catagoryID — preserved as-is)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Category' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Category (
        catagoryID   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        CategoryName NVARCHAR(200) NOT NULL,
        Description  NVARCHAR(500) NULL,
        ImageUrl     NVARCHAR(500) NULL,
        Status       INT           NOT NULL DEFAULT 1,
        CreatedAt    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt    DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    PRINT 'Created table: dbo.Category';
END
GO

-- ================================================================
-- 8. dbo.ConcernType
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ConcernType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ConcernType (
        ConcernTypeId   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ConcernTypeName NVARCHAR(200) NOT NULL,
        Description     NVARCHAR(500) NULL,
        Status          INT           NOT NULL DEFAULT 1,
        CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    PRINT 'Created table: dbo.ConcernType';
END
GO

-- ================================================================
-- 9. dbo.PaymentType
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PaymentType' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.PaymentType (
        PaymentTypeId   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        PaymentTypeName NVARCHAR(200) NOT NULL,
        Description     NVARCHAR(500) NULL,
        Status          INT           NOT NULL DEFAULT 1,
        CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
    );
    PRINT 'Created table: dbo.PaymentType';
END
GO

-- ================================================================
-- 10. dbo.ProductCatalog  (FK to Category uses catagoryID)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductCatalog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductCatalog (
        ProductId   INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductName NVARCHAR(300)    NOT NULL,
        Description NVARCHAR(MAX)    NULL,
        BrandId     INT              NULL,
        CategoryId  INT              NULL,
        Status      INT              NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductCatalog_Brand    FOREIGN KEY (BrandId)    REFERENCES dbo.Brand(BrandId),
        CONSTRAINT FK_ProductCatalog_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Category(catagoryID)
    );
    PRINT 'Created table: dbo.ProductCatalog';
END
GO

-- ================================================================
-- 11. dbo.ProductInventory  (columns: stock, LastStockUpdateUTC)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductInventory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductInventory (
        InventoryId        INT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId          INT       NOT NULL UNIQUE,
        stock              INT       NOT NULL DEFAULT 0,
        LastStockUpdateUTC DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductInventory_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId)
    );
    PRINT 'Created table: dbo.ProductInventory';
END
GO

-- ================================================================
-- 12. dbo.ProductPricing
--     Actual columns: PricingId, price, discountrate, StartUTC, EndUTC, createdate, lastupdated
--     price       = selling price (SellingPrice in API)
--     discountrate= % off (OriginalPrice = ROUND(price / (1 - discountrate/100), 2))
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductPricing' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductPricing (
        PricingId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId    INT           NOT NULL,
        price        DECIMAL(18,2) NOT NULL,
        discountrate DECIMAL(5,2)  NOT NULL DEFAULT 0,
        StartUTC     DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        EndUTC       DATETIME2     NULL,
        createdate   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        lastupdated  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductPricing_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId)
    );
    CREATE INDEX IX_ProductPricing_ProductId ON dbo.ProductPricing(ProductId);
    PRINT 'Created table: dbo.ProductPricing';
END
GO

-- ================================================================
-- 13. dbo.ProductImages
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductImages' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductImages (
        ImageId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId  INT           NOT NULL,
        ImageUrl   NVARCHAR(500) NOT NULL,
        IsPrimary  BIT           NOT NULL DEFAULT 0,
        SortOrder  INT           NOT NULL DEFAULT 0,
        CreatedAt  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductImages_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId)
    );
    CREATE INDEX IX_ProductImages_ProductId ON dbo.ProductImages(ProductId);
    PRINT 'Created table: dbo.ProductImages';
END
GO

-- ================================================================
-- 14. dbo.ProductFAQ
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductFAQ' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductFAQ (
        FAQId     INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId INT          NOT NULL,
        Question  NVARCHAR(500) NOT NULL,
        Answer    NVARCHAR(MAX) NOT NULL,
        Status    INT          NOT NULL DEFAULT 1,
        CreatedAt DATETIME2    NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductFAQ_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId)
    );
    CREATE INDEX IX_ProductFAQ_ProductId ON dbo.ProductFAQ(ProductId);
    PRINT 'Created table: dbo.ProductFAQ';
END
GO

-- ================================================================
-- 15. dbo.ProductConcerns
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductConcerns' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductConcerns (
        ProductConcernId INT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId        INT       NOT NULL,
        ConcernTypeId    INT       NOT NULL,
        CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductConcerns_Product     FOREIGN KEY (ProductId)     REFERENCES dbo.ProductCatalog(ProductId),
        CONSTRAINT FK_ProductConcerns_ConcernType FOREIGN KEY (ConcernTypeId) REFERENCES dbo.ConcernType(ConcernTypeId)
    );
    CREATE INDEX IX_ProductConcerns_ProductId ON dbo.ProductConcerns(ProductId);
    PRINT 'Created table: dbo.ProductConcerns';
END
GO

-- ================================================================
-- 16. dbo.ProductPaymentOptions
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductPaymentOptions' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductPaymentOptions (
        ProductPaymentId INT       NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId        INT       NOT NULL,
        PaymentTypeId    INT       NOT NULL,
        CreatedAt        DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductPaymentOptions_Product     FOREIGN KEY (ProductId)     REFERENCES dbo.ProductCatalog(ProductId),
        CONSTRAINT FK_ProductPaymentOptions_PaymentType FOREIGN KEY (PaymentTypeId) REFERENCES dbo.PaymentType(PaymentTypeId)
    );
    CREATE INDEX IX_ProductPaymentOptions_ProductId ON dbo.ProductPaymentOptions(ProductId);
    PRINT 'Created table: dbo.ProductPaymentOptions';
END
GO

-- ================================================================
-- 17. dbo.ProductReviews
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductReviews' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProductReviews (
        ReviewId    INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProductId   INT              NOT NULL,
        UserId      UNIQUEIDENTIFIER NOT NULL,
        Rating      INT              NOT NULL,
        Title       NVARCHAR(300)    NULL,
        Body        NVARCHAR(MAX)    NULL,
        Status      INT              NOT NULL DEFAULT 1,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductReviews_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId),
        CONSTRAINT FK_ProductReviews_User    FOREIGN KEY (UserId)    REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_ProductReviews_ProductId ON dbo.ProductReviews(ProductId);
    CREATE INDEX IX_ProductReviews_UserId    ON dbo.ProductReviews(UserId);
    PRINT 'Created table: dbo.ProductReviews';
END
GO

-- ================================================================
-- 18. dbo.AdminAuditLog
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AdminAuditLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.AdminAuditLog (
        AuditId     INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        AdminUserId UNIQUEIDENTIFIER NOT NULL,
        Action      NVARCHAR(200)    NOT NULL,
        EntityName  NVARCHAR(200)    NULL,
        EntityId    NVARCHAR(100)    NULL,
        OldValues   NVARCHAR(MAX)    NULL,
        NewValues   NVARCHAR(MAX)    NULL,
        IpAddress   NVARCHAR(50)     NULL,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AdminAuditLog_User FOREIGN KEY (AdminUserId) REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_AdminAuditLog_AdminUserId ON dbo.AdminAuditLog(AdminUserId);
    CREATE INDEX IX_AdminAuditLog_CreatedAt   ON dbo.AdminAuditLog(CreatedAt DESC);
    PRINT 'Created table: dbo.AdminAuditLog';
END
GO

-- ================================================================
-- 19. dbo.UserLoginHistory
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserLoginHistory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.UserLoginHistory (
        HistoryId  INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UserId     UNIQUEIDENTIFIER NOT NULL,
        LoginAt    DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        IpAddress  NVARCHAR(50)     NULL,
        DeviceInfo NVARCHAR(500)    NULL,
        CONSTRAINT FK_UserLoginHistory_User FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_UserLoginHistory_UserId ON dbo.UserLoginHistory(UserId);
    PRINT 'Created table: dbo.UserLoginHistory';
END
GO

-- ================================================================
-- 20. dbo.ProcurementOrders
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementOrders' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProcurementOrders (
        ProcurementId   INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        SupplierName    NVARCHAR(300)    NOT NULL,
        SupplierContact NVARCHAR(500)    NULL,
        Status          NVARCHAR(50)     NOT NULL DEFAULT 'Pending',
        TotalCost       DECIMAL(18,2)    NOT NULL DEFAULT 0,
        OrderedBy       UNIQUEIDENTIFIER NOT NULL,
        OrderedAt       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        ReceivedAt      DATETIME2        NULL,
        Notes           NVARCHAR(MAX)    NULL,
        CONSTRAINT FK_ProcurementOrders_User FOREIGN KEY (OrderedBy) REFERENCES dbo.Users(Id)
    );
    PRINT 'Created table: dbo.ProcurementOrders';
END
GO

-- ================================================================
-- 21. dbo.ProcurementItems
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementItems' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.ProcurementItems (
        ProcurementItemId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ProcurementId     INT           NOT NULL,
        ProductId         INT           NOT NULL,
        Quantity          INT           NOT NULL,
        UnitCost          DECIMAL(18,2) NOT NULL,
        CONSTRAINT FK_ProcurementItems_Order   FOREIGN KEY (ProcurementId) REFERENCES dbo.ProcurementOrders(ProcurementId),
        CONSTRAINT FK_ProcurementItems_Product FOREIGN KEY (ProductId)     REFERENCES dbo.ProductCatalog(ProductId)
    );
    CREATE INDEX IX_ProcurementItems_ProcurementId ON dbo.ProcurementItems(ProcurementId);
    PRINT 'Created table: dbo.ProcurementItems';
END
GO

-- ================================================================
-- 22. dbo.Orders
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Orders' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Orders (
        Id            INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UserId        UNIQUEIDENTIFIER NOT NULL,
        Status        NVARCHAR(50)     NOT NULL DEFAULT 'Pending',
        TotalLkr      DECIMAL(18,2)    NOT NULL DEFAULT 0,
        ShippingName  NVARCHAR(200)    NULL,
        ShippingPhone NVARCHAR(50)     NULL,
        ShippingAddr  NVARCHAR(500)    NULL,
        Notes         NVARCHAR(MAX)    NULL,
        CreatedAt     DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt     DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Orders_User FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
    );
    CREATE INDEX IX_Orders_UserId    ON dbo.Orders(UserId);
    CREATE INDEX IX_Orders_Status    ON dbo.Orders(Status);
    CREATE INDEX IX_Orders_CreatedAt ON dbo.Orders(CreatedAt DESC);
    PRINT 'Created table: dbo.Orders';
END
GO

-- ================================================================
-- 23. dbo.OrderItems
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'OrderItems' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.OrderItems (
        OrderItemId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        OrderId     INT           NOT NULL,
        ProductId   INT           NOT NULL,
        Quantity    INT           NOT NULL,
        UnitPrice   DECIMAL(18,2) NOT NULL,
        CONSTRAINT FK_OrderItems_Order   FOREIGN KEY (OrderId)   REFERENCES dbo.Orders(Id),
        CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(ProductId)
    );
    CREATE INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId);
    PRINT 'Created table: dbo.OrderItems';
END
GO

-- ================================================================
-- 24. dbo.Dispatch
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Dispatch' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.Dispatch (
        DispatchId      INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
        OrderId         INT           NOT NULL UNIQUE,
        CourierName     NVARCHAR(200) NULL,
        TrackingNumber  NVARCHAR(200) NULL,
        Status          NVARCHAR(50)  NOT NULL DEFAULT 'Pending',
        DispatchedAt    DATETIME2     NULL,
        DeliveredAt     DATETIME2     NULL,
        Notes           NVARCHAR(MAX) NULL,
        CreatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_Dispatch_Order FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id)
    );
    PRINT 'Created table: dbo.Dispatch';
END
GO


-- ================================================================
-- ================================================================
--  STORED PROCEDURES
-- ================================================================
-- ================================================================

-- ================================================================
-- USER procedures
-- ================================================================
IF OBJECT_ID('dbo.spUser_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_Insert;
GO
CREATE PROCEDURE dbo.spUser_Insert
    @Email       NVARCHAR(256),
    @DisplayName NVARCHAR(200),
    @PasswordHash NVARCHAR(512),
    @RoleId      INT = 2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewId UNIQUEIDENTIFIER = NEWID();

    INSERT INTO dbo.Users (Id, Email, DisplayName, Status, CreatedAt)
    VALUES (@NewId, @Email, @DisplayName, 1, SYSUTCDATETIME());

    INSERT INTO dbo.UserRoles (UserId, RoleId)
    VALUES (@NewId, @RoleId);

    INSERT INTO dbo.PasswordCredentials (UserId, PasswordHash)
    VALUES (@NewId, @PasswordHash);

    SELECT u.Id, u.Email, u.EmailVerified, u.DisplayName, u.Status, u.CreatedAt, u.LastLoginAt,
           ur.RoleId
    FROM   dbo.Users u
    JOIN   dbo.UserRoles ur ON ur.UserId = u.Id
    WHERE  u.Id = @NewId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_GetByEmail', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_GetByEmail;
GO
CREATE PROCEDURE dbo.spUser_GetByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Email, u.EmailVerified, u.DisplayName, u.Status, u.CreatedAt, u.LastLoginAt,
           pc.PasswordHash,
           ur.RoleId
    FROM   dbo.Users u
    JOIN   dbo.PasswordCredentials pc ON pc.UserId = u.Id
    LEFT JOIN dbo.UserRoles ur        ON ur.UserId = u.Id
    WHERE  u.Email = @Email;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_GetById;
GO
CREATE PROCEDURE dbo.spUser_GetById
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Email, u.EmailVerified, u.DisplayName, u.Status, u.CreatedAt, u.LastLoginAt,
           ur.RoleId
    FROM   dbo.Users u
    LEFT JOIN dbo.UserRoles ur ON ur.UserId = u.Id
    WHERE  u.Id = @UserId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_Update;
GO
CREATE PROCEDURE dbo.spUser_Update
    @UserId      UNIQUEIDENTIFIER,
    @DisplayName NVARCHAR(200),
    @Email       NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Users
    SET    DisplayName = @DisplayName,
           Email       = @Email
    WHERE  Id = @UserId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_UpdatePassword', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_UpdatePassword;
GO
CREATE PROCEDURE dbo.spUser_UpdatePassword
    @UserId      UNIQUEIDENTIFIER,
    @PasswordHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PasswordCredentials
    SET    PasswordHash = @PasswordHash,
           UpdatedAt    = SYSUTCDATETIME()
    WHERE  UserId = @UserId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_UpdateLastLogin', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_UpdateLastLogin;
GO
CREATE PROCEDURE dbo.spUser_UpdateLastLogin
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Users
    SET    LastLoginAt = SYSUTCDATETIME()
    WHERE  Id = @UserId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spUser_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.spUser_GetAll;
GO
CREATE PROCEDURE dbo.spUser_GetAll
    @PageSize INT,
    @Offset   INT,
    @Search   NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Id, u.Email, u.DisplayName, u.Status, u.CreatedAt, u.LastLoginAt,
           ur.RoleId,
           COALESCE(SUM(o.TotalLkr), 0) AS TotalSpent,
           COUNT(DISTINCT o.Id)         AS TotalOrders
    FROM   dbo.Users u
    LEFT JOIN dbo.UserRoles ur ON ur.UserId = u.Id
    LEFT JOIN dbo.Orders o     ON o.UserId  = u.Id
    WHERE  (@Search IS NULL
            OR u.DisplayName LIKE '%' + @Search + '%'
            OR u.Email       LIKE '%' + @Search + '%')
    GROUP BY u.Id, u.Email, u.DisplayName, u.Status, u.CreatedAt, u.LastLoginAt, ur.RoleId
    ORDER BY u.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ================================================================
-- REFRESH TOKEN procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_RefreshToken_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RefreshToken_Create;
GO
CREATE PROCEDURE dbo.sp_RefreshToken_Create
    @UserId     UNIQUEIDENTIFIER,
    @TokenHash  NVARCHAR(512),
    @ExpiresAt  DATETIME2,
    @DeviceInfo NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.RefreshSessions (UserId, TokenHash, ExpiresAt, DeviceInfo)
    VALUES (@UserId, @TokenHash, @ExpiresAt, @DeviceInfo);
    SELECT SCOPE_IDENTITY() AS Id;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_RefreshToken_GetByHash', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RefreshToken_GetByHash;
GO
CREATE PROCEDURE dbo.sp_RefreshToken_GetByHash
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, UserId, TokenHash, ExpiresAt, RevokedAt, CreatedAt, DeviceInfo
    FROM   dbo.RefreshSessions
    WHERE  TokenHash = @TokenHash;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_RefreshToken_Revoke', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RefreshToken_Revoke;
GO
CREATE PROCEDURE dbo.sp_RefreshToken_Revoke
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.RefreshSessions
    SET    RevokedAt = SYSUTCDATETIME()
    WHERE  TokenHash = @TokenHash;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_RefreshToken_RevokeAllForUser', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_RefreshToken_RevokeAllForUser;
GO
CREATE PROCEDURE dbo.sp_RefreshToken_RevokeAllForUser
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.RefreshSessions
    SET    RevokedAt = SYSUTCDATETIME()
    WHERE  UserId    = @UserId
      AND  RevokedAt IS NULL;
END
GO

-- ================================================================
-- PASSWORD RESET TOKEN procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_PasswordResetToken_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PasswordResetToken_Create;
GO
CREATE PROCEDURE dbo.sp_PasswordResetToken_Create
    @UserId    UNIQUEIDENTIFIER,
    @TokenHash NVARCHAR(512),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    -- Invalidate existing tokens for this user
    UPDATE dbo.PasswordResetTokens
    SET    UsedAt = SYSUTCDATETIME()
    WHERE  UserId = @UserId AND UsedAt IS NULL;

    INSERT INTO dbo.PasswordResetTokens (UserId, TokenHash, ExpiresAt)
    VALUES (@UserId, @TokenHash, @ExpiresAt);
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_PasswordResetToken_GetByHash', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PasswordResetToken_GetByHash;
GO
CREATE PROCEDURE dbo.sp_PasswordResetToken_GetByHash
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, UserId, TokenHash, ExpiresAt, UsedAt, CreatedAt
    FROM   dbo.PasswordResetTokens
    WHERE  TokenHash  = @TokenHash
      AND  UsedAt     IS NULL
      AND  ExpiresAt  > SYSUTCDATETIME();
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_PasswordResetToken_MarkUsed', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PasswordResetToken_MarkUsed;
GO
CREATE PROCEDURE dbo.sp_PasswordResetToken_MarkUsed
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PasswordResetTokens
    SET    UsedAt = SYSUTCDATETIME()
    WHERE  TokenHash = @TokenHash;
END
GO

-- ================================================================
-- BRAND procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_Brand_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_GetAll;
GO
CREATE PROCEDURE dbo.sp_Brand_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BrandId, BrandName, Description, LogoUrl, Status, CreatedAt, UpdatedAt
    FROM   dbo.Brand
    WHERE  Status = 1
    ORDER BY BrandName;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Brand_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_GetById;
GO
CREATE PROCEDURE dbo.sp_Brand_GetById
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BrandId, BrandName, Description, LogoUrl, Status, CreatedAt, UpdatedAt
    FROM   dbo.Brand
    WHERE  BrandId = @BrandId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Brand_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Create;
GO
CREATE PROCEDURE dbo.sp_Brand_Create
    @BrandName   NVARCHAR(200),
    @Description NVARCHAR(500) = NULL,
    @LogoUrl     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Brand (BrandName, Description, LogoUrl)
    VALUES (@BrandName, @Description, @LogoUrl);
    SELECT SCOPE_IDENTITY() AS BrandId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Brand_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Update;
GO
CREATE PROCEDURE dbo.sp_Brand_Update
    @BrandId     INT,
    @BrandName   NVARCHAR(200),
    @Description NVARCHAR(500) = NULL,
    @LogoUrl     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Brand
    SET    BrandName   = @BrandName,
           Description = @Description,
           LogoUrl     = @LogoUrl,
           UpdatedAt   = SYSUTCDATETIME()
    WHERE  BrandId = @BrandId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Brand_Deactive', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Deactive;
GO
CREATE PROCEDURE dbo.sp_Brand_Deactive
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Brand SET Status = 0, UpdatedAt = SYSUTCDATETIME() WHERE BrandId = @BrandId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Brand_Active', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Active;
GO
CREATE PROCEDURE dbo.sp_Brand_Active
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Brand SET Status = 1, UpdatedAt = SYSUTCDATETIME() WHERE BrandId = @BrandId;
END
GO

-- ================================================================
-- CATEGORY procedures  (PK: catagoryID)
-- ================================================================
IF OBJECT_ID('dbo.sp_Category_GetAllActive', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_GetAllActive;
GO
CREATE PROCEDURE dbo.sp_Category_GetAllActive
AS
BEGIN
    SET NOCOUNT ON;
    SELECT catagoryID, CategoryName, Description, ImageUrl, Status, CreatedAt, UpdatedAt
    FROM   dbo.Category
    WHERE  Status = 1
    ORDER BY CategoryName;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Category_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_GetById;
GO
CREATE PROCEDURE dbo.sp_Category_GetById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT catagoryID, CategoryName, Description, ImageUrl, Status, CreatedAt, UpdatedAt
    FROM   dbo.Category
    WHERE  catagoryID = @CategoryId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Category_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Create;
GO
CREATE PROCEDURE dbo.sp_Category_Create
    @CategoryName NVARCHAR(200),
    @Description  NVARCHAR(500) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Category (CategoryName, Description, ImageUrl)
    VALUES (@CategoryName, @Description, @ImageUrl);
    SELECT SCOPE_IDENTITY() AS catagoryID;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Category_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Update;
GO
CREATE PROCEDURE dbo.sp_Category_Update
    @CategoryId   INT,
    @CategoryName NVARCHAR(200),
    @Description  NVARCHAR(500) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category
    SET    CategoryName = @CategoryName,
           Description  = @Description,
           ImageUrl     = @ImageUrl,
           UpdatedAt    = SYSUTCDATETIME()
    WHERE  catagoryID = @CategoryId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Category_Deactive', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Deactive;
GO
CREATE PROCEDURE dbo.sp_Category_Deactive
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category SET Status = 0, UpdatedAt = SYSUTCDATETIME() WHERE catagoryID = @CategoryId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_Category_Active', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Active;
GO
CREATE PROCEDURE dbo.sp_Category_Active
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category SET Status = 1, UpdatedAt = SYSUTCDATETIME() WHERE catagoryID = @CategoryId;
END
GO

-- ================================================================
-- CONCERN TYPE procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_ConcernType_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetAll;
GO
CREATE PROCEDURE dbo.sp_ConcernType_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernTypeName, Description, Status, CreatedAt, UpdatedAt
    FROM   dbo.ConcernType
    WHERE  Status = 1
    ORDER BY ConcernTypeName;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ConcernType_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetById;
GO
CREATE PROCEDURE dbo.sp_ConcernType_GetById
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernTypeName, Description, Status, CreatedAt, UpdatedAt
    FROM   dbo.ConcernType
    WHERE  ConcernTypeId = @ConcernTypeId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ConcernType_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Create;
GO
CREATE PROCEDURE dbo.sp_ConcernType_Create
    @ConcernTypeName NVARCHAR(200),
    @Description     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ConcernType (ConcernTypeName, Description)
    VALUES (@ConcernTypeName, @Description);
    SELECT SCOPE_IDENTITY() AS ConcernTypeId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ConcernType_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Update;
GO
CREATE PROCEDURE dbo.sp_ConcernType_Update
    @ConcernTypeId   INT,
    @ConcernTypeName NVARCHAR(200),
    @Description     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ConcernType
    SET    ConcernTypeName = @ConcernTypeName,
           Description     = @Description,
           UpdatedAt       = SYSUTCDATETIME()
    WHERE  ConcernTypeId = @ConcernTypeId;
END
GO

-- ================================================================
-- PAYMENT TYPE procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_PaymentType_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PaymentType_GetAll;
GO
CREATE PROCEDURE dbo.sp_PaymentType_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId, PaymentTypeName, Description, Status, CreatedAt, UpdatedAt
    FROM   dbo.PaymentType
    WHERE  Status = 1
    ORDER BY PaymentTypeName;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_PaymentType_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PaymentType_GetById;
GO
CREATE PROCEDURE dbo.sp_PaymentType_GetById
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId, PaymentTypeName, Description, Status, CreatedAt, UpdatedAt
    FROM   dbo.PaymentType
    WHERE  PaymentTypeId = @PaymentTypeId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_PaymentType_Create', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PaymentType_Create;
GO
CREATE PROCEDURE dbo.sp_PaymentType_Create
    @PaymentTypeName NVARCHAR(200),
    @Description     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PaymentType (PaymentTypeName, Description)
    VALUES (@PaymentTypeName, @Description);
    SELECT SCOPE_IDENTITY() AS PaymentTypeId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_PaymentType_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_PaymentType_Update;
GO
CREATE PROCEDURE dbo.sp_PaymentType_Update
    @PaymentTypeId   INT,
    @PaymentTypeName NVARCHAR(200),
    @Description     NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType
    SET    PaymentTypeName = @PaymentTypeName,
           Description     = @Description,
           UpdatedAt       = SYSUTCDATETIME()
    WHERE  PaymentTypeId = @PaymentTypeId;
END
GO

-- ================================================================
-- PRODUCT CATALOG procedures
-- Note: price = SellingPrice; OriginalPrice = ROUND(price / (1 - discountrate/100), 2)
-- ================================================================
IF OBJECT_ID('dbo.spProductCatalog_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetAll;
GO
CREATE PROCEDURE dbo.spProductCatalog_GetAll
    @PageSize   INT,
    @Offset     INT,
    @CategoryId INT           = NULL,
    @BrandId    INT           = NULL,
    @Search     NVARCHAR(300) = NULL,
    @MinPrice   DECIMAL(18,2) = NULL,
    @MaxPrice   DECIMAL(18,2) = NULL,
    @Status     INT           = 1
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductId,
           p.ProductName,
           p.Description,
           p.BrandId,
           b.BrandName,
           p.CategoryId,
           c.CategoryName,
           p.Status,
           p.CreatedAt,
           p.UpdatedAt,
           inv.stock                                                                 AS StockQuantity,
           inv.LastStockUpdateUTC,
           pr.PricingId,
           pr.price                                                                  AS SellingPrice,
           ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2)            AS OriginalPrice,
           pr.discountrate,
           pr.StartUTC,
           pr.EndUTC,
           (SELECT TOP 1 pi2.ImageUrl
            FROM   dbo.ProductImages pi2
            WHERE  pi2.ProductId = p.ProductId AND pi2.IsPrimary = 1)               AS PrimaryImageUrl
    FROM   dbo.ProductCatalog p
    LEFT JOIN dbo.Brand b              ON b.BrandId    = p.BrandId
    LEFT JOIN dbo.Category c           ON c.catagoryID = p.CategoryId
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.ProductId
    LEFT JOIN dbo.ProductPricing pr    ON pr.ProductId  = p.ProductId
                                      AND pr.StartUTC  <= SYSUTCDATETIME()
                                      AND (pr.EndUTC IS NULL OR pr.EndUTC >= SYSUTCDATETIME())
    WHERE  (@Status     IS NULL OR p.Status     = @Status)
      AND  (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
      AND  (@BrandId    IS NULL OR p.BrandId    = @BrandId)
      AND  (@Search     IS NULL OR p.ProductName LIKE '%' + @Search + '%')
      AND  (@MinPrice   IS NULL OR pr.price     >= @MinPrice)
      AND  (@MaxPrice   IS NULL OR pr.price     <= @MaxPrice)
    ORDER BY p.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductCatalog_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetById;
GO
CREATE PROCEDURE dbo.spProductCatalog_GetById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: product details
    SELECT p.ProductId,
           p.ProductName,
           p.Description,
           p.BrandId,
           b.BrandName,
           p.CategoryId,
           c.CategoryName,
           p.Status,
           p.CreatedAt,
           p.UpdatedAt,
           inv.stock                                                                 AS StockQuantity,
           inv.LastStockUpdateUTC,
           pr.PricingId,
           pr.price                                                                  AS SellingPrice,
           ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2)            AS OriginalPrice,
           pr.discountrate,
           pr.StartUTC,
           pr.EndUTC
    FROM   dbo.ProductCatalog p
    LEFT JOIN dbo.Brand b              ON b.BrandId    = p.BrandId
    LEFT JOIN dbo.Category c           ON c.catagoryID = p.CategoryId
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.ProductId
    LEFT JOIN dbo.ProductPricing pr    ON pr.ProductId  = p.ProductId
                                      AND pr.StartUTC  <= SYSUTCDATETIME()
                                      AND (pr.EndUTC IS NULL OR pr.EndUTC >= SYSUTCDATETIME())
    WHERE  p.ProductId = @ProductId;

    -- Result set 2: images
    SELECT ImageId, ProductId, ImageUrl, IsPrimary, SortOrder, CreatedAt
    FROM   dbo.ProductImages
    WHERE  ProductId = @ProductId
    ORDER BY IsPrimary DESC, SortOrder;

    -- Result set 3: FAQs
    SELECT FAQId, ProductId, Question, Answer, Status, CreatedAt
    FROM   dbo.ProductFAQ
    WHERE  ProductId = @ProductId AND Status = 1;

    -- Result set 4: concern types
    SELECT pc.ProductConcernId, pc.ProductId, ct.ConcernTypeId, ct.ConcernTypeName
    FROM   dbo.ProductConcerns pc
    JOIN   dbo.ConcernType ct ON ct.ConcernTypeId = pc.ConcernTypeId
    WHERE  pc.ProductId = @ProductId;

    -- Result set 5: payment options
    SELECT pp.ProductPaymentId, pp.ProductId, pt.PaymentTypeId, pt.PaymentTypeName
    FROM   dbo.ProductPaymentOptions pp
    JOIN   dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE  pp.ProductId = @ProductId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductCatalog_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Insert;
GO
CREATE PROCEDURE dbo.spProductCatalog_Insert
    @ProductName  NVARCHAR(300),
    @Description  NVARCHAR(MAX) = NULL,
    @BrandId      INT           = NULL,
    @CategoryId   INT           = NULL,
    @StockQuantity INT          = 0,
    @SellingPrice  DECIMAL(18,2),
    @OriginalPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProductId INT;
    -- discountrate = (OriginalPrice - SellingPrice) / OriginalPrice * 100
    DECLARE @DiscountRate DECIMAL(5,2) =
        CASE WHEN @OriginalPrice > 0
             THEN ROUND((@OriginalPrice - @SellingPrice) / @OriginalPrice * 100.0, 2)
             ELSE 0 END;

    INSERT INTO dbo.ProductCatalog (ProductName, Description, BrandId, CategoryId)
    VALUES (@ProductName, @Description, @BrandId, @CategoryId);
    SET @ProductId = SCOPE_IDENTITY();

    INSERT INTO dbo.ProductInventory (ProductId, stock, LastStockUpdateUTC)
    VALUES (@ProductId, @StockQuantity, SYSUTCDATETIME());

    INSERT INTO dbo.ProductPricing (ProductId, price, discountrate, StartUTC, createdate, lastupdated)
    VALUES (@ProductId, @SellingPrice, @DiscountRate, SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME());

    SELECT CAST(@ProductId AS INT) AS ProductId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductCatalog_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Update;
GO
CREATE PROCEDURE dbo.spProductCatalog_Update
    @ProductId    INT,
    @ProductName  NVARCHAR(300),
    @Description  NVARCHAR(MAX) = NULL,
    @BrandId      INT           = NULL,
    @CategoryId   INT           = NULL,
    @StockQuantity INT,
    @SellingPrice  DECIMAL(18,2),
    @OriginalPrice DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DiscountRate DECIMAL(5,2) =
        CASE WHEN @OriginalPrice > 0
             THEN ROUND((@OriginalPrice - @SellingPrice) / @OriginalPrice * 100.0, 2)
             ELSE 0 END;

    UPDATE dbo.ProductCatalog
    SET    ProductName = @ProductName,
           Description = @Description,
           BrandId     = @BrandId,
           CategoryId  = @CategoryId,
           UpdatedAt   = SYSUTCDATETIME()
    WHERE  ProductId = @ProductId;

    IF EXISTS (SELECT 1 FROM dbo.ProductInventory WHERE ProductId = @ProductId)
        UPDATE dbo.ProductInventory
        SET    stock              = @StockQuantity,
               LastStockUpdateUTC = SYSUTCDATETIME()
        WHERE  ProductId = @ProductId;
    ELSE
        INSERT INTO dbo.ProductInventory (ProductId, stock, LastStockUpdateUTC)
        VALUES (@ProductId, @StockQuantity, SYSUTCDATETIME());

    UPDATE dbo.ProductPricing
    SET    price        = @SellingPrice,
           discountrate = @DiscountRate,
           lastupdated  = SYSUTCDATETIME()
    WHERE  ProductId = @ProductId
      AND  StartUTC <= SYSUTCDATETIME()
      AND  (EndUTC IS NULL OR EndUTC >= SYSUTCDATETIME());
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductCatalog_Deactive', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Deactive;
GO
CREATE PROCEDURE dbo.spProductCatalog_Deactive
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductCatalog SET Status = 0, UpdatedAt = SYSUTCDATETIME() WHERE ProductId = @ProductId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductCatalog_Active', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Active;
GO
CREATE PROCEDURE dbo.spProductCatalog_Active
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductCatalog SET Status = 1, UpdatedAt = SYSUTCDATETIME() WHERE ProductId = @ProductId;
END
GO

-- ================================================================
-- PRODUCT IMAGE procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_ProductImage_GetByProductId', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductImage_GetByProductId;
GO
CREATE PROCEDURE dbo.sp_ProductImage_GetByProductId
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ImageId, ProductId, ImageUrl, IsPrimary, SortOrder, CreatedAt
    FROM   dbo.ProductImages
    WHERE  ProductId = @ProductId
    ORDER BY IsPrimary DESC, SortOrder;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductImage_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductImage_Insert;
GO
CREATE PROCEDURE dbo.sp_ProductImage_Insert
    @ProductId INT,
    @ImageUrl  NVARCHAR(500),
    @IsPrimary BIT = 0,
    @SortOrder INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @IsPrimary = 1
        UPDATE dbo.ProductImages SET IsPrimary = 0 WHERE ProductId = @ProductId;

    INSERT INTO dbo.ProductImages (ProductId, ImageUrl, IsPrimary, SortOrder)
    VALUES (@ProductId, @ImageUrl, @IsPrimary, @SortOrder);
    SELECT SCOPE_IDENTITY() AS ImageId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductImage_Delete', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductImage_Delete;
GO
CREATE PROCEDURE dbo.sp_ProductImage_Delete
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ProductImages WHERE ImageId = @ImageId;
END
GO

-- ================================================================
-- PRODUCT FAQ procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_CreateFAQ', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateFAQ;
GO
CREATE PROCEDURE dbo.sp_CreateFAQ
    @ProductId INT,
    @Question  NVARCHAR(500),
    @Answer    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProductFAQ (ProductId, Question, Answer)
    VALUES (@ProductId, @Question, @Answer);
    SELECT SCOPE_IDENTITY() AS FAQId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_UpdateFAQ', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateFAQ;
GO
CREATE PROCEDURE dbo.sp_UpdateFAQ
    @FAQId     INT,
    @ProductId INT,
    @Question  NVARCHAR(500),
    @Answer    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductFAQ
    SET    Question  = @Question,
           Answer    = @Answer,
           ProductId = @ProductId
    WHERE  FAQId = @FAQId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_DeactiveFAQ', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeactiveFAQ;
GO
CREATE PROCEDURE dbo.sp_DeactiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductFAQ SET Status = 0 WHERE FAQId = @FAQId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ActiveFAQ', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ActiveFAQ;
GO
CREATE PROCEDURE dbo.sp_ActiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductFAQ SET Status = 1 WHERE FAQId = @FAQId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_GetFAQById', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetFAQById;
GO
CREATE PROCEDURE dbo.sp_GetFAQById
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, ProductId, Question, Answer, Status, CreatedAt
    FROM   dbo.ProductFAQ
    WHERE  FAQId = @FAQId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_GetAllFAQ', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllFAQ;
GO
CREATE PROCEDURE dbo.sp_GetAllFAQ
    @ProductId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, ProductId, Question, Answer, Status, CreatedAt
    FROM   dbo.ProductFAQ
    WHERE  (@ProductId IS NULL OR ProductId = @ProductId)
      AND  Status = 1;
END
GO

-- ================================================================
-- PRODUCT CONCERN procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_ProductConcern_GetByProductId', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductConcern_GetByProductId;
GO
CREATE PROCEDURE dbo.sp_ProductConcern_GetByProductId
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pc.ProductConcernId, pc.ProductId, ct.ConcernTypeId, ct.ConcernTypeName
    FROM   dbo.ProductConcerns pc
    JOIN   dbo.ConcernType ct ON ct.ConcernTypeId = pc.ConcernTypeId
    WHERE  pc.ProductId = @ProductId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductConcern_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductConcern_Insert;
GO
CREATE PROCEDURE dbo.sp_ProductConcern_Insert
    @ProductId    INT,
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ProductConcerns WHERE ProductId = @ProductId AND ConcernTypeId = @ConcernTypeId)
        INSERT INTO dbo.ProductConcerns (ProductId, ConcernTypeId) VALUES (@ProductId, @ConcernTypeId);
    SELECT SCOPE_IDENTITY() AS ProductConcernId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductConcern_Delete', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductConcern_Delete;
GO
CREATE PROCEDURE dbo.sp_ProductConcern_Delete
    @ProductConcernId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ProductConcerns WHERE ProductConcernId = @ProductConcernId;
END
GO

-- ================================================================
-- PRODUCT PAYMENT OPTION procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_ProductPaymentOption_GetByProductId', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductPaymentOption_GetByProductId;
GO
CREATE PROCEDURE dbo.sp_ProductPaymentOption_GetByProductId
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pp.ProductPaymentId, pp.ProductId, pt.PaymentTypeId, pt.PaymentTypeName
    FROM   dbo.ProductPaymentOptions pp
    JOIN   dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE  pp.ProductId = @ProductId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductPaymentOption_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductPaymentOption_Insert;
GO
CREATE PROCEDURE dbo.sp_ProductPaymentOption_Insert
    @ProductId    INT,
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ProductPaymentOptions WHERE ProductId = @ProductId AND PaymentTypeId = @PaymentTypeId)
        INSERT INTO dbo.ProductPaymentOptions (ProductId, PaymentTypeId) VALUES (@ProductId, @PaymentTypeId);
    SELECT SCOPE_IDENTITY() AS ProductPaymentId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ProductPaymentOption_Delete', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_ProductPaymentOption_Delete;
GO
CREATE PROCEDURE dbo.sp_ProductPaymentOption_Delete
    @ProductPaymentId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ProductPaymentOptions WHERE ProductPaymentId = @ProductPaymentId;
END
GO

-- ================================================================
-- PRODUCT REVIEW procedures
-- ================================================================
IF OBJECT_ID('dbo.spProductReview_GetByProductId', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_GetByProductId;
GO
CREATE PROCEDURE dbo.spProductReview_GetByProductId
    @ProductId INT,
    @PageSize  INT = 20,
    @Offset    INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.ReviewId, r.ProductId, r.UserId, u.DisplayName AS UserName,
           r.Rating, r.Title, r.Body, r.Status, r.CreatedAt, r.UpdatedAt
    FROM   dbo.ProductReviews r
    JOIN   dbo.Users u ON u.Id = r.UserId
    WHERE  r.ProductId = @ProductId AND r.Status = 1
    ORDER BY r.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT AVG(CAST(Rating AS FLOAT)) AS AverageRating,
           COUNT(*)                   AS TotalReviews
    FROM   dbo.ProductReviews
    WHERE  ProductId = @ProductId AND Status = 1;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductReview_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_GetById;
GO
CREATE PROCEDURE dbo.spProductReview_GetById
    @ReviewId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.ReviewId, r.ProductId, r.UserId, u.DisplayName AS UserName,
           r.Rating, r.Title, r.Body, r.Status, r.CreatedAt, r.UpdatedAt
    FROM   dbo.ProductReviews r
    JOIN   dbo.Users u ON u.Id = r.UserId
    WHERE  r.ReviewId = @ReviewId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductReview_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_Insert;
GO
CREATE PROCEDURE dbo.spProductReview_Insert
    @ProductId INT,
    @UserId    UNIQUEIDENTIFIER,
    @Rating    INT,
    @Title     NVARCHAR(300) = NULL,
    @Body      NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProductReviews (ProductId, UserId, Rating, Title, Body)
    VALUES (@ProductId, @UserId, @Rating, @Title, @Body);
    SELECT SCOPE_IDENTITY() AS ReviewId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductReview_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_Update;
GO
CREATE PROCEDURE dbo.spProductReview_Update
    @ReviewId INT,
    @Rating   INT,
    @Title    NVARCHAR(300) = NULL,
    @Body     NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductReviews
    SET    Rating    = @Rating,
           Title     = @Title,
           Body      = @Body,
           UpdatedAt = SYSUTCDATETIME()
    WHERE  ReviewId = @ReviewId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProductReview_Deactive', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_Deactive;
GO
CREATE PROCEDURE dbo.spProductReview_Deactive
    @ReviewId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductReviews SET Status = 0, UpdatedAt = SYSUTCDATETIME() WHERE ReviewId = @ReviewId;
END
GO

-- ================================================================
-- ORDER procedures
-- ================================================================
IF OBJECT_ID('dbo.spOrder_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetAll;
GO
CREATE PROCEDURE dbo.spOrder_GetAll
    @PageSize INT,
    @Offset   INT,
    @Status   NVARCHAR(50)     = NULL,
    @UserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.UserId, u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.Status, o.TotalLkr, o.ShippingName, o.ShippingPhone, o.ShippingAddr,
           o.Notes, o.CreatedAt, o.UpdatedAt
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  (@Status IS NULL OR o.Status = @Status)
      AND  (@UserId IS NULL OR o.UserId = @UserId)
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spOrder_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetById;
GO
CREATE PROCEDURE dbo.spOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: order header
    SELECT o.Id, o.UserId, u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.Status, o.TotalLkr, o.ShippingName, o.ShippingPhone, o.ShippingAddr,
           o.Notes, o.CreatedAt, o.UpdatedAt
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  o.Id = @Id;

    -- Result set 2: order items
    SELECT oi.OrderItemId, oi.OrderId, oi.ProductId, p.ProductName,
           oi.Quantity, oi.UnitPrice,
           (oi.Quantity * oi.UnitPrice) AS LineTotal
    FROM   dbo.OrderItems oi
    JOIN   dbo.ProductCatalog p ON p.ProductId = oi.ProductId
    WHERE  oi.OrderId = @Id;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spOrder_GetByUserId', 'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetByUserId;
GO
CREATE PROCEDURE dbo.spOrder_GetByUserId
    @UserId   UNIQUEIDENTIFIER,
    @PageSize INT,
    @Offset   INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.UserId, o.Status, o.TotalLkr, o.ShippingName, o.ShippingPhone,
           o.ShippingAddr, o.Notes, o.CreatedAt, o.UpdatedAt
    FROM   dbo.Orders o
    WHERE  o.UserId = @UserId
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spOrder_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_Insert;
GO
CREATE PROCEDURE dbo.spOrder_Insert
    @UserId       UNIQUEIDENTIFIER,
    @TotalLkr     DECIMAL(18,2),
    @ShippingName NVARCHAR(200) = NULL,
    @ShippingPhone NVARCHAR(50) = NULL,
    @ShippingAddr  NVARCHAR(500) = NULL,
    @Notes         NVARCHAR(MAX) = NULL,
    @Items         NVARCHAR(MAX) = NULL   -- JSON array: [{"ProductId":1,"Quantity":2,"UnitPrice":100.00}, ...]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OrderId INT;

    INSERT INTO dbo.Orders (UserId, TotalLkr, ShippingName, ShippingPhone, ShippingAddr, Notes)
    VALUES (@UserId, @TotalLkr, @ShippingName, @ShippingPhone, @ShippingAddr, @Notes);
    SET @OrderId = SCOPE_IDENTITY();

    IF @Items IS NOT NULL
    BEGIN
        INSERT INTO dbo.OrderItems (OrderId, ProductId, Quantity, UnitPrice)
        SELECT @OrderId,
               CAST(j.ProductId  AS INT),
               CAST(j.Quantity   AS INT),
               CAST(j.UnitPrice  AS DECIMAL(18,2))
        FROM   OPENJSON(@Items)
               WITH (ProductId INT '$.ProductId', Quantity INT '$.Quantity', UnitPrice DECIMAL(18,2) '$.UnitPrice') j;
    END

    SELECT @OrderId AS Id;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spOrder_UpdateStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_UpdateStatus;
GO
CREATE PROCEDURE dbo.spOrder_UpdateStatus
    @OrderId INT,
    @Status  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Orders
    SET    Status    = @Status,
           UpdatedAt = SYSUTCDATETIME()
    WHERE  Id = @OrderId;
END
GO

-- ================================================================
-- DISPATCH procedures
-- ================================================================
IF OBJECT_ID('dbo.spDispatch_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_GetAll;
GO
CREATE PROCEDURE dbo.spDispatch_GetAll
    @PageSize INT,
    @Offset   INT,
    @Status   NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DispatchId, d.OrderId, d.CourierName, d.TrackingNumber,
           d.Status, d.DispatchedAt, d.DeliveredAt, d.Notes, d.CreatedAt, d.UpdatedAt,
           o.UserId, u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.TotalLkr, o.ShippingName, o.ShippingPhone, o.ShippingAddr
    FROM   dbo.Dispatch d
    JOIN   dbo.Orders o ON o.Id = d.OrderId
    JOIN   dbo.Users u  ON u.Id = o.UserId
    WHERE  (@Status IS NULL OR d.Status = @Status)
    ORDER BY d.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spDispatch_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_GetById;
GO
CREATE PROCEDURE dbo.spDispatch_GetById
    @DispatchId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.DispatchId, d.OrderId, d.CourierName, d.TrackingNumber,
           d.Status, d.DispatchedAt, d.DeliveredAt, d.Notes, d.CreatedAt, d.UpdatedAt,
           o.UserId, u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.TotalLkr, o.ShippingName, o.ShippingPhone, o.ShippingAddr
    FROM   dbo.Dispatch d
    JOIN   dbo.Orders o ON o.Id = d.OrderId
    JOIN   dbo.Users u  ON u.Id = o.UserId
    WHERE  d.DispatchId = @DispatchId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spDispatch_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_Insert;
GO
CREATE PROCEDURE dbo.spDispatch_Insert
    @OrderId       INT,
    @CourierName   NVARCHAR(200) = NULL,
    @TrackingNumber NVARCHAR(200) = NULL,
    @Notes         NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Dispatch (OrderId, CourierName, TrackingNumber, Notes)
    VALUES (@OrderId, @CourierName, @TrackingNumber, @Notes);
    SELECT SCOPE_IDENTITY() AS DispatchId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spDispatch_Update', 'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_Update;
GO
CREATE PROCEDURE dbo.spDispatch_Update
    @DispatchId    INT,
    @CourierName   NVARCHAR(200) = NULL,
    @TrackingNumber NVARCHAR(200) = NULL,
    @Notes         NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Dispatch
    SET    CourierName    = @CourierName,
           TrackingNumber = @TrackingNumber,
           Notes          = @Notes,
           UpdatedAt      = SYSUTCDATETIME()
    WHERE  DispatchId = @DispatchId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spDispatch_UpdateStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_UpdateStatus;
GO
CREATE PROCEDURE dbo.spDispatch_UpdateStatus
    @DispatchId  INT,
    @Status      NVARCHAR(50),
    @DispatchedAt DATETIME2 = NULL,
    @DeliveredAt  DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Dispatch
    SET    Status       = @Status,
           DispatchedAt = COALESCE(@DispatchedAt, DispatchedAt),
           DeliveredAt  = COALESCE(@DeliveredAt, DeliveredAt),
           UpdatedAt    = SYSUTCDATETIME()
    WHERE  DispatchId = @DispatchId;
END
GO

-- ================================================================
-- PROCUREMENT procedures
-- ================================================================
IF OBJECT_ID('dbo.spProcurementOrder_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_GetAll;
GO
CREATE PROCEDURE dbo.spProcurementOrder_GetAll
    @PageSize INT,
    @Offset   INT,
    @Status   NVARCHAR(50)     = NULL,
    @OrderedBy UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ProcurementId, po.SupplierName, po.SupplierContact, po.Status,
           po.TotalCost, po.OrderedBy, u.DisplayName AS OrderedByName,
           po.OrderedAt, po.ReceivedAt, po.Notes
    FROM   dbo.ProcurementOrders po
    JOIN   dbo.Users u ON u.Id = po.OrderedBy
    WHERE  (@Status    IS NULL OR po.Status    = @Status)
      AND  (@OrderedBy IS NULL OR po.OrderedBy = @OrderedBy)
    ORDER BY po.OrderedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProcurementOrder_GetById', 'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_GetById;
GO
CREATE PROCEDURE dbo.spProcurementOrder_GetById
    @ProcurementId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: order header
    SELECT po.ProcurementId, po.SupplierName, po.SupplierContact, po.Status,
           po.TotalCost, po.OrderedBy, u.DisplayName AS OrderedByName,
           po.OrderedAt, po.ReceivedAt, po.Notes
    FROM   dbo.ProcurementOrders po
    JOIN   dbo.Users u ON u.Id = po.OrderedBy
    WHERE  po.ProcurementId = @ProcurementId;

    -- Result set 2: items
    SELECT pi2.ProcurementItemId, pi2.ProcurementId, pi2.ProductId, pc.ProductName,
           pi2.Quantity, pi2.UnitCost, (pi2.Quantity * pi2.UnitCost) AS LineTotal
    FROM   dbo.ProcurementItems pi2
    JOIN   dbo.ProductCatalog pc ON pc.ProductId = pi2.ProductId
    WHERE  pi2.ProcurementId = @ProcurementId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProcurementOrder_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_Insert;
GO
CREATE PROCEDURE dbo.spProcurementOrder_Insert
    @SupplierName    NVARCHAR(300),
    @SupplierContact NVARCHAR(500) = NULL,
    @OrderedBy       UNIQUEIDENTIFIER,
    @Notes           NVARCHAR(MAX) = NULL,
    @Items           NVARCHAR(MAX) = NULL  -- JSON: [{"ProductId":1,"Quantity":5,"UnitCost":200.00}, ...]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProcurementId INT;
    DECLARE @TotalCost DECIMAL(18,2) = 0;

    INSERT INTO dbo.ProcurementOrders (SupplierName, SupplierContact, OrderedBy, Notes)
    VALUES (@SupplierName, @SupplierContact, @OrderedBy, @Notes);
    SET @ProcurementId = SCOPE_IDENTITY();

    IF @Items IS NOT NULL
    BEGIN
        INSERT INTO dbo.ProcurementItems (ProcurementId, ProductId, Quantity, UnitCost)
        SELECT @ProcurementId,
               CAST(j.ProductId AS INT),
               CAST(j.Quantity  AS INT),
               CAST(j.UnitCost  AS DECIMAL(18,2))
        FROM   OPENJSON(@Items)
               WITH (ProductId INT '$.ProductId', Quantity INT '$.Quantity', UnitCost DECIMAL(18,2) '$.UnitCost') j;

        SELECT @TotalCost = SUM(Quantity * UnitCost)
        FROM   dbo.ProcurementItems
        WHERE  ProcurementId = @ProcurementId;

        UPDATE dbo.ProcurementOrders SET TotalCost = @TotalCost WHERE ProcurementId = @ProcurementId;
    END

    SELECT @ProcurementId AS ProcurementId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spProcurementOrder_UpdateStatus', 'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_UpdateStatus;
GO
CREATE PROCEDURE dbo.spProcurementOrder_UpdateStatus
    @ProcurementId INT,
    @Status        NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProcurementOrders
    SET    Status     = @Status,
           ReceivedAt = CASE WHEN @Status = 'Received' THEN SYSUTCDATETIME() ELSE ReceivedAt END
    WHERE  ProcurementId = @ProcurementId;

    -- When received: bump stock for all items
    IF @Status = 'Received'
    BEGIN
        UPDATE inv
        SET    inv.stock              = inv.stock + pi2.Quantity,
               inv.LastStockUpdateUTC = SYSUTCDATETIME()
        FROM   dbo.ProductInventory inv
        JOIN   dbo.ProcurementItems pi2 ON pi2.ProductId = inv.ProductId
        WHERE  pi2.ProcurementId = @ProcurementId;
    END
END
GO

-- ================================================================
-- AUDIT LOG procedures
-- ================================================================
IF OBJECT_ID('dbo.sp_AuditLog_Insert', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AuditLog_Insert;
GO
CREATE PROCEDURE dbo.sp_AuditLog_Insert
    @AdminUserId UNIQUEIDENTIFIER,
    @Action      NVARCHAR(200),
    @EntityName  NVARCHAR(200) = NULL,
    @EntityId    NVARCHAR(100) = NULL,
    @OldValues   NVARCHAR(MAX) = NULL,
    @NewValues   NVARCHAR(MAX) = NULL,
    @IpAddress   NVARCHAR(50)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.AdminAuditLog (AdminUserId, Action, EntityName, EntityId, OldValues, NewValues, IpAddress)
    VALUES (@AdminUserId, @Action, @EntityName, @EntityId, @OldValues, @NewValues, @IpAddress);
    SELECT SCOPE_IDENTITY() AS AuditId;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_AuditLog_GetAll', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_AuditLog_GetAll;
GO
CREATE PROCEDURE dbo.sp_AuditLog_GetAll
    @PageSize    INT,
    @Offset      INT,
    @AdminUserId UNIQUEIDENTIFIER = NULL,
    @Action      NVARCHAR(200)    = NULL,
    @EntityName  NVARCHAR(200)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.AuditId, a.AdminUserId, u.DisplayName AS AdminName,
           a.Action, a.EntityName, a.EntityId, a.OldValues, a.NewValues, a.IpAddress, a.CreatedAt
    FROM   dbo.AdminAuditLog a
    JOIN   dbo.Users u ON u.Id = a.AdminUserId
    WHERE  (@AdminUserId IS NULL OR a.AdminUserId = @AdminUserId)
      AND  (@Action      IS NULL OR a.Action      LIKE '%' + @Action + '%')
      AND  (@EntityName  IS NULL OR a.EntityName  = @EntityName)
    ORDER BY a.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ================================================================
-- DASHBOARD procedures
-- ================================================================
IF OBJECT_ID('dbo.spDashboard_GetStats', 'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetStats;
GO
CREATE PROCEDURE dbo.spDashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*)        FROM dbo.Orders  WHERE CreatedAt >= CAST(GETUTCDATE() AS DATE)) AS TodayOrders,
        (SELECT COALESCE(SUM(TotalLkr), 0) FROM dbo.Orders WHERE CreatedAt >= CAST(GETUTCDATE() AS DATE)) AS TodayRevenue,
        (SELECT COUNT(*)        FROM dbo.Orders  WHERE Status = 'Pending')    AS PendingOrders,
        (SELECT COUNT(*)        FROM dbo.Orders  WHERE Status = 'Processing') AS ProcessingOrders,
        (SELECT COUNT(*)        FROM dbo.Orders  WHERE Status = 'Shipped')    AS ShippedOrders,
        (SELECT COUNT(*)        FROM dbo.Orders  WHERE Status = 'Delivered')  AS DeliveredOrders,
        (SELECT COUNT(*)        FROM dbo.Users   WHERE CAST(CreatedAt AS DATE) = CAST(GETUTCDATE() AS DATE)) AS NewCustomersToday,
        (SELECT COUNT(*)        FROM dbo.Users)                               AS TotalCustomers,
        (SELECT COUNT(*)        FROM dbo.ProductCatalog WHERE Status = 1)     AS ActiveProducts,
        (SELECT COUNT(*)        FROM dbo.ProductInventory WHERE stock = 0)    AS OutOfStockProducts,
        (SELECT COALESCE(SUM(TotalLkr), 0) FROM dbo.Orders
         WHERE  CreatedAt >= DATEADD(DAY, -30, GETUTCDATE()))                  AS Last30DaysRevenue;
END
GO

-- ================================================================
-- REPORT procedures
-- ================================================================
IF OBJECT_ID('dbo.spReport_GetSalesSummary', 'P') IS NOT NULL DROP PROCEDURE dbo.spReport_GetSalesSummary;
GO
CREATE PROCEDURE dbo.spReport_GetSalesSummary
    @StartDate DATETIME2,
    @EndDate   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(o.CreatedAt AS DATE) AS SaleDate,
           COUNT(*)                  AS OrderCount,
           SUM(o.TotalLkr)           AS TotalRevenue,
           AVG(o.TotalLkr)           AS AverageOrderValue
    FROM   dbo.Orders o
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('Cancelled', 'Refunded')
    GROUP BY CAST(o.CreatedAt AS DATE)
    ORDER BY SaleDate;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spReport_GetTopProducts', 'P') IS NOT NULL DROP PROCEDURE dbo.spReport_GetTopProducts;
GO
CREATE PROCEDURE dbo.spReport_GetTopProducts
    @StartDate DATETIME2,
    @EndDate   DATETIME2,
    @TopN      INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@TopN)
           oi.ProductId,
           pc.ProductName,
           SUM(oi.Quantity)              AS TotalUnitsSold,
           SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM   dbo.OrderItems oi
    JOIN   dbo.Orders o          ON o.Id        = oi.OrderId
    JOIN   dbo.ProductCatalog pc ON pc.ProductId = oi.ProductId
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('Cancelled', 'Refunded')
    GROUP BY oi.ProductId, pc.ProductName
    ORDER BY TotalRevenue DESC;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spReport_GetInventoryAlerts', 'P') IS NOT NULL DROP PROCEDURE dbo.spReport_GetInventoryAlerts;
GO
CREATE PROCEDURE dbo.spReport_GetInventoryAlerts
    @LowStockThreshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProductId, p.ProductName, b.BrandName, c.CategoryName,
           inv.stock AS StockQuantity,
           inv.LastStockUpdateUTC,
           CASE WHEN inv.stock = 0 THEN 'OutOfStock'
                WHEN inv.stock <= @LowStockThreshold THEN 'LowStock'
                ELSE 'OK' END AS StockStatus
    FROM   dbo.ProductCatalog p
    LEFT JOIN dbo.Brand b              ON b.BrandId    = p.BrandId
    LEFT JOIN dbo.Category c           ON c.catagoryID = p.CategoryId
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.ProductId
    WHERE  p.Status = 1
      AND  (inv.stock IS NULL OR inv.stock <= @LowStockThreshold)
    ORDER BY inv.stock;
END
GO

-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.spReport_GetCategoryBreakdown', 'P') IS NOT NULL DROP PROCEDURE dbo.spReport_GetCategoryBreakdown;
GO
CREATE PROCEDURE dbo.spReport_GetCategoryBreakdown
    @StartDate DATETIME2,
    @EndDate   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.catagoryID AS CategoryId,
           c.CategoryName,
           COUNT(DISTINCT o.Id)                      AS OrderCount,
           SUM(oi.Quantity)                           AS UnitsSold,
           SUM(oi.Quantity * oi.UnitPrice)            AS Revenue
    FROM   dbo.Category c
    JOIN   dbo.ProductCatalog pc ON pc.CategoryId = c.catagoryID
    JOIN   dbo.OrderItems oi     ON oi.ProductId  = pc.ProductId
    JOIN   dbo.Orders o          ON o.Id          = oi.OrderId
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('Cancelled', 'Refunded')
    GROUP BY c.catagoryID, c.CategoryName
    ORDER BY Revenue DESC;
END
GO

-- ================================================================
-- REFERENCE DATA (seed only if empty)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM dbo.PaymentType)
BEGIN
    INSERT INTO dbo.PaymentType (PaymentTypeName, Description)
    VALUES
        ('Cash on Delivery',  'Pay when the order is delivered'),
        ('Bank Transfer',     'Direct bank transfer'),
        ('Card Payment',      'Credit or debit card'),
        ('Online Payment',    'Online payment gateway');
    PRINT 'Seeded dbo.PaymentType';
END
GO

-- ================================================================
-- END OF SCHEMA
-- ================================================================
PRINT 'TenzyShop schema applied successfully.';
GO
