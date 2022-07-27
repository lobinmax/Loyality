SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-26
-- Create time:	14:43:55
-- Description:	Ф-ция возвращает UID обработчика по 
-- определнной бонусной операции на указанную дату
-- =============================================
CREATE FUNCTION [loyalty].[BonusOperationsCurrentHandlerUID]
(
    @OperationUID UNIQUEIDENTIFIER,
    @DtBegin DATE = NULL
)
RETURNS UNIQUEIDENTIFIER
BEGIN
	
    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate())

    DECLARE @DtBeginMax DATE = 
    (
        SELECT TOP (1)
            boh.DtBegin
        FROM loyalty.BonusOperationsHandlers AS boh
        WHERE boh.OperationUID = @OperationUID
            AND boh.DtBegin <= @DtBegin
        ORDER BY boh.DtBegin DESC
    )
    
    RETURN 
    (
        SELECT boh.OperationHandlerUID 
        FROM loyalty.BonusOperationsHandlers AS boh 
        WHERE boh.OperationUID = @OperationUID 
            AND boh.DtBegin = @DtBeginMax
    )
    
END
GO