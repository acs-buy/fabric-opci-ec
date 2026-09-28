
-- LA COMPLEXITE DE LA BALANCE, une ligne par arrete ouvert, et le type de programme qu'elle propose.
-- comptes_mouvementes : comptes de la balance importee de l'entite portant un debit ou un credit ;
-- cycles_presents     : cycles dont au moins un compte figure a cette balance ;
-- balances_filiales   : filiales detenues a l'arrete, ayant une balance importee au meme arrete ;
-- sources_import      : imports distincts de la balance de l'entite, approximation des systemes d'information.
-- Les seuils sont lus dans ref_parametre, jamais ecrits ici.
CREATE   VIEW dbo.v_complexite_balance AS
WITH seuils AS (
    SELECT (SELECT TRY_CAST(valeur AS INT) FROM dbo.ref_parametre WHERE code = 'PROGRAMME_ETENDU_FILIALES_MIN') AS etendu_filiales,
           (SELECT TRY_CAST(valeur AS INT) FROM dbo.ref_parametre WHERE code = 'PROGRAMME_ETENDU_SOURCES_MIN')  AS etendu_sources,
           (SELECT TRY_CAST(valeur AS INT) FROM dbo.ref_parametre WHERE code = 'PROGRAMME_ALLEGE_FILIALES_MAX') AS allege_filiales,
           (SELECT TRY_CAST(valeur AS INT) FROM dbo.ref_parametre WHERE code = 'PROGRAMME_ALLEGE_COMPTES_MAX')  AS allege_comptes
),
mesure AS (
    SELECT am.entite, am.arrete,
           (SELECT COUNT(DISTINCT e.compte_num) FROM dbo.lot_ecritures l JOIN dbo.ecriture e ON e.lot_id = l.id
             WHERE l.entite = am.entite AND l.arrete = am.arrete AND l.famille = 'IMPORTEE'
               AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND (e.debit <> 0 OR e.credit <> 0)) AS comptes_mouvementes,
           (SELECT COUNT(DISTINCT rc.cycle) FROM dbo.lot_ecritures l JOIN dbo.ecriture e ON e.lot_id = l.id
             JOIN dbo.ref_cycle_compte rc ON e.compte_num LIKE rc.racine + '%'
             WHERE l.entite = am.entite AND l.arrete = am.arrete AND l.famille = 'IMPORTEE'
               AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')) AS cycles_presents,
           (SELECT COUNT(DISTINCT d.entite_fille) FROM dbo.detention d
             WHERE d.entite_mere = am.entite AND d.arrete = am.arrete
               AND EXISTS (SELECT 1 FROM dbo.lot_ecritures l WHERE l.entite = d.entite_fille AND l.arrete = am.arrete
                             AND l.famille = 'IMPORTEE' AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE'))) AS balances_filiales,
           (SELECT COUNT(DISTINCT l.import_id) FROM dbo.lot_ecritures l
             WHERE l.entite = am.entite AND l.arrete = am.arrete AND l.famille = 'IMPORTEE'
               AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')) AS sources_import
    FROM dbo.arrete_mission am
)
SELECT m.entite, m.arrete, m.comptes_mouvementes, m.cycles_presents, m.balances_filiales, m.sources_import,
       CAST(CASE WHEN s.etendu_filiales IS NULL OR s.etendu_sources IS NULL OR s.allege_filiales IS NULL OR s.allege_comptes IS NULL
                      THEN NULL
                 WHEN m.comptes_mouvementes = 0 THEN NULL
                 WHEN m.balances_filiales >= s.etendu_filiales OR m.sources_import >= s.etendu_sources THEN 'ETENDU'
                 WHEN m.balances_filiales <= s.allege_filiales AND m.comptes_mouvementes <= s.allege_comptes THEN 'ALLEGE'
                 ELSE 'CLASSIQUE' END AS VARCHAR (10)) AS type_propose,
       -- LA REGLE QUI A JOUE, en toutes lettres, pour l'ecran.
       CAST(CASE WHEN s.etendu_filiales IS NULL OR s.etendu_sources IS NULL OR s.allege_filiales IS NULL OR s.allege_comptes IS NULL
                      THEN N'Les seuils du programme ne sont pas renseignés aux paramètres : aucun type n''est proposé.'
                 WHEN m.comptes_mouvementes = 0
                      THEN N'Aucune balance n''est importée à cet arrêté : aucun type n''est proposé.'
                 WHEN m.balances_filiales >= s.etendu_filiales
                      THEN N'Étendu : ' + CAST(m.balances_filiales AS NVARCHAR (10)) + N' filiale(s) ont une balance à l''arrêté, seuil ' + CAST(s.etendu_filiales AS NVARCHAR (10)) + N'.'
                 WHEN m.sources_import >= s.etendu_sources
                      THEN N'Étendu : ' + CAST(m.sources_import AS NVARCHAR (10)) + N' imports distincts de la balance, seuil ' + CAST(s.etendu_sources AS NVARCHAR (10)) + N'.'
                 WHEN m.balances_filiales <= s.allege_filiales AND m.comptes_mouvementes <= s.allege_comptes
                      THEN N'Allégé : ' + CAST(m.comptes_mouvementes AS NVARCHAR (10)) + N' compte(s) mouvementé(s) et ' + CAST(m.balances_filiales AS NVARCHAR (10)) + N' balance(s) de filiale.'
                 ELSE N'Classique : ni les seuils de l''étendu, ni ceux de l''allégé ne sont atteints.' END AS NVARCHAR (300)) AS raison,
       m.entite + '|' + m.arrete AS cle_arrete
FROM mesure m CROSS JOIN seuils s;

GO

