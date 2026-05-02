USE [MeerStack]
GO

CREATE TABLE [dbo].[Systems](
	[Hostname] [varchar](50) NOT NULL,
	[Description] [varchar](max) NULL,
	[Environment] [varchar](50) NULL,
	[Details] [varchar](max) NULL,
	[Critical] [bit] NULL,
	[Pair] [int] NULL,
	[Application] [varchar](50) NULL,
	[System] [varchar](50) NULL,
	[Decommissioned] [bit] NULL,
	[AccessTierLevel] [int] NULL,
	[AccessGroup] [varchar](50) NULL,
	[Scope] [varchar](50) NULL,
 CONSTRAINT [PK_Systems] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
