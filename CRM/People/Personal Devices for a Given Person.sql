-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 7/23/2020
-- Description: Displays information about a person's personal devices.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @PersonId int = 2  -- The person we're interested in seeing devices for.

-------------------------------------------------------------------------------------------------------

-- Print the name to confirm that we're looking at the correct person
SELECT 
    [NickName]
    , [LastName]
FROM [Person]
WHERE [Id] = @PersonId

-- Display the personal devices
SELECT 
    pd.[Id]
    , [IsActive]
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
ORDER BY 
    pd.[ModifiedDateTime] DESC

-- Return list of device registration Ids which is what the push notification logic does when sending
SELECT 
    DISTINCT [DeviceRegistrationId]
FROM [PersonalDevice] pd
    INNER JOIN [PersonAlias] pa ON pa.[Id] = pd.[PersonAliasId]
    INNER JOIN [Person] p ON p.[Id] = pa.[PersonId]
WHERE 
    p.[Id] = @PersonId
    AND pd.[NotificationsEnabled] = 1
    AND [DeviceRegistrationId] IS NOT NULL 
    AND [DeviceRegistrationId] != ''

-- Handy SQL to delete a personal device. Just highlight and run.
/*
DECLARE @PersonalDeviceId int  = 6214

DELETE FROM [Interaction] WHERE [PersonalDeviceId] = @PersonalDeviceId 

DELETE FROM [PersonalDevice]
WHERE [Id] = @PersonalDeviceId
*/