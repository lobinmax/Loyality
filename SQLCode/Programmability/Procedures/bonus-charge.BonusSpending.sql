SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.07.2021
-- Create time:	17:35
-- Description:	ХП отмечает куда клиент хочет потратить баллы
-- =============================================
CREATE PROCEDURE [bonus-charge].[BonusSpending] 
    @BonusAccountUID UNIQUEIDENTIFIER,
    @AccountServiceContract XML
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET ANSI_PADDING ON;
        
    BEGIN TRANSACTION 
        DECLARE @msg VARCHAR(MAX); 
        DECLARE @cmd AS NVARCHAR(MAX);
        DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft(); 
        DECLARE @DbOur AS VARCHAR(50) = QUOTENAME(CAST(config.ParametersGetValue('Имя общей базы данных OUR', DEFAULT, DEFAULT) AS VARCHAR(50)));
        DECLARE @DtChange DATETIME2 = dt.GetCurrentDatetime();
        DECLARE @TransactionUID UNIQUEIDENTIFIER = NEWID();
        IF @BonusAccountUID IS NULL
        BEGIN
            SET @msg = 'Не найдено действующих бонусных счетов';
            THROW 50001, @msg, 1;
			IF (@@TRANCOUNT <> 0)
			BEGIN
				ROLLBACK TRANSACTION
			END
			RETURN 0
        END 
        DECLARE @CurrentBalance INT = loyalty.BonusGetCountByAcoount(@BonusAccountUID, DEFAULT);

        CREATE TABLE #tTariff
        (
            Breif VARCHAR(50),
            Amount MONEY,
            Number INT,
            Commment VARCHAR(300),
            Code INT 
        )
        SET @cmd = 
        '
            SELECT ct.Brief, 
                   ct.Summa, 
                   ct.Number, 
                   ct.Comment, 
                   ct.Code 
            FROM ' + @lnk + '.' + @DbOur + '.dbo.com_tTarif AS ct
        ';
        INSERT INTO #tTariff
        (
            Breif,
            Amount,
            Number,
            Commment,
            Code
        )EXEC sys.sp_executesql @stmt = @cmd
                            
        CREATE TABLE #ServiceContracts
        (
            AccountUID UNIQUEIDENTIFIER,
            ServiceContractUID UNIQUEIDENTIFIER,
            AmountFromSite MONEY,
            AmountFromOurBD MONEY,
            ServiceContractName VARCHAR(250),
            IsUsed BIT 
        )
        INSERT INTO #ServiceContracts
        (
            AccountUID,
            ServiceContractUID,
            AmountFromSite, 
            AmountFromOurBD,
            ServiceContractName,
            IsUsed
        )
        SELECT 
            x.t.value('AccountUID[1]', 'UNIQUEIDENTIFIER'),
            x.t.value('ServiceContractUID[1]', 'UNIQUEIDENTIFIER'),
            x.t.value('Amount[1]', 'MONEY') AS AmountFromSite,
            ISNULL(tt.Amount, CAST(0.00 AS MONEY)) AS AmountFromOurBD,
            tsc.Name AS ServiceContractName,
            CASE WHEN bs.AccountUID IS NULL THEN 0 ELSE 1 END AS IsUsed
        FROM @AccountServiceContract.nodes('ServiceContracts') AS x(t)
        INNER JOIN config.TypesServiceContracts AS tsc
            ON tsc.ServiceContractUID = x.t.value('ServiceContractUID[1]', 'UNIQUEIDENTIFIER')
        LEFT JOIN #tTariff AS tt 
            ON tt.Breif = tsc.NameBrief
        LEFT JOIN [bonus-charge].BonusSpent AS bs
            ON bs.AccountUID = x.t.value('AccountUID[1]', 'UNIQUEIDENTIFIER')
            AND bs.ServiceContractUID = tsc.ServiceContractUID
            AND bs.DtBegin = dt.MonthFirstDay(DATEADD(MONTH, 1, @DtChange))
            AND bs.DtEnd = dt.MonthLastDay(DATEADD(MONTH, 1, @DtChange))

        IF EXISTS (SELECT *
                   FROM #ServiceContracts AS sc
                   WHERE sc.IsUsed = 1)
        BEGIN 
            SET @msg = 'Среди выбранных к поощрению комиссий, имеются уже заказанные позиции. Пожалуйста, измените выбор.';
            THROW 50001, @msg, 1;
			IF (@@TRANCOUNT <> 0)
			BEGIN
                SET ANSI_PADDING OFF;
				ROLLBACK TRANSACTION;
			END
			RETURN 0
        END 

        IF EXISTS(SELECT * 
                  FROM #ServiceContracts AS sc
                  WHERE sc.AmountFromSite <> sc.AmountFromOurBD)
        BEGIN 
            SET @msg = 'Текущая стоимость комиссий не совпадает с выбранными. Попробуйте обновить страницу.';
            THROW 50001, @msg, 1;
			IF (@@TRANCOUNT <> 0)
			BEGIN
                SET ANSI_PADDING OFF;
				ROLLBACK TRANSACTION;
			END
			RETURN 0
        END 
        
        DECLARE @AmountRewards AS MONEY = (SELECT SUM(sc.AmountFromOurBD) FROM #ServiceContracts AS sc)
        IF (@CurrentBalance < @AmountRewards)
        BEGIN
            SET @msg = 'Для заказа выбранных поощрений, у Вас недостаточно бонусных баллов!';
            THROW 50001, @msg, 1;
			IF (@@TRANCOUNT <> 0)
			BEGIN
                SET ANSI_PADDING OFF;
				ROLLBACK TRANSACTION;
			END
			RETURN 0
        END 
        
        DECLARE @DtBegin AS DATE 
        DECLARE @DtEnd AS DATE 
        DECLARE @MonthDiff INT = 1
        --IF (DATEDIFF(DAY, @DtChange, dt.MonthLastDay(dt.GetCurrentDate()))) < 3
        --BEGIN
        --    SET @MonthDiff = 2;
        --END 
        SET @DtBegin = dt.MonthFirstDay(DATEADD(MONTH, @MonthDiff, @DtChange));
        SET @DtEnd = dt.MonthLastDay(DATEADD(MONTH, @MonthDiff, @DtChange));         
       
        DECLARE @Description VARCHAR(MAX) = 'Заказ поощерений на период с ' + FORMAT(@DtBegin, 'dd.MM.yyyy') + ' по ' + FORMAT(@DtEnd,'dd.MM.yyyy');
        EXEC [bonus-charge].BonusDocumentCreate @TrasactionUID = @TransactionUID,
                                                @DtTrasaction = @DtChange,
                                                @BonusAccountUID = @BonusAccountUID,
                                                @AccruedBonuses = @AmountRewards,
                                                @DocumentTypeId = 1,    -- Списание бонусов согласно условий
                                                @Description = @Description;

        INSERT INTO [bonus-charge].BonusSpent
        (
            BonusAccountUID,
            TransactionUID,
            ServiceContractUID,
            DtChange,
            AccountUID,
            DtBegin,
            DtEnd,
            AmountFromSite, 
            AmountFromOurBD
        )
        SELECT 
            @BonusAccountUID, 
            @TransactionUID, 
            sc.ServiceContractUID, 
            @DtChange, 
            sc.AccountUID, 
            @DtBegin, 
            @DtEnd, 
            sc.AmountFromSite,
            sc.AmountFromOurBD
        FROM #ServiceContracts AS sc
        
        INSERT [bonus-charge].BonusPrimaryDocs
        (
            TransactionUID,
            TransactionExternalID,
            ClientUID,
            BonusAccountUID,
            AccountIdExternal,
            DtPrimaryDoc,
            AmountPrimaryDoc,
            Description
        )
        SELECT 
            @TransactionUID, 
            -199999, 
            cust.GetClientUIDByBonusAccountUID(@BonusAccountUID), 
            @BonusAccountUID, 
            cust.GetAccountIdByAccountUID(sc.AccountUID), 
            @DtChange, 
            sc.AmountFromOurBD * -1,
            'Оплата комиссии "' + sc.ServiceContractName + '" по счету №' + cust.GetAccountNumberByIdExternal(cust.GetAccountIdByAccountUID(sc.AccountUID)) + ', в период с ' + FORMAT(@DtBegin, 'dd.MM.yyyy') + ' по ' + FORMAT(@DtEnd,'dd.MM.yyyy') + ' бонусными баллами'
        FROM #ServiceContracts AS sc
    
    COMMIT TRANSACTION
    
    SET ANSI_PADDING OFF;
    DROP TABLE #ServiceContracts
    DROP TABLE #tTariff
END
GO