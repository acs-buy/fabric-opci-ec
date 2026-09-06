
-- --- 4 : le 275 compare a sa cible --------------------------------------
CREATE   VIEW dbo.v_controle_ecart_275_inexplique AS
SELECT p.entite, p.arrete,
       p.ecart_275_cible                AS ecart_275_justifie,
       p.ecart_275                      AS ecart_275_comptabilise,
       p.ecart_275 - p.ecart_275_cible  AS ecart_inexplique,
       N'le compte 275 de la mère ne coïncide pas avec ce que la valeur actuelle des titres, article 212-4, justifie au-delà de leur coût : (Σ quote-part × actif net réévalué) - compte 254. Passer la reprise par pr_reprendre_ecart_275.'
                                        AS lecture
FROM dbo.v_reprise_275_a_passer p
JOIN dbo.ref_arrete r ON r.entite = p.entite AND r.arrete = p.arrete
WHERE r.porte_balance = 1
  AND ABS(p.ecart_275 - p.ecart_275_cible) > 0.005;

GO

