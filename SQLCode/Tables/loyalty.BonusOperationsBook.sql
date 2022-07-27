CREATE TABLE [loyalty].[BonusOperationsBook] (
  [OperationUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusOper__Opera__4AB81AF0] DEFAULT (newid()),
  [Name] [varchar](300) NOT NULL,
  [DtBegin] [date] NOT NULL,
  [IsDisabled] [bit] NOT NULL CONSTRAINT [DF_BonusOperationsBook_IsEnabled] DEFAULT (CONVERT([bit],(0))),
  [Description] [varchar](max) NULL,
  [DtCreate] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_BonusOperationsBook_ProgrammUID] PRIMARY KEY CLUSTERED ([OperationUID])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_BonusOperationsBook_Name]
  ON [loyalty].[BonusOperationsBook] ([Name])
  ON [PRIMARY]
GO

ALTER TABLE [loyalty].[BonusOperationsBook]
  ADD CONSTRAINT [FK_BonusOperationsBook_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [loyalty].[BonusOperationsBook]
  ADD CONSTRAINT [FK_BonusOperationsBook_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Перечень бонусных операций', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsBook'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименование операции за которую может начислятся бонус', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsBook', 'COLUMN', N'Name'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата начала действия', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsBook', 'COLUMN', N'DtBegin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Начисление бонусов включено', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsBook', 'COLUMN', N'IsDisabled'
GO