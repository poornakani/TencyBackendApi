USE [tenzyuk_production];
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 012: Soft-delete + item-level updates for procurement & dispatch
-- ─────────────────────────────────────────────────────────────────────────────

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurementItem_SoftDelete;
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurementItem_Update;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatchItem_SoftDelete;
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatchItem_Update;
DROP PROCEDURE IF EXISTS dbo.spSupplyDeletedItems_GetAll;
GO

-- ── Add soft-delete columns to SupplyProcurementItems ────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SupplyProcurementItems')
      AND name = 'IsDeleted'
)
BEGIN
    ALTER TABLE dbo.SupplyProcurementItems
        ADD IsDeleted BIT NOT NULL CONSTRAINT DF_SupplyProcurementItems_IsDeleted DEFAULT (0),
            DeletedAtUtc DATETIME2 NULL,
            DeletedByUserId UNIQUEIDENTIFIER NULL,
            DeletionReason NVARCHAR(500) NULL;
END
GO

-- ── Add soft-delete columns to SupplyShipmentItems ───────────────────────────
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SupplyShipmentItems')
      AND name = 'IsDeleted'
)
BEGIN
    ALTER TABLE dbo.SupplyShipmentItems
        ADD IsDeleted BIT NOT NULL CONSTRAINT DF_SupplyShipmentItems_IsDeleted DEFAULT (0),
            DeletedAtUtc DATETIME2 NULL,
            DeletedByUserId UNIQUEIDENTIFIER NULL,
            DeletionReason NVARCHAR(500) NULL;
END
GO

-- ── Deleted-item audit log table ──────────────────────────────────────────────
IF OBJECT_ID('dbo.SupplyDeletedItemsLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupplyDeletedItemsLog (
        LogId          INT IDENTITY(1,1) PRIMARY KEY,
        TableName      NVARCHAR(100) NOT NULL,
        RecordId       INT NOT NULL,
        ProcurementId  INT NULL,
        ShipmentId     INT NULL,
        ProductName    NVARCHAR(250) NULL,
        BrandName      NVARCHAR(150) NULL,
        CategoryName   NVARCHAR(150) NULL,
        Quantity       INT NULL,
        NetUnitCost    DECIMAL(18,2) NULL,
        DeletionReason NVARCHAR(500) NULL,
        DeletedByUserId UNIQUEIDENTIFIER NULL,
        DeletedAtUtc   DATETIME2 NOT NULL CONSTRAINT DF_SupplyDeletedItemsLog_At DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_SupplyDeletedItemsLog_Table ON dbo.SupplyDeletedItemsLog(TableName, RecordId);
    CREATE INDEX IX_SupplyDeletedItemsLog_Date  ON dbo.SupplyDeletedItemsLog(DeletedAtUtc);
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- SP: spSupplyProcurementItem_SoftDelete
-- ─────────────────────────────────────────────────────────────────────────────
CREATE PROCEDURE dbo.spSupplyProcurementItem_SoftDelete
    @ProcurementItemId INT,
    @DeletionReason    NVARCHAR(500) = NULL,
    @DeletedByUserId   UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate item exists and is not already deleted
    DECLARE @ProcurementId INT, @ProductName NVARCHAR(250), @BrandName NVARCHAR(150),
            @CategoryName NVARCHAR(150), @Quantity INT, @NetUnitCost DECIMAL(18,2);

    SELECT @ProcurementId = ProcurementId,
           @ProductName   = ProductName,
           @BrandName     = BrandName,
           @CategoryName  = CategoryName,
           @Quantity      = Quantity,
           @NetUnitCost   = NetUnitCost
    FROM   dbo.SupplyProcurementItems
    WHERE  ProcurementItemId = @ProcurementItemId
      AND  IsDeleted = 0;

    IF @ProcurementId IS NULL
    BEGIN
        RAISERROR('Procurement item not found or already deleted.', 16, 1);
        RETURN;
    END

    -- Soft delete
    UPDATE dbo.SupplyProcurementItems
    SET    IsDeleted       = 1,
           DeletedAtUtc    = SYSUTCDATETIME(),
           DeletedByUserId = @DeletedByUserId,
           DeletionReason  = @DeletionReason
    WHERE  ProcurementItemId = @ProcurementItemId;

    -- Log the deletion
    INSERT INTO dbo.SupplyDeletedItemsLog
        (TableName, RecordId, ProcurementId, ProductName, BrandName, CategoryName, Quantity, NetUnitCost, DeletionReason, DeletedByUserId)
    VALUES
        ('SupplyProcurementItems', @ProcurementItemId, @ProcurementId,
         @ProductName, @BrandName, @CategoryName, @Quantity, @NetUnitCost,
         @DeletionReason, @DeletedByUserId);

    SELECT 1 AS AffectedRows;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- SP: spSupplyProcurementItem_Update
-- ─────────────────────────────────────────────────────────────────────────────
CREATE PROCEDURE dbo.spSupplyProcurementItem_Update
    @ProcurementItemId INT,
    @ProductName       NVARCHAR(250),
    @BrandName         NVARCHAR(150),
    @CategoryName      NVARCHAR(150),
    @Quantity          INT,
    @UnitPrice         DECIMAL(18,2),
    @BatchNote         NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.SupplyProcurementItems
        WHERE ProcurementItemId = @ProcurementItemId AND IsDeleted = 0
    )
    BEGIN
        RAISERROR('Procurement item not found.', 16, 1);
        RETURN;
    END

    DECLARE @GrossTotal DECIMAL(18,2) = ROUND(@Quantity * @UnitPrice, 2);
    DECLARE @DiscountTotal DECIMAL(18,2);

    SELECT @DiscountTotal = DiscountTotal
    FROM   dbo.SupplyProcurementItems
    WHERE  ProcurementItemId = @ProcurementItemId;

    SET @DiscountTotal = CASE WHEN @DiscountTotal > @GrossTotal THEN @GrossTotal ELSE @DiscountTotal END;

    DECLARE @NetTotal DECIMAL(18,2)   = ROUND(@GrossTotal - @DiscountTotal, 2);
    DECLARE @NetUnitCost DECIMAL(18,2) = CASE WHEN @Quantity > 0 THEN ROUND(@NetTotal / @Quantity, 2) ELSE 0 END;

    UPDATE dbo.SupplyProcurementItems
    SET    ProductName  = @ProductName,
           BrandName    = @BrandName,
           CategoryName = @CategoryName,
           Quantity     = @Quantity,
           UnitPrice    = @UnitPrice,
           GrossTotal   = @GrossTotal,
           NetTotal     = @NetTotal,
           NetUnitCost  = @NetUnitCost,
           BatchNote    = @BatchNote
    WHERE  ProcurementItemId = @ProcurementItemId;

    SELECT 1 AS AffectedRows;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- SP: spSupplyDispatchItem_SoftDelete
