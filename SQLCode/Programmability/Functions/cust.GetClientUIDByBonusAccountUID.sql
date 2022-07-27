SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.07.2021
-- Create time:	9:55
-- Description:	Ф-ция возвращает внутренний ИД клиента 
-- по ИД бонусного счета
-- =============================================
CREATE FUNCTION [cust].[GetClientUIDByBonusAccountUID] 
(
    @BonusAccountUID UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @ClientUID UNIQUEIDENTIFIER = 
    (
        SELECT cbа.ClientUID
        FROM loyalty.ClientBonusАccounts AS cbа
        WHERE cbа.BonusAccountUID = @BonusAccountUID
    )

    RETURN @ClientUID;
END
GO