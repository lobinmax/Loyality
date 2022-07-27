CREATE TABLE [bonus-charge].[BonusTransactionsBase] (
  [TransactionUID] [uniqueidentifier] NOT NULL,
  [OperationUID] [uniqueidentifier] NOT NULL,
  [OperationHandlerUID] [uniqueidentifier] NOT NULL,
  [IsCanceled] [bit] NOT NULL DEFAULT (CONVERT([bit],(0))),
  CONSTRAINT [PK_BonusTransactionsBase_TransactionUID] PRIMARY KEY CLUSTERED ([TransactionUID])
)
ON [PRIMARY]
GO

ALTER TABLE [bonus-charge].[BonusTransactionsBase]
  ADD CONSTRAINT [FK_BonusTransactionsBase_OperationHandlerUID] FOREIGN KEY ([OperationHandlerUID]) REFERENCES [loyalty].[BonusOperationsHandlers] ([OperationHandlerUID])
GO

ALTER TABLE [bonus-charge].[BonusTransactionsBase]
  ADD CONSTRAINT [FK_BonusTransactionsBase_OperationUID] FOREIGN KEY ([OperationUID]) REFERENCES [loyalty].[BonusOperationsBook] ([OperationUID])
GO

ALTER TABLE [bonus-charge].[BonusTransactionsBase]
  ADD CONSTRAINT [FK_BonusTransactionsBase_TransactionUID] FOREIGN KEY ([TransactionUID]) REFERENCES [bonus-charge].[BonusTransactions] ([TransactionUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Операции начисления бонусов, которые произведены в рамках осносных бонусных операций из [BonusOperationsBook]', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactionsBase'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Начисление аннулировано согласно условий', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactionsBase', 'COLUMN', N'IsCanceled'
GO