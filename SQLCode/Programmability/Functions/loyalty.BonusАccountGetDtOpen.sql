SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.07.2021
-- Create time:	16:03
-- Description:	Ф-ция возвращает дата открытия бонусного счета
-- =============================================
CREATE FUNCTION [loyalty].[BonusАccountGetDtOpen]
(
    @BonusAccountUID UNIQUEIDENTIFIER
)
RETURNS DATE
AS
BEGIN
    DECLARE @DtOpen DATE = 
    (
        SELECT cbа.DtOpen
        FROM loyalty.ClientBonusАccounts AS cbа
        WHERE cbа.BonusAccountUID = @BonusAccountUID
    )

    RETURN @DtOpen;
END
GO