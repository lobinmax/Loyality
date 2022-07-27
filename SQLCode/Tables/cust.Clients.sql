CREATE TABLE [cust].[Clients] (
  [ClientUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Clients__ClientU__5FB337D6] DEFAULT (newid()),
  [ClientIdExternal] [numeric](15) NOT NULL,
  [ClientTypeId] [int] NOT NULL,
  [DtCreate] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_Clients_ClientUID] PRIMARY KEY CLUSTERED ([ClientUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_Clients_ClientIdExternal]
  ON [cust].[Clients] ([ClientIdExternal])
  ON [PRIMARY]
GO

ALTER TABLE [cust].[Clients]
  ADD CONSTRAINT [FK_Clients_ClientsType] FOREIGN KEY ([ClientTypeId]) REFERENCES [cust].[ClientsType] ([ClientTypeId])
GO

ALTER TABLE [cust].[Clients]
  ADD CONSTRAINT [FK_Clients_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внутренний ИД клиента', 'SCHEMA', N'cust', 'TABLE', N'Clients', 'COLUMN', N'ClientUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внешний идентификатор клиента в РБС или Диасофте', 'SCHEMA', N'cust', 'TABLE', N'Clients', 'COLUMN', N'ClientIdExternal'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Тип клиента (ЮЛ, ФЛ и т.д)', 'SCHEMA', N'cust', 'TABLE', N'Clients', 'COLUMN', N'ClientTypeId'
GO