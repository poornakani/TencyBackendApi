-- ================================================================
-- TenzyShop — COMPLETE DATABASE SCHEMA
-- All tables (normalized, 3NF) + all stored procedures
-- Run on a clean SQL Server database named: tenzyuk_production
-- Idempotent: safe to run multiple times (IF NOT EXISTS guards)
-- ================================================================
-- TABLE CREATION ORDER (parent → child, respects all FKs):
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

-- ================================================================
-- 1. USERS
--    Core identity table — one row per registered account
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        Id            UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
        Email         NVARCHAR(256)    NOT NULL,
        EmailVerified BIT              NOT NULL DEFAULT 0,
        DisplayName   NVARCHAR(200)    NOT NULL,
        Status        INT              NOT NULL DEFAULT 1,  -- 1=Active, 0=Deactivated
        CreatedAt     DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        LastLoginAt   DATETIME2        NULL
    );
    CREATE UNIQUE INDEX UX_Users_Email ON Users(Email);
    PRINT 'Created table: Users';
END
GO

-- ================================================================
-- 2. USER ROLES
--    Maps users to roles: 1=Admin, 2=Customer
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserRoles')
BEGIN
    CREATE TABLE UserRoles (
        UserId     UNIQUEIDENTIFIER NOT NULL,
        RoleId     INT              NOT NULL,  -- 1=Admin, 2=Customer
        AssignedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_UserRoles PRIMARY KEY (UserId, RoleId),
        CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    CREATE INDEX IX_UserRoles_UserId ON UserRoles(UserId);
    PRINT 'Created table: UserRoles';
END
GO

-- ================================================================
-- 3. PASSWORD CREDENTIALS
--    One row per user — hashed password + brute-force lock state
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordCredentials')
BEGIN
    CREATE TABLE PasswordCredentials (
        UserId            UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
        PasswordHash      NVARCHAR(512)    NOT NULL,
        PasswordUpdatedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        FailedAttempts    INT              NOT NULL DEFAULT 0,
        LockedUntil       DATETIME2        NULL,
        CONSTRAINT FK_PasswordCredentials_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    PRINT 'Created table: PasswordCredentials';
END
GO

-- ================================================================
-- 4. REFRESH SESSIONS
--    One row per active refresh token (rotated on each login)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RefreshSessions')
BEGIN
    CREATE TABLE RefreshSessions (
        Id               INT              IDENTITY(1,1) PRIMARY KEY,
        UserId           UNIQUEIDENTIFIER NOT NULL,
        RefreshTokenHash NVARCHAR(512)    NOT NULL,
        ExpiresAt        DATETIME2        NOT NULL,
        CreatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_RefreshSessions_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    CREATE INDEX IX_RefreshSessions_UserId ON RefreshSessions(UserId);
    PRINT 'Created table: RefreshSessions';
END
GO

-- ================================================================
-- 5. PASSWORD RESET TOKENS
--    One-time tokens for forgot-password flow (expire in 1 hour)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PasswordResetTokens')
BEGIN
    CREATE TABLE PasswordResetTokens (
        Id        INT              IDENTITY(1,1) PRIMARY KEY,
        UserId    UNIQUEIDENTIFIER NOT NULL,
        TokenHash NVARCHAR(512)    NOT NULL,
        ExpiresAt DATETIME2        NOT NULL,
        UsedAt    DATETIME2        NULL,
        CreatedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_PasswordResetTokens_Users FOREIGN KEY (UserId) REFERENCES Users(Id)
    );
    CREATE INDEX IX_PasswordResetTokens_TokenHash ON PasswordResetTokens(TokenHash);
    CREATE INDEX IX_PasswordResetTokens_UserId    ON PasswordResetTokens(UserId);
    PRINT 'Created table: PasswordResetTokens';
END
GO

-- ================================================================
-- 6. BRAND
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Brand')
BEGIN
    CREATE TABLE Brand (
        BrandId    INT           IDENTITY(1,1) PRIMARY KEY,
        name       NVARCHAR(200) NOT NULL,
        barndimage NVARCHAR(500) NULL,          -- URL to brand logo (typo kept for compatibility)
        createdate DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        lastupdated DATETIME2    NULL,
        Isactive   BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Created table: Brand';
END
GO

-- ================================================================
-- 7. CATEGORY
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Category')
BEGIN
    CREATE TABLE Category (
        CategoryId   INT           IDENTITY(1,1) PRIMARY KEY,
        categorytype NVARCHAR(100) NOT NULL,
        Isactive     BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Created table: Category';
END
GO

-- ================================================================
-- 8. CONCERN TYPE (skin/hair concerns for product tagging)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ConcernType')
BEGIN
    CREATE TABLE ConcernType (
        ConcernTypeId INT           IDENTITY(1,1) PRIMARY KEY,
        ConcernType   NVARCHAR(200) NOT NULL,
        description   NVARCHAR(500) NULL,
        IsActive      BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Created table: ConcernType';
END
GO

-- ================================================================
-- 9. PAYMENT TYPE (e.g. CocoPay, Card, Bank)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PaymentType')
BEGIN
    CREATE TABLE PaymentType (
        PaymentTypeId INT           IDENTITY(1,1) PRIMARY KEY,
        PaymentType   NVARCHAR(100) NOT NULL,
        IsActive      BIT           NOT NULL DEFAULT 1
    );
    PRINT 'Created table: PaymentType';
END
GO

-- ================================================================
-- 10. PRODUCT CATALOG
--     Core product master record
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductCatalog')
BEGIN
    CREATE TABLE ProductCatalog (
        productid   INT            IDENTITY(1,1) PRIMARY KEY,
        name        NVARCHAR(200)  NOT NULL,
        brandid     INT            NOT NULL,
        categoryid  INT            NOT NULL,
        description NVARCHAR(MAX)  NULL,
        weight      DECIMAL(18,3)  NULL,
        insale      BIT            NOT NULL DEFAULT 1,
        createdate  DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        lastupdated DATETIME2      NULL,
        CONSTRAINT FK_ProductCatalog_Brand    FOREIGN KEY (brandid)    REFERENCES Brand(BrandId),
        CONSTRAINT FK_ProductCatalog_Category FOREIGN KEY (categoryid) REFERENCES Category(CategoryId)
    );
    CREATE INDEX IX_ProductCatalog_BrandId    ON ProductCatalog(brandid);
    CREATE INDEX IX_ProductCatalog_CategoryId ON ProductCatalog(categoryid);
    CREATE INDEX IX_ProductCatalog_InSale     ON ProductCatalog(insale);
    PRINT 'Created table: ProductCatalog';
END
GO

-- ================================================================
-- 11. PRODUCT INVENTORY
--     One row per product — current stock level
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductInventory')
BEGIN
    CREATE TABLE ProductInventory (
        productid     INT       NOT NULL PRIMARY KEY,
        StockQuantity INT       NOT NULL DEFAULT 0,
        LastUpdated   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductInventory_ProductCatalog FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid)
    );
    PRINT 'Created table: ProductInventory';
END
GO

-- ================================================================
-- 12. PRODUCT PRICING
--     One row per product — current selling and original price
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductPricing')
BEGIN
    CREATE TABLE ProductPricing (
        productid     INT           NOT NULL PRIMARY KEY,
        SellingPrice  DECIMAL(18,2) NOT NULL DEFAULT 0,
        OriginalPrice DECIMAL(18,2) NOT NULL DEFAULT 0,
        CONSTRAINT FK_ProductPricing_ProductCatalog FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid)
    );
    PRINT 'Created table: ProductPricing';
END
GO

-- ================================================================
-- 13. PRODUCT IMAGES
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductImages')
BEGIN
    CREATE TABLE ProductImages (
        ImageId    INT           IDENTITY(1,1) PRIMARY KEY,
        productid  INT           NOT NULL,
        ImageUrl   NVARCHAR(500) NOT NULL,
        IsPrimary  BIT           NOT NULL DEFAULT 0,
        SortOrder  INT           NOT NULL DEFAULT 0,
        createdate DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
        IsActive   BIT           NOT NULL DEFAULT 1,
        CONSTRAINT FK_ProductImages_ProductCatalog FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_ProductImages_ProductId ON ProductImages(productid);
    PRINT 'Created table: ProductImages';
END
GO

-- ================================================================
-- 14. PRODUCT FAQ
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductFAQ')
BEGIN
    CREATE TABLE ProductFAQ (
        FAQId      INT            IDENTITY(1,1) PRIMARY KEY,
        productid  INT            NOT NULL,
        Question   NVARCHAR(1000) NOT NULL,
        Answer     NVARCHAR(MAX)  NOT NULL,
        createdUTC DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
        IsActive   BIT            NOT NULL DEFAULT 1,
        CONSTRAINT FK_ProductFAQ_ProductCatalog FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_ProductFAQ_ProductId ON ProductFAQ(productid);
    PRINT 'Created table: ProductFAQ';
END
GO

-- ================================================================
-- 15. PRODUCT CONCERNS  (junction: product ↔ concern type)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductConcerns')
BEGIN
    CREATE TABLE ProductConcerns (
        productid  INT NOT NULL,
        ConcernId  INT NOT NULL,
        CONSTRAINT PK_ProductConcerns PRIMARY KEY (productid, ConcernId),
        CONSTRAINT FK_ProductConcerns_Product FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid) ON DELETE CASCADE,
        CONSTRAINT FK_ProductConcerns_Concern FOREIGN KEY (ConcernId)
            REFERENCES ConcernType(ConcernTypeId)
    );
    PRINT 'Created table: ProductConcerns';
END
GO

-- ================================================================
-- 16. PRODUCT PAYMENT OPTIONS  (junction: product ↔ payment type)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductPaymentOptions')
BEGIN
    CREATE TABLE ProductPaymentOptions (
        productid     INT NOT NULL,
        PaymentTypeId INT NOT NULL,
        instalment    INT NULL,   -- number of instalments if applicable
        CONSTRAINT PK_ProductPaymentOptions PRIMARY KEY (productid, PaymentTypeId),
        CONSTRAINT FK_ProductPaymentOptions_Product FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid) ON DELETE CASCADE,
        CONSTRAINT FK_ProductPaymentOptions_PayType FOREIGN KEY (PaymentTypeId)
            REFERENCES PaymentType(PaymentTypeId)
    );
    PRINT 'Created table: ProductPaymentOptions';
END
GO

-- ================================================================
-- 17. PRODUCT REVIEWS
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductReviews')
BEGIN
    CREATE TABLE ProductReviews (
        Id                  INT              IDENTITY(1,1) PRIMARY KEY,
        productid           INT              NOT NULL,
        UserId              UNIQUEIDENTIFIER NOT NULL,
        Rate                TINYINT          NOT NULL,      -- 1–5
        Comment             NVARCHAR(2000)   NULL,
        IsVerifiedPurchase  BIT              NOT NULL DEFAULT 0,
        IsApproved          BIT              NOT NULL DEFAULT 0,
        CreatedAt           DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_ProductReviews_Product FOREIGN KEY (productid)
            REFERENCES ProductCatalog(productid),
        CONSTRAINT FK_ProductReviews_Users FOREIGN KEY (UserId)
            REFERENCES Users(Id),
        CONSTRAINT CK_ProductReviews_Rate CHECK (Rate BETWEEN 1 AND 5),
        CONSTRAINT UQ_ProductReviews_User_Product UNIQUE (UserId, productid)
    );
    CREATE INDEX IX_ProductReviews_ProductId ON ProductReviews(productid);
    CREATE INDEX IX_ProductReviews_UserId    ON ProductReviews(UserId);
    CREATE INDEX IX_ProductReviews_Approved  ON ProductReviews(IsApproved);
    PRINT 'Created table: ProductReviews';
END
ELSE
BEGIN
    -- Add missing columns if the table already exists without them
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ProductReviews') AND name = 'IsVerifiedPurchase')
        ALTER TABLE ProductReviews ADD IsVerifiedPurchase BIT NOT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ProductReviews') AND name = 'IsApproved')
        ALTER TABLE ProductReviews ADD IsApproved BIT NOT NULL DEFAULT 0;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('ProductReviews') AND name = 'CreatedAt')
        ALTER TABLE ProductReviews ADD CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME();
    PRINT 'Verified/updated table: ProductReviews';
END
GO

-- ================================================================
-- 18. ADMIN AUDIT LOG
--     Auto-logged by AdminAuditMiddleware for every admin mutation
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AdminAuditLog')
BEGIN
    CREATE TABLE AdminAuditLog (
        Id          BIGINT           IDENTITY(1,1) PRIMARY KEY,
        AdminUserId UNIQUEIDENTIFIER NOT NULL,
        Action      NVARCHAR(100)    NOT NULL,   -- e.g. "Product.Update"
        EntityType  NVARCHAR(100)    NULL,
        EntityId    NVARCHAR(100)    NULL,
        OldValues   NVARCHAR(MAX)    NULL,        -- JSON snapshot before
        NewValues   NVARCHAR(MAX)    NULL,        -- JSON snapshot after
        IpAddress   NVARCHAR(50)     NULL,
        UserAgent   NVARCHAR(500)    NULL,
        CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_AdminAuditLog_Users FOREIGN KEY (AdminUserId)
            REFERENCES Users(Id)
    );
    CREATE INDEX IX_AdminAuditLog_AdminUserId ON AdminAuditLog(AdminUserId);
    CREATE INDEX IX_AdminAuditLog_CreatedAt   ON AdminAuditLog(CreatedAt DESC);
    PRINT 'Created table: AdminAuditLog';
END
GO

-- ================================================================
-- 19. USER LOGIN HISTORY
--     All login attempts (success and failure) for security audit
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UserLoginHistory')
BEGIN
    CREATE TABLE UserLoginHistory (
        Id          BIGINT           IDENTITY(1,1) PRIMARY KEY,
        UserId      UNIQUEIDENTIFIER NULL,        -- NULL when email not found
        Email       NVARCHAR(256)    NOT NULL,
        IsSuccess   BIT              NOT NULL DEFAULT 0,
        FailReason  NVARCHAR(200)    NULL,        -- "InvalidPassword"|"AccountLocked"|"EmailNotFound"
        IpAddress   NVARCHAR(50)     NULL,
        UserAgent   NVARCHAR(500)    NULL,
        AttemptedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_UserLoginHistory_Email       ON UserLoginHistory(Email);
    CREATE INDEX IX_UserLoginHistory_UserId      ON UserLoginHistory(UserId);
    CREATE INDEX IX_UserLoginHistory_AttemptedAt ON UserLoginHistory(AttemptedAt DESC);
    PRINT 'Created table: UserLoginHistory';
END
GO

-- ================================================================
-- 20. PROCUREMENT ORDERS
--     International stock purchase orders (GBP-priced, rate-locked)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementOrders')
BEGIN
    CREATE TABLE ProcurementOrders (
        Id               INT              IDENTITY(1,1) PRIMARY KEY,
        OrderReference   NVARCHAR(50)     NOT NULL,
        SupplierName     NVARCHAR(200)    NOT NULL,
        OrderDate        DATE             NOT NULL,
        GbpToLkr         DECIMAL(12,4)    NOT NULL,    -- exchange rate locked at entry
        CourierCharges   DECIMAL(18,2)    NOT NULL DEFAULT 0,
        CustomsDuty      DECIMAL(18,2)    NOT NULL DEFAULT 0,
        OtherCharges     DECIMAL(18,2)    NOT NULL DEFAULT 0,
        Notes            NVARCHAR(1000)   NULL,
        Status           NVARCHAR(20)     NOT NULL DEFAULT 'ordered',
            -- ordered | in_transit | arrived | approved
        CreatedByUserId  UNIQUEIDENTIFIER NOT NULL,
        ApprovedByUserId UNIQUEIDENTIFIER NULL,
        ApprovedAt       DATETIME2        NULL,
        CreatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt        DATETIME2        NULL,
        CONSTRAINT FK_ProcurementOrders_CreatedBy  FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id),
        CONSTRAINT FK_ProcurementOrders_ApprovedBy FOREIGN KEY (ApprovedByUserId)
            REFERENCES Users(Id),
        CONSTRAINT CK_ProcurementOrders_Status CHECK (
            Status IN ('ordered','in_transit','arrived','approved'))
    );
    CREATE INDEX IX_ProcurementOrders_Status    ON ProcurementOrders(Status);
    CREATE INDEX IX_ProcurementOrders_CreatedAt ON ProcurementOrders(CreatedAt DESC);
    PRINT 'Created table: ProcurementOrders';
END
GO

-- ================================================================
-- 21. PROCUREMENT ITEMS
--     Line items within a procurement order
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProcurementItems')
BEGIN
    CREATE TABLE ProcurementItems (
        Id                 INT           IDENTITY(1,1) PRIMARY KEY,
        ProcurementOrderId INT           NOT NULL,
        ProductId          INT           NULL,         -- NULL if product not yet in catalog
        ProductName        NVARCHAR(200) NOT NULL,     -- snapshot name at time of order
        Quantity           INT           NOT NULL,
        UnitPriceGbp       DECIMAL(18,4) NOT NULL,
        CONSTRAINT FK_ProcurementItems_Order FOREIGN KEY (ProcurementOrderId)
            REFERENCES ProcurementOrders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_ProcurementItems_Product FOREIGN KEY (ProductId)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_ProcurementItems_OrderId ON ProcurementItems(ProcurementOrderId);
    PRINT 'Created table: ProcurementItems';
END
GO

-- ================================================================
-- 22. ORDERS
--     Customer purchase orders
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Orders')
BEGIN
    CREATE TABLE Orders (
        Id              INT              IDENTITY(1,1) PRIMARY KEY,
        OrderRef        NVARCHAR(30)     NOT NULL,   -- e.g. "ORD-20250001"
        UserId          UNIQUEIDENTIFIER NOT NULL,
        Status          NVARCHAR(20)     NOT NULL DEFAULT 'pending',
            -- pending | processing | dispatched | delivered | cancelled
        PaymentMethod   NVARCHAR(50)     NOT NULL,
        PaymentStatus   NVARCHAR(20)     NOT NULL DEFAULT 'pending',
            -- pending | paid | failed
        ShippingName    NVARCHAR(200)    NOT NULL,
        ShippingPhone   NVARCHAR(30)     NOT NULL,
        ShippingAddress NVARCHAR(500)    NOT NULL,
        ShippingCity    NVARCHAR(100)    NOT NULL,
        SubtotalLkr     DECIMAL(18,2)   NOT NULL,
        ShippingFee     DECIMAL(18,2)   NOT NULL DEFAULT 0,
        DiscountLkr     DECIMAL(18,2)   NOT NULL DEFAULT 0,
        TotalLkr        DECIMAL(18,2)   NOT NULL,
        Notes           NVARCHAR(1000)  NULL,
        CreatedAt       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
        UpdatedAt       DATETIME2       NULL,
        CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
        CONSTRAINT CK_Orders_Status CHECK (
            Status IN ('pending','processing','dispatched','delivered','cancelled')),
        CONSTRAINT CK_Orders_PayStatus CHECK (
            PaymentStatus IN ('pending','paid','failed'))
    );
    CREATE UNIQUE INDEX UX_Orders_OrderRef  ON Orders(OrderRef);
    CREATE        INDEX IX_Orders_UserId    ON Orders(UserId);
    CREATE        INDEX IX_Orders_Status    ON Orders(Status);
    CREATE        INDEX IX_Orders_CreatedAt ON Orders(CreatedAt DESC);
    PRINT 'Created table: Orders';
END
GO

-- ================================================================
-- 23. ORDER ITEMS
--     Line items within a customer order (price snapshot)
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'OrderItems')
BEGIN
    CREATE TABLE OrderItems (
        Id          INT           IDENTITY(1,1) PRIMARY KEY,
        OrderId     INT           NOT NULL,
        ProductId   INT           NOT NULL,
        ProductName NVARCHAR(200) NOT NULL,   -- snapshot at time of purchase
        Qty         INT           NOT NULL,
        UnitPrice   DECIMAL(18,2) NOT NULL,   -- snapshot price at time of purchase
        LineTotal   DECIMAL(18,2) NOT NULL,   -- UnitPrice * Qty
        CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId)
            REFERENCES Orders(Id) ON DELETE CASCADE,
        CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductId)
            REFERENCES ProductCatalog(productid)
    );
    CREATE INDEX IX_OrderItems_OrderId   ON OrderItems(OrderId);
    CREATE INDEX IX_OrderItems_ProductId ON OrderItems(ProductId);
    PRINT 'Created table: OrderItems';
END
GO

-- ================================================================
-- 24. DISPATCH
--     Courier tracking info added when an order ships
-- ================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Dispatch')
BEGIN
    CREATE TABLE Dispatch (
        Id                INT              IDENTITY(1,1) PRIMARY KEY,
        OrderId           INT              NOT NULL,
        TrackingId        NVARCHAR(100)    NULL,
        Courier           NVARCHAR(100)    NULL,
        DispatchedAt      DATETIME2        NULL,
        EstimatedDelivery DATE             NULL,
        DeliveredAt       DATETIME2        NULL,
        Notes             NVARCHAR(500)    NULL,
        CreatedByUserId   UNIQUEIDENTIFIER NOT NULL,
        UpdatedAt         DATETIME2        NULL,
        CONSTRAINT FK_Dispatch_Orders FOREIGN KEY (OrderId)
            REFERENCES Orders(Id),
        CONSTRAINT FK_Dispatch_Users FOREIGN KEY (CreatedByUserId)
            REFERENCES Users(Id),
        CONSTRAINT UQ_Dispatch_OrderId UNIQUE (OrderId)  -- one dispatch record per order
    );
    CREATE INDEX IX_Dispatch_OrderId ON Dispatch(OrderId);
    PRINT 'Created table: Dispatch';
END
GO

-- ================================================================
-- END OF TABLE DEFINITIONS
-- ================================================================
PRINT '== All tables verified/created ==';
GO

-- ================================================================
-- STORED PROCEDURES
-- ================================================================
-- All SPs use: IF EXISTS DROP + CREATE (idempotent)
-- ================================================================


-- ================================================================
-- AUTH / USER MANAGEMENT
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUser_Insert')
    DROP PROCEDURE spUser_Insert;
GO
CREATE PROCEDURE spUser_Insert
    @Email         NVARCHAR(256),
    @EmailVerified BIT,
    @DisplayName   NVARCHAR(200),
    @Status        INT,
    @CreatedAt     DATETIME2,
    @LastLoginAt   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Users (Id, Email, EmailVerified, DisplayName, Status, CreatedAt, LastLoginAt)
    VALUES (NEWSEQUENTIALID(), @Email, @EmailVerified, @DisplayName, @Status, @CreatedAt, @LastLoginAt);
    SELECT CAST(SCOPE_IDENTITY() AS UNIQUEIDENTIFIER);
    -- Note: since Id is UNIQUEIDENTIFIER with DEFAULT, use OUTPUT instead for real GUID:
    DECLARE @NewId UNIQUEIDENTIFIER;
    SELECT TOP 1 @NewId = Id FROM Users WHERE Email = @Email;
    SELECT @NewId;
END
GO

-- Better version using OUTPUT clause:
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUser_Insert')
    DROP PROCEDURE spUser_Insert;
GO
CREATE PROCEDURE spUser_Insert
    @Email         NVARCHAR(256),
    @EmailVerified BIT,
    @DisplayName   NVARCHAR(200),
    @Status        INT,
    @CreatedAt     DATETIME2,
    @LastLoginAt   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewId TABLE (Id UNIQUEIDENTIFIER);
    INSERT INTO Users (Email, EmailVerified, DisplayName, Status, CreatedAt, LastLoginAt)
    OUTPUT INSERTED.Id INTO @NewId
    VALUES (@Email, @EmailVerified, @DisplayName, @Status, @CreatedAt, @LastLoginAt);
    SELECT Id FROM @NewId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUserRoles_Insert')
    DROP PROCEDURE spUserRoles_Insert;
GO
CREATE PROCEDURE spUserRoles_Insert
    @UserId    UNIQUEIDENTIFIER,
    @RoleId    INT,
    @AssignedAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO UserRoles (UserId, RoleId, AssignedAt)
    VALUES (@UserId, @RoleId, @AssignedAt);
    SELECT @UserId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordCredentials_Insert')
    DROP PROCEDURE spPasswordCredentials_Insert;
GO
CREATE PROCEDURE spPasswordCredentials_Insert
    @UserId            UNIQUEIDENTIFIER,
    @PasswordHash      NVARCHAR(512),
    @PasswordUpdatedAt DATETIME2,
    @FailedAttempts    INT,
    @LockedUntil       DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO PasswordCredentials
        (UserId, PasswordHash, PasswordUpdatedAt, FailedAttempts, LockedUntil)
    VALUES
        (@UserId, @PasswordHash, @PasswordUpdatedAt, @FailedAttempts, @LockedUntil);
    SELECT @UserId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spRefreshSessions_Insert')
    DROP PROCEDURE spRefreshSessions_Insert;
GO
CREATE PROCEDURE spRefreshSessions_Insert
    @UserId           UNIQUEIDENTIFIER,
    @RefreshTokenHash NVARCHAR(512),
    @ExpiresAt        DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO RefreshSessions (UserId, RefreshTokenHash, ExpiresAt, CreatedAt)
    VALUES (@UserId, @RefreshTokenHash, @ExpiresAt, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordResetToken_Insert')
    DROP PROCEDURE spPasswordResetToken_Insert;
GO
CREATE PROCEDURE spPasswordResetToken_Insert
    @UserId    UNIQUEIDENTIFIER,
    @TokenHash NVARCHAR(512),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    -- Invalidate any previous unused tokens for this user
    UPDATE PasswordResetTokens
    SET UsedAt = SYSUTCDATETIME()
    WHERE UserId = @UserId AND UsedAt IS NULL;

    INSERT INTO PasswordResetTokens (UserId, TokenHash, ExpiresAt, CreatedAt)
    VALUES (@UserId, @TokenHash, @ExpiresAt, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spPasswordResetToken_Validate')
    DROP PROCEDURE spPasswordResetToken_Validate;
GO
CREATE PROCEDURE spPasswordResetToken_Validate
    @TokenHash NVARCHAR(512),
    @Now       DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId
    FROM PasswordResetTokens
    WHERE TokenHash = @TokenHash
      AND ExpiresAt  > @Now
      AND UsedAt     IS NULL;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUser_UpdatePassword')
    DROP PROCEDURE spUser_UpdatePassword;
GO
CREATE PROCEDURE spUser_UpdatePassword
    @TokenHash       NVARCHAR(512),
    @NewPasswordHash NVARCHAR(512),
    @Now             DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId UNIQUEIDENTIFIER;

    -- Validate and consume token
    SELECT @UserId = UserId
    FROM PasswordResetTokens
    WHERE TokenHash = @TokenHash
      AND ExpiresAt  > @Now
      AND UsedAt     IS NULL;

    IF @UserId IS NULL
    BEGIN
        SELECT 0; RETURN;
    END

    -- Update password
    UPDATE PasswordCredentials
    SET PasswordHash      = @NewPasswordHash,
        PasswordUpdatedAt = @Now,
        FailedAttempts    = 0,
        LockedUntil       = NULL
    WHERE UserId = @UserId;

    -- Mark token as used
    UPDATE PasswordResetTokens
    SET UsedAt = @Now
    WHERE TokenHash = @TokenHash;

    SELECT @@ROWCOUNT;
END
GO


-- ================================================================
-- BRAND
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Brand_Insert')
    DROP PROCEDURE sp_Brand_Insert;
GO
CREATE PROCEDURE sp_Brand_Insert
    @Name       NVARCHAR(200),
    @BrandImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Brand (name, barndimage, createdate, Isactive)
    VALUES (@Name, @BrandImage, SYSUTCDATETIME(), 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Brand_Update')
    DROP PROCEDURE sp_Brand_Update;
GO
CREATE PROCEDURE sp_Brand_Update
    @BrandId    INT,
    @Name       NVARCHAR(200),
    @BrandImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Brand
    SET name = @Name, barndimage = @BrandImage, lastupdated = SYSUTCDATETIME()
    WHERE BrandId = @BrandId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Brand_Deactivate')
    DROP PROCEDURE sp_Brand_Deactivate;
GO
CREATE PROCEDURE sp_Brand_Deactivate
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Brand SET Isactive = 0, lastupdated = SYSUTCDATETIME()
    WHERE BrandId = @BrandId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Brand_GetById')
    DROP PROCEDURE sp_Brand_GetById;
GO
CREATE PROCEDURE sp_Brand_GetById
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BrandId, name, barndimage, createdate, lastupdated, Isactive
    FROM Brand WHERE BrandId = @BrandId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Brand_GetAll')
    DROP PROCEDURE sp_Brand_GetAll;
GO
CREATE PROCEDURE sp_Brand_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT BrandId, name, barndimage, createdate, lastupdated, Isactive
    FROM Brand WHERE Isactive = 1 ORDER BY name;
END
GO


-- ================================================================
-- CATEGORY
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_Create')
    DROP PROCEDURE sp_Category_Create;
GO
CREATE PROCEDURE sp_Category_Create
    @CategoryType NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Category (categorytype, Isactive) VALUES (@CategoryType, 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_Update')
    DROP PROCEDURE sp_Category_Update;
GO
CREATE PROCEDURE sp_Category_Update
    @CategoryId   INT,
    @CategoryType NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Category SET categorytype = @CategoryType WHERE CategoryId = @CategoryId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_Deactivate')
    DROP PROCEDURE sp_Category_Deactivate;
GO
CREATE PROCEDURE sp_Category_Deactivate
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Category SET Isactive = 0 WHERE CategoryId = @CategoryId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_Activate')
    DROP PROCEDURE sp_Category_Activate;
GO
CREATE PROCEDURE sp_Category_Activate
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Category SET Isactive = 1 WHERE CategoryId = @CategoryId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_GetById')
    DROP PROCEDURE sp_Category_GetById;
GO
CREATE PROCEDURE sp_Category_GetById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoryId, categorytype, Isactive FROM Category WHERE CategoryId = @CategoryId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_Category_GetAllActive')
    DROP PROCEDURE sp_Category_GetAllActive;
GO
CREATE PROCEDURE sp_Category_GetAllActive
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoryId, categorytype, Isactive FROM Category WHERE Isactive = 1 ORDER BY categorytype;
END
GO


-- ================================================================
-- CONCERN TYPE
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_Create')
    DROP PROCEDURE sp_ConcernType_Create;
GO
CREATE PROCEDURE sp_ConcernType_Create
    @ConcernType NVARCHAR(200),
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ConcernType (ConcernType, description, IsActive) VALUES (@ConcernType, @Description, 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_Update')
    DROP PROCEDURE sp_ConcernType_Update;
GO
CREATE PROCEDURE sp_ConcernType_Update
    @ConcernTypeId INT,
    @ConcernType   NVARCHAR(200),
    @Description   NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ConcernType
    SET ConcernType = @ConcernType, description = @Description
    WHERE ConcernTypeId = @ConcernTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_Deactivate')
    DROP PROCEDURE sp_ConcernType_Deactivate;
GO
CREATE PROCEDURE sp_ConcernType_Deactivate
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ConcernType SET IsActive = 0 WHERE ConcernTypeId = @ConcernTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_Activate')
    DROP PROCEDURE sp_ConcernType_Activate;
GO
CREATE PROCEDURE sp_ConcernType_Activate
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ConcernType SET IsActive = 1 WHERE ConcernTypeId = @ConcernTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_GetById')
    DROP PROCEDURE sp_ConcernType_GetById;
GO
CREATE PROCEDURE sp_ConcernType_GetById
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernType, description, IsActive
    FROM ConcernType WHERE ConcernTypeId = @ConcernTypeId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ConcernType_GetAll')
    DROP PROCEDURE sp_ConcernType_GetAll;
GO
CREATE PROCEDURE sp_ConcernType_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernType, description, IsActive
    FROM ConcernType WHERE IsActive = 1 ORDER BY ConcernType;
END
GO


-- ================================================================
-- PAYMENT TYPE
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_CreatePaymentType')
    DROP PROCEDURE sp_CreatePaymentType;
GO
CREATE PROCEDURE sp_CreatePaymentType
    @PaymentType NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO PaymentType (PaymentType, IsActive) VALUES (@PaymentType, 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_UpdatePaymentType')
    DROP PROCEDURE sp_UpdatePaymentType;
GO
CREATE PROCEDURE sp_UpdatePaymentType
    @PaymentTypeId INT,
    @PaymentType   NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PaymentType SET PaymentType = @PaymentType WHERE PaymentTypeId = @PaymentTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_DeactivePaymentType')
    DROP PROCEDURE sp_DeactivePaymentType;
GO
CREATE PROCEDURE sp_DeactivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PaymentType SET IsActive = 0 WHERE PaymentTypeId = @PaymentTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ActivePaymentType')
    DROP PROCEDURE sp_ActivePaymentType;
GO
CREATE PROCEDURE sp_ActivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PaymentType SET IsActive = 1 WHERE PaymentTypeId = @PaymentTypeId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetPaymentTypeById')
    DROP PROCEDURE sp_GetPaymentTypeById;
GO
CREATE PROCEDURE sp_GetPaymentTypeById
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId, PaymentType, IsActive FROM PaymentType WHERE PaymentTypeId = @PaymentTypeId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetAllPaymentType')
    DROP PROCEDURE sp_GetAllPaymentType;
GO
CREATE PROCEDURE sp_GetAllPaymentType
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId, PaymentType, IsActive FROM PaymentType WHERE IsActive = 1 ORDER BY PaymentType;
END
GO


-- ================================================================
-- PRODUCT IMAGES
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_CreateProductImage')
    DROP PROCEDURE sp_CreateProductImage;
GO
CREATE PROCEDURE sp_CreateProductImage
    @ProductId INT,
    @ImageUrl  NVARCHAR(500),
    @IsPrimary BIT = 0,
    @SortOrder INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductImages (productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive)
    VALUES (@ProductId, @ImageUrl, @IsPrimary, @SortOrder, SYSUTCDATETIME(), 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_UpdateProductImage')
    DROP PROCEDURE sp_UpdateProductImage;
GO
CREATE PROCEDURE sp_UpdateProductImage
    @ImageId   INT,
    @ProductId INT,
    @ImageUrl  NVARCHAR(500),
    @IsPrimary BIT,
    @SortOrder INT,
    @IsActive  BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductImages
    SET productid = @ProductId, ImageUrl = @ImageUrl,
        IsPrimary = @IsPrimary, SortOrder = @SortOrder, IsActive = @IsActive
    WHERE ImageId = @ImageId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_DeactiveProductImage')
    DROP PROCEDURE sp_DeactiveProductImage;
GO
CREATE PROCEDURE sp_DeactiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductImages SET IsActive = 0 WHERE ImageId = @ImageId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ActiveProductImage')
    DROP PROCEDURE sp_ActiveProductImage;
GO
CREATE PROCEDURE sp_ActiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductImages SET IsActive = 1 WHERE ImageId = @ImageId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetProductImageById')
    DROP PROCEDURE sp_GetProductImageById;
GO
CREATE PROCEDURE sp_GetProductImageById
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM ProductImages WHERE ImageId = @ImageId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetAllProductImage')
    DROP PROCEDURE sp_GetAllProductImage;
GO
CREATE PROCEDURE sp_GetAllProductImage
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM ProductImages WHERE IsActive = 1 ORDER BY productid, SortOrder;
END
GO


-- ================================================================
-- PRODUCT FAQ
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_CreateFAQ')
    DROP PROCEDURE sp_CreateFAQ;
GO
CREATE PROCEDURE sp_CreateFAQ
    @ProductId INT,
    @Question  NVARCHAR(1000),
    @Answer    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ProductFAQ (productid, Question, Answer, createdUTC, IsActive)
    VALUES (@ProductId, @Question, @Answer, SYSUTCDATETIME(), 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_UpdateFAQ')
    DROP PROCEDURE sp_UpdateFAQ;
GO
CREATE PROCEDURE sp_UpdateFAQ
    @FAQId     INT,
    @ProductId INT,
    @Question  NVARCHAR(1000),
    @Answer    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductFAQ
    SET productid = @ProductId, Question = @Question, Answer = @Answer
    WHERE FAQId = @FAQId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_DeactiveFAQ')
    DROP PROCEDURE sp_DeactiveFAQ;
GO
CREATE PROCEDURE sp_DeactiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductFAQ SET IsActive = 0 WHERE FAQId = @FAQId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_ActiveFAQ')
    DROP PROCEDURE sp_ActiveFAQ;
GO
CREATE PROCEDURE sp_ActiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductFAQ SET IsActive = 1 WHERE FAQId = @FAQId;
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetFAQById')
    DROP PROCEDURE sp_GetFAQById;
GO
CREATE PROCEDURE sp_GetFAQById
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM ProductFAQ WHERE FAQId = @FAQId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'sp_GetAllFAQ')
    DROP PROCEDURE sp_GetAllFAQ;
GO
CREATE PROCEDURE sp_GetAllFAQ
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM ProductFAQ WHERE IsActive = 1 ORDER BY productid, FAQId;
END
GO


-- ================================================================
-- PRODUCT CATALOG
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_GetAll')
    DROP PROCEDURE spProductCatalog_GetAll;
GO
CREATE PROCEDURE spProductCatalog_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.productid, p.name, p.brandid, b.name AS BrandName,
           p.categoryid, c.categorytype AS CategoryName,
           p.description, p.weight, p.insale, p.createdate, p.lastupdated,
           COALESCE(inv.StockQuantity, 0) AS StockQuantity,
           COALESCE(pr.SellingPrice, 0)   AS SellingPrice,
           COALESCE(pr.OriginalPrice, 0)  AS OriginalPrice
    FROM ProductCatalog p
    LEFT JOIN Brand           b   ON b.BrandId    = p.brandid
    LEFT JOIN Category        c   ON c.CategoryId = p.categoryid
    LEFT JOIN ProductInventory inv ON inv.productid = p.productid
    LEFT JOIN ProductPricing  pr  ON pr.productid  = p.productid
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
           p.categoryid, c.categorytype AS CategoryName,
           p.description, p.weight, p.insale, p.createdate, p.lastupdated,
           COALESCE(inv.StockQuantity, 0) AS StockQuantity,
           COALESCE(pr.SellingPrice, 0)   AS SellingPrice,
           COALESCE(pr.OriginalPrice, 0)  AS OriginalPrice
    FROM ProductCatalog p
    LEFT JOIN Brand           b   ON b.BrandId    = p.brandid
    LEFT JOIN Category        c   ON c.CategoryId = p.categoryid
    LEFT JOIN ProductInventory inv ON inv.productid = p.productid
    LEFT JOIN ProductPricing  pr  ON pr.productid  = p.productid
    WHERE p.productid = @ProductId;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductCatalog_Insert')
    DROP PROCEDURE spProductCatalog_Insert;
GO
CREATE PROCEDURE spProductCatalog_Insert
    @Name          NVARCHAR(200),
    @BrandId       INT,
    @CategoryId    INT,
    @Description   NVARCHAR(MAX)  = NULL,
    @Weight        DECIMAL(18,3)  = NULL,
    @InSale        BIT            = 1,
    @SellingPrice  DECIMAL(18,2)  = 0,
    @OriginalPrice DECIMAL(18,2)  = 0,
    @StockQuantity INT            = 0
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
    @ProductId     INT,
    @Name          NVARCHAR(200),
    @BrandId       INT,
    @CategoryId    INT,
    @Description   NVARCHAR(MAX) = NULL,
    @Weight        DECIMAL(18,3) = NULL,
    @InSale        BIT           = 1,
    @SellingPrice  DECIMAL(18,2) = NULL,
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

    UPDATE ProductPricing
    SET SellingPrice  = COALESCE(@SellingPrice,  SellingPrice),
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


-- ================================================================
-- PRODUCT REVIEWS
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_Insert')
    DROP PROCEDURE spProductReview_Insert;
GO
CREATE PROCEDURE spProductReview_Insert
    @ProductId          INT,
    @UserId             UNIQUEIDENTIFIER,
    @Rate               TINYINT,
    @Comment            NVARCHAR(2000) = NULL,
    @IsVerifiedPurchase BIT            = 0
AS
BEGIN
    SET NOCOUNT ON;
    -- Only allow one review per user per product
    IF EXISTS (SELECT 1 FROM ProductReviews WHERE UserId = @UserId AND productid = @ProductId)
    BEGIN
        SELECT -1; RETURN;
    END

    INSERT INTO ProductReviews
        (productid, UserId, Rate, Comment, IsVerifiedPurchase, IsApproved, CreatedAt)
    VALUES
        (@ProductId, @UserId, @Rate, @Comment, @IsVerifiedPurchase, 0, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_GetByProduct')
    DROP PROCEDURE spProductReview_GetByProduct;
GO
CREATE PROCEDURE spProductReview_GetByProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: approved reviews
    SELECT r.Id, r.productid, p.name AS ProductName,
           r.UserId, u.DisplayName,
           r.Rate, r.Comment, r.IsVerifiedPurchase, r.IsApproved, r.CreatedAt
    FROM ProductReviews r
    INNER JOIN Users           u ON u.Id        = r.UserId
    INNER JOIN ProductCatalog  p ON p.productid = r.productid
    WHERE r.productid = @ProductId
      AND r.IsApproved = 1
    ORDER BY r.CreatedAt DESC;

    -- Result set 2: aggregate
    SELECT COUNT(*)          AS TotalReviews,
           AVG(CAST(Rate AS FLOAT)) AS AvgRating
    FROM ProductReviews
    WHERE productid = @ProductId AND IsApproved = 1;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_GetAll')
    DROP PROCEDURE spProductReview_GetAll;
GO
CREATE PROCEDURE spProductReview_GetAll
    @PageSize    INT  = 50,
    @Offset      INT  = 0,
    @IsApproved  BIT  = NULL,
    @ProductId   INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: reviews
    SELECT r.Id, r.productid, p.name AS ProductName,
           r.UserId, u.DisplayName,
           r.Rate, r.Comment, r.IsVerifiedPurchase, r.IsApproved, r.CreatedAt
    FROM ProductReviews r
    INNER JOIN Users          u ON u.Id        = r.UserId
    INNER JOIN ProductCatalog p ON p.productid = r.productid
    WHERE (@IsApproved IS NULL OR r.IsApproved = @IsApproved)
      AND (@ProductId  IS NULL OR r.productid  = @ProductId)
    ORDER BY r.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;

    -- Result set 2: total count
    SELECT COUNT(*) AS TotalReviews,
           AVG(CAST(Rate AS FLOAT)) AS AvgRating
    FROM ProductReviews
    WHERE (@IsApproved IS NULL OR IsApproved = @IsApproved)
      AND (@ProductId  IS NULL OR productid  = @ProductId);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spProductReview_Moderate')
    DROP PROCEDURE spProductReview_Moderate;
GO
CREATE PROCEDURE spProductReview_Moderate
    @Id         INT,
    @IsApproved BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ProductReviews SET IsApproved = @IsApproved WHERE Id = @Id;
    SELECT @@ROWCOUNT;
END
GO


-- ================================================================
-- ORDERS
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_Insert')
    DROP PROCEDURE spOrder_Insert;
GO
CREATE PROCEDURE spOrder_Insert
    @UserId         UNIQUEIDENTIFIER,
    @OrderRef       NVARCHAR(30),
    @PaymentMethod  NVARCHAR(50),
    @ShippingName   NVARCHAR(200),
    @ShippingPhone  NVARCHAR(30),
    @ShippingAddress NVARCHAR(500),
    @ShippingCity   NVARCHAR(100),
    @SubtotalLkr    DECIMAL(18,2),
    @ShippingFee    DECIMAL(18,2),
    @DiscountLkr    DECIMAL(18,2),
    @TotalLkr       DECIMAL(18,2),
    @Notes          NVARCHAR(1000) = NULL
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
    INSERT INTO OrderItems (OrderId, ProductId, ProductName, Qty, UnitPrice, LineTotal)
    VALUES (@OrderId, @ProductId, @ProductName, @Qty, @UnitPrice, @LineTotal);
    SELECT CAST(SCOPE_IDENTITY() AS INT);
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetAll')
    DROP PROCEDURE spOrder_GetAll;
GO
CREATE PROCEDURE spOrder_GetAll
    @PageSize INT  = 50,
    @Offset   INT  = 0,
    @Status   NVARCHAR(20)     = NULL,
    @UserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName,
           u.Email       AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE (@Status IS NULL OR o.Status = @Status)
      AND (@UserId IS NULL OR o.UserId = @UserId)
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetById')
    DROP PROCEDURE spOrder_GetById;
GO
CREATE PROCEDURE spOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: order header
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName,
           u.Email       AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE o.Id = @Id;

    -- Result set 2: line items
    SELECT oi.Id, oi.OrderId, oi.ProductId, oi.ProductName, oi.Qty, oi.UnitPrice, oi.LineTotal
    FROM OrderItems oi
    WHERE oi.OrderId = @Id;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spOrder_GetByUserId')
    DROP PROCEDURE spOrder_GetByUserId;
GO
CREATE PROCEDURE spOrder_GetByUserId
    @UserId   UNIQUEIDENTIFIER,
    @PageSize INT = 20,
    @Offset   INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName,
           u.Email       AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE o.UserId = @UserId
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

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


-- ================================================================
-- DISPATCH
-- ================================================================

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
        SET TrackingId        = COALESCE(@TrackingId,        TrackingId),
            Courier           = COALESCE(@Courier,           Courier),
            EstimatedDelivery = COALESCE(@EstimatedDelivery, EstimatedDelivery),
            Notes             = COALESCE(@Notes,             Notes),
            UpdatedAt         = SYSUTCDATETIME()
        WHERE OrderId = @OrderId;
    END
    ELSE
    BEGIN
        INSERT INTO Dispatch
            (OrderId, TrackingId, Courier, EstimatedDelivery, Notes,
             DispatchedAt, CreatedByUserId, UpdatedAt)
        VALUES
            (@OrderId, @TrackingId, @Courier, @EstimatedDelivery, @Notes,
             SYSUTCDATETIME(), @CreatedByUserId, NULL);

        -- Update order status to dispatched
        UPDATE Orders SET Status = 'dispatched', UpdatedAt = SYSUTCDATETIME()
        WHERE Id = @OrderId AND Status NOT IN ('delivered', 'cancelled');
    END
    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDispatch_MarkDelivered')
    DROP PROCEDURE spDispatch_MarkDelivered;
GO
CREATE PROCEDURE spDispatch_MarkDelivered
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Dispatch
    SET DeliveredAt = SYSUTCDATETIME(), UpdatedAt = SYSUTCDATETIME()
    WHERE OrderId = @OrderId;

    UPDATE Orders
    SET Status = 'delivered', UpdatedAt = SYSUTCDATETIME()
    WHERE Id = @OrderId;

    SELECT @@ROWCOUNT;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDispatch_GetPending')
    DROP PROCEDURE spDispatch_GetPending;
GO
CREATE PROCEDURE spDispatch_GetPending
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.Id, d.OrderId, o.OrderRef,
           u.DisplayName  AS CustomerName,
           o.ShippingCity,
           o.TotalLkr,
           o.Status        AS OrderStatus,
           d.TrackingId, d.Courier,
           d.DispatchedAt, d.EstimatedDelivery, d.DeliveredAt,
           d.Notes
    FROM Dispatch d
    INNER JOIN Orders o ON o.Id = d.OrderId
    INNER JOIN Users  u ON u.Id = o.UserId
    WHERE d.DeliveredAt IS NULL
    ORDER BY d.DispatchedAt ASC;
END
GO


-- ================================================================
-- PROCUREMENT
-- ================================================================

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

    -- When approved: add stock for all items that link to a product
    IF @Status = 'approved'
    BEGIN
        UPDATE inv
        SET inv.StockQuantity = inv.StockQuantity + pi.Quantity,
            inv.LastUpdated   = SYSUTCDATETIME()
        FROM ProductInventory inv
        INNER JOIN ProcurementItems pi ON pi.ProductId = inv.productid
        WHERE pi.ProcurementOrderId = @Id
          AND pi.ProductId IS NOT NULL;
    END

    SELECT @@ROWCOUNT;
END
GO

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


-- ================================================================
-- AUDIT / SECURITY
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spAdminAuditLog_Insert')
    DROP PROCEDURE spAdminAuditLog_Insert;
GO
CREATE PROCEDURE spAdminAuditLog_Insert
    @AdminUserId UNIQUEIDENTIFIER,
    @Action      NVARCHAR(100),
    @EntityType  NVARCHAR(100) = NULL,
    @EntityId    NVARCHAR(100) = NULL,
    @OldValues   NVARCHAR(MAX) = NULL,
    @NewValues   NVARCHAR(MAX) = NULL,
    @IpAddress   NVARCHAR(50)  = NULL,
    @UserAgent   NVARCHAR(500) = NULL
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

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spAdminAuditLog_GetPaged')
    DROP PROCEDURE spAdminAuditLog_GetPaged;
GO
CREATE PROCEDURE spAdminAuditLog_GetPaged
    @PageSize    INT              = 50,
    @Offset      INT              = 0,
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

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUserLoginHistory_Insert')
    DROP PROCEDURE spUserLoginHistory_Insert;
GO
CREATE PROCEDURE spUserLoginHistory_Insert
    @UserId    UNIQUEIDENTIFIER = NULL,
    @Email     NVARCHAR(256),
    @IsSuccess BIT,
    @FailReason NVARCHAR(200)   = NULL,
    @IpAddress NVARCHAR(50)     = NULL,
    @UserAgent NVARCHAR(500)    = NULL
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


-- ================================================================
-- DASHBOARD (admin analytics — read-only)
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetStats')
    DROP PROCEDURE spDashboard_GetStats;
GO
CREATE PROCEDURE spDashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT COUNT(*) FROM Orders WHERE CAST(CreatedAt AS DATE) = CAST(SYSUTCDATETIME() AS DATE))
            AS TodayOrders,
        (SELECT COALESCE(SUM(TotalLkr), 0) FROM Orders
         WHERE CAST(CreatedAt AS DATE) = CAST(SYSUTCDATETIME() AS DATE)
           AND Status NOT IN ('cancelled'))
            AS TodayRevenue,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'pending')
            AS PendingOrders,
        (SELECT COUNT(*) FROM Orders WHERE Status = 'processing')
            AS ProcessingOrders,
        (SELECT COUNT(*) FROM Orders WHERE MONTH(CreatedAt) = MONTH(SYSUTCDATETIME())
                                        AND YEAR(CreatedAt) = YEAR(SYSUTCDATETIME()))
            AS MonthOrders,
        (SELECT COALESCE(SUM(TotalLkr), 0) FROM Orders
         WHERE MONTH(CreatedAt) = MONTH(SYSUTCDATETIME())
           AND YEAR(CreatedAt)  = YEAR(SYSUTCDATETIME())
           AND Status NOT IN ('cancelled'))
            AS MonthRevenue,
        (SELECT COUNT(*) FROM Users INNER JOIN UserRoles ur ON ur.UserId = Users.Id WHERE ur.RoleId = 2)
            AS TotalCustomers,
        (SELECT COUNT(*) FROM ProductCatalog WHERE insale = 1)
            AS ActiveProducts,
        (SELECT COUNT(*) FROM ProductInventory WHERE StockQuantity = 0)
            AS OutOfStockProducts,
        (SELECT COUNT(*) FROM ProductReviews WHERE IsApproved = 0)
            AS PendingReviews;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetRevenueMonthly')
    DROP PROCEDURE spDashboard_GetRevenueMonthly;
GO
CREATE PROCEDURE spDashboard_GetRevenueMonthly
    @Months INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    SELECT YEAR(CreatedAt)  AS Year,
           MONTH(CreatedAt) AS Month,
           COUNT(*)                    AS OrderCount,
           SUM(TotalLkr)               AS TotalRevenue
    FROM Orders
    WHERE Status NOT IN ('cancelled')
      AND CreatedAt >= DATEADD(MONTH, -@Months, SYSUTCDATETIME())
    GROUP BY YEAR(CreatedAt), MONTH(CreatedAt)
    ORDER BY Year, Month;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetOrderStatusBreakdown')
    DROP PROCEDURE spDashboard_GetOrderStatusBreakdown;
GO
CREATE PROCEDURE spDashboard_GetOrderStatusBreakdown
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Status, COUNT(*) AS Count
    FROM Orders
    GROUP BY Status;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetCategorySales')
    DROP PROCEDURE spDashboard_GetCategorySales;
GO
CREATE PROCEDURE spDashboard_GetCategorySales
    @FromDate DATE = NULL,
    @ToDate   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.categorytype AS Category,
           COUNT(DISTINCT o.Id) AS OrderCount,
           SUM(oi.LineTotal)    AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders        o ON o.Id          = oi.OrderId
    INNER JOIN ProductCatalog p ON p.productid   = oi.ProductId
    INNER JOIN Category      c ON c.CategoryId  = p.categoryid
    WHERE o.Status NOT IN ('cancelled')
      AND (@FromDate IS NULL OR CAST(o.CreatedAt AS DATE) >= @FromDate)
      AND (@ToDate   IS NULL OR CAST(o.CreatedAt AS DATE) <= @ToDate)
    GROUP BY c.CategoryId, c.categorytype
    ORDER BY Revenue DESC;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetTopProducts')
    DROP PROCEDURE spDashboard_GetTopProducts;
GO
CREATE PROCEDURE spDashboard_GetTopProducts
    @Top  INT  = 10,
    @Days INT  = 30
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           oi.ProductId,
           oi.ProductName,
           SUM(oi.Qty)       AS TotalQty,
           SUM(oi.LineTotal) AS TotalRevenue
    FROM OrderItems oi
    INNER JOIN Orders o ON o.Id = oi.OrderId
    WHERE o.Status NOT IN ('cancelled')
      AND o.CreatedAt >= DATEADD(DAY, -@Days, SYSUTCDATETIME())
    GROUP BY oi.ProductId, oi.ProductName
    ORDER BY TotalRevenue DESC;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDashboard_GetRecentOrders')
    DROP PROCEDURE spDashboard_GetRecentOrders;
GO
CREATE PROCEDURE spDashboard_GetRecentOrders
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           o.Id, o.OrderRef, u.DisplayName AS CustomerName,
           o.TotalLkr, o.Status, o.CreatedAt
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    ORDER BY o.CreatedAt DESC;
END
GO


-- ================================================================
-- REPORTS (admin date-range analytics)
-- ================================================================

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_Revenue')
    DROP PROCEDURE spReport_Revenue;
GO
CREATE PROCEDURE spReport_Revenue
    @FromDate DATE,
    @ToDate   DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(o.CreatedAt AS DATE) AS Date,
           COUNT(*)                  AS OrderCount,
           SUM(o.SubtotalLkr)        AS Subtotal,
           SUM(o.ShippingFee)        AS ShippingFee,
           SUM(o.DiscountLkr)        AS Discount,
           SUM(o.TotalLkr)           AS TotalRevenue
    FROM Orders o
    WHERE CAST(o.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND o.Status NOT IN ('cancelled')
    GROUP BY CAST(o.CreatedAt AS DATE)
    ORDER BY Date;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_SalesByCategory')
    DROP PROCEDURE spReport_SalesByCategory;
GO
CREATE PROCEDURE spReport_SalesByCategory
    @FromDate DATE,
    @ToDate   DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.categorytype AS Category,
           COUNT(DISTINCT o.Id) AS OrderCount,
           SUM(oi.Qty)          AS UnitsSold,
           SUM(oi.LineTotal)    AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders         o ON o.Id         = oi.OrderId
    INNER JOIN ProductCatalog p ON p.productid  = oi.ProductId
    INNER JOIN Category       c ON c.CategoryId = p.categoryid
    WHERE CAST(o.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND o.Status NOT IN ('cancelled')
    GROUP BY c.CategoryId, c.categorytype
    ORDER BY Revenue DESC;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_TopCustomers')
    DROP PROCEDURE spReport_TopCustomers;
GO
CREATE PROCEDURE spReport_TopCustomers
    @FromDate DATE,
    @ToDate   DATE,
    @Top      INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           u.Id AS UserId,
           u.DisplayName,
           u.Email,
           COUNT(o.Id)       AS OrderCount,
           SUM(o.TotalLkr)   AS TotalSpent
    FROM Orders o
    INNER JOIN Users u ON u.Id = o.UserId
    WHERE CAST(o.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND o.Status NOT IN ('cancelled')
    GROUP BY u.Id, u.DisplayName, u.Email
    ORDER BY TotalSpent DESC;
END
GO

IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spReport_SalesByProduct')
    DROP PROCEDURE spReport_SalesByProduct;
GO
CREATE PROCEDURE spReport_SalesByProduct
    @FromDate DATE,
    @ToDate   DATE,
    @Top      INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           oi.ProductId,
           oi.ProductName,
           SUM(oi.Qty)       AS UnitsSold,
           SUM(oi.LineTotal) AS Revenue
    FROM OrderItems oi
    INNER JOIN Orders o ON o.Id = oi.OrderId
    WHERE CAST(o.CreatedAt AS DATE) BETWEEN @FromDate AND @ToDate
      AND o.Status NOT IN ('cancelled')
    GROUP BY oi.ProductId, oi.ProductName
    ORDER BY Revenue DESC;
END
GO


-- ================================================================
PRINT '== TenzyShop schema complete: 24 tables + 78 stored procedures ==';
GO
