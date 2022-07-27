CREATE TABLE [bonus-charge].[BonusDocumentsType] (
  [DocumentTypeId] [int] NOT NULL,
  [Name] [varchar](150) NOT NULL,
  [IsDebet] [bit] NOT NULL CONSTRAINT [DF__BonusDocu__IsDeb__442B18F2] DEFAULT (0),
  [Description] [varchar](max) NULL,
  CONSTRAINT [PK_BonusDocumentsType_DocumentTypeId] PRIMARY KEY CLUSTERED ([DocumentTypeId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE INDEX [IDX_BonusDocumentsType_DocumentTypeId]
  ON [bonus-charge].[BonusDocumentsType] ([DocumentTypeId])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_BonusDocumentsType_Name]
  ON [bonus-charge].[BonusDocumentsType] ([Name])
  ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Типы докуметов начислений бонусов', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusDocumentsType'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Документ со знаком минус', 'SCHEMA', N'bonus-charge', 'TABLE', N'BonusDocumentsType', 'COLUMN', N'IsDebet'
GO