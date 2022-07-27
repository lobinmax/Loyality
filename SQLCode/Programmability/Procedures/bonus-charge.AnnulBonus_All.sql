SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 20.07.2021
-- Create time:	14:39
-- Description:	ХП аннулирует все баллы на счете
-- =============================================
CREATE PROCEDURE [bonus-charge].[AnnulBonus_All]
    @BonusAccountUID UNIQUEIDENTIFIER,
    @DocumentTypeId INT,
    @Description VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @msg AS VARCHAR(MAX);
    DECLARE @TransactionIsLocal AS BIT = 0;

    IF @@TRANCOUNT = 0
    BEGIN 
        BEGIN TRANSACTION;
        SET @TransactionIsLocal = 1;
    END 

    DECLARE @DocumentIsDebet BIT;
    DECLARE @DocumentName VARCHAR(150);
    SELECT 
        @DocumentIsDebet = bdt.IsDebet,
        @DocumentName = bdt.Name
    FROM [bonus-charge].BonusDocumentsType AS bdt
    WHERE bdt.DocumentTypeId = @DocumentTypeId

    IF @DocumentIsDebet = 0
    BEGIN 
        SET @msg = 'ХП [bonus-charge].[AnnulBonus_All]. Предпринята попытка аннулирования бонусных баллов, кредитовым документом. Тип документа - "' + @DocumentName + '"';
        THROW 50001, @msg, 1;

        IF @TransactionIsLocal = 1
        BEGIN 
            ROLLBACK TRANSACTION
        END 
        RETURN 0;
    END 

    DECLARE @CurrentBonusCount INT = loyalty.BonusGetCountByAcoount(@BonusAccountUID, DEFAULT);
    IF (@CurrentBonusCount > 0)
    BEGIN
        UPDATE btb
        SET btb.IsCanceled = 1
        FROM [bonus-charge].BonusTransactionsBase AS btb
        INNER JOIN [bonus-charge].BonusTransactions AS bt 
            ON bt.TransactionUID = btb.TransactionUID
        WHERE bt.BonusAccountUID = @BonusAccountUID
        
        EXEC [bonus-charge].BonusDocumentCreate @BonusAccountUID = @BonusAccountUID,
                                                @AccruedBonuses = @CurrentBonusCount,
                                                @DocumentTypeId = @DocumentTypeId,
                                                @Description = @Description
    END 

    IF @TransactionIsLocal = 1
    BEGIN 
        COMMIT TRANSACTION
    END 

END
GO