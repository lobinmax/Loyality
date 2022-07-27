SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-19
-- Create time:	10:33:33
-- Description:	Возвращает текущую дату
-- =============================================
CREATE FUNCTION	[dt].[GetCurrentDate_DF]()
RETURNS DATETIME2
AS
BEGIN 
	RETURN dt.GetCurrentDate()
END
GO