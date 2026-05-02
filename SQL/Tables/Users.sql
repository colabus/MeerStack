USE [MeerStack]
GO

CREATE TABLE [dbo].[Users](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[Enabled] [bit] NOT NULL,
	[Description] [varchar](max) NULL,
	[FullName] [varchar](50) NULL,
	[LastLogon] [datetime] NULL,
	[AccountExpires] [datetime] NULL,
	[PasswordLastSet] [datetime] NULL,
	[PasswordRequired] [bit] NOT NULL,
	[UserMayChangePassword] [bit] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
