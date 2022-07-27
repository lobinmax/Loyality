SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 12.07.2021
-- Create time:	17:30
-- Description:	Ф-ция возвращает текущее кол-во баллов на бонусном счете
-- на указанную дату
-- =============================================
CREATE FUNCTION [loyalty].[BonusGetCountByAcoount]
(
    @BonusAccountUID UNIQUEIDENTIFIER,
    @DtBegin DATE = NULL
)
RETURNS INT
AS
BEGIN
    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate());
    DECLARE @BonusCount INT = 
    (
        SELECT SUM(bt.AccruedBonuses) 
        FROM [bonus-charge].BonusTransactions AS bt
        INNER JOIN [bonus-charge].BonusTransactionsBase AS btb
            ON btb.TransactionUID = bt.TransactionUID
        WHERE bt.BonusAccountUID = @BonusAccountUID
            AND bt.DtTrasaction <= @DtBegin
            AND btb.IsCanceled = 0
    )

    RETURN ISNULL(@BonusCount, 0)
END
GO