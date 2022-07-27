SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.05.2021
-- Create time:	13:57
-- Description:	LTRIM(RTRIM)
-- =============================================
CREATE FUNCTION [str].[Trim] 
(
	@InputString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	RETURN LTRIM(RTRIM(@InputString))
END
GO