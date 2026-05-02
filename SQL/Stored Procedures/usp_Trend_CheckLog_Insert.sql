USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Trend_CheckLog_Insert]

AS
BEGIN
	INSERT INTO dbo.TrendCheckLog
		SELECT
			getdate() AS Timestamp,
			COUNT(*) AS BacklogCount,
			MIN(Timestamp) MinTimestamp,
			DATEDIFF(second, MIN(Timestamp), getdate()) AS MinDateVariance,
			MAX(Timestamp) AS MaxTimestamp,
			DATEDIFF(second, MAX(Timestamp), getdate()) AS MaxDateVariance,
			MIN(CASE WHEN Filename LIKE 'Heartbeat%' THEN Timestamp ELSE NULL END) HeartbeatMinTimestamp,
			DATEDIFF(second, MIN(CASE WHEN Filename LIKE 'Heartbeat%' THEN Timestamp ELSE NULL END), getdate()) AS HeartbeatMinDateVariance,
			MAX(CASE WHEN Filename LIKE 'Heartbeat%' THEN Timestamp ELSE NULL END) AS HeartbeatMaxTimestamp,
			DATEDIFF(second, MAX(CASE WHEN Filename LIKE 'Heartbeat%' THEN Timestamp ELSE NULL END), getdate()) AS HeartbeatMaxDateVariance
		FROM
			dbo.CheckLog
		WHERE
			Processed = 0
END

GO
