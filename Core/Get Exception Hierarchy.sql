-- =====================================================================================================
-- Author:      Ethan Drotning
-- Create Date: 3/26/2020
-- Description: Gets the parent and children of an exception ID
-- Note:		Use this if you want to see the chain of events for a specific exception (e.g. an inner exception)
--				For instance a description can be queried for such as '%timeout expired%' and the Id can be plugged
--				into this query to see the parents and children of the exception.
--
--				This pattern can be used for any self referencing table.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @exceptionId INT = 0;		-- The ID of the exception

-------------------------------------------------------------------------------------------------------

DECLARE @parentExceptionId INT = 0;

-------------------------------------------------------------------------------------------------------

-- First get the top parent
WITH ParentCTE AS (
	SELECT * FROM dbo.[ExceptionLog] WHERE [Id] = @exceptionId 
	UNION ALL
	SELECT A.* FROM dbo.[ExceptionLog] A INNER JOIN ParentCTE B ON B.[ParentId] = A.[Id]
)

SELECT @parentExceptionId = [Id] FROM ParentCTE WHERE [ParentId] IS NULL;

-- Find all the children from the top parent
WITH ChildrenCTE AS (
	SELECT * FROM dbo.[ExceptionLog] WHERE [Id] = @parentExceptionId
	UNION ALL
	SELECT A.* FROM dbo.[ExceptionLog] A INNER JOIN ChildrenCTE B ON B.[Id] = A.[ParentId]
)

SELECT [Id], [ParentId], [ExceptionType], [Description], [Source], [StackTrace], [CreatedDateTime]
FROM ChildrenCTE
ORDER BY [ParentId];
