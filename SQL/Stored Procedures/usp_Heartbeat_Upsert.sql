USE [MeerStack]
GO

CREATE PROCEDURE [dbo].[usp_Heartbeat_Upsert]

	@PayLoad nvarchar(MAX)

AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Hostname varchar(50),
            @Timestamp datetime,
            @IPAddresses varchar(100),
            @OS varchar(MAX),
			@CurrentTimeZone int,
            @Domain varchar(50),
			@LogonServer varchar(50),
            @TotalMemoryGB float,
            @CPU varchar(MAX),
            @NumberOfLogicalProcessors int,
            @BootTime datetime,
			@MeerStackScriptName varchar(MAX),
			@MeerStackScriptVersion varchar(50),
			@MeerStackDatabaseVersion varchar(50),
			@MeerStackScriptStartTime datetime,
			@MeerStackLogFileSize varchar(50),
			@FirewallProfileEnabled bit,
			@FirewallActiveProfile varchar(50),
			@PSVersion varchar(50),
			@PSEdition varchar(50),
            @RebootRequired bit,
			@ResourceMemory varchar(50)

    SELECT
        @Hostname                   = JSON_VALUE(@Payload, '$.Hostname'),
        @Timestamp                  = JSON_VALUE(@Payload, '$.Timestamp'),
        @IPAddresses                = JSON_VALUE(@Payload, '$.IPAddresses'),
        @OS                         = JSON_VALUE(@Payload, '$.OS'),
        @CurrentTimeZone            = JSON_VALUE(@Payload, '$.CurrentTimeZone'),
        @Domain                     = JSON_VALUE(@Payload, '$.Domain'),
        @LogonServer                = JSON_VALUE(@Payload, '$.LogonServer'),
        @TotalMemoryGB              = JSON_VALUE(@Payload, '$.TotalMemoryGB'),
        @CPU                        = JSON_VALUE(@Payload, '$.CPU'),
        @NumberOfLogicalProcessors  = JSON_VALUE(@Payload, '$.NumberOfLogicalProcessors'),
        @BootTime                   = JSON_VALUE(@Payload, '$.BootTime'),
        @MeerStackScriptName        = JSON_VALUE(@Payload, '$.MeerStackScriptName'),
        @MeerStackScriptVersion     = JSON_VALUE(@Payload, '$.MeerStackScriptVersion'),
		@MeerStackDatabaseVersion   = JSON_VALUE(@Payload, '$.MeerStackDatabaseVersion'),
        @MeerStackScriptStartTime   = JSON_VALUE(@Payload, '$.MeerStackScriptStartTime'),
		@MeerStackLogFileSize		= JSON_VALUE(@PayLoad, '$.MeerStackLogFileSize'),
        @FirewallProfileEnabled     = JSON_VALUE(@Payload, '$.FirewallProfileEnabled'),
        @FirewallActiveProfile      = JSON_VALUE(@Payload, '$.FirewallActiveProfile'),
        @PSVersion                  = JSON_VALUE(@Payload, '$.PSVersion'),
        @PSEdition                  = JSON_VALUE(@Payload, '$.PSEdition'),
        @RebootRequired             = JSON_VALUE(@Payload, '$.RebootRequired'),
		@ResourceMemory				= JSON_VALUE(@Payload, '$.ResourceMemory')

    SET NOCOUNT OFF

    IF EXISTS (SELECT 1 FROM dbo.Heartbeats WHERE Hostname = @Hostname)
    BEGIN
        UPDATE dbo.Heartbeats SET
            Timestamp					= @Timestamp,
            IPAddresses					= @IPAddresses,
            OS							= @OS,
			CurrentTimeZone				= @CurrentTimeZone,
            Domain						= @Domain,
			LogonServer					= @LogonServer,
            TotalMemoryGB				= @TotalMemoryGB,
            CPU							= @CPU,
            NumberOfLogicalProcessors	= @NumberOfLogicalProcessors,
            BootTime					= @BootTime,
			MeerStackScriptName			= @MeerStackScriptName,
			MeerStackScriptVersion		= @MeerStackScriptVersion,
			MeerStackDatabaseVersion	= @MeerStackDatabaseVersion,
			MeerStackScriptStartTime	= @MeerStackScriptStartTime,
			MeerStackLogFileSize		= @MeerStackLogFileSize,
			FirewallProfileEnabled		= @FirewallProfileEnabled,
			FirewallActiveProfile		= @FirewallActiveProfile,
			PSVersion					= @PSVersion,
			PSEdition					= @PSEdition,
            RebootRequired				= @RebootRequired,
			ResourceMemory				= @ResourceMemory
        WHERE
            Hostname = @Hostname
    END
    ELSE
    BEGIN
        INSERT INTO dbo.Heartbeats
            (
                Hostname,
                Timestamp,
                IPAddresses,
                OS,
				CurrentTimeZone,
                Domain,
				LogonServer,
                TotalMemoryGB,
                CPU,
                NumberOfLogicalProcessors,
                BootTime,
				MeerStackScriptName,
				MeerStackScriptVersion,
				MeerStackDatabaseVersion,
				MeerStackScriptStartTime,
				MeerStackLogFileSize,
				Alive,
				FirewallProfileEnabled,
				FirewallActiveProfile,
				PSVersion,
				PSEdition,
                RebootRequired,
				ResourceMemory
            ) VALUES (
                @Hostname,
                @Timestamp,
                @IPAddresses,
                @OS,
				@CurrentTimeZone,
                @Domain,
				@LogonServer,
                @TotalMemoryGB,
                @CPU,
                @NumberOfLogicalProcessors,
                @BootTime,
				@MeerStackScriptName,
				@MeerStackScriptVersion,
				@MeerStackDatabaseVersion,
				@MeerStackScriptStartTime,
				@MeerStackLogFileSize,
				1,
				@FirewallProfileEnabled,
				@FirewallActiveProfile,
				@PSVersion,
				@PSEdition,
                @RebootRequired,
				@ResourceMemory
            )
    END
END



GO
