SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 14.07.2021
-- Create time:	12:41
-- Description:	ХП возвращает подключенные к счетам клиента коммиссии
-- только те за которые можно расчитаться бонусами
-- =============================================
CREATE PROCEDURE [loyalty].[GetConnectedCommissions]
	@ClientId NUMERIC(15)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ClientUID UNIQUEIDENTIFIER = cust.GetClientUIDByClientId(@ClientId);
    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @DbOur AS VARCHAR(50) = QUOTENAME(CAST(config.ParametersGetValue('Имя общей базы данных OUR', DEFAULT, DEFAULT) AS VARCHAR(50)));
    DECLARE @cmd AS NVARCHAR(MAX);  
    DECLARE @Today AS DATE = dt.GetCurrentDate();

    CREATE TABLE #tIRTAccountService
    (
        ClientId NUMERIC(15),
        RecordId NUMERIC(15),
        AccountId NUMERIC(15),
        InstRelTypeID NUMERIC(15),
        AccountNumber VARCHAR(50)
    )

    CREATE TABLE #tTariff
    (
        Breif VARCHAR(50),
        Amount MONEY,
        Number INT,
        Commment VARCHAR(300),
        Code INT 
    )

    SET @cmd = 
    '
        SELECT r.InstOwnerID, 
               [is].IRTAccountServiceID, 
               [is].ResourceID, 
               [is].InstRelTypeID, 
               r.Brief
        FROM ' + @lnk + '.' + @DbName + '.dbo.tIRTAccountService AS [is]
        INNER JOIN ' + @lnk + '.' + @DbName + '.dbo.tResource AS r
            ON [is].ResourceID = r.ResourceID
        WHERE r.InstOwnerID = ' + CAST(@ClientId AS VARCHAR(50)) + 
    '';

    INSERT INTO #tIRTAccountService
    (
        ClientId,
        RecordId,
        AccountId,
        InstRelTypeID,
        AccountNumber
    )EXEC sys.sp_executesql @stmt = @cmd;

    SET @cmd = 
    '
        SELECT ct.Brief, 
               ct.Summa, 
               ct.Number, 
               ct.Comment, 
               ct.Code 
        FROM ' + @lnk + '.' + @DbOur + '.dbo.com_tTarif AS ct
    ';

    INSERT INTO #tTariff
    (
        Breif,
        Amount,
        Number,
        Commment,
        Code
    )EXEC sys.sp_executesql @stmt = @cmd

    SELECT loyalty.BonusАccountGetCurrentUID(@ClientUID, DEFAULT) AS BonusAccountUID,
           ps.PackageServiceUID,
           gcbpsn.ServiceContractUID,
           tias.AccountNumber,
           cust.GetAccountUIDByIdExternal(tias.AccountId) AS AccountUID,
           gcbpsn.InstRelTypeID,
           ps.Name AS PackageName,
           gcbpsn.Name AS CommissionName, 
           ps.Description, 
           gcbpsn.NameBrief,
           tt.Amount,
           CASE WHEN bs.AccountUID IS NULL THEN 0 ELSE 1 END AS IsUsed
    FROM config.GetContractsByPackageServiceName('Поощрительные пакеты услуг') AS gcbpsn
    INNER JOIN config.PackageServices AS ps
        ON ps.PackageServiceUID = gcbpsn.PackageServiceUID
    INNER JOIN #tIRTAccountService AS tias
        ON tias.InstRelTypeID = gcbpsn.InstRelTypeID
    INNER JOIN #tTariff AS tt
        ON tt.Breif = gcbpsn.NameBrief
    LEFT JOIN [bonus-charge].BonusSpent AS bs
        ON bs.AccountUID = cust.GetAccountUIDByIdExternal(tias.AccountId)
        AND bs.ServiceContractUID = gcbpsn.ServiceContractUID
        AND bs.DtBegin = dt.MonthFirstDay(DATEADD(MONTH, 1, @Today))
        AND bs.DtEnd = dt.MonthLastDay(DATEADD(MONTH, 1, @Today))
    ORDER BY tias.AccountNumber, ps.Name, gcbpsn.Name

    DROP TABLE #tIRTAccountService
    DROP TABLE #tTariff
END
GO