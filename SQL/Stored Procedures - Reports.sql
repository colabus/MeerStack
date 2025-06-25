CREATE PROCEDURE [dbo].[usp_Reports_Systems_Certificates_Get]

AS
BEGIN
	SELECT
		TC.Hostname,
		S.Description,
		S.Environment,
		TC.Timestamp,
		TC.DnsNameList,
		TC.Issuer,
		TC.NotBefore,
		TC.NotAfter,
		DATEDIFF(day, getdate(), TC.NotAfter) AS DaysLeft,
		TC.HasPrivateKey,
		TC.SerialNumber,
		TC.Subject,
		TC.Thumbprint,
		TC.Template,
		TC.Version,
		CASE
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 0 THEN 'Certificate expired.'
			WHEN TC.Template = 'DBCT - Workstation Authentication' THEN 'DBCT\Domain Computers AD group set to Autoenroll. Nothing to action.'
			WHEN TC.Template = 'DBCT - Server' THEN 'DBCT\Certificate Server Authentication AD group set to Autoenroll. Nothing to action.'
			WHEN TC.Template = 'DBCT - Server (Manual)' THEN 'Requires manual intervention.'
			WHEN TC.HasPrivateKey = 0 THEN 'No access to private key. Nothing to action'
		END AS ActionTooltip,
		CASE
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 30 THEN 'Red'
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 30 THEN 'Orange'
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 60 THEN 'Yellow'
			WHEN TC.Template = 'DBCT - Workstation Authentication' THEN 'LawnGreen'
			WHEN TC.Template = 'DBCT - Server' THEN 'LawnGreen'
			ELSE 'LawnGreen'
		END AS ActionBackgroundColor,
		CASE
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 30 THEN 'White'
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 30 THEN 'Black'
			WHEN DATEDIFF(day, getdate(), TC.NotAfter) < 60 THEN 'Black'
			WHEN TC.Template = 'DBCT - Workstation Authentication' THEN 'Black'
			WHEN TC.Template = 'DBCT - Server' THEN 'Black'
			ELSE 'Black'
		END AS ActionColor
	FROM
		(
			SELECT
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
				Version,
				ROW_NUMBER() OVER (PARTITION BY Hostname, Thumbprint ORDER BY Timestamp DESC) AS RowNumber
			FROM
				dbo.TrendCertificates
			WHERE
				ISNULL(Deleted, 0) <> 1
		) TC
			LEFT JOIN
		dbo.Systems S
			ON
		TC.Hostname = S.Hostname
	WHERE
		RowNumber = 1
	ORDER BY
		TC.Hostname
END


GO

/****** Object:  StoredProcedure [dbo].[usp_Reports_Systems_Disks_Get]    Script Date: 25/06/2025 8:44:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Reports_Systems_Disks_Get]

AS
BEGIN
	SELECT
		TD.Hostname,
		S.Description,
		S.Environment,
		TD.Timestamp,
		TD.DeviceID,
		TD.VolumeName,
		TD.SizeGB,
		TD.UsedGB,
		TD.FreeGB,
		TD.UsedPercent / 100.0 AS UsedPercent
	FROM
		(
			SELECT
				Hostname,
				Timestamp,
				DeviceID,
				VolumeName,
				SizeGB,
				UsedGB,
				FreeGB,
				UsedPercent,
				ROW_NUMBER() OVER (PARTITION BY Hostname, DeviceID ORDER BY Timestamp DESC) AS RowNumber
			FROM
				dbo.TrendDisks
		) TD
			LEFT JOIN
		dbo.Systems S
			ON
		TD.Hostname = S.Hostname
	WHERE
		RowNumber = 1
	ORDER BY
		TD.Hostname
END


GO

/****** Object:  StoredProcedure [dbo].[usp_Reports_Systems_Get]    Script Date: 25/06/2025 8:44:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Reports_Systems_Get]

AS
BEGIN
	SELECT
		H.Hostname,
		S.Description,
		S.Environment,
		H.Timestamp,
		DATEDIFF(second, H.Timestamp, getdate()) AS LastUpdated,
		H.IPAddresses,
		REPLACE(REPLACE(H.OS, 'Microsoft Windows Server ', ''), ' Standard 64-bit', '') AS OS,
		REPLACE(H.Domain, 'dbct.com.au', 'DBCT') AS Domain,
		H.TotalMemoryGB,
		H.CPU,
		H.NumberOfLogicalProcessors,
		H.BootTime,
		DATEDIFF(second, H.BootTime, getdate()) / 60.0 / 60.0 / 24.0 AS LastBooted
	FROM
		dbo.Heartbeats H
			LEFT JOIN
		dbo.Systems S
			ON
		H.Server = S.Hostname
END


GO

/****** Object:  StoredProcedure [dbo].[usp_Reports_Systems_Services_Get]    Script Date: 25/06/2025 8:44:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_Reports_Systems_Services_Get]

	@Status varchar(MAX) = 'Stopped,StartPending,StopPending,Running,ContinuePending,PausePending,Paused'

AS
BEGIN 
	SELECT
		TS.Hostname,
		S.Description,
		S.Environment,
		TS.Timestamp,
		CASE TS.Name
			WHEN 'CSFalconService' THEN 'CrowdStrike'
			WHEN 'AirlockClient' THEN 'Airlock'
			WHEN 'CQRXSvc' THEN 'CQR Exchange'
			WHEN 'JDE E920 B9 Network' THEN 'JDE'
			WHEN 'KeySecureSyncService' THEN 'Key Secure'
			WHEN 'MSSQLSERVER' THEN 'MSSQL'
			WHEN 'QDBODBC_64' THEN 'Quintiq Integrator'
			WHEN 'QSERVER_64' THEN 'Quintiq Server'
			WHEN 'QTCE_64' THEN 'Quintiq TCE'
			WHEN 'rumble-agent-554b612c-0291-45fb-914e-38ef55a18a67' THEN 'Rumble'
			WHEN 'SCFAGENT1' THEN 'SM Agent'
			WHEN 'SQLSERVERAGENT' THEN 'SQL Server Agent'
			WHEN 'W3SVC' THEN 'IIS'
			WHEN 'VeeamNFSSvc' THEN 'Veeam'
			ELSE TS.Name
		END AS Name,
		TS.Name AS ServiceName,
		TS.DisplayName,
		TS.Status,
		TS.StartType
	FROM
		(
			SELECT
				Hostname,
				Timestamp,
				Name,
				DisplayName,
				Status,
				StartType,
				ROW_NUMBER() OVER (PARTITION BY Hostname, Name ORDER BY Timestamp DESC) AS RowNumber
			FROM
				dbo.TrendServices
		) TS
			LEFT JOIN
		dbo.Systems S
			ON
		TS.Hostname = S.Hostname
	WHERE
		RowNumber = 1
			AND
		Status IN (SELECT Item FROM dbo.Split(@Status, ','))
	ORDER BY
		TS.Hostname,
		Name,
		Timestamp DESC
END


GO