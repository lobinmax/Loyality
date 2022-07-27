CREATE TABLE [config].[ParametersValue] (
  [ParameterValueUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Parameter__Param__5224328E] DEFAULT (newid()),
  [ParameterUID] [uniqueidentifier] NOT NULL,
  [DtBegin] [date] NOT NULL CONSTRAINT [DF__Parameter__DtBeg__7720AD13] DEFAULT ([dt].[GetCurrentDate_DF]()),
  [СriteriaDivisionUID] [uniqueidentifier] NULL,
  [СriteriaUserUID] [uniqueidentifier] NULL,
  [СriteriaValue] [sql_variant] NULL,
  [ParameterValue] [sql_variant] NOT NULL,
  [Description] [varchar](300) NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__Parameter__DtCre__0880433F] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__Parameter__DtUpd__09746778] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Parameter__Creat__5CA1C101] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Parameter__Updat__5D95E53A] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_ParametersValue_ParameterValueUID] PRIMARY KEY CLUSTERED ([ParameterValueUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_ParametersValue]
  ON [config].[ParametersValue] ([ParameterUID], [DtBegin], [СriteriaDivisionUID], [СriteriaUserUID])
  ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrParametersValue_InsertUpdate]
ON [config].[ParametersValue]
AFTER INSERT, UPDATE
AS
IF (UPDATE(СriteriaDivisionUID) OR UPDATE(СriteriaUserUID))
BEGIN
    
    DECLARE @msg AS VARCHAR(MAX)
    IF EXISTS(SELECT * 
              FROM INSERTED AS ins 
              WHERE (ins.СriteriaDivisionUID IS NOT NULL AND ins.СriteriaUserUID IS NOT NULL) 
                    OR (ins.СriteriaDivisionUID IS NULL AND ins.СriteriaUserUID IS NULL))
    BEGIN 
        
        SET @msg = 'Критерий действия параметра должен быть указан и только один';
        THROW 50001, @msg, 1;
        
        COMMIT ROLLBACK;
    END 
END
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [config].[tgrParametersValue_Delete]
ON [config].[ParametersValue]
AFTER DELETE
AS
BEGIN	
    DECLARE @msg AS VARCHAR(MAX)

    IF EXISTS(SELECT * FROM DELETED AS d
              INNER JOIN config.Parameters p
                  ON d.ParameterUID = p.ParameterUID
              INNER JOIN config.ParametrsValueType pvt 
                  ON p.ParameterValueType = pvt.ValueType
              WHERE pvt.ValueType = 'Защищенные настройки')
    BEGIN
        SET @msg = 'Предпринята попытка удалить значение параметра с типом "Защищенные настройки". Это может нарушить работу системы';
        THROW 50001, @msg, 1;
        
        ROLLBACK;
    END 
END
GO

ALTER TABLE [config].[ParametersValue]
  ADD CONSTRAINT [FK_ParametersValue_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [config].[ParametersValue]
  ADD CONSTRAINT [FK_ParametersValue_ParameterUID] FOREIGN KEY ([ParameterUID]) REFERENCES [config].[Parameters] ([ParameterUID])
GO

ALTER TABLE [config].[ParametersValue]
  ADD CONSTRAINT [FK_ParametersValue_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [config].[ParametersValue]
  ADD CONSTRAINT [FK_ParametersValue_СriteriaDivisionUID] FOREIGN KEY ([СriteriaDivisionUID]) REFERENCES [corp-struct].[Divisions] ([DivisionUID])
GO

ALTER TABLE [config].[ParametersValue]
  ADD CONSTRAINT [FK_ParametersValue_СriteriaUserUID] FOREIGN KEY ([СriteriaUserUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Значения параметров', 'SCHEMA', N'config', 'TABLE', N'ParametersValue'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Дата начала действия параметра', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'DtBegin'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД отдела на каторый действует параметр', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'СriteriaDivisionUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ИД пользователя на которого действует параметр', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'СriteriaUserUID'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'ХЗ зачем мне это поле, но может потом вспомню :)', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'СriteriaValue'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Значение параметра', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'ParameterValue'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Комментрапий', 'SCHEMA', N'config', 'TABLE', N'ParametersValue', 'COLUMN', N'Description'
GO