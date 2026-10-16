
CREATE   VIEW dbo.v_perimetre_groupe AS
SELECT
    CONCAT(m.code, '|', m.code) AS cle_ecran,
    m.code                      AS vehicule,
    m.denomination              AS vehicule_denomination,
    m.code                      AS entite,
    m.denomination              AS entite_denomination,
    m.forme_sociale,
    CAST(1 AS bit)              AS est_vehicule,
    CAST(1.000000 AS decimal(9, 6)) AS quote_part,
    1                           AS rang,
    N'Véhicule du dossier : la révision porte sur lui.' AS message_ecran,
    CAST(m.code AS nvarchar(24))                        AS entite_affichee,
    CONCAT(m.code, '-', RIGHT('000' + CAST(1 AS varchar(3)), 3)) AS ordre_affichage,
    CAST(NULL AS bit)                                   AS controlee
FROM dbo.ref_entite m
WHERE m.forme_vehicule IS NOT NULL
UNION ALL
SELECT
    CONCAT(e.entite_mere, '|', e.entite_fille) AS cle_ecran,
    e.entite_mere                   AS vehicule,
    m.denomination                  AS vehicule_denomination,
    e.entite_fille                  AS entite,
    f.denomination                  AS entite_denomination,
    f.forme_sociale,
    CAST(0 AS bit)                  AS est_vehicule,
    CAST(e.droits_de_vote AS decimal(9, 6)) AS quote_part,
    1 + ROW_NUMBER() OVER (PARTITION BY e.entite_mere ORDER BY e.entite_fille) AS rang,
    CONCAT(N'Filiale du périmètre, ', FORMAT(e.droits_de_vote, 'P2', 'fr-FR'), N' des droits de vote.') AS message_ecran,
    CAST(N'└ ' + e.entite_fille AS nvarchar(24))         AS entite_affichee,
    CONCAT(e.entite_mere, '-', RIGHT('000' + CAST(1 + ROW_NUMBER() OVER (PARTITION BY e.entite_mere ORDER BY e.entite_fille) AS varchar(3)), 3)) AS ordre_affichage,
    e.controlee                     AS controlee
FROM dbo.eligibilite_participation e
JOIN dbo.ref_entite m ON m.code = e.entite_mere
JOIN dbo.ref_entite f ON f.code = e.entite_fille;

GO

