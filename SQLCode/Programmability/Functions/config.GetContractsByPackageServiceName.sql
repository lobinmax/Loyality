SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-18
-- Create time:	14:29:47
-- Description:	Ф-ци возвращает таблицу договоров
-- входящих в пакет услуг
-- =============================================
CREATE FUNCTION [config].[GetContractsByPackageServiceName]
(
    @PackageServiceName VARCHAR(250)
)
RETURNS @tblResult TABLE 
(
    PackageServiceUID UNIQUEIDENTIFIER,
    ServiceContractUID UNIQUEIDENTIFIER,
    InstRelTypeID NUMERIC(15),
    Name VARCHAR(250),
    NameBrief VARCHAR(50)
) 
AS 
BEGIN
    DECLARE @PackageServiceUID UNIQUEIDENTIFIER = 
    (
        SELECT ps.PackageServiceUID 
        FROM config.PackageServices AS ps
        WHERE ps.Name = @PackageServiceName
    )
    
    INSERT INTO @tblResult 
    (
        PackageServiceUID, 
        ServiceContractUID, 
        InstRelTypeID, 
        Name, 
        NameBrief
    )
    SELECT 
        tsc.PackageServiceUID, 
        tsc.ServiceContractUID, 
        tsc.InstRelTypeID, 
        tsc.Name, 
        tsc.NameBrief 
    FROM config.GetContractsByPackageServiceUID(@PackageServiceUID) AS tsc;  

    RETURN
END
GO