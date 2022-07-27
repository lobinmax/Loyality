SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 13.07.2021
-- Create time:	10:05
-- Description:	ХП создает документ - начисление бонусов
-- знак документа +/- определяется по таблице [bonus-charge].[BonusDocumentsType]
-- =============================================
CREATE PROCEDURE [bonus-charge].[BonusDocumentCreate] 
    @TrasactionUID UNIQUEIDENTIFIER = NULL,
    @DtTrasaction DATE = NULL,
    @BonusAccountUID UNIQUEIDENTIFIER,
    @AccruedBonuses INT,
    @DocumentTypeId INT,    --0	Начисление бонусов согласно условий
                            --1	Списание бонусов согласно условий
                            --2	Ручное начисление бонусов
                            --3	Ручное списание бонусов
                            --4	Аннулирование: Нет операций по счету
                            --5	Аннулирование: Баллы не востребованы
                            --6	Аннулирование: Закрытие бонусного счета Участника
                            --7	Аннулирование: Сомнительные действия Участника
                            --8	Овердрафтный документ
    @Description VARCHAR(MAX)
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @msg AS VARCHAR(MAX);
    DECLARE @DocumentIsDebet BIT;
    DECLARE @ClientUID AS UNIQUEIDENTIFIER;
    DECLARE @TransactionIsLocal AS BIT = 0;
    SET @DtTrasaction = COALESCE(@DtTrasaction, dt.GetCurrentDate())
    SET @TrasactionUID = COALESCE(@TrasactionUID, NEWID())
    
    IF @@TRANCOUNT = 0
    BEGIN 
        BEGIN TRANSACTION;
        SET @TransactionIsLocal = 1;
    END 

    IF @AccruedBonuses = 0
    BEGIN
        RETURN 0
    END 

    IF NOT EXISTS (SELECT * 
                   FROM [bonus-charge].BonusDocumentsType AS bdt 
                   WHERE bdt.DocumentTypeId = @DocumentTypeId)
    BEGIN 
        SET @msg = 'ХП [bonus-charge].[BonusDocumentCreate]. Не удалось определить тип документа - начисления. Тип - "' + CAST(@DocumentTypeId AS VARCHAR(5)) + '"';
        THROW 50001, @msg, 1;
        
        IF @TransactionIsLocal = 1
        BEGIN 
            ROLLBACK TRANSACTION
        END 
        RETURN 0;
    END 

    SELECT @ClientUID = cbа.ClientUID
    FROM loyalty.ClientBonusАccounts AS cbа 
    WHERE cbа.BonusAccountUID = @BonusAccountUID

    IF @ClientUID IS NULL
    BEGIN 
        SET @msg = 'ХП [bonus-charge].[BonusDocumentCreate]. Не удалось найти бонусный счет. UID счета - "' + CAST(@BonusAccountUID AS VARCHAR(50)) + '"';
        THROW 50001, @msg, 1;
        
        IF @TransactionIsLocal = 1
        BEGIN 
            ROLLBACK TRANSACTION
        END 
        RETURN 0;
    END 

    SELECT @DocumentIsDebet = bdt.IsDebet
    FROM [bonus-charge].BonusDocumentsType AS bdt
    WHERE bdt.DocumentTypeId = bdt.DocumentTypeId
    
    IF @DocumentIsDebet IS NULL
    BEGIN 
        SET @msg = 'ХП [bonus-charge].[BonusDocumentCreate]. Не удалось определить полярность создаваемой проводки. UID счета - "' + CAST(@BonusAccountUID AS VARCHAR(50)) + '"';
        THROW 50001, @msg, 1;
        
        IF @TransactionIsLocal = 1
        BEGIN 
            ROLLBACK TRANSACTION
        END 
        RETURN 0;
    END 

    IF @DocumentIsDebet = 1 AND @AccruedBonuses > 0
    BEGIN
        SET @AccruedBonuses = @AccruedBonuses * -1
    END 

    INSERT INTO [bonus-charge].BonusTransactions
    (
        TransactionUID,
        DtTrasaction,
        ClientUID,
        BonusAccountUID,
        AccruedBonuses,
        DocumentTypeId,
        PeriodNumber,
        Description
    )
    VALUES
    (   
        @TrasactionUID,
        @DtTrasaction,
        @ClientUID,
        @BonusAccountUID,
        @AccruedBonuses,
        @DocumentTypeId,
        YEAR(@DtTrasaction) * 100 + MONTH(@DtTrasaction),
        str.Trim(@Description)
    )

    IF @TransactionIsLocal = 1
    BEGIN 
        COMMIT TRANSACTION
    END 
END
GO