-- =====================================================================
-- Le montant simulable : les valeurs que le curseur de la restitution
-- client propose, exprimees en euros et non en positions.
-- Arbitrage du candidat du 03/09/2026 : le curseur va de l'obligation
-- minimale au plafond des sommes distribuables. Les 2 bornes etant
-- calculees par dossier et par exercice, la liste des valeurs vient de la
-- base et non d'une table de parametre en dur.
-- Le pas est de 100,00, et les 2 bornes EXACTES sont toujours presentes
-- meme si elles ne tombent pas sur le pas : sans elles, le curseur ne
-- pourrait atteindre ni l'obligation ni le plafond, et l'invariant de la
-- simulation ne tiendrait pas.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : la suite des entiers, 0 a 4095 --------------------------------
-- Bornee a 4 096 valeurs : au pas de 100,00 cela couvre un intervalle de
-- 409 500,00 entre les 2 bornes. Le controle du bloc 4 refuse tout
-- dossier qui depasserait, plutot que de rendre un curseur tronque en
-- silence.
CREATE   VIEW dbo.v_suite_entiers AS
WITH n2  AS (SELECT 0 AS n UNION ALL SELECT 1),
     n4  AS (SELECT 0 AS n FROM n2 a CROSS JOIN n2 b),
     n16 AS (SELECT 0 AS n FROM n4 a CROSS JOIN n4 b),
     n256 AS (SELECT 0 AS n FROM n16 a CROSS JOIN n16 b),
     n4096 AS (SELECT 0 AS n FROM n256 a CROSS JOIN n16 b)
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n FROM n4096;

GO

