
-- --- 5 : la vue de lecture, par actif, methode et article ---------------
CREATE   VIEW dbo.v_actif_methode AS
SELECT a.code, a.nature, r.libelle AS nature_libelle, a.poste_bilan,
       a.entite_detentrice, r.methode, r.article, r.expertise_requise,
       (SELECT COUNT(*) FROM dbo.expertise e WHERE e.code_actif = a.code)
           AS rapports_deposes
FROM dbo.actif a
LEFT JOIN dbo.ref_nature_actif r ON r.nature = a.nature;

GO

