
-- 5. LA FORME PROPOSEE. Les colonnes d'hier gardent leur nom et leur place ; les 2 nouvelles viennent en dernier.
-- Une feuille REFUS_ATTESTER se traduit en IMPOSSIBILITE, code du rapport pour le refus d'attester. Entite soumise au
-- commissariat aux comptes : le compte rendu de travaux (NP 2300, A10, exemple E4).
CREATE   VIEW dbo.v_forme_attestation_proposee AS
WITH f AS (
    SELECT r.entite, r.arrete,
           COUNT(f.cote) AS feuilles,
           COUNT(f.forme_conclusion) AS feuilles_conclues,
           SUM(CASE WHEN f.forme_conclusion = 'REFUS_ATTESTER' THEN 1 ELSE 0 END) AS en_refus,
           SUM(CASE WHEN f.forme_conclusion = 'AVEC_OBSERVATION' THEN 1 ELSE 0 END) AS avec_observation
    FROM dbo.ref_arrete r
    LEFT JOIN dbo.feuille_travail f ON f.entite = r.entite AND f.arrete = r.arrete AND f.cycle IS NOT NULL
    WHERE r.nature_technique = 'MISSION'
    GROUP BY r.entite, r.arrete
),
d AS (
    SELECT f.*, CAST(CASE WHEN e.soumise_commissariat_comptes = 1 THEN 1 ELSE 0 END AS BIT) AS soumise,
           e.soumise_commissariat_comptes,
           CASE WHEN f.feuilles_conclues = 0 THEN NULL
                WHEN f.en_refus > 0 THEN 'IMPOSSIBILITE'
                WHEN f.avec_observation > 0 THEN 'AVEC_OBSERVATION'
                ELSE 'SANS_OBSERVATION' END AS derivee
    FROM f JOIN dbo.ref_entite e ON e.code = f.entite
)
SELECT d.entite, d.arrete, d.feuilles, d.feuilles_conclues, d.en_refus, d.avec_observation,
       CAST(CASE WHEN d.soumise = 1 THEN 'COMPTE_RENDU_TRAVAUX' ELSE d.derivee END AS VARCHAR (20)) AS forme_proposee,
       CAST(CASE WHEN d.soumise = 1
                 THEN N'COMPTE_RENDU_TRAVAUX ; avec un motif de considérations particulières : '
                      + CASE WHEN d.feuilles_conclues = 0 THEN N'AVEC_OBSERVATION, IMPOSSIBILITE' ELSE d.derivee END
                 WHEN d.feuilles_conclues = 0 THEN N'AVEC_OBSERVATION, IMPOSSIBILITE'
                 ELSE d.derivee END AS NVARCHAR (200)) AS formes_admises,
       CAST(CASE WHEN d.feuilles_conclues = 0 THEN 1 ELSE 0 END AS BIT) AS limitation_des_diligences,
       CAST(CASE WHEN d.soumise = 1
                 THEN N'l''entité est soumise au commissariat aux comptes : le rapport est un compte rendu de travaux, sans formulation d''assurance sur les comptes ; une attestation n''y est délivrée que pour des considérations particulières, motivées'
                 WHEN d.feuilles_conclues = 0
                 THEN N'aucune feuille de cycle n''est conclue : la forme ne se dérive pas, l''expert-comptable la choisit entre l''observation du paragraphe 20 et le refus d''attester du paragraphe 21, selon l''importance qu''il donne à la limitation de ses diligences. La forme sans observation est fermée.'
                 WHEN d.feuilles > d.feuilles_conclues
                 THEN N'des feuilles restent à conclure : la forme proposée peut encore changer'
                 ELSE N'toutes les feuilles sont conclues : la forme proposée est stable' END AS NVARCHAR (400)) AS lecture,
       CAST(CASE WHEN d.soumise = 1
                 THEN N'NP 2300, paragraphe A10 et exemple E4 pour le compte rendu de travaux ; paragraphes 18 à 21 pour une attestation délivrée sur considérations particulières'
                 ELSE N'NP 2300 paragraphe 18 pour les 3 formes, paragraphe 20 pour l''observation en cas de limitation des diligences, paragraphe 21 pour le refus d''attester' END AS NVARCHAR (300)) AS source,
       d.soumise_commissariat_comptes,
       CAST(d.derivee AS VARCHAR (20)) AS forme_attestation_derivee
FROM d;

GO

