-- ================================================================
-- TenzyShop — COMPLETE DATABASE SCHEMA
-- Exact column names derived from C# Entity files
-- Exact SP names derived from C# Reader/Writer files
-- Run on: tenzyuk_production
-- ================================================================

USE [tenzyuk_production];
GO

-- ================================================================
-- SECTION 1: DROP ALL STORED PROCEDURES
-- ================================================================
IF OBJECT_ID('dbo.spUser_Insert',                    'P') IS NOT NULL DROP PROCEDURE dbo.spUser_Insert;
IF OBJECT_ID('dbo.spUserRoles_Insert',               'P') IS NOT NULL DROP PROCEDURE dbo.spUserRoles_Insert;
IF OBJECT_ID('dbo.spPasswordCredentials_Insert',     'P') IS NOT NULL DROP PROCEDURE dbo.spPasswordCredentials_Insert;
IF OBJECT_ID('dbo.spRefreshSessions_Insert',         'P') IS NOT NULL DROP PROCEDURE dbo.spRefreshSessions_Insert;
IF OBJECT_ID('dbo.spPasswordResetToken_Insert',      'P') IS NOT NULL DROP PROCEDURE dbo.spPasswordResetToken_Insert;
IF OBJECT_ID('dbo.spPasswordResetToken_Validate',    'P') IS NOT NULL DROP PROCEDURE dbo.spPasswordResetToken_Validate;
IF OBJECT_ID('dbo.spUser_UpdatePassword',            'P') IS NOT NULL DROP PROCEDURE dbo.spUser_UpdatePassword;
IF OBJECT_ID('dbo.sp_Brand_GetAll',                  'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_GetAll;
IF OBJECT_ID('dbo.sp_Brand_GetById',                 'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_GetById;
IF OBJECT_ID('dbo.sp_Brand_Insert',                  'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Insert;
IF OBJECT_ID('dbo.sp_Brand_Update',                  'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Update;
IF OBJECT_ID('dbo.sp_Brand_Deactivate',              'P') IS NOT NULL DROP PROCEDURE dbo.sp_Brand_Deactivate;
IF OBJECT_ID('dbo.sp_Category_GetAllActive',         'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_GetAllActive;
IF OBJECT_ID('dbo.sp_Category_GetById',              'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_GetById;
IF OBJECT_ID('dbo.sp_Category_Create',               'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Create;
IF OBJECT_ID('dbo.sp_Category_Update',               'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Update;
IF OBJECT_ID('dbo.sp_Category_Deactivate',           'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Deactivate;
IF OBJECT_ID('dbo.sp_Category_Activate',             'P') IS NOT NULL DROP PROCEDURE dbo.sp_Category_Activate;
IF OBJECT_ID('dbo.sp_ConcernType_GetAll',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetAll;
IF OBJECT_ID('dbo.sp_ConcernType_GetById',           'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetById;
IF OBJECT_ID('dbo.sp_ConcernType_Create',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Create;
IF OBJECT_ID('dbo.sp_ConcernType_Update',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Update;
IF OBJECT_ID('dbo.sp_ConcernType_Deactivate',        'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Deactivate;
IF OBJECT_ID('dbo.sp_ConcernType_Activate',          'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Activate;
IF OBJECT_ID('dbo.sp_GetAllPaymentType',             'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllPaymentType;
IF OBJECT_ID('dbo.sp_GetPaymentTypeById',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetPaymentTypeById;
IF OBJECT_ID('dbo.sp_CreatePaymentType',             'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreatePaymentType;
IF OBJECT_ID('dbo.sp_UpdatePaymentType',             'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdatePaymentType;
IF OBJECT_ID('dbo.sp_DeactivePaymentType',           'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeactivePaymentType;
IF OBJECT_ID('dbo.sp_ActivePaymentType',             'P') IS NOT NULL DROP PROCEDURE dbo.sp_ActivePaymentType;
IF OBJECT_ID('dbo.spProductCatalog_GetAll',          'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetAll;
IF OBJECT_ID('dbo.spProductCatalog_GetAllAdmin',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetAllAdmin;
IF OBJECT_ID('dbo.spProductCatalog_GetById',         'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetById;
IF OBJECT_ID('dbo.spProductCatalog_Insert',          'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Insert;
IF OBJECT_ID('dbo.spProductCatalog_Update',          'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Update;
IF OBJECT_ID('dbo.spProductCatalog_Deactivate',      'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Deactivate;
IF OBJECT_ID('dbo.sp_GetProductImageById',           'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetProductImageById;
IF OBJECT_ID('dbo.sp_GetAllProductImage',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllProductImage;
IF OBJECT_ID('dbo.sp_CreateProductImage',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateProductImage;
IF OBJECT_ID('dbo.sp_UpdateProductImage',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateProductImage;
IF OBJECT_ID('dbo.sp_DeactiveProductImage',          'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeactiveProductImage;
IF OBJECT_ID('dbo.sp_ActiveProductImage',            'P') IS NOT NULL DROP PROCEDURE dbo.sp_ActiveProductImage;
IF OBJECT_ID('dbo.sp_GetFAQById',                   'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetFAQById;
IF OBJECT_ID('dbo.sp_GetAllFAQ',                    'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllFAQ;
IF OBJECT_ID('dbo.sp_CreateFAQ',                    'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateFAQ;
IF OBJECT_ID('dbo.sp_UpdateFAQ',                    'P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdateFAQ;
IF OBJECT_ID('dbo.sp_DeactiveFAQ',                  'P') IS NOT NULL DROP PROCEDURE dbo.sp_DeactiveFAQ;
IF OBJECT_ID('dbo.sp_ActiveFAQ',                    'P') IS NOT NULL DROP PROCEDURE dbo.sp_ActiveFAQ;
IF OBJECT_ID('dbo.spProductReview_GetByProduct',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_GetByProduct;
IF OBJECT_ID('dbo.spProductReview_GetAll',           'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_GetAll;
IF OBJECT_ID('dbo.spProductReview_Insert',           'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_Insert;
IF OBJECT_ID('dbo.spProductReview_Moderate',         'P') IS NOT NULL DROP PROCEDURE dbo.spProductReview_Moderate;
IF OBJECT_ID('dbo.spAdminAuditLog_Insert',           'P') IS NOT NULL DROP PROCEDURE dbo.spAdminAuditLog_Insert;
IF OBJECT_ID('dbo.spAdminAuditLog_GetPaged',         'P') IS NOT NULL DROP PROCEDURE dbo.spAdminAuditLog_GetPaged;
IF OBJECT_ID('dbo.spUserLoginHistory_Insert',        'P') IS NOT NULL DROP PROCEDURE dbo.spUserLoginHistory_Insert;
IF OBJECT_ID('dbo.spProcurementOrder_GetAll',        'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_GetAll;
IF OBJECT_ID('dbo.spProcurementOrder_GetById',       'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_GetById;
IF OBJECT_ID('dbo.spProcurementOrder_Insert',        'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_Insert;
IF OBJECT_ID('dbo.spProcurementItem_Insert',         'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementItem_Insert;
IF OBJECT_ID('dbo.spProcurementOrder_UpdateStatus',  'P') IS NOT NULL DROP PROCEDURE dbo.spProcurementOrder_UpdateStatus;
IF OBJECT_ID('dbo.spOrder_GetAll',                   'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetAll;
IF OBJECT_ID('dbo.spOrder_GetById',                  'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetById;
IF OBJECT_ID('dbo.spOrder_GetByUserId',              'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_GetByUserId;
IF OBJECT_ID('dbo.spOrder_Insert',                   'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_Insert;
IF OBJECT_ID('dbo.spOrderItem_Insert',               'P') IS NOT NULL DROP PROCEDURE dbo.spOrderItem_Insert;
IF OBJECT_ID('dbo.spOrder_UpdateStatus',             'P') IS NOT NULL DROP PROCEDURE dbo.spOrder_UpdateStatus;
IF OBJECT_ID('dbo.spDispatch_GetPending',            'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_GetPending;
IF OBJECT_ID('dbo.spDispatch_Upsert',                'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_Upsert;
IF OBJECT_ID('dbo.spDispatch_MarkDelivered',         'P') IS NOT NULL DROP PROCEDURE dbo.spDispatch_MarkDelivered;
IF OBJECT_ID('dbo.spDashboard_GetStats',             'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetStats;
IF OBJECT_ID('dbo.spDashboard_GetRevenueMonthly',    'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetRevenueMonthly;
IF OBJECT_ID('dbo.spDashboard_GetOrderStatusBreakdown','P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetOrderStatusBreakdown;
IF OBJECT_ID('dbo.spDashboard_GetCategorySales',     'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetCategorySales;
IF OBJECT_ID('dbo.spDashboard_GetTopProducts',       'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetTopProducts;
IF OBJECT_ID('dbo.spDashboard_GetRecentOrders',      'P') IS NOT NULL DROP PROCEDURE dbo.spDashboard_GetRecentOrders;
IF OBJECT_ID('dbo.spReport_Revenue',                 'P') IS NOT NULL DROP PROCEDURE dbo.spReport_Revenue;
IF OBJECT_ID('dbo.spReport_SalesByCategory',         'P') IS NOT NULL DROP PROCEDURE dbo.spReport_SalesByCategory;
IF OBJECT_ID('dbo.spReport_TopCustomers',            'P') IS NOT NULL DROP PROCEDURE dbo.spReport_TopCustomers;
IF OBJECT_ID('dbo.spReport_SalesByProduct',          'P') IS NOT NULL DROP PROCEDURE dbo.spReport_SalesByProduct;
GO
PRINT 'Dropped all stored procedures.';
GO

-- ================================================================
-- SECTION 2: DROP ALL TABLES (children before parents)
-- ================================================================
IF OBJECT_ID('dbo.Dispatch',              'U') IS NOT NULL DROP TABLE dbo.Dispatch;
IF OBJECT_ID('dbo.OrderItems',            'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders',               'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.ProcurementItems',      'U') IS NOT NULL DROP TABLE dbo.ProcurementItems;
IF OBJECT_ID('dbo.ProcurementOrders',     'U') IS NOT NULL DROP TABLE dbo.ProcurementOrders;
IF OBJECT_ID('dbo.ProductReviews',        'U') IS NOT NULL DROP TABLE dbo.ProductReviews;
IF OBJECT_ID('dbo.AdminAuditLog',         'U') IS NOT NULL DROP TABLE dbo.AdminAuditLog;
IF OBJECT_ID('dbo.UserLoginHistory',      'U') IS NOT NULL DROP TABLE dbo.UserLoginHistory;
IF OBJECT_ID('dbo.PasswordResetTokens',   'U') IS NOT NULL DROP TABLE dbo.PasswordResetTokens;
IF OBJECT_ID('dbo.RefreshSessions',       'U') IS NOT NULL DROP TABLE dbo.RefreshSessions;
IF OBJECT_ID('dbo.PasswordCredentials',   'U') IS NOT NULL DROP TABLE dbo.PasswordCredentials;
IF OBJECT_ID('dbo.UserRoles',             'U') IS NOT NULL DROP TABLE dbo.UserRoles;
IF OBJECT_ID('dbo.ProductPaymentOptions', 'U') IS NOT NULL DROP TABLE dbo.ProductPaymentOptions;
IF OBJECT_ID('dbo.ProductConcerns',       'U') IS NOT NULL DROP TABLE dbo.ProductConcerns;
IF OBJECT_ID('dbo.ProductFAQ',            'U') IS NOT NULL DROP TABLE dbo.ProductFAQ;
IF OBJECT_ID('dbo.ProductImages',         'U') IS NOT NULL DROP TABLE dbo.ProductImages;
IF OBJECT_ID('dbo.ProductPricing',        'U') IS NOT NULL DROP TABLE dbo.ProductPricing;
IF OBJECT_ID('dbo.ProductInventory',      'U') IS NOT NULL DROP TABLE dbo.ProductInventory;
IF OBJECT_ID('dbo.ProductCatalog',        'U') IS NOT NULL DROP TABLE dbo.ProductCatalog;
IF OBJECT_ID('dbo.ConcernTypes',          'U') IS NOT NULL DROP TABLE dbo.ConcernTypes;
IF OBJECT_ID('dbo.PaymentType',           'U') IS NOT NULL DROP TABLE dbo.PaymentType;
IF OBJECT_ID('dbo.Brand',                 'U') IS NOT NULL DROP TABLE dbo.Brand;
IF OBJECT_ID('dbo.Category',              'U') IS NOT NULL DROP TABLE dbo.Category;
IF OBJECT_ID('dbo.Users',                 'U') IS NOT NULL DROP TABLE dbo.Users;
GO
PRINT 'Dropped all tables.';
GO

-- ================================================================
-- SECTION 3: CREATE ALL TABLES
-- Column names match C# Entity [Column("xxx")] attributes exactly
-- ================================================================

-- ----------------------------------------------------------------
-- dbo.Users
-- ----------------------------------------------------------------
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
GO

-- ----------------------------------------------------------------
-- dbo.UserRoles  (RoleId: 1=Admin, 2=Customer)
-- ----------------------------------------------------------------
CREATE TABLE dbo.UserRoles (
    UserId     UNIQUEIDENTIFIER NOT NULL,
    RoleId     INT              NOT NULL,
    AssignedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserRoles PRIMARY KEY (UserId, RoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
);
GO

-- ----------------------------------------------------------------
-- dbo.PasswordCredentials
-- ----------------------------------------------------------------
CREATE TABLE dbo.PasswordCredentials (
    UserId            UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    PasswordHash      NVARCHAR(512)    NOT NULL,
    PasswordUpdatedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    FailedAttempts    INT              NOT NULL DEFAULT 0,
    LockedUntil       DATETIME2        NULL,
    CONSTRAINT FK_PasswordCredentials_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
);
GO

-- ----------------------------------------------------------------
-- dbo.RefreshSessions
-- ----------------------------------------------------------------
CREATE TABLE dbo.RefreshSessions (
    Id               INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId           UNIQUEIDENTIFIER NOT NULL,
    RefreshTokenHash NVARCHAR(512)    NOT NULL,
    ExpiresAt        DATETIME2        NOT NULL,
    CreatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_RefreshSessions_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
);
CREATE INDEX IX_RefreshSessions_UserId ON dbo.RefreshSessions(UserId);
GO

-- ----------------------------------------------------------------
-- dbo.PasswordResetTokens
-- ----------------------------------------------------------------
CREATE TABLE dbo.PasswordResetTokens (
    Id        INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId    UNIQUEIDENTIFIER NOT NULL,
    TokenHash NVARCHAR(512)    NOT NULL,
    ExpiresAt DATETIME2        NOT NULL,
    UsedAt    DATETIME2        NULL,
    CreatedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_PasswordResetTokens_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
);
GO

-- ----------------------------------------------------------------
-- dbo.Brand  (column "barndimage" preserved as-is from entity)
-- ----------------------------------------------------------------
CREATE TABLE dbo.Brand (
    Brandid     INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(200) NOT NULL,
    barndimage  NVARCHAR(500) NULL,
    createdate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    lastupdated DATETIME2     NULL,
    Isactive    BIT           NOT NULL DEFAULT 1
);
GO

-- ----------------------------------------------------------------
-- dbo.Category  (column "catagoryID" and "categorytype" preserved as-is)
-- ----------------------------------------------------------------
CREATE TABLE dbo.Category (
    catagoryID   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    categorytype NVARCHAR(200) NOT NULL,
    IsActive     BIT           NOT NULL DEFAULT 1
);
GO

-- ----------------------------------------------------------------
-- dbo.ConcernTypes  (column "ConcernType" is the name column)
-- ----------------------------------------------------------------
CREATE TABLE dbo.ConcernTypes (
    ConcernTypeId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ConcernType   NVARCHAR(200) NOT NULL,
    description   NVARCHAR(500) NULL,
    IsActive      BIT           NOT NULL DEFAULT 1
);
GO

-- ----------------------------------------------------------------
-- dbo.PaymentType  (column "PaymentType" is the name column)
-- ----------------------------------------------------------------
CREATE TABLE dbo.PaymentType (
    PaymentTypeId INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PaymentType   NVARCHAR(200) NOT NULL,
    IsActive      BIT           NOT NULL DEFAULT 1
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductCatalog
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductCatalog (
    productid   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(300) NOT NULL,
    brandid     INT           NULL,
    categoryid  INT           NULL,
    description NVARCHAR(MAX) NULL,
    weight      DECIMAL(18,3) NULL,
    insale      BIT           NOT NULL DEFAULT 1,
    createdate  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    lastupdated DATETIME2     NULL,
    CONSTRAINT FK_ProductCatalog_Brand    FOREIGN KEY (brandid)    REFERENCES dbo.Brand(Brandid),
    CONSTRAINT FK_ProductCatalog_Category FOREIGN KEY (categoryid) REFERENCES dbo.Category(catagoryID)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductInventory
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductInventory (
    ProductId          INT       NOT NULL PRIMARY KEY,
    stock              INT       NOT NULL DEFAULT 0,
    LastStockUpdateUTC DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ProductInventory_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(productid)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductPricing
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductPricing (
    PricingId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProductId    INT           NOT NULL,
    price        DECIMAL(18,2) NOT NULL,
    discountrate DECIMAL(5,2)  NOT NULL DEFAULT 0,
    StartUTC     DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    EndUTC       DATETIME2     NULL,
    createdate   DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    lastupdated  DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ProductPricing_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(productid)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductImages
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductImages (
    ImageId    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    productid  INT           NOT NULL,
    ImageUrl   NVARCHAR(500) NOT NULL,
    IsPrimary  BIT           NOT NULL DEFAULT 0,
    SortOrder  INT           NOT NULL DEFAULT 0,
    createdate DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME(),
    IsActive   BIT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_ProductImages_Product FOREIGN KEY (productid) REFERENCES dbo.ProductCatalog(productid)
);
CREATE INDEX IX_ProductImages_productid ON dbo.ProductImages(productid);
GO

-- ----------------------------------------------------------------
-- dbo.ProductFAQ
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductFAQ (
    FAQId     INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    productid INT           NOT NULL,
    Question  NVARCHAR(500) NOT NULL,
    Answer    NVARCHAR(MAX) NOT NULL,
    createdUTC DATETIME2   NOT NULL DEFAULT SYSUTCDATETIME(),
    IsActive  BIT          NOT NULL DEFAULT 1,
    CONSTRAINT FK_ProductFAQ_Product FOREIGN KEY (productid) REFERENCES dbo.ProductCatalog(productid)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductConcerns  (concernID FK → ConcernTypes.ConcernTypeId)
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductConcerns (
    productid INT NOT NULL,
    concernID INT NOT NULL,
    CONSTRAINT PK_ProductConcerns          PRIMARY KEY (productid, concernID),
    CONSTRAINT FK_ProductConcerns_Product     FOREIGN KEY (productid) REFERENCES dbo.ProductCatalog(productid),
    CONSTRAINT FK_ProductConcerns_ConcernType FOREIGN KEY (concernID)  REFERENCES dbo.ConcernTypes(ConcernTypeId)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductPaymentOptions
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductPaymentOptions (
    productid     INT NOT NULL,
    PaymentTypeId INT NOT NULL,
    instalment    INT NULL,
    CONSTRAINT PK_ProductPaymentOptions         PRIMARY KEY (productid, PaymentTypeId),
    CONSTRAINT FK_ProductPaymentOptions_Product FOREIGN KEY (productid)     REFERENCES dbo.ProductCatalog(productid),
    CONSTRAINT FK_ProductPaymentOptions_Payment FOREIGN KEY (PaymentTypeId) REFERENCES dbo.PaymentType(PaymentTypeId)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProductReviews
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProductReviews (
    Id                 INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProductId          INT              NOT NULL,
    UserId             UNIQUEIDENTIFIER NOT NULL,
    DisplayName        NVARCHAR(200)    NOT NULL DEFAULT '',
    Rate               TINYINT          NOT NULL,
    Comment            NVARCHAR(MAX)    NULL,
    IsVerifiedPurchase BIT              NOT NULL DEFAULT 0,
    IsApproved         BIT              NOT NULL DEFAULT 0,
    CreatedAt          DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_ProductReviews_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(productid),
    CONSTRAINT FK_ProductReviews_User    FOREIGN KEY (UserId)    REFERENCES dbo.Users(Id)
);
CREATE INDEX IX_ProductReviews_ProductId ON dbo.ProductReviews(ProductId);
GO

-- ----------------------------------------------------------------
-- dbo.AdminAuditLog
-- ----------------------------------------------------------------
CREATE TABLE dbo.AdminAuditLog (
    Id          BIGINT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AdminUserId UNIQUEIDENTIFIER NOT NULL,
    Action      NVARCHAR(200)    NOT NULL,
    EntityType  NVARCHAR(200)    NULL,
    EntityId    NVARCHAR(100)    NULL,
    OldValues   NVARCHAR(MAX)    NULL,
    NewValues   NVARCHAR(MAX)    NULL,
    IpAddress   NVARCHAR(50)     NULL,
    UserAgent   NVARCHAR(500)    NULL,
    CreatedAt   DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_AdminAuditLog_User FOREIGN KEY (AdminUserId) REFERENCES dbo.Users(Id)
);
CREATE INDEX IX_AdminAuditLog_CreatedAt ON dbo.AdminAuditLog(CreatedAt DESC);
GO

-- ----------------------------------------------------------------
-- dbo.UserLoginHistory
-- ----------------------------------------------------------------
CREATE TABLE dbo.UserLoginHistory (
    Id          BIGINT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    UserId      UNIQUEIDENTIFIER NULL,
    Email       NVARCHAR(256)    NOT NULL,
    IsSuccess   BIT              NOT NULL DEFAULT 0,
    FailReason  NVARCHAR(500)    NULL,
    IpAddress   NVARCHAR(50)     NULL,
    UserAgent   NVARCHAR(500)    NULL,
    AttemptedAt DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

-- ----------------------------------------------------------------
-- dbo.ProcurementOrders
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProcurementOrders (
    Id               INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
    OrderReference   NVARCHAR(100)    NOT NULL DEFAULT '',
    SupplierName     NVARCHAR(300)    NOT NULL,
    OrderDate        DATE             NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    GbpToLkr         DECIMAL(18,4)    NOT NULL DEFAULT 0,
    CourierCharges   DECIMAL(18,2)    NOT NULL DEFAULT 0,
    CustomsDuty      DECIMAL(18,2)    NOT NULL DEFAULT 0,
    OtherCharges     DECIMAL(18,2)    NOT NULL DEFAULT 0,
    Notes            NVARCHAR(MAX)    NULL,
    Status           NVARCHAR(50)     NOT NULL DEFAULT 'ordered',
    CreatedByUserId  UNIQUEIDENTIFIER NOT NULL,
    ApprovedByUserId UNIQUEIDENTIFIER NULL,
    ApprovedAt       DATETIME2        NULL,
    CreatedAt        DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt        DATETIME2        NULL,
    CONSTRAINT FK_ProcurementOrders_CreatedBy  FOREIGN KEY (CreatedByUserId)  REFERENCES dbo.Users(Id),
    CONSTRAINT FK_ProcurementOrders_ApprovedBy FOREIGN KEY (ApprovedByUserId) REFERENCES dbo.Users(Id)
);
GO

-- ----------------------------------------------------------------
-- dbo.ProcurementItems
-- ----------------------------------------------------------------
CREATE TABLE dbo.ProcurementItems (
    Id                INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProcurementOrderId INT          NOT NULL,
    ProductId         INT           NULL,
    ProductName       NVARCHAR(300) NOT NULL DEFAULT '',
    Quantity          INT           NOT NULL,
    UnitPriceGbp      DECIMAL(18,4) NOT NULL,
    CONSTRAINT FK_ProcurementItems_Order   FOREIGN KEY (ProcurementOrderId) REFERENCES dbo.ProcurementOrders(Id),
    CONSTRAINT FK_ProcurementItems_Product FOREIGN KEY (ProductId)           REFERENCES dbo.ProductCatalog(productid)
);
GO

-- ----------------------------------------------------------------
-- dbo.Orders
-- ----------------------------------------------------------------
CREATE TABLE dbo.Orders (
    Id              INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
    OrderRef        NVARCHAR(50)     NOT NULL DEFAULT '',
    UserId          UNIQUEIDENTIFIER NOT NULL,
    Status          NVARCHAR(50)     NOT NULL DEFAULT 'pending',
    PaymentMethod   NVARCHAR(100)    NOT NULL DEFAULT '',
    PaymentStatus   NVARCHAR(50)     NOT NULL DEFAULT 'pending',
    ShippingName    NVARCHAR(200)    NOT NULL DEFAULT '',
    ShippingPhone   NVARCHAR(50)     NOT NULL DEFAULT '',
    ShippingAddress NVARCHAR(500)    NOT NULL DEFAULT '',
    ShippingCity    NVARCHAR(200)    NOT NULL DEFAULT '',
    SubtotalLkr     DECIMAL(18,2)    NOT NULL DEFAULT 0,
    ShippingFee     DECIMAL(18,2)    NOT NULL DEFAULT 0,
    DiscountLkr     DECIMAL(18,2)    NOT NULL DEFAULT 0,
    TotalLkr        DECIMAL(18,2)    NOT NULL DEFAULT 0,
    Notes           NVARCHAR(MAX)    NULL,
    CreatedAt       DATETIME2        NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt       DATETIME2        NULL,
    CONSTRAINT FK_Orders_User FOREIGN KEY (UserId) REFERENCES dbo.Users(Id)
);
CREATE INDEX IX_Orders_UserId    ON dbo.Orders(UserId);
CREATE INDEX IX_Orders_Status    ON dbo.Orders(Status);
CREATE INDEX IX_Orders_CreatedAt ON dbo.Orders(CreatedAt DESC);
GO

-- ----------------------------------------------------------------
-- dbo.OrderItems
-- ----------------------------------------------------------------
CREATE TABLE dbo.OrderItems (
    Id          INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    OrderId     INT           NOT NULL,
    ProductId   INT           NOT NULL,
    ProductName NVARCHAR(300) NOT NULL DEFAULT '',
    Qty         INT           NOT NULL,
    UnitPrice   DECIMAL(18,2) NOT NULL,
    LineTotal   DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_OrderItems_Order   FOREIGN KEY (OrderId)   REFERENCES dbo.Orders(Id),
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductId) REFERENCES dbo.ProductCatalog(productid)
);
CREATE INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId);
GO

-- ----------------------------------------------------------------
-- dbo.Dispatch
-- ----------------------------------------------------------------
CREATE TABLE dbo.Dispatch (
    Id                INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    OrderId           INT           NOT NULL UNIQUE,
    TrackingId        NVARCHAR(200) NULL,
    Courier           NVARCHAR(200) NULL,
    DispatchedAt      DATETIME2     NULL,
    EstimatedDelivery DATETIME2     NULL,
    DeliveredAt       DATETIME2     NULL,
    Notes             NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Dispatch_Order FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id)
);
GO

PRINT 'Created all tables.';
GO


-- ================================================================
-- SECTION 4: STORED PROCEDURES
-- ================================================================

-- ----------------------------------------------------------------
-- AUTH: spUser_Insert
-- Called by LoginWriter.InsertUser
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spUser_Insert
    @Email        NVARCHAR(256),
    @EmailVerified BIT       = 0,
    @DisplayName  NVARCHAR(200),
    @Status       INT        = 1,
    @CreatedAt    DATETIME2  = NULL,
    @LastLoginAt  DATETIME2  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewId UNIQUEIDENTIFIER = NEWID();
    INSERT INTO dbo.Users (Id, Email, EmailVerified, DisplayName, Status, CreatedAt, LastLoginAt)
    VALUES (@NewId, @Email, @EmailVerified, @DisplayName, @Status,
            COALESCE(@CreatedAt, SYSUTCDATETIME()),
            @LastLoginAt);
    SELECT @NewId AS Id;
END
GO

-- ----------------------------------------------------------------
-- AUTH: spUserRoles_Insert
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spUserRoles_Insert
    @UserId     UNIQUEIDENTIFIER,
    @RoleId     INT,
    @AssignedAt DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.UserRoles (UserId, RoleId, AssignedAt)
    VALUES (@UserId, @RoleId, COALESCE(@AssignedAt, SYSUTCDATETIME()));
END
GO

-- ----------------------------------------------------------------
-- AUTH: spPasswordCredentials_Insert
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spPasswordCredentials_Insert
    @UserId            UNIQUEIDENTIFIER,
    @PasswordHash      NVARCHAR(512),
    @PasswordUpdatedAt DATETIME2 = NULL,
    @FailedAttempts    INT       = 0,
    @LockedUntil       DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PasswordCredentials (UserId, PasswordHash, PasswordUpdatedAt, FailedAttempts, LockedUntil)
    VALUES (@UserId, @PasswordHash,
            COALESCE(@PasswordUpdatedAt, SYSUTCDATETIME()),
            @FailedAttempts, @LockedUntil);
END
GO

-- ----------------------------------------------------------------
-- AUTH: spRefreshSessions_Insert
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spRefreshSessions_Insert
    @UserId           UNIQUEIDENTIFIER,
    @RefreshTokenHash NVARCHAR(512),
    @ExpiresAt        DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.RefreshSessions (UserId, RefreshTokenHash, ExpiresAt)
    VALUES (@UserId, @RefreshTokenHash, @ExpiresAt);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

-- ----------------------------------------------------------------
-- AUTH: spPasswordResetToken_Insert
-- Called by LoginWriter.StoreForgotPasswordTokenAsync
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spPasswordResetToken_Insert
    @UserId    UNIQUEIDENTIFIER,
    @TokenHash NVARCHAR(512),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    -- Invalidate any existing active tokens for this user
    UPDATE dbo.PasswordResetTokens
    SET    UsedAt = SYSUTCDATETIME()
    WHERE  UserId = @UserId AND UsedAt IS NULL;

    INSERT INTO dbo.PasswordResetTokens (UserId, TokenHash, ExpiresAt)
    VALUES (@UserId, @TokenHash, @ExpiresAt);
END
GO

-- ----------------------------------------------------------------
-- AUTH: spPasswordResetToken_Validate
-- Called by LoginWriter.ValidateForgotPasswordTokenAsync
-- Returns UserId (Guid) if token is valid, else NULL
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spPasswordResetToken_Validate
    @TokenHash NVARCHAR(512),
    @Now       DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT UserId
    FROM   dbo.PasswordResetTokens
    WHERE  TokenHash  = @TokenHash
      AND  UsedAt     IS NULL
      AND  ExpiresAt  > @Now;
END
GO

-- ----------------------------------------------------------------
-- AUTH: spUser_UpdatePassword
-- Called by LoginWriter.ResetPasswordAsync
-- Validates token, updates PasswordCredentials, marks token used
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spUser_UpdatePassword
    @TokenHash       NVARCHAR(512),
    @NewPasswordHash NVARCHAR(512),
    @Now             DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UserId UNIQUEIDENTIFIER;

    SELECT @UserId = UserId
    FROM   dbo.PasswordResetTokens
    WHERE  TokenHash = @TokenHash
      AND  UsedAt    IS NULL
      AND  ExpiresAt > @Now;

    IF @UserId IS NULL
    BEGIN
        SELECT 0 AS Rows; RETURN;
    END

    UPDATE dbo.PasswordCredentials
    SET    PasswordHash      = @NewPasswordHash,
           PasswordUpdatedAt = SYSUTCDATETIME(),
           FailedAttempts    = 0,
           LockedUntil       = NULL
    WHERE  UserId = @UserId;

    UPDATE dbo.PasswordResetTokens
    SET    UsedAt = SYSUTCDATETIME()
    WHERE  TokenHash = @TokenHash;

    SELECT @@ROWCOUNT AS Rows;
END
GO

-- ================================================================
-- BRAND
-- ================================================================
CREATE PROCEDURE dbo.sp_Brand_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Brandid       AS BrandId,
           name          AS Name,
           barndimage    AS BrandImage,
           createdate    AS CreateDate,
           lastupdated   AS LastUpdated,
           Isactive      AS IsActive
    FROM   dbo.Brand
    WHERE  Isactive = 1
    ORDER BY name;
END
GO

CREATE PROCEDURE dbo.sp_Brand_GetById
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Brandid       AS BrandId,
           name          AS Name,
           barndimage    AS BrandImage,
           createdate    AS CreateDate,
           lastupdated   AS LastUpdated,
           Isactive      AS IsActive
    FROM   dbo.Brand
    WHERE  Brandid = @BrandId;
END
GO

CREATE PROCEDURE dbo.sp_Brand_Insert
    @Name       NVARCHAR(200),
    @BrandImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Brand (name, barndimage, createdate)
    VALUES (@Name, @BrandImage, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Brandid;
END
GO

CREATE PROCEDURE dbo.sp_Brand_Update
    @BrandId    INT,
    @Name       NVARCHAR(200),
    @BrandImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Brand
    SET    name        = @Name,
           barndimage  = @BrandImage,
           lastupdated = SYSUTCDATETIME()
    WHERE  Brandid = @BrandId;
END
GO

CREATE PROCEDURE dbo.sp_Brand_Deactivate
    @BrandId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Brand SET Isactive = 0, lastupdated = SYSUTCDATETIME() WHERE Brandid = @BrandId;
END
GO

-- ================================================================
-- CATEGORY  (PK: catagoryID, name column: categorytype)
-- ================================================================
CREATE PROCEDURE dbo.sp_Category_GetAllActive
AS
BEGIN
    SET NOCOUNT ON;
    SELECT catagoryID    AS CategoryId,
           categorytype  AS CategoryType,
           IsActive
    FROM   dbo.Category
    WHERE  IsActive = 1
    ORDER BY categorytype;
END
GO

CREATE PROCEDURE dbo.sp_Category_GetById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT catagoryID    AS CategoryId,
           categorytype  AS CategoryType,
           IsActive
    FROM   dbo.Category
    WHERE  catagoryID = @CategoryId;
END
GO

CREATE PROCEDURE dbo.sp_Category_Create
    @CategoryType NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Category (categorytype) VALUES (@CategoryType);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS catagoryID;
END
GO

CREATE PROCEDURE dbo.sp_Category_Update
    @CategoryId   INT,
    @CategoryType NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category SET categorytype = @CategoryType WHERE catagoryID = @CategoryId;
END
GO

CREATE PROCEDURE dbo.sp_Category_Deactivate
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category SET IsActive = 0 WHERE catagoryID = @CategoryId;
END
GO

CREATE PROCEDURE dbo.sp_Category_Activate
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Category SET IsActive = 1 WHERE catagoryID = @CategoryId;
END
GO

-- ================================================================
-- CONCERN TYPE  (name column: ConcernType)
-- ================================================================
CREATE PROCEDURE dbo.sp_ConcernType_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernType AS Name, description AS Description, IsActive
    FROM   dbo.ConcernTypes
    WHERE  IsActive = 1
    ORDER BY ConcernType;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_GetById
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ConcernTypeId, ConcernType AS Name, description AS Description, IsActive
    FROM   dbo.ConcernTypes
    WHERE  ConcernTypeId = @ConcernTypeId;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_Create
    @ConcernType NVARCHAR(200),
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ConcernTypes (ConcernType, description)
    VALUES (@ConcernType, @Description);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ConcernTypeId;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_Update
    @ConcernTypeId INT,
    @ConcernType   NVARCHAR(200),
    @Description   NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ConcernTypes
    SET    ConcernType = @ConcernType,
           description = @Description
    WHERE  ConcernTypeId = @ConcernTypeId;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_Deactivate
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ConcernTypes SET IsActive = 0 WHERE ConcernTypeId = @ConcernTypeId;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_Activate
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ConcernTypes SET IsActive = 1 WHERE ConcernTypeId = @ConcernTypeId;
END
GO

-- ================================================================
-- PAYMENT TYPE  (name column: PaymentType)
-- ================================================================
CREATE PROCEDURE dbo.sp_GetAllPaymentType
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId,
           PaymentType AS Name,
           IsActive
    FROM   dbo.PaymentType
    WHERE  IsActive = 1
    ORDER BY PaymentType;
END
GO

CREATE PROCEDURE dbo.sp_GetPaymentTypeById
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PaymentTypeId,
           PaymentType AS Name,
           IsActive
    FROM   dbo.PaymentType
    WHERE  PaymentTypeId = @PaymentTypeId;
END
GO

CREATE PROCEDURE dbo.sp_CreatePaymentType
    @PaymentType NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PaymentType (PaymentType) VALUES (@PaymentType);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS PaymentTypeId;
END
GO

CREATE PROCEDURE dbo.sp_UpdatePaymentType
    @PaymentTypeId INT,
    @PaymentType   NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType SET PaymentType = @PaymentType WHERE PaymentTypeId = @PaymentTypeId;
END
GO

CREATE PROCEDURE dbo.sp_DeactivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType SET IsActive = 0 WHERE PaymentTypeId = @PaymentTypeId;
END
GO

CREATE PROCEDURE dbo.sp_ActivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType SET IsActive = 1 WHERE PaymentTypeId = @PaymentTypeId;
END
GO

-- ================================================================
-- PRODUCT CATALOG
-- Pricing: price = selling price stored; discountrate = % off; OriginalPrice back-calculated
-- ================================================================
CREATE PROCEDURE dbo.spProductCatalog_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.productid,
        p.name,
        p.brandid,
        b.name             AS BrandName,
        p.categoryid,
        c.categorytype     AS CategoryName,
        p.description,
        p.weight,
        p.insale,
        p.createdate,
        p.lastupdated,
        ISNULL(inv.stock, 0)          AS StockQuantity,
        ISNULL(pr.price, 0)           AS SellingPrice,
        ISNULL(
            ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2),
            ISNULL(pr.price, 0)
        )                             AS OriginalPrice,
        ISNULL(pr.discountrate, 0)    AS DiscountRate,
        pr.StartUTC,
        pr.EndUTC,
        (SELECT TOP 1 ImageUrl
         FROM dbo.ProductImages pi2
         WHERE pi2.productid = p.productid AND pi2.IsPrimary = 1 AND pi2.IsActive = 1
        )                             AS PrimaryImageUrl,
        (SELECT STRING_AGG(CAST(pc.concernID AS NVARCHAR(20)), ',')
         FROM dbo.ProductConcerns pc
         WHERE pc.productid = p.productid
        )                             AS ConcernTypeIdsCsv
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand          b   ON b.Brandid      = p.brandid    AND b.Isactive  = 1
    LEFT JOIN dbo.Category       c   ON c.catagoryID   = p.categoryid AND c.IsActive  = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    LEFT JOIN dbo.ProductPricing   pr  ON pr.ProductId = p.productid
        AND pr.StartUTC <= SYSUTCDATETIME()
        AND (pr.EndUTC IS NULL OR pr.EndUTC >= SYSUTCDATETIME())
    WHERE p.insale = 1
    ORDER BY p.createdate DESC;
END
GO

-- Admin version: returns ALL products regardless of insale status
CREATE PROCEDURE dbo.spProductCatalog_GetAllAdmin
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.productid,
        p.name,
        p.brandid,
        b.name             AS BrandName,
        p.categoryid,
        c.categorytype     AS CategoryName,
        p.description,
        p.weight,
        p.insale,
        p.createdate,
        p.lastupdated,
        ISNULL(inv.stock, 0)          AS StockQuantity,
        ISNULL(pr.price, 0)           AS SellingPrice,
        ISNULL(
            ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2),
            ISNULL(pr.price, 0)
        )                             AS OriginalPrice,
        ISNULL(pr.discountrate, 0)    AS DiscountRate,
        pr.StartUTC,
        pr.EndUTC,
        (SELECT TOP 1 ImageUrl
         FROM dbo.ProductImages pi2
         WHERE pi2.productid = p.productid AND pi2.IsPrimary = 1 AND pi2.IsActive = 1
        )                             AS PrimaryImageUrl,
        (SELECT STRING_AGG(CAST(pc.concernID AS NVARCHAR(20)), ',')
         FROM dbo.ProductConcerns pc
         WHERE pc.productid = p.productid
        )                             AS ConcernTypeIdsCsv
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand          b   ON b.Brandid      = p.brandid    AND b.Isactive  = 1
    LEFT JOIN dbo.Category       c   ON c.catagoryID   = p.categoryid AND c.IsActive  = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    OUTER APPLY (
        SELECT TOP 1 price, discountrate, StartUTC, EndUTC
        FROM dbo.ProductPricing pr1
        WHERE pr1.ProductId = p.productid
        ORDER BY ISNULL(pr1.lastupdated, pr1.createdate) DESC, pr1.PricingId DESC
    ) pr
    ORDER BY p.createdate DESC;
END
GO

CREATE PROCEDURE dbo.spProductCatalog_GetById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: product (same full join as GetAll)
    SELECT
        p.productid,
        p.name,
        p.brandid,
        b.name             AS BrandName,
        p.categoryid,
        c.categorytype     AS CategoryName,
        p.description,
        p.weight,
        p.insale,
        p.createdate,
        p.lastupdated,
        ISNULL(inv.stock, 0)          AS StockQuantity,
        ISNULL(pr.price, 0)           AS SellingPrice,
        ISNULL(
            ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2),
            ISNULL(pr.price, 0)
        )                             AS OriginalPrice,
        ISNULL(pr.discountrate, 0)    AS DiscountRate,
        pr.StartUTC,
        pr.EndUTC,
        (SELECT TOP 1 ImageUrl
         FROM dbo.ProductImages pi2
         WHERE pi2.productid = p.productid AND pi2.IsPrimary = 1 AND pi2.IsActive = 1
        )                             AS PrimaryImageUrl,
        (SELECT STRING_AGG(CAST(pc.concernID AS NVARCHAR(20)), ',')
         FROM dbo.ProductConcerns pc
         WHERE pc.productid = p.productid
        )                             AS ConcernTypeIdsCsv
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand          b   ON b.Brandid      = p.brandid    AND b.Isactive  = 1
    LEFT JOIN dbo.Category       c   ON c.catagoryID   = p.categoryid AND c.IsActive  = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    OUTER APPLY (
        SELECT TOP 1 price, discountrate, StartUTC, EndUTC
        FROM dbo.ProductPricing pr1
        WHERE pr1.ProductId = p.productid
        ORDER BY ISNULL(pr1.lastupdated, pr1.createdate) DESC, pr1.PricingId DESC
    ) pr
    WHERE  p.productid = @ProductId;

    -- Result set 2: images
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM   dbo.ProductImages
    WHERE  productid = @ProductId AND IsActive = 1
    ORDER BY IsPrimary DESC, SortOrder;

    -- Result set 5: FAQs
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM   dbo.ProductFAQ
    WHERE  productid = @ProductId AND IsActive = 1;

    -- Result set 6: concerns
    SELECT pc.productid, pc.concernID AS ConcernTypeId, ct.ConcernType
    FROM   dbo.ProductConcerns pc
    JOIN   dbo.ConcernTypes ct ON ct.ConcernTypeId = pc.concernID
    WHERE  pc.productid = @ProductId;

    -- Result set 7: payment options
    SELECT pp.productid, pp.PaymentTypeId, pt.PaymentType, pp.instalment
    FROM   dbo.ProductPaymentOptions pp
    JOIN   dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE  pp.productid = @ProductId;
END
GO

CREATE PROCEDURE dbo.spProductCatalog_Insert
    @Name           NVARCHAR(300),
    @BrandId        INT,
    @CategoryId     INT,
    @Description    NVARCHAR(MAX)  = NULL,
    @Weight         DECIMAL(18,3)  = NULL,
    @InSale         BIT            = 1,
    @SellingPrice   DECIMAL(18,2)  = 0,
    @OriginalPrice  DECIMAL(18,2)  = 0,
    @StockQuantity  INT            = 0,
    @StartUTC       DATETIME2      = NULL,
    @EndUTC         DATETIME2      = NULL,
    @ConcernTypeIds NVARCHAR(MAX)  = NULL   -- comma-separated list e.g. '1,2,3'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProductId    INT;
    DECLARE @DiscountRate DECIMAL(5,2) =
        CASE WHEN @OriginalPrice > 0
             THEN ROUND((@OriginalPrice - @SellingPrice) / @OriginalPrice * 100.0, 2)
             ELSE 0 END;

    INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
    VALUES (@Name, @BrandId, @CategoryId, @Description, @Weight, @InSale, SYSUTCDATETIME());
    SET @ProductId = SCOPE_IDENTITY();

    INSERT INTO dbo.ProductInventory (ProductId, stock, LastStockUpdateUTC)
    VALUES (@ProductId, @StockQuantity, SYSUTCDATETIME());

    INSERT INTO dbo.ProductPricing (ProductId, price, discountrate, StartUTC, EndUTC, createdate, lastupdated)
    VALUES (@ProductId, @SellingPrice, @DiscountRate, ISNULL(@StartUTC, SYSUTCDATETIME()), @EndUTC, SYSUTCDATETIME(), SYSUTCDATETIME());

    -- Insert concern types (ignores invalid IDs)
    IF @ConcernTypeIds IS NOT NULL AND LEN(TRIM(@ConcernTypeIds)) > 0
    BEGIN
        INSERT INTO dbo.ProductConcerns (productid, concernID)
        SELECT @ProductId, TRY_CAST(TRIM(value) AS INT)
        FROM   STRING_SPLIT(@ConcernTypeIds, ',')
        WHERE  TRIM(value) <> ''
          AND  TRY_CAST(TRIM(value) AS INT) IS NOT NULL
          AND  EXISTS (
              SELECT 1 FROM dbo.ConcernTypes ct
              WHERE  ct.ConcernTypeId = TRY_CAST(TRIM(value) AS INT)
          );
    END

    SELECT @ProductId AS productid;
END
GO

CREATE PROCEDURE dbo.spProductCatalog_Update
    @ProductId      INT,
    @Name           NVARCHAR(300),
    @BrandId        INT,
    @CategoryId     INT,
    @Description    NVARCHAR(MAX)  = NULL,
    @Weight         DECIMAL(18,3)  = NULL,
    @InSale         BIT            = 1,
    @SellingPrice   DECIMAL(18,2)  = 0,
    @OriginalPrice  DECIMAL(18,2)  = 0,
    @StockQuantity  INT            = NULL,
    @StartUTC       DATETIME2      = NULL,
    @EndUTC         DATETIME2      = NULL,
    @ConcernTypeIds NVARCHAR(MAX)  = NULL   -- comma-separated; NULL = leave unchanged
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DiscountRate DECIMAL(5,2) =
        CASE WHEN @OriginalPrice > 0
             THEN ROUND((@OriginalPrice - @SellingPrice) / @OriginalPrice * 100.0, 2)
             ELSE 0 END;

    UPDATE dbo.ProductCatalog
    SET    name        = @Name,
           brandid     = @BrandId,
           categoryid  = @CategoryId,
           description = @Description,
           weight      = @Weight,
           insale      = @InSale,
           lastupdated = SYSUTCDATETIME()
    WHERE  productid   = @ProductId;

    IF @StockQuantity IS NOT NULL
        UPDATE dbo.ProductInventory
        SET    stock = @StockQuantity, LastStockUpdateUTC = SYSUTCDATETIME()
        WHERE  ProductId = @ProductId;

    UPDATE dbo.ProductPricing
    SET    price        = @SellingPrice,
           discountrate = @DiscountRate,
           StartUTC     = ISNULL(@StartUTC, StartUTC),
           EndUTC       = @EndUTC,
           lastupdated  = SYSUTCDATETIME()
    WHERE  PricingId = (
        SELECT TOP 1 PricingId
        FROM dbo.ProductPricing
        WHERE ProductId = @ProductId
        ORDER BY ISNULL(lastupdated, createdate) DESC, PricingId DESC
    );

    -- Replace concern associations when a list is supplied
    IF @ConcernTypeIds IS NOT NULL
    BEGIN
        DELETE FROM dbo.ProductConcerns WHERE productid = @ProductId;

        IF LEN(TRIM(@ConcernTypeIds)) > 0
        BEGIN
            INSERT INTO dbo.ProductConcerns (productid, concernID)
            SELECT @ProductId, TRY_CAST(TRIM(value) AS INT)
            FROM   STRING_SPLIT(@ConcernTypeIds, ',')
            WHERE  TRIM(value) <> ''
              AND  TRY_CAST(TRIM(value) AS INT) IS NOT NULL
              AND  EXISTS (
                  SELECT 1 FROM dbo.ConcernTypes ct
                  WHERE  ct.ConcernTypeId = TRY_CAST(TRIM(value) AS INT)
              );
        END
    END
END
GO

CREATE PROCEDURE dbo.spProductCatalog_Deactivate
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductCatalog SET insale = 0, lastupdated = SYSUTCDATETIME() WHERE productid = @ProductId;
END
GO

-- ================================================================
-- PRODUCT IMAGES
-- ================================================================
CREATE PROCEDURE dbo.sp_GetProductImageById
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM   dbo.ProductImages
    WHERE  ImageId = @ImageId;
END
GO

CREATE PROCEDURE dbo.sp_GetAllProductImage
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM   dbo.ProductImages
    WHERE  IsActive = 1;
END
GO

CREATE PROCEDURE dbo.sp_CreateProductImage
    @ProductId INT,
    @ImageUrl  NVARCHAR(500),
    @IsPrimary BIT = 0,
    @SortOrder INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @IsPrimary = 1
        UPDATE dbo.ProductImages SET IsPrimary = 0 WHERE productid = @ProductId;

    INSERT INTO dbo.ProductImages (productid, ImageUrl, IsPrimary, SortOrder, createdate)
    VALUES (@ProductId, @ImageUrl, @IsPrimary, @SortOrder, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ImageId;
END
GO

CREATE PROCEDURE dbo.sp_UpdateProductImage
    @ImageId   INT,
    @ProductId INT,
    @ImageUrl  NVARCHAR(500),
    @IsPrimary BIT,
    @SortOrder INT,
    @IsActive  BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF @IsPrimary = 1
        UPDATE dbo.ProductImages SET IsPrimary = 0 WHERE productid = @ProductId AND ImageId <> @ImageId;

    UPDATE dbo.ProductImages
    SET    productid = @ProductId, ImageUrl = @ImageUrl,
           IsPrimary = @IsPrimary, SortOrder = @SortOrder, IsActive = @IsActive
    WHERE  ImageId = @ImageId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

CREATE PROCEDURE dbo.sp_DeactiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductImages SET IsActive = 0 WHERE ImageId = @ImageId;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

CREATE PROCEDURE dbo.sp_ActiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductImages SET IsActive = 1 WHERE ImageId = @ImageId;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ================================================================
-- PRODUCT FAQ
-- ================================================================
CREATE PROCEDURE dbo.sp_GetFAQById
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM   dbo.ProductFAQ
    WHERE  FAQId = @FAQId;
END
GO

CREATE PROCEDURE dbo.sp_GetAllFAQ
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM   dbo.ProductFAQ
    WHERE  IsActive = 1;
END
GO

CREATE PROCEDURE dbo.sp_CreateFAQ
    @ProductId INT,
    @Question  NVARCHAR(500),
    @Answer    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProductFAQ (productid, Question, Answer, createdUTC)
    VALUES (@ProductId, @Question, @Answer, SYSUTCDATETIME());
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS FAQId;
END
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
    SET    productid = @ProductId, Question = @Question, Answer = @Answer
    WHERE  FAQId = @FAQId;
END
GO

CREATE PROCEDURE dbo.sp_DeactiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductFAQ SET IsActive = 0 WHERE FAQId = @FAQId;
END
GO

CREATE PROCEDURE dbo.sp_ActiveFAQ
    @FAQId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductFAQ SET IsActive = 1 WHERE FAQId = @FAQId;
END
GO

-- ================================================================
-- PRODUCT REVIEWS
-- ================================================================
CREATE PROCEDURE dbo.spProductReview_GetByProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: reviews
    SELECT Id, ProductId, UserId, DisplayName, Rate, Comment,
           IsVerifiedPurchase, IsApproved, CreatedAt
    FROM   dbo.ProductReviews
    WHERE  ProductId = @ProductId
    ORDER BY CreatedAt DESC;

    -- Result set 2: aggregate
    SELECT COUNT(*)                     AS TotalReviews,
           AVG(CAST(Rate AS FLOAT))     AS AvgRating
    FROM   dbo.ProductReviews
    WHERE  ProductId = @ProductId AND IsApproved = 1;
END
GO

CREATE PROCEDURE dbo.spProductReview_GetAll
    @PageSize   INT,
    @Offset     INT,
    @IsApproved BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, ProductId, UserId, DisplayName, Rate, Comment,
           IsVerifiedPurchase, IsApproved, CreatedAt
    FROM   dbo.ProductReviews
    WHERE  (@IsApproved IS NULL OR IsApproved = @IsApproved)
    ORDER BY CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE PROCEDURE dbo.spProductReview_Insert
    @ProductId          INT,
    @UserId             UNIQUEIDENTIFIER,
    @DisplayName        NVARCHAR(200),
    @Rate               TINYINT,
    @Comment            NVARCHAR(MAX) = NULL,
    @IsVerifiedPurchase BIT           = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProductReviews (ProductId, UserId, DisplayName, Rate, Comment, IsVerifiedPurchase)
    VALUES (@ProductId, @UserId, @DisplayName, @Rate, @Comment, @IsVerifiedPurchase);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

CREATE PROCEDURE dbo.spProductReview_Moderate
    @Id         INT,
    @IsApproved BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProductReviews SET IsApproved = @IsApproved WHERE Id = @Id;
END
GO

-- ================================================================
-- ADMIN AUDIT LOG
-- ================================================================
CREATE PROCEDURE dbo.spAdminAuditLog_Insert
    @AdminUserId UNIQUEIDENTIFIER,
    @Action      NVARCHAR(200),
    @EntityType  NVARCHAR(200)    = NULL,
    @EntityId    NVARCHAR(100)    = NULL,
    @OldValues   NVARCHAR(MAX)    = NULL,
    @NewValues   NVARCHAR(MAX)    = NULL,
    @IpAddress   NVARCHAR(50)     = NULL,
    @UserAgent   NVARCHAR(500)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.AdminAuditLog
        (AdminUserId, Action, EntityType, EntityId, OldValues, NewValues, IpAddress, UserAgent)
    VALUES
        (@AdminUserId, @Action, @EntityType, @EntityId, @OldValues, @NewValues, @IpAddress, @UserAgent);
    SELECT CAST(SCOPE_IDENTITY() AS BIGINT) AS Id;
END
GO

CREATE PROCEDURE dbo.spAdminAuditLog_GetPaged
    @PageSize    INT,
    @Offset      INT,
    @AdminUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Id, a.AdminUserId, u.DisplayName AS AdminName,
           a.Action, a.EntityType, a.EntityId,
           a.OldValues, a.NewValues, a.IpAddress, a.UserAgent, a.CreatedAt
    FROM   dbo.AdminAuditLog a
    JOIN   dbo.Users u ON u.Id = a.AdminUserId
    WHERE  (@AdminUserId IS NULL OR a.AdminUserId = @AdminUserId)
    ORDER BY a.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

-- ================================================================
-- USER LOGIN HISTORY
-- ================================================================
CREATE PROCEDURE dbo.spUserLoginHistory_Insert
    @UserId     UNIQUEIDENTIFIER = NULL,
    @Email      NVARCHAR(256),
    @IsSuccess  BIT,
    @FailReason NVARCHAR(500)    = NULL,
    @IpAddress  NVARCHAR(50)     = NULL,
    @UserAgent  NVARCHAR(500)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.UserLoginHistory (UserId, Email, IsSuccess, FailReason, IpAddress, UserAgent)
    VALUES (@UserId, @Email, @IsSuccess, @FailReason, @IpAddress, @UserAgent);
END
GO

-- ================================================================
-- PROCUREMENT
-- ================================================================
CREATE PROCEDURE dbo.spProcurementOrder_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, OrderReference, SupplierName, OrderDate, GbpToLkr,
           CourierCharges, CustomsDuty, OtherCharges, Notes, Status,
           CreatedByUserId, ApprovedByUserId, ApprovedAt, CreatedAt, UpdatedAt
    FROM   dbo.ProcurementOrders
    ORDER BY CreatedAt DESC;
END
GO

CREATE PROCEDURE dbo.spProcurementOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: order header
    SELECT Id, OrderReference, SupplierName, OrderDate, GbpToLkr,
           CourierCharges, CustomsDuty, OtherCharges, Notes, Status,
           CreatedByUserId, ApprovedByUserId, ApprovedAt, CreatedAt, UpdatedAt
    FROM   dbo.ProcurementOrders
    WHERE  Id = @Id;

    -- Result set 2: items
    SELECT Id, ProcurementOrderId, ProductId, ProductName, Quantity, UnitPriceGbp
    FROM   dbo.ProcurementItems
    WHERE  ProcurementOrderId = @Id;
END
GO

CREATE PROCEDURE dbo.spProcurementOrder_Insert
    @OrderReference  NVARCHAR(100),
    @SupplierName    NVARCHAR(300),
    @OrderDate       DATE,
    @GbpToLkr        DECIMAL(18,4),
    @CourierCharges  DECIMAL(18,2) = 0,
    @CustomsDuty     DECIMAL(18,2) = 0,
    @OtherCharges    DECIMAL(18,2) = 0,
    @Notes           NVARCHAR(MAX) = NULL,
    @CreatedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProcurementOrders
        (OrderReference, SupplierName, OrderDate, GbpToLkr,
         CourierCharges, CustomsDuty, OtherCharges, Notes, CreatedByUserId)
    VALUES
        (@OrderReference, @SupplierName, @OrderDate, @GbpToLkr,
         @CourierCharges, @CustomsDuty, @OtherCharges, @Notes, @CreatedByUserId);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

CREATE PROCEDURE dbo.spProcurementItem_Insert
    @ProcurementOrderId INT,
    @ProductId          INT           = NULL,
    @ProductName        NVARCHAR(300),
    @Quantity           INT,
    @UnitPriceGbp       DECIMAL(18,4)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProcurementItems (ProcurementOrderId, ProductId, ProductName, Quantity, UnitPriceGbp)
    VALUES (@ProcurementOrderId, @ProductId, @ProductName, @Quantity, @UnitPriceGbp);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

CREATE PROCEDURE dbo.spProcurementOrder_UpdateStatus
    @Id               INT,
    @Status           NVARCHAR(50),
    @ApprovedByUserId UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProcurementOrders
    SET    Status           = @Status,
           ApprovedByUserId = COALESCE(@ApprovedByUserId, ApprovedByUserId),
           ApprovedAt       = CASE WHEN @ApprovedByUserId IS NOT NULL THEN SYSUTCDATETIME() ELSE ApprovedAt END,
           UpdatedAt        = SYSUTCDATETIME()
    WHERE  Id = @Id;

    -- When received: bump stock for all catalogued items
    IF @Status = 'received'
    BEGIN
        UPDATE inv
        SET    inv.stock              = inv.stock + pi2.Quantity,
               inv.LastStockUpdateUTC = SYSUTCDATETIME()
        FROM   dbo.ProductInventory inv
        JOIN   dbo.ProcurementItems pi2 ON pi2.ProductId = inv.ProductId
        WHERE  pi2.ProcurementOrderId = @Id
          AND  pi2.ProductId IS NOT NULL;
    END
END
GO

-- ================================================================
-- ORDERS
-- ================================================================
CREATE PROCEDURE dbo.spOrder_GetAll
    @PageSize INT,
    @Offset   INT,
    @Status   NVARCHAR(50)     = NULL,
    @UserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  (@Status IS NULL OR o.Status = @Status)
      AND  (@UserId IS NULL OR o.UserId = @UserId)
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE PROCEDURE dbo.spOrder_GetById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: order header
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  o.Id = @Id;

    -- Result set 2: items
    SELECT Id, OrderId, ProductId, ProductName, Qty, UnitPrice, LineTotal
    FROM   dbo.OrderItems
    WHERE  OrderId = @Id;
END
GO

CREATE PROCEDURE dbo.spOrder_GetByUserId
    @UserId   UNIQUEIDENTIFIER,
    @PageSize INT,
    @Offset   INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.Id, o.OrderRef, o.UserId,
           u.DisplayName AS CustomerName, u.Email AS CustomerEmail,
           o.Status, o.PaymentMethod, o.PaymentStatus,
           o.ShippingName, o.ShippingPhone, o.ShippingAddress, o.ShippingCity,
           o.SubtotalLkr, o.ShippingFee, o.DiscountLkr, o.TotalLkr,
           o.Notes, o.CreatedAt, o.UpdatedAt,
           (SELECT COUNT(*) FROM dbo.OrderItems oi WHERE oi.OrderId = o.Id) AS ItemCount
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  o.UserId = @UserId
    ORDER BY o.CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END
GO

CREATE PROCEDURE dbo.spOrder_Insert
    @UserId         UNIQUEIDENTIFIER,
    @PaymentMethod  NVARCHAR(100),
    @ShippingName   NVARCHAR(200),
    @ShippingPhone  NVARCHAR(50),
    @ShippingAddress NVARCHAR(500),
    @ShippingCity   NVARCHAR(200),
    @SubtotalLkr    DECIMAL(18,2),
    @ShippingFee    DECIMAL(18,2) = 0,
    @DiscountLkr    DECIMAL(18,2) = 0,
    @TotalLkr       DECIMAL(18,2),
    @Notes          NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NewId    INT;
    DECLARE @OrderRef NVARCHAR(50);

    INSERT INTO dbo.Orders
        (UserId, PaymentMethod, ShippingName, ShippingPhone, ShippingAddress, ShippingCity,
         SubtotalLkr, ShippingFee, DiscountLkr, TotalLkr, Notes)
    VALUES
        (@UserId, @PaymentMethod, @ShippingName, @ShippingPhone, @ShippingAddress, @ShippingCity,
         @SubtotalLkr, @ShippingFee, @DiscountLkr, @TotalLkr, @Notes);

    SET @NewId    = SCOPE_IDENTITY();
    SET @OrderRef = 'ORD-' + CONVERT(NVARCHAR(8), GETUTCDATE(), 112) + '-' + RIGHT('000000' + CAST(@NewId AS NVARCHAR), 6);

    UPDATE dbo.Orders SET OrderRef = @OrderRef WHERE Id = @NewId;

    SELECT @NewId AS Id;
END
GO

CREATE PROCEDURE dbo.spOrderItem_Insert
    @OrderId     INT,
    @ProductId   INT,
    @ProductName NVARCHAR(300),
    @Qty         INT,
    @UnitPrice   DECIMAL(18,2),
    @LineTotal   DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.OrderItems (OrderId, ProductId, ProductName, Qty, UnitPrice, LineTotal)
    VALUES (@OrderId, @ProductId, @ProductName, @Qty, @UnitPrice, @LineTotal);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
END
GO

CREATE PROCEDURE dbo.spOrder_UpdateStatus
    @Id     INT,
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Orders
    SET    Status    = @Status,
           UpdatedAt = SYSUTCDATETIME()
    WHERE  Id = @Id;
END
GO

-- ================================================================
-- DISPATCH
-- ================================================================
CREATE PROCEDURE dbo.spDispatch_GetPending
AS
BEGIN
    SET NOCOUNT ON;
    SELECT d.Id, d.OrderId, o.OrderRef, u.DisplayName AS CustomerName,
           o.ShippingCity, o.TotalLkr, o.Status AS OrderStatus,
           d.TrackingId, d.Courier, d.DispatchedAt, d.EstimatedDelivery, d.DeliveredAt, d.Notes
    FROM   dbo.Dispatch d
    JOIN   dbo.Orders o ON o.Id = d.OrderId
    JOIN   dbo.Users u  ON u.Id = o.UserId
    WHERE  d.DeliveredAt IS NULL
    ORDER BY d.DispatchedAt;
END
GO

CREATE PROCEDURE dbo.spDispatch_Upsert
    @OrderId           INT,
    @TrackingId        NVARCHAR(200) = NULL,
    @Courier           NVARCHAR(200) = NULL,
    @EstimatedDelivery DATETIME2     = NULL,
    @Notes             NVARCHAR(MAX) = NULL,
    @CreatedByUserId   UNIQUEIDENTIFIER = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Dispatch WHERE OrderId = @OrderId)
    BEGIN
        UPDATE dbo.Dispatch
        SET    TrackingId        = COALESCE(@TrackingId, TrackingId),
               Courier           = COALESCE(@Courier, Courier),
               EstimatedDelivery = COALESCE(@EstimatedDelivery, EstimatedDelivery),
               Notes             = COALESCE(@Notes, Notes),
               DispatchedAt      = COALESCE(DispatchedAt, SYSUTCDATETIME())
        WHERE  OrderId = @OrderId;
        SELECT Id FROM dbo.Dispatch WHERE OrderId = @OrderId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Dispatch (OrderId, TrackingId, Courier, EstimatedDelivery, Notes, DispatchedAt)
        VALUES (@OrderId, @TrackingId, @Courier, @EstimatedDelivery, @Notes, SYSUTCDATETIME());
        SELECT CAST(SCOPE_IDENTITY() AS INT) AS Id;
    END

    -- Mark order as shipped
    UPDATE dbo.Orders SET Status = 'shipped', UpdatedAt = SYSUTCDATETIME() WHERE Id = @OrderId;
END
GO

CREATE PROCEDURE dbo.spDispatch_MarkDelivered
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Dispatch SET DeliveredAt = SYSUTCDATETIME() WHERE OrderId = @OrderId;
    UPDATE dbo.Orders  SET Status = 'delivered', UpdatedAt = SYSUTCDATETIME() WHERE Id = @OrderId;
END
GO

-- ================================================================
-- DASHBOARD
-- ================================================================
CREATE PROCEDURE dbo.spDashboard_GetStats
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ThisMonthStart DATETIME2 = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETUTCDATE()), 0);
    DECLARE @LastMonthStart DATETIME2 = DATEADD(MONTH, -1, @ThisMonthStart);
    DECLARE @LastMonthEnd   DATETIME2 = @ThisMonthStart;

    SELECT
        COALESCE((SELECT SUM(TotalLkr) FROM dbo.Orders WHERE Status NOT IN ('cancelled','refunded')), 0)          AS TotalRevenue,
        (SELECT COUNT(*) FROM dbo.Orders)                                                                          AS TotalOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE Status = 'pending')                                                 AS PendingOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE Status = 'processing')                                              AS ProcessingOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE Status = 'shipped')                                                 AS DispatchedOrders,
        (SELECT COUNT(*) FROM dbo.Orders WHERE Status = 'delivered')                                               AS DeliveredOrders,
        (SELECT COUNT(*) FROM dbo.Users  u JOIN dbo.UserRoles ur ON ur.UserId=u.Id AND ur.RoleId=2)                AS TotalCustomers,
        (SELECT COUNT(*) FROM dbo.ProductCatalog WHERE insale = 1)                                                 AS TotalProducts,
        (SELECT COUNT(*) FROM dbo.ProductInventory WHERE stock > 0 AND stock <= 10)                                AS LowStockProducts,
        (SELECT COUNT(*) FROM dbo.ProductInventory WHERE stock = 0)                                                AS OutOfStockProducts,
        COALESCE((SELECT SUM(TotalLkr) FROM dbo.Orders WHERE CreatedAt >= @ThisMonthStart
                  AND Status NOT IN ('cancelled','refunded')), 0)                                                  AS RevenueThisMonth,
        COALESCE((SELECT SUM(TotalLkr) FROM dbo.Orders
                  WHERE CreatedAt >= @LastMonthStart AND CreatedAt < @LastMonthEnd
                  AND Status NOT IN ('cancelled','refunded')), 0)                                                  AS RevenueLastMonth,
        (SELECT COUNT(*) FROM dbo.Orders WHERE CreatedAt >= @ThisMonthStart)                                       AS OrdersThisMonth,
        (SELECT COUNT(*) FROM dbo.Orders WHERE CreatedAt >= @LastMonthStart AND CreatedAt < @LastMonthEnd)         AS OrdersLastMonth;
END
GO

CREATE PROCEDURE dbo.spDashboard_GetRevenueMonthly
AS
BEGIN
    SET NOCOUNT ON;
    SELECT FORMAT(o.CreatedAt, 'yyyy-MM')        AS Month,
           SUM(o.TotalLkr)                       AS Revenue,
           COUNT(*)                               AS Orders,
           COUNT(DISTINCT u_new.Id)               AS NewCustomers
    FROM   dbo.Orders o
    LEFT JOIN (
        SELECT Id, CreatedAt FROM dbo.Users
    ) u_new ON FORMAT(u_new.CreatedAt, 'yyyy-MM') = FORMAT(o.CreatedAt, 'yyyy-MM')
    WHERE  o.CreatedAt >= DATEADD(MONTH, -12, GETUTCDATE())
      AND  o.Status NOT IN ('cancelled','refunded')
    GROUP BY FORMAT(o.CreatedAt, 'yyyy-MM')
    ORDER BY Month;
END
GO

CREATE PROCEDURE dbo.spDashboard_GetOrderStatusBreakdown
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Status, COUNT(*) AS Count
    FROM   dbo.Orders
    GROUP BY Status
    ORDER BY Count DESC;
END
GO

CREATE PROCEDURE dbo.spDashboard_GetCategorySales
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.categorytype AS Category,
           SUM(oi.Qty)    AS Units,
           SUM(oi.LineTotal) AS Revenue
    FROM   dbo.OrderItems oi
    JOIN   dbo.ProductCatalog p ON p.productid  = oi.ProductId
    JOIN   dbo.Category c       ON c.catagoryID = p.categoryid
    JOIN   dbo.Orders o         ON o.Id         = oi.OrderId
    WHERE  o.Status NOT IN ('cancelled','refunded')
    GROUP BY c.categorytype
    ORDER BY Revenue DESC;
END
GO

CREATE PROCEDURE dbo.spDashboard_GetTopProducts
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           oi.ProductId,
           p.name                             AS Name,
           SUM(oi.Qty)                        AS UnitsSold,
           SUM(oi.LineTotal)                  AS Revenue,
           COALESCE(inv.stock, 0)             AS Stock
    FROM   dbo.OrderItems oi
    JOIN   dbo.ProductCatalog p ON p.productid  = oi.ProductId
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = oi.ProductId
    JOIN   dbo.Orders o         ON o.Id         = oi.OrderId
    WHERE  o.Status NOT IN ('cancelled','refunded')
    GROUP BY oi.ProductId, p.name, inv.stock
    ORDER BY Revenue DESC;
END
GO

CREATE PROCEDURE dbo.spDashboard_GetRecentOrders
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           o.Id, o.OrderRef,
           u.DisplayName AS CustomerName,
           o.TotalLkr, o.Status, o.PaymentStatus, o.CreatedAt
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    ORDER BY o.CreatedAt DESC;
END
GO

-- ================================================================
-- REPORTS
-- ================================================================
CREATE PROCEDURE dbo.spReport_Revenue
    @StartDate DATETIME2,
    @EndDate   DATETIME2,
    @GroupBy   NVARCHAR(10) = 'month'   -- 'day' | 'week' | 'month'
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CASE @GroupBy
            WHEN 'day'   THEN CONVERT(NVARCHAR(10), o.CreatedAt, 120)
            WHEN 'week'  THEN 'W' + CAST(DATEPART(WEEK, o.CreatedAt) AS NVARCHAR) + ' ' + CAST(YEAR(o.CreatedAt) AS NVARCHAR)
            ELSE              FORMAT(o.CreatedAt, 'yyyy-MM')
        END                    AS Label,
        SUM(o.TotalLkr)        AS Revenue,
        COUNT(*)               AS OrderCount
    FROM   dbo.Orders o
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('cancelled','refunded')
    GROUP BY
        CASE @GroupBy
            WHEN 'day'   THEN CONVERT(NVARCHAR(10), o.CreatedAt, 120)
            WHEN 'week'  THEN 'W' + CAST(DATEPART(WEEK, o.CreatedAt) AS NVARCHAR) + ' ' + CAST(YEAR(o.CreatedAt) AS NVARCHAR)
            ELSE              FORMAT(o.CreatedAt, 'yyyy-MM')
        END
    ORDER BY Label;
END
GO

CREATE PROCEDURE dbo.spReport_SalesByCategory
    @StartDate DATETIME2,
    @EndDate   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.categorytype  AS Category,
           SUM(oi.Qty)     AS UnitsSold,
           SUM(oi.LineTotal) AS Revenue
    FROM   dbo.OrderItems oi
    JOIN   dbo.ProductCatalog p ON p.productid  = oi.ProductId
    JOIN   dbo.Category c       ON c.catagoryID = p.categoryid
    JOIN   dbo.Orders o         ON o.Id         = oi.OrderId
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('cancelled','refunded')
    GROUP BY c.categorytype
    ORDER BY Revenue DESC;
END
GO

CREATE PROCEDURE dbo.spReport_TopCustomers
    @Top       INT,
    @StartDate DATETIME2,
    @EndDate   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           u.Id          AS UserId,
           u.DisplayName AS CustomerName,
           u.Email,
           COUNT(DISTINCT o.Id)  AS OrderCount,
           SUM(o.TotalLkr)       AS TotalSpent
    FROM   dbo.Orders o
    JOIN   dbo.Users u ON u.Id = o.UserId
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('cancelled','refunded')
    GROUP BY u.Id, u.DisplayName, u.Email
    ORDER BY TotalSpent DESC;
END
GO

CREATE PROCEDURE dbo.spReport_SalesByProduct
    @Top       INT,
    @StartDate DATETIME2,
    @EndDate   DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Top)
           oi.ProductId,
           p.name              AS ProductName,
           SUM(oi.Qty)         AS UnitsSold,
           SUM(oi.LineTotal)   AS Revenue
    FROM   dbo.OrderItems oi
    JOIN   dbo.ProductCatalog p ON p.productid = oi.ProductId
    JOIN   dbo.Orders o         ON o.Id        = oi.OrderId
    WHERE  o.CreatedAt BETWEEN @StartDate AND @EndDate
      AND  o.Status NOT IN ('cancelled','refunded')
    GROUP BY oi.ProductId, p.name
    ORDER BY Revenue DESC;
END
GO

-- ================================================================
-- SECTION 5: SEED DATA
-- ================================================================

-- Payment Types
INSERT INTO dbo.PaymentType (PaymentType) VALUES ('Cash on Delivery');
INSERT INTO dbo.PaymentType (PaymentType) VALUES ('Bank Transfer');
INSERT INTO dbo.PaymentType (PaymentType) VALUES ('Card Payment');
INSERT INTO dbo.PaymentType (PaymentType) VALUES ('Online Payment');
GO

-- Categories
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Skin Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Face Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Body Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Head Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Sun Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Lip Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Hand Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Acne Care', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Moisturizers', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Serums', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Cleansers', 1);
INSERT INTO dbo.Category (categorytype, IsActive) VALUES ('Toners', 1);
GO

-- Concern Types
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Anti-Aging',        'Reduces fine lines and wrinkles', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Acne-Prone',        'Controls breakouts and excess oil', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Dryness',           'Intense hydration for dry skin', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Brightening',       'Evens skin tone and adds radiance', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Sensitive Skin',    'Gentle formulas for reactive skin', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Dark Spots',        'Fades hyperpigmentation', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Sun Damage',        'Repairs UV-related damage', 1);
INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive) VALUES ('Oily Skin',         'Mattifies and controls shine', 1);
GO

-- Brands
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('CeraVe',      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/CeraVe_logo.svg/320px-CeraVe_logo.svg.png', SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('The Ordinary','https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/The_Ordinary_logo.svg/320px-The_Ordinary_logo.svg.png', SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('Neutrogena',  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Neutrogena_logo.svg/320px-Neutrogena_logo.svg.png', SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('Cetaphil',    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Cetaphil_logo.svg/320px-Cetaphil_logo.svg.png', SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('Aveeno',      'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Aveeno_logo.svg/320px-Aveeno_logo.svg.png', SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('L''Oréal',    NULL, SYSUTCDATETIME(), 1);
INSERT INTO dbo.Brand (name, barndimage, createdate, Isactive)
VALUES ('Tenzy',       NULL, SYSUTCDATETIME(), 1);
GO

-- Products (productid auto-increments starting at 1)
DECLARE @skincare_cat  INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Skin Care');
DECLARE @moisturizer   INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Moisturizers');
DECLARE @serum_cat     INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Serums');
DECLARE @cleanser_cat  INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Cleansers');
DECLARE @suncare_cat   INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Sun Care');
DECLARE @body_cat      INT = (SELECT TOP 1 catagoryID FROM dbo.Category WHERE categorytype = 'Body Care');

DECLARE @cerave   INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'CeraVe');
DECLARE @ordinary INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'The Ordinary');
DECLARE @neutro   INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'Neutrogena');
DECLARE @cetaphil INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'Cetaphil');
DECLARE @aveeno   INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'Aveeno');
DECLARE @tenzy    INT = (SELECT TOP 1 Brandid FROM dbo.Brand WHERE name = 'Tenzy');

-- Product 1: CeraVe Moisturizing Cream
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('CeraVe Moisturizing Cream', @cerave, @moisturizer,
        'A rich moisturizing cream with ceramides and hyaluronic acid to restore the skin''s natural barrier. Fragrance-free and non-comedogenic, suitable for dry to very dry skin.',
        250.0, 1, SYSUTCDATETIME());
DECLARE @p1 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p1, 45);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p1, 3200.00, 10.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p1, 'https://images.unsplash.com/photo-1620916566393-7c3a4a4f3f10?q=80&w=600', 1, 1);
INSERT INTO dbo.ProductFAQ       (productid, Question, Answer) VALUES (@p1, 'Is this suitable for sensitive skin?', 'Yes, CeraVe Moisturizing Cream is fragrance-free and developed with dermatologists, making it suitable for sensitive skin.');
INSERT INTO dbo.ProductFAQ       (productid, Question, Answer) VALUES (@p1, 'Can I use it on my face?', 'Yes, it is non-comedogenic and safe for facial use.');

-- Product 2: The Ordinary Hyaluronic Acid 2% + B5
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Hyaluronic Acid 2% + B5', @ordinary, @serum_cat,
        'Multi-depth hydration serum with low, medium and high molecular weight hyaluronic acid plus Vitamin B5 for immediate and lasting moisture.',
        30.0, 1, SYSUTCDATETIME());
DECLARE @p2 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p2, 60);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p2, 1850.00, 0.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p2, 'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?q=80&w=600', 1, 1);
INSERT INTO dbo.ProductFAQ       (productid, Question, Answer) VALUES (@p2, 'How often should I use this?', 'Apply twice daily, morning and evening, before moisturizer.');

-- Product 3: Neutrogena Hydro Boost Gel Cream
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Hydro Boost Gel Cream', @neutro, @moisturizer,
        'Oil-free gel-cream formula with hyaluronic acid that absorbs quickly to quench dry skin and keep it moisturised for 72 hours. Non-greasy, non-comedogenic.',
        50.0, 1, SYSUTCDATETIME());
DECLARE @p3 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p3, 38);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p3, 2750.00, 15.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p3, 'https://images.unsplash.com/photo-1629198726018-41b7b7a4b3b2?q=80&w=600', 1, 1);

-- Product 4: CeraVe Foaming Facial Cleanser
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Foaming Facial Cleanser', @cerave, @cleanser_cat,
        'Gentle foaming face wash for normal to oily skin. With ceramides, niacinamide and hyaluronic acid to remove dirt and oil without disrupting the skin barrier.',
        473.0, 1, SYSUTCDATETIME());
DECLARE @p4 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p4, 55);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p4, 2100.00, 0.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p4, 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?q=80&w=600', 1, 1);

-- Product 5: Neutrogena Ultra Sheer SPF 50+
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Ultra Sheer Dry-Touch SPF 50+', @neutro, @suncare_cat,
        'Lightweight, fast-absorbing sunscreen with Helioplex technology for broad-spectrum UVA/UVB protection. Non-greasy, water-resistant for 80 minutes.',
        88.0, 1, SYSUTCDATETIME());
DECLARE @p5 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p5, 42);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p5, 2900.00, 5.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p5, 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?q=80&w=600', 1, 1);

-- Product 6: Cetaphil Gentle Skin Cleanser
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Gentle Skin Cleanser', @cetaphil, @cleanser_cat,
        'Soap-free, fragrance-free gentle cleanser for all skin types. Removes impurities without stripping the skin of its natural moisture.',
        500.0, 1, SYSUTCDATETIME());
DECLARE @p6 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p6, 70);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p6, 1650.00, 0.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p6, 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?q=80&w=600', 1, 1);

-- Product 7: Aveeno Daily Moisturising Lotion
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Daily Moisturising Lotion', @aveeno, @body_cat,
        'Lightweight body lotion with natural colloidal oatmeal and rich emollients that moisturise and soothe dry, sensitive skin 24 hours a day. Fragrance-free.',
        532.0, 1, SYSUTCDATETIME());
DECLARE @p7 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p7, 50);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p7, 3500.00, 0.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p7, 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?q=80&w=600', 1, 1);

-- Product 8: Vitamin C Brightening Serum (Tenzy)
INSERT INTO dbo.ProductCatalog (name, brandid, categoryid, description, weight, insale, createdate)
VALUES ('Vitamin C Brightening Serum', @tenzy, @serum_cat,
        'Potent 20% Vitamin C serum with ferulic acid and hyaluronic acid to brighten skin, fade dark spots and protect against environmental damage. Paraben-free.',
        30.0, 1, SYSUTCDATETIME());
DECLARE @p8 INT = SCOPE_IDENTITY();
INSERT INTO dbo.ProductInventory (ProductId, stock) VALUES (@p8, 25);
INSERT INTO dbo.ProductPricing   (ProductId, price, discountrate, StartUTC) VALUES (@p8, 4200.00, 20.00, SYSUTCDATETIME());
INSERT INTO dbo.ProductImages    (productid, ImageUrl, IsPrimary, SortOrder) VALUES (@p8, 'https://images.unsplash.com/photo-1620916566393-7c3a4a4f3f10?q=80&w=600', 1, 1);
INSERT INTO dbo.ProductFAQ       (productid, Question, Answer) VALUES (@p8, 'Does this serum oxidise quickly?', 'It contains ferulic acid as a stabiliser. Store in a cool, dark place and use within 3 months of opening.');

GO

PRINT 'Seed data inserted successfully.';
GO

PRINT 'TenzyShop schema created successfully — all tables and stored procedures ready.';
GO
