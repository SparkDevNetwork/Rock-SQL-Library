-- =====================================================================================================
-- Author:      Nick Airdo
-- Create Date: 3/1/2025
-- Description: Deletes ExceptionLog records older than a specified date in batches.
-- Notes:       Useful for cleaning up old exceptions in a controlled way. The loop deletes in batches 
--              of 5,000 rows to avoid long-running transactions and excessive locking.
--              Set @DeleteOlderThanDate to your desired cutoff.
--              Set @MAX_TIMES_TO_LOOP to limit the number of iterations (for safety or testing).
-- 
--              You can optionally use TRANSACTION statements to test this script without committing changes.
--              Use with caution in production environments.
--
-- PRINT Statement Behavior:
--              SQL Server buffers PRINT statements and sends them to the client only when a batch completes 
--              or the buffer fills. Azure Data Studio may delay these messages more than SSMS due to differences 
--              in how each handles output buffering.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @MAX_TIMES_TO_LOOP INT = 100 -- set to lower if you just want to test.
DECLARE @DeleteOlderThanDate DATETIME = '10/1/2025' 

--BEGIN TRANSACTION -- uncomment if you want to only test (and the ROLLBACK below)

-------------------------------------------------------------------------------------------------------

DECLARE @Rows INT
SET @Rows = 1
DECLARE @Counter INT
SET @Counter = 0

SELECT COUNT(*) FROM ExceptionLog WHERE CreatedDateTime < @DeleteOlderThanDate

WHILE (@Rows > 0 AND @Counter < @MAX_TIMES_TO_LOOP)
BEGIN
    DELETE TOP (5000) FROM ExceptionLog
    WHERE CreatedDateTime < @DeleteOlderThanDate 
    SET @Rows = @@ROWCOUNT
	SET @Counter = @Counter + 1
    -- Display the current loop iteration
    SELECT 'Loop #' AS Message, @Counter AS CurrentLoop, @Rows AS RowsDeleted
    PRINT 'Loop #: ' + CONVERT(VARCHAR, @Counter);
    
    -- This command forces all previous PRINT statements to be sent to the client immediately
    RAISERROR(N'', 0, 1) WITH NOWAIT; 

END

SELECT COUNT(*) FROM ExceptionLog WHERE CreatedDateTime < @DeleteOlderThanDate
--ROLLBACK TRANSACTION -- uncomment if you want to only test
