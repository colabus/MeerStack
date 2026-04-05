CREATE PROCEDURE [dbo].[usp_Trend_Software_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname       varchar(50),
            @Timestamp      datetime,
            @DisplayName    varchar(255),
            @DisplayVersion varchar(50),
            @Publisher      varchar(255),
            @InstallDate    varchar(50)

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    DELETE FROM dbo.TrendSoftware WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.TrendSoftware (Hostname, Timestamp, DisplayName, DisplayVersion, Publisher, InstallDate)
         SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(Software.value, '$.DisplayName'),
            JSON_VALUE(Software.value, '$.DisplayVersion'),
            JSON_VALUE(Software.value, '$.Publisher'),
            JSON_VALUE(Software.value, '$.InstallDate')
        FROM
            OPENJSON(@Payload, '$.Software') AS Software

END
GO
