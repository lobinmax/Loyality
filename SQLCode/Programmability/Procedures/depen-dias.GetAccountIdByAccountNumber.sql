SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 29.06.2021
-- Create time:	14:26
-- Description:	<ХП возвращает внешний ИД банковского счета 
-- напрямую из диасофта по номеру счета>
-- =============================================
CREATE PROCEDURE [depen-dias].[GetAccountIdByAccountNumber] 
(
	@AccountNumber VARCHAR(100),
	@AccountId NUMERIC(15) OUTPUT
)
AS
BEGIN 
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @tResult TABLE 
	(
		AccountId NUMERIC(15) NOT NULL
	);
	DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
	DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
	DECLARE @cmd AS NVARCHAR(MAX) = 
		'SELECT 
			r.ResourceID 
		FROM ' + @lnk + '.' + @DbName + '.dbo.tResource AS r
		WHERE r.Brief = ''' + @AccountNumber + ''''

	INSERT INTO @tResult
	EXEC sys.sp_executesql @stmt = @cmd

	SELECT @AccountId = tr.AccountId FROM @tResult AS tr
END
GO