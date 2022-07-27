SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 20.07.2021
-- Create time:	14:26
-- Description:	ХП аннулирует начисленные баллы
-- если нет активности по банковским счетам клиента
-- =============================================
CREATE PROCEDURE [bonus-charge].[AnnulBonus_WithoutActivity]
    @BonusAccountUID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PeriodWithoutOper AS INT = CAST(config.ParametersGetValue('Срок жизни бонусных баллов без опериций по счетам, мес', DEFAULT, DEFAULT) AS INT);
    DECLARE @BonusAccountDtOpen AS DATE = loyalty.BonusАccountGetDtOpen(@BonusAccountUID);
    DECLARE @ReferDate AS DATE = DATEADD(MONTH, @PeriodWithoutOper, @BonusAccountDtOpen);

    IF (@ReferDate > dt.GetCurrentDate())
    BEGIN
        RETURN 0;
    END 

    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @ClientId AS NUMERIC(15) = cust.GetClientIdByBonusAccountUID(@BonusAccountUID);
    DECLARE @cmd AS NVARCHAR(MAX) = 
        @lnk + '.' + @DbName + '.[dbo].[_avs_GetLoyaltyLastOperDateByClientID] @ID = ' + CAST(@ClientId AS VARCHAR(50))
    
    CREATE TABLE #LastOperDate
    (
        ResourceID NUMERIC(15), 
        LastOperDate DATE, 
        AccBrief VARCHAR(50), 
        CorAccBrief VARCHAR(50)
    )
    INSERT INTO #LastOperDate
    (
        ResourceID,
        LastOperDate,
        AccBrief,
        CorAccBrief
    )EXEC sys.sp_executesql @stmt = @cmd

    IF NOT EXISTS (SELECT * 
                   FROM #LastOperDate AS lod 
                   WHERE lod.LastOperDate BETWEEN @BonusAccountDtOpen AND @ReferDate) 
    BEGIN
        DECLARE @Description VARCHAR(MAX) = 'В течение ' + CAST(@PeriodWithoutOper AS VARCHAR(5)) + ' мес., начиная с ' + FORMAT(@BonusAccountDtOpen, 'dd.MM.yyyy') + ' нет активности по банковским счетам.'

        EXEC [bonus-charge].AnnulBonus_All @BonusAccountUID = @BonusAccountUID,
                                           @DocumentTypeId = 4,     -- Аннулирование: Нет операций по счету
                                           @Description = @Description
    END 

    DROP TABLE #LastOperDate
END
GO