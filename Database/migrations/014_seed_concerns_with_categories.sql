-- ============================================================
-- Migration 014: Seed concern types and category mappings
--                and expose mapped category info in concern reads.
-- ============================================================

IF OBJECT_ID('dbo.ConcernTypeCategories', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ConcernTypeCategories (
        ConcernTypeId INT NOT NULL,
        CategoryId INT NOT NULL,
        CreatedAtUtc DATETIME2 NOT NULL CONSTRAINT DF_ConcernTypeCategories_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_ConcernTypeCategories PRIMARY KEY (ConcernTypeId, CategoryId),
        CONSTRAINT FK_ConcernTypeCategories_Concern FOREIGN KEY (ConcernTypeId) REFERENCES dbo.ConcernTypes(ConcernTypeId),
        CONSTRAINT FK_ConcernTypeCategories_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Category(catagoryID)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Acne & Breakouts')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Acne & Breakouts', 'Helps target blemishes and breakout-prone skin.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Dryness & Dehydration')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Dryness & Dehydration', 'Supports moisture balance and relieves dehydration.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Sensitivity & Redness')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Sensitivity & Redness', 'Focused on calming visible irritation and reactive skin.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Dark Spots & Pigmentation')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Dark Spots & Pigmentation', 'Targets uneven tone, post-acne marks, and discoloration.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Dullness & Uneven Tone')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Dullness & Uneven Tone', 'Helps improve radiance and smooth uneven complexion.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Fine Lines & Wrinkles')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Fine Lines & Wrinkles', 'Supports anti-ageing routines for visible lines and wrinkles.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Oiliness & Shine')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Oiliness & Shine', 'Balances excess sebum and helps control shine.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Pores & Texture')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Pores & Texture', 'Improves rough texture and the look of enlarged pores.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Sun Protection')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Sun Protection', 'Daily UV defense and support for sun-exposed skin.', 1);
END

IF NOT EXISTS (SELECT 1 FROM dbo.ConcernTypes WHERE ConcernType = 'Dark Circles & Puffiness')
BEGIN
    INSERT INTO dbo.ConcernTypes (ConcernType, description, IsActive)
    VALUES ('Dark Circles & Puffiness', 'Targets tired-looking under-eye concerns and puffiness.', 1);
END
GO

;WITH ConcernCategorySeed AS (
    SELECT ConcernName = 'Acne & Breakouts', CategoryName = 'Cleanser' UNION ALL
    SELECT 'Acne & Breakouts', 'Serum' UNION ALL
    SELECT 'Acne & Breakouts', 'Treatment' UNION ALL
    SELECT 'Dryness & Dehydration', 'Moisturizer' UNION ALL
    SELECT 'Dryness & Dehydration', 'Serum' UNION ALL
    SELECT 'Dryness & Dehydration', 'Mask' UNION ALL
    SELECT 'Sensitivity & Redness', 'Cleanser' UNION ALL
    SELECT 'Sensitivity & Redness', 'Moisturizer' UNION ALL
    SELECT 'Sensitivity & Redness', 'Serum' UNION ALL
    SELECT 'Dark Spots & Pigmentation', 'Serum' UNION ALL
    SELECT 'Dark Spots & Pigmentation', 'Treatment' UNION ALL
    SELECT 'Dark Spots & Pigmentation', 'Sunscreen' UNION ALL
    SELECT 'Dullness & Uneven Tone', 'Serum' UNION ALL
    SELECT 'Dullness & Uneven Tone', 'Exfoliator' UNION ALL
    SELECT 'Dullness & Uneven Tone', 'Mask' UNION ALL
    SELECT 'Fine Lines & Wrinkles', 'Serum' UNION ALL
    SELECT 'Fine Lines & Wrinkles', 'Moisturizer' UNION ALL
    SELECT 'Fine Lines & Wrinkles', 'Eye Care' UNION ALL
    SELECT 'Oiliness & Shine', 'Cleanser' UNION ALL
    SELECT 'Oiliness & Shine', 'Toner' UNION ALL
    SELECT 'Oiliness & Shine', 'Serum' UNION ALL
    SELECT 'Pores & Texture', 'Cleanser' UNION ALL
    SELECT 'Pores & Texture', 'Exfoliator' UNION ALL
    SELECT 'Pores & Texture', 'Treatment' UNION ALL
    SELECT 'Sun Protection', 'Sunscreen' UNION ALL
    SELECT 'Sun Protection', 'Moisturizer' UNION ALL
    SELECT 'Dark Circles & Puffiness', 'Eye Care' UNION ALL
    SELECT 'Dark Circles & Puffiness', 'Mask'
)
INSERT INTO dbo.ConcernTypeCategories (ConcernTypeId, CategoryId)
SELECT ct.ConcernTypeId, c.catagoryID
FROM ConcernCategorySeed seed
INNER JOIN dbo.ConcernTypes ct ON ct.ConcernType = seed.ConcernName
INNER JOIN dbo.Category c ON c.categorytype = seed.CategoryName
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.ConcernTypeCategories x
    WHERE x.ConcernTypeId = ct.ConcernTypeId
      AND x.CategoryId = c.catagoryID
);
GO

CREATE OR ALTER PROCEDURE dbo.sp_ConcernType_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ct.ConcernTypeId,
        ct.ConcernType AS Name,
        ct.description AS Description,
        ct.IsActive,
        CategoryIdsCsv = (
            SELECT STRING_AGG(CAST(cc.CategoryId AS NVARCHAR(20)), ',')
            FROM dbo.ConcernTypeCategories cc
            WHERE cc.ConcernTypeId = ct.ConcernTypeId
        ),
        CategoryNamesCsv = (
            SELECT STRING_AGG(c.categorytype, ', ')
            FROM dbo.ConcernTypeCategories cc
            INNER JOIN dbo.Category c ON c.catagoryID = cc.CategoryId
            WHERE cc.ConcernTypeId = ct.ConcernTypeId
        )
    FROM dbo.ConcernTypes ct
    WHERE ct.IsActive = 1
    ORDER BY ct.ConcernType;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ConcernType_GetById
    @ConcernTypeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ct.ConcernTypeId,
        ct.ConcernType AS Name,
        ct.description AS Description,
        ct.IsActive,
        CategoryIdsCsv = (
            SELECT STRING_AGG(CAST(cc.CategoryId AS NVARCHAR(20)), ',')
            FROM dbo.ConcernTypeCategories cc
            WHERE cc.ConcernTypeId = ct.ConcernTypeId
        ),
        CategoryNamesCsv = (
            SELECT STRING_AGG(c.categorytype, ', ')
            FROM dbo.ConcernTypeCategories cc
            INNER JOIN dbo.Category c ON c.catagoryID = cc.CategoryId
            WHERE cc.ConcernTypeId = ct.ConcernTypeId
        )
    FROM dbo.ConcernTypes ct
    WHERE ct.ConcernTypeId = @ConcernTypeId;
END
GO

PRINT 'Migration 014 complete.';
