
-- =====================================================================================================
-- Author:      Ethan Drotning
-- Create Date: 5/13/2020
-- Description: Enables foriegn key indexes that were disabled by bacpac and failed to enable.
-- Note:		Exporting to a bacpac file from Azure is not transitionally consistent. Because of this
--				the file may contain rows that cause a constraint failure when the indexes are enabled
--				after all of the data has been inserted. This script will check for those indexes, delete
--				rows that are causing the constraint, and then enable the FK index constraint.
--
--				To avoid the problem altogether MS recommends creating a bacpac file while writes are
--				turned off, or use a copy of the DB that is not having anything written to it.
--
--				This script is intended to correct the FK constraints of a non-production copy of the 
--				production DB that was made using a bacpac file.
--
-- Change History:
--   
-- =====================================================================================================

DECLARE @sqlAlterTable varchar(max);
DECLARE @sqlDeleteViolations varchar(max);

DECLARE cursor_AlterTable CURSOR FOR
	SELECT 
		'ALTER TABLE [dbo].[' + o.name + '] WITH CHECK CHECK CONSTRAINT [' + k.[name] + '];',
		'DELETE FROM [dbo].[' + o.name + '] WHERE ' + childColumn.name + ' not in (select ' + parentColumn.name + ' from ' + o2.name + ')'
	FROM sys.foreign_keys k
	join sys.objects o on k.parent_object_id = o.object_id
	join sys.objects o2 on k.referenced_object_id = o2.object_id
	join sys.foreign_key_columns kc on k.object_id = kc.constraint_object_id
	join sys.columns childColumn on kc.parent_object_id = childColumn.object_id and kc.parent_column_id = childColumn.column_id
	join sys.columns parentColumn on kc.referenced_object_id = parentColumn.object_id and kc.referenced_column_id = parentColumn.column_id
	WHERE [is_disabled] = 1 
		AND [is_not_trusted] = 1
	ORDER BY k.[name];

OPEN cursor_AlterTable;

FETCH NEXT FROM cursor_AlterTable INTO @sqlAlterTable, @sqlDeleteViolations;
WHILE @@FETCH_STATUS = 0
BEGIN
	BEGIN TRY
		PRINT @sqlAlterTable;
		EXEC (@sqlAlterTable);
	END TRY
	
	BEGIN CATCH
		PRINT @sqlDeleteViolations;
		EXEC(@sqlDeleteViolations);
		PRINT @sqlAlterTable;
		EXEC (@sqlAlterTable);
	END CATCH

	FETCH NEXT FROM cursor_AlterTable INTO @sqlAlterTable, @sqlDeleteViolations;
END;

CLOSE cursor_AlterTable;
DEALLOCATE cursor_AlterTable;

PRINT 'Foreign Key repair complete'