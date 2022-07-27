SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 05.07.2021
-- Create time:	10:19
-- Description:	Ф-ция возвращает внешний ИД клиента по 
-- внешнему ИД счета
-- =============================================
CREATE FUNCTION [cust].[GetClientIdByAccountId]
(
	@AccountId NUMERIC(15)
)
RETURNS NUMERIC(15)
AS
BEGIN
	DECLARE @ClientId NUMERIC(15) = 
    (
        SELECT c.ClientIdExternal
        FROM cust.Clients AS c
        INNER JOIN cust.ClientAccounts AS ca
            ON ca.ClientUID = c.ClientUID
        WHERE ca.AccountIdExternal = @AccountId
    )

    RETURN @ClientId;
END
GO