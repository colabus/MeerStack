USE [MeerStack]
GO

CREATE TABLE [dbo].[TaskActions](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[TaskName] [varchar](100) NOT NULL,
	[TaskPath] [varchar](100) NOT NULL,
	[Index] [int] NOT NULL,
	[Execute] [varchar](max) NULL,
	[ImagePath] [varchar](max) NULL,
	[Arguments] [varchar](max) NULL,
	[LastModified] [datetime] NULL,
 CONSTRAINT [PK_TaskActions] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[TaskPath] ASC,
	[TaskName] ASC,
	[Index] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
