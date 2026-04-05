CREATE PROCEDURE [dbo].[usp_EventLogs_Upsert]

	@Payload nvarchar(MAX)

AS
BEGIN
    DECLARE @Hostname varchar(50),
            @TimeCreated datetime2

    INSERT INTO dbo.EventLogs
    (
        Hostname,
        Timestamp,
        LogName,
        LevelDisplayName,
        TimeCreated,
        ProviderName,
        TaskDisplayName,
        [Message],
        ID,
        RecordID,
        MachineName
    )
    SELECT
        PL.Hostname,
        PL.Timestamp,
        PL.LogName,
        PL.LevelDisplayName,
        PL.TimeCreated,
        PL.ProviderName,
        PL.TaskDisplayName,
        PL.[Message],
        PL.ID,
        PL.RecordID,
        PL.MachineName
    FROM
        (
            SELECT
                JSON_VALUE(@Payload, '$.Hostname')              AS Hostname,
                JSON_VALUE(@Payload, '$.Timestamp')             AS Timestamp,
                JSON_VALUE(Event.value, '$.LogName')            AS LogName,
                JSON_VALUE(Event.value, '$.LevelDisplayName')   AS LevelDisplayName,
                JSON_VALUE(Event.value, '$.TimeCreated')        AS TimeCreated,
                JSON_VALUE(Event.value, '$.ProviderName')       AS ProviderName,
                JSON_VALUE(Event.value, '$.TaskDisplayName')    AS TaskDisplayName,
                JSON_VALUE(Event.value, '$.Message')            AS [Message],
                JSON_VALUE(Event.value, '$.Id')                 AS ID,
                JSON_VALUE(Event.value, '$.RecordId')           AS RecordID,
                JSON_VALUE(Event.value, '$.MachineName')        AS MachineName
            FROM
                OPENJSON(@Payload, '$.EventLog') AS Event
        ) PL
            LEFT JOIN
        dbo.EventLogs EL
            ON
        PL.Hostname = EL.Hostname
            AND
        PL.LogName = EL.LogName
            AND
        PL.TimeCreated = EL.TimeCreated
            AND
        PL.RecordID = EL.RecordID
    WHERE
        EL.Id IS NULL

    SET NOCOUNT ON

    DECLARE curEventLogs CURSOR FORWARD_ONLY STATIC FOR

    SELECT
        JSON_VALUE(@Payload, '$.Hostname')  AS Hostname,
        MAX(JSON_VALUE(Event.value, '$.TimeCreated')) AS TimeCreated
    FROM
        OPENJSON(@Payload, '$.EventLog') AS Event

    OPEN curEventLogs

    FETCH NEXT FROM curEventLogs INTO
        @Hostname,
        @TimeCreated

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE
            dbo.Heartbeats
        SET
            EventLogsLastUpdated = IIF(@TimeCreated > ISNULL(EventLogsLastUpdated, 0), @TimeCreated, EventLogsLastUpdated)
        WHERE
            Hostname = @Hostname

        UPDATE
            dbo.HostConfiguration
        SET
            EventLogsLastUpdated = IIF(@TimeCreated > ISNULL(EventLogsLastUpdated, 0), @TimeCreated, EventLogsLastUpdated)
        WHERE
            Hostname = @Hostname

        FETCH NEXT FROM curEventLogs INTO
            @Hostname,
            @TimeCreated
    END

    CLOSE curEventLogs
    DEALLOCATE curEventLogs

    SET NOCOUNT OFF
END
GO
