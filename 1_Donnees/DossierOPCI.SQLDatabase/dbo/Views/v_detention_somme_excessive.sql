

-- ---------------------------------------------------------------------
-- BLOC 2 : v_detention_somme_excessive. La somme des quotes-parts d'une
-- même filiale, à un arrêté, n'excède pas 1. Seule dans son lot.
-- Regroupement par filiale et arrêté.
-- ATTENDU : 0 ligne est la condition d'un calcul de valorisation.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_detention_somme_excessive AS
SELECT
    d.entite_fille        AS entite_fille,
    d.arrete              AS arrete,
    SUM(d.quote_part)     AS somme_des_quotes_parts,
    COUNT(*)              AS detenteurs
FROM dbo.detention d
GROUP BY d.entite_fille, d.arrete
HAVING SUM(d.quote_part) > 1;

GO

