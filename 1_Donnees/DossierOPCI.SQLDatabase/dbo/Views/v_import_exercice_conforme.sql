-- La conformite a l'arrete se lit dans une vue et non dans une
-- contrainte : dbo.ref_arrete peut changer apres l'inscription, et une
-- contrainte figerait un fait qui se verifie.
CREATE   VIEW dbo.v_import_exercice_conforme AS
SELECT i.id AS import_id, i.entite, i.arrete, i.format, i.nom_fichier,
       i.exercice_debut, i.exercice_fin, r.date_arrete,
       CAST(CASE WHEN r.date_arrete BETWEEN i.exercice_debut AND i.exercice_fin
                 THEN 1 ELSE 0 END AS BIT)              AS exercice_conforme,
       CASE WHEN r.date_arrete IS NULL
                 THEN N'L''arrete ne figure pas au referentiel.'
            WHEN r.date_arrete NOT BETWEEN i.exercice_debut AND i.exercice_fin
                 THEN N'La date d''arrete ' + CONVERT(CHAR (10), r.date_arrete, 126)
                    + N' n''est pas comprise dans l''exercice du fichier, du '
                    + CONVERT(CHAR (10), i.exercice_debut, 126) + N' au '
                    + CONVERT(CHAR (10), i.exercice_fin, 126) + N'.'
       END                                              AS motif_non_conforme
FROM dbo.import_fec i
LEFT JOIN dbo.ref_arrete r ON r.entite = i.entite AND r.arrete = i.arrete;

GO

