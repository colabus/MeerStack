USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Shares_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @ShareName varchar(100),
            @Path varchar(MAX),
            @Description varchar(MAX),
            @Status varchar(50),
            @Type varchar(100),
            @Access nvarchar(MAX)

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

	DELETE FROM
		dbo.Shares
	WHERE
		Hostname = @Hostname

	INSERT INTO dbo.Shares
		(Hostname, Timestamp, Name, Path, Description, Status, Type)
    SELECT
		@Hostname,
		@Timestamp,
        JSON_VALUE(Share.value, '$.Name'),
        JSON_VALUE(Share.value, '$.Path'),
        JSON_VALUE(Share.value, '$.Description'),
        JSON_VALUE(Share.value, '$.Status'),
        JSON_VALUE(Share.value, '$.Type')
    FROM
        OPENJSON(@Payload, '$.Shares') AS Share

	DELETE FROM
		dbo.SharePermissions
	WHERE
		Hostname = @Hostname

	INSERT INTO dbo.SharePermissions
		(Hostname, Timestamp, ShareName, AccountName, AccessRight, AccessControlType)
	SELECT
		JSON_VALUE(@Payload, '$.Hostname'),
		JSON_VALUE(@Payload, '$.Timestamp'),
		JSON_VALUE(Share.value, '$.Name'),
		JSON_VALUE(Access.value, '$.AccountName'),
		JSON_VALUE(Access.value, '$.AccessRight'),
		JSON_VALUE(Access.value, '$.AccessControlType')
	FROM
		OPENJSON(@Payload, '$.Shares') AS Share
			CROSS APPLY
		OPENJSON(Share.value, '$.Access') AS Access
END
GO
