USE [MeerStack]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Check_Log_Insert]

	@Hostname varchar(50),
	@Filename varchar(50),
	@PayLoad xml

AS
BEGIN
	INSERT INTO dbo.CheckLog
		(Hostname, Filename, Payload)
			VALUES
		(@Hostname, @Filename, @PayLoad)
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Check_Log_Process]

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Id bigint,
            @Timestamp datetime,
            @Hostname varchar(50),
            @Filename varchar(50),
            @Payload xml,

            @Check varchar(50)

	-- Skip outdated Heartbeats to speed backlog processing ..

	UPDATE
		[MeerStack].[dbo].[CheckLog]
	SET
		Processed = 1
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
    ORDER BY
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

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END

        -- Metrics
        ELSE IF @Check = 'CPU'
        BEGIN
            EXEC dbo.usp_Metrics_CPU_Upsert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END

        ELSE IF @Check = 'Memory'
        BEGIN
            EXEC dbo.usp_Metrics_Memory_Upsert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END

        -- Trend
        ELSE IF @Check = 'Disks'
        BEGIN
            EXEC dbo.usp_Trend_Disks_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END

        ELSE IF @Check = 'Services'
        BEGIN
            EXEC dbo.usp_Trend_Services_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END

        ELSE IF @Check = 'Certificates'
        BEGIN
            EXEC dbo.usp_Trend_Certificates_Insert @Payload

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END
        ELSE IF @Check = 'EventLogs'
        BEGIN
            EXEC dbo.usp_EventLogs_Upsert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
        END
		ELSE IF @Check = 'Sessions'
        BEGIN
            EXEC dbo.usp_Trend_Sessions_Insert @PayLoad

            UPDATE [MeerStack].[dbo].[CheckLog] SET Processed = 1 WHERE Id = @Id
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_EventLogs_Upsert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT OFF

    DECLARE @Hostname varchar(50),
            @TimeCreated datetime

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
        RecordID
    )
    SELECT
        Event.value('../../Hostname[1]', 'varchar(50)') AS Hostname,
        Event.value('../../Timestamp[1]', 'datetime') AS Timestamp,
        Event.value('LogName[1]', 'varchar(100)') AS LogName,
        Event.value('LevelDisplayName[1]', 'varchar(50)') AS LevelDisplayName,
        Event.value('TimeCreated[1]', 'datetime') AS TimeCreated,
        Event.value('ProviderName[1]', 'varchar(MAX)') AS ProviderName,
        Event.value('TaskDisplayName[1]', 'varchar(50)') AS TaskDisplayName,
        Event.value('Message[1]', 'varchar(MAX)') AS Message,
        Event.value('ID[1]', 'int') AS ID,
        Event.value('RecordID[1]', 'int') AS RecordID
    FROM
        @PayLoad.nodes('(/EventLogs/EventLog/Event)') AS E(Event)
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                dbo.EventLogs AS EL
            WHERE
                EL.Hostname = Event.value('../../Hostname[1]', 'varchar(50)')
                    AND
                EL.LogName = Event.value('LogName[1]', 'varchar(100)')
                    AND
                EL.TimeCreated = Event.value('TimeCreated[1]', 'datetime')
                    AND
                EL.RecordID = Event.value('RecordID[1]', 'int')
        )

    SET NOCOUNT ON

    DECLARE curEventLogs CURSOR FORWARD_ONLY STATIC FOR

    SELECT
        Hostname,
        MAX(TimeCreated) AS TimeCreated
    FROM
        (
            SELECT
                Event.value('../../Hostname[1]', 'varchar(50)') AS Hostname,
                Event.value('TimeCreated[1]', 'datetime') AS TimeCreated
            FROM
                @PayLoad.nodes('(/EventLogs/EventLog/Event)') AS E(Event)
        ) E
    GROUP BY
        Hostname

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

        FETCH NEXT FROM curEventLogs INTO
            @Hostname,
            @TimeCreated
    END

    CLOSE curEventLogs
    DEALLOCATE curEventLogs

    SET NOCOUNT OFF
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Heartbeat_Upsert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @Server varchar(50),
            @IPAddresses varchar(50),
            @OS varchar(MAX),
            @Domain varchar(50),
            @TotalMemoryGB float,
            @CPU varchar(MAX),
            @NumberOfLogicalProcessors int,
            @BootTime datetime

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');
    SET @Server = @Payload.value('(/Metrics/Information/Server)[1]', 'varchar(50)');
    SET @IPAddresses = @Payload.value('(/Metrics/Information/IPAddresses)[1]', 'varchar(50)');
    SET @OS = @Payload.value('(/Metrics/Information/OS)[1]', 'varchar(MAX)');
    SET @Domain = @Payload.value('(/Metrics/Information/Domain)[1]', 'varchar(50)');
    SET @TotalMemoryGB = @Payload.value('(/Metrics/Information/TotalMemoryGB)[1]', 'FLOAT');
    SET @CPU = @Payload.value('(/Metrics/Information/CPU)[1]', 'varchar(MAX)');
    SET @NumberOfLogicalProcessors = @Payload.value('(/Metrics/Information/NumberOfLogicalProcessors)[1]', 'int');
    SET @BootTime = @Payload.value('(/Metrics/Information/BootTime)[1]', 'datetime');

    SET NOCOUNT OFF

    IF EXISTS (SELECT 1 FROM dbo.Heartbeats WHERE Hostname = @Hostname)
    BEGIN
        UPDATE dbo.Heartbeats SET
            Timestamp = @Timestamp,
            Server = @Server,
            IPAddresses = @IPAddresses,
            OS = @OS,
            Domain = @Domain,
            TotalMemoryGB = @TotalMemoryGB,
            CPU = @CPU,
            NumberOfLogicalProcessors = @NumberOfLogicalProcessors,
            BootTime = @BootTime
        WHERE
            Hostname = @Hostname
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Heartbeats
            (
                Hostname,
                Timestamp,
                Server,
                IPAddresses,
                OS,
                Domain,
                TotalMemoryGB,
                CPU,
                NumberOfLogicalProcessors,
                BootTime
            ) VALUES (
                @Hostname,
                @Timestamp,
                @Server,
                @IPAddresses,
                @OS,
                @Domain,
                @TotalMemoryGB,
                @CPU,
                @NumberOfLogicalProcessors,
                @BootTime
            )
    END
