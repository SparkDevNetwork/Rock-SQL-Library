
-- =====================================================================================================
-- Author:      Ethan Drotning
-- Create Date: 11/30/2020
-- Description: This script will insert a configured number of communications for every person who has a
--				phone with SMS enabled. Each Recipeint will have configured number of responses.
--
-- Note:		To get the best impact for load testing run the insert plethora of persons script before
--				running this script.
-- WARNING!!!	This script will take at least 2 seconds per communication/recipient/response. The delays
--				are too space out the data by an increment displayed in the UI. If this is not needed
--				then remove or reduce the WAITFOR DELAY values.
--
-- Change History:
--   
-- =====================================================================================================

-- Settings
declare @NumberOfCommunications int = 2
declare @NumberOfResponsesPerCommunication int = 1
declare @SenderPersonId int = 1 -- 1 is the default Admin person


-- Gathered values needed by the queries, shouldn't need to be edited unless specifying a specific @SMSFromDefinedValueId or sender
declare @SMSFromDefinedValueId int = (SELECT TOP 1 v.[Id] FROM [DefinedType] t JOIN [DefinedValue] v ON t.[Id] = v.[DefinedTypeId] WHERE t.[Guid] = '611BDE1F-7405-4D16-8626-CCFEDB0E62BE')
declare @SenderName nvarchar(100) = (SELECT FirstName + ' ' + LastName FROM Person WHERE Id = @SenderPersonId)
declare @SenderPersonAliasId int = (SELECT TOP 1 [Id] FROM [PersonAlias] WHERE PersonId = @SenderPersonId ORDER BY [Id] DESC )
declare @SMSMediumEntityTypeId int = (SELECT Id FROM [EntityType] WHERE [Guid] = '4BC02764-512A-4A10-ACDE-586F71D8A8BD')
declare @TransportEntityTypeId int = (SELECT [Id] FROM EntityType WHERE [Name] = 'Rock.Communication.Transport.Twilio')
declare @mobilePhoneTypeDefinedValueId int = (select dv.[Id] from [DefinedType] dt JOIN [DefinedValue] dv ON dt.[Id] = dv.[DefinedTypeId] WHERE dt.[Guid] = '8345DD45-73C6-4F5E-BEBD-B77FC83F18FD' AND dv.[Value] = 'Mobile')
declare @RecipientPersonId int = 0

DECLARE PersonCursor CURSOR FOR SELECT p.Id FROM Person p JOIN PhoneNumber n ON p.Id = n.PersonId WHERE n.IsMessagingEnabled = 1
OPEN PersonCursor
FETCH NEXT FROM PersonCursor INTO @RecipientPersonId
WHILE @@FETCH_STATUS = 0
BEGIN

	declare @RecipientName nvarchar(100) = (SELECT FirstName + ' ' + LastName FROM Person WHERE Id = @RecipientPersonId)
	declare @RecipientPersonAliasId int = (SELECT TOP 1 [Id] FROM [PersonAlias] WHERE PersonId = @RecipientPersonId ORDER BY [Id] DESC )
	declare @CommunicationIterations int = 0
	declare @ResponsesInterations int = 0
	declare @dtNow DATETIME
	declare @SendDataKey int
	declare @CommunicationId int
	declare @SentMessage nvarchar(max)
	declare @ResponseCode varchar(6)
	declare @phoneNumber varchar(20)

	BEGIN TRY
	BEGIN TRANSACTION
	WHILE @CommunicationIterations <= @NumberOfCommunications
	BEGIN
		SET @ResponsesInterations = 0
		SET @dtNow = GETDATE()
		SET @SendDataKey = (CONVERT(INT, CONVERT(VARCHAR(8), @dtNow, 112)))
		SET @ResponseCode = '@' + (SELECT RIGHT('00000' + CONVERT(VARCHAR(5), @CommunicationIterations), 5))
		SET @SentMessage = 'This Communication message is iteration number ' + CONVERT(nvarchar(50), @CommunicationIterations)
		SET @phoneNumber = (SELECT [Number] FROM [PhoneNumber] WHERE [PersonId] = @RecipientPersonId AND NumberTypeValueId = @mobilePhoneTypeDefinedValueId AND IsMessagingEnabled = 1)

		-- INSERT the communication
		INSERT INTO Communication( [Status], [AdditionalMergeFieldsJson], [Guid], [CreatedDateTime], [ModifiedDateTime], [CreatedByPersonAliasId], [IsBulkCommunication], [SenderPersonAliasId], [Name], [CommunicationType], [SegmentCriteria], [SMSFromDefinedValueId], [SMSMessage], [SendDateTime], [ExcludeDuplicateRecipientAddress], [SendDateKey])
		VALUES(3, '[]', NEWID(), @dtNow, @dtNow, @SenderPersonAliasId, 0, @SenderPersonAliasId, 'From: ' + @SenderName, 2, 0, @SMSFromDefinedValueId, @SentMessage, @dtNow, 0, @SendDataKey )

		SET @CommunicationId = @@IDENTITY

		-- INSERT CommunicationRecipient
		INSERT INTO [CommunicationRecipient]([CommunicationId], [Status], [AdditionalMergeValuesJson], [Guid], [CreatedDateTime], [ModifiedDateTime], [CreatedByPersonAliasId], [TransportEntityTypeName], [UniqueMessageId], [ResponseCode], [PersonAliasId], [MediumEntityTypeId], [SendDateTime], [SentMessage])
		VALUES (@CommunicationId, 1, '{}', NEWID(), @dtNow, @dtNow, @SenderPersonAliasId, 'Rock.Communication.Transport.Twilio', 'SM' + CONVERT(varchar(40), NEWID()), @ResponseCode, @RecipientPersonAliasId, @SMSMediumEntityTypeId, @dtNow, @SentMessage)

		-- Insert Responses
		WHILE @ResponsesInterations <= @NumberOfResponsesPerCommunication
		BEGIN
		
			INSERT INTO CommunicationResponse([MessageKey], [FromPersonAliasId], [IsRead], [RelatedSmsFromDefinedValueId], [RelatedCommunicationId], [RelatedTransportEntityTypeId], [RelatedMediumEntityTypeId], [Response], [CreatedDateTime], [ModifiedDateTime], [Guid])
			VALUES(@phoneNumber, @RecipientPersonAliasId, 1, @SMSFromDefinedValueId, @CommunicationId, @TransportEntityTypeId, @SMSMediumEntityTypeId, 'Response for Communication: ' + CONVERT(NVARCHAR(50), @CommunicationId) + ', Iteration: ' + CONVERT(NVARCHAR(50), @ResponsesInterations) , @dtNow, @dtNow, NEWID())

			WAITFOR DELAY '00:00:01';
			SET @ResponsesInterations += 1
		END

		SET @CommunicationIterations += 1
		WAITFOR DELAY '00:00:01';
	END

	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	END CATCH

	FETCH NEXT FROM PersonCursor INTO @RecipientPersonId
END
CLOSE PersonCursor
DEALLOCATE PersonCursor
