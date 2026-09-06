
-- --- 5 : les ratios, avec leur conclusion en clair ----------------------
CREATE   VIEW dbo.v_client_ratio AS
SELECT v.entite + '|' + v.arrete AS cle_arrete, v.entite, v.arrete,
       v.code, v.libelle,
       CASE v.sens WHEN 'MINIMUM' THEN N'au moins' WHEN 'MAXIMUM' THEN N'au plus' ELSE v.sens END
                                       AS sens_libelle,
       v.seuil, v.ratio,
       v.numerateur, v.denominateur, v.article,
       CASE WHEN v.ratio IS NULL THEN N'non calculable'
            WHEN v.sens = 'MINIMUM' AND v.ratio >= v.seuil THEN N'respecté'
            WHEN v.sens = 'MAXIMUM' AND v.ratio <= v.seuil THEN N'respecté'
            ELSE N'non respecté' END    AS conclusion,
       CAST(CASE WHEN v.ratio IS NULL THEN 0
                 WHEN v.sens = 'MINIMUM' AND v.ratio >= v.seuil THEN 1
                 WHEN v.sens = 'MAXIMUM' AND v.ratio <= v.seuil THEN 1
                 ELSE 0 END AS BIT)      AS respecte,
       v.note, rr.ordre
FROM dbo.v_ratio_arrete v
JOIN dbo.ref_ratio rr ON rr.code = v.code
JOIN dbo.ref_arrete r ON r.entite = v.entite AND r.arrete = v.arrete
WHERE r.porte_balance = 1;

GO

