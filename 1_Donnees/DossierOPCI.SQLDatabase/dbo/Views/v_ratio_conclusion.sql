
-- La conclusion, avec le geste quand le ratio est hors borne.
CREATE   VIEW dbo.v_ratio_conclusion AS
SELECT r.entite, r.arrete, r.code, r.libelle, r.article, r.sens, r.seuil,
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
       r.citation, r.lu_le, r.note
FROM dbo.v_ratio_arrete r;

GO

