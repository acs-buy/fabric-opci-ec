

-- ---------------------------------------------------------------------
-- BLOC 3 : v_detention_circuit. Aucun circuit de détention indirect.
-- Seule dans son lot. Le parcours se fait à arrêté constant ; la borne de
-- récursion est portée par la colonne profondeur (limite 20 liens, un
-- circuit plus long n'est pas détecté).
-- ATTENDU : 0 ligne est la condition d'un calcul de valorisation.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_detention_circuit AS
WITH chaine AS (
    SELECT
        d.arrete            AS arrete,
        d.entite_mere       AS origine,
        d.entite_fille      AS courante,
        CAST(1 AS INT)      AS profondeur
    FROM dbo.detention d
    UNION ALL
    SELECT
        c.arrete            AS arrete,
        c.origine           AS origine,
        d.entite_fille      AS courante,
        c.profondeur + 1    AS profondeur
    FROM dbo.detention d
    INNER JOIN chaine c
        ON d.entite_mere = c.courante
       AND d.arrete = c.arrete
    WHERE c.profondeur < 20
      AND c.courante <> c.origine
)
SELECT
    c.arrete              AS arrete,
    c.origine             AS entite_du_circuit,
    c.profondeur          AS liens_du_circuit
FROM chaine c
WHERE c.courante = c.origine;

GO

