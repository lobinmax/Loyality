SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-23
-- Create time:	15:44:35
-- Description:	Ф-ция возвращает внитренний ИД счета по внешнему
-- =============================================
CREATE FUNCTION [cust].[GetAccountUIDByIdExternal]
(
    @AccountIdExternal NUMERIC(15)
)
RETURNS UNIQUEIDENTIFIER
AS BEGIN
    DECLARE @AccountUID UNIQUEIDENTIFIER = 
    (
        SELECT ca.AccountUID 
        FROM cust.ClientAccounts AS ca 
        WHERE ca.AccountIdExternal = @AccountIdExternal
    )
    RETURN @AccountUID;
END 
GO