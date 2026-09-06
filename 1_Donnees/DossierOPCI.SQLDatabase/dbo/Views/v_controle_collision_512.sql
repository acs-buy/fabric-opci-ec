-- C25 : le piege du compte 512. Une filiale dont le 512 pointe le 512 du
-- modele traduirait sa banque en emprunt. ATTENDU zero.
CREATE   VIEW dbo.v_controle_collision_512 AS
SELECT r.entite, r.compte_entite, r.compte_modele,
       N'Le 512 du PCG est la banque, le 512 du plan de l''article 411-3 est un emprunt : la traduction doit envoyer vers le 511.'
           AS motif
FROM dbo.ref_compte_entite r
JOIN dbo.detention d ON d.entite_fille = r.entite AND d.entite_mere = 'OMEGA-OPCI'
WHERE r.compte_entite = '512' AND r.compte_modele = '512';

GO

