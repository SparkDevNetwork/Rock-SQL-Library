-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/1/2020
-- Description: Displays a data views with information on usage and performance. 
--              Note this requires Rock v11. 
--
-- Change History:
--   4/2/2020 Jon Edmiston: Updated SQL to consider "Related Data Views"
-- =====================================================================================================

SELECT 
    dv.[Id], 
    dv.[Name], 
    c.[Name] AS [Category],
    ([TimeToRunMs]) [Time To Run Ms], 
    CAST (([TimeToRunMs] / 1000 ) AS decimal (6,2)) [Time To Run Sec], 
    CAST (([TimeToRunMs] / 1000 / 60) AS decimal (6,2))    [Time To Run Min],
    [LastRunDateTime], 
    [RunCount], 
    ([PersistedScheduleIntervalMinutes] / 60) AS [Persisted Hrs],
    ISNULL((SELECT COUNT(*) FROM [DataViewFilter] dvf 
        WHERE dvf.[Selection] LIKE  '%"DataViewId":' + CONVERT( varchar(10), dv.[Id]) + ',%' OR CONVERT( varchar(36), dv.[Guid] ) =  dvf.[Selection]
    ), 0) AS [Parent Data Views]
FROM 
    [DataView] dv
    INNER JOIN [Category] c ON c.[Id] = dv.[CategoryId]
--WHERE dv.[Id] = 160
ORDER BY [TimeToRunMs] DESC