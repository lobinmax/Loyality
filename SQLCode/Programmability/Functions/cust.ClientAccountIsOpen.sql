SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-06-15
-- Create time:	10:38:33
-- Description:	Ф-ция определяет действует ли счет на дату
-- =============================================
CREATE FUNCTION [cust].[ClientAccountIsOpen] 
(
    @AccountUID UNIQUEIDENTIFIER,
    @Dt DATE = NULL
)
RETURNS BIT 
AS
BEGIN
	SET @Dt = COALESCE(@Dt, dt.GetCurrentDate())    
    DECLARE @Result AS BIT = 0;

    IF EXISTS (SELECT *
               FROM cust.ClientAccounts AS ca
               WHERE ca.AccountUID = @AccountUID
                    AND (ca.DtClose IS NULL OR ca.DtClose > @Dt)
                    AND ca.DtOpen <= @Dt)
    BEGIN
        SET @Result = 1
    END

    RETURN @Result 
END
GO