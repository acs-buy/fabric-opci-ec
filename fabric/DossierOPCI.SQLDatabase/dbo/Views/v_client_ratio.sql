
-- --- 5 : les ratios, avec leur conclusion en clair ----------------------
CREATE   VIEW dbo.v_client_ratio AS
SELECT v.entite + '|' + v.arrete AS cle_arrete, v.entite, v.arrete,
       v.code, v.libelle,
       CASE v.sens WHEN 'MINIMUM' THEN N'au moins' WHEN 'MAXIMUM' THEN N'au plus' ELSE v.sens END
                                       AS sens_libelle,
       v.seuil, v.ratio,
       v.numerateur, v.denominateur, v.article,
       -- 06/09/2026 : la source du seuil en clair pour le client, le corps promettant
       -- « le seuil applicable au vehicule, seuil legal ou seuil du prospectus ».
       CASE v.source_du_seuil WHEN 'TEXTE' THEN N'Seuil légal'
                              WHEN 'PROSPECTUS' THEN N'Seuil du prospectus'
                              WHEN 'CABINET' THEN N'Seuil du cabinet'
                              ELSE v.source_du_seuil END AS source_du_seuil,
       -- 06/09/2026 : 3 etats, non 2. Un calcul que le reviseur n'a pas valide ne
       -- conclut pas devant le client, il l'annonce ; releve le 06/09/2026, les 4
       -- ratios du jeu portaient calcul_a_valider = 1 et le client lisait « non
       -- respecte ».
       CASE WHEN v.calcul_a_valider = 1 THEN N'calcul à valider'
            WHEN v.ratio IS NULL THEN N'non calculable'
            WHEN v.sens = 'MINIMUM' AND v.ratio >= v.seuil THEN N'respecté'
            WHEN v.sens = 'MAXIMUM' AND v.ratio <= v.seuil THEN N'respecté'
            ELSE N'non respecté' END    AS conclusion,
       CAST(CASE WHEN v.calcul_a_valider = 1 OR v.ratio IS NULL THEN 0
                 WHEN v.sens = 'MINIMUM' AND v.ratio >= v.seuil THEN 1
                 WHEN v.sens = 'MAXIMUM' AND v.ratio <= v.seuil THEN 1
                 ELSE 0 END AS BIT)      AS respecte,
       CAST(CASE WHEN v.calcul_a_valider = 0 AND v.ratio IS NOT NULL
                  AND ((v.sens = 'MINIMUM' AND v.ratio < v.seuil)
                    OR (v.sens = 'MAXIMUM' AND v.ratio > v.seuil)) THEN 1
                 ELSE 0 END AS BIT)      AS non_respecte,
       CAST(CASE WHEN v.calcul_a_valider = 1 THEN 1 ELSE 0 END AS BIT) AS a_valider,
       v.note, rr.ordre
FROM dbo.v_ratio_arrete v
JOIN dbo.ref_ratio rr ON rr.code = v.code
JOIN dbo.ref_arrete r ON r.entite = v.entite AND r.arrete = v.arrete
WHERE r.porte_balance = 1;

GO

