SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-20
-- Create time:	18:13:11
-- Description:	ХП возвращает текущий депортамент сотрудника
-- =============================================
CREATE FUNCTION [corp-struct].[GetCurrentUsersDeportamentUID]
(
    @UserUID UNIQUEIDENTIFIER = NULL
)
RETURNS UNIQUEIDENTIFIER
BEGIN
	
    IF (@UserUID IS NULL)
    BEGIN
    	SET @UserUID = [corp-struct].GetCurrerntUserUID()
    END

    DECLARE @DeportamentUID AS UNIQUEIDENTIFIER 
    SET @DeportamentUID = 
    (
        SELECT TOP(1) u.DeportamentUID 
        FROM [corp-struct].Users u
        WHERE u.UserUID = @UserUID
    ) 

    RETURN @DeportamentUID
END
GO