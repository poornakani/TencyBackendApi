-- ============================================================
-- Migration 010: Add concern ids to product catalog read SPs
-- Enables storefront concern-based filtering/sorting from nav.
-- Run after: 009_fix_product_image_update_sps.sql
-- ============================================================

IF OBJECT_ID('dbo.spProductCatalog_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductCatalog_GetAll;
GO

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
    LEFT JOIN dbo.Brand            b   ON b.Brandid    = p.brandid    AND b.Isactive = 1
    LEFT JOIN dbo.Category         c   ON c.catagoryID = p.categoryid AND c.IsActive = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    LEFT JOIN dbo.ProductPricing   pr  ON pr.ProductId = p.productid
        AND pr.StartUTC <= SYSUTCDATETIME()
        AND (pr.EndUTC IS NULL OR pr.EndUTC >= SYSUTCDATETIME())
    WHERE p.insale = 1
    ORDER BY p.createdate DESC;
END
GO

IF OBJECT_ID('dbo.spProductCatalog_GetAllAdmin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductCatalog_GetAllAdmin;
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
        )                             AS PrimaryImageUrl,
        (SELECT STRING_AGG(CAST(pc.concernID AS NVARCHAR(20)), ',')
         FROM dbo.ProductConcerns pc
         WHERE pc.productid = p.productid
        )                             AS ConcernTypeIdsCsv
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand            b   ON b.Brandid    = p.brandid    AND b.Isactive = 1
    LEFT JOIN dbo.Category         c   ON c.catagoryID = p.categoryid AND c.IsActive = 1
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

IF OBJECT_ID('dbo.spProductCatalog_GetById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.spProductCatalog_GetById;
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
        )                             AS PrimaryImageUrl,
        (SELECT STRING_AGG(CAST(pc.concernID AS NVARCHAR(20)), ',')
         FROM dbo.ProductConcerns pc
         WHERE pc.productid = p.productid
        )                             AS ConcernTypeIdsCsv
    FROM dbo.ProductCatalog p
    LEFT JOIN dbo.Brand            b   ON b.Brandid    = p.brandid    AND b.Isactive = 1
    LEFT JOIN dbo.Category         c   ON c.catagoryID = p.categoryid AND c.IsActive = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    OUTER APPLY (
        SELECT TOP 1 price, discountrate, StartUTC, EndUTC
        FROM dbo.ProductPricing pr1
        WHERE pr1.ProductId = p.productid
        ORDER BY ISNULL(pr1.lastupdated, pr1.createdate) DESC, pr1.PricingId DESC
    ) pr
    WHERE p.productid = @ProductId;

    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM   dbo.ProductImages
    WHERE  productid = @ProductId AND IsActive = 1
    ORDER BY IsPrimary DESC, SortOrder;

    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM   dbo.ProductFAQ
    WHERE  productid = @ProductId AND IsActive = 1;

    SELECT pc.productid, pc.concernID AS ConcernTypeId, ct.ConcernType
    FROM   dbo.ProductConcerns pc
    JOIN   dbo.ConcernTypes ct ON ct.ConcernTypeId = pc.concernID
    WHERE  pc.productid = @ProductId;

    SELECT pp.productid, pp.PaymentTypeId, pt.PaymentType, pp.instalment
    FROM   dbo.ProductPaymentOptions pp
    JOIN   dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE  pp.productid = @ProductId;
END
GO

PRINT 'Migration 010 complete.';
