-- =====================================================================================================
-- Author:      Nick Airdo
-- Create Date: 4/12/2020
-- Description: Displays information about the state of workflow logging on the server. 
--              On larger systems consider adding a TOP 100.
--
--              Logging Level Key
--              0 = None
--              1 = Workflow
--              2 = Activity
--              3 = Action
--
-- Change History:
--   
-- =====================================================================================================

SELECT 
    t.[Name], 
    t.[Id] AS [WorkflowTypeId], 
    t.[LoggingLevel],
    t.[LogRetentionPeriod],
    COUNT(1) AS [NumberOfLogRecords] 
FROM 
    [WorkflowLog] l
    INNER JOIN [Workflow] w ON w.[Id] = l.[WorkflowId]
    INNER JOIN [WorkflowType] t ON t.[Id] = w.[WorkflowTypeId]
GROUP BY 
    t.[Name], t.[Id], t.[LoggingLevel],[LogRetentionPeriod]
