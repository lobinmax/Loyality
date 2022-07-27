SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-24
-- Create time:	14:18:21
-- Description:	Ф-ция возвращает номер банковского счёта 
-- по внешнему ИД
-- =============================================
CREATE FUNCTION [cust].[GetAccountNumberByIdExternal]
(
    @AccountIdExternal NUMERIC(15)
)
RETURNS VARCHAR(50)
BEGIN
    DECLARE @AccountNumberExternal VARCHAR(50) = 
    (
        SELECT str.Trim(ca.AccountNumberExternal) 
        FROM cust.ClientAccounts AS ca 
        WHERE ca.AccountIdExternal = @AccountIdExternal
    )
    RETURN @AccountNumberExternal;
END 
GO