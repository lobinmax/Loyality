SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 20.07.2021
-- Create time:	9:16
-- Description:	Ф-ция определяет подключен ли клиент 
-- к программе лояльности в определенную дату
-- =============================================
CREATE FUNCTION [cust].[ClientIsConnectToLoyalty]
(
    @ClientId NUMERIC(15),
    @DtBegin DATE = NULL
)
RETURNS BIT 
AS
BEGIN
    DECLARE @ClientIsConnect BIT = 0;
	
    IF loyalty.BonusАccountGetCurrentUID(cust.GetClientUIDByClientId(@ClientId), @DtBegin) IS NOT NULL
    BEGIN 
        SET @ClientIsConnect = 1;
    END 
    
    RETURN @ClientIsConnect;
END
GO