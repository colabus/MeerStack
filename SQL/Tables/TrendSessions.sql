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
