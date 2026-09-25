
CREATE   VIEW dbo.v_ecran_journal_visa AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[horodatage], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[nature], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[objet_ref], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[genre], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[issue], 121), N'') AS cle_ecran, v.*
FROM dbo.v_journal_visa v;

GO

