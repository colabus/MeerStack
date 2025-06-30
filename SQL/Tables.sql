USE [MeerStack]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CheckLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Hostname] [varchar](50) NOT NULL,
	[Filename] [varchar](50) NOT NULL,
	[Payload] [xml] NOT NULL,
	[Processed] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[EventLogs](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NULL,
	[LogName] [varchar](100) NOT NULL,
	[LevelDisplayName] [varchar](50) NULL,
	[TimeCreated] [datetime] NOT NULL,
	[ProviderName] [varchar](max) NULL,
	[TaskDisplayName] [varchar](50) NULL,
	[Message] [varchar](max) NULL,
	[ID] [int] NULL,
	[RecordID] [bigint] NOT NULL,
 CONSTRAINT [PK_EventLogs] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[LogName] ASC,
	[TimeCreated] ASC,
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Heartbeats](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NULL,
	[Server] [varchar](50) NULL,
	[IPAddresses] [varchar](50) NULL,
	[OS] [varchar](max) NULL,
	[Domain] [varchar](50) NULL,
	[TotalMemoryGB] [float] NULL,
	[CPU] [varchar](max) NULL,
	[NumberOfLogicalProcessors] [int] NULL,
	[BootTime] [datetime] NULL,
	[EventLogsLastUpdated] [datetime] NULL,
 CONSTRAINT [PK_Heartbeats] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[HostConfiguration](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Hostname] [varchar](50) NOT NULL,
	[Cpu] [bit] NOT NULL,
	[CpuInterval] [int] NOT NULL,
	[Memory] [bit] NOT NULL,
	[MemoryInterval] [int] NOT NULL,
	[Services] [bit] NOT NULL,
	[ServicesInterval] [int] NOT NULL,
	[ServicesToCheck] [varchar](max) NOT NULL,
	[ServicesVerbose] [bit] NOT NULL,
	[Disks] [bit] NOT NULL,
	[DisksInterval] [int] NOT NULL,
	[Certificates] [bit] NULL,
	[CertificatesInterval] [int] NULL,
	[EventLogs] [bit] NULL,
	[EventLogsInterval] [int] NULL,
	[EventLogsXmlFilter] [varchar](max) NULL,
	[Sessions] [bit] NULL,
	[SessionsInterval] [int] NULL,
	[Processes] [bit] NULL,
	[ProcessesInterval] [int] NULL,
	[HeartbeatInterval] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MetricsCPU](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[PercentProcessorTime] [float] NOT NULL,
 CONSTRAINT [PK_MetricsCPU] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MetricsMemory](
	[Hostname] [varchar](50) NULL,
	[Timestamp] [datetime] NULL,
	[UsedMB] [int] NULL,
	[TotalMB] [int] NULL,
	[UsedPercent] [float] NULL
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Systems](
	[Hostname] [varchar](50) NOT NULL,
	[Description] [varchar](max) NULL,
	[Environment] [varchar](50) NULL,
	[Details] [varchar](max) NULL,
 CONSTRAINT [PK_Systems] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TrendCertificates](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DnsNameList] [varchar](max) NOT NULL,
	[Issuer] [varchar](max) NOT NULL,
	[NotBefore] [datetime] NOT NULL,
	[NotAfter] [datetime] NOT NULL,
	[HasPrivateKey] [bit] NOT NULL,
	[SerialNumber] [varchar](50) NOT NULL,
	[Subject] [varchar](max) NOT NULL,
	[Thumbprint] [varchar](50) NOT NULL,
	[Template] [varchar](50) NULL,
	[Version] [float] NOT NULL,
	[Deleted] [bit] NULL,
 CONSTRAINT [PK_TrendCertificates] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Thumbprint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TrendDisks](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DeviceID] [varchar](50) NOT NULL,
	[VolumeName] [varchar](50) NULL,
	[SizeGB] [float] NOT NULL,
	[UsedGB] [float] NOT NULL,
	[FreeGB] [float] NOT NULL,
	[UsedPercent] [float] NOT NULL,
 CONSTRAINT [PK_TrendDisks] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TrendServices](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[DisplayName] [varchar](50) NULL,
	[Status] [varchar](50) NOT NULL,
	[StartType] [varchar](50) NOT NULL,
 CONSTRAINT [PK_TrendServices] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TrendSessions](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[ID] [int] NOT NULL,
	[SessionName] [varchar](50) NULL,
	[LogonTime] [datetime] NULL,
	[IdleTime] [int] NULL,
	[UserName] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Deleted] [bit] NULL,
 CONSTRAINT [PK_TrendSessions] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Processed]  DEFAULT ((0)) FOR [Processed]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Version](
	[ScriptVersion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED 
(
	[ScriptVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO