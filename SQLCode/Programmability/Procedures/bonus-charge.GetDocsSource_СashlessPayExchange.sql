SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.05.2021
-- Create time:	12:55
-- Description:	ХП получает данные из диасофта для расчета бонусов
-- БЕЗНАЛИЧНЫЕ ПЕРЕВОДЫ СРЕДСТВ СО СЧЕТА КЛИЕНТА
-- КОНВЕРТАЦИЯ
-- =============================================
CREATE PROCEDURE [bonus-charge].[GetDocsSource_СashlessPayExchange]
	@DtStart DATE,
	@DtEnd DATE, 
	@OperationHandlerUID UNIQUEIDENTIFIER,
	@Function INT = 0	-- 0 - БЕЗНАЛИЧНЫЕ ПЕРЕВОДЫ СРЕДСТВ СО СЧЕТА КЛИЕНТА
						-- 1 - КОНВЕРТАЦИЯ
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @BonusOperationUID UNIQUEIDENTIFIER
	DECLARE @BonusOperationName VARCHAR(300)

	SELECT 
		@BonusOperationUID = boh.OperationUID,
		@BonusOperationName = bob.Name
	FROM loyalty.BonusOperationsHandlers AS boh
	INNER JOIN loyalty.BonusOperationsBook AS bob
		ON bob.OperationUID = boh.OperationUID
	WHERE boh.OperationHandlerUID = @OperationHandlerUID
		
	DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
	DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
	DECLARE @cmd AS NVARCHAR(MAX) = 
	    @lnk + '.' + @DbName + '.[dbo].[_avs_GetLoyaltyInfo] 
		@D1 = ''' + CAST(@DtStart AS VARCHAR(15)) + ''', 
		@D2 = ''' + CAST(@DtEnd AS VARCHAR(15)) + ''', 
		@Function = ' + CAST(@Function AS VARCHAR(2));

	CREATE TABLE #DocsSource
	(
		Date DATE,
		ClientID NUMERIC(15),
		AccountID NUMERIC(15),
		DealTransactID NUMERIC(15),
		Amount MONEY,
		BonusAmount INT,
		BonusAmountTotal INT,
		BonusAmountNow INT,
		Comment VARCHAR(MAX)
	)
	INSERT INTO #DocsSource
	(
	    Date,
	    ClientID,
	    AccountID,
	    DealTransactID,
	    Amount, 
	    Comment
	)
	EXEC sys.sp_executesql @stmt = @cmd

	DELETE ds
	FROM #DocsSource AS ds
	WHERE NOT EXISTS
		(
			SELECT * 
			FROM #BonusAccounts AS ba
			WHERE ba.AccountIdExternal = ds.AccountID
		)
	
	EXEC [bonus-charge].DataSoursePrepaire @OperationHandlerUID = @OperationHandlerUID,
	                                       @DtSource = @DtStart	

	INSERT INTO #NewTransactions
	( 
		TransactionUID,
	    DtTrasaction,
	    ClientUID,
	    BonusAccountUID,
	    AccruedBonuses,
	    DocumentTypeId,
	    Description
	)
	SELECT
		NEWID(),
		ds.Date,
		ba.ClientUID, 
		ba.BonusAccountUID, 
		ds.BonusAmountTotal AS BonusAmount,
		0, -- Тип документа: "Начисление бонусов согласно условий"
		'Бонусы за операции типа "' + @BonusOperationName + '"'
	FROM #BonusAccounts AS ba
	INNER JOIN #DocsSource AS ds
		ON ba.AccountIdExternal = ds.AccountID
	GROUP BY ds.Date, ba.ClientUID, ba.BonusAccountUID, ds.BonusAmountTotal
	
	INSERT INTO [bonus-charge].BonusTransactions
	(
	    TransactionUID,
	    DtTrasaction,
	    ClientUID,
	    BonusAccountUID,
	    AccruedBonuses,
	    DocumentTypeId, 
	    Description
	)
	SELECT 
		nt.TransactionUID, 
		nt.DtTrasaction, 
		nt.ClientUID, 
		nt.BonusAccountUID, 
		nt.AccruedBonuses, 
		nt.DocumentTypeId, 
		nt.Description
	FROM #NewTransactions AS nt

	INSERT INTO [bonus-charge].BonusTransactionsBase
	(
	    TransactionUID,
	    OperationUID,
	    OperationHandlerUID
	)
	SELECT 
		nt.TransactionUID, 
		@BonusOperationUID,
		@OperationHandlerUID
	FROM #NewTransactions AS nt

	INSERT INTO [bonus-charge].BonusPrimaryDocs
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
		nt.TransactionUID,
        ds.DealTransactID, 
		c.ClientUID, 
		nt.BonusAccountUID, 
		ds.AccountID,
        ds.Date,
		ds.Amount,
		ds.Comment
	FROM #DocsSource AS ds
	INNER JOIN cust.Clients AS c
		ON ds.ClientID = c.ClientIdExternal
	INNER JOIN #NewTransactions AS nt
		ON nt.ClientUID = c.ClientUID

	DROP TABLE #DocsSource
END
GO