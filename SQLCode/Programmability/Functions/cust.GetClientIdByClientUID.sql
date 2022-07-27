SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:	Lobin A. Max
-- Create date: 05.07.2021
-- Create time:	10:15
-- Description:	Ф-ция возвращает локальный идентификатор клиента
-- =============================================
CREATE FUNCTION [cust].[GetClientIdByClientUID]
(
	@ClientUID UNIQUEIDENTIFIER
)
RETURNS NUMERIC(15)
AS
BEGIN
	DECLARE @ClientId NUMERIC(15) = 
    (
        SELECT c.ClientIdExternal 
        FROM cust.Clients AS c
        WHERE c.ClientUID = @ClientUID
    )
    RETURN @ClientId;
END
GO