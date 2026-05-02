USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_CheckLog_Process]

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Id bigint,
            @Timestamp datetime,
            @Hostname varchar(50),
            @Filename varchar(100),
            @Payload nvarchar(MAX),

            @Check varchar(50)

	-- Skip outdated Heartbeats to speed backlog processing ..

	UPDATE
		[MeerStack].[dbo].[CheckLog]
	SET
		Processed = 1,
		ProcessedDate = getdate(),
		Skipped = 1
	WHERE
		Id IN (
			SELECT
				Id
			FROM
				(
					SELECT
						Id,
						ROW_NUMBER() OVER (PARTITION BY Hostname ORDER BY Filename DESC) AS MessageOrder
					FROM
						[MeerStack].[dbo].[CheckLog]
					WHERE
						Processed = 0
							AND
						Filename LIKE 'Heartbeat%'
				) CL
			WHERE
				MessageOrder <> 1
		)

	-- Skip blank payloads .. # temporary control

	UPDATE
		[MeerStack].[dbo].[CheckLog]
	SET
		Processed = 1,
		ProcessedDate = getdate(),
		Skipped = 1
	FROM
		[MeerStack].[dbo].[CheckLog]
	WHERE
		Processed = 0
			AND
		LEN(Payload) = 0

    DECLARE curCheckLog CURSOR FORWARD_ONLY STATIC FOR

    SELECT
        Id,
        Timestamp,
        Hostname,
        Filename,
        Payload
    FROM
        [MeerStack].[dbo].[CheckLog]
    WHERE
        Processed = 0
		--	AND
		--NOT (
		--	LEFT(Filename, CHARINDEX('-', Filename) - 1) = 'EventLogs'
		--		AND
		--	Hostname = 'VMRDG02'
		--)
        --    AND
        --(
        --    Filename LIKE 'Heartbeat%'
        --        OR
        --    Filename LIKE 'CPU%'
        --        OR
        --    Filename LIKE 'Memory%'
        --        OR
        --    Filename LIKE 'Disks%'
        --        OR
        --    Filename LIKE 'Sessions%'
        --        OR
        --    Filename LIKE 'Processes%'
        --        OR
        --    Filename LIKE 'Services%'
        --        OR
        --    Filename LIKE 'Connections%'
        --)
    ORDER BY
		CASE
			WHEN LEFT(Filename, CHARINDEX('-', Filename) - 1) = 'Heartbeat' THEN 0
			WHEN LEFT(Filename, CHARINDEX('-', Filename) - 1) = 'EventLogs' THEN 2
			ELSE 1
		END,
        Timestamp

    OPEN curCheckLog

    FETCH NEXT FROM curCheckLog INTO
        @Id,
        @Timestamp,
        @Hostname,
        @Filename,
        @Payload

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Check = LEFT(@Filename, CHARINDEX('-', @Filename) - 1)

        BEGIN TRY

        -- Heartbeat
        IF @Check = 'Heartbeat'
        BEGIN
            EXEC dbo.usp_Heartbeat_Upsert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        -- Metrics
        ELSE IF @Check = 'CPU'
        BEGIN
            EXEC dbo.usp_Metrics_CPU_Upsert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        ELSE IF @Check = 'Memory'
        BEGIN
            EXEC dbo.usp_Metrics_Memory_Upsert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        -- Trend
        ELSE IF @Check = 'Disks'
        BEGIN
            EXEC dbo.usp_Trend_Disks_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        ELSE IF @Check = 'Services'
        BEGIN
            EXEC dbo.usp_Trend_Services_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        ELSE IF @Check = 'Certificates'
        BEGIN
            EXEC dbo.usp_Trend_Certificates_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
        ELSE IF @Check = 'EventLogs'
        BEGIN
            EXEC dbo.usp_EventLogs_Upsert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
		ELSE IF @Check = 'Sessions'
        BEGIN
            EXEC dbo.usp_Snapshot_Sessions_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
        ELSE IF @Check = 'Processes'
        BEGIN
            EXEC dbo.usp_Snapshot_Processes_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
        ELSE IF @Check = 'Connections'
        BEGIN
            EXEC dbo.usp_Snapshot_Connections_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
        ELSE IF @Check = 'Software'
        BEGIN
            EXEC dbo.usp_Snapshot_Software_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
        ELSE IF @Check = 'Shares'
        BEGIN
            EXEC dbo.usp_Snapshot_Shares_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
		ELSE IF @Check = 'Identities'
        BEGIN
            EXEC dbo.usp_Snapshot_Identities_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END
		ELSE IF @Check = 'Tasks'
        BEGIN
            EXEC dbo.usp_Snapshot_Tasks_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1, ProcessedDate = getdate() WHERE Id = @Id
        END

        END TRY
        BEGIN CATCH
            SELECT
				@Id AS ID,
                ERROR_NUMBER() AS ErrorNumber,
                ERROR_SEVERITY() AS ErrorSeverity,
                ERROR_STATE() AS ErrorState,
                ERROR_PROCEDURE() AS ErrorProcedure,
                ERROR_LINE() AS ErrorLine,
                ERROR_MESSAGE() AS ErrorMessage
        END CATCH

        FETCH NEXT FROM curCheckLog INTO
            @Id,
            @Timestamp,
            @Hostname,
            @Filename,
            @Payload
    END

    CLOSE curCheckLog
    DEALLOCATE curCheckLog

    SET NOCOUNT OFF
END
GO
