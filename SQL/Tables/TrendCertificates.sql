USE [MeerStack]
GO

CREATE TABLE [dbo].[TrendCertificates](
	[Hostname] [varchar](50) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[DnsNameList] [varchar](max) NOT NULL,
	[Issuer] [varchar](max) NOT NULL,
	[NotBefore] [datetime] NOT NULL,
	[NotAfter] [datetime] NOT NULL,
	[HasPrivateKey] [bit] NOT NULL,
	[SerialNumber] [varchar](50) NOT NULL,
	[Subject] [varchar](max) NOT NULL,
	[Thumbprint] [varchar](50) NOT NULL,
	[Template] [varchar](50) NULL,
	[Version] [float] NOT NULL,
	[Deleted] [bit] NULL,
 CONSTRAINT [PK_TrendCertificates] PRIMARY KEY CLUSTERED 
(
	[Hostname] ASC,
	[Timestamp] ASC,
	[Thumbprint] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
