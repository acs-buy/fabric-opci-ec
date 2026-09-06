
-- C71 : une participation NON ELIGIBLE detenue a l'actif. L'article
-- R. 214-83 dit qu'elle « n'est PAS eligible a l'actif d'un organisme de
-- placement collectif immobilier » : la detenir est une irregularite.
-- ATTENDU zero.
CREATE   VIEW dbo.v_controle_participation_non_eligible AS
SELECT entite_mere, entite_fille, denomination, lecture
FROM dbo.v_eligibilite_participation
WHERE eligible = 0;

GO

