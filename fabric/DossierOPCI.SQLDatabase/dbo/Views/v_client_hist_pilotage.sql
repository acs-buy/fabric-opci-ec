-- Le pilotage du groupe pour le client, arrete par arrete, aux seuls arretes vises. Les flux intragroupe (avances,
-- dettes, interets recus, dividendes recus) n'entrent pas dans les totaux du groupe.
CREATE   VIEW dbo.v_client_hist_pilotage AS
SELECT g.entite, g.arrete, g.tresorerie, g.emprunt_bancaire, g.loyers, g.charges_entretien, g.interets,
       g.resultat_locatif, g.valeur_actuelle_immeubles, g.rendement_locatif
FROM dbo.v_client_pilotage_groupe g
WHERE EXISTS (SELECT 1 FROM dbo.v_arrete_client c WHERE c.entite = g.entite AND c.arrete = g.arrete);

GO

