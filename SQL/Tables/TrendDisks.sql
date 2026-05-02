USE [MeerStack]
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
	[Description] [varchar](50) NULL,
	[FileSystem] [varchar](50) NULL,
	[VolumeSerialNumber] [varchar](50) NULL,
 CONSTRAINT [PK_TrendDisks] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
