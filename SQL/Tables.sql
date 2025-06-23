USE [MeerStack]
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
	[EventLogsXmlFilter] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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

CREATE TABLE [dbo].[MetricsMemory](
	[Hostname] [varchar](50) NULL,
	[Timestamp] [datetime] NULL,
	[UsedMB] [int] NULL,
	[TotalMB] [int] NULL,
	[UsedPercent] [float] NULL
) ON [PRIMARY]
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
	[Version] [float] NOT NULL,
 CONSTRAINT [PK_TrendCertificates] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Thumbprint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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

CREATE TABLE [dbo].[Version](
	[ScriptVersion] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED 
(
	[ScriptVersion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Processed]  DEFAULT ((0)) FOR [Processed]
GO
