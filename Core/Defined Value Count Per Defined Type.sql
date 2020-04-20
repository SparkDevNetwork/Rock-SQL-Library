-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/20/2020
-- Description: Lists the number of defined values for each defined type.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @MinimumDefinedValuesToList int = 0      -- The number of defined values that a type needs to have to be 
                                                     -- listed. Consider making this 100 to look for defined types with
                                                     -- too many defined values. Leave it 0 to show all defined types.
-------------------------------------------------------------------------------------------------------

SELECT 
    dt.[Id]
    ,[Name]
    ,COUNT(dv.[Id]) as [DefinedValueCount]
  FROM [DefinedType] dt
    INNER JOIN [DefinedValue] dv ON dv.[DefinedTypeId] = dt.[Id]
 GROUP BY dt.[Id], dt.[Name]
 HAVING COUNT(dv.[Id]) > @MinimumDefinedValuesToList
 ORDER BY [DefinedValueCount] DESC