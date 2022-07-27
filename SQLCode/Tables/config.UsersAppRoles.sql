CREATE TABLE [config].[UsersAppRoles] (
  [AppRoleId] [int] NOT NULL,
  [Name] [varchar](50) NOT NULL,
  CONSTRAINT [PK_UsersAppRoles] PRIMARY KEY CLUSTERED ([AppRoleId])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_UsersAppRoles_Name]
  ON [config].[UsersAppRoles] ([Name])
  ON [PRIMARY]
GO