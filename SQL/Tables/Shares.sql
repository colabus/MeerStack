USE [MeerStack]
GO

CREATE TABLE [dbo].[Shares](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Path] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[Status] [varchar](50) NULL,
	[Type] [varchar](50) NULL,
 CONSTRAINT [PK_Shares] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
