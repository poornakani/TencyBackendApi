-- ============================================================
-- Migration 003: Rename ConcernType → ConcernTypes,
--                Fix spProductCatalog_Insert & spProductCatalog_Update
--                to handle concern types.
-- Run against: tenzyuk_production
-- ============================================================

-- ----------------------------------------------------------------
-- 1. Rename the ConcernType table to ConcernTypes
-- ----------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ConcernType')
   AND NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ConcernTypes')
BEGIN
    -- Drop existing FK from ProductConcerns before renaming
    IF EXISTS (
        SELECT 1 FROM sys.foreign_keys
        WHERE name = 'FK_ProductConcerns_ConcernType'
    )
        ALTER TABLE dbo.ProductConcerns DROP CONSTRAINT FK_ProductConcerns_ConcernType;

    EXEC sp_rename 'dbo.ConcernType', 'ConcernTypes';
    PRINT 'Renamed table ConcernType → ConcernTypes';
END

-- ----------------------------------------------------------------
-- 2. Re-add the foreign key pointing at the renamed table
-- ----------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_ProductConcerns_ConcernType'
      AND parent_object_id = OBJECT_ID('dbo.ProductConcerns')
)
BEGIN
    ALTER TABLE dbo.ProductConcerns
        ADD CONSTRAINT FK_ProductConcerns_ConcernType
        FOREIGN KEY (concernID) REFERENCES dbo.ConcernTypes(ConcernTypeId);
    PRINT 'Recreated FK_ProductConcerns_ConcernType → ConcernTypes';
END
GO

-- ----------------------------------------------------------------
-- 3. Drop all stored procedures that reference ConcernType/ConcernTypes
--    so we can recreate them pointing at ConcernTypes
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ConcernType_GetAll',       'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetAll;
IF OBJECT_ID('dbo.sp_ConcernType_GetById',      'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_GetById;
IF OBJECT_ID('dbo.sp_ConcernType_Create',       'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Create;
IF OBJECT_ID('dbo.sp_ConcernType_Update',       'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Update;
IF OBJECT_ID('dbo.sp_ConcernType_Deactivate',   'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Deactivate;
IF OBJECT_ID('dbo.sp_ConcernType_Activate',     'P') IS NOT NULL DROP PROCEDURE dbo.sp_ConcernType_Activate;
IF OBJECT_ID('dbo.spProductCatalog_GetById',    'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_GetById;
IF OBJECT_ID('dbo.spProductCatalog_Insert',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Insert;
IF OBJECT_ID('dbo.spProductCatalog_Update',     'P') IS NOT NULL DROP PROCEDURE dbo.spProductCatalog_Update;
GO

-- ----------------------------------------------------------------
-- 4. Recreate concern-type stored procedures (now use ConcernTypes)
-- ----------------------------------------------------------------
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

-- ----------------------------------------------------------------
-- 5. Recreate spProductCatalog_GetById (uses ConcernTypes now)
-- ----------------------------------------------------------------
CREATE PROCEDURE dbo.spProductCatalog_GetById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Result set 1: product
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
    LEFT JOIN dbo.Brand          b   ON b.Brandid      = p.brandid    AND b.Isactive  = 1
    LEFT JOIN dbo.Category       c   ON c.catagoryID   = p.categoryid AND c.IsActive  = 1
    LEFT JOIN dbo.ProductInventory inv ON inv.ProductId = p.productid
    LEFT JOIN dbo.ProductPricing   pr  ON pr.ProductId = p.productid
        AND pr.StartUTC <= SYSUTCDATETIME()
        AND (pr.EndUTC IS NULL OR pr.EndUTC >= SYSUTCDATETIME())
    WHERE  p.productid = @ProductId;

    -- Result set 2: images
    SELECT ImageId, productid, ImageUrl, IsPrimary, SortOrder, createdate, IsActive
    FROM   dbo.ProductImages
    WHERE  productid = @ProductId AND IsActive = 1
    ORDER BY IsPrimary DESC, SortOrder;

    -- Result set 3: FAQs
    SELECT FAQId, productid, Question, Answer, createdUTC, IsActive
    FROM   dbo.ProductFAQ
    WHERE  productid = @ProductId AND IsActive = 1;

    -- Result set 4: concerns
    SELECT pc.productid, pc.concernID AS ConcernTypeId, ct.ConcernType
    FROM   dbo.ProductConcerns pc
    JOIN   dbo.ConcernTypes ct ON ct.ConcernTypeId = pc.concernID
    WHERE  pc.productid = @ProductId;

    -- Result set 5: payment options
    SELECT pp.productid, pp.PaymentTypeId, pt.PaymentType, pp.instalment
    FROM   dbo.ProductPaymentOptions pp
    JOIN   dbo.PaymentType pt ON pt.PaymentTypeId = pp.PaymentTypeId
    WHERE  pp.productid = @ProductId;
END
GO

-- ----------------------------------------------------------------
-- 6. Fix spProductCatalog_Insert — now accepts comma-separated
--    concern type IDs and inserts rows into ProductConcerns.
-- ----------------------------------------------------------------
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

    INSERT INTO dbo.ProductPricing (ProductId, price, discountrate, StartUTC, createdate, lastupdated)
    VALUES (@ProductId, @SellingPrice, @DiscountRate, SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME());

    -- Insert concern types (ignores invalid IDs via INNER JOIN)
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

-- ----------------------------------------------------------------
-- 7. Fix spProductCatalog_Update — now accepts comma-separated
--    concern type IDs; replaces existing concern associations.
-- ----------------------------------------------------------------
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
    @ConcernTypeIds NVARCHAR(MAX)  = NULL   -- comma-separated list; NULL = leave unchanged
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
           lastupdated  = SYSUTCDATETIME()
    WHERE  ProductId = @ProductId
      AND  StartUTC <= SYSUTCDATETIME()
      AND  (EndUTC IS NULL OR EndUTC >= SYSUTCDATETIME());

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

PRINT 'Migration 003 complete.';
