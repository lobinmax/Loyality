SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      Lobin A. Max
-- Create date: 28.07.2021
-- Create time:	15:21
-- Description:	ХП управления журналом выполнения заданий
-- @Function: 0 - запись в лог, 1 - обновление записи в логе
-- =============================================
CREATE PROCEDURE [logs].[ExecutingJobsMisc]
    @JobExecutingUID UNIQUEIDENTIFIER,
    @JobName VARCHAR(500) = NULL,
    @DtBegin DATETIME2 = NULL,
    @DtEnd DATETIME2 = NULL,
    @Result VARCHAR(500),
    @Description VARCHAR(MAX) = NULL,

    @Function INT
AS 
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;  

    IF @Function = 0 -- запись в лог
    BEGIN        
        INSERT INTO logs.ExecutingJobs
        (
            JobExecutingUID,
            JobName,
            DtBegin,
            Result,
            Description
        )
        VALUES
        (   
            @JobExecutingUID,
            str.Trim(@JobName),
            COALESCE(@DtBegin, dt.GetCurrentDatetime()), 
            str.Trim(@Result),
            str.Trim(@Description)
        )
    END 

    IF @Function = 1 -- обновление записи в логе
    BEGIN 
        DECLARE @DescriptionPrev VARCHAR(MAX) = 
        (
            SELECT ej.Description 
            FROM logs.ExecutingJobs AS ej 
            WHERE ej.JobExecutingUID = @JobExecutingUID
        )
        SET @Description = COALESCE(str.Trim(@Description), @DescriptionPrev);

        UPDATE logs.ExecutingJobs
        SET DtEnd = COALESCE(@DtEnd, dt.GetCurrentDatetime()),
            Result = str.Trim(@Result),
            Description = @Description
        WHERE JobExecutingUID = @JobExecutingUID
    END 
END
GO