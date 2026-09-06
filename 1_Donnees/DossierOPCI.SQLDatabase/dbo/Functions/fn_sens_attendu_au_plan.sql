-- =====================================================================
-- LE SENS D'UN COMPTE SE JUGE AU PLAN QUI LE PORTE.
--
-- LE DEFAUT QUE LA TRADUCTION A REVELE. La fonction fn_sens_attendu
-- portait les regles de sens du plan de l'article 411-3 : elle y traite
-- le 512 comme un emprunt, donc crediteur. Depuis que les 12 filiales
-- tiennent leur propre plan, leur 512 est LEUR BANQUE, debitrice, et le
-- controle du sens la signalait a tort. Mesure du 05/09/2026 :
-- v_controle_sens_contredit est passe de 0 a 25 apres la traduction,
-- sans qu'aucune ecriture ne soit fausse.
--
-- LA REGLE : LE SENS SUIT LE PLAN. Une entite qui tient son propre plan
-- voit ses comptes juges aux regles du plan comptable general ; les
-- autres restent jugees aux regles du plan de l'article 411-3. La seule
-- divergence entre les 2 porte sur les comptes 512 et 513 : emprunts
-- dans le plan des OPCI, banques et etablissements financiers dans le
-- plan comptable general, verifie le 05/09/2026 sur le plan publie par
-- l'ANC, article 932-1 du reglement n° 2014-03, et sur l'article 411-3
-- du reglement ANC n° 2021-09 reproduit au recueil.
--
-- DEUX VUES CESSENT D'ETRE COMPTEES COMME DES ANOMALIES.
-- v_controle_sens_du_solde rend les 255 soldes du dossier avec leur
-- sens : c'est la matiere du controle, non son resultat.
-- v_controle_double_chemin_de_compte decrit l'etat de la correspondance,
-- 73 natures ayant 2 comptes tant que toutes les entites ne sont pas
-- traduites. Les 2 passent au genre MESURE, avec leur motif.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : le sens attendu, selon le plan de l'entite -----------------
CREATE   FUNCTION dbo.fn_sens_attendu_au_plan (
    @entite VARCHAR (20),
    @compte VARCHAR (20)
)
RETURNS VARCHAR (10)
AS
BEGIN
    DECLARE @propre INT =
        ISNULL((SELECT TOP 1 plan_propre_en_service FROM dbo.ref_entite
                WHERE code = @entite), 0);

    -- Les exceptions communes aux 2 plans, testees avant la classe.
    IF @compte LIKE '119%' OR @compte LIKE '129%' OR @compte LIKE '1291%'
        RETURN 'DEBIT';
    IF @compte LIKE '28%' OR @compte LIKE '29%'
        RETURN 'CREDIT';

    -- LA SEULE DIVERGENCE ENTRE LES 2 PLANS. Le 512 et le 513 designent
    -- des emprunts dans le plan de l'article 411-3, et des comptes de
    -- banque dans le plan comptable general.
    IF @compte LIKE '512%' OR @compte LIKE '513%'
        RETURN CASE WHEN @propre = 1 THEN 'DEBIT' ELSE 'CREDIT' END;
    IF @compte LIKE '519%'
        RETURN 'CREDIT';
    -- Les emprunts du plan comptable general sont en classe 16.
    IF @propre = 1 AND @compte LIKE '16%'
        RETURN 'CREDIT';

    IF LEFT(@compte, 1) = '1' RETURN 'CREDIT';
    IF LEFT(@compte, 1) = '2' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '5' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '6' RETURN 'DEBIT';
    IF LEFT(@compte, 1) = '7' RETURN 'CREDIT';
    RETURN 'MIXTE';
END;

GO

