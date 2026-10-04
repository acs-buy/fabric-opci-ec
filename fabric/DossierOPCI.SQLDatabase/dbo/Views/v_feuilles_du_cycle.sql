

-- 4. LES FEUILLES DU CYCLE, LIBELLEES : une ligne par feuille de cycle hors Q- et par vehicule au
-- perimetre duquel son entite appartient a l'arrete de la feuille. Aucune colonne ne porte un chemin du coffre.
CREATE   VIEW dbo.v_feuilles_du_cycle AS
SELECT p.vehicule, f.entite, f.arrete, f.cycle, f.cote,
       q.reference AS question_reference,
       f.modele_code AS gabarit, m.libelle AS gabarit_libelle,
       f.objectif, ISNULL(f.objectif, N'à remplir') AS objectif_libelle,
       f.forme_conclusion AS forme, fc.libelle AS forme_libelle,
       f.conclusion, f.conclue_par, f.conclue_le, f.preparateur, f.prepare_le,
       (SELECT TOP 1 x.web_url FROM dbo.export_dossier x WHERE x.entite = f.entite AND x.arrete = f.arrete
          AND x.fichier = N'feuille_' + f.cote + N'.xlsx' AND x.statut = 'FAIT' AND x.web_url LIKE N'https://%'
         ORDER BY x.depose_le DESC, x.id DESC) AS web_url,
       CAST(CASE WHEN f.conclue_le IS NOT NULL AND f.conclue_le > c.conclu_le THEN 1 ELSE 0 END AS BIT) AS conclue_apres_cycle,
       p.vehicule + '|' + f.arrete + '|' + f.cycle AS cle_cycle
FROM dbo.feuille_travail f
JOIN dbo.v_perimetre_vehicule p ON p.entite = f.entite AND p.arrete = f.arrete
LEFT JOIN dbo.ref_question q ON q.id = f.question_id
LEFT JOIN dbo.modele_feuille m ON m.code = f.modele_code
LEFT JOIN dbo.ref_forme_conclusion fc ON fc.code = f.forme_conclusion
LEFT JOIN dbo.conclusion_cycle c ON c.entite = p.vehicule AND c.arrete = f.arrete AND c.cycle = f.cycle
WHERE f.cycle IS NOT NULL AND f.cote NOT LIKE 'Q-%';

GO

