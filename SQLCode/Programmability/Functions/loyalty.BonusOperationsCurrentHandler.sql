SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-26
-- Create time:	14:41:35
-- Description:	Ф-ция возвращает таблицу активных бонусных 
-- операций на определенную дату @DtBegin.
-- По этим операциям производится расчет бонусов
-- =============================================
CREATE FUNCTION [loyalty].[BonusOperationsCurrentHandler] 
(
    @DtBegin DATE = NULL
)
RETURNS @tblResult TABLE 
(
    OperationUID UNIQUEIDENTIFIER
   ,OperationHandlerUID UNIQUEIDENTIFIER
   ,BonusOperationName VARCHAR(100)
   ,BonusOperationDtBegin DATE
   ,IsDisabled BIT
   ,BonusOperationsHandlerDtBegin DATE
   ,PointsCount MONEY
   ,PointsCountMin INT
   ,PointsCountMax INT
   ,MethodChargeId INT
   ,MethodCharge VARCHAR(50)
   ,HandlerName VARCHAR(150)
   ,HandlerRequest VARCHAR(150)
) 
AS 
BEGIN
    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate());
    
	INSERT @tblResult
    SELECT
        bob.OperationUID
       ,boh.OperationHandlerUID
       ,bob.Name
       ,bob.DtBegin AS BonusOperationDtBegin
       ,bob.IsDisabled
       ,boh.DtBegin AS BonusOperationsHandlerDtBegin
       ,boh.PointsCount
       ,boh.PointsCountMin
       ,boh.PointsCountMax
       ,boh.MethodChargeId
       ,bmc.Name AS MethodCharge
       ,boh.HandlerName
       ,boh.HandlerRequest
    FROM loyalty.BonusOperationsBook AS bob
    INNER JOIN loyalty.BonusOperationsHandlers AS boh
        ON boh.OperationUID = bob.OperationUID
    INNER JOIN loyalty.BonusMethodCharge AS bmc
        ON boh.MethodChargeId = bmc.MethodChargeId
    WHERE bob.DtBegin <= @DtBegin
        AND bob.IsDisabled = 0
        AND boh.OperationHandlerUID = loyalty.BonusOperationsCurrentHandlerUID(bob.OperationUID, @DtBegin)
    
	RETURN
END
GO