
-- --- 5 : la vue des prerequis d'entree, par entite et par arrete --------
-- Ce que la porte 1 refusera, lisible AVANT toute tentative d'ouverture.
-- ATTENDU : zero ligne quand l'arrete peut s'ouvrir.
CREATE   VIEW dbo.v_prerequis_arrete AS
SELECT a.entite_detentrice AS entite,
       e2.arrete,
       'EXPERTISE_MANQUANTE' AS manquant,
       a.code               AS objet
FROM dbo.actif a
CROSS APPLY (SELECT DISTINCT l.arrete FROM dbo.lot_ecritures l) e2
WHERE a.entite_detentrice IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.expertise e
                  WHERE e.code_actif = a.code
                    AND e.date_valeur = e2.arrete)
UNION ALL
SELECT d.entite_mere,
       d.arrete,
       'BALANCE_FILIALE_MANQUANTE',
       d.entite_fille
FROM dbo.detention d
WHERE NOT EXISTS (SELECT 1 FROM dbo.lot_ecritures l
                  WHERE l.entite = d.entite_fille
                    AND l.arrete = d.arrete
                    AND l.famille = 'IMPORTEE'
                    AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE'));

GO

