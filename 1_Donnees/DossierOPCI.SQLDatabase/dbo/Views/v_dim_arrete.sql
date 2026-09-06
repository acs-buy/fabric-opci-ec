-- =====================================================================
-- Tranche T5 : la dimension des arretes, pour le filtrage des ecrans.
-- Un arrete existe des qu'un lot, une feuille ou un arrete ouvert le
-- porte. A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

CREATE   VIEW dbo.v_dim_arrete AS
SELECT arrete FROM dbo.lot_ecritures
UNION
SELECT arrete FROM dbo.feuille_travail
UNION
SELECT arrete FROM dbo.arrete_mission
UNION
SELECT arrete FROM dbo.parts_en_circulation;

GO

