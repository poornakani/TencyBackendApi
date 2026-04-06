USE [tenzyuk_production];
GO

DROP PROCEDURE IF EXISTS dbo.spProcurementOrder_GetAll;
DROP PROCEDURE IF EXISTS dbo.spProcurementOrder_GetById;
DROP PROCEDURE IF EXISTS dbo.spProcurementOrder_Insert;
DROP PROCEDURE IF EXISTS dbo.spProcurementItem_Insert;
DROP PROCEDURE IF EXISTS dbo.spProcurementOrder_UpdateStatus;
DROP PROCEDURE IF EXISTS dbo.spDispatch_GetPending;
DROP PROCEDURE IF EXISTS dbo.spDispatch_Upsert;
DROP PROCEDURE IF EXISTS dbo.spDispatch_MarkDelivered;

DROP PROCEDURE IF EXISTS dbo.spSupplyDashboard_GetSummary;
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurement_GetAll;
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurement_GetById;
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurement_Save;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_GetAll;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_GetById;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_Save;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_AddCharge;
DROP PROCEDURE IF EXISTS dbo.spSupplyArrival_GetAll;
DROP PROCEDURE IF EXISTS dbo.spSupplyArrival_GetById;
DROP PROCEDURE IF EXISTS dbo.spSupplyArrival_Save;
DROP PROCEDURE IF EXISTS dbo.spSupplyPricing_GetEligible;
DROP PROCEDURE IF EXISTS dbo.spSupplyPricing_GetAll;
DROP PROCEDURE IF EXISTS dbo.spSupplyPricing_Save;
DROP PROCEDURE IF EXISTS dbo.spSupplyReport_Procurement;
DROP PROCEDURE IF EXISTS dbo.spSupplyReport_Dispatch;
DROP PROCEDURE IF EXISTS dbo.spSupplyReport_MonthlyDispatchSummary;
GO

IF OBJECT_ID('dbo.Dispatch', 'U') IS NOT NULL DROP TABLE dbo.Dispatch;
IF OBJECT_ID('dbo.ProcurementItems', 'U') IS NOT NULL DROP TABLE dbo.ProcurementItems;
IF OBJECT_ID('dbo.ProcurementOrders', 'U') IS NOT NULL DROP TABLE dbo.ProcurementOrders;

IF OBJECT_ID('dbo.SupplyPricing', 'U') IS NOT NULL DROP TABLE dbo.SupplyPricing;
IF OBJECT_ID('dbo.SupplyArrivalItems', 'U') IS NOT NULL DROP TABLE dbo.SupplyArrivalItems;
IF OBJECT_ID('dbo.SupplyArrivalVerifications', 'U') IS NOT NULL DROP TABLE dbo.SupplyArrivalVerifications;
IF OBJECT_ID('dbo.SupplyShipmentCharges', 'U') IS NOT NULL DROP TABLE dbo.SupplyShipmentCharges;
IF OBJECT_ID('dbo.SupplyShipmentItems', 'U') IS NOT NULL DROP TABLE dbo.SupplyShipmentItems;
IF OBJECT_ID('dbo.SupplyShipments', 'U') IS NOT NULL DROP TABLE dbo.SupplyShipments;
IF OBJECT_ID('dbo.SupplyProcurementDiscountAllocations', 'U') IS NOT NULL DROP TABLE dbo.SupplyProcurementDiscountAllocations;
IF OBJECT_ID('dbo.SupplyProcurementDiscounts', 'U') IS NOT NULL DROP TABLE dbo.SupplyProcurementDiscounts;
IF OBJECT_ID('dbo.SupplyProcurementItems', 'U') IS NOT NULL DROP TABLE dbo.SupplyProcurementItems;
IF OBJECT_ID('dbo.SupplyProcurements', 'U') IS NOT NULL DROP TABLE dbo.SupplyProcurements;
GO

CREATE TABLE dbo.SupplyProcurements (
    ProcurementId INT IDENTITY(1,1) PRIMARY KEY,
    ProcurementReference NVARCHAR(50) NOT NULL,
    ShopName NVARCHAR(150) NOT NULL,
    PurchaseDate DATETIME2 NOT NULL,
    InvoiceReference NVARCHAR(120) NOT NULL,
    Status NVARCHAR(30) NOT NULL CONSTRAINT DF_SupplyProcurements_Status DEFAULT ('procured'),
    PurchaseNote NVARCHAR(500) NULL,
    EnteredByUserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyProcurements_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc DATETIME2 NULL
);
CREATE UNIQUE INDEX UX_SupplyProcurements_Reference ON dbo.SupplyProcurements(ProcurementReference);
CREATE INDEX IX_SupplyProcurements_PurchaseDate ON dbo.SupplyProcurements(PurchaseDate);
GO

CREATE TABLE dbo.SupplyProcurementItems (
    ProcurementItemId INT IDENTITY(1,1) PRIMARY KEY,
    ProcurementId INT NOT NULL,
    LineNumber INT NOT NULL,
    ProductId INT NULL,
    ProductName NVARCHAR(250) NOT NULL,
    BrandName NVARCHAR(150) NOT NULL,
    CategoryName NVARCHAR(150) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,
    GrossTotal DECIMAL(18,2) NOT NULL,
    DiscountTotal DECIMAL(18,2) NOT NULL,
    NetTotal DECIMAL(18,2) NOT NULL,
    NetUnitCost DECIMAL(18,2) NOT NULL,
    BatchNote NVARCHAR(250) NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyProcurementItems_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyProcurementItems_Procurements FOREIGN KEY (ProcurementId) REFERENCES dbo.SupplyProcurements(ProcurementId) ON DELETE CASCADE
);
CREATE UNIQUE INDEX UX_SupplyProcurementItems_Line ON dbo.SupplyProcurementItems(ProcurementId, LineNumber);
GO

CREATE TABLE dbo.SupplyProcurementDiscounts (
    DiscountId INT IDENTITY(1,1) PRIMARY KEY,
    ProcurementId INT NOT NULL,
    DiscountCode NVARCHAR(50) NOT NULL,
    DiscountType NVARCHAR(50) NOT NULL,
    DiscountScope NVARCHAR(50) NOT NULL,
    Description NVARCHAR(250) NULL,
    TargetProductName NVARCHAR(250) NULL,
    TargetBrandName NVARCHAR(150) NULL,
    TargetShopName NVARCHAR(150) NULL,
    BuyQuantity INT NULL,
    PayQuantity INT NULL,
    Percentage DECIMAL(18,2) NULL,
    FixedAmount DECIMAL(18,2) NULL,
    DiscountAmount DECIMAL(18,2) NOT NULL,
    Notes NVARCHAR(250) NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyProcurementDiscounts_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyProcurementDiscounts_Procurements FOREIGN KEY (ProcurementId) REFERENCES dbo.SupplyProcurements(ProcurementId) ON DELETE CASCADE
);
CREATE UNIQUE INDEX UX_SupplyProcurementDiscounts_Code ON dbo.SupplyProcurementDiscounts(ProcurementId, DiscountCode);
GO

