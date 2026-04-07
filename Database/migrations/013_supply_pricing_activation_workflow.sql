-- ============================================================
-- Migration 013: Add pricing activation workflow for arrivals
--                so approved arrivals wait for pricing review
--                before they affect live product stock/price.
-- ============================================================

IF COL_LENGTH('dbo.SupplyPricing', 'ApplicationMode') IS NULL
BEGIN
    ALTER TABLE dbo.SupplyPricing
    ADD ApplicationMode NVARCHAR(40) NOT NULL
        CONSTRAINT DF_SupplyPricing_ApplicationMode DEFAULT ('merge_into_live');
END
GO

IF COL_LENGTH('dbo.SupplyPricing', 'PricingReviewStatus') IS NULL
BEGIN
    ALTER TABLE dbo.SupplyPricing
    ADD PricingReviewStatus NVARCHAR(40) NOT NULL
        CONSTRAINT DF_SupplyPricing_ReviewStatus DEFAULT ('pending_price_approval');
END
GO

IF COL_LENGTH('dbo.SupplyPricing', 'AppliedToProductAtUtc') IS NULL
BEGIN
    ALTER TABLE dbo.SupplyPricing
    ADD AppliedToProductAtUtc DATETIME2 NULL;
END
GO

UPDATE dbo.SupplyPricing
SET ApplicationMode = ISNULL(NULLIF(ApplicationMode, ''), 'merge_into_live'),
    PricingReviewStatus = CASE
        WHEN PricingReviewStatus IS NOT NULL AND LTRIM(RTRIM(PricingReviewStatus)) <> '' THEN PricingReviewStatus
        WHEN IsApproved = 1 THEN 'pending_activation'
        ELSE 'draft'
    END
