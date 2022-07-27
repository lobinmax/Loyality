CREATE TABLE [bonus-charge].[BonusTransactions] (
  [TransactionUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusTran__Trans__6C6E1476] DEFAULT (newid()),
  [DtTrasaction] [date] NOT NULL,
  [ClientUID] [uniqueidentifier] NOT NULL,
  [BonusAccountUID] [uniqueidentifier] NOT NULL,
  [AccruedBonuses] [int] NOT NULL CONSTRAINT [DF__BonusTran__Accru__6D6238AF] DEFAULT (CONVERT([int],(0))),
  [DocumentTypeId] [int] NOT NULL,
  [PeriodNumber] [int] NOT NULL CONSTRAINT [DF__BonusTran__Perio__62AFA012] DEFAULT ([dt].[GetPeriodNumber_DF](DEFAULT)),
  [Description] [varchar](max) NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__BonusTran__DtCre__6E565CE8] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__BonusTran__DtUpd__6F4A8121] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusTran__Creat__703EA55A] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusTran__Updat__7132C993] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_BonusTransactions_TransactionUID] PRIMARY KEY CLUSTERED ([TransactionUID])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [bonus-charge].[trgBonusTransactions_InsertUpdate]
ON [bonus-charge].[BonusTransactions]
AFTER INSERT, UPDATE
AS
BEGIN
    IF (UPDATE(DtTrasaction))
    BEGIN

        DECLARE @msg AS VARCHAR(MAX) 
        IF EXISTS (SELECT *
                   FROM INSERTED AS ins
                   WHERE ins.DtTrasaction < dt.GetCurrentDate())
        BEGIN

            SET @msg = 'Дата проводки не может быть меньше текущей даты';
            THROW 50001, @msg, 1;

            COMMIT
            ROLLBACK;
        END 
    END
END
GO

ALTER TABLE [bonus-charge].[BonusTransactions]
  ADD CONSTRAINT [FK_BonusTransactions_BonusAccountUID] FOREIGN KEY ([BonusAccountUID]) REFERENCES [loyalty].[ClientBonusАccounts] ([BonusAccountUID])
GO

ALTER TABLE [bonus-charge].[BonusTransactions]
  ADD CONSTRAINT [FK_BonusTransactions_ClientUID] FOREIGN KEY ([ClientUID]) REFERENCES [cust].[Clients] ([ClientUID])
GO

ALTER TABLE [bonus-charge].[BonusTransactions]
  ADD CONSTRAINT [FK_BonusTransactions_DocumentTypeId] FOREIGN KEY ([DocumentTypeId]) REFERENCES [bonus-charge].[BonusDocumentsType] ([DocumentTypeId])
GO

DISABLE TRIGGER [bonus-charge].[trgBonusTransactions_InsertUpdate] ON [bonus-charge].[BonusTransactions]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Проводки начислений бонусов за каждый день по бонусному счету', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД проводки', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'TransactionUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата проводки', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'DtTrasaction'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД клиента', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'ClientUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД бонусного счета клиента', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'BonusAccountUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Сумма начисленных бонусов', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'AccruedBonuses'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Тип документа. Так же по нему определяется знак', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'DocumentTypeId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Комментарий к проводке', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusTransactions', 'COLUMN', N'Description'
GO