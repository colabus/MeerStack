CREATE PROCEDURE [dbo].[usp_Trend_Processes_Insert]

    @PayLoad nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    DELETE FROM dbo.TrendProcesses WHERE Hostname = @Hostname

    SET NOCOUNT OFF

    INSERT INTO dbo.TrendProcesses (Hostname, Timestamp, Name, PID, ParentPid, Path, CommandLine, StartTime, SessionId, SHA256)
        SELECT
            @Hostname,
            @Timestamp,
            JSON_VALUE(Process.value, '$.Name'),
            JSON_VALUE(Process.value, '$.PID'),
            JSON_VALUE(Process.value, '$.ParentPid'),
            JSON_VALUE(Process.value, '$.Path'),
            JSON_VALUE(Process.value, '$.CommandLine'),
            JSON_VALUE(Process.value, '$.StartTime'),
            JSON_VALUE(Process.value, '$.SessionId'),
            JSON_VALUE(Process.value, '$.SHA256')
        FROM
            OPENJSON(@Payload, '$.Processes') AS Process
END

GO
