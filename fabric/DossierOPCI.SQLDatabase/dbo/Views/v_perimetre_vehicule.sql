
-- 2. LE PERIMETRE D'UN VEHICULE A UN ARRETE : le vehicule, a chacun de ses arretes, et les filiales que
-- detention lui rattache a cet arrete. Jamais la partie filiales de v_perimetre_groupe, qui ne porte pas
-- de date (regle 0.7).
CREATE   VIEW dbo.v_perimetre_vehicule AS
SELECT r.entite AS vehicule, r.arrete, r.entite
FROM dbo.ref_arrete r JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
UNION
SELECT d.entite_mere, d.arrete, d.entite_fille
FROM dbo.detention d JOIN dbo.ref_entite e ON e.code = d.entite_mere AND e.forme_vehicule IS NOT NULL;

GO

