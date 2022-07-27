CREATE TABLE [cust].[ClientAccounts] (
  [AccountUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientAcc__Accou__6A30C649] DEFAULT (newid()),
  [AccountIdExternal] [numeric](15) NOT NULL,
  [AccountNumberExternal] [varchar](50) NOT NULL,
  [ClientUID] [uniqueidentifier] NOT NULL,
  [DtOpen] [date] NOT NULL,
  [DtClose] [date] NULL,
  [CloseReason] [varchar](150) NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__ClientAcc__DtCre__0A688BB1] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__ClientAcc__DtUpd__0B5CAFEA] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientAcc__Creat__607251E5] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientAcc__Updat__6166761E] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_ClientAccounts_AccountUID] PRIMARY KEY CLUSTERED ([AccountUID])
)
ON [PRIMARY]
GO

CREATE INDEX [IDX_ClientAccounts_ClientUID]
  ON [cust].[ClientAccounts] ([ClientUID])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ClientAccounts_AccountIdExternal]
  ON [cust].[ClientAccounts] ([AccountIdExternal])
  ON [PRIMARY]
GO

CREATE INDEX [UK_ClientAccounts_AccountNumberExternal]
  ON [cust].[ClientAccounts] ([AccountNumberExternal])
  ON [PRIMARY]
GO

ALTER TABLE [cust].[ClientAccounts]
  ADD CONSTRAINT [FK_ClientAccounts_ClientUID] FOREIGN KEY ([ClientUID]) REFERENCES [cust].[Clients] ([ClientUID])
GO

ALTER TABLE [cust].[ClientAccounts]
  ADD CONSTRAINT [FK_ClientAccounts_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [cust].[ClientAccounts]
  ADD CONSTRAINT [FK_ClientAccounts_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внутренний ИД счета', 'SCHEMA', N'cust', 'TABLE', N'ClientAccounts', 'COLUMN', N'AccountUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внешний ИД счета в РБС или Диасофте', 'SCHEMA', N'cust', 'TABLE', N'ClientAccounts', 'COLUMN', N'AccountIdExternal'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата открытия (переходит из внешнего билинга)', 'SCHEMA', N'cust', 'TABLE', N'ClientAccounts', 'COLUMN', N'DtOpen'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата закрытия (переходит из внешнего билинга)', 'SCHEMA', N'cust', 'TABLE', N'ClientAccounts', 'COLUMN', N'DtClose'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Причина закрытия', 'SCHEMA', N'cust', 'TABLE', N'ClientAccounts', 'COLUMN', N'CloseReason'
GO