CREATE PROCEDURE [dbo].[usp_HostConfiguration_Get] -- EXEC [usp_HostConfiguration_Get] 'Nick-PC'

	@Hostname varchar(50)

AS
BEGIN
	DECLARE @ScriptVersion varchar(50),
			@EventLogsLastUpdated datetime

	SELECT @ScriptVersion = ScriptVersion FROM dbo.Version

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

		-- Version
		@ScriptVersion AS ScriptVersion,

		CONVERT(datetime, NULL) AS MeerStackForceExit
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
