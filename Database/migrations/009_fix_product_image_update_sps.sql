-- ============================================================
-- Migration 009: Fix product image update-related SPs only
-- Ensures product image update/activate/deactivate procedures
-- return @@ROWCOUNT so WriterBase.UpdateAsync works correctly.
-- Run after: 008_fix_update_sps_payment_type_ops.sql
-- ============================================================

-- ----------------------------------------------------------------
-- 1. Fix sp_UpdateProductImage — return @@ROWCOUNT so WriterBase
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
        UPDATE dbo.ProductImages
        SET IsPrimary = 0
        WHERE productid = @ProductId
          AND ImageId <> @ImageId;

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
-- 2. Fix sp_DeactiveProductImage — return @@ROWCOUNT.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_DeactiveProductImage', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeactiveProductImage;
GO

CREATE PROCEDURE dbo.sp_DeactiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ProductImages
    SET IsActive = 0
    WHERE ImageId = @ImageId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

-- ----------------------------------------------------------------
-- 3. Fix sp_ActiveProductImage — return @@ROWCOUNT.
-- ----------------------------------------------------------------
IF OBJECT_ID('dbo.sp_ActiveProductImage', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ActiveProductImage;
GO

CREATE PROCEDURE dbo.sp_ActiveProductImage
    @ImageId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.ProductImages
    SET IsActive = 1
    WHERE ImageId = @ImageId;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

PRINT 'Migration 009 complete.';
