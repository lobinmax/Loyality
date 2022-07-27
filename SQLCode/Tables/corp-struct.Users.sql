CREATE TABLE [corp-struct].[Users] (
  [UserUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Users__UserUID__38996AB5] DEFAULT (newid()),
  [Login] [varchar](50) NOT NULL,
  [LastName] [varchar](50) NOT NULL,
  [FirstName] [varchar](50) NOT NULL,
  [Patronymic] [varchar](50) NOT NULL,
  [DeportamentUID] [uniqueidentifier] NOT NULL,
  [PositionId] [int] NOT NULL,
  [Phone] [varchar](25) NULL,
  [PhoneMobile] [varchar](25) NULL,
  [DateDismissal] [date] NULL,
  [AppRoleId] [int] NOT NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__Users__DtCreate__04AFB25B] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__Users__DtUpdate__05A3D694] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Users__CreaterUI__681373AD] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__Users__UpdaterUI__690797E6] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [IsLocked] [bit] NULL CONSTRAINT [DF__Users__IsLocked__398D8EEE] DEFAULT (CONVERT([bit],(0))),
  CONSTRAINT [PK_Users_UserUID] PRIMARY KEY CLUSTERED ([UserUID])
)
ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [corp-struct].[tgrUsers_InsertUpdate]
ON [corp-struct].[Users]
AFTER INSERT, UPDATE
AS
IF (UPDATE (DeportamentUID))  
BEGIN
	
    DECLARE @msg AS VARCHAR(MAX)
    DECLARE @DeportamentUID AS UNIQUEIDENTIFIER

    IF NOT EXISTS (SELECT * 
                   FROM INSERTED AS ins 
                   INNER JOIN [corp-struct].Divisions d
                        ON ins.DeportamentUID = d.DivisionUID
                   INNER JOIN config.DivisionsTypes dt 
                        ON d.DivisionTypeId = dt.DivisionTypeId 
                   WHERE dt.NameFull = 'Департамент')  
     BEGIN   
        SET @msg = 'Неверно заполнено поле наименования Депортамента (DeportamentUID). Выбран неверный уровень узла.';
        THROW 50001, @msg, 1;

        ROLLBACK
    END  
END
GO

ALTER TABLE [corp-struct].[Users]
  ADD CONSTRAINT [FK_Users_AppRoleId] FOREIGN KEY ([AppRoleId]) REFERENCES [config].[UsersAppRoles] ([AppRoleId])
GO

ALTER TABLE [corp-struct].[Users]
  ADD CONSTRAINT [FK_Users_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [corp-struct].[Users]
  ADD CONSTRAINT [FK_Users_DeportamentUID] FOREIGN KEY ([DeportamentUID]) REFERENCES [corp-struct].[Divisions] ([DivisionUID])
GO

ALTER TABLE [corp-struct].[Users]
  ADD CONSTRAINT [FK_Users_PositionId] FOREIGN KEY ([PositionId]) REFERENCES [corp-struct].[Positions] ([PositionId])
GO

ALTER TABLE [corp-struct].[Users]
  ADD CONSTRAINT [FK_Users_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Пользователи базы данных', 'SCHEMA', N'corp-struct', 'TABLE', N'Users'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', '1 - пользователь заблокирован; 0 - пользователь активен', 'SCHEMA', N'corp-struct', 'TABLE', N'Users', 'COLUMN', N'IsLocked'
GO