WHERE ApplicationMode IS NULL
   OR LTRIM(RTRIM(ApplicationMode)) = ''
   OR PricingReviewStatus IS NULL
   OR LTRIM(RTRIM(PricingReviewStatus)) = '';
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
        sp.PricingId,
        b.ShipmentId,
        s.DispatchReference,
        b.ProductId,
        b.ProductName,
        b.BrandName,
        b.CategoryName,
        ai.ApprovedQuantity,
        LandedUnitCost = b.NetUnitCost + CASE WHEN b.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / b.QuantityDispatched, 2) END,
        LandedTotalCost = ai.ApprovedQuantity * (b.NetUnitCost + CASE WHEN b.QuantityDispatched = 0 OR b.TotalNetAmount = 0 THEN 0 ELSE ROUND((b.TotalChargeAmount * (b.NetAmount / b.TotalNetAmount)) / b.QuantityDispatched, 2) END),
        IsPriced = CAST(CASE WHEN sp.PricingId IS NULL THEN 0 ELSE 1 END AS BIT),
        IsApproved = ISNULL(sp.IsApproved, 0),
        PricingReviewStatus = ISNULL(sp.PricingReviewStatus, 'pending_price_approval'),
        ApplicationMode = ISNULL(sp.ApplicationMode, 'pending_price_approval'),
        CurrentSellingPrice = ISNULL(pr.price, 0),
        CurrentOriginalPrice = ISNULL(
            ROUND(pr.price / NULLIF(1.0 - pr.discountrate / 100.0, 0), 2),
            ISNULL(pr.price, 0)
        ),
        CurrentStockQuantity = ISNULL(inv.stock, 0)
    FROM dbo.SupplyArrivalItems ai
    INNER JOIN ShipmentChargeBase b ON b.ShipmentItemId = ai.ShipmentItemId
    INNER JOIN dbo.SupplyShipments s ON s.ShipmentId = b.ShipmentId
    LEFT JOIN dbo.SupplyPricing sp ON sp.ArrivalItemId = ai.ArrivalItemId
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = ai.ProductId
    OUTER APPLY (
        SELECT TOP 1 price, discountrate
        FROM dbo.ProductPricing pr1
        WHERE pr1.ProductId = ai.ProductId
        ORDER BY ISNULL(pr1.lastupdated, pr1.createdate) DESC, pr1.PricingId DESC
    ) pr
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
        sp.ApplicationMode,
        sp.PricingReviewStatus,
        sp.AppliedToProductAtUtc,
        sp.ApprovedAtUtc
    FROM dbo.SupplyPricing sp
    INNER JOIN dbo.SupplyArrivalItems ai ON ai.ArrivalItemId = sp.ArrivalItemId
    INNER JOIN ShipmentCostBase base ON base.ShipmentItemId = ai.ShipmentItemId
    ORDER BY ISNULL(sp.AppliedToProductAtUtc, sp.ApprovedAtUtc) DESC, sp.PricingId DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.spSupplyPricing_Activate
    @PricingId INT,
    @ForceActivate BIT = 0,
    @ApprovedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductId INT;
    DECLARE @ApprovedQuantity INT;
    DECLARE @FinalSellingPrice DECIMAL(18,2);
    DECLARE @ApplicationMode NVARCHAR(40);
    DECLARE @PricingReviewStatus NVARCHAR(40);
    DECLARE @IsApproved BIT;
    DECLARE @CurrentStock INT;

    SELECT
        @ProductId = ai.ProductId,
        @ApprovedQuantity = ai.ApprovedQuantity,
        @FinalSellingPrice = sp.FinalSellingPrice,
        @ApplicationMode = sp.ApplicationMode,
        @PricingReviewStatus = sp.PricingReviewStatus,
        @IsApproved = sp.IsApproved
    FROM dbo.SupplyPricing sp
    INNER JOIN dbo.SupplyArrivalItems ai ON ai.ArrivalItemId = sp.ArrivalItemId
    WHERE sp.PricingId = @PricingId;

    IF @ProductId IS NULL
        THROW 50001, 'This arrival item is not linked to a live product.', 1;

    IF ISNULL(@IsApproved, 0) = 0
        THROW 50002, 'Pricing must be approved before it can be activated.', 1;

    IF @PricingReviewStatus = 'applied_live'
    BEGIN
        SELECT @PricingId;
        RETURN;
    END

    SELECT @CurrentStock = ISNULL(stock, 0)
    FROM dbo.ProductInventory
    WHERE ProductId = @ProductId;

    IF ISNULL(@ForceActivate, 0) = 0
       AND @ApplicationMode = 'wait_for_current_stock'
       AND ISNULL(@CurrentStock, 0) > 0
        THROW 50003, 'Current live stock must be finished before activating this queued price.', 1;

    IF EXISTS (SELECT 1 FROM dbo.ProductInventory WHERE ProductId = @ProductId)
    BEGIN
        UPDATE dbo.ProductInventory
        SET stock = ISNULL(stock, 0) + @ApprovedQuantity,
            LastStockUpdateUTC = SYSUTCDATETIME()
        WHERE ProductId = @ProductId;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.ProductInventory (ProductId, stock, LastStockUpdateUTC)
        VALUES (@ProductId, @ApprovedQuantity, SYSUTCDATETIME());
    END

    INSERT INTO dbo.ProductPricing (ProductId, price, discountrate, StartUTC, EndUTC, createdate, lastupdated)
    VALUES (@ProductId, @FinalSellingPrice, 0, SYSUTCDATETIME(), NULL, SYSUTCDATETIME(), SYSUTCDATETIME());

    UPDATE dbo.SupplyPricing
    SET PricingReviewStatus = 'applied_live',
        AppliedToProductAtUtc = SYSUTCDATETIME(),
        UpdatedAtUtc = SYSUTCDATETIME(),
        ApprovedByUserId = @ApprovedByUserId,
        ApprovedAtUtc = SYSUTCDATETIME()
    WHERE PricingId = @PricingId;

    SELECT @PricingId;
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
    @ApplicationMode NVARCHAR(40) = 'merge_into_live',
    @ApprovedByUserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LandedUnitCost DECIMAL(18,2);
    DECLARE @FinalSellingPrice DECIMAL(18,2);
    DECLARE @MarkupPercent DECIMAL(18,2);
    DECLARE @MarginPercent DECIMAL(18,2);
    DECLARE @ExistingPricingId INT;
    DECLARE @ExistingReviewStatus NVARCHAR(40);
    DECLARE @NextReviewStatus NVARCHAR(40);

    SET @ApplicationMode = CASE
        WHEN @ApplicationMode = 'wait_for_current_stock' THEN 'wait_for_current_stock'
        ELSE 'merge_into_live'
    END;

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

    SELECT TOP 1
        @ExistingPricingId = sp.PricingId,
        @ExistingReviewStatus = sp.PricingReviewStatus
    FROM dbo.SupplyPricing sp
    WHERE sp.ArrivalItemId = @ArrivalItemId
    ORDER BY sp.PricingId DESC;

    SET @PricingId = ISNULL(@PricingId, @ExistingPricingId);
    SET @FinalSellingPrice = ROUND(@SellingPrice - ((@SellingPrice * @CustomerDiscountPercent) / 100.0) - @CustomerDiscountAmount, 2);
    SET @MarkupPercent = CASE WHEN @LandedUnitCost <= 0 THEN 0 ELSE ROUND(((@FinalSellingPrice - @LandedUnitCost) / @LandedUnitCost) * 100.0, 2) END;
    SET @MarginPercent = CASE WHEN @FinalSellingPrice <= 0 THEN 0 ELSE ROUND(((@FinalSellingPrice - @LandedUnitCost) / @FinalSellingPrice) * 100.0, 2) END;

    SET @NextReviewStatus = CASE
        WHEN @ExistingReviewStatus = 'applied_live' THEN 'applied_live'
        WHEN @IsApproved = 0 THEN 'draft'
        WHEN @ApplicationMode = 'wait_for_current_stock' THEN 'awaiting_stock_depletion'
        ELSE 'pending_activation'
    END;

    IF @PricingId IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.SupplyPricing WHERE PricingId = @PricingId)
    BEGIN
        INSERT INTO dbo.SupplyPricing
        (
            ArrivalItemId, SellingPrice, CustomerDiscountPercent, CustomerDiscountAmount, FinalSellingPrice,
            MarkupPercent, MarginPercent, PricingNotes, IsApproved, ApplicationMode, PricingReviewStatus,
            ApprovedByUserId, AppliedToProductAtUtc
        )
        VALUES
        (
            @ArrivalItemId, @SellingPrice, @CustomerDiscountPercent, @CustomerDiscountAmount, @FinalSellingPrice,
            @MarkupPercent, @MarginPercent, @PricingNotes, @IsApproved, @ApplicationMode, @NextReviewStatus,
            @ApprovedByUserId, CASE WHEN @NextReviewStatus = 'applied_live' THEN SYSUTCDATETIME() ELSE NULL END
        );

        SET @PricingId = CAST(SCOPE_IDENTITY() AS INT);
    END
    ELSE
    BEGIN
        UPDATE dbo.SupplyPricing
        SET SellingPrice = @SellingPrice,
            CustomerDiscountPercent = @CustomerDiscountPercent,
            CustomerDiscountAmount = @CustomerDiscountAmount,
            FinalSellingPrice = @FinalSellingPrice,
            MarkupPercent = @MarkupPercent,
            MarginPercent = @MarginPercent,
            PricingNotes = @PricingNotes,
            IsApproved = @IsApproved,
            ApplicationMode = @ApplicationMode,
            PricingReviewStatus = @NextReviewStatus,
            ApprovedByUserId = @ApprovedByUserId,
            UpdatedAtUtc = SYSUTCDATETIME(),
            ApprovedAtUtc = CASE WHEN @IsApproved = 1 THEN SYSUTCDATETIME() ELSE ApprovedAtUtc END,
            AppliedToProductAtUtc = CASE WHEN @NextReviewStatus = 'applied_live' THEN ISNULL(AppliedToProductAtUtc, SYSUTCDATETIME()) ELSE NULL END
        WHERE PricingId = @PricingId;
    END

    IF @IsApproved = 1
       AND @ApplicationMode = 'merge_into_live'
       AND ISNULL(@ExistingReviewStatus, '') <> 'applied_live'
    BEGIN
        EXEC dbo.spSupplyPricing_Activate
            @PricingId = @PricingId,
            @ForceActivate = 1,
            @ApprovedByUserId = @ApprovedByUserId;

        SELECT @PricingId;
        RETURN;
    END

    SELECT @PricingId;
END;
GO

PRINT 'Migration 013 complete.';