-- ─────────────────────────────────────────────────────────────────────────────
CREATE PROCEDURE dbo.spSupplyDispatchItem_SoftDelete
    @ShipmentItemId  INT,
    @DeletionReason  NVARCHAR(500) = NULL,
    @DeletedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ShipmentId INT, @ProductName NVARCHAR(250), @BrandName NVARCHAR(150),
            @CategoryName NVARCHAR(150), @QuantityDispatched INT, @NetUnitCost DECIMAL(18,2);

    SELECT @ShipmentId          = ShipmentId,
           @ProductName          = ProductName,
           @BrandName            = BrandName,
           @CategoryName         = CategoryName,
           @QuantityDispatched   = QuantityDispatched,
           @NetUnitCost          = NetUnitCost
    FROM   dbo.SupplyShipmentItems
    WHERE  ShipmentItemId = @ShipmentItemId
      AND  IsDeleted = 0;

    IF @ShipmentId IS NULL
    BEGIN
        RAISERROR('Shipment item not found or already deleted.', 16, 1);
        RETURN;
    END

    UPDATE dbo.SupplyShipmentItems
    SET    IsDeleted       = 1,
           DeletedAtUtc    = SYSUTCDATETIME(),
           DeletedByUserId = @DeletedByUserId,
           DeletionReason  = @DeletionReason
    WHERE  ShipmentItemId = @ShipmentItemId;

    INSERT INTO dbo.SupplyDeletedItemsLog
        (TableName, RecordId, ShipmentId, ProductName, BrandName, CategoryName, Quantity, NetUnitCost, DeletionReason, DeletedByUserId)
    VALUES
        ('SupplyShipmentItems', @ShipmentItemId, @ShipmentId,
         @ProductName, @BrandName, @CategoryName, @QuantityDispatched, @NetUnitCost,
         @DeletionReason, @DeletedByUserId);

    SELECT 1 AS AffectedRows;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- SP: spSupplyDispatchItem_Update
