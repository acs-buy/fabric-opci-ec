-- =====================================================================
-- O9 ET O11 : LES ECRITURES D'UN COMPTE, LA CLASSE DANS LA BALANCE,
-- L'ENTITE LIEE D'UN RATTACHEMENT ET LES PARTS A L'ARRETE.
--
-- O9, CE QUE L'ECRAN E4-0b DEMANDE. Un clic sur une ligne de balance
-- doit ouvrir les ecritures du compte pour l'arrete, avec le lot, sa
-- famille, son etat, et l'origine de l'ecriture, question de feuille ou
-- actif. dbo.v_balance rend les soldes par compte mais aucune vue ne
-- rend le detail. Elle ne rend pas non plus la classe du compte, que
-- l'ecran groupe.
--
-- O11, CE QUE L'ECRAN E1-A2 DEMANDE. Le rattachement d'un compte de
-- filiale au plan de l'OPCI ne dit pas a quelle ENTITE le compte se
-- rapporte quand il porte une operation entre entites : le compte 4551
-- d'une filiale est la dette envers la mere, et son symetrique chez la
-- mere est une creance. Sans l'entite liee, le controle de symetrie du
-- script 94 doit deviner le couple. Et les parts a l'arrete, que l'etape
-- 1 saisit, ne sont portees par aucune table : dbo.mouvement_porteur
-- porte les mouvements, non le nombre de parts arrete a une date.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : O9, la classe du compte dans la balance --------------------
-- Elle se lit du premier chiffre du numero de compte. Le plan de
-- l'article 411-3 a 8 classes, de 1 a 8, et la classe 9 porte le hors
-- bilan, posee par le script 08.
CREATE   FUNCTION dbo.fn_classe_du_compte (@compte VARCHAR (20))
RETURNS VARCHAR (30)
AS
BEGIN
    DECLARE @c CHAR (1) = LEFT(@compte, 1);
    RETURN CASE @c
        WHEN '1' THEN N'1 Capitaux'
        WHEN '2' THEN N'2 Actifs a caractere immobilier'
        WHEN '3' THEN N'3 Depots et instruments financiers non immobiliers'
        WHEN '4' THEN N'4 Comptes de tiers'
        WHEN '5' THEN N'5 Comptes financiers'
        WHEN '6' THEN N'6 Charges'
        WHEN '7' THEN N'7 Produits'
        WHEN '8' THEN N'8 Comptes speciaux'
        WHEN '9' THEN N'9 Engagements hors bilan'
        ELSE N'classe inconnue' END;
END

GO

