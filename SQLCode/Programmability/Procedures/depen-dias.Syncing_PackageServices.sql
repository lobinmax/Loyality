SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 22.07.2021
-- Create time:	11:30
-- Description:	ХП синхронизирует набор пакетов и комисий
-- с базой Диасофт. 
-- =============================================
CREATE PROCEDURE [depen-dias].[Syncing_PackageServices]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @MailProfileName AS VARCHAR(50) = CAST(config.ParametersGetValue('Имя профиля компонента Database Mail', DEFAULT, DEFAULT) AS VARCHAR(50));
    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @cmd AS NVARCHAR(MAX) = 
    '
        SELECT irt.InstRelTypeID,
               irt.Name,
               irt.Brief,
               irt.ParentName,
               irt.ParentProperty,
               irt.ChildName,
               irt.ChildProperty,
               irt.DocName,
               irt.DocAttr1,
               irt.DocAttr2,
               irt.DocAttr3,
               irt.DocAttr4,
               irt.DocAttr5,
               irt.DocAttr6,
               irt.SystemFlag,
               irt.SystemNumber,
               irt.DepartmentID,
               irt.Comment
        FROM ' + @lnk + '.' + @DbName + '.dbo.tInstRelType AS irt;
    '
    SELECT * 
    INTO #DS_tInstRelType
    FROM [depen-dias].tInstRelType AS tirt
    WHERE tirt.InstRelTypeID IS NULL

    INSERT INTO #DS_tInstRelType
    (
        InstRelTypeID,
        Name,
        Brief,
        ParentName,
        ParentProperty,
        ChildName,
        ChildProperty,
        DocName,
        DocAttr1,
        DocAttr2,
        DocAttr3,
        DocAttr4,
        DocAttr5,
        DocAttr6,
        SystemFlag,
        SystemNumber,
        DepartmentID,
        Comment
    ) EXEC sys.sp_executesql @stmt = @cmd

    EXECUTE AS LOGIN = 'lobin';
        DECLARE @CountColumnLoyal INT = 
        (
            SELECT COUNT(*) 
            FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = 'depen-dias'
                AND TABLE_NAME = 'tInstRelType'
        );
    REVERT;

    DECLARE @CountColumnDias NVARCHAR(10); 
    DECLARE @ParmDefinition NVARCHAR(500) = '@CountColumnOUT NVARCHAR(25) OUTPUT';
    SET @cmd = 
    '
        SELECT @CountColumnOUT = COUNT(*)
        FROM ' + @lnk + '.' + @DbName + '.INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_CATALOG = ''' + str.QuoteReplace(@DbName) + '''
            AND TABLE_SCHEMA = ''dbo''
            AND TABLE_NAME = ''tInstRelType''   
    '
    EXEC sys.sp_executesql @stmt = @cmd,
                           @param1 = @ParmDefinition,
                           @CountColumnOUT = @CountColumnDias OUTPUT;
    
    IF ISNULL(@CountColumnLoyal, 0) <> ISNULL(@CountColumnDias, 0)
    BEGIN 
        DECLARE @msg AS VARCHAR(MAX) = 
            'В таблице Диасофта "tInstRelType" изменилось кол-во столбцов. Было ' + CAST(@CountColumnLoyal AS VARCHAR(5)) + ', стало ' + CAST(@CountColumnDias AS VARCHAR(5)) + '.'
        EXEC msdb.dbo.sp_send_dbmail  
            @profile_name = @MailProfileName,  
            @recipients = 'lobin.ma@united.ru',  
            @body = @msg ,  
            @subject = 'Job. ХП [depen-dias].[Syncing_PackageServices]';
    END 

    DELETE dtirt 
    FROM #DS_tInstRelType AS dtirt
    WHERE EXISTS 
    (
        SELECT * 
        FROM [depen-dias].tInstRelType AS tirt
        WHERE tirt.InstRelTypeID = dtirt.InstRelTypeID
    )

    INSERT INTO [depen-dias].tInstRelType
    (
        InstRelTypeID,
        Name,
        Brief,
        ParentName,
        ParentProperty,
        ChildName,
        ChildProperty,
        DocName,
        DocAttr1,
        DocAttr2,
        DocAttr3,
        DocAttr4,
        DocAttr5,
        DocAttr6,
        SystemFlag,
        SystemNumber,
        DepartmentID,
        Comment
    )
    SELECT dtirt.InstRelTypeID,
           dtirt.Name,
           dtirt.Brief,
           dtirt.ParentName,
           dtirt.ParentProperty,
           dtirt.ChildName,
           dtirt.ChildProperty,
           dtirt.DocName,
           dtirt.DocAttr1,
           dtirt.DocAttr2,
           dtirt.DocAttr3,
           dtirt.DocAttr4,
           dtirt.DocAttr5,
           dtirt.DocAttr6,
           dtirt.SystemFlag,
           dtirt.SystemNumber,
           dtirt.DepartmentID,
           dtirt.Comment 
    FROM #DS_tInstRelType AS dtirt

END
GO