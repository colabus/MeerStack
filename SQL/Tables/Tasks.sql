USE [MeerStack]
GO

CREATE TABLE [dbo].[Tasks](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Path] [varchar](100) NOT NULL,
	[Description] [varchar](max) NULL,
	[Author] [varchar](100) NULL,
	[State] [varchar](50) NOT NULL,
	[PrincipalUserId] [varchar](100) NULL,
	[PrincipalLogonType] [varchar](50) NULL,
	[PrincipalRunLevel] [varchar](50) NULL,
	[LastRunTime] [datetime] NULL,
	[LastResult] [varchar](50) NULL,
	[NextRunTime] [datetime] NULL,
 CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Path] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
