SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 28.06.2021
-- Create time:	15:32
-- Description:	Процедура подготавливает источник данных
-- удаляя лишнее
-- =============================================
CREATE PROCEDURE [bonus-charge].[DataSoursePrepaire] 
	@OperationHandlerUID UNIQUEIDENTIFIER,
	@DtSource DATE
AS
BEGIN
	SET XACT_ABORT ON;
    SET NOCOUNT ON;

	DECLARE @BonusOperationUID UNIQUEIDENTIFIER
	DECLARE @MethodChargeId INT 
	DECLARE @BonusPointCount MONEY 
	DECLARE @PointsCountMax INT 
	DECLARE @PointsCountMin INT
	DECLARE @ОnlyFirstOneForClient AS BIT 
	DECLARE @ОnlyFirstOneForAccount AS BIT 

	SELECT 
		@BonusOperationUID = boh.OperationUID,
		@MethodChargeId = boh.MethodChargeId,
        @BonusPointCount = boh.PointsCount,
		@PointsCountMax = boh.PointsCountMax,
		@PointsCountMin = boh.PointsCountMin, 
		@ОnlyFirstOneForClient = boh.ОnlyFirstOneForClient,
		@ОnlyFirstOneForAccount = boh.ОnlyFirstOneForAccount
	FROM loyalty.BonusOperationsHandlers AS boh
	INNER JOIN loyalty.BonusOperationsBook AS bob
		ON bob.OperationUID = boh.OperationUID
	WHERE boh.OperationHandlerUID = @OperationHandlerUID

    UPDATE ds
    SET BonusAmount = CASE @MethodChargeId
    		WHEN 0 THEN CAST(ROUND(ds.Amount * @BonusPointCount, 0, 1) AS INT)	-- Процент от бонусной операции
    		WHEN 1 THEN CAST(@BonusPointCount AS INT)							-- За каждую бонусную операцию
    		WHEN 2 THEN 1 ELSE 0 END,											-- За факт свершения бонусной операции
        ds.BonusAmountNow = loyalty.BonusGetCountByOperation(ba.BonusAccountUID, @BonusOperationUID, @DtSource)
    FROM #DocsSource AS ds
    INNER JOIN #BonusAccounts AS ba
        ON ba.AccountIdExternal = ds.AccountID
    
	UPDATE ds
	SET BonusAmountTotal =
		(
			SELECT SUM(BonusAmount)
			FROM #DocsSource AS d
			WHERE d.ClientID = ds.ClientID
		)
	FROM #DocsSource AS ds;

    UPDATE #DocsSource
    SET BonusAmountTotal = CASE
        WHEN BonusAmountNow >= @PointsCountMax THEN 0
        WHEN BonusAmountNow + BonusAmountTotal >= @PointsCountMax THEN (@PointsCountMax - BonusAmountNow)
        WHEN BonusAmountTotal < @PointsCountMin THEN 0
        ELSE BonusAmountTotal END 
    FROM #DocsSource AS ds
    
    DELETE FROM #DocsSource
    WHERE BonusAmount = 0
    
	IF (@ОnlyFirstOneForClient = 1)
	BEGIN
		DELETE ds 
		FROM #DocsSource AS ds
		WHERE EXISTS 
			(
				SELECT * 
				FROM [bonus-charge].BonusTransactionsBase AS btb
				INNER JOIN [bonus-charge].BonusTransactions AS bt
					ON bt.TransactionUID = btb.TransactionUID
				WHERE bt.ClientUID = cust.GetClientUIDByClientId(ds.ClientID)
			)		
	END 

	IF (@ОnlyFirstOneForAccount = 1)
	BEGIN
		DELETE ds 
		FROM #DocsSource AS ds
		WHERE EXISTS 
			(
				SELECT * 
				FROM [bonus-charge].BonusPrimaryDocs AS bpd
				WHERE ds.AccountID = bpd.AccountIdExternal
			)			
	END 
END
GO