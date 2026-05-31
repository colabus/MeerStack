USE [MeerStack]
GO

CREATE TABLE [dbo].[RegistryKeys](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[RegistryKeys] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_RegistryKeys] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[RegistryKeys]  WITH CHECK ADD  CONSTRAINT [RegistryKeys_RegistryKeys] CHECK  ((isjson([RegistryKeys])=(1)))
GO

ALTER TABLE [dbo].[RegistryKeys] CHECK CONSTRAINT [RegistryKeys_RegistryKeys]
GO
