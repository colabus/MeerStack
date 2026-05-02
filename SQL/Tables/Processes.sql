USE [MeerStack]
GO

CREATE TABLE [dbo].[Processes](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[PID] [int] NOT NULL,
	[Name] [varchar](255) NULL,
	[ParentPid] [int] NULL,
	[Path] [varchar](max) NULL,
	[CommandLine] [varchar](max) NULL,
	[StartTime] [datetime] NULL,
	[SessionId] [int] NULL,
	[SHA256] [varchar](64) NULL,
 CONSTRAINT [PK_TrendProcesses] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[PID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
