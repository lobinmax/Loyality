SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-22
-- Create time:	16:41:29
-- Description:	Функция возвращиет перечень подпакетов услуг
-- по наименованию пакета
-- =============================================
CREATE FUNCTION [config].[GetSubPackageServicesByName]
(
    @PackageServiceName VARCHAR(500)
)
RETURNS @tblResult TABLE 
(
    PackageServiceUID UNIQUEIDENTIFIER,
    PackageServiceParentUID UNIQUEIDENTIFIER,
    Name VARCHAR(250)
)
AS 
BEGIN    
    DECLARE @PackageServiceUID UNIQUEIDENTIFIER
    SELECT @PackageServiceUID = ps.PackageServiceUID
    FROM config.PackageServices AS ps
    WHERE ps.Name = @PackageServiceName

    INSERT INTO @tblResult
    (
        PackageServiceUID,
        PackageServiceParentUID,
        Name
    )
    SELECT 
        PackageServiceUID,
        PackageServiceParentUID,
        Name
    FROM config.GetSubPackageServicesByUID(@PackageServiceUID)
    
    RETURN 

END 
GO