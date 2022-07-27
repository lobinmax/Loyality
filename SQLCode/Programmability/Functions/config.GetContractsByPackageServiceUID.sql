SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-18
-- Create time:	14:29:47
-- Description:	Ф-ци возвращает таблицу договоров
-- входящих в пакет услуг
-- =============================================
CREATE FUNCTION [config].[GetContractsByPackageServiceUID]
(
    @PackageServiceUID UNIQUEIDENTIFIER
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
	DECLARE @ChildCount INT = 
    (            
        SELECT COUNT(*) 
        FROM config.PackageServices AS ps
        WHERE ps.PackageServiceParentUID = @PackageServiceUID
    )
    
    IF @ChildCount = 0
    BEGIN
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
        FROM config.TypesServiceContracts AS tsc
        WHERE tsc.PackageServiceUID = @PackageServiceUID;

        RETURN
    END 
    
    DECLARE @ChildPackageServiceUID UNIQUEIDENTIFIER
    DECLARE crsr CURSOR READ_ONLY FAST_FORWARD
    FOR 
        SELECT 
            ps.PackageServiceUID 
        FROM config.PackageServices AS ps
        WHERE ps.PackageServiceParentUID = @PackageServiceUID

    OPEN crsr
    FETCH NEXT FROM crsr INTO  
        @ChildPackageServiceUID
    
    WHILE @@FETCH_STATUS = 0
	BEGIN        
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
        FROM config.GetContractsByPackageServiceUID(@ChildPackageServiceUID) AS tsc;  
        
        FETCH FROM crsr INTO
            @ChildPackageServiceUID
    END
    CLOSE crsr
    DEALLOCATE crsr

    RETURN
END
GO