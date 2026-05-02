USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Software_Insert]

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

    DELETE FROM dbo.Software WHERE Hostname = @Hostname

	DELETE FROM dbo.SQLServers WHERE Hostname = @Hostname

	DELETE FROM dbo.NETFrameworks WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.Software (Hostname, Timestamp, DisplayName, DisplayVersion, Publisher, InstallDate)
         SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(Software.value, '$.DisplayName'),
            JSON_VALUE(Software.value, '$.DisplayVersion'),
            JSON_VALUE(Software.value, '$.Publisher'),
            JSON_VALUE(Software.value, '$.InstallDate')
        FROM
            OPENJSON(@Payload, '$.Software') AS Software
		WHERE
			RIGHT(JSON_VALUE(Software.value, '$.DisplayName'), 1) <> ' '

    INSERT INTO dbo.SQLServers (Hostname, Timestamp, InstanceName, Edition, Version, PatchLevel, SQLBinRoot)
         SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(SQLServer.value, '$.InstanceName'),
            JSON_VALUE(SQLServer.value, '$.Edition'),
            JSON_VALUE(SQLServer.value, '$.Version'),
            JSON_VALUE(SQLServer.value, '$.PatchLevel'),
			JSON_VALUE(SQLServer.value, '$.SQLBinRoot')
        FROM
            OPENJSON(@Payload, '$.SQLServer') AS SQLServer

    INSERT INTO dbo.NETFrameworks (Hostname, Timestamp, Name, Version)
         SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(NETFramework.value, '$.Name'),
            JSON_VALUE(NETFramework.value, '$.Version')
        FROM
            OPENJSON(@Payload, '$.NETFramework') AS NETFramework

END
GO
