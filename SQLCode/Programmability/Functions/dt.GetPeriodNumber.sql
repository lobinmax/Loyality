SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-28
-- Create time:	09:19:05
-- Description:	Ф-ция возвращает из даты период в формате YYYYMM
-- ============================================= 
CREATE FUNCTION [dt].[GetPeriodNumber]
(
    @Dt DATE = NULL
)
RETURNS INT 
AS
BEGIN
    SET @Dt = COALESCE(@Dt, dt.GetCurrentDate())
	RETURN YEAR(@Dt) * 100 + MONTH(@Dt)
END
GO