-- ─────────────────────────────────────────────────────────────────────────────
CREATE PROCEDURE dbo.spSupplyDispatchItem_Update
    @ShipmentItemId    INT,
    @QuantityDispatched INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NetUnitCost DECIMAL(18,2);
    SELECT @NetUnitCost = NetUnitCost
    FROM   dbo.SupplyShipmentItems
    WHERE  ShipmentItemId = @ShipmentItemId AND IsDeleted = 0;

    IF @NetUnitCost IS NULL
    BEGIN
        RAISERROR('Shipment item not found.', 16, 1);
        RETURN;
    END

    IF @QuantityDispatched <= 0
    BEGIN
        RAISERROR('Quantity must be greater than zero.', 16, 1);
        RETURN;
    END

    UPDATE dbo.SupplyShipmentItems
    SET    QuantityDispatched = @QuantityDispatched,
           NetAmount = ROUND(@QuantityDispatched * @NetUnitCost, 2)
    WHERE  ShipmentItemId = @ShipmentItemId;

    SELECT 1 AS AffectedRows;
END
GO

-- ─────────────────────────────────────────────────────────────────────────────
-- SP: spSupplyDeletedItems_GetAll
-- ─────────────────────────────────────────────────────────────────────────────
CREATE PROCEDURE dbo.spSupplyDeletedItems_GetAll
    @TableName NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT LogId, TableName, RecordId, ProcurementId, ShipmentId,
           ProductName, BrandName, CategoryName, Quantity, NetUnitCost,
           DeletionReason, DeletedByUserId, DeletedAtUtc
    FROM   dbo.SupplyDeletedItemsLog
    WHERE  (@TableName IS NULL OR TableName = @TableName)
    ORDER  BY DeletedAtUtc DESC;
END
GO

-- ── Patch existing SPs to exclude soft-deleted items ─────────────────────────
-- Patch spSupplyProcurement_GetById to exclude deleted items
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurement_GetById;
GO

CREATE PROCEDURE dbo.spSupplyProcurement_GetById
    @ProcurementId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT p.ProcurementId, p.ProcurementReference, p.ShopName, p.PurchaseDate,
           p.InvoiceReference, p.PaymentCardName, p.PaymentReference, p.Status,
           p.PurchaseNote, p.EnteredByUserId, p.CreatedAtUtc,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.GrossTotal ELSE 0 END) AS TotalGrossAmount,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.DiscountTotal ELSE 0 END) AS TotalDiscountAmount,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetTotal ELSE 0 END) AS TotalNetAmount,
           COUNT(CASE WHEN i.IsDeleted = 0 THEN 1 END) AS ItemCount
    FROM   dbo.SupplyProcurements p
    LEFT   JOIN dbo.SupplyProcurementItems i ON i.ProcurementId = p.ProcurementId
    WHERE  p.ProcurementId = @ProcurementId
    GROUP  BY p.ProcurementId, p.ProcurementReference, p.ShopName, p.PurchaseDate,
              p.InvoiceReference, p.PaymentCardName, p.PaymentReference, p.Status,
              p.PurchaseNote, p.EnteredByUserId, p.CreatedAtUtc;

    -- Items (exclude deleted)
    SELECT ProcurementItemId, LineNumber, ProductId, ProductName, BrandName,
           CategoryName, Quantity, UnitPrice, GrossTotal, DiscountTotal,
           NetTotal, NetUnitCost, BatchNote
    FROM   dbo.SupplyProcurementItems
    WHERE  ProcurementId = @ProcurementId
      AND  IsDeleted = 0
    ORDER  BY LineNumber;

    -- Discounts
    SELECT d.DiscountId, d.DiscountCode, d.DiscountType, d.DiscountScope,
           d.Description, d.TargetProductName, d.TargetBrandName, d.TargetShopName,
           d.BuyQuantity, d.PayQuantity, d.Percentage, d.FixedAmount, d.DiscountAmount, d.Notes
    FROM   dbo.SupplyProcurementDiscounts d
    WHERE  d.ProcurementId = @ProcurementId;

    -- Discount allocations (for non-deleted items only)
    SELECT da.DiscountId, da.ProcurementItemId, i.LineNumber, da.Amount
    FROM   dbo.SupplyProcurementDiscountAllocations da
    JOIN   dbo.SupplyProcurementItems i ON i.ProcurementItemId = da.ProcurementItemId
    WHERE  i.ProcurementId = @ProcurementId
      AND  i.IsDeleted = 0;
END
GO

-- Patch spSupplyProcurement_GetAll to exclude deleted items from counts
DROP PROCEDURE IF EXISTS dbo.spSupplyProcurement_GetAll;
GO

