SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.05.2021
-- Create time:	10:22
-- Description:	Возвращает UID текущего пользователя
-- =============================================
CREATE FUNCTION [corp-struct].[GetCurrerntUserUID_DF] ()
RETURNS UNIQUEIDENTIFIER
BEGIN
    RETURN [corp-struct].GetCurrerntUserUID()    
END
GO