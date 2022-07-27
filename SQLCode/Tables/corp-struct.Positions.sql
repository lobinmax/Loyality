CREATE TABLE [corp-struct].[Positions] (
  [PositionId] [int] IDENTITY (0, 1),
  [Name] [varchar](100) NOT NULL,
  CONSTRAINT [PK_Positions_PositionId] PRIMARY KEY CLUSTERED ([PositionId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_Positions_Name]
  ON [corp-struct].[Positions] ([Name])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Таблица должностей', 'SCHEMA', N'corp-struct', 'TABLE', N'Positions'
GO