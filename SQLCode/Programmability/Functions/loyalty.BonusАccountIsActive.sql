SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-28
-- Create time:	11:03:18
-- Description:	Ф-ция определяет действует ли бонусный счет на дату
-- 0 закрыт; 1 открыт
-- =============================================
CREATE FUNCTION [loyalty].[BonusАccountIsActive] 
(
    @BonusAccountUID UNIQUEIDENTIFIER,
    @DtBegin DATE = NULL
)
RETURNS BIT
AS 
BEGIN
    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate())
    DECLARE @Result AS BIT = 0;

    IF EXISTS(SELECT * 
              FROM loyalty.ClientBonusАccounts AS cbа 
              WHERE cbа.BonusAccountUID = @BonusAccountUID 
                AND (cbа.DtClose IS NULL OR cbа.DtClose > @DtBegin)
                AND cbа.DtOpen <= @DtBegin)
    BEGIN
        SET @Result = 1
    END 

    RETURN @Result 

END 
GO