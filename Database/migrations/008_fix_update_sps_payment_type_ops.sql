-- ============================================================
-- Migration 008: Fix Update SPs to return @@ROWCOUNT,
--                Fix Payment Type SPs (add @PaymentTypeId to update,
--                ensure all payment type SPs exist with correct columns).
-- Run after: 007_fix_product_concern_save_compat.sql
-- ============================================================

-- ----------------------------------------------------------------
-- 1. Fix sp_ConcernType_Update — add SELECT @@ROWCOUNT so
--    WriterBase.UpdateAsync<int> gets a non-zero value.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ConcernType_Update', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ConcernType_Update;
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
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ----------------------------------------------------------------
-- 2. Ensure sp_GetAllPaymentType exists and returns correct columns
--    (PaymentTypeId, Name alias, IsActive) so Dapper maps correctly.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_GetAllPaymentType', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAllPaymentType;
GO

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

-- ----------------------------------------------------------------
-- 3. Ensure sp_GetPaymentTypeById exists and returns correct columns.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_GetPaymentTypeById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetPaymentTypeById;
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

-- ----------------------------------------------------------------
-- 4. Fix sp_CreatePaymentType — ensure it inserts and returns new ID.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_CreatePaymentType', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreatePaymentType;
GO

CREATE PROCEDURE dbo.sp_CreatePaymentType
    @PaymentType NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.PaymentType (PaymentType, IsActive)
    VALUES (@PaymentType, 1);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS PaymentTypeId;
END
GO

-- ----------------------------------------------------------------
-- 5. Fix sp_UpdatePaymentType — add @PaymentTypeId param and
--    SELECT @@ROWCOUNT so WriterBase.UpdateAsync<int> works.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_UpdatePaymentType', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdatePaymentType;
GO

CREATE PROCEDURE dbo.sp_UpdatePaymentType
    @PaymentTypeId INT,
    @PaymentType   NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType
    SET    PaymentType = @PaymentType
    WHERE  PaymentTypeId = @PaymentTypeId;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ----------------------------------------------------------------
-- 6. Ensure sp_DeactivePaymentType exists.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_DeactivePaymentType', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeactivePaymentType;
GO

CREATE PROCEDURE dbo.sp_DeactivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType SET IsActive = 0 WHERE PaymentTypeId = @PaymentTypeId;
END
GO

-- ----------------------------------------------------------------
-- 7. Ensure sp_ActivePaymentType exists.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ActivePaymentType', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ActivePaymentType;
GO

CREATE PROCEDURE dbo.sp_ActivePaymentType
    @PaymentTypeId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PaymentType SET IsActive = 1 WHERE PaymentTypeId = @PaymentTypeId;
END
GO

-- ----------------------------------------------------------------
-- 8. Ensure ProductPaymentOptions table exists.
-- ----------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductPaymentOptions')
BEGIN
    CREATE TABLE dbo.ProductPaymentOptions (
        ProductId     INT NOT NULL,
        PaymentTypeId INT NOT NULL,
        instalment    INT NULL,
        CONSTRAINT PK_ProductPaymentOptions PRIMARY KEY (ProductId, PaymentTypeId),
        CONSTRAINT FK_PPO_Product     FOREIGN KEY (ProductId)     REFERENCES dbo.ProductCatalog(productid),
        CONSTRAINT FK_PPO_PaymentType FOREIGN KEY (PaymentTypeId) REFERENCES dbo.PaymentType(PaymentTypeId)
    );
    PRINT 'Created table ProductPaymentOptions';
END
GO

-- ----------------------------------------------------------------
-- 9. Fix sp_UpdateProductImage — return @@ROWCOUNT so WriterBase
--    does not treat successful updates as "not found".
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_UpdateProductImage', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateProductImage;
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
    SET    productid = @ProductId,
           ImageUrl = @ImageUrl,
           IsPrimary = @IsPrimary,
           SortOrder = @SortOrder,
           IsActive = @IsActive
    WHERE  ImageId = @ImageId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ----------------------------------------------------------------
-- 10. Fix sp_DeactiveProductImage — return @@ROWCOUNT.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_DeactiveProductImage', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeactiveProductImage;
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

-- ----------------------------------------------------------------
-- 11. Fix sp_ActiveProductImage — return @@ROWCOUNT.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ActiveProductImage', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ActiveProductImage;
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

PRINT 'Migration 008 complete.';
