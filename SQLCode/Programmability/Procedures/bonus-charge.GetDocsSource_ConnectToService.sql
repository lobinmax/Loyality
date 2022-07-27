SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-22
-- Create time:	15:17:58
-- Description:	ХП получает данные из диасофта для расчета бонусов
-- ПОДКЛЮЧЕНИЕ КЛИЕНТА К ПАКЕТУ УСЛУГ
-- ПОДКЛЮЧЕНИЕ СИСТЕМЫ ДБО
-- =============================================
CREATE PROCEDURE [bonus-charge].[GetDocsSource_ConnectToService]
	@DtStart DATE,
	@DtEnd DATE, 
	@OperationHandlerUID UNIQUEIDENTIFIER,
	@PackageServiceOperationName VARCHAR(500)   -- 'Наименование группы пакета услуг'	
                                                -- 0 - ПОДКЛЮЧЕНИЕ КЛИЕНТА К ПАКЕТУ УСЛУГ
                        						-- 1 - ПОДКЛЮЧЕНИЕ СИСТЕМЫ ДБО
AS 
BEGIN
    
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
        'SELECT 
            r.InstOwnerID, 
            acr.ResourceID, 
            acr.ContractID, 
            acr.DateStart, 
            acr.DateEnd
        FROM ' + @lnk + '.' + @DbName + '.dbo.eob_AccContractRelation AS acr
        INNER JOIN ' + @lnk + '.' + @DbName + '.dbo.Resource AS r
            ON acr.ResourceID = r.ResourceID
        WHERE acr.DateStart = ''' + CAST(@DtStart AS VARCHAR(20)) + '''
			OR acr.DateEnd = ''' + CAST(@DtStart AS VARCHAR(20)) + '''';
    
    CREATE TABLE #AccContractRelation
    (
        InstOwnerID NUMERIC(15),
        ResourceID NUMERIC(15),
        ContractID NUMERIC(15),
        DateStart DATE,
        DateEnd DATE
    )

    INSERT INTO #AccContractRelation 
    (
        InstOwnerID, 
        ResourceID, 
        ContractID, 
        DateStart, 
        DateEnd
    ) EXEC sys.sp_executesql @stmt = @cmd

    CREATE TABLE #DocsSource
    (
        Date DATE,
        ClientID NUMERIC(15),
        AccountID NUMERIC(15),
        Amount MONEY,
        BonusAmount INT,
        BonusAmountNow INT,
		BonusAmountTotal INT,
        Comment VARCHAR(MAX)
    )
    
    DECLARE @ClientID NUMERIC(15)
    DECLARE @AccountIdExternal NUMERIC(15)

	
    BEGIN   -- <<<<<<< ПРОВЕРКА ФАКТА ПОДКЛЮЧЕНИЯ УСЛУГ >>>>>>>
        DECLARE crsrAccCREnable CURSOR READ_ONLY FAST_FORWARD LOCAL 
        FOR
            SELECT 
                acr.InstOwnerID,
                acr.ResourceID
            FROM #AccContractRelation AS acr
            WHERE acr.DateStart = @DtStart
                --AND acr.DateEnd IS NULL
                AND EXISTS 
                (
                    SELECT * 
                    FROM #BonusAccounts AS ba
                    WHERE ba.AccountIdExternal = acr.ResourceID
                )
            GROUP BY acr.InstOwnerID, acr.ResourceID
    
        OPEN crsrAccCREnable
        FETCH NEXT FROM crsrAccCREnable INTO 
            @ClientID,
            @AccountIdExternal
    
        WHILE @@FETCH_STATUS = 0
        BEGIN
    
            DECLARE @PackageServiceUID UNIQUEIDENTIFIER
            DECLARE crsrPackagesEnable CURSOR READ_ONLY FAST_FORWARD LOCAL 
            FOR 
                SELECT gspsbn.PackageServiceUID
                FROM config.GetSubPackageServicesByName(@PackageServiceOperationName) AS gspsbn 
            
                OPEN crsrPackagesEnable
                FETCH NEXT FROM crsrPackagesEnable INTO 
                    @PackageServiceUID
            
                WHILE @@FETCH_STATUS = 0
                BEGIN
    
                IF NOT EXISTS 
                (
                    SELECT *
                    FROM config.TypesServiceContracts tsc
                    INNER JOIN config.PackageServices ps
                        ON tsc.PackageServiceUID = ps.PackageServiceUID
                    LEFT JOIN 
                        (
                            SELECT * 
                            FROM #AccContractRelation AS acr
                            WHERE acr.ResourceID = @AccountIdExternal
                                AND acr.DateStart = @DtStart
                                --AND acr.DateEnd IS NULL
                        ) AS AccCon
                    ON tsc.InstRelTypeID = AccCon.ContractID
                    WHERE ps.PackageServiceUID = @PackageServiceUID
                        AND AccCon.InstOwnerID IS NULL
                )
                BEGIN
                
                    INSERT INTO cust.ClientAccountsPackageHistory 
                    (
                        AccountUID, 
                        DtBegin, 
                        PackageServiceUID, 
                        OperationHandlerUID
                    )
                    VALUES 
                    ( 
                        cust.GetAccountUIDByIdExternal(@AccountIdExternal), 
                        @DtStart, 
                        @PackageServiceUID, 
                        @OperationHandlerUID 
                    );          
                
                    INSERT INTO #DocsSource 
                    (
                        Date, 
                        ClientID, 
                        AccountID, 
                        Amount, 
                        Comment
                    )
                    VALUES 
                    (
                        @DtStart,
                        @ClientID, 
                        @AccountIdExternal, 
                        1, 
                        FORMAT(@DtStart, 'dd.MM.yyyy') + ' счёт №' + cust.GetAccountNumberByIdExternal(@AccountIdExternal) + ' подключен к пакету услуг "' + config.GetPackageServiceNameByUID(@PackageServiceUID) + '"'
                    );            
                
                END 
            
                FETCH NEXT FROM crsrPackagesEnable INTO 
                    @PackageServiceUID
            END 
            CLOSE crsrPackagesEnable
            DEALLOCATE crsrPackagesEnable
    
            FETCH NEXT FROM crsrAccCREnable INTO 
                @ClientID,
                @AccountIdExternal
    
        END 
        CLOSE crsrAccCREnable
        DEALLOCATE crsrAccCREnable
    
	    EXEC [bonus-charge].DataSoursePrepaire @OperationHandlerUID = @OperationHandlerUID,
										       @DtSource = @DtStart;
    END 

    BEGIN   -- <<<<<<< ПРОВЕРКА ФАКТА ОТКЛЮЧЕНИЯ ОТ УСЛУГ >>>>>>>

        DECLARE @PackageHistoryUID UNIQUEIDENTIFIER
        DECLARE @HistoryOperationHandlerUID UNIQUEIDENTIFIER
	    DECLARE crsrAccCRDisable CURSOR READ_ONLY FAST_FORWARD LOCAL 
        FOR 
            SELECT 
                caph.PackageHistoryUID,
                cust.GetAccountIdByAccountUID(caph.AccountUID) AS AccountId,
                caph.PackageServiceUID,
                caph.OperationHandlerUID
            FROM cust.ClientAccountsPackageHistory AS caph
            WHERE caph.DtEnd IS NULL
                AND caph.DtBegin <= @DtStart
    
        OPEN crsrAccCRDisable
        FETCH NEXT FROM crsrAccCRDisable INTO 
            @PackageHistoryUID,
            @AccountIdExternal,
            @PackageServiceUID,
            @HistoryOperationHandlerUID
    
        WHILE @@FETCH_STATUS = 0
        BEGIN
        
            DECLARE @SubPackageServiceUID UNIQUEIDENTIFIER
            DECLARE crsrPackagesDisable CURSOR READ_ONLY FAST_FORWARD LOCAL 
            FOR 
                SELECT gspsbn.PackageServiceUID
                FROM config.GetSubPackageServicesByUID(@PackageServiceUID) AS gspsbn 
            
                OPEN crsrPackagesDisable
                FETCH NEXT FROM crsrPackagesDisable INTO 
                    @SubPackageServiceUID
            
                WHILE @@FETCH_STATUS = 0
                BEGIN
    
                IF NOT EXISTS 
                (
                    SELECT *
				    FROM config.TypesServiceContracts AS tsc
				    INNER JOIN config.PackageServices AS ps
					    ON tsc.PackageServiceUID = ps.PackageServiceUID
				    LEFT JOIN 
					    (
						    SELECT * 
						    FROM #AccContractRelation AS acr
						    WHERE acr.ResourceID = @AccountIdExternal
							    AND acr.DateStart IS NOT NULL
							    AND acr.DateEnd = @DtStart
					    ) AS AccCon
				    ON tsc.InstRelTypeID = AccCon.ContractID
				    WHERE ps.PackageServiceUID = @SubPackageServiceUID
					    AND AccCon.InstOwnerID IS NULL
                )
                BEGIN
                
				    UPDATE caph
				    SET caph.DtEnd = @DtStart
				    FROM cust.ClientAccountsPackageHistory AS caph
				    WHERE caph.PackageHistoryUID = @PackageHistoryUID
                
                    INSERT INTO #DocsSource 
                    (
                        Date, 
                        ClientID, 
                        AccountID, 
                        Amount, 
                        BonusAmountTotal,
                        Comment
                    )
                    VALUES 
                    (
                        @DtStart,
                        cust.GetClientIdByAccountId(@AccountIdExternal), 
                        @AccountIdExternal, 
                        -1,
                        loyalty.BonusOperHandGetPointCount(@HistoryOperationHandlerUID) * -1,
                        FORMAT(@DtStart, 'dd.MM.yyyy') + ' счёт №' + cust.GetAccountNumberByIdExternal(@AccountIdExternal) + ' отключен от пакета услуг "' + config.GetPackageServiceNameByUID(@PackageServiceUID) + '"'
                    );            
                
                END 
            
                FETCH NEXT FROM crsrPackagesDisable INTO 
                    @SubPackageServiceUID
            END 
            CLOSE crsrPackagesDisable
            DEALLOCATE crsrPackagesDisable
    
            FETCH NEXT FROM crsrAccCRDisable INTO 
                @PackageHistoryUID,
                @AccountIdExternal,
                @PackageServiceUID,
                @HistoryOperationHandlerUID
    
        END 
        CLOSE crsrAccCRDisable
        DEALLOCATE crsrAccCRDisable
    END 

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
        CASE 
            WHEN ds.BonusAmountTotal < 0 THEN 
                1 -- Тип документа: "Списание бонусов согласно условий"
            ELSE 
                0 -- Тип документа: "Начисление бонусов согласно условий"
        END,  
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
        -199999, 
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
    DROP TABLE #AccContractRelation
END  
GO