SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 23.07.2021
-- Create time:	16:51
-- Description:	ХП синхронизирует перечень банковских счетов
-- с базой Диасофт. 
-- =============================================
CREATE PROCEDURE [depen-dias].[Syncing_ClientAccounts]
AS
BEGIN 
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    CREATE TABLE #AccountsFromDias 
    (
        AccountId NUMERIC(15),
        DtOpen DATE,
        DtClose DATE,
        CloseReason VARCHAR(300),
        ClientTypeId INT,
        DivisionPrefix VARCHAR(10),
        Brief VARCHAR(50)
    )

    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @db AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @cmd AS NVARCHAR(MAX);
    DECLARE @ClientId NUMERIC(15);   
    DECLARE @ClientUID UNIQUEIDENTIFIER;    
    DECLARE crsrClients CURSOR FAST_FORWARD READ_ONLY LOCAL FOR 
        SELECT c.ClientIdExternal
        FROM cust.Clients AS c
        WHERE loyalty.BonusАccountGetCurrentUID(c.ClientUID, DEFAULT) IS NOT NULL
    
    OPEN crsrClients
    
    FETCH NEXT FROM crsrClients INTO 
        @ClientId
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        TRUNCATE TABLE #AccountsFromDias
        SET @cmd =
            @lnk + '.' + @db + '.[dbo].[_avs_GetLoyaltyClientInfo] 
			    @ClientID = ' + CAST(@ClientId AS VARCHAR(50));

        SET @ClientUID = cust.GetClientUIDByClientId(@ClientId);        
        INSERT INTO #AccountsFromDias
        (
            AccountId,
            DtOpen,
            DtClose,
            CloseReason,
            ClientTypeId,
            DivisionPrefix,
            Brief
        ) EXEC sys.sp_executesql @stmt = @cmd

        UPDATE ca
        SET ca.DtClose = afd.DtClose,
            ca.CloseReason = afd.CloseReason
        FROM cust.ClientAccounts AS ca
        INNER JOIN #AccountsFromDias AS afd
            ON afd.AccountId = ca.AccountIdExternal
        WHERE ca.ClientUID = @ClientUID

        INSERT INTO cust.ClientAccounts
        (
            AccountIdExternal,
            AccountNumberExternal,
            ClientUID,
            DtOpen,
            DtClose,
            CloseReason
        )
        SELECT afd.AccountId, 
               afd.Brief, 
               @ClientUID, 
               afd.DtOpen, 
               afd.DtClose, 
               afd.CloseReason
        FROM #AccountsFromDias AS afd
        WHERE NOT EXISTS
            (
                SELECT * 
                FROM cust.ClientAccounts AS ca
                WHERE ca.AccountIdExternal = afd.AccountId
            )

        FETCH NEXT FROM crsrClients INTO 
            @ClientId
    END
    
    CLOSE crsrClients
    DEALLOCATE crsrClients    
END
GO