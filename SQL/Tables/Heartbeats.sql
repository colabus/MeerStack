CREATE TABLE [dbo].[Heartbeats](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NULL,
	[Server] [varchar](50) NULL,
	[IPAddresses] [varchar](100) NULL,
	[OS] [varchar](max) NULL,
	[CurrentTimeZone] [int] NULL,
	[Domain] [varchar](50) NULL,
	[LogonServer] [varchar](50) NULL,
	[TotalMemoryGB] [float] NULL,
	[CPU] [varchar](max) NULL,
	[NumberOfLogicalProcessors] [int] NULL,
	[BootTime] [datetime] NULL,
	[EventLogsLastUpdated] [datetime] NULL,
	[MeerStackScriptName] [varchar](max) NULL,
	[MeerStackScriptVersion] [varchar](50) NULL,
	[MeerStackScriptStartTime] [datetime] NULL,
	[Alive] [bit] NULL,
	[FirewallProfileEnabled] [bit] NULL,
	[FirewallActiveProfile] [varchar](50) NULL,
	[PSVersion] [varchar](50) NULL,
	[PSEdition] [varchar](50) NULL,
 CONSTRAINT [PK_Heartbeats] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

