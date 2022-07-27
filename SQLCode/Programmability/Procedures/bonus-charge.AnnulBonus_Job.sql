SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.07.2021
-- Create time:	12:21
-- Description:	Job аннулирует бонусные баллы
-- согласно условий лояльности
-- Выполняется каждый день в 03-00 (1-ым шагом)
-- =============================================
CREATE PROCEDURE [bonus-charge].[AnnulBonus_Job]  
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF CAST(config.ParametersGetValue('Job - Аннулирование баллов согласно условий (вкл/выкл)', DEFAULT, DEFAULT) AS BIT) = 0
    BEGIN
        RETURN 0
    END   

    DECLARE @LogExecutingUID UNIQUEIDENTIFIER = NEWID();
    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID, 
                                @JobName = '[bonus-charge].[AnnulBonus_Job]',
                                @DtBegin = DEFAULT, 
                                @Result = 'Задание не выполнено',
                                @Function = 0

    DECLARE @BonusAccountUID UNIQUEIDENTIFIER
    DECLARE crsrBonusAccounts CURSOR FAST_FORWARD READ_ONLY LOCAL
    FOR
        SELECT cbа.BonusAccountUID
        FROM loyalty.ClientBonusАccounts AS cbа
        WHERE loyalty.BonusGetCountByAcoount(cbа.BonusAccountUID, DEFAULT) > 0
    
    OPEN crsrBonusAccounts    
    FETCH NEXT FROM crsrBonusAccounts INTO 
        @BonusAccountUID
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRANSACTION
            EXEC [bonus-charge].AnnulBonus_WithoutActivity @BonusAccountUID = @BonusAccountUID;            
        COMMIT TRANSACTION

        BEGIN TRANSACTION
            EXEC [bonus-charge].AnnulBonus_Unclaimed @BonusAccountUID = @BonusAccountUID;            
        COMMIT TRANSACTION
    
        FETCH NEXT FROM crsrBonusAccounts INTO 
            @BonusAccountUID
    END
    
    CLOSE crsrBonusAccounts;
    DEALLOCATE crsrBonusAccounts;

    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID,
                                @DtEnd = DEFAULT,
                                @Result = 'Задание успешно выполнено',
                                @Function = 1
END
GO