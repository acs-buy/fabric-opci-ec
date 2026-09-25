CREATE   VIEW dbo.v_colonne_de_grille AS
WITH source AS (
    SELECT v.object_id, v.name AS vue FROM sys.views v
    UNION ALL
    SELECT t.object_id, t.name FROM sys.tables t
),
resolue AS (
    -- L'objet ou chercher les masquages, dans cet ordre, le premier trouve gagne :
    --   1. le nom EXACT, pour une vue qui porte ses propres masquages ;
    --   2. pour une v_ctx_X, la TABLE X, quand la vue de contexte est batie sur une table ;
    --   3. pour une v_ctx_X, la VUE v_ecran_X, quand elle est batie sur une vue d'ecran.
    -- CORRIGE LE 13/09/2026, ET LE DEFAUT ETAIT GRAVE : le cas 3 manquait, si bien que 53 des
    -- 68 vues de contexte n'etaient PAS couvertes. v_ctx_balance se cherchait sous « balance »,
    -- qui n'existe pas, alors que ses masquages sont ecrits sous « v_ecran_balance ». Le controle
    -- « 77 vues couvertes » ne l'avait pas vu parce qu'il comptait les vues v_ecran_* elles-memes,
    -- que les feuilles ne pointent pas.
    SELECT s.object_id, s.vue,
           CASE
               WHEN EXISTS (SELECT 1 FROM dbo.ref_colonne_masquee r WHERE r.vue = s.vue)
                   THEN s.vue
               WHEN EXISTS (SELECT 1 FROM dbo.ref_colonne_masquee r
                            WHERE r.vue = SUBSTRING(s.vue, 7, 200))
                   THEN SUBSTRING(s.vue, 7, 200)
               ELSE 'v_ecran_' + SUBSTRING(s.vue, 7, 200)
           END AS objet_des_masquages
    FROM source s
)
SELECT r.vue,
       c.column_id                                                AS ordre,
       c.name                                                     AS colonne,
       CAST(CASE WHEN m.colonne IS NULL THEN 1 ELSE 0 END AS bit) AS visible,
       ISNULL(m.motif, '')                                        AS motif_du_masquage,
       r.objet_des_masquages
FROM resolue r
JOIN sys.columns c ON c.object_id = r.object_id
LEFT JOIN dbo.ref_colonne_masquee m
       ON m.vue = r.objet_des_masquages AND m.colonne = c.name
-- 13/09/2026 : une grille dont AUCUNE colonne n'est masquee doit figurer ici quand meme, avec
-- toutes ses colonnes visibles. v_ctx_actif en etait absente, et le generateur de feuilles n'y
-- trouvait donc rien a lire : il ne faut pas confondre « rien a masquer » et « pas de consigne ».
WHERE EXISTS (SELECT 1 FROM dbo.ref_colonne_masquee x WHERE x.vue = r.objet_des_masquages)
   OR r.vue LIKE 'v[_]ctx[_]%';

GO

