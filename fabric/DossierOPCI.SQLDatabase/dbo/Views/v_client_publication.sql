
-- --- 6 : ce que le client lit de la publication -------------------------
CREATE   VIEW dbo.v_client_publication AS
SELECT a.cle_arrete, a.entite, a.arrete,
       a.cloture_visee_le, a.cloture_visee_par,
       p.publiee_le, p.publiee_par
FROM dbo.v_arrete_client a
LEFT JOIN (SELECT entite, arrete, MAX(publiee_le) AS publiee_le,
                  MAX(publiee_par) AS publiee_par
           FROM dbo.publication_client WHERE etat IN ('EN_COURS', 'PUBLIEE')
           GROUP BY entite, arrete) p ON p.entite = a.entite AND p.arrete = a.arrete;
-- EN_COURS compte : la photographie est prise pendant cet etat, et un rafraichissement
-- en echec ne remplace pas la photographie precedente (import transactionnel).

GO

