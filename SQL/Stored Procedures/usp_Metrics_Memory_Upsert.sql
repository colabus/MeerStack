USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Metrics_Memory_Upsert]

	@PayLoad nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @UsedMB int,
            @TotalMB int,
            @UsedPercent float

    SELECT
        @Hostname    = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp   = JSON_VALUE(@Payload, '$.Timestamp'),
        @UsedMB      = JSON_VALUE(@Payload, '$.UsedMB'),
        @TotalMB     = JSON_VALUE(@Payload, '$.TotalMB'),
        @UsedPercent = JSON_VALUE(@Payload, '$.UsedPercent')

    SET NOCOUNT OFF

    IF EXISTS (SELECT 1 FROM dbo.MetricsMemory WHERE Hostname = @Hostname AND Timestamp = @Timestamp)
        BEGIN
            UPDATE dbo.MetricsMemory SET
                UsedMB = @UsedMB,
                TotalMB = @TotalMB,
                UsedPercent = @UsedPercent
            WHERE
                Hostname = @Hostname
                    AND
                Timestamp = @Timestamp
        END
        ELSE
        BEGIN
            INSERT INTO dbo.MetricsMemory
                (
                    Hostname,
                    Timestamp,
                    UsedMB,
                    TotalMB,
                    UsedPercent
                ) VALUES (
                    @Hostname,
                    @Timestamp,
                    @UsedMB,
                    @TotalMB,
                    @UsedPercent
                )
        END
END
GO
