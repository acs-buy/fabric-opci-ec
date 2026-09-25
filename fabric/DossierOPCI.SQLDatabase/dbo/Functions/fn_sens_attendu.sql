-- =====================================================================
-- LE SENS D'UN SOLDE, JUGE AU PLAN DE L'ENTITE, ET LE RECLASSEMENT DU
-- FINANCEMENT INTRAGROUPE.
--
-- CE QUE LA VERIFICATION DU 05/09/2026 ETABLIT. Les soldes des 12
-- filiales sont TOUS dans leur sens attendu, LU AU PLAN DU MODELE : le
-- capital, le report a nouveau et le resultat sont crediteurs, les
-- constructions et la tresorerie debitrices, le compte 512 crediteur
-- puisqu'il y designe des emprunts, les charges et les produits soldes
-- par la determination du resultat.
--
-- CE QUE LA MEME VERIFICATION ETABLIT, LUE AU PLAN DECLARE DES FILIALES.
-- Le plan de chaque filiale designe le 512 comme « Comptes a vue ». Un
-- solde crediteur y serait un DECOUVERT BANCAIRE, et il porte
-- 229 600 000,00 cumules sur les 3 arretes. Un decouvert de cette
-- ampleur n'a pas de sens pour une societe civile immobiliere dont le
-- seul actif est un immeuble.
-- LES DEUX LECTURES NE PEUVENT PAS ETRE VRAIES ENSEMBLE. Les ecritures
-- sont en plan du modele, et le plan declare des filiales decrit une
-- comptabilite qu'elles ne tiennent pas encore.
--
-- LE SENS ATTENDU, ET D'OU IL VIENT. La regle se lit sur la classe du
-- compte, telle que le plan de comptes general la fixe, verifie le
-- 05/09/2026 sur le plan publie par l'Autorite des normes comptables,
-- article 932-1 du reglement ANC n° 2014-03 :
--   classe 1, capitaux propres et emprunts : CREDITEUR, sauf le report a
--     nouveau debiteur, la perte de l'exercice et les acomptes verses ;
--   classe 2, immobilisations : DEBITEUR, sauf les amortissements et les
--     depreciations ;
--   classe 5, comptes financiers : DEBITEUR, sauf les emprunts et les
--     concours bancaires courants ;
--   classe 6, charges : DEBITEUR ; classe 7, produits : CREDITEUR. Un
--     solde nul y est normal apres la determination du resultat.
--   classe 3 et classe 4 : le sens depend du compte, elles ne sont pas
--     jugees.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : le sens attendu de chaque compte ---------------------------
CREATE   FUNCTION dbo.fn_sens_attendu (@compte VARCHAR (20))
RETURNS VARCHAR (10)
AS
BEGIN
    -- Les exceptions se testent AVANT la classe : un compte les porte
    -- par son numero, non par sa famille.
    IF @compte LIKE '119%' OR @compte LIKE '129%' OR @compte LIKE '1291%'
        RETURN 'DEBIT';
    IF @compte LIKE '28%' OR @compte LIKE '29%'
        RETURN 'CREDIT';
    IF @compte LIKE '512%' OR @compte LIKE '513%' OR @compte LIKE '519%'
        RETURN 'CREDIT';

    IF LEFT(@compte, 1) = '1' RETURN 'CREDIT';
    IF LEFT(@compte, 1) = '2' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '5' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '6' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '7' RETURN 'CREDIT';
    RETURN 'MIXTE';
END;

GO

