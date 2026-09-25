

-- --- 3 : la lecture des 4 natures de flux ----------------------------
CREATE   VIEW dbo.v_flux_intragroupe AS
SELECT f.id, f.arrete, f.nature,
       CASE f.nature
            WHEN 'PRET'           THEN N'Prêt entre entités'
            WHEN 'INTERET'        THEN N'Intérêts sur prêt interne'
            WHEN 'DIVIDENDE'      THEN N'Dividende reçu d''une filiale'
            WHEN 'VENTE_IMMEUBLE' THEN N'Vente d''immeuble entre entités'
            END                              AS nature_libelle,
       f.entite_debitrice, ed.denomination   AS debitrice_libelle,
       f.entite_creditrice, ec.denomination  AS creditrice_libelle,
       f.compte_debiteur, f.compte_crediteur, f.code_actif, f.montant,
       -- Le flux est-il neutralise dans la rationalisation de l'OPCI ?
       -- Seuls ceux dont la mere est partie prenante le sont a son
       -- niveau ; une vente entre 2 filiales se neutralise au niveau du
       -- groupe, non a celui de l'OPCI seul.
       CAST(CASE WHEN f.entite_creditrice = 'OMEGA-OPCI'
                   OR f.entite_debitrice = 'OMEGA-OPCI'
                 THEN 1 ELSE 0 END AS BIT)   AS neutralise_chez_l_opci,
       f.source
FROM dbo.flux_intragroupe f
LEFT JOIN dbo.ref_entite ed ON ed.code = f.entite_debitrice
LEFT JOIN dbo.ref_entite ec ON ec.code = f.entite_creditrice;

GO