END



GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_HostConfiguration_Get]

	@Hostname varchar(50)

AS
BEGIN
	DECLARE @ScriptVersion varchar(50),
			@EventLogsLastUpdated datetime

	SELECT @ScriptVersion = ScriptVersion FROM dbo.Version

	SELECT @EventLogsLastUpdated = ISNULL(EventLogsLastUpdated, DATEADD(hour, -1, getdate())) FROM dbo.Heartbeats WHERE Hostname = @Hostname

	SELECT TOP 1
		Hostname,
		Cpu,
		CpuInterval,
		Memory,
		MemoryInterval,
		Services,
		ServicesInterval,
		ServicesToCheck,
		ServicesVerbose,
		Disks,
		DisksInterval,
		Certificates,
		CertificatesInterval,
		EventLogs,
		EventLogsInterval,
		EventLogsXmlFilter,
		@EventLogsLastUpdated AS EventLogsLastUpdated,
		Sessions,
		SessionsInterval,

		@ScriptVersion AS ScriptVersion
	FROM
		dbo.HostConfiguration
	WHERE
		Hostname IN (@Hostname, 'DEFAULT')
	ORDER BY
		CASE
			WHEN Hostname = @Hostname THEN 1
			ELSE 0
		END DESC
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Metrics_CPU_Upsert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @PercentProcessorTime float

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');
    SET @PercentProcessorTime = @Payload.value('(/Metrics/CPU/PercentProcessorTime)[1]', 'float');

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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Metrics_Memory_Upsert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @UsedMB int,
            @TotalMB int,
            @UsedPercent float

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');
    SET @UsedMB = @Payload.value('(/Metrics/Memory/UsedMB)[1]', 'int');
    SET @TotalMB = @Payload.value('(/Metrics/Memory/TotalMB)[1]', 'int');
    SET @UsedPercent = @Payload.value('(/Metrics/Memory/UsedPercent)[1]', 'float');

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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Trend_Certificates_Insert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @DnsNameList varchar(MAX),
            @Issuer varchar(MAX),
            @NotBefore datetime,
            @NotAfter datetime,
            @HasPrivateKey bit,
            @SerialNumber varchar(50),
            @Subject varchar(MAX),
            @Thumbprint varchar(50),
			@Template varchar(50),
            @Version float

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');

    SET NOCOUNT OFF

    DECLARE curCertificates CURSOR FOR
        SELECT 
            Certificate.value('DnsNameList[1]', 'varchar(MAX)') AS DnsNameList,
            Certificate.value('Issuer[1]', 'varchar(MAX)') AS Issuer,
            Certificate.value('NotBefore[1]', 'datetime') AS NotBefore,
            Certificate.value('NotAfter[1]', 'datetime') AS NotAfter,
            Certificate.value('HasPrivateKey[1]', 'bit') AS HasPrivateKey,
            Certificate.value('SerialNumber[1]', 'varchar(50)') AS SerialNumber,
            Certificate.value('Subject[1]', 'varchar(MAX)') AS Subject,
            Certificate.value('Thumbprint[1]', 'varchar(50)') AS Thumbprint,
			Certificate.value('Template[1]', 'varchar(50)') AS Template,
            Certificate.value('Version[1]', 'float') AS Version
        FROM
            @Payload.nodes('(/Metrics/Certificates/Certificate)') AS T(Certificate)

        OPEN curCertificates

        FETCH NEXT FROM curCertificates INTO
            @DnsNameList,
            @Issuer,
            @NotBefore,
            @NotAfter,
            @HasPrivateKey,
            @SerialNumber,
            @Subject,
            @Thumbprint,
			@Template,
            @Version

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
                            DnsNameList,
                            Issuer,
                            NotBefore,
                            NotAfter,
                            HasPrivateKey,
                            SerialNumber,
                            Subject,
                            Thumbprint,
							Template,
                            Version
                        FROM
                            dbo.TrendCertificates
                        WHERE
                            Hostname = @Hostname
                                AND
                            Timestamp <= @Timestamp
                                AND
                            Thumbprint = @Thumbprint
                        ORDER BY
                            Timestamp DESC
                    ) TrendCertificates
                WHERE
                    DnsNameList = @DnsNameList
                        AND
                    Issuer = @Issuer
                        AND
                    NotBefore = @NotBefore
                        AND
                    NotAfter = @NotAfter
                        AND
                    HasPrivateKey = @HasPrivateKey
                        AND
                    SerialNumber = @SerialNumber
                        AND
                    Subject = @Subject
                        AND
                    Thumbprint = @Thumbprint
                        AND
                    ISNULL(Template, '') = ISNULL(@Template, '')
                        AND
                    Version = @Version
            )
            BEGIN
                INSERT INTO dbo.TrendCertificates
                    (
                        Hostname,
                        Timestamp,
                        DnsNameList,
                        Issuer,
                        NotBefore,
                        NotAfter,
                        HasPrivateKey,
                        SerialNumber,
                        Subject,
                        Thumbprint,
						Template,
                        Version
                    )
                VALUES
                    (
                        @Hostname,
                        @Timestamp,
                        @DnsNameList,
                        @Issuer,
                        @NotBefore,
                        @NotAfter,
                        @HasPrivateKey,
                        @SerialNumber,
                        @Subject,
                        @Thumbprint,
						@Template,
                        @Version
                    )
            END

            FETCH NEXT FROM curCertificates INTO
                @DnsNameList,
                @Issuer,
                @NotBefore,
                @NotAfter,
                @HasPrivateKey,
                @SerialNumber,
                @Subject,
                @Thumbprint,
				@Template,
                @Version
        END

        CLOSE curCertificates
        DEALLOCATE curCertificates

		-- Mark old certificates as deleted
		UPDATE
			dbo.TrendCertificates
		SET
			Deleted = 1
		WHERE
			Hostname = @Hostname
				AND
			Thumbprint NOT IN (
				SELECT
					Certificate.value('Thumbprint[1]', 'varchar(50)') AS Thumbprint
				FROM
					@Payload.nodes('(/Metrics/Certificates/Certificate)') AS T(Certificate)
			)

