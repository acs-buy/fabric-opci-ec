-- =====================================================================
-- LES GARDES DE ROLE, POSEES PARTOUT, ET LA CONCORDANCE DES ARTICLES.
--
-- CE QUE LE RELEVE DU 05/09/2026 A MONTRE. Douze referentiels sur 35
-- n'avaient aucune garde de role : ref_cas_eligibilite,
-- ref_categorie_actif_cmf, ref_ligne_annexe, ref_ligne_etat,
-- ref_livrable, ref_obligation_distribution, ref_ratio,
-- ref_rubrique_resultat, ref_tableau_annexe, saisie_annexe et les 2
-- referentiels poses la veille. Tous sont nes des scripts 106 a 121, qui
-- appelaient pr_proteger_referentiel, la protection de SEMIS, sans
-- appeler pr_garder_referentiel, la garde de ROLE. Les 2 mecanismes sont
-- distincts et se cumulent : le premier refuse une ecriture hors semis,
-- le second refuse une ecriture par un compte sans le role voulu.
--
-- LA CAUSE EST L'APPEL MANUEL, ET C'EST ELLE QUI EST CORRIGEE. Poser les
-- 12 gardes a la main laisserait le 13e referentiel sans garde le jour
-- ou un script en creerait un. La procedure pr_garder_tous_referentiels
-- parcourt dbo.ref_referentiel et pose la garde sur chaque table qui y
-- est inscrite : inscrire un referentiel suffit desormais a le garder.
--
-- LA FONCTION DE GARDE LISAIT UN NOM DE TABLE EN DUR. Elle accordait au
-- reviseur le droit d'ecrire ref_question par un test litteral sur ce
-- nom, alors que dbo.ref_referentiel porte deja la colonne qui_tient,
-- qui dit pour chaque table qui la tient. La fonction lit desormais
-- cette colonne : le referentiel gouverne, le code ne redit plus ce que
-- la donnee dit deja.
--
-- LES 3 VALEURS DE qui_tient, ET CE QU'ELLES EMPORTENT.
--   ASSOCIE  : l'associe seul ecrit. Trente tables sur 35.
--   REVISEUR : l'associe ou le reviseur ecrivent. ref_question et
--              saisie_annexe.
--   BASE     : valeurs livrees avec la base, l'associe seul ecrit, et le
--              message le dit. CE N'EST PAS UN REFUS TOTAL : ref_entite
--              y figure, et le cabinet doit pouvoir y ajouter un
--              dossier. Le refus total ferait de la base un objet mort.
--
-- LE SEMIS RESTE AUTORISE. Un script qui a appele pr_debut_semis ecrit
-- sans passer la garde de role : c'est alors la protection de semis qui
-- gouverne. Sans cette reserve, la garde et la protection se
-- contrediraient, et aucune sequence ne se rejouerait.
--
-- LA CONCORDANCE DES ARTICLES. Le controle C13 comptait 6 ecarts : les
-- articles L. 214-37, L. 214-39, L. 214-82, R. 214-82, R. 214-83 et
-- R. 214-125 etaient dans dbo.ref_reference et absents de
-- dbo.ref_article. Ils y entrent, aux rangs 9 a 14 de la source CMF.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : la fonction de garde lit le referentiel --------------------
CREATE   FUNCTION dbo.fn_peut_ecrire_referentiel (
    @table_nom  VARCHAR (120),
    @connexion  NVARCHAR (400)
)
RETURNS BIT
AS
BEGIN
    DECLARE @oui BIT = 0;

    -- Un semis en cours ecrit : la protection de semis gouverne alors.
    IF TRY_CAST(SESSION_CONTEXT(N'semis') AS INT) = 1
        RETURN 1;

    DECLARE @qui_tient VARCHAR (20) =
        (SELECT TOP 1 qui_tient FROM dbo.ref_referentiel
         WHERE table_nom = @table_nom);

    -- Une table non inscrite au referentiel n'est pas gardee par role :
    -- la garde ne se pose que sur ce qui y est inscrit.
    IF @qui_tient IS NULL
        RETURN 1;

    -- L'associe ecrit tous les referentiels.
    IF EXISTS (SELECT 1 FROM dbo.role_mission r
               WHERE r.connexion = @connexion AND r.role = 'ASSOCIE'
                 AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                 AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
        SET @oui = 1;

    -- Le reviseur ecrit les tables que le referentiel lui confie.
    -- La revue du 04/09/2026 a ECARTE la restriction au cycle du
    -- reviseur : la table des roles ne porte pas de cycle.
    IF @oui = 0 AND @qui_tient = 'REVISEUR'
       AND EXISTS (SELECT 1 FROM dbo.role_mission r
                   WHERE r.connexion = @connexion AND r.role = 'REVISEUR'
                     AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                     AND (r.au IS NULL
                          OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
        SET @oui = 1;

    RETURN @oui;
END

GO

