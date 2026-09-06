
-- --- 4 : la vue de lecture, ce que le rattachement traduit ------------
CREATE   VIEW dbo.v_rattachement_plan AS
SELECT r.entite, r.compte_entite, r.libelle_entite,
       r.compte_modele, COALESCE(c.libelle, r.compte_modele) AS libelle_modele,
       CASE WHEN r.compte_entite = r.compte_modele THEN 'IDENTITE'
            WHEN LEN(r.compte_entite) > LEN(r.compte_modele) THEN 'SUBDIVISION'
            ELSE 'REGROUPEMENT' END AS sens,
       r.rattache_par, r.rattache_le
FROM dbo.ref_compte_entite r
LEFT JOIN dbo.ref_compte c ON c.compte = r.compte_modele;

GO

