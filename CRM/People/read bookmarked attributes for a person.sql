-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 7/23/2020
-- Description: Displays the person's bookmarked attributes.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @PersonId int = 2  -- The person who bookmarked the attributes.
DECLARE @TargetPersonId int = 4 -- The person we want the values for.

-------------------------------------------------------------------------------------------------------


SELECT 
    ba.[Name]
    , bav.[Value]
    , bav.[PersistedTextValue]
FROM [AttributeValue] bav
    INNER JOIN [Attribute] ba ON ba.[Id] = bav.[AttributeId]
WHERE ba.[Id] IN (

        SELECT
            bav.value
        FROM
            [AttributeValue] av
            CROSS APPLY STRING_SPLIT(av.[Value], ',') AS bav
            INNER JOIN [Attribute] a ON a.[Id] = av.[AttributeId] AND a.[Key] LIKE 'Rock.KeyAttributes.%'
        WHERE av.[EntityId] = @PersonId
) AND bav.[EntityId] = @TargetPersonId
