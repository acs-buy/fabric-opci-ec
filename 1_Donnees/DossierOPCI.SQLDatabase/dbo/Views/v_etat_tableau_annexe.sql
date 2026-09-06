
-- L'etat de chaque tableau, que l'ecran L1c lit : combien de cellules
-- sont remplies sur celles qu'il attend.
CREATE   VIEW dbo.v_etat_tableau_annexe AS
SELECT t.ordre, t.article, t.libelle, t.source_valeur, t.cellules AS attendues,
       r.entite, r.arrete,
       COALESCE(s.remplies, 0)                        AS remplies,
       CASE WHEN t.cellules IS NULL
            THEN N'nombre de cellules variable : une ligne par actif'
            WHEN COALESCE(s.remplies, 0) = 0
            THEN N'aucune cellule saisie'
            WHEN COALESCE(s.remplies, 0) >= t.cellules
            THEN N'complet'
            ELSE N'incomplet : ' + CAST(COALESCE(s.remplies, 0) AS NVARCHAR (10))
                 + N' sur ' + CAST(t.cellules AS NVARCHAR (10)) END AS etat,
       s.dernier_saisi_le, t.note
FROM dbo.ref_tableau_annexe t
CROSS JOIN (SELECT entite, arrete FROM dbo.ref_arrete
            WHERE nature_technique = 'MISSION') AS r
OUTER APPLY (
    SELECT COUNT(*) AS remplies, MAX(x.saisi_le) AS dernier_saisi_le
    FROM dbo.saisie_annexe x
    WHERE x.entite = r.entite AND x.arrete = r.arrete
      AND x.article = t.article
) AS s;

GO

