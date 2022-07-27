SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 24.05.2021
-- Create time:	11:37
-- Description:	ХП создает клиента в программе лояльности
-- по внешнему ИД клиента из АБС
-- =============================================
CREATE PROCEDURE [loyalty].[LoyaltyConnect] 
    @ClientIdExternal NUMERIC(15),
    @CodeResult INT = 0 OUTPUT
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    DECLARE @msg AS VARCHAR(MAX);
    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @db AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @ClientUID AS UNIQUEIDENTIFIER = NEWID();

    BEGIN TRANSACTION
        
        CREATE TABLE #AccountsFromDias 
        (
            AccountId NUMERIC(15)
            ,DtOpen DATE
            ,DtClose DATE
            ,CloseReason VARCHAR(300)
            ,ClientTypeId INT
            ,DivisionPrefix VARCHAR(10)
            ,Brief VARCHAR(50)
        )

        DECLARE @cmd AS NVARCHAR(MAX) =
            @lnk + '.' + @db + '.[dbo].[_avs_GetLoyaltyClientInfo] 
			    @ClientID = ' + CAST(@ClientIdExternal AS VARCHAR(50));

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

        -- создать клиента
        IF NOT EXISTS (SELECT * 
                       FROM cust.Clients AS c 
                       WHERE c.ClientIdExternal = @ClientIdExternal)
        BEGIN

            IF NOT EXISTS (SELECT *
                           FROM #AccountsFromDias)
            BEGIN
                SET @msg = 'По клиенту не найдены счета во внешней АБС. Ид клиента: "' + CAST(@ClientIdExternal AS VARCHAR(50)) + '"';
                SET @CodeResult = 2;
                THROW 50001, @msg, 1;
                ROLLBACK TRANSACTION;
                RETURN 0;
            END        
            
            INSERT cust.Clients
            (
                ClientUID,
                ClientIdExternal,
                ClientTypeId
            )
            VALUES
            (   
                @ClientUID, 
                @ClientIdExternal,
                ( SELECT TOP (1) ClientTypeId FROM #AccountsFromDias )
            );

            -- добавить счета по клиенту
            INSERT cust.ClientAccounts 
            (
                AccountIdExternal,
                ClientUID,
                DtOpen,
                DtClose,
                CloseReason,
                AccountNumberExternal
            )
            SELECT
                afd.AccountId
                ,@ClientUID
                ,CAST(afd.DtOpen AS DATE)
                ,CAST(afd.DtClose AS DATE)
                ,afd.CloseReason
                ,str.Trim(afd.Brief)
            FROM #AccountsFromDias AS afd
        END 
        ELSE BEGIN
            IF loyalty.BonusАccountGetCurrentUID(cust.GetClientUIDByClientId(@ClientIdExternal), DEFAULT) IS NOT NULL
            BEGIN
                SET @msg = 'По клиенту уже имеется открытый бонусный счет. Ид клиента: "' + CAST(@ClientIdExternal AS VARCHAR(50)) + '"';
                SET @CodeResult = 3;
                THROW 50001, @msg, 1;
                ROLLBACK TRANSACTION;
                RETURN 0;
            END 
            SET @ClientUID = cust.GetClientUIDByClientId(@ClientIdExternal)
        END 

        -- создать бонусный счет
        DECLARE @NextAccountNumber VARCHAR(15);
        DECLARE @DivisionPrefix VARCHAR(10) = 
        (
            SELECT TOP (1)
            DivisionPrefix
            FROM #AccountsFromDias
        )
        EXEC loyalty.AccountGetNextNumber @DidvisionPrefix = @DivisionPrefix
                                         ,@NextAccountNumber = @NextAccountNumber OUTPUT
        
        DECLARE @NewBonusAccountUID UNIQUEIDENTIFIER = NEWID();
        INSERT INTO loyalty.ClientBonusАccounts (BonusAccountUID, ClientUID, AccountNumber)
        VALUES (@NewBonusAccountUID, @ClientUID, @NextAccountNumber)

        IF EXISTS (SELECT * 
                   FROM  loyalty.ClientBonusАccounts AS cbа
                   WHERE cbа.DtClose IS NULL 
                        AND cbа.DtClose <= dt.GetCurrentDate()
                        AND cbа.ClientUID = cust.GetClientUIDByClientId(@ClientIdExternal))
        BEGIN
            DECLARE @SumPreviousBonus INT;
            WITH T0 AS 
            (
                SELECT SUM(loyalty.BonusGetCountByAcoount(cbа.BonusAccountUID, DEFAULT)) AS SumPreviousBonus
                FROM  loyalty.ClientBonusАccounts AS cbа
                WHERE cbа.DtClose IS NOT NULL 
                    AND cbа.DtClose <= dt.GetCurrentDate()
                    AND cbа.ClientUID = cust.GetClientUIDByClientId(@ClientIdExternal) 
            )
            SELECT @SumPreviousBonus = T0.SumPreviousBonus
            FROM T0
            IF (@SumPreviousBonus < 0)
            BEGIN
                EXEC [bonus-charge].BonusDocumentCreate @BonusAccountUID = @NewBonusAccountUID,
                                                        @AccruedBonuses = @SumPreviousBonus,
                                                        @DocumentTypeId = 8, -- Овердрафтный документ
                                                        @Description = 'Перенос задолженности из предыдущих закрытых бонусных счетов'
            END 
        END 

    COMMIT TRANSACTION

    DROP TABLE #AccountsFromDias
END
GO