CREATE TABLE dbo.SupplyProcurementDiscountAllocations (
    DiscountAllocationId INT IDENTITY(1,1) PRIMARY KEY,
    DiscountId INT NOT NULL,
    ProcurementItemId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyProcurementDiscountAllocations_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyProcurementDiscountAllocations_Discounts FOREIGN KEY (DiscountId) REFERENCES dbo.SupplyProcurementDiscounts(DiscountId) ON DELETE CASCADE,
    CONSTRAINT FK_SupplyProcurementDiscountAllocations_Items FOREIGN KEY (ProcurementItemId) REFERENCES dbo.SupplyProcurementItems(ProcurementItemId)
);
GO

CREATE TABLE dbo.SupplyShipments (
    ShipmentId INT IDENTITY(1,1) PRIMARY KEY,
    DispatchReference NVARCHAR(50) NOT NULL,
    DispatchDate DATETIME2 NOT NULL,
    CourierName NVARCHAR(150) NOT NULL,
    ParcelNumber NVARCHAR(120) NOT NULL,
    ShipmentStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_SupplyShipments_Status DEFAULT ('pending'),
    Notes NVARCHAR(500) NULL,
    CreatedByUserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyShipments_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc DATETIME2 NULL
);
CREATE UNIQUE INDEX UX_SupplyShipments_Reference ON dbo.SupplyShipments(DispatchReference);
GO

CREATE TABLE dbo.SupplyShipmentItems (
    ShipmentItemId INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentId INT NOT NULL,
    ProcurementItemId INT NOT NULL,
    ProcurementId INT NOT NULL,
    ProductId INT NULL,
    ProductName NVARCHAR(250) NOT NULL,
    BrandName NVARCHAR(150) NOT NULL,
    CategoryName NVARCHAR(150) NOT NULL,
    QuantityDispatched INT NOT NULL,
    NetUnitCost DECIMAL(18,2) NOT NULL,
    NetAmount DECIMAL(18,2) NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyShipmentItems_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyShipmentItems_Shipments FOREIGN KEY (ShipmentId) REFERENCES dbo.SupplyShipments(ShipmentId) ON DELETE CASCADE,
    CONSTRAINT FK_SupplyShipmentItems_ProcurementItems FOREIGN KEY (ProcurementItemId) REFERENCES dbo.SupplyProcurementItems(ProcurementItemId)
);
GO

CREATE TABLE dbo.SupplyShipmentCharges (
    ShipmentChargeId INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentId INT NOT NULL,
    ChargeType NVARCHAR(50) NOT NULL,
    CurrencyCode NVARCHAR(10) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    ChargeDate DATETIME2 NOT NULL,
    Notes NVARCHAR(250) NULL,
    EnteredByUserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyShipmentCharges_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyShipmentCharges_Shipments FOREIGN KEY (ShipmentId) REFERENCES dbo.SupplyShipments(ShipmentId) ON DELETE CASCADE
);
GO

CREATE TABLE dbo.SupplyArrivalVerifications (
    ArrivalVerificationId INT IDENTITY(1,1) PRIMARY KEY,
    ShipmentId INT NOT NULL,
    VerificationDate DATETIME2 NOT NULL,
    VerificationStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_SupplyArrivalVerifications_Status DEFAULT ('received'),
    Notes NVARCHAR(500) NULL,
    VerifiedByUserId UNIQUEIDENTIFIER NOT NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyArrivalVerifications_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc DATETIME2 NULL,
    CONSTRAINT FK_SupplyArrivalVerifications_Shipments FOREIGN KEY (ShipmentId) REFERENCES dbo.SupplyShipments(ShipmentId)
);
GO

CREATE TABLE dbo.SupplyArrivalItems (
    ArrivalItemId INT IDENTITY(1,1) PRIMARY KEY,
    ArrivalVerificationId INT NOT NULL,
    ShipmentItemId INT NOT NULL,
    ProcurementItemId INT NOT NULL,
    ProductId INT NULL,
    ProductName NVARCHAR(250) NOT NULL,
    BrandName NVARCHAR(150) NOT NULL,
    CategoryName NVARCHAR(150) NOT NULL,
    QuantityDispatched INT NOT NULL,
    QuantityReceived INT NOT NULL,
    ApprovedQuantity INT NOT NULL,
    MissingQuantity INT NOT NULL,
    ExtraQuantity INT NOT NULL,
    DamagedQuantity INT NOT NULL,
    ApprovedForPricing BIT NOT NULL,
    Notes NVARCHAR(250) NULL,
    CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyArrivalItems_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_SupplyArrivalItems_Arrival FOREIGN KEY (ArrivalVerificationId) REFERENCES dbo.SupplyArrivalVerifications(ArrivalVerificationId) ON DELETE CASCADE,
    CONSTRAINT FK_SupplyArrivalItems_ShipmentItems FOREIGN KEY (ShipmentItemId) REFERENCES dbo.SupplyShipmentItems(ShipmentItemId)
);
GO

