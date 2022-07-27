SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:	Lobin A. Max
-- Create date: 05.07.2021
-- Create time:	9:35
-- Description:	<Ф-ция возвращает внешний ИД счета по внутреннему>
-- =============================================
CREATE FUNCTION [cust].[GetAccountIdByAccountUID]
(
	@AccountUID UNIQUEIDENTIFIER
)
RETURNS NUMERIC(15)
AS
BEGIN
	DECLARE @AccountId NUMERIC(15) = 
    (
        SELECT ca.AccountIdExternal
        FROM cust.ClientAccounts AS ca
        WHERE ca.AccountUID = @AccountUID
    )

    RETURN @AccountId;
END
GO