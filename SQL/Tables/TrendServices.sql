CREATE TABLE [dbo].[TrendServices](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[DisplayName] [varchar](100) NULL,
	[State] [varchar](50) NOT NULL,
	[StartMode] [varchar](50) NOT NULL,
	[DelayedAutoStart] [bit] NULL,
	[StartName] [varchar](50) NULL,
	[PathName] [varchar](max) NULL,
	[ServiceType] [varchar](50) NULL,
 CONSTRAINT [PK_TrendServices] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
