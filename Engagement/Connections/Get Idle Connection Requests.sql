-- =====================================================================================================
-- Author:      Jon Edmiston
-- Create Date: 2/23/2021
-- Description: This script will display idle requests for a given Connection Type.
--              Note that we are only filtering on requests with a State of idle (ignoring future follow-ups)/
--              In the next release (v12.2) a job will be changing the State of future follow-ups to active 
--              when their future follow-up date is past.
--
--              This script is meant to be a starting point for other features.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @ConnectionTypeId int = 1  -- The Connection Type we are wanting to filter on.

-------------------------------------------------------------------------------------------------------

SELECT 
    *
FROM
    -- a sub-select to get requests and their days since last activity
    (SELECT
        cr.[Id]
        , ISNULL ( 
                DATEDIFF( 
                    day
                    , (SELECT MAX(cra.[CreatedDateTime]) FROM [ConnectionRequestActivity] cra WHERE cra.[ConnectionRequestId] = cr.[Id] )
                    , GETDATE() )
                , DATEDIFF( day, cr.[CreatedDateTime], GETDATE() )
            ) AS [DaysSinceLastActivity]
    FROM
        [ConnectionRequest] cr
        INNER JOIN [ConnectionOpportunity] co ON co.[Id] = cr.[ConnectionOpportunityId]
        INNER JOIN [ConnectionType] ct ON ct.[Id] = co.[ConnectionTypeId]
    WHERE 
        ct.[Id] = @ConnectionTypeId
        AND [ConnectionState] = 0) AS [Requests]
WHERE 
[DaysSinceLastActivity] > 14
