-- =====================================================================================================
-- Author:      Nick Airdo
-- Create Date: 8/20/2019
-- Description: Displays information on the top 10 largest database tables.
--
-- Change History:
--   
-- =====================================================================================================

SELECT Top 10
    t.NAME AS TableName,
    s.Name AS SchemaName,
    FORMAT( p.rows, 'N0')  AS RowCounts,
    FORMAT( SUM(a.total_pages) * 8 / 1024, 'N0') AS TotalSpaceMB, 
    FORMAT( SUM(a.used_pages) * 8 / 1024, 'N0') AS UsedSpaceMB, 
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024 AS UnusedSpaceMB
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
GROUP BY 
    t.Name, s.Name, p.Rows
ORDER BY 
    SUM(a.used_pages) desc