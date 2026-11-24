-- --- 1 ---------------------------------------------------------------------------------------------
-- 1.5 : les pieces retirees, une ligne par RETRAIT du journal.
-- : fait_le et [Retirée le] a l'heure de Paris, heure d'ete comprise ; « UTC » retire du texte.
CREATE   VIEW dbo.v_ecran_pieces_retirees AS
SELECT j.entite, j.piece_id, j.arrete, h.fait_le, j.entite + '|' + CAST(j.id AS VARCHAR (10)) AS cle_ecran,
       j.nom_fichier AS [Fichier], j.question AS [Question], dbo.fn_date_ecran(j.arrete) AS [Arrêté], j.motif AS [Motif du retrait],
       dbo.fn_nom_personne_ecran(j.entite, j.fait_par) AS [Retirée par],
       CAST(CONVERT(NVARCHAR (10), h.fait_le, 103) + N' ' + LEFT(CONVERT(NVARCHAR (8), h.fait_le, 108), 5) AS NVARCHAR (20)) AS [Retirée le]
FROM dbo.journal_piece j
CROSS APPLY (SELECT ISNULL(CAST(j.fait_le AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0)), j.fait_le) AS fait_le) h
WHERE j.action = 'RETRAIT';

GO

