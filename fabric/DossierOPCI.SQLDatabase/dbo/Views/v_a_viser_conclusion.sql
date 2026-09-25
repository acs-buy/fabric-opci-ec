
CREATE   VIEW dbo.v_a_viser_conclusion AS
SELECT f.entite, f.arrete, f.cycle, 'CONCLUSION' AS nature,
       CAST(f.cote AS VARCHAR (30))                   AS objet_ref,
       CAST(NULL AS INT)                              AS objet_id,
       CAST(N'Feuille ' + f.cote + N', conclusion ' + f.forme_conclusion
            AS NVARCHAR (300))                        AS libelle,
       f.preparateur                                  AS propose_par,
       COALESCE(f.conclue_le, f.prepare_le)           AS propose_le,
       CAST(NULL AS INT)                              AS lignes,
       CAST(NULL AS DECIMAL (19,2))                   AS montant,
       f.forme_conclusion                             AS etat,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       f.message_ecran
FROM dbo.feuille_travail f
LEFT JOIN dbo.v_derniere_decision d ON d.nature = 'CONCLUSION'
                                   AND d.objet_ref = f.cote
WHERE f.forme_conclusion IS NOT NULL
  -- Ni visee, ni renvoyee apres sa conclusion : une conclusion renvoyee
  -- attend le preparateur, non le chef de mission.
  AND (d.decision IS NULL
       OR (d.decision = 'RENVOYE' AND d.decide_le < f.conclue_le));

GO

