USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Snapshot_Identities_Insert]

    @Payload nvarchar(MAX)

AS
BEGIN
    DECLARE @Hostname varchar(50),
            @Timestamp datetime

    SELECT
        @Hostname  = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp = JSON_VALUE(@Payload, '$.Timestamp')

    DELETE FROM
        dbo.Users
    WHERE
        Hostname = @Hostname

    INSERT INTO dbo.Users (Hostname, Timestamp, Name, Enabled, Description, FullName, LastLogon, AccountExpires, PasswordLastSet, PasswordRequired, UserMayChangePassword)
		SELECT
			@Hostname,
			@Timestamp,
			JSON_VALUE(Users.value, '$.Name'),
			JSON_VALUE(Users.value, '$.Enabled'),
			JSON_VALUE(Users.value, '$.Description'),
			JSON_VALUE(Users.value, '$.FullName'),
			JSON_VALUE(Users.value, '$.LastLogon'),
			JSON_VALUE(Users.value, '$.AccountExpires'),
			JSON_VALUE(Users.value, '$.PasswordLastSet'),
			JSON_VALUE(Users.value, '$.PasswordRequired'),
			JSON_VALUE(Users.value, '$.UserMayChangePassword')
		FROM
			OPENJSON(@Payload, '$.Identities.Users') AS Users

    DELETE FROM
        dbo.Groups
    WHERE
        Hostname = @Hostname

    INSERT INTO dbo.Groups (Hostname, Timestamp, Name, Description)
		SELECT
			@Hostname,
			@Timestamp,
			JSON_VALUE(Groups.value, '$.Name'),
			JSON_VALUE(Groups.value, '$.Description')
		FROM
			OPENJSON(@Payload, '$.Identities.Groups') AS Groups

    DELETE FROM
        dbo.GroupMembers
    WHERE
        Hostname = @Hostname

    INSERT INTO dbo.GroupMembers (Hostname, Timestamp, GroupName, MemberName, ObjectClass)
		SELECT
			@Hostname,
			@Timestamp,
			JSON_VALUE(Groups.value, '$.Name'),
			JSON_VALUE(Members.value, '$.Name'),
			JSON_VALUE(Members.value, '$.ObjectClass')
		FROM
			OPENJSON(@Payload, '$.Identities.Groups') AS Groups
				CROSS APPLY
			OPENJSON(Groups.value, '$.Members') AS Members
		WHERE
			JSON_VALUE(Members.value, '$.Name') IS NOT NULL /* workaround */
END
GO
