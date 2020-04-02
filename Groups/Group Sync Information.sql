-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 4/1/2020
-- Description: Displays a list of the all the group syncs configured for the system and how long 
--              each data view takes to run.
--              This requires Rock v11.
--              Note: Time is in millseconds.
--
-- Change History:
--   
-- =====================================================================================================

SELECT
    g.[Name] AS [Group Name], gtr.[Name] AS [Role], dv.[Name] AS [Data View], dv.[TimeToRunMS]
FROM
    [GroupSync] gs
    INNER JOIN [Group] g ON g.[Id] = gs.[GroupId]
    INNER JOIN [GroupTypeRole] gtr ON gtr.[Id] = gs.[GroupTypeRoleId]
    INNER JOIN [DataView] dv ON dv.[Id] = gs.[SyncDataViewId]
ORDER BY dv.[TimeToRunMS] DESC