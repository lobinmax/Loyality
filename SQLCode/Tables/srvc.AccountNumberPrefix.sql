CREATE TABLE [srvc].[AccountNumberPrefix] (
  [CurrentPrefix] [varchar](10) NOT NULL,
  [OrdinalNumber] [int] NOT NULL DEFAULT (1)
)
ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE TRIGGER [srvc].[tgrAccountNumberPrefix_Insert]
ON [srvc].[AccountNumberPrefix]
AFTER INSERT
AS
BEGIN
    
    DECLARE @msg VARCHAR(MAX) = 'Insert в таблицу "[srvc].[tgrAccountNumberPrefix_Insert] запрещен"';
    THROW 50001, @msg, 1;
    ROLLBACK;
END
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Префикс для генерации номера бонусного счета', 'SCHEMA', N'srvc', 'TABLE', N'AccountNumberPrefix'
GO