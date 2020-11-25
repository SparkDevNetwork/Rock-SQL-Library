
-- =====================================================================================================
-- Author:      Ethan Drotning
-- Create Date: 11/25/2020
-- Description: This script will insert a number of communications and responses to that communication.
-- Note:		Requires a person who has a phone with SMS enabled.
--				SELECT p.* FROM Person p JOIN PhoneNumber n ON p.Id = n.PersonId WHERE n.IsMessagingEnabled = 1
--
--
-- Change History:
--   
-- =====================================================================================================

-- Settings
declare @NumberOfCommunications int = 5
declare @NumberOfResponsesPerCommunication int = 3
declare @RecipientPersonId int = 72
declare @SenderPersonId int = 1 -- 1 is the default Admin person

-- Gathered values needed by the queries, shouldn't need to be edited unless specifying a specific @SMSFromDefinedValueId
declare @SMSFromDefinedValueId int = (SELECT TOP 1 v.[Id] FROM [DefinedType] t JOIN [DefinedValue] v ON t.[Id] = v.[DefinedTypeId] WHERE t.[Guid] = '611BDE1F-7405-4D16-8626-CCFEDB0E62BE')
declare @RecipientName nvarchar(100) = (SELECT FirstName + ' ' + LastName FROM Person WHERE Id = @RecipientPersonId)
declare @RecipientPersonAliasId int = (SELECT TOP 1 [Id] FROM [PersonAlias] WHERE PersonId = @RecipientPersonId ORDER BY [Id] DESC )
declare @SenderName nvarchar(100) = (SELECT FirstName + ' ' + LastName FROM Person WHERE Id = @SenderPersonId)
declare @SenderPersonAliasId int = (SELECT TOP 1 [Id] FROM [PersonAlias] WHERE PersonId = @SenderPersonId ORDER BY [Id] DESC )
declare @SMSMediumEntityTypeId int = (SELECT Id FROM [EntityType] WHERE [Guid] = '4BC02764-512A-4A10-ACDE-586F71D8A8BD')
declare @TransportEntityTypeId int = (SELECT [Id] FROM EntityType WHERE [Name] = 'Rock.Communication.Transport.Twilio')
declare @mobilePhoneTypeDefinedValueId int = (select dv.[Id] from [DefinedType] dt JOIN [DefinedValue] dv ON dt.[Id] = dv.[DefinedTypeId] WHERE dt.[Guid] = '8345DD45-73C6-4F5E-BEBD-B77FC83F18FD' AND dv.[Value] = 'Mobile')

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
	SET @SentMessage = 'This message is iteration number ' + CONVERT(nvarchar(50), @CommunicationIterations)
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
		VALUES(@phoneNumber, @RecipientPersonAliasId, 1, @SMSFromDefinedValueId, @CommunicationId, @TransportEntityTypeId, @SMSMediumEntityTypeId, 'Communication: ' + CONVERT(NVARCHAR(50), @CommunicationId) + ', Iteration: ' + CONVERT(NVARCHAR(50), @ResponsesInterations) , @dtNow, @dtNow, NEWID())

		WAITFOR DELAY '00:00:01';
		SET @ResponsesInterations += 1
	END

	SET @CommunicationIterations += 1
	WAITFOR DELAY '00:00:02';
END

COMMIT TRANSACTION
print 'Finished inserting communications'

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	print @@Error
END CATCH
