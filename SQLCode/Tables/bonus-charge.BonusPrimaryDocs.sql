CREATE TABLE [bonus-charge].[BonusPrimaryDocs] (
  [PrimaryDocUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusPrim__Prima__46D27B73] DEFAULT (newid()),
  [TransactionUID] [uniqueidentifier] NOT NULL,
  [TransactionExternalID] [numeric](15) NOT NULL,
  [ClientUID] [uniqueidentifier] NOT NULL,
  [BonusAccountUID] [uniqueidentifier] NOT NULL,
  [AccountIdExternal] [numeric](15) NOT NULL,
  [DtPrimaryDoc] [date] NOT NULL,
  [AmountPrimaryDoc] [money] NOT NULL,
  [Description] [varchar](max) NULL,
  CONSTRAINT [PK_BonusPrimaryDocs_TransactionUID] PRIMARY KEY CLUSTERED ([PrimaryDocUID])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE INDEX [IDX_BonusPrimaryDocs_BonusAccountUID]
  ON [bonus-charge].[BonusPrimaryDocs] ([BonusAccountUID])
  ON [PRIMARY]
GO

CREATE INDEX [IDX_BonusPrimaryDocs_ClientUID]
  ON [bonus-charge].[BonusPrimaryDocs] ([ClientUID])
  ON [PRIMARY]
GO

ALTER TABLE [bonus-charge].[BonusPrimaryDocs]
  ADD CONSTRAINT [FK_BonusPrimaryDocs_BonusAccountUID] FOREIGN KEY ([BonusAccountUID]) REFERENCES [loyalty].[ClientBonusАccounts] ([BonusAccountUID])
GO

ALTER TABLE [bonus-charge].[BonusPrimaryDocs]
  ADD CONSTRAINT [FK_BonusPrimaryDocs_ClientAccounts_AccountIdExternal] FOREIGN KEY ([AccountIdExternal]) REFERENCES [cust].[ClientAccounts] ([AccountIdExternal])
GO

ALTER TABLE [bonus-charge].[BonusPrimaryDocs]
  ADD CONSTRAINT [FK_BonusPrimaryDocs_ClientUID] FOREIGN KEY ([ClientUID]) REFERENCES [cust].[Clients] ([ClientUID])
GO

ALTER TABLE [bonus-charge].[BonusPrimaryDocs]
  ADD CONSTRAINT [FK_BonusPrimaryDocs_TransactionUID] FOREIGN KEY ([TransactionUID]) REFERENCES [bonus-charge].[BonusTransactions] ([TransactionUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Первиные документы - основания для начисленных бонусов', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusPrimaryDocs'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД первичного документа во внешней АБС', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusPrimaryDocs', 'COLUMN', N'TransactionExternalID'
GO