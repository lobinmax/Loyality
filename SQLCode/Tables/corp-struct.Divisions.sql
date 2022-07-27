CREATE TABLE [corp-struct].[Divisions] (
  [DivisionUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Deportame__Depor__34C8D9D1] DEFAULT (newid()),
  [DivisionParentUID] [uniqueidentifier] NULL,
  [NameFull] [varchar](150) NOT NULL,
  [NameShort] [varchar](100) NOT NULL,
  [DivisionTypeId] [int] NOT NULL,
  CONSTRAINT [PK_Divisions_DivisionUID] PRIMARY KEY CLUSTERED ([DivisionUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_Divisions_Name]
  ON [corp-struct].[Divisions] ([NameFull])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_Divisions_NameShort]
  ON [corp-struct].[Divisions] ([NameShort])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [corp-struct].[tgrDivisions_Delete]
ON [corp-struct].[Divisions]
AFTER DELETE
AS
BEGIN
	DECLARE @msg AS VARCHAR(MAX)
    IF EXISTS(SELECT * FROM DELETED AS d WHERE d.NameFull = 'АО АИКБ "Енисейский объединенный банк"')
    BEGIN 
        SET @msg = 'Запрещено удаление корневого узла "ЕО Банк""';
        THROW 50001, @msg, 1;

        ROLLBACK
    END 

END
GO

ALTER TABLE [corp-struct].[Divisions]
  ADD CONSTRAINT [FK_Divisions_DivisionParentUID] FOREIGN KEY ([DivisionParentUID]) REFERENCES [corp-struct].[Divisions] ([DivisionUID])
GO

ALTER TABLE [corp-struct].[Divisions]
  ADD CONSTRAINT [FK_Divisions_DivisionTypeId] FOREIGN KEY ([DivisionTypeId]) REFERENCES [config].[DivisionsTypes] ([DivisionTypeId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Перечень наименований отделов', 'SCHEMA', N'corp-struct', 'TABLE', N'Divisions'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД отдела', 'SCHEMA', N'corp-struct', 'TABLE', N'Divisions', 'COLUMN', N'DivisionUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименование отдела', 'SCHEMA', N'corp-struct', 'TABLE', N'Divisions', 'COLUMN', N'NameFull'
GO