CREATE TABLE [loyalty].[BonusOperationsHandlers] (
  [OperationHandlerUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusOper__Opera__5070F446] DEFAULT (newid()),
  [OperationUID] [uniqueidentifier] NOT NULL,
  [DtBegin] [date] NOT NULL,
  [PointsCount] [money] NOT NULL,
  [PointsCountMin] [int] NOT NULL CONSTRAINT [DF_BonusOperationsHandlers_PointsCountMin] DEFAULT (0),
  [PointsCountMax] [int] NOT NULL,
  [MethodChargeId] [int] NOT NULL,
  [ОnlyFirstOneForClient] [bit] NOT NULL CONSTRAINT [DF_BonusOperationsHandlers_ОnlyFirstOne] DEFAULT (CONVERT([bit],(0))),
  [ОnlyFirstOneForAccount] [bit] NOT NULL CONSTRAINT [DF_BonusOperationsHandlers_ОnlyFirstOneForClient1] DEFAULT (CONVERT([bit],(0))),
  [HandlerName] [varchar](150) NOT NULL,
  [HandlerRequest] [varchar](150) NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__BonusOper__DtCre__02C769E9] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__BonusOper__DtUpd__03BB8E22] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusOper__Creat__756D6ECB] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__BonusOper__Updat__76619304] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_BonusOperationsHandlers_OperationHandlerUID] PRIMARY KEY CLUSTERED ([OperationHandlerUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_BonusOperationsHandlers]
  ON [loyalty].[BonusOperationsHandlers] ([OperationUID], [DtBegin])
  ON [PRIMARY]
GO

ALTER TABLE [loyalty].[BonusOperationsHandlers]
  ADD CONSTRAINT [FK_BonusOperationsHandlers_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [loyalty].[BonusOperationsHandlers]
  ADD CONSTRAINT [FK_BonusOperationsHandlers_MethodChargeId] FOREIGN KEY ([MethodChargeId]) REFERENCES [loyalty].[BonusMethodCharge] ([MethodChargeId])
GO

ALTER TABLE [loyalty].[BonusOperationsHandlers]
  ADD CONSTRAINT [FK_BonusOperationsHandlers_OperationUID] FOREIGN KEY ([OperationUID]) REFERENCES [loyalty].[BonusOperationsBook] ([OperationUID])
GO

ALTER TABLE [loyalty].[BonusOperationsHandlers]
  ADD CONSTRAINT [FK_BonusOperationsHandlers_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Обработчики для бонусных программ', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД бонусной операции', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'OperationUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Начало работы обработчика', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'DtBegin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Кол-во баллов начисляемых за операцию', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'PointsCount'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Минимальное кол-во баллов возможных к начислению', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'PointsCountMin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Максимальное кол-во баллов возможных к начислению', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'PointsCountMax'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Метод начисления баллов', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'MethodChargeId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Начислять только за первый факт для клиента. Факт определять наличием записи в [bonus-charge].[BonusTransactionsBase]', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'ОnlyFirstOneForClient'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Начислять только за первый факт для банковского счета. Факт определять наличием записи в [bonus-charge].[BonusPrimaryDocs]', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'ОnlyFirstOneForAccount'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Имя ХП которая начисляет бонусы в формате [схема].[имя ХП]', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'HandlerName'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Строка запроса обращения к ХП', 'SCHEMA', N'loyalty', 'TABLE', N'BonusOperationsHandlers', 'COLUMN', N'HandlerRequest'
GO