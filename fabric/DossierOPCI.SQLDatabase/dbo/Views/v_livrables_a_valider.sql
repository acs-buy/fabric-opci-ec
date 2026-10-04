
-- LES FICHIERS DE LA DERNIERE VERSION DE CHAQUE LIVRABLE DU, du perimetre de production (COMPTES_ANNUELS et ATTESTATION a
-- l'annuel, DIP hors annuel), avec, par livrable, si chaque format attendu a sa ligne non perimee.
CREATE   VIEW dbo.v_livrables_a_valider AS
WITH du AS (
    SELECT d.entite, d.arrete, d.livrable, d.libelle, l.formats,
           (SELECT MAX(x.version) FROM dbo.document_produit x WHERE x.entite = d.entite AND x.arrete = d.arrete AND x.livrable = d.livrable) AS version
    FROM dbo.v_livrables_dus d
    JOIN dbo.ref_livrable l ON l.code = d.livrable
    WHERE l.produit_etape_6 = 1
),
etat AS (
    SELECT du.*,
           CAST(CASE WHEN du.version IS NOT NULL AND NOT EXISTS (
                    SELECT 1 FROM STRING_SPLIT(du.formats, ',') f
                    WHERE NOT EXISTS (SELECT 1 FROM dbo.document_produit p
                                      WHERE p.entite = du.entite AND p.arrete = du.arrete AND p.livrable = du.livrable
                                        AND p.version = du.version AND p.format = LTRIM(RTRIM(f.value)) AND p.perime_le IS NULL))
                THEN 1 ELSE 0 END AS BIT) AS produit_complet
    FROM du
)
SELECT e.entite, e.arrete, e.livrable, e.libelle, e.version, e.produit_complet,
       p.id AS document_id, p.format, p.fichier, p.web_url, p.produit_par, p.couvre_version
FROM etat e
LEFT JOIN dbo.document_produit p ON p.entite = e.entite AND p.arrete = e.arrete AND p.livrable = e.livrable
                                AND p.version = e.version AND p.perime_le IS NULL;

GO

