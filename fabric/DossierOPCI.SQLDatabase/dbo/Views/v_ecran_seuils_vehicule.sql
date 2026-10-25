-- Objet n° 23 de l'ecran 5 (lot 1) : les seuils propres a un vehicule, l'expression eprouvee de B20
-- (65_JOURNAL/preuves_ecran_5/besoins_base_20261016.md) sur les colonnes reelles. Les limites de ref_ratio_memoire
-- dont valeur_laissee vaut GESTIONNAIRE, pour tout OPCI, ou STATUTS, pour un OPCI professionnel (est_professionnel
-- = 1 ; NULL ou 0 : grand public), d'une forme compatible, pour chaque vehicule (forme_vehicule renseignee) et chaque
-- arrete de ref_arrete ; le seuil du vehicule est la ligne de ref_ratio_vehicule en vigueur a l'arrete
-- (en_vigueur_depuis vide ou au plus tard la date d'arrete). Decision D9 : une limite RETENUE se lit « retenue par
-- le cabinet » avec le seuil du texte de ref_ratio, ou « fixee par les statuts » avec le seuil du vehicule.
-- Chaque colonne au type et a la nullabilite du tableau de B20.
-- Pose par 63_SQL/322_e5_vues_choix_inventaire_seuils_articles.sql, genere par 61_DEPLOIEMENT/generer_e5_322_vues_choix_inventaire_seuils_articles.py ;
-- ne pas modifier a la main : regenerer le script quand une table s'inscrit ou qu'une colonne change.
CREATE   VIEW dbo.v_ecran_seuils_vehicule AS
SELECT ISNULL(CAST('ref_ratio_memoire' AS VARCHAR (120)), '') AS referentiel,
       e.code AS entite, a.arrete, m.code, m.libelle,
       ISNULL(CAST(CASE m.valeur_laissee WHEN 'GESTIONNAIRE' THEN N'le gestionnaire' WHEN 'STATUTS' THEN N'les statuts' END AS NVARCHAR (20)), N'') AS laissee_aux,
       CAST(CASE WHEN e.est_professionnel = 1 THEN m.fondement_professionnel ELSE m.fondement_grand_public END
            AS NVARCHAR (600)) AS fondement,
       m.limite_texte,
       ISNULL(CAST(CASE WHEN st.code = 'RETENUE' AND v.entite IS NOT NULL THEN N'fixée par les statuts'
                        WHEN st.code = 'APPLICABLE' THEN N'applicable'
                        WHEN st.code = 'A_ARRETER' THEN N'à arrêter'
                        WHEN st.code = 'CONDITION' THEN N'sous condition'
                        WHEN st.code = 'RETENUE' THEN N'retenue par le cabinet'
                        WHEN st.code = 'SANS_OBJET' THEN N'sans objet'
                        ELSE COALESCE(lv.libelle, st.code) END AS NVARCHAR (30)), N'') AS statut,
       ISNULL(CAST(CASE WHEN e.est_professionnel = 1 THEN N'OPCI professionnel' ELSE N'OPCI grand public' END AS NVARCHAR (20)), N'') AS regime,
       ISNULL(e.forme_vehicule, '') AS forme_vehicule,
       ISNULL(CAST(CASE WHEN v.entite IS NOT NULL
                        THEN CASE WHEN m.unite_seuil = 'TAUX' THEN FORMAT(v.seuil * 100, N'0.######', 'fr-FR') + NCHAR(160) + N'%'
                                       ELSE FORMAT(v.seuil, N'0.######', 'fr-FR') END
                             + CASE v.source WHEN 'STATUTS' THEN N', fixé par les statuts'
                                             WHEN 'GESTIONNAIRE' THEN N', fixé par le gestionnaire'
                                             ELSE N', ' + v.source END
                        WHEN st.code = 'RETENUE'
                        THEN COALESCE(CASE WHEN m.unite_seuil = 'TAUX' THEN FORMAT(rr.seuil * 100, N'0.######', 'fr-FR') + NCHAR(160) + N'%'
                                                ELSE FORMAT(rr.seuil, N'0.######', 'fr-FR') END,
                                      N'seuil du texte') + N', retenu par le cabinet'
                        ELSE N'à remplir' END AS NVARCHAR (60)), N'à remplir') AS seuil_vehicule,
       ISNULL(CAST(CASE WHEN v.entite IS NULL AND st.code = 'RETENUE' THEN N'sans objet'
                        WHEN v.entite IS NULL OR v.en_vigueur_depuis IS NULL THEN N'à remplir'
                        ELSE CONVERT(NVARCHAR (10), v.en_vigueur_depuis, 103) END AS NVARCHAR (10)), N'à remplir') AS depuis,
       CAST(v.motif AS NVARCHAR (600)) AS motif,
       ISNULL(CAST(CASE WHEN v.entite IS NULL AND st.code = 'RETENUE' THEN N'sans objet'
                        WHEN ISNULL(v.motif, N'') = N'' THEN N'à remplir'
                        ELSE N'renseigné' END AS NVARCHAR (10)), N'à remplir') AS motif_court
FROM dbo.ref_entite e
JOIN dbo.ref_arrete a ON a.entite = e.code
JOIN dbo.ref_ratio_memoire m
  ON (m.forme_vehicule IS NULL OR m.forme_vehicule = e.forme_vehicule)
 AND (m.valeur_laissee = 'GESTIONNAIRE' OR (m.valeur_laissee = 'STATUTS' AND e.est_professionnel = 1))
CROSS APPLY (SELECT CASE WHEN e.est_professionnel = 1 THEN m.statut_professionnel ELSE m.statut_grand_public END AS code,
                    CASE WHEN e.est_professionnel = 1 THEN 'statut_professionnel' ELSE 'statut_grand_public' END AS colonne) st
LEFT JOIN dbo.ref_ratio_vehicule v
  ON v.entite = e.code AND v.code = m.code
 AND (v.en_vigueur_depuis IS NULL OR v.en_vigueur_depuis <= a.date_arrete)
LEFT JOIN dbo.ref_ratio rr ON rr.code = m.code
LEFT JOIN dbo.ref_libelle_valeur lv
  ON lv.table_nom = 'ref_ratio_memoire' AND lv.colonne = st.colonne AND lv.valeur = st.code
WHERE e.forme_vehicule IS NOT NULL;

GO

