SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-22
-- Create time:	16:41:29
-- Description:	Функция возвращает перечень подпакетов услуг
-- по UID пакета
-- =============================================
CREATE FUNCTION [config].[GetSubPackageServicesByUID]
(
    @PackageServiceUID UNIQUEIDENTIFIER
)
RETURNS @tblResult TABLE 
(
    PackageServiceUID UNIQUEIDENTIFIER,
    PackageServiceParentUID UNIQUEIDENTIFIER,
    Name VARCHAR(250)
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
            PackageServiceParentUID, 
            Name
        )
        SELECT 
            ps.PackageServiceUID, 
            ps.PackageServiceParentUID, 
            ps.Name
        FROM config.PackageServices AS ps
        WHERE ps.PackageServiceUID = @PackageServiceUID;

        RETURN
    END 

    DECLARE @ChildPackageServiceUID VARCHAR(500)
    DECLARE @ChildPackageServiceName VARCHAR(500)
    DECLARE crsr CURSOR READ_ONLY FAST_FORWARD
    FOR 
        SELECT 
            ps.PackageServiceUID,
            ps.Name 
        FROM config.PackageServices AS ps
        WHERE ps.PackageServiceParentUID = @PackageServiceUID

    OPEN crsr
    FETCH NEXT FROM crsr INTO  
        @ChildPackageServiceUID,
        @ChildPackageServiceName
    
    WHILE @@FETCH_STATUS = 0
	BEGIN
        IF NOT EXISTS (SELECT * 
                       FROM config.PackageServices AS ps
                       WHERE ps.PackageServiceParentUID = @ChildPackageServiceUID)   
        BEGIN
            INSERT INTO @tblResult 
            (
                PackageServiceUID, 
                PackageServiceParentUID, 
                Name
            )
            SELECT 
                ps.PackageServiceUID, 
                ps.PackageServiceParentUID, 
                ps.Name
            FROM config.PackageServices AS ps
            WHERE ps.PackageServiceUID = @ChildPackageServiceUID
        END 
        ELSE BEGIN     
            INSERT INTO @tblResult 
            (
                PackageServiceUID, 
                PackageServiceParentUID, 
                Name
            )
            SELECT 
                tsc.PackageServiceUID, 
                tsc.PackageServiceParentUID, 
                tsc.Name
            FROM config.GetSubPackageServicesByName(@ChildPackageServiceName) AS tsc;  
        END
        FETCH FROM crsr INTO
            @ChildPackageServiceUID,
            @ChildPackageServiceName
    END
    CLOSE crsr
    DEALLOCATE crsr

    RETURN 

END 
GO