CREATE PROCEDURE dbo.spSupplyProcurement_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.ProcurementId, p.ProcurementReference, p.ShopName, p.PurchaseDate,
           p.InvoiceReference, p.PaymentCardName, p.PaymentReference, p.Status, p.PurchaseNote,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.GrossTotal ELSE 0 END) AS TotalGrossAmount,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.DiscountTotal ELSE 0 END) AS TotalDiscountAmount,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetTotal ELSE 0 END) AS TotalNetAmount,
           COUNT(CASE WHEN i.IsDeleted = 0 THEN 1 END) AS ItemCount
    FROM   dbo.SupplyProcurements p
    LEFT   JOIN dbo.SupplyProcurementItems i ON i.ProcurementId = p.ProcurementId
    GROUP  BY p.ProcurementId, p.ProcurementReference, p.ShopName, p.PurchaseDate,
              p.InvoiceReference, p.PaymentCardName, p.PaymentReference, p.Status, p.PurchaseNote
    ORDER  BY p.PurchaseDate DESC;
END
GO

-- Patch spSupplyDispatch_GetById to exclude deleted items
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_GetById;
GO

CREATE PROCEDURE dbo.spSupplyDispatch_GetById
    @ShipmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.ShipmentId, s.DispatchReference, s.DispatchDate, s.CourierName,
           s.ParcelNumber, s.ShipmentStatus, s.Notes,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetAmount ELSE 0 END) AS TotalProductCost,
           ISNULL(SUM(DISTINCT c.Amount), 0) AS TotalShipmentCharges,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetAmount ELSE 0 END) + ISNULL(SUM(DISTINCT c.Amount), 0) AS TotalLandedCost,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.QuantityDispatched ELSE 0 END) AS TotalQuantity
    FROM   dbo.SupplyShipments s
    LEFT   JOIN dbo.SupplyShipmentItems i ON i.ShipmentId = s.ShipmentId
    LEFT   JOIN dbo.SupplyShipmentCharges c ON c.ShipmentId = s.ShipmentId
    WHERE  s.ShipmentId = @ShipmentId
    GROUP  BY s.ShipmentId, s.DispatchReference, s.DispatchDate, s.CourierName,
              s.ParcelNumber, s.ShipmentStatus, s.Notes;

    -- Items (exclude deleted)
    SELECT ShipmentItemId, ShipmentId, ProcurementItemId, ProcurementId, ProductId,
           ProductName, BrandName, CategoryName, QuantityDispatched, NetUnitCost, NetAmount
    FROM   dbo.SupplyShipmentItems
    WHERE  ShipmentId = @ShipmentId
      AND  IsDeleted = 0
    ORDER  BY ShipmentItemId;

    -- Charges
    SELECT ShipmentChargeId, ShipmentId, ChargeType, CurrencyCode, Amount, ChargeDate, Notes
    FROM   dbo.SupplyShipmentCharges
    WHERE  ShipmentId = @ShipmentId
    ORDER  BY ChargeDate;
END
GO

-- Patch spSupplyDispatch_GetAll to exclude deleted items
DROP PROCEDURE IF EXISTS dbo.spSupplyDispatch_GetAll;
GO

CREATE PROCEDURE dbo.spSupplyDispatch_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.ShipmentId, s.DispatchReference, s.DispatchDate, s.CourierName,
           s.ParcelNumber, s.ShipmentStatus, s.Notes,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetAmount ELSE 0 END) AS TotalProductCost,
           ISNULL(SUM(DISTINCT c.Amount), 0) AS TotalShipmentCharges,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.NetAmount ELSE 0 END) + ISNULL(SUM(DISTINCT c.Amount), 0) AS TotalLandedCost,
           SUM(CASE WHEN i.IsDeleted = 0 THEN i.QuantityDispatched ELSE 0 END) AS TotalQuantity
    FROM   dbo.SupplyShipments s
    LEFT   JOIN dbo.SupplyShipmentItems i ON i.ShipmentId = s.ShipmentId
    LEFT   JOIN dbo.SupplyShipmentCharges c ON c.ShipmentId = s.ShipmentId
    GROUP  BY s.ShipmentId, s.DispatchReference, s.DispatchDate, s.CourierName,
              s.ParcelNumber, s.ShipmentStatus, s.Notes
    ORDER  BY s.DispatchDate DESC;
END
GO

PRINT 'Migration 012 complete.';
GO
