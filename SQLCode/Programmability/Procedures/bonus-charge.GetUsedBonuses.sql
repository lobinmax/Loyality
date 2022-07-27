SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 19.07.2021
-- Create time:	11:27
-- Description:	ХП возвращвет счета по которым в периоде
-- необходимо применить скидку
-- =============================================
CREATE PROCEDURE [bonus-charge].[GetUsedBonuses]
    @DtBegin DATE,
    @DtEnd DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT cust.GetClientIdByBonusAccountUID(bs.BonusAccountUID) AS InstOwnerID,
           ca.AccountIdExternal AS ResourceID,
           tsc.InstRelTypeID AS InstRelTypeID,
           tsc.NameBrief AS Brief
    FROM [bonus-charge].BonusSpent AS bs
    INNER JOIN cust.ClientAccounts AS ca
        ON ca.AccountUID = bs.AccountUID
    INNER JOIN config.TypesServiceContracts AS tsc
        ON tsc.ServiceContractUID = bs.ServiceContractUID
    WHERE bs.DtBegin = @DtBegin 
        AND bs.DtEnd = @DtEnd
END
GO