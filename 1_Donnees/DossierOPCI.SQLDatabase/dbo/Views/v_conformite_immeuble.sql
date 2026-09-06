
-- --- 6 : la conformite, immeuble par immeuble -----------------------
CREATE   VIEW dbo.v_conformite_immeuble AS
SELECT a.code AS code_actif, a.entite_detentrice, a.adresse, a.secteur,
       a.prix_de_revient,
       a.cas_r214_81, ci.libelle AS cas_libelle,
       a.droit_r214_82, dr.libelle AS droit_libelle,
       CAST(CASE WHEN a.cas_r214_81 IS NOT NULL AND a.droit_r214_82 IS NOT NULL
                 THEN 1 ELSE 0 END AS BIT)          AS conforme,
       CASE WHEN a.cas_r214_81 IS NULL AND a.droit_r214_82 IS NULL
            THEN N'à qualifier : ni le cas de l''article R. 214-81 ni le droit réel de l''article R. 214-82 ne sont renseignés'
            WHEN a.cas_r214_81 IS NULL
            THEN N'à qualifier : le cas de l''article R. 214-81 n''est pas renseigné'
            WHEN a.droit_r214_82 IS NULL
            THEN N'à qualifier : le droit réel de l''article R. 214-82 n''est pas renseigné'
            ELSE N'conforme : l''immeuble relève d''un cas de l''article R. 214-81 et d''un droit réel de l''article R. 214-82'
            END                                     AS lecture
FROM dbo.actif a
LEFT JOIN dbo.ref_cas_immeuble ci ON ci.cas = a.cas_r214_81
LEFT JOIN dbo.ref_droit_reel dr ON dr.droit = a.droit_r214_82
WHERE a.nature = 'IMMEUBLE';

GO

