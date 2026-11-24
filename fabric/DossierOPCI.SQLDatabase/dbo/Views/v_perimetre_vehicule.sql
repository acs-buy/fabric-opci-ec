-- --- 0-bis. le perimetre d'un vehicule a un arrete, sur la meme fonction ------------------------------
-- 2. LE PERIMETRE D'UN VEHICULE A UN ARRETE : le vehicule, a chacun de ses arretes, et ses filiales a cet arrete.
-- Jamais la partie filiales de v_perimetre_groupe, qui ne porte pas de date (regle 0.7).
-- 19/11/2026 : les filiales par dbo.fn_filiales_a_l_arrete ; detention ne porte une ligne qu'a un arrete du
-- vehicule au referentiel (fk_detention_arrete), le perimetre d'un arrete a detention est donc inchange.
CREATE   VIEW dbo.v_perimetre_vehicule AS
SELECT r.entite AS vehicule, r.arrete, r.entite
FROM dbo.ref_arrete r JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
UNION
SELECT r.entite, r.arrete, f.entite_fille
FROM dbo.ref_arrete r JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
CROSS APPLY dbo.fn_filiales_a_l_arrete(r.entite, r.arrete) f;

GO

