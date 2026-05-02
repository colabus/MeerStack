USE [MeerStack]
GO

CREATE TABLE [dbo].[SharePermissions](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[ShareName] [varchar](100) NOT NULL,
	[AccountName] [varchar](100) NOT NULL,
	[AccessRight] [varchar](50) NULL,
	[AccessControlType] [varchar](50) NULL,
 CONSTRAINT [PK_SharePermissions] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[ShareName] ASC,
	[AccountName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
