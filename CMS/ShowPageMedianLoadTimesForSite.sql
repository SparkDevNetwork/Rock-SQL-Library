-- =====================================================================================================
-- Author:      Mike Peterson
-- Create Date: 9/29/2020
-- Description: Returns MedianPageLoadTimeDurationSeconds for Pages related to the specified @SiteId
--
-- Change History:
--   
-- =====================================================================================================
DECLARE 
  @SiteId INT = 1, -- The site we're interested in seeing median page load times for
  @IncludePagesWithoutMedianPageLoadTimes BIT = 0 -- set this to 1 to include pages that haven't had views or MedianPageLoadTimeDurationSeconds calculated

-- Print the Site Name to confirm that we're looking at the correct site
SELECT [Name] [Site.Name]
FROM [Site]
WHERE [Id] = @SiteId

-- List Median Page Load Times (in seconds) 
SELECT [p].[Id], [p].[InternalName], [p].[PageTitle], [p].[MedianPageLoadTimeDurationSeconds]
FROM [Page] p
WHERE [p].[LayoutId] IN (
		SELECT [LayoutId]
		FROM [Site]
		WHERE [Id] = @SiteId
		) AND (@IncludePagesWithoutMedianPageLoadTimes = 1 OR [p].[MedianPageLoadTimeDurationSeconds] IS NOT NULL)
ORDER BY [p].[InternalName]