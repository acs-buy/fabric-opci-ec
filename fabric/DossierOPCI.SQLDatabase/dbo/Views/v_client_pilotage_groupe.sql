
-- --- 5e : le pilotage du groupe, arrete par arrete, pour l'historique --------
-- Relie a l'entite seule, non a l'arrete vise : la courbe remonte tous les
-- arretes a balance. Les flux intragroupe (avances, dettes, interets recus,
-- dividendes recus) n'entrent pas dans les totaux du groupe.
CREATE   VIEW dbo.v_client_pilotage_groupe AS
SELECT entite, arrete,
       SUM(tresorerie)                AS tresorerie,
       SUM(emprunt_bancaire)          AS emprunt_bancaire,
       SUM(loyers)                    AS loyers,
       SUM(charges_entretien)         AS charges_entretien,
       SUM(interets)                  AS interets,
       SUM(resultat_locatif)          AS resultat_locatif,
       SUM(valeur_actuelle_immeubles) AS valeur_actuelle_immeubles,
       CAST(CASE WHEN SUM(valeur_actuelle_immeubles) = 0 THEN NULL
                 ELSE SUM(loyers) / SUM(valeur_actuelle_immeubles) END AS DECIMAL (9,6)) AS rendement_locatif
FROM dbo.v_client_pilotage_societe
GROUP BY entite, arrete;

GO

