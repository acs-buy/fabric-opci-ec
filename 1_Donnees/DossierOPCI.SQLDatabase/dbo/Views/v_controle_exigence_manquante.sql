
-- --- 6 : les controles ---------------------------------------------
-- C36 : une exigence obligatoire manquante a un arrete qui porte
-- balance. Ce n'est pas une anomalie de la base mais l'etat du dossier :
-- la vue le mesure pour que l'ecran le montre.
CREATE   VIEW dbo.v_controle_exigence_manquante AS
SELECT entite, arrete, cycle, phase, exigence, periodicite
FROM dbo.v_documents_attendus WHERE etat = 'MANQUANTE';

GO

