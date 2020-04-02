-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/2/2020
-- Description: Displays information on which Azure SQL service level the server is running.
--
-- Change History:
--   
-- =====================================================================================================

SELECT  d.[Name] AS [Database Name],   
     slo.*    
FROM 
    sys.databases d   
    INNER JOIN sys.database_service_objectives slo ON d.database_id = slo.database_id;