-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/23/2020
-- Description: Displays the number of interactions for each component of a channel for a number of days back
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @InteractionChannelId int = 23   -- Id of the Interaction Channel you want to filter on
DECLARE @DaysBack int = -1               -- The number of days back to look. Use -1 if you want all

-------------------------------------------------------------------------------------------------------

DECLARE @DaysBackDays int = @DaysBack * -1
DECLARE @StartDate datetime = (SELECT DATEADD (day , @DaysBackDays , GETDATE() ) )

------------------------------

-- Using two different selects as checking the InteractionDateTime is slower and we may not care about it
IF ( @DaysBack = -1 )
    BEGIN
        SELECT  
            ic.[Id]
            , ic.[Name]
            , (SELECT COUNT(*) FROM [Interaction] i WHERE i.[InteractionComponentId] = ic.[Id]  ) AS [InteractionCount]
        FROM [InteractionComponent] ic 
        WHERE 
            ic.[InteractionChannelId] = @InteractionChannelId
        ORDER BY ic.[Name]
    END;

ELSE
    BEGIN
        SELECT  
            ic.[Id]
            , ic.[Name]
            , (SELECT COUNT(*) FROM [Interaction] i WHERE i.[InteractionComponentId] = ic.[Id] AND [InteractionDateTime] >= @StartDate  ) AS [InteractionCount]
        FROM [InteractionComponent] ic 
        WHERE 
            ic.[InteractionChannelId] = @InteractionChannelId
        ORDER BY ic.[Name]
    END; 



    