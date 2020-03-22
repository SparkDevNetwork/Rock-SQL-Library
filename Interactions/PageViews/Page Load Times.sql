-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 3/22/2020
-- Description: Displays page load times for a specified page. Also displays who loaded the page if 
--              known.
-- ...
-- Parameters:
--   @PageId - Id of the page you want timings from. 
--   @MaxRows - The maximum number of rows to return
-- =====================================================================================================


DECLARE @PageId int = 1
DECLARE @MaxRows int = 1000

SELECT
    TOP(@MaxRows) [InteractionTimeToServe], [InteractionDateTime], p.[NickName], p.[LastName]
   
FROM
    [Interaction] i
    INNER JOIN [InteractionComponent] ic ON ic.[Id] = i.[InteractionComponentId]
    LEFT OUTER JOIN [PersonAlias] pa ON pa.[Id] = i.[PersonAliasId]
    LEFT OUTER JOIN [Person] p ON p.[Id] = pa.[PersonId]
WHERE
    i.[EntityId] = @PageId AND [InteractionTimeToServe] IS NOT NULL
    AND [InteractionDateTime] > '3/20/2020'
ORDER BY [InteractionTimeToServe] DESC
--ORDER BY [InteractionDateTime] DESC