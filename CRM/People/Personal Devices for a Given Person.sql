-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 7/23/2020
-- Description: Displays information about a person's personal devices.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @PersonId int = 15981  -- The person we're interested in seeing devices for.

-------------------------------------------------------------------------------------------------------

SELECT 
    [IsActive]
    , (SELECT [Value] FROM [DefinedValue] WHERE [Id] = pd.[PlatformValueId]) AS [Platform]
    , (SELECT [Value] FROM [DefinedValue] WHERE [Id] = pd.[PersonalDeviceTypeValueId]) AS [Device Type]
    , [NotificationsEnabled]
    , pd.[CreatedDateTime]
    , pd.[ModifiedDateTime]
    , [MACAddress]
    , [DeviceUniqueIdentifier]
    , [DeviceRegistrationId]
    , [MACAddress]
    , pd.*
FROM [PersonalDevice] pd
    INNER JOIN [PersonAlias] pa ON pa.[Id] = pd.[PersonAliasId]
    INNER JOIN [Person] p ON p.[Id] = pa.[PersonId]
WHERE 
    p.[Id] = @PersonId