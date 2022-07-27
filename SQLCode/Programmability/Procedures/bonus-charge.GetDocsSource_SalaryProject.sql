SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 29.06.2021
-- Create time:	15:46
-- Description:	ХП получает данные из РБС для расчета бонусов
-- ЗАКЛЮЧЕНИЕ ЗАРПЛАТНОГО ПРОЕКТА С ВЫПУСКОМ КАРТ
-- =============================================
CREATE PROCEDURE [bonus-charge].[GetDocsSource_SalaryProject]
	@DtStart DATE, 
	@DtEnd DATE, 
	@OperationHandlerUID UNIQUEIDENTIFIER
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

	DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkRBS();
	DECLARE @cmd AS NVARCHAR(MAX) = 
	'EXECUTE
	 (
	 	''BEGIN 
	 		GC.PAV_CALC_PARAM2_LOYAL(
                ''''' + FORMAT(@DtStart, 'dd/MM/yyyy') + ''''', 
                ''''' + FORMAT(@DtEnd, 'dd/MM/yyyy') + '''''); 
	 	  END;''
	 ) AT ' + @lnk  + '
	 EXECUTE
	 (
	 	''SELECT * 
	 	  FROM GC.PAV_LOYAL_REZ_2''
	 ) AT ' + @lnk

	CREATE TABLE #DocsSource
	(
        RecordUID UNIQUEIDENTIFIER,
		Date DATE,
		ClientID NUMERIC(15),
		AccountID NUMERIC(15),
		DocumentId NUMERIC(15),
		Amount MONEY,
		BonusAmount INT,
		BonusAmountTotal INT,
		BonusAmountNow INT,
		Comment VARCHAR(MAX),
		INN VARCHAR(25),
		AccountNumber VARCHAR(50)
	)

	CREATE TABLE #DataFromRBS
	(
		DtSalaryContract DATE,
		[FileName] VARCHAR(300),
		DtFile DATE,
		PAN VARCHAR(50),
		INN VARCHAR(50),
		AccountNumber VARCHAR(50),
		DtCalc DATE,
		Comment VARCHAR(MAX)
	)

	INSERT INTO #DataFromRBS
	EXEC sys.sp_executesql @stmt = @cmd;

	INSERT INTO #DocsSource
	(
        RecordUID,
	    Date, 
	    DocumentId,
	    Amount,
	    Comment,
	    INN,
		AccountNumber
	)
	SELECT 
        NEWID(),
		dfr.DtSalaryContract,
		-199999,
		CAST(1 AS MONEY),
		dfr.Comment,
		dfr.INN,
        dfr.AccountNumber
	FROM #DataFromRBS AS dfr;

	DECLARE @RecordUID UNIQUEIDENTIFIER
	DECLARE @INN VARCHAR(25)
	DECLARE @AccountNumber VARCHAR(50)
	DECLARE @ClientId NUMERIC(15)
	DECLARE @AccountId NUMERIC(15, 0)
	DECLARE crsrFromDiasoft CURSOR FAST_FORWARD LOCAL 
	FOR
		SELECT 
			ds.RecordUID,
			ds.INN,
			ds.AccountNumber
		FROM #DocsSource AS ds;
	
	OPEN crsrFromDiasoft
	FETCH NEXT FROM crsrFromDiasoft INTO 
		@RecordUID,
		@INN,
		@AccountNumber
	
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		EXEC [depen-dias].GetClientIdByAccountNumber @AccountNumber = @AccountNumber,
	                                             @ClientId = @ClientId OUTPUT
		
		EXEC [depen-dias].GetAccountIdByAccountNumber @AccountNumber = @AccountNumber,
		                                              @AccountId = @AccountId OUTPUT
		

		UPDATE ds
		SET ds.ClientID = @ClientId,
			ds.AccountID = @AccountId
		FROM #DocsSource AS ds
		WHERE RecordUID = @RecordUID
			   		
		FETCH NEXT FROM crsrFromDiasoft INTO 
			@RecordUID,
			@INN,
			@AccountNumber
	END
	
	CLOSE crsrFromDiasoft
	DEALLOCATE crsrFromDiasoft
	
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
        ds.DocumentId, 
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
	DROP TABLE #DataFromRBS
END
GO