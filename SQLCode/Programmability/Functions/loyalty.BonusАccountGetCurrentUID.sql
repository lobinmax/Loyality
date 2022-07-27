SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 13.07.2021
-- Create time:	9:10
-- Description:	Ф-ция возвращает ИД текущего бонусного 
-- счета действующего на дату
-- =============================================
CREATE FUNCTION [loyalty].[BonusАccountGetCurrentUID] 
(
	@ClientUID UNIQUEIDENTIFIER,
    @DtBegin DATE = NULL
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate());
    DECLARE @BonusAccountUID UNIQUEIDENTIFIER = 
    (
        SELECT cbа.BonusAccountUID
        FROM loyalty.ClientBonusАccounts AS cbа
        WHERE cbа.DtOpen <= @DtBegin 
            AND (cbа.DtClose IS NULL OR cbа.DtClose > @DtBegin)
            AND cbа.ClientUID = @ClientUID
    )

	RETURN @BonusAccountUID
END
GO