CREATE TABLE [loyalty].[AccountReasonClosing] (
  [ReasonClosingId] [int] NOT NULL,
  [Name] [varchar](250) NOT NULL,
  CONSTRAINT [PK_AccountReasonClosing_ReasonClosingId] PRIMARY KEY CLUSTERED ([ReasonClosingId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_AccountReasonClosing_Name]
  ON [loyalty].[AccountReasonClosing] ([Name])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Причины закрытия бонусного счета', 'SCHEMA', N'loyalty', 'TABLE', N'AccountReasonClosing'
GO