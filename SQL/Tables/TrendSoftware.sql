CREATE TABLE [dbo].[TrendSoftware](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DisplayName] [varchar](255) NOT NULL,
	[DisplayVersion] [varchar](50) NULL,
	[Publisher] [varchar](255) NULL,
	[InstallDate] [varchar](50) NULL,
	[Deleted] [bit] NULL,
 CONSTRAINT [PK_TrendSoftware] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[DisplayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
