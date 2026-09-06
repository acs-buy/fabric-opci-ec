
-- --- 3 : les controles ----------------------------------------
-- C21 : un visa pose sur une nature que le role du decideur ne couvre
-- pas. Le verrou l'interdit ; la vue le detecte si la repartition change
-- apres coup. ATTENDU zero.
CREATE   VIEW dbo.v_controle_visa_hors_nature AS
SELECT v.id, v.entite, v.nature, v.decide_par, v.decide_le
FROM dbo.visa v
WHERE dbo.fn_peut_viser_nature(v.entite, v.decide_par, v.nature,
                               CAST(v.decide_le AS DATE)) = 0;

GO

