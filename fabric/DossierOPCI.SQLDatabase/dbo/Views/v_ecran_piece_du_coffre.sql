
CREATE   VIEW dbo.v_ecran_piece_du_coffre AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[piece_id], 121), N'') AS cle_ecran, v.*
FROM dbo.v_piece_du_coffre v;

GO

