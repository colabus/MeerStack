USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Trend_RegistryKeys_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname       varchar(50),
            @Timestamp      datetime,
            @RegistryKeys   nvarchar(MAX)

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp'),
        @RegistryKeys = JSON_QUERY(@Payload, '$.RegistryKeys')

    DELETE FROM dbo.RegistryKeys WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.RegistryKeys (Hostname, Timestamp, RegistryKeys)
         VALUES
    (
        @Hostname,
        @Timestamp,
        @RegistryKeys
    )

END
GO
