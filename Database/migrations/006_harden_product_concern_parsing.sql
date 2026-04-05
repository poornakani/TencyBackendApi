-- ============================================================
-- Migration 006: Harden product concern parsing
-- Ignore invalid concern ids instead of throwing when saving products.
-- ============================================================

IF OBJECT_ID('dbo.spProductCatalog_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductCatalog_Insert;
GO

IF OBJECT_ID('dbo.spProductCatalog_Update', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductCatalog_Update;
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
    @ConcernTypeIds NVARCHAR(MAX)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ProductId INT;
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

    IF @ConcernTypeIds IS NOT NULL AND LEN(TRIM(@ConcernTypeIds)) > 0
    BEGIN
        INSERT INTO dbo.ProductConcerns (productid, concernID)
        SELECT @ProductId, TRY_CAST(TRIM(value) AS INT)
        FROM STRING_SPLIT(@ConcernTypeIds, ',')
        WHERE TRIM(value) <> ''
          AND TRY_CAST(TRIM(value) AS INT) IS NOT NULL
          AND EXISTS (
              SELECT 1
              FROM dbo.ConcernTypes ct
              WHERE ct.ConcernTypeId = TRY_CAST(TRIM(value) AS INT)
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
    @ConcernTypeIds NVARCHAR(MAX)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @DiscountRate DECIMAL(5,2) =
        CASE WHEN @OriginalPrice > 0
             THEN ROUND((@OriginalPrice - @SellingPrice) / @OriginalPrice * 100.0, 2)
             ELSE 0 END;

    UPDATE dbo.ProductCatalog
    SET name = @Name,
        brandid = @BrandId,
        categoryid = @CategoryId,
        description = @Description,
        weight = @Weight,
        insale = @InSale,
        lastupdated = SYSUTCDATETIME()
    WHERE productid = @ProductId;

    IF @StockQuantity IS NOT NULL
        UPDATE dbo.ProductInventory
        SET stock = @StockQuantity, LastStockUpdateUTC = SYSUTCDATETIME()
        WHERE ProductId = @ProductId;

    UPDATE dbo.ProductPricing
    SET price = @SellingPrice,
        discountrate = @DiscountRate,
        StartUTC = ISNULL(@StartUTC, StartUTC),
        EndUTC = @EndUTC,
        lastupdated = SYSUTCDATETIME()
    WHERE PricingId = (
        SELECT TOP 1 PricingId
        FROM dbo.ProductPricing
        WHERE ProductId = @ProductId
        ORDER BY ISNULL(lastupdated, createdate) DESC, PricingId DESC
    );

    IF @ConcernTypeIds IS NOT NULL
    BEGIN
        DELETE FROM dbo.ProductConcerns WHERE productid = @ProductId;

        IF LEN(TRIM(@ConcernTypeIds)) > 0
        BEGIN
            INSERT INTO dbo.ProductConcerns (productid, concernID)
            SELECT @ProductId, TRY_CAST(TRIM(value) AS INT)
            FROM STRING_SPLIT(@ConcernTypeIds, ',')
            WHERE TRIM(value) <> ''
              AND TRY_CAST(TRIM(value) AS INT) IS NOT NULL
              AND EXISTS (
                  SELECT 1
                  FROM dbo.ConcernTypes ct
                  WHERE ct.ConcernTypeId = TRY_CAST(TRIM(value) AS INT)
              );
        END
    END
END
GO

PRINT 'Migration 006 complete.';
