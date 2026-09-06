
-- --- E2 : les conclusions a viser, avec leur derniere decision -----
-- La vue n'excluait que les cotes visees : une conclusion renvoyee
-- reapparaissait a viser, sans son motif de renvoi, et le preparateur ne
-- savait pas ce qu'il devait corriger. Elle exclut desormais la cote dont
-- le dernier visa est un renvoi POSTERIEUR a conclue_le, et rend la
-- decision et son motif dans les autres cas.
CREATE   VIEW dbo.v_a_viser_conclusion AS
SELECT f.entite, f.arrete, f.cycle, 'CONCLUSION' AS nature,
       CAST(f.cote AS VARCHAR (30))                   AS objet_ref,
       CAST(N'Feuille ' + f.cote + N', conclusion ' + f.forme_conclusion
            AS NVARCHAR (300))                        AS libelle,
       f.preparateur                                  AS propose_par,
       COALESCE(f.conclue_le, f.prepare_le)           AS propose_le,
       CAST(NULL AS INT)                              AS lignes,
       CAST(NULL AS DECIMAL (19,2))                   AS montant,
       f.forme_conclusion                             AS etat
FROM dbo.feuille_travail f
LEFT JOIN dbo.v_derniere_decision d ON d.nature = 'CONCLUSION'
                                   AND d.objet_ref = f.cote
WHERE f.forme_conclusion IS NOT NULL
  -- Ni visee, ni renvoyee apres sa conclusion : une conclusion renvoyee
  -- attend le preparateur, non le chef de mission.
  AND (d.decision IS NULL
       OR (d.decision = 'RENVOYE' AND d.decide_le < f.conclue_le));

GO

