CREATE TABLE [cust].[ClientAccountsPackageHistory] (
  [PackageHistoryUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientAcc__Packa__03DB89B3] DEFAULT (newid()),
  [AccountUID] [uniqueidentifier] NOT NULL,
  [DtBegin] [date] NOT NULL,
  [DtEnd] [date] NULL,
  [PackageServiceUID] [uniqueidentifier] NOT NULL,
  [OperationHandlerUID] [uniqueidentifier] NOT NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__BonusTran__DtCre__6E565CE8] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__BonusTran__DtUpd__6F4A8121] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusTran__Creat__703EA55A] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusTran__Updat__7132C993] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_ClientAccountsPackageHistory_PackageHistoryUID] PRIMARY KEY CLUSTERED ([PackageHistoryUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ClientAccountsPackageHistory]
  ON [cust].[ClientAccountsPackageHistory] ([AccountUID], [DtBegin], [PackageServiceUID])
  ON [PRIMARY]
GO

ALTER TABLE [cust].[ClientAccountsPackageHistory]
  ADD CONSTRAINT [FK_ClientAccountsPackageHistory_AccountUID] FOREIGN KEY ([AccountUID]) REFERENCES [cust].[ClientAccounts] ([AccountUID])
GO

ALTER TABLE [cust].[ClientAccountsPackageHistory]
  ADD CONSTRAINT [FK_ClientAccountsPackageHistory_BonusOperationsHandlers_OperationHandlerUID] FOREIGN KEY ([OperationHandlerUID]) REFERENCES [loyalty].[BonusOperationsHandlers] ([OperationHandlerUID])
GO

ALTER TABLE [cust].[ClientAccountsPackageHistory]
  ADD CONSTRAINT [FK_ClientAccountsPackageHistory_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [cust].[ClientAccountsPackageHistory]
  ADD CONSTRAINT [FK_ClientAccountsPackageHistory_PackageServiceUID] FOREIGN KEY ([PackageServiceUID]) REFERENCES [config].[PackageServices] ([PackageServiceUID])
GO

ALTER TABLE [cust].[ClientAccountsPackageHistory]
  ADD CONSTRAINT [FK_ClientAccountsPackageHistory_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'История подлючения к пакетам услуг по счетам клиентов', 'SCHEMA', N'cust', 'TABLE', N'ClientAccountsPackageHistory'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внутренний ИД банковского счета', 'SCHEMA', N'cust', 'TABLE', N'ClientAccountsPackageHistory', 'COLUMN', N'AccountUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата подключения пакета', 'SCHEMA', N'cust', 'TABLE', N'ClientAccountsPackageHistory', 'COLUMN', N'DtBegin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата отключения пакета', 'SCHEMA', N'cust', 'TABLE', N'ClientAccountsPackageHistory', 'COLUMN', N'DtEnd'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внутренний идентификатор пакета услуг', 'SCHEMA', N'cust', 'TABLE', N'ClientAccountsPackageHistory', 'COLUMN', N'PackageServiceUID'
GO