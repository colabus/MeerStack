CREATE PROCEDURE [dbo].[usp_CheckLog_Insert]

	@Hostname varchar(50),
	@Filename varchar(100),
	@Payload nvarchar(MAX)

AS
BEGIN
	INSERT INTO dbo.CheckLog
		(Hostname, Filename, Payload)
			VALUES
		(@Hostname, @Filename, @Payload)
END
GO
