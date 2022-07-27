CREATE TABLE [config].[ParametrsValueType] (
  [ValueType] [varchar](50) NOT NULL,
  CONSTRAINT [PK_ParametrsValueType_ValueType] PRIMARY KEY CLUSTERED ([ValueType])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ParametrsValueType_ValueType]
  ON [config].[ParametrsValueType] ([ValueType])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrParametrsValueType_Delete]
ON [config].[ParametrsValueType]
AFTER DELETE
AS
BEGIN
	
    DECLARE @msg AS VARCHAR(MAX)
    SET @msg = 'Удаление записей из этой таблицы ([config].[ParametrsValueType]), может нарушить работу приложения!';
    THROW 50001, @msg, 1;
    
    ROLLBACK;
END
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Допустимые типы значений параметров', 'SCHEMA', N'config', 'TABLE', N'ParametrsValueType'
GO