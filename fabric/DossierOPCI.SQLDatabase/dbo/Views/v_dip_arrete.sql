
-- Le grain : un arrete auquel le DIP est du, et l'arrete dont la rubrique 6 lit l'obligation.
CREATE   VIEW dbo.v_dip_arrete AS
SELECT d.entite, d.arrete, d.entite + '|' + d.arrete AS cle_arrete, r.type_arrete,
       CASE WHEN r.type_arrete = 'ANNUEL' THEN d.arrete ELSE a.arrete_n_1 END AS exercice_distribution
FROM dbo.v_livrables_dus d
JOIN dbo.ref_arrete r ON r.entite = d.entite AND r.arrete = d.arrete
LEFT JOIN dbo.v_arrete_etat a ON a.entite = d.entite AND a.arrete = d.arrete
WHERE d.livrable = 'DIP';

GO

