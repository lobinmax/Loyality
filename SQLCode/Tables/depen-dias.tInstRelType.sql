CREATE TABLE [depen-dias].[tInstRelType] (
  [InstRelTypeID] [numeric](15) NOT NULL,
  [Name] [varchar](60) NOT NULL,
  [Brief] [varchar](10) NOT NULL,
  [ParentName] [varchar](40) NOT NULL,
  [ParentProperty] [tinyint] NOT NULL,
  [ChildName] [varchar](40) NOT NULL,
  [ChildProperty] [tinyint] NOT NULL,
  [DocName] [varchar](60) NOT NULL,
  [DocAttr1] [varchar](40) NOT NULL,
  [DocAttr2] [varchar](40) NOT NULL,
  [DocAttr3] [varchar](40) NOT NULL,
  [DocAttr4] [varchar](40) NOT NULL,
  [DocAttr5] [varchar](40) NOT NULL,
  [DocAttr6] [varchar](40) NOT NULL,
  [SystemFlag] [tinyint] NOT NULL,
  [SystemNumber] [numeric](15) NOT NULL,
  [DepartmentID] [numeric](15) NOT NULL,
  [Comment] [varchar](255) NOT NULL,
  CONSTRAINT [PK_tInstRelType_InstRelTypeID] PRIMARY KEY CLUSTERED ([InstRelTypeID])
)
ON [PRIMARY]
GO