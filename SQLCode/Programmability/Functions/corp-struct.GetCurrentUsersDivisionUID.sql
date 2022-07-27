SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-20
-- Create time:	18:13:11
-- Description:	ХП возвращает текущее ВСП сотрудника
-- =============================================
CREATE FUNCTION [corp-struct].[GetCurrentUsersDivisionUID]
(
    @UserUID UNIQUEIDENTIFIER = NULL
)
RETURNS UNIQUEIDENTIFIER
BEGIN
	
    IF (@UserUID IS NULL)
    BEGIN
    	SET @UserUID = [corp-struct].GetCurrerntUserUID()
    END

    DECLARE @DeportamentUID AS UNIQUEIDENTIFIER = [corp-struct].GetCurrentUsersDeportamentUID(@UserUID)
    
    RETURN [corp-struct].GetDivisionUidByDeportamentUid(@DeportamentUID)
END
GO