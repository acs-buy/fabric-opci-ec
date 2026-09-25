
CREATE VIEW dbo.v_famille_actif AS
SELECT f.famille, f.libelle, f.libelle_court, f.article, f.ordre
FROM (VALUES
    ('IMMEUBLE',       N'Immeubles, terrains et droits réels',        N'Immeubles',        '211-6', 1),
    ('TITRE',          N'Parts et actions de filiales immobilières',  N'Titres',           '212-4', 2),
    ('COMPTE_COURANT', N'Avances en compte courant aux filiales',     N'Comptes courants', '213-4', 3),
    ('INSTRUMENT',     N'Instruments financiers et dépôts',           N'Instruments',      '221-1', 4)
) AS f(famille, libelle, libelle_court, article, ordre);

GO

