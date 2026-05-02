USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Trend_Services_Insert]

	@Payload nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @Name varchar(100),
            @DisplayName varchar(100),
            @Status varchar(50),
            @StartType varchar(50),
            @DelayedAutoStart bit,
            @StartName varchar(50),
            @PathName varchar(MAX),
            @ServiceType varchar(50)

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    SET NOCOUNT OFF

    DECLARE curServices CURSOR FOR

    SELECT
        JSON_VALUE(Service.value, '$.Name'),
        JSON_VALUE(Service.value, '$.DisplayName'),
        JSON_VALUE(Service.value, '$.Status'),
        JSON_VALUE(Service.value, '$.StartType'),
        JSON_VALUE(Service.value, '$.DelayedAutoStart'),
        JSON_VALUE(Service.value, '$.StartName'),
        JSON_VALUE(Service.value, '$.PathName'),
        JSON_VALUE(Service.value, '$.ServiceType')
    FROM
        OPENJSON(@Payload, '$.Services') AS Service
    WHERE
        JSON_VALUE(Service.value, '$.Monitored') = 'true'

    OPEN curServices

    FETCH NEXT FROM curServices INTO
        @Name,
        @DisplayName,
        @Status,
        @StartType,
        @DelayedAutoStart,
        @StartName,
        @PathName,
        @ServiceType

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT
                1
            FROM
                (
                    SELECT TOP 1
                        Hostname,
                        Timestamp,
                        Name,
                        DisplayName,
                        Status,
                        StartType,
                        DelayedAutoStart,
                        StartName,
                        PathName,
                        ServiceType
                    FROM
                        dbo.TrendServices
                    WHERE
                        Hostname = @Hostname
                            AND
                        Timestamp <= @Timestamp
                            AND
                        Name = @Name
                    ORDER BY
                        Timestamp DESC
                ) TrendServices
            WHERE
                Status = @Status
                    AND
                StartType = @StartType
                    AND
                DelayedAutoStart = @DelayedAutoStart
                    AND
                StartName = @StartName
                    AND
                PathName = @PathName
                    AND
                ServiceType = @ServiceType
        )
        BEGIN
            INSERT INTO dbo.TrendServices
                (
                    Hostname,
                    Timestamp,
                    Name,
                    DisplayName,
                    Status,
                    StartType,
                    DelayedAutoStart,
                    StartName,
                    PathName,
                    ServiceType
                )
            VALUES
                (
                    @Hostname,
                    @Timestamp,
                    @Name,
                    @DisplayName,
                    @Status,
                    @StartType,
                    @DelayedAutoStart,
                    @StartName,
                    @PathName,
                    @ServiceType
                )
        END

        FETCH NEXT FROM curServices INTO
            @Name,
            @DisplayName,
            @Status,
            @StartType,
            @DelayedAutoStart,
            @StartName,
            @PathName,
            @ServiceType
    END

    CLOSE curServices
    DEALLOCATE curServices
END
GO
