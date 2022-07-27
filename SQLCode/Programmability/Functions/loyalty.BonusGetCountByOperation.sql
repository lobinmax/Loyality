SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-28
-- Create time:	16:04:37
-- Description:	Ф-ция вычисляет общее кол-во начисленных баллов по 
-- определенной бонусной операции на бонусном счете в периоде
-- =============================================
CREATE FUNCTION [loyalty].[BonusGetCountByOperation]
(
    @BonusAccountUID UNIQUEIDENTIFIER,
    @BonusOperationUID UNIQUEIDENTIFIER,
    @DtDegin DATE = NULL
)
RETURNS INT
BEGIN
    SET @DtDegin = COALESCE(@DtDegin, dt.GetCurrentDate())
    DECLARE @PeriodNumber INT = YEAR(@DtDegin) * 100 + MONTH(@DtDegin)
	DECLARE @AccruedBonuses INT = 
    (
        SELECT SUM(bt.AccruedBonuses)
        FROM [bonus-charge].BonusTransactionsBase AS btb
        INNER JOIN [bonus-charge].BonusTransactions AS bt
            ON btb.TransactionUID = bt.TransactionUID
        WHERE btb.IsCanceled = 0
            AND btb.OperationUID = @BonusOperationUID
            AND bt.BonusAccountUID = @BonusAccountUID
            AND bt.PeriodNumber = @PeriodNumber
            AND bt.DtTrasaction <= @DtDegin
    )
    RETURN ISNULL(@AccruedBonuses, 0)
END

GO