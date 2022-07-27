SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-20
-- Create time:	19:27:29
-- Description:	Функция возвращает значение параметра
-- =============================================
CREATE FUNCTION [config].[ParametersGetValue] 
(
    @ParameterName VARCHAR(600),
    @UserUID UNIQUEIDENTIFIER = NULL,
    @DtBegin DATE = NULL
)
RETURNS SQL_VARIANT
BEGIN     

    DECLARE @Result SQL_VARIANT
    DECLARE @ParametrValueForUser AS SQL_VARIANT
    DECLARE @ParametrValueForDivision AS SQL_VARIANT
    DECLARE @UsersDeportamentUID AS UNIQUEIDENTIFIER

    SET @DtBegin = COALESCE(@DtBegin, dt.GetCurrentDate())
    SET @UserUID = COALESCE(@UserUID, [corp-struct].GetCurrerntUserUID()) 
	SET @UsersDeportamentUID = [corp-struct].GetCurrentUsersDeportamentUID(DEFAULT)

    -- получить значение для пользователя
    SET @ParametrValueForUser = 
    (
        SELECT TOP(1) pv.ParameterValue
        FROM config.ParametersValue pv
        INNER JOIN config.Parameters p 
            ON pv.ParameterUID = p.ParameterUID
        WHERE p.Name = @ParameterName 
            AND pv.СriteriaUserUID = @UserUID
        ORDER BY pv.DtBegin DESC
    )
    
    -- получить значение для ВСП
    DECLARE @level INT
    DECLARE @parent UNIQUEIDENTIFIER 
    SELECT 
        @level = dt.PermissionsLevel, 
        @parent = d.DivisionUID
    FROM [corp-struct].Divisions d
    INNER JOIN config.DivisionsTypes dt 
        ON d.DivisionTypeId = dt.DivisionTypeId
    WHERE d.DivisionUID = @UsersDeportamentUID
    
	-- получить ВСП родителей для ВСП сотрудника
    DECLARE @ParentDivisionUID AS TABLE(DivisionUID UNIQUEIDENTIFIER NOT NULL) 
    WHILE @level >= 0 BEGIN  
        INSERT INTO @ParentDivisionUID
        SELECT d.DivisionUID
        FROM [corp-struct].Divisions d
        WHERE d.DivisionUID = @parent

        SET @parent = 
        (
            SELECT TOP(1) d.DivisionParentUID 
            FROM [corp-struct].Divisions d 
            WHERE d.DivisionUID = @parent 
			ORDER BY d.DivisionParentUID 
        )
        SET @level = @level - 1
    END
    
    SET @ParametrValueForDivision = 
    (
        SELECT TOP(1) pv.ParameterValue
        FROM config.ParametersValue pv
        INNER JOIN config.Parameters p 
			ON pv.ParameterUID = p.ParameterUID
		INNER JOIN @ParentDivisionUID AS pd 
			ON pv.СriteriaDivisionUID = pd.DivisionUID
        WHERE p.Name = @ParameterName  
        ORDER BY pv.DtBegin DESC
    )    
    
    SET @Result = COALESCE(@ParametrValueForUser, @ParametrValueForDivision);
    IF @Result IS NULL
    BEGIN
        DECLARE @i INT = CAST('Не удалось определить значение параметра "' + @ParameterName + '"' AS INT) 
    END 

    RETURN @Result;
END
GO