CREATE TABLE [logs].[ExecutingJobs] (
  [JobExecutingUID] [uniqueidentifier] NULL,
  [JobName] [varchar](250) NOT NULL,
  [DtBegin] [datetime2] NOT NULL DEFAULT ([dt].[GetCurrentDatetime]()),
  [DtEnd] [datetime2] NULL,
  [Result] [varchar](250) NOT NULL,
  [Description] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Логирование выполнения заданий (jobs)', 'SCHEMA', N'logs', 'TABLE', N'ExecutingJobs'
GO