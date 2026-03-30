CREATE TABLE [dbo].[CheckLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Hostname] [varchar](50) NOT NULL,
	[Filename] [varchar](50) NOT NULL,
	[Payload] [xml] NOT NULL,
	[Processed] [bit] NOT NULL,
	[ProcessedDate] [datetime] NULL,
	[Skipped] [bit] NULL,
 CONSTRAINT [PK_CheckLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Timestamp]  DEFAULT (getdate()) FOR [Timestamp]
GO

ALTER TABLE [dbo].[CheckLog] ADD  CONSTRAINT [DF_CheckLog_Processed]  DEFAULT ((0)) FOR [Processed]
GO

