-- ============================================================
-- Migration 005: Fix concern stored procedure name mapping
-- Dapper maps by property name, so ConcernType must be aliased as Name
-- for ConcernTypeEntity/ConcernTypeModel to populate correctly.
-- ============================================================

IF OBJECT_ID('dbo.sp_ConcernType_GetAll', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ConcernType_GetAll;
GO

IF OBJECT_ID('dbo.sp_ConcernType_GetById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ConcernType_GetById;
GO

CREATE PROCEDURE dbo.sp_ConcernType_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ConcernTypeId,
        ConcernType AS Name,
        description AS Description,
        IsActive
    FROM dbo.ConcernTypes
    WHERE IsActive = 1
    ORDER BY ConcernType;
END
GO

CREATE PROCEDURE dbo.sp_ConcernType_GetById
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ConcernTypeId,
        ConcernType AS Name,
        description AS Description,
        IsActive
    FROM dbo.ConcernTypes
    WHERE ConcernTypeId = @ConcernTypeId;
END
GO

PRINT 'Migration 005 complete.';
