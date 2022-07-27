SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-21
-- Create time:	11:53:33
-- Description:	Возвращает из параметров текущий линк к RBS
-- для текущего пользователя
-- =============================================
CREATE FUNCTION [config].[ParametersLinkRBS]()
RETURNS VARCHAR(50)
BEGIN
	RETURN QUOTENAME(CAST(config.ParametersGetValue('LinkedServer к RBS', DEFAULT, DEFAULT) AS VARCHAR(50)));
END
GO