
-- --- 5 : la concordance du rejeu, compte par compte -------------------
-- Le rejeu se charge sur un arrete distinct, sans quoi il s'ajouterait a
-- la balance qu'il doit reproduire. La vue apparie les 2 arretes.
CREATE   VIEW dbo.v_rejeu_concordance AS
SELECT o.entite,
       o.arrete                       AS arrete_origine,
       r.arrete                       AS arrete_rejeu,
       o.compte,
       o.b0_initiale                  AS origine_b0,
       o.balance_finale               AS origine_finale,
       r.b0_initiale                  AS rejeu_b0,
       CAST(r.b0_initiale - o.b0_initiale AS DECIMAL (19,2))
                                      AS ecart_profil_source,
       CAST(r.b0_initiale - o.balance_finale AS DECIMAL (19,2))
                                      AS ecart_profil_avec_ajustements
FROM dbo.v_balance o
JOIN dbo.v_balance r
  ON r.entite = o.entite AND r.compte = o.compte
 AND r.arrete <> o.arrete;

GO

