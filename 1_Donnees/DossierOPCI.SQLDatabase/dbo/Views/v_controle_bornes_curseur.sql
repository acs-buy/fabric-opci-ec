
-- 4b : une borne exacte absente de la liste. C'est l'invariant du
--      curseur : sans les 2 bornes, la simulation ne peut atteindre ni
--      l'obligation ni le plafond.
CREATE   VIEW dbo.v_controle_bornes_curseur AS
SELECT s.cle_arrete, s.obligation_minimale, s.plafond_distribuable,
       (SELECT COUNT(*) FROM dbo.v_montant_simulable m
        WHERE m.cle_arrete = s.cle_arrete
          AND m.montant_simulable = s.obligation_minimale) AS borne_basse_presente,
       (SELECT COUNT(*) FROM dbo.v_montant_simulable m
        WHERE m.cle_arrete = s.cle_arrete
          AND m.montant_simulable = s.plafond_distribuable) AS borne_haute_presente
FROM dbo.v_simulation_distribution s
WHERE s.plafond_distribuable >= s.obligation_minimale
  AND (NOT EXISTS (SELECT 1 FROM dbo.v_montant_simulable m
                   WHERE m.cle_arrete = s.cle_arrete
                     AND m.montant_simulable = s.obligation_minimale)
    OR NOT EXISTS (SELECT 1 FROM dbo.v_montant_simulable m
                   WHERE m.cle_arrete = s.cle_arrete
                     AND m.montant_simulable = s.plafond_distribuable));

GO

