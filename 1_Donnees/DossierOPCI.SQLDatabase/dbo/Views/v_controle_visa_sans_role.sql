-- C9 : un visa dont le decideur n'avait pas de role habilite a la date
-- de la decision. ATTENDU zero.
CREATE   VIEW dbo.v_controle_visa_sans_role AS
SELECT v.id, v.entite, v.arrete, v.nature, v.decide_par, v.decide_le
FROM dbo.visa v
WHERE dbo.fn_peut_viser(v.entite, v.decide_par, CAST(v.decide_le AS DATE)) = 0;

GO

