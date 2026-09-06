
-- --- 9 : detection des couples entite et arrete portant plus d'un import.
-- 2 imports pour le meme couple entite/arrete restent possibles (fichier
-- livre en plusieurs morceaux) et ne sont vus par aucun controle existant :
-- cette vue les rend visibles, sans les interdire.
-- GRAIN : une ligne par lot de famille IMPORTEE appartenant a un couple
-- (arrete, entite) qui en porte plus d'un.
-- Rattachement du lot a l'entete par (arrete, entite, importe_par=cree_par,
-- famille IMPORTEE), dbo.lot_ecritures ne portant pas de cle etrangere ; si
-- ambigu (meme reviseur, meme arrete/entite), la vue liste tous les entetes
-- correspondants.
-- Compte tout lot IMPORTEE quel que soit son statut (REJETE ne double plus
-- la balance depuis 63_SQL/08_classe9_et_colonnes_balance.sql partie B3,
-- mais reste visible ici).
-- Forme retenue : STUFF + FOR XML PATH plutot que STRING_AGG, non
-- documente comme applicable a SQL database in Microsoft Fabric
-- (verifie le 21/08/2026).
CREATE   VIEW dbo.v_imports_en_doublon AS
SELECT
    l.arrete,
    l.entite,
    d.nb_lots_importes,
    l.id                                                        AS lot_id,
    l.statut                                                    AS statut_lot,
    l.cree_par,
    l.cree_le,
    (SELECT COUNT(*) FROM dbo.ecriture e WHERE e.lot_id = l.id)
                                                                 AS lignes,
    (SELECT SUM(e.debit) FROM dbo.ecriture e WHERE e.lot_id = l.id)
                                                                 AS total_debit,
    (SELECT SUM(e.credit) FROM dbo.ecriture e WHERE e.lot_id = l.id)
                                                                 AS total_credit,
    STUFF((
        SELECT ' ; ' + CAST(i.id AS VARCHAR(10)) + ' : ' + i.nom_fichier
             + ' (statut ' + i.statut + ', importe le '
             + CONVERT(VARCHAR(19), i.importe_le, 120)
             + ' par ' + i.importe_par + ')'
        FROM dbo.import_fec i
        WHERE i.arrete       = l.arrete
          AND i.entite        = l.entite
          AND i.importe_par   = l.cree_par
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 3, '')                    AS entetes_import
FROM dbo.lot_ecritures l
JOIN (
    SELECT arrete, entite, COUNT(*) AS nb_lots_importes
    FROM dbo.lot_ecritures
    WHERE famille = 'IMPORTEE'
    GROUP BY arrete, entite
    HAVING COUNT(*) > 1
) d ON d.arrete = l.arrete AND d.entite = l.entite
WHERE l.famille = 'IMPORTEE';

GO

