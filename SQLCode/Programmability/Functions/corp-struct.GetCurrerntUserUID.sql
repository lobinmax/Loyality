SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.05.2021
-- Create time:	10:22
-- Description:	Возвращает UID текущего пользователя
-- =============================================
CREATE FUNCTION [corp-struct].[GetCurrerntUserUID] ()
RETURNS UNIQUEIDENTIFIER
BEGIN

    DECLARE @CurrentLogin AS VARCHAR(100) = SYSTEM_USER 
    DECLARE @UserUID AS UNIQUEIDENTIFIER 

    SELECT @UserUID = u.UserUID 
    FROM [corp-struct].Users u
    WHERE u.Login = @CurrentLogin 

    RETURN @UserUID
    
END
GO