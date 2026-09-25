-- 190 -- Un arrete rouvert restait CLOS : le statut ignorait les renvois
-- 13/09/2026. Second defaut trouve en rouvrant l'arrete du 31/12/2025, apres celui du script 189.
--
-- LE DEFAUT. dbo.pr_rouvrir_arrete inscrit un visa de cloture a l'issue RENVOYE, sans supprimer le
-- visa VISE d'origine, et c'est voulu : la trace demeure. Mais dbo.v_arrete_statut ne regardait que
-- les visas VISE, par un WHERE issue = 'VISE' pose avant l'agregat. Le visa VISE du 06/09 restait
-- donc trouve, vise_cloture valait 1, et l'arrete restait CLOS apres sa reouverture.
-- Mesure : la procedure corrigee s'est executee sans erreur, le visa RENVOYE du 13/09 a 11h46 est
-- bien en base, et v_arrete_statut rendait toujours CLOS.
--
-- LA CORRECTION. Le DERNIER visa de cloture fait foi, quelle que soit son issue : il est pris par
-- un rang sur l'horodatage, puis conserve seulement s'il est VISE. Un VISE suivi d'un RENVOYE
-- laisse donc l'arrete OUVERT, ce qui est l'objet meme d'une reouverture, et un RENVOYE suivi d'un
-- nouveau VISE le referme.
--
-- SEULE LA PREMIERE EXPRESSION DE LA VUE CHANGE. Le reste est repris mot pour mot de la definition
-- lue en base, colonnes, rangs, est_courant et message_ecran compris.

CREATE   VIEW dbo.v_arrete_statut AS
WITH cloture AS (
    /* 13/09/2026, CORRIGE : LE DERNIER visa de cloture fait foi, QUELLE QUE SOIT SON ISSUE.
       La redaction d'origine ne regardait que les visas VISE et ignorait les renvois : un arrete
       rouvert restait donc CLOS, et pr_rouvrir_arrete etait sans effet sur son statut.
       Ici le dernier visa est pris d'abord, puis conserve seulement s'il est VISE. */
    SELECT d.entite, d.arrete, d.horodatage AS vise_le, d.auteur AS vise_par
    FROM (SELECT j.entite, j.arrete, j.horodatage, j.auteur, j.issue,
                 ROW_NUMBER() OVER (PARTITION BY j.entite, j.arrete
                                    ORDER BY j.horodatage DESC) AS rang
          FROM dbo.v_ecran_journal_visa j
          WHERE j.nature = 'CLOTURE') d
    WHERE d.rang = 1 AND d.issue = 'VISE'
),
base AS (
    SELECT a.entite, a.arrete, a.type_arrete, a.exercice, a.date_arrete,
           a.ouvert_par, a.ouvert_le,
           CAST(CASE WHEN c.vise_le IS NOT NULL THEN 1 ELSE 0 END AS bit) AS vise_cloture,
           c.vise_le  AS cloture_visee_le,
           c.vise_par AS cloture_visee_par,
           CAST(ISNULL(e.cloturee, 0) AS bit) AS etape5_cloturee,
           CAST(CASE WHEN v.valeur_liquidative IS NOT NULL THEN 1 ELSE 0 END AS bit) AS vl_calculee
    FROM dbo.arrete_mission a
    LEFT JOIN cloture c            ON c.entite = a.entite AND c.arrete = a.arrete
    LEFT JOIN dbo.v_etat_etape_5 e ON e.entite = a.entite AND e.arrete = a.arrete
    LEFT JOIN dbo.v_ecran_valeur_liquidative v
                                   ON v.entite = a.entite AND v.arrete = a.arrete
),
range AS (
    SELECT b.*,
           CASE WHEN b.vise_cloture = 1 THEN 'CLOS' ELSE 'OUVERT' END AS statut,
           /* Rang des arretes OUVERTS, du plus recent au plus ancien. */
           ROW_NUMBER() OVER (PARTITION BY b.entite, CASE WHEN b.vise_cloture = 1 THEN 1 ELSE 0 END
                              ORDER BY b.arrete DESC) AS rang_dans_statut,
           ROW_NUMBER() OVER (PARTITION BY b.entite ORDER BY b.arrete DESC) AS rang_tous,
           SUM(CASE WHEN b.vise_cloture = 0 THEN 1 ELSE 0 END)
               OVER (PARTITION BY b.entite) AS ouverts_de_l_entite
    FROM base b
)
SELECT
    CONCAT(r.entite, '|', r.arrete) AS cle_ecran,
    r.entite,
    r.arrete,
    r.type_arrete,
    r.exercice,
    r.date_arrete,
    r.statut,
    r.vise_cloture,
    r.cloture_visee_le,
    r.cloture_visee_par,
    r.etape5_cloturee,
    r.vl_calculee,
    r.ouvert_par,
    r.ouvert_le,
    r.rang_tous,
    /* L'arrete courant : le dernier OUVERT de l'entite ; a defaut, le dernier clos, afin qu'un
       tableau de bord ne soit jamais vide. */
    CAST(CASE
        WHEN r.ouverts_de_l_entite > 0 AND r.vise_cloture = 0 AND r.rang_dans_statut = 1 THEN 1
        WHEN r.ouverts_de_l_entite = 0 AND r.rang_tous = 1 THEN 1
        ELSE 0 END AS bit) AS est_courant,
    CASE
        WHEN r.vise_cloture = 1
            THEN CONCAT(N'Arrêté clos : visa de clôture du ',
                        FORMAT(r.cloture_visee_le, 'dd/MM/yyyy', 'fr-FR'), N' par ',
                        r.cloture_visee_par, N'.')
        WHEN r.etape5_cloturee = 1
            THEN N'Arrêté ouvert, étape d''arrêté close : le visa de clôture reste à poser.'
        ELSE N'Arrêté ouvert, travaux en cours.'
    END AS message_ecran
FROM range r;

GO

