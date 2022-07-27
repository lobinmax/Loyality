SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 30.07.2021
-- Create time:	10:37
-- Description:	Ф-ция удаляет из строки символы "[" и "]"
-- =============================================
CREATE FUNCTION [str].[QuoteReplace] 
(
    @InputString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    RETURN REPLACE(REPLACE(@InputString, '[', ''), ']', '');
END 
GO