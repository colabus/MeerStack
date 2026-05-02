USE [MeerStack]
GO

CREATE TABLE [dbo].[TrendCheckLog](
	[Timestamp] [datetime] NOT NULL,
	[BacklogCount] [int] NULL,
	[MinTimestamp] [datetime] NULL,
	[MinDateVariance] [int] NULL,
	[MaxTimestamp] [datetime] NULL,
	[MaxDateVariance] [int] NULL,
	[HeartbeatMinTimestamp] [datetime] NULL,
	[HeartbeatMinDateVariance] [int] NULL,
	[HeartbeatMaxTimestamp] [datetime] NULL,
	[HeartbeatMaxDateVariance] [int] NULL,
 CONSTRAINT [PK_TrendCheckLog] PRIMARY KEY CLUSTERED 
(
	[Timestamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
