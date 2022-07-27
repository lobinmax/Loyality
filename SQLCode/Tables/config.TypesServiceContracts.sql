CREATE TABLE [config].[TypesServiceContracts] (
  [ServiceContractUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__TypesServ__Servi__71BCD978] DEFAULT (newid()),
  [PackageServiceUID] [uniqueidentifier] NOT NULL,
  [InstRelTypeID] [numeric](15) NOT NULL,
  [Name] [varchar](250) NOT NULL,
  [NameBrief] [varchar](50) NOT NULL,
  [DtCreate] [datetime2] NOT NULL CONSTRAINT [DF__TypesServ__DtCre__7EF6D905] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [DtUpdate] [datetime2] NOT NULL CONSTRAINT [DF__TypesServ__DtUpd__7FEAFD3E] DEFAULT ([dt].[GetCurrentDatetime_DF]()),
  [CreaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__TypesServ__Creat__7D0E9093] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  [UpdaterUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__TypesServ__Updat__7E02B4CC] DEFAULT ([corp-struct].[GetCurrerntUserUID_DF]()),
  CONSTRAINT [PK_TypesServiceContracts_ServiceContractUID] PRIMARY KEY CLUSTERED ([ServiceContractUID])
)
ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_TypesServiceContracts]
  ON [config].[TypesServiceContracts] ([PackageServiceUID], [NameBrief])
  ON [PRIMARY]
GO

CREATE UNIQUE INDEX [UK_TypesServiceContracts_Name]
  ON [config].[TypesServiceContracts] ([Name], [PackageServiceUID], [NameBrief])
  ON [PRIMARY]
GO

ALTER TABLE [config].[TypesServiceContracts]
  ADD CONSTRAINT [FK_TypesServiceContracts_CreaterUID] FOREIGN KEY ([CreaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

ALTER TABLE [config].[TypesServiceContracts]
  ADD CONSTRAINT [FK_TypesServiceContracts_PackageServiceUID] FOREIGN KEY ([PackageServiceUID]) REFERENCES [config].[PackageServices] ([PackageServiceUID])
GO

ALTER TABLE [config].[TypesServiceContracts]
  ADD CONSTRAINT [FK_TypesServiceContracts_UpdaterUID] FOREIGN KEY ([UpdaterUID]) REFERENCES [corp-struct].[Users] ([UserUID])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Внешний идентификатор Диасофта из таблицы с договорами обслуживания tInstRelType', 'SCHEMA', N'config', 'TABLE', N'TypesServiceContracts', 'COLUMN', N'InstRelTypeID'
GO