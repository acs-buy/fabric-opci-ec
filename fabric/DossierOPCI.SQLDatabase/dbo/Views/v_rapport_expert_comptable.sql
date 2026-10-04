
-- 8. LES DONNEES DU RAPPORT. Par arrete de mission d'un vehicule auquel le rapport est du : la forme arretee (la
-- proposee tant qu'aucune ne l'est), son texte, et une colonne par emplacement du texte. NULL, « à remplir », la ou la
-- base n'a pas la donnee. Le chiffre d'affaires est le total I du modele 322-2 (decision du 03/10/2026) ; le resultat
-- net comptable, la ligne R_RE.
CREATE   VIEW dbo.v_rapport_expert_comptable AS
SELECT ld.entite, ld.arrete, e.soumise_commissariat_comptes,
       a.forme AS forme_arretee, fa.libelle AS forme_arretee_libelle, a.arretee_par, a.arretee_le,
       p.forme_proposee, fp.libelle AS forme_proposee_libelle,
       COALESCE(fa.code, fp.code) AS forme_du_texte,
       COALESCE(fa.intitule, fp.intitule) AS intitule,
       COALESCE(fa.texte, fp.texte) AS texte,
       a.motif_limitation, a.motif_considerations_particulieres,
       CAST(CASE r.type_arrete WHEN 'ANNUEL' THEN N'annuels' WHEN 'SEMESTRIEL' THEN N'intermédiaires' END AS NVARCHAR (20)) AS comptes_annuels_ou_intermediaires,
       e.denomination AS entite_concernee,
       r.exercice, r.date_arrete,
       m.total_actif AS total_du_bilan,
       m.total_i AS chiffre_d_affaires,
       N'Total I du compte de résultat, modèle 322-2 : produits de l''activité immobilière' AS chiffre_d_affaires_lecture,
       m.resultat AS resultat_net_comptable,
       CAST(NULL AS DATE) AS lettre_de_mission_du,
       CAST(NULL AS NVARCHAR (2000)) AS description_des_points,
       CAST(NULL AS NVARCHAR (200)) AS lieu_date_signature,
       N'NP 2300, paragraphes 17 à 22 et A10, exemples E1 à E4' AS source
FROM dbo.v_livrables_dus ld
JOIN dbo.ref_arrete r ON r.entite = ld.entite AND r.arrete = ld.arrete
JOIN dbo.ref_entite e ON e.code = ld.entite AND e.forme_vehicule IS NOT NULL
LEFT JOIN dbo.attestation a ON a.entite = ld.entite AND a.arrete = ld.arrete AND a.arretee_le IS NOT NULL
LEFT JOIN dbo.ref_forme_rapport fa ON fa.code = a.forme
LEFT JOIN dbo.v_forme_attestation_proposee p ON p.entite = ld.entite AND p.arrete = ld.arrete
LEFT JOIN dbo.ref_forme_rapport fp ON fp.code = p.forme_proposee
LEFT JOIN (SELECT entite, arrete,
                  MAX(CASE WHEN code = 'A_TOTAL' THEN exercice_n END) AS total_actif,
                  MAX(CASE WHEN code = 'R_TI' THEN exercice_n END) AS total_i,
                  MAX(CASE WHEN code = 'R_RE' THEN exercice_n END) AS resultat
           FROM dbo.fn_ligne_etat_montant() WHERE code IN ('A_TOTAL', 'R_TI', 'R_RE') GROUP BY entite, arrete) m
       ON m.entite = ld.entite AND m.arrete = ld.arrete
WHERE ld.livrable = 'ATTESTATION';

GO

