
-- --- 2 : ce qui se traduit, et ce qui ne se traduit pas -------------
CREATE   VIEW dbo.v_traduction_a_faire AS
WITH employe AS (
    SELECT DISTINCT l.entite, e.compte_num AS compte_ecrit
    FROM dbo.ecriture e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
),
cible AS (
    SELECT em.entite, em.compte_ecrit,
           COUNT(rce.compte_entite)                    AS candidats,
           MIN(rce.compte_entite)                      AS compte_cible
    FROM employe em
    -- Le compte cible est celui du plan de l'entite qui se rattache au
    -- compte employe, sans etre ce compte lui-meme.
    LEFT JOIN dbo.ref_compte_entite rce
           ON rce.entite = em.entite
          AND rce.compte_modele = em.compte_ecrit
          AND rce.compte_entite <> em.compte_ecrit
    GROUP BY em.entite, em.compte_ecrit
)
SELECT c.entite, c.compte_ecrit, c.candidats, c.compte_cible,
       CASE WHEN c.candidats = 0
            THEN N'rien à traduire : aucun compte du plan de l''entité ne se rattache à celui-ci'
            WHEN c.candidats = 1
            THEN N'traduisible : ' + c.compte_ecrit + N' devient '
                 + c.compte_cible
            ELSE N'à répartir : ' + CAST(c.candidats AS NVARCHAR (4))
                 + N' comptes du plan de l''entité se rattachent à celui-ci, et la comptabilité seule ne dit pas dans quelle proportion'
            END                                        AS lecture
FROM cible c
WHERE EXISTS (SELECT 1 FROM dbo.detention d WHERE d.entite_fille = c.entite);

GO

