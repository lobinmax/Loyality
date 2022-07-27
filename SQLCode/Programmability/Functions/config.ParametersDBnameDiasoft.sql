SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-24
-- Create time:	14:26:33
-- Description:	Ф-ция возвращает текущее наименование базы Диасофт
-- =============================================
CREATE FUNCTION [config].[ParametersDBnameDiasoft]()
RETURNS VARCHAR(50)
BEGIN
	RETURN QUOTENAME(CAST(config.ParametersGetValue('Имя базы данных Diasoft', DEFAULT, DEFAULT) AS VARCHAR(50)));
END
GO