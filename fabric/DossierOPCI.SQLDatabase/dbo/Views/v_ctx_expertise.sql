
-- Les expertises des actifs du perimetre. Pas de filtre d'arrete non plus : le reviseur compare
-- les valeurs d'un arrete a l'autre, et masquer les expertises anterieures lui retirerait ce qu'il
-- vient chercher.
CREATE   VIEW dbo.v_ctx_expertise AS
SELECT t.* FROM dbo.expertise t
WHERE EXISTS (SELECT 1 FROM dbo.actif a
              JOIN dbo.v_mon_perimetre p ON p.entite = a.entite_detentrice
              WHERE a.code = t.code_actif);

GO

