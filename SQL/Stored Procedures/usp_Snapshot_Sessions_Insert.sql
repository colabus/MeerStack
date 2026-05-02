USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Sessions_Insert]

	@Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

	DECLARE @Hostname varchar(50),
			@Timestamp datetime

	SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

	DELETE FROM dbo.Sessions WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.Sessions (Hostname, Timestamp, ID, SessionName, LogonTime, IdleTime, UserName, State)
        SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(Session.value, '$.ID'),
            JSON_VALUE(Session.value, '$.SessionName'),
            JSON_VALUE(Session.value, '$.LogonTime'),
            JSON_VALUE(Session.value, '$.IdleTime'),
            JSON_VALUE(Session.value, '$.UserName'),
            JSON_VALUE(Session.value, '$.State')
        FROM
            OPENJSON(@Payload, '$.Sessions') AS Session
END


GO
