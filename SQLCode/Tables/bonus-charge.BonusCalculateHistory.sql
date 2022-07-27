CREATE TABLE [bonus-charge].[BonusCalculateHistory] (
  [DtAppeal] [date] NULL,
  [CreaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]())
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_BonusCalculateHistory_DtAppeal ]
  ON [bonus-charge].[BonusCalculateHistory] ([DtAppeal])
  ON [PRIMARY]
GO

ALTER TABLE [bonus-charge].[BonusCalculateHistory]
  ADD CONSTRAINT [FK_BonusCalculateHistory_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'История загрузки первичных документов из АБС', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusCalculateHistory'
GO