-- =====================================================================================================
-- Author:      Nick Airdo
-- Create Date: 4/21/2020
-- Description: Lists active workflow types and some critical 'health check' data about them
--              ordered by the number of active worflows.
--
-- Change History:
--   
-- =====================================================================================================
SELECT 
  [Id], 
  [Name],
  
    CASE 
	WHEN ( [CompletedWorkflowRetentionPeriod] IS NULL OR [CompletedWorkflowRetentionPeriod] = '' OR [CompletedWorkflowRetentionPeriod] = 0 )  THEN 'forever'
	ELSE CAST([CompletedWorkflowRetentionPeriod] AS varchar) + ' days'
	END  as 'CompletedWorkflowRetentionPeriod',

  CASE 
	WHEN ( [LogRetentionPeriod] IS NULL OR [LogRetentionPeriod] = '' OR [LogRetentionPeriod] = 0 )  THEN 'forever'
	ELSE CAST([LogRetentionPeriod] AS varchar) + ' days'
	END  as 'LogRetentionPeriod',

  CASE 
	WHEN ( [LoggingLevel] = 0 )  THEN 'off'
	WHEN ( [LoggingLevel] = 1 )  THEN 'low'
	WHEN ( [LoggingLevel] = 2 )  THEN 'med'
	WHEN ( [LoggingLevel] = 3 )  THEN 'high'
	ELSE CAST([LoggingLevel] AS varchar)
	END  as 'LoggingLevel',

  CASE 
	WHEN ( [ProcessingIntervalSeconds] IS NULL OR [ProcessingIntervalSeconds] = '' OR [ProcessingIntervalSeconds] = 0 )  THEN 'always'
	ELSE CAST([ProcessingIntervalSeconds] AS varchar)
	END  as 'ProcessingIntervalSeconds',

 ( SELECT COUNT(*) FROM [WorkflowLog] wl INNER JOIN [Workflow] w ON w.Id = wl.WorkflowId WHERE w.[WorkflowTypeId] = wt.Id ) as '# Logs',
 ( SELECT COUNT(1) FROM [Workflow] w2 WHERE w2.[WorkflowTypeId] = wt.Id AND ( NOT ( w2.[Status] = 'Completed' OR w2.[CompletedDateTime] IS NOT NULL ) ) ) as '# Active Workflows',
  [IsPersisted]
FROM [WorkflowType] wt
WHERE IsActive = 1
ORDER BY ( SELECT COUNT(1) FROM [Workflow] w2 WHERE w2.[WorkflowTypeId] = wt.Id AND ( NOT ( w2.[Status] = 'Completed' OR w2.[CompletedDateTime] IS NOT NULL ) ) ) DESC