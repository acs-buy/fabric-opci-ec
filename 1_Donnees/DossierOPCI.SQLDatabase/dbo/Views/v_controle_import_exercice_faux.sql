
-- --- 7 : les controles ----------------------------------------------
-- C26 : un import dont l'exercice ne contient pas la date d'arrete et qui
-- est pourtant charge. ATTENDU zero : le carnet doit le refuser.
CREATE   VIEW dbo.v_controle_import_exercice_faux AS
SELECT import_id, entite, arrete, nom_fichier, exercice_debut, exercice_fin,
       date_arrete, motif_non_conforme
FROM dbo.v_import_exercice_conforme
WHERE exercice_conforme = 0
  AND EXISTS (SELECT 1 FROM dbo.import_fec i
              WHERE i.id = import_id AND i.statut = 'CHARGE');

GO

