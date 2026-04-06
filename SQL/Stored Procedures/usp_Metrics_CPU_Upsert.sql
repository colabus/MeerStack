CREATE PROCEDURE [dbo].[usp_Metrics_CPU_Upsert]

	@Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @PercentProcessorTime float

    SELECT
        @Hostname               = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp              = JSON_VALUE(@Payload, '$.Timestamp'),
        @PercentProcessorTime   = JSON_VALUE(@Payload, '$.PercentProcessorTime')

    SET NOCOUNT OFF

    IF EXISTS (SELECT 1 FROM dbo.MetricsCPU WHERE Hostname = @Hostname AND Timestamp = @Timestamp)
        BEGIN
            UPDATE dbo.MetricsCPU SET
                PercentProcessorTime = @PercentProcessorTime
            WHERE
                Hostname = @Hostname
                    AND
                Timestamp = @Timestamp
        END
        ELSE
        BEGIN
            INSERT INTO dbo.MetricsCPU
                (
                    Hostname,
                    Timestamp,
                    PercentProcessorTime
                ) VALUES (
                    @Hostname,
                    @Timestamp,
                    @PercentProcessorTime
                )
        END
END

GO
