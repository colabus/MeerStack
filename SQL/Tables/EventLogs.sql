USE [MeerStack]
GO

CREATE TABLE [dbo].[EventLogs](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NULL,
	[LogName] [varchar](100) NOT NULL,
	[LevelDisplayName] [varchar](50) NULL,
	[TimeCreated] [datetime2](7) NOT NULL,
	[ProviderName] [varchar](max) NULL,
	[TaskDisplayName] [varchar](50) NULL,
	[Message] [varchar](max) NULL,
	[Id] [int] NULL,
	[RecordID] [bigint] NOT NULL,
	[MachineName] [varchar](50) NULL,
 CONSTRAINT [PK_EventLogs] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[LogName] ASC,
	[TimeCreated] ASC,
	[RecordID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
