SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 2021-05-20
-- Create time:	16:32:14
-- Description:	ХП управляет пользователями
-- =============================================
CREATE PROCEDURE [corp-struct].[UsersCRUD]
	@UserUID UNIQUEIDENTIFIER = NULL, 
	@Login VARCHAR(100),
	@Password VARCHAR(100),
	@LastName VARCHAR(100),
	@FirstName VARCHAR(100),
	@Patronymic VARCHAR(100),
	@DeportamentUID UNIQUEIDENTIFIER,
	@Phone VARCHAR(50),
	@PhoneMobile VARCHAR(50),
	@DateDismissal DATE = NULL,
	@IsLocked BIT = NULL,
    @Function INT = 0
AS 
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

    IF @Function = 0 -- select
    BEGIN
        RETURN
    END 
    
    IF @Function = 1 -- insert
    BEGIN
        BEGIN TRANSACTION

        SET @UserUID = COALESCE(@UserUID, NEWID());        
		DECLARE @Role AS VARCHAR(100) = CAST(config.ParametersGetValue('Роль для сотрудников по-умолчанию', DEFAULT, DEFAULT) AS VARCHAR(100))
		DECLARE @cmd AS NVARCHAR(MAX)

		SET @cmd = 
			'CREATE LOGIN ['+ @Login +'] WITH ' +
			'PASSWORD = ''' + @Password + ''', '+
			'DEFAULT_DATABASE = [' + DB_NAME() + '], ' +
			'DEFAULT_LANGUAGE = [US_ENGLISH], ' +
			'CHECK_EXPIRATION = OFF, ' +
			'CHECK_POLICY = OFF';
		EXEC sp_executesql @cmd = @cmd

		IF @@ERROR <> 0 
		BEGIN 
			ROLLBACK TRANSACTION 
			RETURN NULL 
		END 

		EXEC sp_addrolemember 
			@rolename = @Role, 
			@membername = @login
	
		IF @@ERROR <> 0 
		BEGIN 
			ROLLBACK TRANSACTION 
			RETURN NULL 
		END 	

		SET @cmd =
			'CREATE USER [' + @login + '] FOR LOGIN [' + @login + '] WITH DEFAULT_SCHEMA = [dbo]'
		EXEC sp_executesql @cmd = @cmd;

		INSERT [corp-struct].Users
		(
		    UserUID,
		    Login,
		    LastName,
		    FirstName,
		    Patronymic,
		    DeportamentUID,
		    Phone,
		    PhoneMobile,
		    DateDismissal, 
		    IsLocked
		)
		VALUES
		(   
			@UserUID,
		    @Login,  
		    @LastName, 
		    @FirstName,
		    @Patronymic,
		    @DeportamentUID,
		    @Phone,
		    @PhoneMobile,
		    @DateDismissal,
			@IsLocked
		)

        COMMIT TRANSACTION
    END 
    
    IF @Function = 2 -- update
    BEGIN
        RETURN
    END 
    
    IF @Function = 3 -- delete
    BEGIN
        RETURN
    END 

END
GO