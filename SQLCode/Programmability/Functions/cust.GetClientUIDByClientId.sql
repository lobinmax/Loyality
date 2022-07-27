SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 29.06.2021 
-- Description:	Ф-ция возвращает локальный идентификатор клиента
-- =============================================
CREATE FUNCTION [cust].[GetClientUIDByClientId]
(
	@ClientId NUMERIC(15)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @ClientUID UNIQUEIDENTIFIER = 
    (
        SELECT c.ClientUID 
        FROM cust.Clients AS c
        WHERE c.ClientIdExternal = @ClientId
    )
    RETURN @ClientUID;
END
GO