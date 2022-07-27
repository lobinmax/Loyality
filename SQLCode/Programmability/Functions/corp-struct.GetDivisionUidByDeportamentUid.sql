SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-20
-- Create time:	18:21:24
-- Description:	Ф-ция возвращает ВСП которому принадлежит депортамент
-- =============================================
CREATE FUNCTION [corp-struct].[GetDivisionUidByDeportamentUid]
(
    @DeportamentUID UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
BEGIN
	
    DECLARE @DivisionUID AS UNIQUEIDENTIFIER
    SET @DivisionUID = 
    (
        SELECT TOP(1) d.DivisionParentUID
        FROM [corp-struct].Divisions d
        WHERE d.DivisionUID = @DeportamentUID    
    )
    
    RETURN @DivisionUID;
END
GO