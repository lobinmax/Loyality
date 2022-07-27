SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-28
-- Create time:	18:11:59
-- Description:	Процедура основного базового расчета бонусов
-- по всем активным бонусным операциям
-- Выполняется каждый день в 03-00 (2-ым шагом)
-- =============================================
CREATE PROCEDURE [bonus-charge].[BonusBasicCalculation_Job]
    @Dt DATE = NULL
AS 
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON

    IF CAST(config.ParametersGetValue('Job - Расчет баллов по основным бонусным операциям (вкл/выкл)', DEFAULT, DEFAULT) AS BIT) = 0
    BEGIN
        RETURN 0
    END

    IF @Dt IS NOT NULL AND 
       EXISTS (SELECT * 
               FROM [bonus-charge].BonusCalculateHistory AS bch 
               WHERE bch.DtAppeal = @Dt)
    BEGIN
        RETURN 0
    END 

    DECLARE @msg AS VARCHAR(MAX);
    DECLARE @Description AS VARCHAR(MAX);
    DECLARE @LogExecutingUID UNIQUEIDENTIFIER;
    DECLARE @lnk AS VARCHAR(50) = config.ParametersLinkDiasoft();
    DECLARE @DbName AS VARCHAR(50) = config.ParametersDBnameDiasoft();
    DECLARE @cmd AS NVARCHAR(MAX) =
        'EXEC ' + @lnk + '.' + @DbName + '.[dbo].[_avs_GetLoyaltyDayStatus]';

    CREATE TABLE #StatusDaysDias 
    (
		Date DATE,
		IsСlosed BIT
    )
    INSERT INTO #StatusDaysDias
    EXEC sys.sp_executesql @stmt = @cmd
		
	CREATE TABLE #BonusAccounts
	(
		BonusAccountUID UNIQUEIDENTIFIER,
		ClientUID UNIQUEIDENTIFIER,
		AccountIdExternal NUMERIC(15),
		AccountNumber VARCHAR(50),
		DtOpen DATE
	)
	
	CREATE TABLE #NewTransactions 
	(
		TransactionUID UNIQUEIDENTIFIER DEFAULT NEWID(),
		DtTrasaction DATE,
		ClientUID UNIQUEIDENTIFIER,
		BonusAccountUID UNIQUEIDENTIFIER,
		AccruedBonuses INT,
		DocumentTypeId INT,
		Description VARCHAR(MAX)
	)
    	
	DECLARE @DtSourse DATE
	DECLARE crsrDt CURSOR READ_ONLY LOCAL 
	FOR
		SELECT stD.Date
		FROM #StatusdaysDias AS stD
		WHERE NOT EXISTS 
			(
				SELECT * 
				FROM [bonus-charge].BonusCalculateHistory AS bch 
				WHERE bch.DtAppeal = stD.Date
			)
			AND stD.IsСlosed = 1
            AND stD.Date >= CAST(config.ParametersGetValue('Дата начала расчетов лояльности', DEFAULT, DEFAULT) AS DATE)
        AND @Dt IS NULL OR stD.Date = @Dt
		ORDER BY stD.Date
            
	OPEN crsrDt
	FETCH NEXT FROM crsrDt INTO 
		@DtSourse

	WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @Description = 'Расчет бонусов за ' + FORMAT(@DtSourse, 'dd.MM.yyyy');
        SET @LogExecutingUID = NEWID();
        EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID, 
                                @JobName = '[bonus-charge].[BonusBasicCalculation_Job]',
                                @DtBegin = DEFAULT,
                                @Description = @Description,
                                @Result = 'Задание не выполнено',
                                @Function = 0
        BEGIN TRANSACTION

		TRUNCATE TABLE #BonusAccounts
			
		INSERT INTO [bonus-charge].BonusCalculateHistory
		( DtAppeal )
		VALUES
		( @DtSourse )

		INSERT INTO #BonusAccounts
		SELECT
			cbа.BonusAccountUID,
			cbа.ClientUID,
			ca.AccountIdExternal,
			cbа.AccountNumber,
			cbа.DtOpen  
		FROM loyalty.ClientBonusАccounts AS cbа
		INNER JOIN cust.ClientAccounts AS ca
			ON ca.ClientUID = cbа.ClientUID
		WHERE loyalty.BonusАccountIsActive(cbа.BonusAccountUID, @DtSourse) = 1
			AND cust.ClientAccountIsOpen(ca.AccountUID, @DtSourse) = 1

			DECLARE @crsrOperationHandlerUID UNIQUEIDENTIFIER
			DECLARE @crsrHandlerRequest VARCHAR(150)
			DECLARE @crsrHandlerName VARCHAR(150)
			DECLARE @crsrBonusOperationName VARCHAR(100)
			DECLARE crsr CURSOR READ_ONLY LOCAL 
			FOR
				SELECT
					boch.OperationHandlerUID,
					boch.HandlerRequest,
					boch.HandlerName,
					boch.BonusOperationName
				FROM loyalty.BonusOperationsCurrentHandler(DEFAULT) AS boch

			OPEN crsr
			FETCH NEXT FROM crsr INTO
				@crsrOperationHandlerUID,
				@crsrHandlerRequest,
				@crsrHandlerName,
				@crsrBonusOperationName

			WHILE @@FETCH_STATUS = 0
			BEGIN
				TRUNCATE TABLE #NewTransactions
                
				-- вызов обработчика
                EXECUTE AS LOGIN = 'lobin';
				IF NOT EXISTS (SELECT *
                                FROM sys.objects AS o
                                INNER JOIN sys.schemas AS s
	                                ON o.schema_id = s.schema_id
                                WHERE '' + QUOTENAME(s.name) + '.' + QUOTENAME(o.name) + '' = @crsrHandlerName)
				BEGIN
                    REVERT;

					SET @msg = 'Ошибка начисления бонусов. Не найден обработчик для бонусных операций типа "' + @crsrBonusOperationName + '", 
    							имя обработчика: "' + @crsrHandlerName + '"';
					THROW 50001, @msg, 1;
					IF (@@TRANCOUNT <> 0)
					BEGIN
						ROLLBACK TRANSACTION
					END
					RETURN 0
				END
                REVERT;

				SET @cmd = @crsrHandlerRequest +
					'@DtStart = ''' + CAST(@DtSourse AS VARCHAR(50)) + ''', 
    				    @DtEnd = ''' + CAST(@DtSourse AS VARCHAR(50)) + ''', 
					    @OperationHandlerUID = ''' + CAST(@crsrOperationHandlerUID AS VARCHAR(100)) + '''';
				EXEC sys.sp_executesql @stmt = @cmd

				FETCH FROM crsr INTO
					@crsrOperationHandlerUID,
					@crsrHandlerRequest,
					@crsrHandlerName,
					@crsrBonusOperationName
			END
			CLOSE crsr
			DEALLOCATE crsr

		FETCH FROM crsrDt INTO @DtSourse

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION
    END
	COMMIT TRANSACTION
    EXEC logs.ExecutingJobsMisc @JobExecutingUID = @LogExecutingUID,
                                @DtEnd = DEFAULT,
                                @Result = 'Задание успешно выполнено',
                                @Function = 1

	END 
	CLOSE crsrDt
	DEALLOCATE crsrDt            

	DROP TABLE #StatusdaysDias
	DROP TABLE #BonusAccounts
	DROP TABLE #NewTransactions
END
GO