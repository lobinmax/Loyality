SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-23
-- Create time:	17:12:39
-- Description:	Ф-ция возвращает наименование 
-- пакета услуг по его UID
-- =============================================
CREATE FUNCTION [config].[GetPackageServiceNameByUID]
(
    @PackageServiceUID UNIQUEIDENTIFIER
)
RETURNS VARCHAR(500)
AS BEGIN
    DECLARE @PackageService VARCHAR(500) = 
    (
        SELECT ps.Name
        FROM config.PackageServices AS ps
        WHERE ps.PackageServiceUID = @PackageServiceUID
    )
    RETURN @PackageService	
END
GO