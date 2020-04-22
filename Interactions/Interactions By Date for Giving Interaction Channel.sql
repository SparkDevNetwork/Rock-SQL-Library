-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/21/2020
-- Description: Displays the number of interactions by date for a given Interaction Channel
--
-- Change History:
--   3/22/2020 Jon Edmiston: Updated SQL to allow passing in Page Id vs having to know ComponentId.
-- =====================================================================================================

DECLARE @InteractionChannelId int = 23      -- Id of the Interaction Channel you want to filter on
DECLARE @DaysBack int = 100       -- The number of days back to look.

-------------------------------------------------------------------------------------------------------

SET @DaysBack = @DaysBack * -1
DECLARE @StartDate datetime = (SELECT DATEADD (day , @DaysBack , GETDATE() ) )

------------------------------

SELECT
    CAST([InteractionDateTime] AS DATE) AS [Date],
    COUNT(i.[Id]) AS [InteractionCount]
FROM
    [Interaction] i 
    INNER JOIN [InteractionComponent] ic ON ic.[Id] = i.[InteractionComponentId]
WHERE ic.[InteractionChannelId] = @InteractionChannelId 
    AND i.[InteractionDateTime] > @StartDate
GROUP BY CAST([InteractionDateTime] AS DATE)
ORDER BY CAST([InteractionDateTime] AS DATE) DESC