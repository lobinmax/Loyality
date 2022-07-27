SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.05.2021
-- Create time:	10:32
-- Description:	Возвращает текущие дата - время
-- =============================================
CREATE FUNCTION	[dt].[GetCurrentDatetime_DF]()
RETURNS DATETIME2
AS
BEGIN 
	RETURN dt.GetCurrentDatetime()
END
GO