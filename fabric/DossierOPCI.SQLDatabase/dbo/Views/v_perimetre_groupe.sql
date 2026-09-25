-- 210 : v_perimetre_groupe porte un libelle hierarchique, pour la liste des clients de l'ecran 1.
--
-- POURQUOI EN BASE ET PAS EN MESURE : la liste est une TABLE PLATE (decision du 17/09/2026) dont la
-- premiere colonne est une COLONNE projetee, ref_entite[Entité] ; une mesure a sa place changerait le
-- tri et le regroupement. Une colonne de la vue garde la table telle qu'elle est : la filiale s'affiche
-- « └ SCI-1 » sous son client, et le tri par vehicule puis rang reste celui de la vue.
-- AUCUNE LIGNE MODIFIEE, 2 colonnes ajoutees : entite_affichee et ordre_affichage. REJOUABLE.
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
    CONCAT(m.code, '-', RIGHT('000' + CAST(1 AS varchar(3)), 3)) AS ordre_affichage
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
    CONCAT(e.entite_mere, '-', RIGHT('000' + CAST(1 + ROW_NUMBER() OVER (PARTITION BY e.entite_mere ORDER BY e.entite_fille) AS varchar(3)), 3)) AS ordre_affichage
FROM dbo.eligibilite_participation e
JOIN dbo.ref_entite m ON m.code = e.entite_mere
JOIN dbo.ref_entite f ON f.code = e.entite_fille;

GO

