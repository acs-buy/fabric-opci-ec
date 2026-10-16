
-- 1.5 : les pieces retirees, une ligne par RETRAIT du journal.
CREATE   VIEW dbo.v_ecran_pieces_retirees AS
SELECT j.entite, j.piece_id, j.arrete, j.fait_le, j.entite + '|' + CAST(j.id AS VARCHAR (10)) AS cle_ecran,
       j.nom_fichier AS [Fichier], j.question AS [Question], dbo.fn_date_ecran(j.arrete) AS [Arrêté], j.motif AS [Motif du retrait],
       dbo.fn_nom_personne_ecran(j.entite, j.fait_par) AS [Retirée par],
       CONVERT(NVARCHAR (10), j.fait_le, 103) + N' ' + LEFT(CONVERT(NVARCHAR (8), j.fait_le, 108), 5) + N' UTC' AS [Retirée le]
FROM dbo.journal_piece j
WHERE j.action = 'RETRAIT';

GO

