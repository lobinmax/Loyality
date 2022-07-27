CREATE TABLE [config].[DivisionsTypes] (
  [DivisionTypeId] [int] NOT NULL,
  [DivisionParentTypeId] [int] NULL,
  [NameFull] [varchar](150) NOT NULL,
  [NameShort] [varchar](100) NOT NULL,
  [PermissionsLevel] [int] NOT NULL,
  [Description] [varchar](max) NULL,
  CONSTRAINT [PK_DivisionsType_DivisionTypeId] PRIMARY KEY CLUSTERED ([DivisionTypeId])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_DivisionsType_NameFull]
  ON [config].[DivisionsTypes] ([NameFull])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_DivisionsType_NameShort]
  ON [config].[DivisionsTypes] ([NameShort])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrDivisionsTypes_Delete]
ON [config].[DivisionsTypes]
AFTER DELETE
AS
BEGIN
	DECLARE @msg AS VARCHAR(MAX)
    IF EXISTS(SELECT * FROM DELETED AS d WHERE d.DivisionTypeId = 0)
    BEGIN 
        SET @msg = 'Запрещено удаление корневого узла "Банк"';
        THROW 50001, @msg, 1;

        ROLLBACK
    END 

END
GO

ALTER TABLE [config].[DivisionsTypes]
  ADD CONSTRAINT [FK_DivisionsTypes_DivisionParentTypeId] FOREIGN KEY ([DivisionParentTypeId]) REFERENCES [config].[DivisionsTypes] ([DivisionTypeId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Типы структурных подразделений иерархически', 'SCHEMA', N'config', 'TABLE', N'DivisionsTypes'
GO