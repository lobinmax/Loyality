SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:	Lobin A. Max
-- Create date: 02.07.2021
-- Create time:	17:35
-- Description:	<Ф-ция возвращает PointsCount обработчика 
-- бонусной операции>
-- =============================================
CREATE FUNCTION [loyalty].[BonusOperHandGetPointCount]
(
	@OperationHandlerUID UNIQUEIDENTIFIER
)
RETURNS MONEY
AS
BEGIN
	DECLARE @PointsCount MONEY = 
    (
        SELECT PointsCount 
        FROM loyalty.BonusOperationsHandlers 
        WHERE OperationHandlerUID = @OperationHandlerUID
    )

	RETURN @PointsCount;

END
GO