-- 181 -- Quelle colonne une grille PowerTable doit declarer comme cle, vue par vue
-- 13/09/2026. Repond au refus mesure par l'agent Fabric IQ : le service rend HTTP 400 avec
-- « There is no primary key column detected in source table or column configuration » a la lecture
-- des lignes d'une grille dont la source est une vue sans colonne identifiante.
--
-- LE PROBLEME. Une vue n'a pas de cle primaire : sys.indexes ne connait que les tables. Le
-- generateur de feuilles ne declarait identifiante que cle_ecran, presente sur les seules vues
-- d'ecran issues du script 144. Les 15 vues de contexte qui s'appuient directement sur une table,
-- et les 5 vues de l'ecran 1.1, n'en portent pas : leurs grilles ne peuvent pas servir de lignes.
--
-- CE QUE CETTE VUE REND, et c'est une DONNEE, pas du code : pour chaque vue lisible par une grille,
-- la colonne a declarer identifiante, et d'ou elle vient. Le generateur la lit au lieu de deduire.
--   'cle_ecran'          la vue porte deja la colonne du script 144, rien a faire
--   'cle primaire'       la table sous-jacente a une cle primaire d'UNE colonne, presente dans la vue
--   'unicite de groupe'  la vue agrege, la colonne de regroupement est unique par construction
--   'a traiter'          aucune des 3, il faut ajouter cle_ecran a la vue, cf. le script 182
--
-- POURQUOI UNE VUE ET NON UNE REGLE DE NOMMAGE. La deduction X -> v_ctx_X ne couvre pas
-- v_ecran_mon_contexte, dont la table est contexte_reviseur, ni v_ecran_vehicules_ouverts, qui
-- n'a pas de table. Une regle de nommage qui souffre des exceptions non ecrites se casse en
-- silence le jour ou une vue est renommee. Ici les exceptions sont dans la vue, donc lisibles.
--
-- CE QUE CETTE VUE NE DIT PAS : si le service accepte une cle COMPOSITE. Deux vues ont une cle
-- primaire de 2 colonnes, feuille_question et ref_compte_entite, et elles ressortent 'a traiter'
-- sans que la question composite ait ete eprouvee. Si elle l'etait et que la reponse est oui,
-- cette vue serait a etendre.

CREATE   VIEW dbo.v_cle_de_grille AS
WITH pk AS (
    SELECT t.name                    AS table_source,
           COUNT(*)                  AS colonnes_de_la_cle,
           MIN(c.name)               AS colonne
    FROM sys.tables t
    JOIN sys.indexes i       ON i.object_id = t.object_id AND i.is_primary_key = 1
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c       ON c.object_id = t.object_id AND c.column_id = ic.column_id
    GROUP BY t.name
),
-- Les exceptions, ecrites et non deduites. Une vue dont la table ne se devine pas par son nom.
exception AS (
    SELECT 'v_ecran_mon_contexte'     AS vue, 'contexte_reviseur' AS table_source UNION ALL
    SELECT 'v_ecran_c11_acceptation',       'acceptation_mission' UNION ALL
    SELECT 'v_ecran_c11_arretes',           'arrete_mission'      UNION ALL
    SELECT 'v_ecran_c11_maintiens',         'maintien_mission'    UNION ALL
    SELECT 'v_ecran_c11_questions',         'feuille_question'
),
agregat AS (
    -- Une vue d'agregat n'a pas de table sous-jacente utilisable, sa colonne de regroupement suffit.
    SELECT 'v_ecran_vehicules_ouverts' AS vue, 'vehicule' AS colonne
),
v AS (
    SELECT vw.name AS vue, vw.object_id,
           COALESCE(e.table_source, REPLACE(vw.name, 'v_ctx_', '')) AS table_deduite
    FROM sys.views vw
    LEFT JOIN exception e ON e.vue = vw.name
    WHERE vw.name LIKE 'v[_]ctx[_]%' OR vw.name LIKE 'v[_]ecran[_]c11[_]%'
       OR vw.name IN ('v_ecran_mon_contexte', 'v_ecran_vehicules_ouverts')
)
SELECT v.vue,
       CASE
           WHEN EXISTS (SELECT 1 FROM sys.columns c
                        WHERE c.object_id = v.object_id AND c.name = 'cle_ecran')
               THEN 'cle_ecran'
           WHEN ag.colonne IS NOT NULL                     THEN ag.colonne
           WHEN pk.colonnes_de_la_cle = 1
                AND EXISTS (SELECT 1 FROM sys.columns c
                            WHERE c.object_id = v.object_id AND c.name = pk.colonne)
               THEN pk.colonne
           ELSE NULL
       END                                                 AS colonne_cle,
       CASE
           WHEN EXISTS (SELECT 1 FROM sys.columns c
                        WHERE c.object_id = v.object_id AND c.name = 'cle_ecran')
               THEN 'cle_ecran'
           WHEN ag.colonne IS NOT NULL                     THEN 'unicite de groupe'
           WHEN pk.colonnes_de_la_cle = 1
                AND EXISTS (SELECT 1 FROM sys.columns c
                            WHERE c.object_id = v.object_id AND c.name = pk.colonne)
               THEN 'cle primaire'
           ELSE 'a traiter'
       END                                                 AS origine,
       v.table_deduite,
       ISNULL(pk.colonnes_de_la_cle, 0)                     AS colonnes_de_la_cle
FROM v
LEFT JOIN pk      ON pk.table_source = v.table_deduite
LEFT JOIN agregat ag ON ag.vue = v.vue;

GO

