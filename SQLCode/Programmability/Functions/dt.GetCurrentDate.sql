SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-19
-- Create time:	10:28:50
-- Description:	Возвращает текущую дату
-- =============================================
CREATE FUNCTION	[dt].[GetCurrentDate]()
RETURNS DATE
AS
BEGIN 
	RETURN CAST(dt.GetCurrentDatetime() AS DATE);
END
GO