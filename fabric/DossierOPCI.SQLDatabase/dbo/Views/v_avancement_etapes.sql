-- 171 -- Les libelles d'ecran des 5 etapes, avant la pose de la barre d'avancement
-- 12/09/2026. Le candidat a arrete que le panneau des 15 ecrans de travail devient la barre
-- d'avancement de la mission, alimentee par cette vue. L'agent Fabric IQ a releve en la lisant
-- que les libelles y sont des CODES : COLLECTE, REVISION, ARRETE, en capitales et sans accent.
-- Un ecran d'expert-comptable ne montre pas ses codes, et « ARRETE » sans accent est ambigu.
-- Deux colonnes de libelle sont donc ajoutees, etape_libelle et unite_libelle. Elles sont portees
-- par la vue et non redressees dans chaque visuel, pour etre les memes sur les 15 ecrans.
-- Les colonnes de code sont conservees telles quelles : elles servent aux jointures, aux filtres
-- et a la mesure « Etape en cours », et les changer casserait ce qui les compare.
-- LE MOMENT EST CHOISI : la vue alimente le modele semantique, donc cette colonne de plus demande
-- un rafraichissement. Il se fait maintenant, avant que les 15 ecrans soient poses ; apres, il
-- aurait coute une repose de chacun d'eux.
CREATE VIEW dbo.v_avancement_etapes AS
WITH couple AS (
    /* Tout couple entite et arrete connu d'au moins une des 5 sources. */
    SELECT entite, arrete FROM dbo.v_documents_attendus_synthese
    UNION SELECT entite, arrete FROM dbo.feuille_travail WHERE arrete IS NOT NULL
    UNION SELECT entite, arrete FROM dbo.v_actifs_expertise_requise
    UNION SELECT entite, arrete FROM dbo.v_etat_etape_5
    UNION SELECT entite, arrete FROM dbo.v_livrables_dus
),
etape AS (
    -- LIBELLES D'ECRAN AJOUTES LE 12/09/2026, avant la pose des 15 ecrans de travail.
    -- Les colonnes etape et unite sont des CODES, en capitales et sans accent, faits pour etre
    -- compares et joints. La barre d'avancement les affichait tels quels, et « ARRETE » sans
    -- accent se lit aussi bien arrete qu'arrete. Un ecran d'expert-comptable ne montre pas ses
    -- codes. Les 2 libelles sont donc portes ICI plutot que redresses dans chaque visuel, pour
    -- qu'ils soient les memes sur les 15 ecrans et dans toute lecture ulterieure.
    -- Les colonnes de code sont conservees : elles servent aux jointures et aux filtres.
    SELECT 1 AS etape_ordre, 'COLLECTE'     AS etape, 'pieces obligatoires'    AS unite,
           N'Collecte'     AS etape_libelle, N'pièces obligatoires'     AS unite_libelle
    UNION ALL SELECT 2, 'REVISION',     'feuilles de travail',
           N'Révision',     N'feuilles de travail'
    UNION ALL SELECT 3, 'VALORISATION', 'actifs a valeur externe',
           N'Valorisation', N'actifs à valeur externe'
    UNION ALL SELECT 4, 'ARRETE',       'cloture de l''etape 5',
           N'Arrêté',       N'clôture de l''étape'
    UNION ALL SELECT 5, 'LIVRABLES',    'livrables dus',
           N'Livrables',    N'livrables dus'
),
collecte AS (
    SELECT entite, arrete,
           SUM(fournies) AS fait,
           SUM(fournies) + SUM(manquantes) AS total
    FROM dbo.v_documents_attendus_synthese
    GROUP BY entite, arrete
),
revision AS (
    SELECT entite, arrete,
           SUM(CASE WHEN conclue_le IS NOT NULL THEN 1 ELSE 0 END) AS fait,
           COUNT(*) AS total
    FROM dbo.feuille_travail
    WHERE arrete IS NOT NULL
    GROUP BY entite, arrete
),
valorisation AS (
    SELECT entite, arrete,
           SUM(CASE WHEN valeur_retenue_saisie = 1 THEN 1 ELSE 0 END) AS fait,
           COUNT(*) AS total
    FROM dbo.v_actifs_expertise_requise
    GROUP BY entite, arrete
),
arrete_etape AS (
    SELECT entite, arrete,
           MAX(CASE WHEN cloturee = 1 THEN 1 ELSE 0 END) AS fait,
           1 AS total
    FROM dbo.v_etat_etape_5
    GROUP BY entite, arrete
),
livrables AS (
    SELECT entite, arrete,
           SUM(CASE WHEN produit_le IS NOT NULL THEN 1 ELSE 0 END) AS fait,
           COUNT(*) AS total
    FROM dbo.v_livrables_dus
    GROUP BY entite, arrete
),
brut AS (
    SELECT c.entite, c.arrete, e.etape_ordre, e.etape, e.unite, e.etape_libelle, e.unite_libelle,
           CAST(CASE e.etape_ordre
                    WHEN 1 THEN ISNULL(co.fait, 0)
                    WHEN 2 THEN ISNULL(re.fait, 0)
                    WHEN 3 THEN ISNULL(va.fait, 0)
                    WHEN 4 THEN ISNULL(ar.fait, 0)
                    WHEN 5 THEN ISNULL(li.fait, 0)
                END AS int) AS fait,
           CAST(CASE e.etape_ordre
                    WHEN 1 THEN ISNULL(co.total, 0)
                    WHEN 2 THEN ISNULL(re.total, 0)
                    WHEN 3 THEN ISNULL(va.total, 0)
                    WHEN 4 THEN ISNULL(ar.total, 0)
                    WHEN 5 THEN ISNULL(li.total, 0)
                END AS int) AS total
    FROM couple c
    CROSS JOIN etape e
    LEFT JOIN collecte     co ON co.entite = c.entite AND co.arrete = c.arrete
    LEFT JOIN revision     re ON re.entite = c.entite AND re.arrete = c.arrete
    LEFT JOIN valorisation va ON va.entite = c.entite AND va.arrete = c.arrete
    LEFT JOIN arrete_etape ar ON ar.entite = c.entite AND ar.arrete = c.arrete
    LEFT JOIN livrables    li ON li.entite = c.entite AND li.arrete = c.arrete
),
avec_part AS (
    SELECT b.*,
           CASE WHEN b.total > 0
                THEN CAST(CAST(b.fait AS decimal(18, 4)) / b.total AS decimal(5, 4))
           END AS part
    FROM brut b
)
SELECT
    CONCAT(p.entite, '|', p.arrete, '|', p.etape) AS cle_ecran,
    p.entite,
    p.arrete,
    p.etape_ordre,
    p.etape,
    p.unite,
    p.etape_libelle,
    p.unite_libelle,
    p.fait,
    p.total,
    p.part,
    CAST(CASE WHEN p.etape_ordre = (
                   SELECT MIN(q.etape_ordre) FROM avec_part q
                   WHERE q.entite = p.entite AND q.arrete = p.arrete
                     AND q.total > 0 AND q.part < 1)
              THEN 1 ELSE 0 END AS bit) AS en_cours,
    CASE
        WHEN p.total = 0 THEN CONCAT('Aucun ', p.unite, ' a cet arrete : etape sans objet.')
        WHEN p.part = 1  THEN CONCAT('Etape achevee : ', CAST(p.fait AS varchar(10)), ' ', p.unite, ' sur ', CAST(p.total AS varchar(10)), '.')
        ELSE CONCAT(CAST(p.fait AS varchar(10)), ' ', p.unite, ' sur ', CAST(p.total AS varchar(10)), ' a ce jour.')
    END AS message_ecran
FROM avec_part p
;

GO

