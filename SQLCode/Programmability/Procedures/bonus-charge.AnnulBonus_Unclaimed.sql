SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 20.07.2021
-- Create time:	16:54
-- Description:	ХП аннулирует начисленные баллы
-- если баллы не востребованы
-- =============================================
CREATE PROCEDURE [bonus-charge].[AnnulBonus_Unclaimed]
    @BonusAccountUID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    DECLARE @BonusAccountDtOpen AS DATE = loyalty.BonusАccountGetDtOpen(@BonusAccountUID);
    DECLARE @ExpirationDate INT = CAST(config.ParametersGetValue('Срок жизни бонусных баллов, мес', DEFAULT, DEFAULT) AS INT);
    DECLARE @ReferDate AS DATE = DATEADD(MONTH, -@ExpirationDate, dt.GetCurrentDate());

    IF (@ReferDate <= @BonusAccountDtOpen)
    BEGIN
        RETURN 0;
    END 

    IF EXISTS(SELECT * 
              FROM [bonus-charge].BonusSpent AS bs 
              WHERE bs.BonusAccountUID = @BonusAccountUID 
                AND bs.DtChange BETWEEN @ReferDate AND dt.GetCurrentDate())
    BEGIN 
        RETURN 0;
    END 

    DECLARE @CurrentBonusCount INT = loyalty.BonusGetCountByAcoount(@BonusAccountUID, @ReferDate);
    IF (@CurrentBonusCount > 0)
    BEGIN        
        UPDATE btb
        SET btb.IsCanceled = 1
        FROM [bonus-charge].BonusTransactionsBase AS btb
        INNER JOIN [bonus-charge].BonusTransactions AS bt 
            ON bt.TransactionUID = btb.TransactionUID
        WHERE bt.BonusAccountUID = @BonusAccountUID
            AND bt.DtTrasaction < @ReferDate
        
        DECLARE @Description VARCHAR(MAX) = 'В течение ' + CAST(@ExpirationDate AS VARCHAR(5)) + ' мес. начиная с ' + FORMAT(@ReferDate, 'dd.MM.yyyy') + ' по бонусному счету нет активности.'
        EXEC [bonus-charge].BonusDocumentCreate @BonusAccountUID = @BonusAccountUID,
                                                @AccruedBonuses = @CurrentBonusCount,
                                                @DocumentTypeId = 5,
                                                @Description = @Description


    END 
END
GO