SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[debugSetPoint]
    @id INT = NULL,
    @val_1 SQL_VARIANT = NULL,
    @val_2 SQL_VARIANT = NULL,
    @val_3 SQL_VARIANT = NULL,
    @val_4 SQL_VARIANT = NULL
AS 
BEGIN
	BEGIN TRANSACTION
        INSERT INTO debug (id, val_1, val_2, val_3, val_4)
        VALUES (@id, @val_1, @val_2, @val_3, @val_4);
    COMMIT TRANSACTION
END
GO