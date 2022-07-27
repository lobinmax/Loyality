SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 29.06.2021
-- Create time:	14:26
-- Description:	<ХП возвращает внешний ИД клиента 
-- напрямую из диасофта>
-- =============================================
CREATE PROCEDURE [depen-dias].[GetClientIdByINN] 
(
	@INN VARCHAR(50),
	@ClientId NUMERIC(15) OUTPUT
)
AS
BEGIN 
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @tResult TABLE 
	(
		ClientId NUMERIC(15) NOT NULL
	);
	DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
	DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
	DECLARE @cmd AS NVARCHAR(MAX) = 
		'SELECT 
			r.InstOwnerID 
		FROM ' + @lnk + '.' + @DbName + '.dbo.tInstitution AS i
		INNER JOIN ' + @lnk + '.' + @DbName + '.dbo.tResource AS r
			ON i.InstitutionID = r.InstOwnerID
		WHERE i.INN = ''' + @INN + '''
		GROUP BY r.InstOwnerID'

	INSERT INTO @tResult
	EXEC sys.sp_executesql @stmt = @cmd

	SELECT @ClientId = tr.ClientId FROM @tResult AS tr
END
GO