SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 12.07.2021
-- Create time:	16:52
-- Description:	<ХП отключает клиента от программы лояльности>
-- =============================================
CREATE PROCEDURE [loyalty].[LoyaltyDisconnect] 
    @ClientIdExternal NUMERIC(15),
    @ReasonClosingId INT = 0,
    @CodeResult INT = 0 OUTPUT
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRANSACTION

        DECLARE @msg AS VARCHAR(MAX);
        DECLARE @CurrentBonusAccountUID UNIQUEIDENTIFIER = loyalty.BonusАccountGetCurrentUID(cust.GetClientUIDByClientId(@ClientIdExternal), DEFAULT)

        IF @CurrentBonusAccountUID IS NULL
        BEGIN  
            SET @msg = 'У клиента не найдены действующие бонусные счета. Внешний ИД клиента: "' + CAST(@ClientIdExternal AS VARCHAR(50)) + '"';
            SET @CodeResult = 1;
            THROW 50001, @msg, 1;
            ROLLBACK TRANSACTION;
            RETURN 0;        
        END 

        UPDATE cbа
        SET cbа.DtClose = dt.GetCurrentDate(),
            cbа.ReasonClosingId = @ReasonClosingId
        FROM loyalty.ClientBonusАccounts AS cbа
        WHERE cbа.BonusAccountUID = @CurrentBonusAccountUID

        EXEC [bonus-charge].AnnulBonus_All @BonusAccountUID = @CurrentBonusAccountUID, -- uniqueidentifier
                                           @DocumentTypeId = 6,
                                           @Description = 'Аннулирование бонусов в связи с выходом из программы лояльности'
                
    COMMIT TRANSACTION
END
GO