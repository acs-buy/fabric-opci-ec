
CREATE   VIEW dbo.v_etat_tableau_annexe AS
SELECT t.ordre, t.article, t.libelle, t.source_valeur, t.cellules AS attendues,
       -- 06/09/2026, O14 : le caractere du modele, article 335-1 du reglement ANC
       -- 2021-09, sections 3, 4 et 6 imposees, section 5 indicative. C'est ce que
       -- pr_demander_document lit pour refuser ou accepter avec mention.
       CAST(ISNULL(t.indicatif, 0) AS BIT)              AS indicatif,
       CASE WHEN ISNULL(t.indicatif, 0) = 1 THEN N'indicatif' ELSE N'imposé' END AS modele,
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

