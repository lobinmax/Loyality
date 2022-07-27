CREATE TABLE [loyalty].[ClientBonusАccounts] (
  [BonusAccountUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientBon__Bonus__6383C8BA] DEFAULT (newid()),
  [ClientUID] [uniqueidentifier] NOT NULL,
  [AccountNumber] [varchar](50) NOT NULL,
  [DtOpen] [date] NOT NULL CONSTRAINT [DF__ClientBon__DtOpe__035179CE] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtClose] [date] NULL,
  [ReasonClosingId] [int] NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__ClientBon__DtCre__0E391C95] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__ClientBon__DtUpd__0F2D40CE] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientBon__Creat__719CDDE7] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdeterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__ClientBon__Updet__72910220] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_ClientBonusАccount_BonusAccountUID] PRIMARY KEY CLUSTERED ([BonusAccountUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ClientBonusАccount]
  ON [loyalty].[ClientBonusАccounts] ([AccountNumber])
  ON [PRIMARY]
GO

ALTER TABLE [loyalty].[ClientBonusАccounts]
  ADD CONSTRAINT [FK_ClientBonusАccount_ClientUID] FOREIGN KEY ([ClientUID]) REFERENCES [cust].[Clients] ([ClientUID])
GO

ALTER TABLE [loyalty].[ClientBonusАccounts]
  ADD CONSTRAINT [FK_ClientBonusАccount_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [loyalty].[ClientBonusАccounts]
  ADD CONSTRAINT [FK_ClientBonusАccount_UpdeterUID] FOREIGN KEY ([UpdeterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [loyalty].[ClientBonusАccounts]
  ADD CONSTRAINT [FK_ClientBonusАccounts_AccountReasonClosing_ReasonClosingId] FOREIGN KEY ([ReasonClosingId]) REFERENCES [loyalty].[AccountReasonClosing] ([ReasonClosingId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Бонусные счета клиента', 'SCHEMA', N'loyalty', 'TABLE', N'ClientBonusАccounts'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Номер бонусного счета', 'SCHEMA', N'loyalty', 'TABLE', N'ClientBonusАccounts', 'COLUMN', N'AccountNumber'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата открытия счета', 'SCHEMA', N'loyalty', 'TABLE', N'ClientBonusАccounts', 'COLUMN', N'DtOpen'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата закррытия счета', 'SCHEMA', N'loyalty', 'TABLE', N'ClientBonusАccounts', 'COLUMN', N'DtClose'
GO