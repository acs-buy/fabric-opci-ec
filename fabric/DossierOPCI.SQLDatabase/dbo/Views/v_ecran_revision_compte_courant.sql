-- --- les revisions de compte courant ---------------------------------------------------------------------------------------------
-- La table revision_compte_courant telle quelle, saisi_le a l'heure de Paris, heure d'ete comprise.
-- La table du modele revision_compte_courant lit cette vue :
-- memes colonnes, meme ordre, memes types.
CREATE VIEW dbo.v_ecran_revision_compte_courant AS
SELECT r.id, r.entite, r.arrete, r.entite_fille, r.compte, r.montant_nominal, r.montant_revise, r.motif, r.saisi_par,
       ISNULL(CAST(r.saisi_le AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (3)), r.saisi_le) AS saisi_le
FROM dbo.revision_compte_courant r;

GO

