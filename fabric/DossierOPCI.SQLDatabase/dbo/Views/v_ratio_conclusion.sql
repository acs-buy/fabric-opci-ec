
-- ------------------------------------------------------------------ n° 3, 17, 18 : v_ratio_conclusion
-- ordre et libelle_memoire, lus sur ref_ratio_memoire ; a_respecter, regle des dates de respect (n° 17) :
--   ACTIFS_IMMO_60, NON_COTE_51 (R. 214-90) et ENDETTEMENT_40 (R. 214-105) : 1 a un arrete du 30 juin ou du 31 decembre,
--   0 sinon ; LIQUIDITES_5 (R. 214-101, aucune date fixee) : 1 a tout arrete ; la periode de 3 ans de L. 214-43 court
--   de la creation de l'organisme, que la base ne porte pas : elle est reputee ecoulee ;
--   OPCI professionnel (ref_entite.est_professionnel = 1) : ENDETTEMENT_40, retenu par le cabinet sans date fixee par
--   le texte (R. 214-105 ecarte par R. 214-199), et LIQUIDITES_5, sans objet (R. 214-197) : NULL.
-- arrete_libelle : l'arrete ecrit jj/mm/aaaa.

CREATE   VIEW dbo.v_ratio_conclusion AS
SELECT r.entite, r.arrete, r.code, r.libelle, r.article, r.sens, r.seuil,
       r.source_du_seuil,
       -- 06/09/2026, O7, option 1 arretee par le candidat : un ratio non conforme
       -- renvoie vers la feuille du cycle VALO de l'arrete, ou la regularisation
       -- se travaille ; la feuille humaine avant celle du moteur.
       (SELECT TOP 1 f.cote FROM dbo.feuille_travail f
        WHERE f.entite = r.entite AND f.arrete = r.arrete AND f.cycle = 'VALO'
        ORDER BY CASE f.origine WHEN 'HUMAINE' THEN 0 ELSE 1 END, f.cote)
                                                 AS feuille_regularisation,
       r.numerateur, r.denominateur, r.ratio,
       -- La conformite reste NULLE tant que le calcul n'est pas valide :
       -- rendre 0 laisserait lire une non-conformite comme un fait.
       CAST(CASE WHEN r.calcul_a_valider = 1 THEN NULL
                 WHEN r.ratio IS NULL THEN NULL
                 WHEN r.sens = 'MINIMUM' AND r.ratio >= r.seuil THEN 1
                 WHEN r.sens = 'MAXIMUM' AND r.ratio <= r.seuil THEN 1
                 ELSE 0 END AS BIT)              AS conforme,
       CAST(r.calcul_a_valider AS BIT)           AS calcul_a_valider,
       CASE WHEN r.calcul_a_valider = 1
            THEN N'CALCUL À VALIDER, la conformité n''est pas établie : '
                 + N'le seuil est lu sur pièce, ' + r.article
                 + N', mais le numérateur et le dénominateur restent à '
                 + N'arrêter. Valeur indicative de '
                 + COALESCE(FORMAT(r.ratio, 'P2', 'fr-FR'), N'non calculable')
                 + N'.'
            WHEN r.ratio IS NULL
            THEN N'non calculable : le dénominateur est nul'
            WHEN r.sens = 'MINIMUM' AND r.ratio >= r.seuil
            THEN N'conforme : ' + FORMAT(r.ratio, 'P2', 'fr-FR')
                 + N' pour un minimum de ' + FORMAT(r.seuil, 'P2', 'fr-FR')
            WHEN r.sens = 'MAXIMUM' AND r.ratio <= r.seuil
            THEN N'conforme : ' + FORMAT(r.ratio, 'P2', 'fr-FR')
                 + N' pour un maximum de ' + FORMAT(r.seuil, 'P2', 'fr-FR')
            WHEN r.sens = 'MINIMUM'
            THEN N'NON CONFORME : ' + FORMAT(r.ratio, 'P2', 'fr-FR')
                 + N', en deçà du minimum de '
                 + FORMAT(r.seuil, 'P2', 'fr-FR') + N', '
                 + r.article + N'. Régulariser avant la publication, ou '
                 + N'porter une dérogation motivée.'
            ELSE N'NON CONFORME : ' + FORMAT(r.ratio, 'P2', 'fr-FR')
                 + N', au-delà du maximum de '
                 + FORMAT(r.seuil, 'P2', 'fr-FR') + N', '
                 + r.article + N'. Régulariser avant la publication, ou '
                 + N'porter une dérogation motivée.'
            END                                  AS conclusion,
       r.citation, r.lu_le, r.note,
       m.ordre,
       -- Decision D9 : le libelle de la limite ecrit le seuil des statuts a la place de celui du texte.
       CAST(CASE WHEN r.source_du_seuil = 'STATUTS'
                 THEN REPLACE(m.libelle, FORMAT(rr.seuil * 100, N'0.##', 'fr-FR') + N' %',
                              FORMAT(r.seuil * 100, N'0.##', 'fr-FR') + N' %')
                 ELSE m.libelle END AS NVARCHAR (120)) AS libelle_memoire,
       CAST(CASE WHEN ISNULL(en.est_professionnel, 0) = 1 AND r.code IN ('ENDETTEMENT_40', 'LIQUIDITES_5') THEN NULL
                 WHEN r.code = 'LIQUIDITES_5' THEN 1
                 WHEN RIGHT(r.arrete, 5) IN ('06-30', '12-31') THEN 1
                 ELSE 0 END AS BIT) AS a_respecter,
       CAST(RIGHT(r.arrete, 2) + '/' + SUBSTRING(r.arrete, 6, 2) + '/' + LEFT(r.arrete, 4) AS VARCHAR (10)) AS arrete_libelle
FROM dbo.v_ratio_arrete r
LEFT JOIN dbo.ref_ratio_memoire m ON m.code = r.code
LEFT JOIN dbo.ref_entite en ON en.code = r.entite
LEFT JOIN dbo.ref_ratio rr ON rr.code = r.code;

GO

