SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 30.06.2021
-- Create time:	14:41
-- Description:	<Ф-ция возвращает последний день месяца по дате>
-- =============================================
CREATE FUNCTION [dt].[MonthLastDay]
(
	@Dt DATE = NULL
)
RETURNS DATE
AS
BEGIN
	SET @Dt = COALESCE(@Dt, dt.GetCurrentDate());
	
    RETURN (SELECT EOMONTH(@Dt));
END
GO