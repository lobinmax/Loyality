SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 25.05.2021
-- Create time:	10:17
-- Description:	ХП генерирует очередной уникальный 
-- номер бонусного счета
-- =============================================
CREATE PROCEDURE [loyalty].[AccountGetNextNumber]
    @DidvisionPrefix VARCHAR(10),
    @NextAccountNumber VARCHAR(15) OUTPUT
AS 
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    BEGIN TRANSACTION;
        
        DECLARE @OrdinalNumber AS INT
        DECLARE @OrdinalPrefix AS VARCHAR(4) = 
            CAST(FORMAT(dt.GetCurrentDate(), 'yy', 'en-US') AS VARCHAR(2)) + 
            CAST(FORMAT(dt.GetCurrentDate(), 'MM', 'en-US') AS VARCHAR(2));
        
        DECLARE @CurentPrefix AS VARCHAR(4) 
        DECLARE @CurentNumber AS INT
        SELECT TOP(1) 
            @CurentPrefix = anp.CurrentPrefix, 
            @CurentNumber = anp.OrdinalNumber 
        FROM srvc.AccountNumberPrefix anp 

        IF (@CurentPrefix = @OrdinalPrefix)
        BEGIN
            SET @OrdinalNumber = @CurentNumber + 1
            UPDATE srvc.AccountNumberPrefix 
            SET OrdinalNumber = @OrdinalNumber 
        END
        ELSE 
        BEGIN 
            UPDATE srvc.AccountNumberPrefix 
            SET CurrentPrefix = @OrdinalPrefix, 
                OrdinalNumber = 0 

            EXEC loyalty.AccountGetNextNumber 
                @DidvisionPrefix, 
                @NextAccountNumber OUTPUT

            COMMIT TRANSACTION;
            RETURN 0;
        END 

    COMMIT TRANSACTION;
    
    SET @NextAccountNumber = 
        @OrdinalPrefix + @DidvisionPrefix + RIGHT('0000' + CAST(@OrdinalNumber AS VARCHAR(10)), 4);
    RETURN 0;
END 
GO