END


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Trend_Disks_Insert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @DeviceID varchar(50),
            @VolumeName varchar(50),
            @SizeGB float,
            @UsedGB float,
            @FreeGB float,
            @UsedPercent float

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');

    SET NOCOUNT OFF

    DECLARE curDisks CURSOR FOR
        SELECT 
            Disk.value('DeviceID[1]', 'varchar(50)') AS DeviceID,
            Disk.value('VolumeName[1]', 'varchar(50)') AS VolumeName,
            Disk.value('SizeGB[1]', 'float') AS SizeGB,
            Disk.value('UsedGB[1]', 'float') AS UsedGB,
            Disk.value('FreeGB[1]', 'float') AS FreeGB,
            Disk.value('UsedPercent[1]', 'float') AS UsedPercent
        FROM
            @Payload.nodes('(/Metrics/Disks/Disk)') AS T(Disk)

        OPEN curDisks

        FETCH NEXT FROM curDisks INTO
            @DeviceID,
            @VolumeName,
            @SizeGB,
            @UsedGB,
            @FreeGB,
            @UsedPercent

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
                            DeviceID,
                            VolumeName,
                            SizeGB,
                            UsedGB,
                            FreeGB,
                            UsedPercent
                        FROM
                            dbo.TrendDisks
                        WHERE
                            Hostname = @Hostname
                                AND
                            Timestamp <= @Timestamp
                                AND
                            DeviceID = @DeviceID
                        ORDER BY
                            Timestamp DESC
                    ) TrendDisks
                WHERE
                    SizeGB = @SizeGB
                        AND
                    UsedGB = @UsedGB
                        AND
                    FreeGB = @FreeGB
                        AND
                    UsedPercent = @UsedPercent
            )
            BEGIN
                INSERT INTO dbo.TrendDisks
                    (
                        Hostname,
                        Timestamp,
                        DeviceID,
                        VolumeName,
                        SizeGB,
                        UsedGB,
                        FreeGB,
                        UsedPercent
                    )
                VALUES
                    (
                        @Hostname,
                        @Timestamp,
                        @DeviceID,
                        @VolumeName,
                        @SizeGB,
                        @UsedGB,
                        @FreeGB,
                        @UsedPercent
                    )
            END

            FETCH NEXT FROM curDisks INTO
                @DeviceID,
                @VolumeName,
                @SizeGB,
                @UsedGB,
                @FreeGB,
                @UsedPercent
        END

        CLOSE curDisks
        DEALLOCATE curDisks
