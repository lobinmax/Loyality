SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 30.06.2021
-- Create time:	14:41
-- Description:	<Ф-ция возвращает первый день месяца по дате>
-- =============================================
CREATE FUNCTION [dt].[MonthFirstDay]
(
	@Dt DATE = NULL
)
RETURNS DATE
AS
BEGIN
	SET @Dt = COALESCE(@Dt, dt.GetCurrentDate());
	
    RETURN (SELECT DATEADD(DAY, 1, EOMONTH(@Dt, -1)));
END
GO