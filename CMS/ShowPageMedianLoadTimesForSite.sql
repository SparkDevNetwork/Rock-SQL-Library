-- =====================================================================================================
-- Author:      Mike Peterson
-- Create Date: 9/29/2020
-- Description: Returns MedianPageLoadTimeDurationSeconds for Pages related to the specified @SiteId
--
-- Change History:
--   
-- =====================================================================================================
DECLARE @SiteId INT = 8 -- The site we're interested in seeing median page load times for
DECLARE @IncludePagesWithoutMedianPageLoadTimes BIT = 0 -- set this to 1 to include pages that haven't had views or MedianPageLoadTimeDurationSeconds calculated

-- Print the Site Name to confirm that we're looking at the correct site
DECLARE @SiteName nvarchar(100) = (SELECT TOP 1 [Name] [Site.Name] FROM [Site] WHERE [Id] = @SiteId )

-- List Median Page Load Times (in seconds) 
SELECT 
    @SiteName AS [SiteName]
    , [p].[Id] AS [PageId]
    , [p].[InternalName]
    , [p].[PageTitle]
    , [p].[MedianPageLoadTimeDurationSeconds]
FROM [Page] p
WHERE [p].[LayoutId] IN (
		SELECT [Id]
		FROM [Layout]
		WHERE [SiteId] = @SiteId
		) AND (@IncludePagesWithoutMedianPageLoadTimes = 1 OR [p].[MedianPageLoadTimeDurationSeconds] IS NOT NULL)
ORDER BY [p].[MedianPageLoadTimeDurationSeconds] DESC