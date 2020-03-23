-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 3/21/2020
-- Description: Displays page load times for a specified page. Also displays who loaded the page if 
--              known.
-- ...
-- Parameters:
--   @PageId - Id of the page you want timings from. 
--   @MaxRows - The maximum number of rows to return.
--   @DaysBack - The number of days back to look.
--
-- Change History:
--   3/22/2020 Jon Edmiston: Updated SQL to allow passing in Page Id vs having to know ComponentId
-- =====================================================================================================

DECLARE @PageId int = 1247
DECLARE @MaxRows int = 1000
DECLARE @DaysBack int = 1

-------------------------------------------------------------------------------------------------------

SET @DaysBack = @DaysBack * -1
DECLARE @StartDate datetime = (SELECT DATEADD (day , @DaysBack , GETDATE() ) )

SELECT
    TOP (@MaxRows) 
    [InteractionTimeToServe], 
    [InteractionDateTime], 
    p.[NickName], 
    p.[LastName]
FROM
    [Interaction] i
    INNER JOIN [InteractionComponent] ic ON ic.[Id] = i.[InteractionComponentId]
    LEFT OUTER JOIN [PersonAlias] pa ON pa.[Id] = i.[PersonAliasId]
    LEFT OUTER JOIN [Person] p ON p.[Id] = pa.[PersonId]
WHERE
    ic.[EntityId] = @PageId 
    AND [InteractionTimeToServe] IS NOT NULL
    AND [InteractionDateTime] > @StartDate
ORDER BY [InteractionTimeToServe] DESC
--ORDER BY [InteractionDateTime] DESC