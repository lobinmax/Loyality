CREATE TABLE [config].[ParametersType] (
  [ParameterTypeId] [int] NOT NULL,
  [Name] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ParametersType] PRIMARY KEY CLUSTERED ([ParameterTypeId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [IDX_ParametersType_ParameterType]
  ON [config].[ParametersType] ([ParameterTypeId])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ParametersType_Name]
  ON [config].[ParametersType] ([Name])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrParametersType_Delete]
ON [config].[ParametersType]
AFTER DELETE
AS
BEGIN
	DECLARE @msg AS VARCHAR(MAX)
    SET @msg = 'Удаление записей из этой таблицы ([config].[ParametersType]), может нарушить работу приложения!';
    THROW 50001, @msg, 1;
    
    ROLLBACK;
END
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Группы параметров', 'SCHEMA', N'config', 'TABLE', N'ParametersType'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД группы', 'SCHEMA', N'config', 'TABLE', N'ParametersType', 'COLUMN', N'ParameterTypeId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименование группы', 'SCHEMA', N'config', 'TABLE', N'ParametersType', 'COLUMN', N'Name'
GO