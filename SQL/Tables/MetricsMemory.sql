CREATE TABLE [dbo].[MetricsMemory](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[UsedMB] [int] NULL,
	[TotalMB] [int] NULL,
	[UsedPercent] [float] NULL,
 CONSTRAINT [PK_MetricsMemory] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
