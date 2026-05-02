USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_HostConfiguration_Get] -- EXEC [usp_HostConfiguration_Get] '<Hostname>'

	@Hostname varchar(50)

AS
BEGIN
	DECLARE @ScriptVersion varchar(50),
			@DatabaseVersion varchar(50),
			@EventLogsLastUpdated datetime

	SELECT
		@ScriptVersion = ScriptVersion,
		@DatabaseVersion = DatabaseVersion
	FROM
		dbo.Version

	SELECT @EventLogsLastUpdated = ISNULL(EventLogsLastUpdated, DATEADD(hour, -1, getdate())) FROM dbo.Heartbeats WHERE Hostname = @Hostname

	SELECT TOP 1
		Hostname,

		-- Heartbeat
		HeartbeatInterval,

		-- Checks
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
		ISNULL(@EventLogsLastUpdated, getdate()) AS EventLogsLastUpdated,
		Sessions,
		SessionsInterval,

		Processes,
		ProcessesInterval,
		Connections,
		ConnectionsInterval,

		Software,
		SoftwareInterval,
		Shares,
		SharesInterval,
		Tasks,
		TasksInterval,
		Identities,
		IdentitiesInterval,

		-- Version
		@ScriptVersion AS ScriptVersion,
		@DatabaseVersion AS DatabaseVersion,
		NULL AS MeerStackForceExit
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