END


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Trend_Services_Insert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @Name varchar(50),
            @DisplayName varchar(50),
            @Status varchar(50),
            @StartType varchar(50)

    SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)');
    SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime');

    SET NOCOUNT OFF

    DECLARE curServices CURSOR FOR
        SELECT 
            Disk.value('Name[1]', 'varchar(50)') AS Name,
            Disk.value('DisplayName[1]', 'varchar(50)') AS DisplayName,
            Disk.value('Status[1]', 'varchar(50)') AS Status,
            Disk.value('StartType[1]', 'varchar(50)') AS StartType
        FROM
            @Payload.nodes('(/Metrics/Services/Service)') AS T(Disk)

        OPEN curServices

        FETCH NEXT FROM curServices INTO
            @Name,
            @DisplayName,
            @Status,
            @StartType

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
                            StartType
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
            )
            BEGIN
                INSERT INTO dbo.TrendServices
                    (
                        Hostname,
                        Timestamp,
                        Name,
                        DisplayName,
                        Status,
                        StartType
                    )
                VALUES
                    (
                        @Hostname,
                        @Timestamp,
                        @Name,
                        @DisplayName,
                        @Status,
                        @StartType
                    )
            END

            FETCH NEXT FROM curServices INTO
                @Name,
                @DisplayName,
                @Status,
                @StartType
        END

        CLOSE curServices
        DEALLOCATE curServices
END


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Trend_Sessions_Insert]

	@PayLoad xml

AS
BEGIN
    SET NOCOUNT ON

	DECLARE @Hostname varchar(50),
			@Timestamp datetime

	SET @Hostname = @Payload.value('(/Metrics/Hostname)[1]', 'varchar(50)')
	SET @Timestamp = @Payload.value('(/Metrics/Timestamp)[1]', 'datetime')

	--UPDATE dbo.TrendSessions SET Deleted = 1 WHERE Hostname = @Hostname
	DELETE FROM dbo.TrendSessions WHERE Hostname = @Hostname

    SET NOCOUNT OFF

	INSERT INTO dbo.TrendSessions (Hostname, Timestamp, ID, SessionName, LogonTime, IdleTime, UserName, State)
		SELECT
			@Hostname,
			@Timestamp,
			Session.value('ID[1]', 'int') AS ID,
			Session.value('SessionName[1]', 'varchar(50)') AS SessionName,
			Session.value('LogonTime[1]', 'datetime') AS LogonTime,
			Session.value('IdleTime[1]', 'int') AS IdleTime,
			Session.value('UserName[1]', 'varchar(50)') AS UserName,
			Session.value('State[1]', 'varchar(50)') AS State
		FROM
			@Payload.nodes('(/Metrics/Sessions/Session)') AS S(Session)

	--SELECT
	--	*
	--FROM
	--	dbo.TrendSessions
	--WHERE
	--	Hostname = @Hostname
	--		AND
	--	Deleted = 1


END


GO


