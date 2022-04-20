-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 12/15/2021
-- Description: Updates every date field in the database by a giving number of days. It also updates
--				all attribute values that are dates.
--
--              Takes around 5-13 seconds to run on the demo database.
--
-- Change History:
--   4/20/2022 - NA
--       * Updated to also change Date columns  (system_type_id = 40).
--       * Changed to weeks so that we can also easily adjust the SundayDate column data too.
--       * Changed to not update if the date would land into the future.
--       * Updated to exclude the AnalyticsSourceDate table.
-- =====================================================================================================

DECLARE @NumWeeksForward int = 10 -- The number of weeks to add to each date

-------------------------------------------------------------------------------------------------------
DECLARE @Sql NVARCHAR(MAX) = N'   DECLARE  @Now DATETIME = GETDATE();'

------------------------------

-- Update every date time field in the database (but not if it pushes it into the future)
SELECT @Sql += N'
   UPDATE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) 
     + ' SET ' + QUOTENAME(c.name) + ' = DATEADD( WK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + ', ' + QUOTENAME(c.name) + ')'
	 + ' WHERE @Now > DATEADD( WK, ' + CAST(@NumWeeksForward AS VARCHAR(10)) + ', ' + QUOTENAME(c.name) + ')'
FROM sys.columns AS c 
 INNER JOIN sys.tables  AS t ON c.[object_id] = t.[object_id]
 INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id]
 WHERE ( c.[system_type_id] = 61 OR c.[system_type_id] = 40 ) AND t.[name] <> 'AnalyticsSourceDate'
 ORDER BY t.[name], c.[name]

EXEC sp_executesql @Sql

-- Update date time attribute values
UPDATE [AttributeValue]
SET [Value] = FORMAT( DATEADD( WK, @NumWeeksForward, [ValueAsDateTime]) , 'M/d/yyyy h:m:s tt', 'en-US' )
WHERE [ValueAsDateTime] IS NOT NULL
