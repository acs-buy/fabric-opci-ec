-- C20 : une demande servie sans compte rendu. La contrainte l'interdit ;
-- la vue le mesure. ATTENDU zero.
CREATE   VIEW dbo.v_controle_demande_sans_compte_rendu AS
SELECT id, entite, arrete, etat, posee_par, servie_le
FROM dbo.demande_reevaluation
WHERE etat <> 'EN_ATTENTE' AND compte_rendu IS NULL;

GO

