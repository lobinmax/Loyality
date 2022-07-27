CREATE TABLE [loyalty].[BonusMethodCharge] (
  [MethodChargeId] [int] NOT NULL,
  [Name] [varchar](50) NOT NULL,
  CONSTRAINT [PK_BonusMethodCharge_MethodChargeId] PRIMARY KEY CLUSTERED ([MethodChargeId])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Методы начисления бонусов', 'SCHEMA', N'loyalty', 'TABLE', N'BonusMethodCharge'
GO