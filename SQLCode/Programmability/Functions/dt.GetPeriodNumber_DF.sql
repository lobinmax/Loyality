SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-28
-- Create time:	09:19:05
-- Description:	Ф-ция возвращает из даты период в формате YYYYMM
-- ============================================= 
CREATE FUNCTION [dt].[GetPeriodNumber_DF] 
(
    @Dt DATE = NULL
)
RETURNS INT
AS
BEGIN    
    RETURN dt.GetPeriodNumber(@Dt);
END
GO