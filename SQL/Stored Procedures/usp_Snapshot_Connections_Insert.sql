USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Connections_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    DELETE FROM dbo.Connections WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.Connections (Hostname, Timestamp, Protocol, LocalAddress, RemoteAddress, State, PID)
        SELECT DISTINCT
            @Hostname,
            @Timestamp,
            JSON_VALUE(Connection.value, '$.Protocol'),
            JSON_VALUE(Connection.value, '$.LocalAddress'),
            JSON_VALUE(Connection.value, '$.RemoteAddress'),
            JSON_VALUE(Connection.value, '$.State'),
            JSON_VALUE(Connection.value, '$.PID')
        FROM
            OPENJSON(@Payload, '$.Connections') AS Connection
        WHERE
            JSON_VALUE(Connection.value, '$.Protocol') = 'TCP'
                AND
            JSON_VALUE(Connection.value, '$.State') = 'Listening'
END

GO
