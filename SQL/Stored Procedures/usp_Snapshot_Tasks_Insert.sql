USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Tasks_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    DECLARE @Hostname varchar(50),
            @Timestamp datetime

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    DELETE FROM
        dbo.Tasks
    WHERE
        Hostname = @Hostname

    INSERT INTO dbo.Tasks (Hostname, Timestamp, Name, Path, Description, Author, State, PrincipalUserId, PrincipalLogonType, PrincipalRunLevel, LastRunTime, LastResult, NextRunTime)
		SELECT
			@Hostname,
			@Timestamp,
			JSON_VALUE(Tasks.value, '$.Name'),
			JSON_VALUE(Tasks.value, '$.Path'),
			JSON_VALUE(Tasks.value, '$.Description'),
			JSON_VALUE(Tasks.value, '$.Author'),
			JSON_VALUE(Tasks.value, '$.State'),
			JSON_VALUE(Tasks.value, '$.Principal.UserId'),
			JSON_VALUE(Tasks.value, '$.Principal.LogonType'),
			JSON_VALUE(Tasks.value, '$.Principal.RunLevel'),
			JSON_VALUE(Tasks.value, '$.LastRunTime'),
			JSON_VALUE(Tasks.value, '$.LastResult'),
			JSON_VALUE(Tasks.value, '$.NextRunTime')
		FROM
			OPENJSON(@Payload, '$.Tasks') AS Tasks

    DELETE FROM
        dbo.TaskActions
    WHERE
        Hostname = @Hostname

    INSERT INTO dbo.TaskActions (Hostname, Timestamp, TaskName, TaskPath, [Index], [Execute], ImagePath, Arguments, LastModified)
		SELECT
			@Hostname,
			@Timestamp,
			JSON_VALUE(Tasks.value, '$.Name'),
			JSON_VALUE(Tasks.value, '$.Path'),
			CAST(Actions.[key] AS int),
			JSON_VALUE(Actions.value, '$.Execute'),
			JSON_VALUE(Actions.value, '$.ImagePath'),
			JSON_VALUE(Actions.value, '$.Arguments'),
			JSON_VALUE(Actions.value, '$.LastModified')
		FROM
			OPENJSON(@Payload, '$.Tasks') AS Tasks
				CROSS APPLY
			OPENJSON(Tasks.value, '$.Actions') AS Actions
END
GO
