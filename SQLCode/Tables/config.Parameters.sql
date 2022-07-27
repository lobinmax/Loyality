CREATE TABLE [config].[Parameters] (
  [ParameterUID] [uniqueidentifier] NOT NULL DEFAULT (newid()),
  [ParameterTypeId] [int] NOT NULL,
  [Name] [varchar](300) NOT NULL,
  [ParameterValueType] [varchar](50) NOT NULL,
  [Description] [varchar](300) NULL,
  [DtCreate] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_Parameters_ParameterUID] PRIMARY KEY CLUSTERED ([ParameterUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_Parameters]
  ON [config].[Parameters] ([ParameterTypeId], [Name])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrParameters_Delete]
ON [config].[Parameters]
AFTER DELETE
AS
BEGIN	
    DECLARE @msg AS VARCHAR(MAX)

    IF EXISTS(SELECT * FROM DELETED AS d
              INNER JOIN config.ParametrsValueType pvt 
                  ON d.ParameterValueType = pvt.ValueType
              WHERE pvt.ValueType = 'Защищенные настройки')
    BEGIN
        SET @msg = 'Предпринята попытка удалить параметр с типом "Защищенные настройки". Это может нарушить работу системы';
        THROW 50001, @msg, 1;
        
        ROLLBACK;
    END 
END
GO

ALTER TABLE [config].[Parameters]
  ADD CONSTRAINT [FK_Parameters_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [config].[Parameters]
  ADD CONSTRAINT [FK_Parameters_ParameterTypeId] FOREIGN KEY ([ParameterTypeId]) REFERENCES [config].[ParametersType] ([ParameterTypeId])
GO

ALTER TABLE [config].[Parameters]
  ADD CONSTRAINT [FK_Parameters_ParameterValueType] FOREIGN KEY ([ParameterValueType]) REFERENCES [config].[ParametrsValueType] ([ValueType])
GO

ALTER TABLE [config].[Parameters]
  ADD CONSTRAINT [FK_Parameters_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименования параметров для работы приложения', 'SCHEMA', N'config', 'TABLE', N'Parameters'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД группы праметров', 'SCHEMA', N'config', 'TABLE', N'Parameters', 'COLUMN', N'ParameterTypeId'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименование параметра', 'SCHEMA', N'config', 'TABLE', N'Parameters', 'COLUMN', N'Name'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Тип значения параметра (строка, число и т.п.)', 'SCHEMA', N'config', 'TABLE', N'Parameters', 'COLUMN', N'ParameterValueType'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Комментарий', 'SCHEMA', N'config', 'TABLE', N'Parameters', 'COLUMN', N'Description'
GO