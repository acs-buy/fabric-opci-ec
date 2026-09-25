
CREATE   VIEW dbo.v_a_viser_derogation AS
SELECT d.entite, d.arrete,
       (SELECT f.cycle FROM dbo.feuille_travail f WHERE f.cote = d.cote) AS cycle,
       'DEROGATION'                                   AS nature,
       CAST(d.id AS VARCHAR (30))                     AS objet_ref,
       d.id                                           AS objet_id,
       CAST(N'Derogation ' + CAST(d.id AS NVARCHAR (20))
            + COALESCE(N' sur ' + d.cote, N'')
            + N' : ' + LEFT(d.motif, 180) AS NVARCHAR (300))
                                                      AS libelle,
       d.accordee_par                                 AS propose_par,
       d.accordee_le                                  AS propose_le,
       CAST(NULL AS INT)                              AS lignes,
       CAST(NULL AS DECIMAL (19,2))                   AS montant,
       'ACCORDEE'                                     AS etat,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       d.message_ecran
FROM dbo.derogation d
WHERE d.levee_le IS NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.visa v
                  WHERE v.nature = 'DEROGATION'
                    AND v.objet_ref = CAST(d.id AS VARCHAR (30))
                    AND v.decision = 'VISE');

GO

