CREATE TABLE [cust].[ClientsType] (
  [ClientTypeId] [int] NOT NULL,
  [NameFull] [varchar](50) NOT NULL,
  [NameShort] [varchar](20) NOT NULL,
  CONSTRAINT [PK_ClientsType_ClientTypeId] PRIMARY KEY CLUSTERED ([ClientTypeId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ClientsType_NameFull]
  ON [cust].[ClientsType] ([NameFull])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ClientsType_NameShort]
  ON [cust].[ClientsType] ([NameShort])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Типы клиентов (КО, ИП, ФЛ и т.д)', 'SCHEMA', N'cust', 'TABLE', N'ClientsType'
GO