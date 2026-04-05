CREATE TABLE [dbo].[TrendConnections](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Protocol] [varchar](10) NOT NULL,
	[LocalAddress] [varchar](50) NOT NULL,
	[RemoteAddress] [varchar](50) NULL,
	[State] [varchar](50) NOT NULL,
	[PID] [varchar](10) NULL,
 CONSTRAINT [PK_TrendConnections] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Protocol] ASC,
	[LocalAddress] ASC,
	[State] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
