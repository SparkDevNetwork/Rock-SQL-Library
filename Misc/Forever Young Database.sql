-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 12/15/2021
-- Description: Updates every date field in the database by a giving number of days. It also updates
--				all attribute values that are dates.
--
--              Takes around 5-13 seconds to run on the demo database.
--
-- Change History:
--   10/01/2025 - NA
--       * Updated to avoid 'date' column overflow.
--       * Updated to swallow any "Cannot insert duplicate key row in object" (2601/2627) errors.
--   03/04/2025 - NA
--       * Updated to include *DateKey columns (system_type_id = 56 AND Column Name like '%DateKey' )
--   04/20/2022 - NA
--       * Updated to also change Date columns  (system_type_id = 40).
--       * Changed to weeks so that we can also easily adjust the SundayDate column data too.
--       * Changed to not update if the date would land into the future.
--       * Updated to exclude the AnalyticsSourceDate table.
-- =====================================================================================================

DECLARE @NumWeeksForward int = 10 -- The number of weeks to add to each date

-------------------------------------------------------------------------------------------------------
DECLARE @Sql NVARCHAR(MAX) = N'
   SET NOCOUNT ON;
   SET XACT_ABORT OFF; -- why: allow statement-level failures to not abort the batch
   DECLARE @Now DATETIME = GETDATE();
';

------------------------------

-- BEGIN TRANSACTION -- (uncomment for testing purposes)

-- Update every date time field in the database (but not if it pushes it into the future)
SELECT @Sql += N'
BEGIN TRY
   UPDATE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) 
     + N' SET ' + QUOTENAME(c.name) + N' = DATEADD( WK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', ' + QUOTENAME(c.name) + N')'
	 + N' WHERE @Now > DATEADD( WK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', ' + QUOTENAME(c.name) + N')'
     + N' AND ' + QUOTENAME(c.name) + N' <= DATEADD( WK, -' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', CONVERT(date, ''99991231''));'
+ N'
END TRY
BEGIN CATCH
   IF ERROR_NUMBER() NOT IN (2601, 2627) THROW; -- why: swallow only duplicate key violations
END CATCH;
'
FROM sys.columns AS c 
 INNER JOIN sys.tables  AS t ON c.[object_id] = t.[object_id]
 INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id]
 WHERE ( c.[system_type_id] = 61 OR c.[system_type_id] = 40 ) AND ( t.[name] <> 'AnalyticsSourceDate' AND t.[name] <> 'AnalyticsSourcePersonHistorical' )
 ORDER BY t.[name], c.[name]

-- Also update every DATE KEY field in the database (but not if it pushes it into the future)
SELECT @Sql += N'
BEGIN TRY
   UPDATE ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) 
	 + N' SET ' + QUOTENAME(c.name) + N' = CONVERT(INT, FORMAT(DATEADD(WEEK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', '
	 +       N'CONVERT(DATE, CAST(' + QUOTENAME(c.name) + N' AS CHAR(8)), 112)), ''yyyyMMdd''))'
	 + N' WHERE ' + QUOTENAME(c.name) + N' IS NOT NULL'
     + N' AND @Now > DATEADD( WK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', CONVERT(DATE, CAST(' + QUOTENAME(c.name) + N' AS CHAR(8)), 112))'
     + N' AND CONVERT(DATE, CAST(' + QUOTENAME(c.name) + N' AS CHAR(8)), 112) <= DATEADD( WK, -' + CAST(@NumWeeksForward AS VARCHAR(10)) + N', CONVERT(date, ''99991231''));'
+ N'
END TRY
BEGIN CATCH
   IF ERROR_NUMBER() NOT IN (2601, 2627) THROW;
END CATCH;
'
FROM sys.columns AS c 
 INNER JOIN sys.tables  AS t ON c.[object_id] = t.[object_id]
 INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id]
 WHERE ( c.[system_type_id] = 56 AND c.[name] like '%DateKey' ) AND ( t.[name] <> 'AnalyticsSourceDate' AND t.[name] <> 'AnalyticsSourcePersonHistorical')
 ORDER BY t.[name], c.[name];

EXEC sp_executesql @Sql

-- Update date time attribute values
BEGIN TRY
UPDATE [AttributeValue]
SET [Value] = FORMAT( DATEADD( WK, @NumWeeksForward, [ValueAsDateTime]) , 'M/d/yyyy h:m:s tt', 'en-US' )
WHERE [ValueAsDateTime] IS NOT NULL
  AND [ValueAsDateTime] <= DATEADD( WK, -@NumWeeksForward, CONVERT(date, '99991231') );
END TRY
BEGIN CATCH
   IF ERROR_NUMBER() NOT IN (2601, 2627) THROW;
END CATCH;

-- ROLLBACK TRANSACTION -- (uncomment for testing purposes)