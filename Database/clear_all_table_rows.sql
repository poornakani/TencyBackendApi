-- ============================================================
-- Utility: Clear all rows from user tables
-- Purpose: Delete data without dropping schema objects
-- Warning: This removes all rows from dbo/user tables and
--          reseeds identity columns back to 0.
-- ============================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @sql NVARCHAR(MAX) = N'';

    -- Disable foreign keys so delete order does not matter.
    SELECT @sql +=
        N'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) +
        N' NOCHECK CONSTRAINT ALL;' + CHAR(10)
    FROM sys.tables t
    WHERE t.is_ms_shipped = 0;

    EXEC sp_executesql @sql;

    SET @sql = N'';

    -- Delete all data from every user table.
    SELECT @sql +=
        N'DELETE FROM ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) + N';' + CHAR(10)
    FROM sys.tables t
    WHERE t.is_ms_shipped = 0
    ORDER BY t.name;

    EXEC sp_executesql @sql;

    SET @sql = N'';

    -- Reset identities so inserts start fresh.
    SELECT @sql +=
        N'DBCC CHECKIDENT (''' +
        REPLACE(QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name), '''', '''''') +
        N''', RESEED, 0);' + CHAR(10)
    FROM sys.tables t
    WHERE t.is_ms_shipped = 0
      AND EXISTS (
          SELECT 1
          FROM sys.identity_columns ic
          WHERE ic.object_id = t.object_id
      );

    IF @sql <> N''
        EXEC sp_executesql @sql;

    SET @sql = N'';

    -- Re-enable and validate constraints.
    SELECT @sql +=
        N'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + N'.' + QUOTENAME(t.name) +
        N' WITH CHECK CHECK CONSTRAINT ALL;' + CHAR(10)
    FROM sys.tables t
    WHERE t.is_ms_shipped = 0;

    EXEC sp_executesql @sql;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;
