CREATE TABLE [config].[PackageServices] (
  [PackageServiceUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__PackageSe__Packa__664B26CC] DEFAULT (newid()),
  [PackageServiceParentUID] [uniqueidentifier] NULL,
  [Name] [varchar](250) NOT NULL,
  [Description] [varchar](max) NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__PackageSe__DtCre__00DF2177] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__PackageSe__DtUpd__01D345B0] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__PackageSe__Creat__793DFFAF] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__PackageSe__Updat__7A3223E8] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_PackageServices_PackageServiceUID] PRIMARY KEY CLUSTERED ([PackageServiceUID])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_PackageServices_Name]
  ON [config].[PackageServices] ([Name])
  ON [PRIMARY]
GO

ALTER TABLE [config].[PackageServices]
  ADD CONSTRAINT [FK_PackageServices_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [config].[PackageServices]
  ADD CONSTRAINT [FK_PackageServices_PackageServiceParentUID] FOREIGN KEY ([PackageServiceParentUID]) REFERENCES [config].[PackageServices] ([PackageServiceUID])
GO

ALTER TABLE [config].[PackageServices]
  ADD CONSTRAINT [FK_PackageServices_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Пакеты и подпакеты услуг', 'SCHEMA', N'config', 'TABLE', N'PackageServices'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Наименование пакета услуг', 'SCHEMA', N'config', 'TABLE', N'PackageServices', 'COLUMN', N'Name'
GO