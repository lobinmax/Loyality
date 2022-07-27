SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 26.07.2021
-- Create time:	17:51
-- Description:	Job выполняет синхронизацию данных
-- лояльности с данными Диасофт
-- =============================================
CREATE PROCEDURE [depen-dias].[Syncing_Job]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF CAST(config.ParametersGetValue('Job - Синхронизация данных с АБС', DEFAULT, DEFAULT) AS BIT) = 0
    BEGIN
        RETURN 0
    END

    DECLARE @LogExecutingUID UNIQUEIDENTIFIER = NEWID();
    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID, 
                                @JobName = '[depen-dias].[Syncing_Job]',
                                @DtBegin = DEFAULT,
                                @Description = N'Run → [depen-dias].[Syncing_ClientAccounts]',
                                @Result = 'Задание не выполнено',
                                @Function = 0

    BEGIN TRANSACTION
        EXEC [depen-dias].Syncing_ClientAccounts;            
    COMMIT TRANSACTION

    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID,
                                @DtEnd = DEFAULT,
                                @Result = 'Задание успешно выполнено',
                                @Function = 1

    SET @LogExecutingUID = NEWID();
    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID, 
                                @JobName = '[depen-dias].[Syncing_Job]',
                                @DtBegin = DEFAULT,
                                @Description = N'Run → [depen-dias].[Syncing_PackageServices]',
                                @Result = 'Задание не выполнено',
                                @Function = 0

    BEGIN TRANSACTION
        EXEC [depen-dias].Syncing_PackageServices;            
    COMMIT TRANSACTION

    
    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID,
                                @DtEnd = DEFAULT,
                                @Result = 'Задание успешно выполнено',
                                @Function = 1
END
GO