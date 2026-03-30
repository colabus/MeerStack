CREATE TABLE [dbo].[HostConfiguration](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Hostname] [varchar](50) NOT NULL,
	[HeartbeatInterval] [int] NOT NULL,
	[HeartbeatAlertThreshold] [int] NULL,
	[Cpu] [bit] NOT NULL,
	[CpuInterval] [int] NOT NULL,
	[Memory] [bit] NOT NULL,
	[MemoryInterval] [int] NOT NULL,
	[Services] [bit] NOT NULL,
	[ServicesInterval] [int] NOT NULL,
	[ServicesToCheck] [varchar](max) NOT NULL,
	[ServicesVerbose] [bit] NOT NULL,
	[ServicesAlertLastUpdated] [datetime] NULL,
	[Disks] [bit] NOT NULL,
	[DisksInterval] [int] NOT NULL,
	[Certificates] [bit] NOT NULL,
	[CertificatesInterval] [int] NOT NULL,
	[EventLogs] [bit] NOT NULL,
	[EventLogsInterval] [int] NOT NULL,
	[EventLogsXmlFilter] [varchar](max) NOT NULL,
	[EventLogsLastUpdated] [datetime] NULL,
	[Sessions] [bit] NOT NULL,
	[SessionsInterval] [int] NOT NULL,
	[Processes] [bit] NOT NULL,
	[ProcessesInterval] [int] NOT NULL,
	[Connections] [bit] NOT NULL,
	[ConnectionsInterval] [int] NOT NULL,
	[NotificationRecipients] [varchar](max) NULL,
 CONSTRAINT [PK_HostConfiguration] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

