-- ============================================================
-- Migration 004: Persist product pricing start/end dates
--                and return latest pricing in admin reads
-- Run after: 003_rename_concerntype_fix_catalog_sp.sql
-- ============================================================

IF OBJECT_ID('dbo.spProductCatalog_GetAllAdmin', 'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetAllAdmin;
IF OBJECT_ID('dbo.spProductCatalog_GetById',    'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetById;
IF OBJECT_ID('dbo.spProductCatalog_Insert',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Insert;
IF OBJECT_ID('dbo.spProductCatalog_Update',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Update;
GO

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
        )                             AS PrimaryImageUrl
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand b ON b.Brandid = p.brandid AND b.Isactive = 1
    LEFT JOIN dbo.Category c ON c.catagoryID = p.categoryid AND c.IsActive = 1
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
        )                             AS PrimaryImageUrl
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand b ON b.Brandid = p.brandid AND b.Isactive = 1
    LEFT JOIN dbo.Category c ON c.catagoryID = p.categoryid AND c.IsActive = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    OUTER APPLY (
        SELECT TOP 1 price, discountrate, StartUTC, EndUTC
        FROM dbo.ProductPricing pr1
        WHERE pr1.ProductId = p.productid
        ORDER BY ISNULL(pr1.lastupdated, pr1.createdate) DESC, pr1.PricingId DESC
    ) pr
    WHERE p.productid = @ProductId;

    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM dbo.ProductImages
    WHERE productid = @ProductId AND IsActive = 1
    ORDER BY IsPrimary DESC, SortOrder;

    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM dbo.ProductFAQ
    WHERE productid = @ProductId AND IsActive = 1;

    SELECT pc.productid, pc.concernID AS ConcernTypeId, ct.ConcernType
    FROM dbo.ProductConcerns pc
    JOIN dbo.ConcernTypes ct ON ct.ConcernTypeId = pc.concernID
    WHERE pc.productid = @ProductId;

    SELECT pp.productid, pp.PaymentTypeId, pt.PaymentType, pp.instalment
    FROM dbo.ProductPaymentOptions pp
    JOIN dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE pp.productid = @ProductId;
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

PRINT 'Migration 004 complete.';
