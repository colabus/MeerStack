USE [MeerStack]
GO

CREATE TABLE [dbo].[SQLServers](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[InstanceName] [varchar](50) NOT NULL,
	[Edition] [varchar](50) NULL,
	[Version] [varchar](50) NULL,
	[PatchLevel] [varchar](50) NULL,
	[SQLBinRoot] [varchar](255) NULL,
 CONSTRAINT [PK_SQLServers] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[InstanceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
