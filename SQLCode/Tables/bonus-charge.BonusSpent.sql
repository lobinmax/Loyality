CREATE TABLE [bonus-charge].[BonusSpent] (
  [BonusSpentUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusSpen__Bonus__2B4A5C8F] DEFAULT (newid()),
  [BonusAccountUID] [uniqueidentifier] NOT NULL,
  [TransactionUID] [uniqueidentifier] NOT NULL,
  [ServiceContractUID] [uniqueidentifier] NOT NULL,
  [DtChange] [datetime2] NOT NULL,
  [AccountUID] [uniqueidentifier] NOT NULL,
  [DtBegin] [date] NOT NULL,
  [DtEnd] [date] NOT NULL,
  [AmountFromSite] [money] NOT NULL,
  [AmountFromOurBD] [money] NOT NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__BonusSpen__DtCre__1EE485AA] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__BonusSpen__DtUpd__1FD8A9E3] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusSpen__Creat__20CCCE1C] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusSpen__Updat__21C0F255] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_BonusSpent_BonusSpentUID] PRIMARY KEY CLUSTERED ([BonusSpentUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_BonusSpent]
  ON [bonus-charge].[BonusSpent] ([AccountUID], [ServiceContractUID], [DtBegin], [DtEnd])
  ON [PRIMARY]
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_AccountUID] FOREIGN KEY ([AccountUID]) REFERENCES [cust].[ClientAccounts] ([AccountUID])
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_ClientUID] FOREIGN KEY ([BonusAccountUID]) REFERENCES [loyalty].[ClientBonusАccounts] ([BonusAccountUID])
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_ServiceContractUID] FOREIGN KEY ([ServiceContractUID]) REFERENCES [config].[TypesServiceContracts] ([ServiceContractUID])
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_TransactionUID] FOREIGN KEY ([TransactionUID]) REFERENCES [bonus-charge].[BonusTransactions] ([TransactionUID])
GO

ALTER TABLE [bonus-charge].[BonusSpent]
  ADD CONSTRAINT [FK_BonusSpent_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Потраченные бонусы, для отдачи в Diasoft', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusSpent'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД проводки списания подраченых баллов', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusSpent', 'COLUMN', N'TransactionUID'
GO