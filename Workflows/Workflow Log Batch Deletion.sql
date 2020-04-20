-- =====================================================================================================
-- Author:      Nick Airdo
-- Create Date: 3/25/2019
-- Description: SSMS Script that deletes old workflow logs (that are outside the retention period) in batches.
--              WARNING!!! This deletes data and also requires SSRS to see the output in the Messages tab.
--              Adjust the BATCHSIZE and LIMIT to fit your needs.
--
-- Change History:
--   
-- =====================================================================================================

SET NOCOUNT ON;
 
/*
* Limits you can set
*/ 
DECLARE @BATCHSIZE INT = 5000;
DECLARE @LIMIT INT = 20000;
 
 
/* Don't touch the code below */
DECLARE @r INT;
DECLARE @Counter INT;
DECLARE @TotalDeleted INT = 0;
DECLARE @StartTime DATETIME;
 
SET @r = 1;
SET @counter = 1;
 
-- How many are there?
DECLARE @TOTAL INT = (
              SELECT COUNT(1)
              FROM [WorkflowLog] wl WHERE wl.[WorkflowId] IN (
                     SELECT w.[Id] 
                     FROM [Workflow] w
                     INNER JOIN [WorkflowType] wt ON wt.[Id] = w.[WorkflowTypeId]
                     WHERE
                     w.[Status] = 'Completed'
                     AND wt.[LogRetentionPeriod] IS NOT NULL
                     AND w.[ModifiedDateTime] < DateAdd( d, - wt.[LogRetentionPeriod], GetDate() )
              )
)
 
RAISERROR( N'Preparing to delete %d workflow logs in batches of %d with a limit of %d.', 0, 1, @TOTAL, @BATCHSIZE, @LIMIT ) WITH NOWAIT
 
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION;
       SET @StartTime = GETDATE();
       DELETE TOP (@BATCHSIZE) FROM [WorkflowLog] WHERE [WorkflowId] IN
       (
              SELECT w.[Id]
              FROM [Workflow] w
              INNER JOIN [WorkflowType] wt ON wt.[Id] = w.[WorkflowTypeId]
              WHERE
              w.[Status] = 'Completed'
              AND wt.[LogRetentionPeriod] IS NOT NULL
              AND w.[ModifiedDateTime] < DateAdd( d, - wt.[LogRetentionPeriod], GetDate() )
       )
 
  SET @r = @@ROWCOUNT;
  SET @TotalDeleted = @TotalDeleted + @r;
 
  COMMIT TRANSACTION;
 
 -- Because you may be deleting a ton of records, you may need to worry about transaction logging 
  CHECKPOINT;    -- if using "Simple" recovery model 
  -- BACKUP LOG ... -- if using "Full" recovery model
 
  PRINT ' ' + CONVERT(varchar, GETDATE(), 120) + '...batch ' + CAST(@counter as varchar(10)) + ' deleted ' + CAST(@r as varchar(10)) + ' rows in ' + CAST( DATEDIFF(s, @StartTime, GetDate()) as varchar(5) )+ ' seconds. Total removed: ' + CAST(@TotalDeleted as varchar(12))
  SET @counter = @Counter + 1;
 
  IF @LIMIT <= @TotalDeleted
  BEGIN
       PRINT 'Limit exceeded, exiting.'
       SET @r = 0;
  END
 
END
