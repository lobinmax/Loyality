SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 21.05.2021
-- Create time:	18:16
-- Description:	Ф-ция возвращает вчерашнюю дату
-- =============================================
CREATE FUNCTION [dt].[Yesterday]
(
	@Dt DATE = NULL
)
RETURNS DATE
AS
BEGIN
	SET @Dt = COALESCE(@Dt, dt.GetCurrentDate())

	RETURN DATEADD(DAY, -1, @Dt);
END
GO