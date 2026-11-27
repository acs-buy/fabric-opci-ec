-- Les ratios du client, avec le statut de la limite selon le regime du vehicule, lu comme v_ecran_seuils_vehicule :
-- statut_professionnel pour un OPCI professionnel (ref_entite.est_professionnel = 1), statut_grand_public sinon.
-- Une limite sans objet ne conclut pas : la conclusion est le libelle du statut et aucun drapeau n'est leve. Une limite
-- retenue par le cabinet garde le seuil du texte et la conclusion du calcul ; l'article est le fondement du regime et la
-- source du seuil est le cabinet. Toute autre ligne est celle de v_client_ratio.
CREATE   VIEW dbo.v_client_ratio_regime AS
SELECT v.cle_arrete, v.entite, v.arrete, v.code, v.libelle, v.sens_libelle, v.seuil, v.ratio,
       v.numerateur, v.denominateur,
       ISNULL(CAST(CASE WHEN st.statut = 'SANS_OBJET' AND NULLIF(st.fondement, N'') IS NOT NULL THEN st.fondement
                        WHEN st.cabinet = 1 AND NULLIF(st.fondement, N'') IS NOT NULL THEN st.fondement
                        ELSE v.article END AS NVARCHAR (600)), N'') AS article,
       ISNULL(CAST(CASE WHEN st.cabinet = 1 THEN N'Seuil du cabinet' ELSE v.source_du_seuil END AS NVARCHAR (20)), N'')
                                       AS source_du_seuil,
       ISNULL(CAST(CASE WHEN st.statut = 'SANS_OBJET' THEN COALESCE(lv.libelle, st.statut) ELSE v.conclusion END
                   AS NVARCHAR (120)), N'') AS conclusion,
       CAST(CASE WHEN st.statut = 'SANS_OBJET' THEN 0 ELSE v.respecte END AS BIT)     AS respecte,
       CAST(CASE WHEN st.statut = 'SANS_OBJET' THEN 0 ELSE v.non_respecte END AS BIT) AS non_respecte,
       CAST(CASE WHEN st.statut = 'SANS_OBJET' THEN 0 ELSE v.a_valider END AS BIT)    AS a_valider,
       v.note, v.ordre
FROM dbo.v_client_ratio v
LEFT JOIN dbo.ref_entite en ON en.code = v.entite
LEFT JOIN dbo.ref_ratio_memoire m ON m.code = v.code
CROSS APPLY (SELECT CASE WHEN en.est_professionnel = 1 THEN m.statut_professionnel ELSE m.statut_grand_public END AS statut,
                    CASE WHEN en.est_professionnel = 1 THEN m.fondement_professionnel ELSE m.fondement_grand_public END
                                                                                                          AS fondement,
                    CASE WHEN en.est_professionnel = 1 THEN 'statut_professionnel' ELSE 'statut_grand_public' END AS colonne,
                    CASE WHEN (CASE WHEN en.est_professionnel = 1 THEN m.statut_professionnel ELSE m.statut_grand_public END)
                              = 'RETENUE' AND v.source_du_seuil = N'Seuil l' + NCHAR(233) + N'gal' THEN 1 ELSE 0 END AS cabinet) st
LEFT JOIN dbo.ref_libelle_valeur lv
  ON lv.table_nom = 'ref_ratio_memoire' AND lv.colonne = st.colonne AND lv.valeur = st.statut;

GO

