-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 12/15/2021
-- Description: Updates every date field in the database by a giving number of days. It also updates
--				all attribute values that are dates.
--
--              Takes around 4-11 seconds to run on the demo database.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @NumDaysForward int = 10 -- The number of days to add to each date

-------------------------------------------------------------------------------------------------------
DECLARE @Sql NVARCHAR(MAX) = N''

------------------------------

-- Update every date time field in the database
SELECT @Sql += N'
   UPDATE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) 
     + ' SET ' + QUOTENAME(c.name) + ' = DATEADD( day, ' + CAST(@NumDaysForward AS VARCHAR(10)) + ', ' + QUOTENAME(c.name) + ')'
FROM sys.columns AS c 
 INNER JOIN sys.tables  AS t ON c.[object_id] = t.[object_id]
 INNER JOIN sys.schemas AS s ON t.[schema_id] = s.[schema_id]
 WHERE c.system_type_id = 61;

EXEC sp_executesql @Sql

-- Update date time attribute values
UPDATE [AttributeValue]
SET [Value] = FORMAT( DATEADD( day, @NumDaysForward, [ValueAsDateTime]) , 'M/d/yyyy h:m:s tt', 'en-US' )
WHERE [ValueAsDateTime] IS NOT NULL
