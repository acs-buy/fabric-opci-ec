CREATE   PROCEDURE dbo.pr_fin_semis
AS
BEGIN
    SET NOCOUNT ON;
    EXEC sp_set_session_context @key = N'semis', @value = 0;
END;

GO

