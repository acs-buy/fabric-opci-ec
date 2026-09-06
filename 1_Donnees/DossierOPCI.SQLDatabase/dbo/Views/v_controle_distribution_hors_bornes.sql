
-- C62 : une decision de distribution hors des bornes. La contrainte
-- l'interdit ; la vue le mesure. ATTENDU zero.
CREATE   VIEW dbo.v_controle_distribution_hors_bornes AS
SELECT entite, exercice, categorie, obligation_minimale, montant_decide,
       total_distribuable
FROM dbo.decision_distribution
WHERE montant_decide < obligation_minimale
   OR montant_decide > total_distribuable;

GO

