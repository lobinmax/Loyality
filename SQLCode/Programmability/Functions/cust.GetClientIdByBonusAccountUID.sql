SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.07.2021
-- Create time:	9:55
-- Description:	Ф-ция возвращает внешний ИД клиента 
-- по ИД бонусного счета
-- =============================================
CREATE FUNCTION [cust].[GetClientIdByBonusAccountUID] 
(
    @BonusAccountUID UNIQUEIDENTIFIER
)
RETURNS NUMERIC(15)
AS
BEGIN
	DECLARE @ClientId NUMERIC(15) = 
    (
        SELECT c.ClientIdExternal
        FROM loyalty.ClientBonusАccounts AS cbа
        INNER JOIN cust.Clients AS c
            ON c.ClientUID = cbа.ClientUID
        WHERE cbа.BonusAccountUID = @BonusAccountUID
    )

    RETURN @ClientId;
END
GO