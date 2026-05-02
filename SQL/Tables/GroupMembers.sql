USE [MeerStack]
GO

CREATE TABLE [dbo].[GroupMembers](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[GroupName] [varchar](100) NOT NULL,
	[MemberName] [varchar](100) NOT NULL,
	[ObjectClass] [varchar](50) NOT NULL,
 CONSTRAINT [PK_GroupMembers_1] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[GroupName] ASC,
	[MemberName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
