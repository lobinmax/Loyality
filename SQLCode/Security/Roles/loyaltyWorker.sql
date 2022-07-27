CREATE ROLE [loyaltyWorker]
GO

EXEC sp_addrolemember N'loyaltyWorker', N'jobRobot'
GO

EXEC sp_addrolemember N'loyaltyWorker', N'LoaderII'
GO

EXEC sp_addrolemember N'loyaltyWorker', N'loyalty'
GO

EXEC sp_addrolemember N'loyaltyWorker', N'pvv'
GO