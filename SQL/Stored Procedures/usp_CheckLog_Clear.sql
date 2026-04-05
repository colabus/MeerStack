CREATE PROCEDURE [dbo].[usp_CheckLog_Clear]

AS
BEGIN
	DELETE FROM
		[MeerStack].[dbo].[CheckLog]
	WHERE
		Timestamp < DATEADD(week, -1, getdate())
			AND
		Processed = 1
END
GO
