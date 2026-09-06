
-- --- 3 : le niveau 2, sans aucun litteral d'article ------------------
CREATE   VIEW dbo.v_patrimoine_valorise AS
SELECT v.entite, v.arrete, v.exercice, v.code_actif, v.nature, v.poste_bilan,
       CASE WHEN v.nature IN ('ACTION_ASSIMILEE', 'OBLIGATION_ASSIMILEE',
                              'TITRE_CREANCE', 'PART_OPC', 'DEPOT',
                              'OPERATION_TEMPORAIRE', 'INSTRUMENT_TERME')
            THEN 'INSTRUMENT' ELSE 'IMMEUBLE' END AS famille,
       v.valeur_comptable, v.valeur_actuelle, v.difference_estimation,
       v.source, v.article, v.norme, v.reference, v.citation_courte,
       CAST(NULL AS VARCHAR (20))  AS entite_liee,
       CAST(NULL AS DECIMAL (12,6)) AS quote_part
FROM dbo.v_valeur_actuelle_actif v
UNION ALL
-- Les titres : l'article vient de la nature, non d'un litteral.
SELECT t.entite_mere, t.arrete,
       (SELECT MIN(r.exercice) FROM dbo.ref_arrete r
        WHERE r.entite = t.entite_mere AND r.arrete = t.arrete),
       a.code, a.nature, a.poste_bilan, 'TITRE',
       CAST(t.valeur_comptable_titres AS DECIMAL (19,2)),
       CAST(t.valeur_actuelle_titres AS DECIMAL (19,2)),
       CAST(t.difference_estimation_titres AS DECIMAL (19,2)),
       'ANR_FILIALE',
       CAST(rf.reference AS VARCHAR (40)), rf.norme, rf.reference,
       rf.citation_courte,
       t.entite_fille, CAST(t.quote_part AS DECIMAL (12,6))
FROM dbo.v_titres_valeur_actuelle t
JOIN dbo.actif a ON a.entite_detentrice = t.entite_mere
                AND a.entite_liee = t.entite_fille
                AND a.nature = 'TITRES_ENTITE_IMMOBILIERE'
LEFT JOIN dbo.v_reference rf
       ON rf.id = dbo.fn_reference_evaluation('TITRES_ENTITE_IMMOBILIERE')
UNION ALL
-- Les comptes courants : l'article de la cascade quand elle deprecie,
-- celui de la nature sinon. Les 2 viennent du referentiel.
SELECT a.entite_detentrice, r.arrete, r.exercice,
       a.code, a.nature, a.poste_bilan, 'COMPTE_COURANT',
       CAST(a.prix_de_revient AS DECIMAL (19,2)),
       CAST(COALESCE(rc.montant_revise,
                     a.prix_de_revient
                   + COALESCE(c.difference_estimation_compte_courant, 0))
            AS DECIMAL (19,2)),
       CAST(COALESCE(rc.montant_revise - a.prix_de_revient,
                     c.difference_estimation_compte_courant, 0)
            AS DECIMAL (19,2)),
       CASE WHEN rc.id IS NOT NULL THEN 'REVISION'
            WHEN COALESCE(c.difference_estimation_compte_courant, 0) <> 0
                 THEN 'CASCADE_212_5'
            ELSE 'NOMINAL' END,
       CAST(rcc.reference AS VARCHAR (40)), rcc.norme, rcc.reference,
       rcc.citation_courte,
       a.entite_liee, CAST(NULL AS DECIMAL (12,6))
FROM dbo.actif a
JOIN dbo.ref_arrete r ON r.entite = a.entite_detentrice AND r.porte_balance = 1
LEFT JOIN dbo.v_cascade_212_5 c ON c.entite_mere = a.entite_detentrice
                               AND c.entite_fille = a.entite_liee
                               AND c.arrete = r.arrete
LEFT JOIN dbo.revision_compte_courant rc ON rc.entite = a.entite_detentrice
                                        AND rc.entite_fille = a.entite_liee
                                        AND rc.arrete = r.arrete
-- La cascade de l'article 212-5 quand elle deprecie, l'article de la
-- nature sinon : les 2 references sont lues, jamais ecrites.
LEFT JOIN dbo.v_reference rcc
       ON rcc.id = CASE
              WHEN COALESCE(c.difference_estimation_compte_courant, 0) <> 0
                   THEN (SELECT id FROM dbo.ref_reference
                         WHERE norme = 'ANC2021-09' AND reference = '212-5')
              ELSE dbo.fn_reference_evaluation('AVANCE_COMPTE_COURANT') END
WHERE a.nature = 'AVANCE_COMPTE_COURANT'
  AND (a.date_acquisition IS NULL OR a.date_acquisition <= r.date_arrete);

GO