CREATE TABLE dbo.SupplyPricing (
    PricingId INT IDENTITY(1,1) PRIMARY KEY,
    ArrivalItemId INT NOT NULL,
    SellingPrice DECIMAL(18,2) NOT NULL,
    CustomerDiscountPercent DECIMAL(18,2) NOT NULL CONSTRAINT DF_SupplyPricing_DiscountPct DEFAULT (0),
    CustomerDiscountAmount DECIMAL(18,2) NOT NULL CONSTRAINT DF_SupplyPricing_DiscountAmt DEFAULT (0),
    FinalSellingPrice DECIMAL(18,2) NOT NULL,
    MarkupPercent DECIMAL(18,2) NOT NULL,
    MarginPercent DECIMAL(18,2) NOT NULL,
    PricingNotes NVARCHAR(500) NULL,
    IsApproved BIT NOT NULL CONSTRAINT DF_SupplyPricing_Approved DEFAULT (1),
    ApprovedByUserId UNIQUEIDENTIFIER NOT NULL,
    ApprovedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_SupplyPricing_ApprovedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAtUtc DATETIME2 NULL,
    CONSTRAINT FK_SupplyPricing_ArrivalItems FOREIGN KEY (ArrivalItemId) REFERENCES dbo.SupplyArrivalItems(ArrivalItemId)
);
CREATE UNIQUE INDEX UX_SupplyPricing_ArrivalItemId ON dbo.SupplyPricing(ArrivalItemId);
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyDashboard_GetSummary
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ProcurementCount = COUNT(*),
        ProcurementNetTotal = ISNULL(SUM(p.TotalNetAmount), 0),
        ActiveShipmentCount = (SELECT COUNT(*) FROM dbo.SupplyShipments WHERE ShipmentStatus <> 'received'),
        ShipmentChargeTotal = ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges), 0),
        AwaitingVerificationCount = (SELECT COUNT(*) FROM dbo.SupplyShipments s WHERE NOT EXISTS (SELECT 1 FROM dbo.SupplyArrivalVerifications av WHERE av.ShipmentId = s.ShipmentId)),
        EligiblePricingCount = (SELECT COUNT(*) FROM dbo.SupplyArrivalItems ai WHERE ai.ApprovedForPricing = 1 AND ai.ApprovedQuantity > 0),
        PricingValueTotal = ISNULL((SELECT SUM(FinalSellingPrice * ai.ApprovedQuantity) FROM dbo.SupplyPricing sp INNER JOIN dbo.SupplyArrivalItems ai ON ai.ArrivalItemId = sp.ArrivalItemId WHERE sp.IsApproved = 1), 0)
    FROM (
        SELECT sp.ProcurementId, SUM(ISNULL(i.NetTotal, 0)) AS TotalNetAmount
        FROM dbo.SupplyProcurements sp
        LEFT JOIN dbo.SupplyProcurementItems i ON i.ProcurementId = sp.ProcurementId
        GROUP BY sp.ProcurementId
    ) p;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyProcurement_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProcurementId,
        p.ProcurementReference,
        p.ShopName,
        p.PurchaseDate,
        p.InvoiceReference,
        p.Status,
        p.PurchaseNote,
        TotalGrossAmount = ISNULL(SUM(i.GrossTotal), 0),
        TotalDiscountAmount = ISNULL(SUM(i.DiscountTotal), 0),
        TotalNetAmount = ISNULL(SUM(i.NetTotal), 0),
        ItemCount = COUNT(i.ProcurementItemId)
    FROM dbo.SupplyProcurements p
    LEFT JOIN dbo.SupplyProcurementItems i ON i.ProcurementId = p.ProcurementId
    GROUP BY p.ProcurementId, p.ProcurementReference, p.ShopName, p.PurchaseDate, p.InvoiceReference, p.Status, p.PurchaseNote
    ORDER BY p.PurchaseDate DESC, p.ProcurementId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyProcurement_GetById
    @ProcurementId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        p.ProcurementId,
        p.ProcurementReference,
        p.ShopName,
        p.PurchaseDate,
        p.InvoiceReference,
        p.Status,
        p.PurchaseNote,
        p.EnteredByUserId,
        p.CreatedAtUtc,
        TotalGrossAmount = ISNULL((SELECT SUM(GrossTotal) FROM dbo.SupplyProcurementItems WHERE ProcurementId = p.ProcurementId), 0),
        TotalDiscountAmount = ISNULL((SELECT SUM(DiscountTotal) FROM dbo.SupplyProcurementItems WHERE ProcurementId = p.ProcurementId), 0),
        TotalNetAmount = ISNULL((SELECT SUM(NetTotal) FROM dbo.SupplyProcurementItems WHERE ProcurementId = p.ProcurementId), 0),
        ItemCount = ISNULL((SELECT COUNT(*) FROM dbo.SupplyProcurementItems WHERE ProcurementId = p.ProcurementId), 0)
    FROM dbo.SupplyProcurements p
    WHERE p.ProcurementId = @ProcurementId;

    SELECT
        ProcurementItemId,
        LineNumber,
        ProductId,
        ProductName,
        BrandName,
        CategoryName,
        Quantity,
        UnitPrice,
        GrossTotal,
        DiscountTotal,
        NetTotal,
        NetUnitCost,
        BatchNote
    FROM dbo.SupplyProcurementItems
    WHERE ProcurementId = @ProcurementId
    ORDER BY LineNumber;

    SELECT
        DiscountId,
        DiscountCode,
        DiscountType,
        DiscountScope,
        Description,
        TargetProductName,
        TargetBrandName,
        TargetShopName,
        BuyQuantity,
        PayQuantity,
        Percentage,
        FixedAmount,
        DiscountAmount,
        Notes
    FROM dbo.SupplyProcurementDiscounts
    WHERE ProcurementId = @ProcurementId
    ORDER BY DiscountId;

    SELECT
        a.DiscountId,
        a.ProcurementItemId,
        i.LineNumber,
        a.Amount
    FROM dbo.SupplyProcurementDiscountAllocations a
    INNER JOIN dbo.SupplyProcurementItems i ON i.ProcurementItemId = a.ProcurementItemId
    INNER JOIN dbo.SupplyProcurementDiscounts d ON d.DiscountId = a.DiscountId
    WHERE d.ProcurementId = @ProcurementId
    ORDER BY a.DiscountAllocationId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyProcurement_Save
    @ProcurementId INT = NULL,
    @ProcurementReference NVARCHAR(50),
    @ShopName NVARCHAR(150),
    @PurchaseDate DATETIME2,
    @InvoiceReference NVARCHAR(120),
    @PurchaseNote NVARCHAR(500) = NULL,
    @EnteredByUserId UNIQUEIDENTIFIER,
    @ItemsJson NVARCHAR(MAX),
    @DiscountsJson NVARCHAR(MAX),
    @AllocationsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    IF @ProcurementId IS NULL
    BEGIN
        INSERT INTO dbo.SupplyProcurements (ProcurementReference, ShopName, PurchaseDate, InvoiceReference, PurchaseNote, EnteredByUserId)
        VALUES (@ProcurementReference, @ShopName, @PurchaseDate, @InvoiceReference, @PurchaseNote, @EnteredByUserId);

        SET @ProcurementId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.SupplyProcurements
        SET ProcurementReference = @ProcurementReference,
            ShopName = @ShopName,
            PurchaseDate = @PurchaseDate,
            InvoiceReference = @InvoiceReference,
            PurchaseNote = @PurchaseNote,
            UpdatedAtUtc = SYSUTCDATETIME()
        WHERE ProcurementId = @ProcurementId;

        DELETE a
        FROM dbo.SupplyProcurementDiscountAllocations a
        INNER JOIN dbo.SupplyProcurementDiscounts d ON d.DiscountId = a.DiscountId
        WHERE d.ProcurementId = @ProcurementId;

        DELETE FROM dbo.SupplyProcurementDiscounts WHERE ProcurementId = @ProcurementId;
        DELETE FROM dbo.SupplyProcurementItems WHERE ProcurementId = @ProcurementId;
    END

    DECLARE @InsertedItems TABLE (ProcurementItemId INT, LineNumber INT);
    INSERT INTO dbo.SupplyProcurementItems
    (
        ProcurementId, LineNumber, ProductId, ProductName, BrandName, CategoryName,
        Quantity, UnitPrice, GrossTotal, DiscountTotal, NetTotal, NetUnitCost, BatchNote
    )
    OUTPUT inserted.ProcurementItemId, inserted.LineNumber INTO @InsertedItems (ProcurementItemId, LineNumber)
    SELECT
        @ProcurementId,
        LineNumber,
        ProductId,
        ProductName,
        ISNULL(BrandName, ''),
        ISNULL(CategoryName, ''),
        Quantity,
        UnitPrice,
        GrossTotal,
        DiscountTotal,
        NetTotal,
        NetUnitCost,
        BatchNote
    FROM OPENJSON(@ItemsJson)
    WITH
    (
        LineNumber INT '$.lineNumber',
        ProductId INT '$.productId',
        ProductName NVARCHAR(250) '$.productName',
        BrandName NVARCHAR(150) '$.brandName',
        CategoryName NVARCHAR(150) '$.categoryName',
        Quantity INT '$.quantity',
        UnitPrice DECIMAL(18,2) '$.unitPrice',
        GrossTotal DECIMAL(18,2) '$.grossTotal',
        DiscountTotal DECIMAL(18,2) '$.discountTotal',
        NetTotal DECIMAL(18,2) '$.netTotal',
        NetUnitCost DECIMAL(18,2) '$.netUnitCost',
        BatchNote NVARCHAR(250) '$.batchNote'
    );

    DECLARE @InsertedDiscounts TABLE (DiscountId INT, DiscountCode NVARCHAR(50));
    INSERT INTO dbo.SupplyProcurementDiscounts
    (
        ProcurementId, DiscountCode, DiscountType, DiscountScope, Description, TargetProductName,
        TargetBrandName, TargetShopName, BuyQuantity, PayQuantity, Percentage, FixedAmount,
        DiscountAmount, Notes
    )
    OUTPUT inserted.DiscountId, inserted.DiscountCode INTO @InsertedDiscounts (DiscountId, DiscountCode)
    SELECT
        @ProcurementId,
        DiscountCode,
        DiscountType,
        DiscountScope,
        Description,
        TargetProductName,
        TargetBrandName,
        TargetShopName,
        BuyQuantity,
        PayQuantity,
        Percentage,
        FixedAmount,
        DiscountAmount,
        Notes
    FROM OPENJSON(@DiscountsJson)
    WITH
    (
        DiscountCode NVARCHAR(50) '$.discountCode',
        DiscountType NVARCHAR(50) '$.discountType',
        DiscountScope NVARCHAR(50) '$.discountScope',
        Description NVARCHAR(250) '$.description',
        TargetProductName NVARCHAR(250) '$.targetProductName',
        TargetBrandName NVARCHAR(150) '$.targetBrandName',
        TargetShopName NVARCHAR(150) '$.targetShopName',
        BuyQuantity INT '$.buyQuantity',
        PayQuantity INT '$.payQuantity',
        Percentage DECIMAL(18,2) '$.percentage',
        FixedAmount DECIMAL(18,2) '$.fixedAmount',
        DiscountAmount DECIMAL(18,2) '$.discountAmount',
        Notes NVARCHAR(250) '$.notes'
    );

    INSERT INTO dbo.SupplyProcurementDiscountAllocations (DiscountId, ProcurementItemId, Amount)
    SELECT
        d.DiscountId,
        i.ProcurementItemId,
        a.Amount
    FROM OPENJSON(@AllocationsJson)
    WITH
    (
        DiscountCode NVARCHAR(50) '$.discountCode',
        LineNumber INT '$.lineNumber',
        Amount DECIMAL(18,2) '$.amount'
    ) a
    INNER JOIN @InsertedDiscounts d ON d.DiscountCode = a.DiscountCode
    INNER JOIN @InsertedItems i ON i.LineNumber = a.LineNumber;

    COMMIT TRAN;
    SELECT @ProcurementId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyDispatch_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.ShipmentId,
        s.DispatchReference,
        s.DispatchDate,
        s.CourierName,
        s.ParcelNumber,
        s.ShipmentStatus,
        s.Notes,
        TotalProductCost = ISNULL((SELECT SUM(NetAmount) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0),
        TotalShipmentCharges = ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges WHERE ShipmentId = s.ShipmentId), 0),
        TotalLandedCost = ISNULL((SELECT SUM(NetAmount) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0)
                        + ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges WHERE ShipmentId = s.ShipmentId), 0),
        TotalQuantity = ISNULL((SELECT SUM(QuantityDispatched) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0)
    FROM dbo.SupplyShipments s
    ORDER BY s.DispatchDate DESC, s.ShipmentId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyDispatch_GetById
    @ShipmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        s.ShipmentId,
        s.DispatchReference,
        s.DispatchDate,
        s.CourierName,
        s.ParcelNumber,
        s.ShipmentStatus,
        s.Notes,
        TotalProductCost = ISNULL((SELECT SUM(NetAmount) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0),
        TotalShipmentCharges = ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges WHERE ShipmentId = s.ShipmentId), 0),
        TotalLandedCost = ISNULL((SELECT SUM(NetAmount) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0)
                        + ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges WHERE ShipmentId = s.ShipmentId), 0),
        TotalQuantity = ISNULL((SELECT SUM(QuantityDispatched) FROM dbo.SupplyShipmentItems WHERE ShipmentId = s.ShipmentId), 0)
    FROM dbo.SupplyShipments s
    WHERE s.ShipmentId = @ShipmentId;

    SELECT
        ShipmentItemId,
        ShipmentId,
        ProcurementItemId,
        ProcurementId,
        ProductId,
        ProductName,
        BrandName,
        CategoryName,
        QuantityDispatched,
        NetUnitCost,
        NetAmount
    FROM dbo.SupplyShipmentItems
    WHERE ShipmentId = @ShipmentId
    ORDER BY ShipmentItemId;

    SELECT
        ShipmentChargeId,
        ShipmentId,
        ChargeType,
        CurrencyCode,
        Amount,
        ChargeDate,
        Notes
    FROM dbo.SupplyShipmentCharges
    WHERE ShipmentId = @ShipmentId
    ORDER BY ChargeDate, ShipmentChargeId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyDispatch_Save
    @ShipmentId INT = NULL,
    @DispatchReference NVARCHAR(50),
    @DispatchDate DATETIME2,
    @CourierName NVARCHAR(150),
    @ParcelNumber NVARCHAR(120),
    @ShipmentStatus NVARCHAR(30),
    @Notes NVARCHAR(500) = NULL,
    @CreatedByUserId UNIQUEIDENTIFIER,
    @ItemsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    IF @ShipmentId IS NULL
    BEGIN
        INSERT INTO dbo.SupplyShipments (DispatchReference, DispatchDate, CourierName, ParcelNumber, ShipmentStatus, Notes, CreatedByUserId)
        VALUES (@DispatchReference, @DispatchDate, @CourierName, @ParcelNumber, @ShipmentStatus, @Notes, @CreatedByUserId);

        SET @ShipmentId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.SupplyShipments
        SET DispatchReference = @DispatchReference,
            DispatchDate = @DispatchDate,
            CourierName = @CourierName,
            ParcelNumber = @ParcelNumber,
            ShipmentStatus = @ShipmentStatus,
            Notes = @Notes,
            UpdatedAtUtc = SYSUTCDATETIME()
        WHERE ShipmentId = @ShipmentId;

        DELETE FROM dbo.SupplyShipmentItems WHERE ShipmentId = @ShipmentId;
    END

    INSERT INTO dbo.SupplyShipmentItems
    (
        ShipmentId, ProcurementItemId, ProcurementId, ProductId, ProductName, BrandName,
        CategoryName, QuantityDispatched, NetUnitCost, NetAmount
    )
    SELECT
        @ShipmentId,
        p.ProcurementItemId,
        p.ProcurementId,
        p.ProductId,
        p.ProductName,
        p.BrandName,
        p.CategoryName,
        j.QuantityDispatched,
        p.NetUnitCost,
        ROUND(j.QuantityDispatched * p.NetUnitCost, 2)
    FROM OPENJSON(@ItemsJson)
    WITH
    (
        ProcurementItemId INT '$.procurementItemId',
        QuantityDispatched INT '$.quantityDispatched'
    ) j
    INNER JOIN dbo.SupplyProcurementItems p ON p.ProcurementItemId = j.ProcurementItemId;

    UPDATE p
    SET Status = 'dispatched',
        UpdatedAtUtc = SYSUTCDATETIME()
    FROM dbo.SupplyProcurements p
    WHERE EXISTS (
        SELECT 1
        FROM dbo.SupplyShipmentItems si
        WHERE si.ShipmentId = @ShipmentId
          AND si.ProcurementId = p.ProcurementId
    );

    COMMIT TRAN;
    SELECT @ShipmentId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyDispatch_AddCharge
    @ShipmentId INT,
    @ChargeType NVARCHAR(50),
    @CurrencyCode NVARCHAR(10),
    @Amount DECIMAL(18,2),
    @ChargeDate DATETIME2,
    @Notes NVARCHAR(250) = NULL,
    @EnteredByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.SupplyShipmentCharges (ShipmentId, ChargeType, CurrencyCode, Amount, ChargeDate, Notes, EnteredByUserId)
    VALUES (@ShipmentId, @ChargeType, @CurrencyCode, @Amount, @ChargeDate, @Notes, @EnteredByUserId);

    SELECT CAST(SCOPE_IDENTITY() AS INT);
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyArrival_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        av.ArrivalVerificationId,
        av.ShipmentId,
        s.DispatchReference,
        av.VerificationDate,
        av.VerificationStatus,
        av.Notes,
        TotalApprovedQuantity = ISNULL(SUM(ai.ApprovedQuantity), 0),
        TotalDamagedQuantity = ISNULL(SUM(ai.DamagedQuantity), 0),
        TotalMissingQuantity = ISNULL(SUM(ai.MissingQuantity), 0)
    FROM dbo.SupplyArrivalVerifications av
    INNER JOIN dbo.SupplyShipments s ON s.ShipmentId = av.ShipmentId
    LEFT JOIN dbo.SupplyArrivalItems ai ON ai.ArrivalVerificationId = av.ArrivalVerificationId
    GROUP BY av.ArrivalVerificationId, av.ShipmentId, s.DispatchReference, av.VerificationDate, av.VerificationStatus, av.Notes
    ORDER BY av.VerificationDate DESC, av.ArrivalVerificationId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyArrival_GetById
    @ArrivalVerificationId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        av.ArrivalVerificationId,
        av.ShipmentId,
        s.DispatchReference,
        av.VerificationDate,
        av.VerificationStatus,
        av.Notes,
        TotalApprovedQuantity = ISNULL((SELECT SUM(ApprovedQuantity) FROM dbo.SupplyArrivalItems WHERE ArrivalVerificationId = av.ArrivalVerificationId), 0),
        TotalDamagedQuantity = ISNULL((SELECT SUM(DamagedQuantity) FROM dbo.SupplyArrivalItems WHERE ArrivalVerificationId = av.ArrivalVerificationId), 0),
        TotalMissingQuantity = ISNULL((SELECT SUM(MissingQuantity) FROM dbo.SupplyArrivalItems WHERE ArrivalVerificationId = av.ArrivalVerificationId), 0)
    FROM dbo.SupplyArrivalVerifications av
    INNER JOIN dbo.SupplyShipments s ON s.ShipmentId = av.ShipmentId
    WHERE av.ArrivalVerificationId = @ArrivalVerificationId;

    ;WITH ShipmentChargeBase AS (
        SELECT
            si.ShipmentItemId,
            si.ShipmentId,
            si.NetUnitCost,
            si.QuantityDispatched,
            si.NetAmount,
            TotalNetAmount = SUM(si.NetAmount) OVER (PARTITION BY si.ShipmentId),
            TotalChargeAmount = ISNULL((SELECT SUM(sc.Amount) FROM dbo.SupplyShipmentCharges sc WHERE sc.ShipmentId = si.ShipmentId), 0)
        FROM dbo.SupplyShipmentItems si
    )
    SELECT
        ai.ArrivalItemId,
        ai.ShipmentItemId,
        ai.ProcurementItemId,
        ai.ProductName,
        ai.BrandName,
        ai.CategoryName,
        ai.QuantityDispatched,
        ai.QuantityReceived,
        ai.ApprovedQuantity,
        ai.MissingQuantity,
        ai.ExtraQuantity,
        ai.DamagedQuantity,
        ai.ApprovedForPricing,
        b.NetUnitCost,
        AllocatedShipmentCostPerUnit = CASE WHEN ai.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / ai.QuantityDispatched, 2) END,
        LandedUnitCost = b.NetUnitCost + CASE WHEN ai.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / ai.QuantityDispatched, 2) END,
        ai.Notes
    FROM dbo.SupplyArrivalItems ai
    INNER JOIN ShipmentChargeBase b ON b.ShipmentItemId = ai.ShipmentItemId
    WHERE ai.ArrivalVerificationId = @ArrivalVerificationId
    ORDER BY ai.ArrivalItemId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyArrival_Save
    @ArrivalVerificationId INT = NULL,
    @ShipmentId INT,
    @VerificationDate DATETIME2,
    @VerificationStatus NVARCHAR(30),
    @Notes NVARCHAR(500) = NULL,
    @VerifiedByUserId UNIQUEIDENTIFIER,
    @ItemsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    IF @ArrivalVerificationId IS NULL
    BEGIN
        INSERT INTO dbo.SupplyArrivalVerifications (ShipmentId, VerificationDate, VerificationStatus, Notes, VerifiedByUserId)
        VALUES (@ShipmentId, @VerificationDate, @VerificationStatus, @Notes, @VerifiedByUserId);

        SET @ArrivalVerificationId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.SupplyArrivalVerifications
        SET VerificationDate = @VerificationDate,
            VerificationStatus = @VerificationStatus,
            Notes = @Notes,
            UpdatedAtUtc = SYSUTCDATETIME()
        WHERE ArrivalVerificationId = @ArrivalVerificationId;

        DELETE FROM dbo.SupplyArrivalItems WHERE ArrivalVerificationId = @ArrivalVerificationId;
    END

    INSERT INTO dbo.SupplyArrivalItems
    (
        ArrivalVerificationId, ShipmentItemId, ProcurementItemId, ProductId, ProductName, BrandName, CategoryName,
        QuantityDispatched, QuantityReceived, ApprovedQuantity, MissingQuantity, ExtraQuantity, DamagedQuantity,
        ApprovedForPricing, Notes
    )
    SELECT
        @ArrivalVerificationId,
        si.ShipmentItemId,
        si.ProcurementItemId,
        si.ProductId,
        si.ProductName,
        si.BrandName,
        si.CategoryName,
        si.QuantityDispatched,
        j.QuantityReceived,
        j.ApprovedQuantity,
        j.MissingQuantity,
        j.ExtraQuantity,
        j.DamagedQuantity,
        j.ApprovedForPricing,
        j.Notes
    FROM OPENJSON(@ItemsJson)
    WITH
    (
        ShipmentItemId INT '$.shipmentItemId',
        QuantityReceived INT '$.quantityReceived',
        ApprovedQuantity INT '$.approvedQuantity',
        MissingQuantity INT '$.missingQuantity',
        ExtraQuantity INT '$.extraQuantity',
        DamagedQuantity INT '$.damagedQuantity',
        ApprovedForPricing BIT '$.approvedForPricing',
        Notes NVARCHAR(250) '$.notes'
    ) j
    INNER JOIN dbo.SupplyShipmentItems si ON si.ShipmentItemId = j.ShipmentItemId;

    UPDATE s
    SET ShipmentStatus = CASE WHEN @VerificationStatus IN ('received', 'completed') THEN 'received' ELSE @VerificationStatus END,
        UpdatedAtUtc = SYSUTCDATETIME()
    FROM dbo.SupplyShipments s
    WHERE s.ShipmentId = @ShipmentId;

    UPDATE p
    SET Status = CASE WHEN EXISTS (
            SELECT 1
            FROM dbo.SupplyShipmentItems si
            INNER JOIN dbo.SupplyArrivalItems ai ON ai.ShipmentItemId = si.ShipmentItemId
            WHERE si.ProcurementId = p.ProcurementId
              AND ai.ArrivalVerificationId = @ArrivalVerificationId
              AND ai.ApprovedForPricing = 1
              AND ai.ApprovedQuantity > 0
        ) THEN 'verified' ELSE p.Status END,
        UpdatedAtUtc = SYSUTCDATETIME()
    FROM dbo.SupplyProcurements p
    WHERE EXISTS (
        SELECT 1
        FROM dbo.SupplyShipmentItems si
        WHERE si.ShipmentId = @ShipmentId
          AND si.ProcurementId = p.ProcurementId
    );

    COMMIT TRAN;
    SELECT @ArrivalVerificationId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyPricing_GetEligible
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ShipmentChargeBase AS (
        SELECT
            si.ShipmentItemId,
            si.ShipmentId,
            si.ProcurementItemId,
            si.ProductId,
            si.ProductName,
            si.BrandName,
            si.CategoryName,
            si.QuantityDispatched,
            si.NetUnitCost,
            si.NetAmount,
            TotalNetAmount = SUM(si.NetAmount) OVER (PARTITION BY si.ShipmentId),
            TotalChargeAmount = ISNULL((SELECT SUM(sc.Amount) FROM dbo.SupplyShipmentCharges sc WHERE sc.ShipmentId = si.ShipmentId), 0)
        FROM dbo.SupplyShipmentItems si
    )
    SELECT
        ai.ArrivalItemId,
        b.ShipmentId,
        s.DispatchReference,
        b.ProductId,
        b.ProductName,
        b.BrandName,
        b.CategoryName,
        ai.ApprovedQuantity,
        LandedUnitCost = b.NetUnitCost + CASE WHEN b.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / b.QuantityDispatched, 2) END,
        LandedTotalCost = ai.ApprovedQuantity * (b.NetUnitCost + CASE WHEN b.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / b.QuantityDispatched, 2) END),
        IsPriced = CAST(CASE WHEN sp.PricingId IS NULL THEN 0 ELSE 1 END AS BIT)
    FROM dbo.SupplyArrivalItems ai
    INNER JOIN ShipmentChargeBase b ON b.ShipmentItemId = ai.ShipmentItemId
    INNER JOIN dbo.SupplyShipments s ON s.ShipmentId = b.ShipmentId
    LEFT JOIN dbo.SupplyPricing sp ON sp.ArrivalItemId = ai.ArrivalItemId
    WHERE ai.ApprovedForPricing = 1
      AND ai.ApprovedQuantity > 0
    ORDER BY s.DispatchDate DESC, ai.ArrivalItemId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyPricing_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ShipmentCostBase AS (
        SELECT
            si.ShipmentItemId,
            si.QuantityDispatched,
            si.NetUnitCost,
            si.NetAmount,
            TotalNetAmount = SUM(si.NetAmount) OVER (PARTITION BY si.ShipmentId),
            TotalChargeAmount = ISNULL((SELECT SUM(sc.Amount) FROM dbo.SupplyShipmentCharges sc WHERE sc.ShipmentId = si.ShipmentId), 0)
        FROM dbo.SupplyShipmentItems si
    )
    SELECT
        sp.PricingId,
        ai.ArrivalItemId,
        ai.ProductId,
        ai.ProductName,
        ai.BrandName,
        ai.CategoryName,
        ai.ApprovedQuantity,
        LandedUnitCost = base.NetUnitCost + CASE WHEN base.QuantityDispatched = 0 OR base.TotalNetAmount = 0 THEN 0 ELSE ROUND((base.TotalChargeAmount * (base.NetAmount / base.TotalNetAmount)) / base.QuantityDispatched, 2) END,
        sp.SellingPrice,
        sp.CustomerDiscountPercent,
        sp.CustomerDiscountAmount,
        sp.FinalSellingPrice,
        sp.MarkupPercent,
        sp.MarginPercent,
        sp.PricingNotes,
        sp.IsApproved,
        sp.ApprovedAtUtc
    FROM dbo.SupplyPricing sp
    INNER JOIN dbo.SupplyArrivalItems ai ON ai.ArrivalItemId = sp.ArrivalItemId
    INNER JOIN ShipmentCostBase base ON base.ShipmentItemId = ai.ShipmentItemId
    ORDER BY sp.ApprovedAtUtc DESC, sp.PricingId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyPricing_Save
    @PricingId INT = NULL,
    @ArrivalItemId INT,
    @SellingPrice DECIMAL(18,2),
    @CustomerDiscountPercent DECIMAL(18,2),
    @CustomerDiscountAmount DECIMAL(18,2),
    @PricingNotes NVARCHAR(500) = NULL,
    @IsApproved BIT,
    @ApprovedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LandedUnitCost DECIMAL(18,2);
    DECLARE @FinalSellingPrice DECIMAL(18,2);
    DECLARE @MarkupPercent DECIMAL(18,2);
    DECLARE @MarginPercent DECIMAL(18,2);

    ;WITH CostBase AS (
        SELECT
            ai.ArrivalItemId,
            LandedUnitCost = si.NetUnitCost + CASE WHEN si.QuantityDispatched = 0 OR totals.TotalNetAmount = 0 THEN 0 ELSE ROUND((totals.TotalChargeAmount * (si.NetAmount / totals.TotalNetAmount)) / si.QuantityDispatched, 2) END
        FROM dbo.SupplyArrivalItems ai
        INNER JOIN dbo.SupplyShipmentItems si ON si.ShipmentItemId = ai.ShipmentItemId
        INNER JOIN (
            SELECT
                ShipmentId,
                TotalNetAmount = SUM(NetAmount),
                TotalChargeAmount = ISNULL((SELECT SUM(Amount) FROM dbo.SupplyShipmentCharges sc WHERE sc.ShipmentId = ssi.ShipmentId), 0)
            FROM dbo.SupplyShipmentItems ssi
            GROUP BY ShipmentId
        ) totals ON totals.ShipmentId = si.ShipmentId
        WHERE ai.ArrivalItemId = @ArrivalItemId
    )
    SELECT @LandedUnitCost = LandedUnitCost FROM CostBase;

    SET @FinalSellingPrice = ROUND(@SellingPrice - ((@SellingPrice * @CustomerDiscountPercent) / 100.0) - @CustomerDiscountAmount, 2);
    SET @MarkupPercent = CASE WHEN @LandedUnitCost <= 0 THEN 0 ELSE ROUND(((@FinalSellingPrice - @LandedUnitCost) / @LandedUnitCost) * 100.0, 2) END;
    SET @MarginPercent = CASE WHEN @FinalSellingPrice <= 0 THEN 0 ELSE ROUND(((@FinalSellingPrice - @LandedUnitCost) / @FinalSellingPrice) * 100.0, 2) END;

    IF @PricingId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.SupplyPricing WHERE PricingId = @PricingId)
    BEGIN
        INSERT INTO dbo.SupplyPricing
        (
            ArrivalItemId, SellingPrice, CustomerDiscountPercent, CustomerDiscountAmount, FinalSellingPrice,
            MarkupPercent, MarginPercent, PricingNotes, IsApproved, ApprovedByUserId
        )
        VALUES
        (
            @ArrivalItemId, @SellingPrice, @CustomerDiscountPercent, @CustomerDiscountAmount, @FinalSellingPrice,
            @MarkupPercent, @MarginPercent, @PricingNotes, @IsApproved, @ApprovedByUserId
        );

        SELECT CAST(SCOPE_IDENTITY() AS INT);
        RETURN;
    END

    UPDATE dbo.SupplyPricing
    SET SellingPrice = @SellingPrice,
        CustomerDiscountPercent = @CustomerDiscountPercent,
        CustomerDiscountAmount = @CustomerDiscountAmount,
        FinalSellingPrice = @FinalSellingPrice,
        MarkupPercent = @MarkupPercent,
        MarginPercent = @MarginPercent,
        PricingNotes = @PricingNotes,
        IsApproved = @IsApproved,
        ApprovedByUserId = @ApprovedByUserId,
        UpdatedAtUtc = SYSUTCDATETIME(),
        ApprovedAtUtc = SYSUTCDATETIME()
    WHERE PricingId = @PricingId;

    SELECT @PricingId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyReport_Procurement
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL,
    @ShopName NVARCHAR(150) = NULL,
    @BrandName NVARCHAR(150) = NULL,
    @ProductName NVARCHAR(250) = NULL,
    @CategoryName NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProcurementReference,
        p.PurchaseDate,
        p.ShopName,
        p.InvoiceReference,
        i.ProductName,
        i.BrandName,
        i.CategoryName,
        i.Quantity,
        i.UnitPrice,
        i.GrossTotal,
        i.DiscountTotal,
        i.NetTotal,
        i.NetUnitCost,
        p.PurchaseNote
    FROM dbo.SupplyProcurements p
    INNER JOIN dbo.SupplyProcurementItems i ON i.ProcurementId = p.ProcurementId
    WHERE (@StartDate IS NULL OR p.PurchaseDate >= @StartDate)
      AND (@EndDate IS NULL OR p.PurchaseDate < DATEADD(DAY, 1, @EndDate))
      AND (@ShopName IS NULL OR p.ShopName = @ShopName)
      AND (@BrandName IS NULL OR i.BrandName = @BrandName)
      AND (@ProductName IS NULL OR i.ProductName = @ProductName)
      AND (@CategoryName IS NULL OR i.CategoryName = @CategoryName)
    ORDER BY p.PurchaseDate DESC, p.ProcurementId DESC, i.LineNumber;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyReport_Dispatch
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL,
    @CourierName NVARCHAR(150) = NULL,
    @BrandName NVARCHAR(150) = NULL,
    @ProductName NVARCHAR(250) = NULL,
    @CategoryName NVARCHAR(150) = NULL,
    @ShipmentStatus NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH ChargeSummary AS (
        SELECT
            ShipmentId,
            UkCourierCharge = SUM(CASE WHEN ChargeType = 'uk_courier' THEN Amount ELSE 0 END),
            SriLankaCourierCharge = SUM(CASE WHEN ChargeType = 'sl_courier' THEN Amount ELSE 0 END),
            TaxCharge = SUM(CASE WHEN ChargeType = 'tax' THEN Amount ELSE 0 END),
            AdditionalCharge = SUM(CASE WHEN ChargeType NOT IN ('uk_courier', 'sl_courier', 'tax') THEN Amount ELSE 0 END),
            TotalShipmentCharge = SUM(Amount)
        FROM dbo.SupplyShipmentCharges
        GROUP BY ShipmentId
    )
    SELECT
        s.DispatchReference,
        s.DispatchDate,
        s.CourierName,
        s.ParcelNumber,
        s.ShipmentStatus,
        si.ProductName,
        si.BrandName,
        si.CategoryName,
        si.QuantityDispatched,
        ProductCost = si.NetAmount,
        UkCourierCharge = ISNULL(c.UkCourierCharge, 0),
        SriLankaCourierCharge = ISNULL(c.SriLankaCourierCharge, 0),
        TaxCharge = ISNULL(c.TaxCharge, 0),
        AdditionalCharge = ISNULL(c.AdditionalCharge, 0),
        TotalShipmentCharge = ISNULL(c.TotalShipmentCharge, 0)
    FROM dbo.SupplyShipments s
    INNER JOIN dbo.SupplyShipmentItems si ON si.ShipmentId = s.ShipmentId
    LEFT JOIN ChargeSummary c ON c.ShipmentId = s.ShipmentId
    WHERE (@StartDate IS NULL OR s.DispatchDate >= @StartDate)
      AND (@EndDate IS NULL OR s.DispatchDate < DATEADD(DAY, 1, @EndDate))
      AND (@CourierName IS NULL OR s.CourierName = @CourierName)
      AND (@BrandName IS NULL OR si.BrandName = @BrandName)
      AND (@ProductName IS NULL OR si.ProductName = @ProductName)
      AND (@CategoryName IS NULL OR si.CategoryName = @CategoryName)
      AND (@ShipmentStatus IS NULL OR s.ShipmentStatus = @ShipmentStatus)
    ORDER BY s.DispatchDate DESC, s.ShipmentId DESC, si.ShipmentItemId;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyReport_MonthlyDispatchSummary
    @StartDate DATETIME2 = NULL,
    @EndDate DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;

    WITH ChargeSummary AS (
        SELECT
            ShipmentId,
            UkCourierCharge = SUM(CASE WHEN ChargeType = 'uk_courier' THEN Amount ELSE 0 END),
            SriLankaCourierCharge = SUM(CASE WHEN ChargeType = 'sl_courier' THEN Amount ELSE 0 END),
            TaxCharge = SUM(CASE WHEN ChargeType = 'tax' THEN Amount ELSE 0 END),
            AdditionalCharge = SUM(CASE WHEN ChargeType NOT IN ('uk_courier', 'sl_courier', 'tax') THEN Amount ELSE 0 END),
            TotalShipmentCharge = SUM(Amount)
        FROM dbo.SupplyShipmentCharges
        GROUP BY ShipmentId
    ),
    ShipmentBase AS (
        SELECT
            MonthKey = CONVERT(VARCHAR(7), s.DispatchDate, 120),
            s.ShipmentId,
            TotalProductsDispatched = SUM(si.QuantityDispatched),
            TotalProductCost = SUM(si.NetAmount),
            UkCourierCharge = ISNULL(MAX(c.UkCourierCharge), 0),
            SriLankaCourierCharge = ISNULL(MAX(c.SriLankaCourierCharge), 0),
            TaxCharge = ISNULL(MAX(c.TaxCharge), 0),
            AdditionalCharge = ISNULL(MAX(c.AdditionalCharge), 0),
            TotalShipmentCharge = ISNULL(MAX(c.TotalShipmentCharge), 0)
        FROM dbo.SupplyShipments s
        INNER JOIN dbo.SupplyShipmentItems si ON si.ShipmentId = s.ShipmentId
        LEFT JOIN ChargeSummary c ON c.ShipmentId = s.ShipmentId
        WHERE (@StartDate IS NULL OR s.DispatchDate >= @StartDate)
          AND (@EndDate IS NULL OR s.DispatchDate < DATEADD(DAY, 1, @EndDate))
        GROUP BY CONVERT(VARCHAR(7), s.DispatchDate, 120), s.ShipmentId
    )
    SELECT
        SummaryMonth = MonthKey,
        TotalShipments = COUNT(*),
        TotalProductsDispatched = SUM(TotalProductsDispatched),
        TotalProductCost = SUM(TotalProductCost),
        TotalUkCourierCost = SUM(UkCourierCharge),
        TotalSriLankaCourierCost = SUM(SriLankaCourierCharge),
        TotalTaxCharges = SUM(TaxCharge),
        TotalAdditionalCharges = SUM(AdditionalCharge),
        TotalShipmentCost = SUM(TotalShipmentCharge)
    FROM ShipmentBase
    GROUP BY MonthKey
    ORDER BY MonthKey DESC;
END;
GO
