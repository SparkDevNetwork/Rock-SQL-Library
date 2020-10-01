-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 10/1/2020
-- Description: Returns a list of binary files that are larger than a pre-defined size.
--
-- Change History:
--   
-- =====================================================================================================
DECLARE @MaxSize FLOAT = 1.1 -- The threshold size in MB.

-------------------------------------------------------------------------------------------------------

SELECT @MaxSize = @MaxSize * 1000000

-------------------------------------------------------------------------------------------------------

SELECT
    bf.[Id]
    ,[BinaryFileTypeId]
    ,[FileName]
    ,[MimeType]
    , et.[FriendlyName]
    , bf.[CreatedDateTime]
    , p.[FirstName] + ' ' + p.[LastName] AS [Created By]
    ,[Path]
    ,[FileSize]
    ,[Width]
    ,[Height]
  FROM [dbo].[BinaryFile] bf
    INNER JOIN [EntityType] et ON et.[Id] = bf.[StorageEntityTypeId]
    LEFT OUTER JOIN [PersonAlias] pa ON pa.[Id] = bf.[CreatedByPersonAliasId]
    LEFT OUTER JOIN [Person] p ON p.[Id] = pa.[PersonId]
  WHERE [FileSize] > @MaxSize