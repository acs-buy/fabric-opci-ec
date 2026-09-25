-- 205 : ce qui manquait en base pour qu'un CLIENT NOUVEAU parcoure l'ecran 1, Client et Acceptation,
--       de bout en bout. Objets 1.6 (procedures des imports), 1.7 (procedures des boutons) et 1.9
--       (depot de piece) du plan PLAN_V2_ECRANS_1_2.md. Fait suite au 204.
--
-- MESURE LE 16/09/2026 AVANT D'ECRIRE, sur la base, et c'est ce qui commande la conception :
--   1. feuille_travail.arrete est NOT NULL et porte fk_ft_arrete vers ref_arrete (entite, arrete).
--      Le questionnaire d'acceptation est une feuille de phase ACCEPT : il lui faut donc un arrete
--      AU REFERENTIEL, meme pour un client qui n'a encore rien arrete.
--   2. ref_arrete n'est rempli QUE par les semis 72 et 143 : aucune procedure ne planifie un arrete.
--      pr_ouvrir_arrete ecrit arrete_mission, dont fk_am_arrete exige la ligne de ref_arrete.
--   3. pr_ouvrir_feuille refuse toute feuille sans arrete OUVERT (arrete_mission). Le declencheur
--      VIVANT tr_arrete_portes, lu par OBJECT_DEFINITION le 16/09/2026, porte 3 portes : expertise a
--      la date (50025), balances des filiales (50026), maintien du dernier annuel (50027). La porte
--      d'acceptation 50032 du script 54 n'y est PLUS : le script 57 l'a retiree, « sans arrete annuel
--      anterieur, la porte ne s'applique pas, l'acceptation repondant de l'ouverture ». Un premier
--      arrete s'ouvre donc sans acceptation visee, ce que le candidat demande : « creer un arrete
--      meme si pas valide ». Eprouve en section B de l'essai : ouvert.
--   4. Le questionnaire, lui, precede l'arrete ouvert par nature : ACC-OMEGA-OPCI ne l'a pas connu,
--      son arrete 2025-12-31 ayant ete ouvert par l'historique.
--   5. Aucune procedure ne depose une piece : les 5 semis inserent dans dbo.piece a la main.
--   6. Les 11 questions de CHOIX de l'acceptation ont options = NULL : rien ne borne leur reponse.
--
-- CE QUE LE SCRIPT DECIDE, et pourquoi c'est conforme a la maquette 71 validee le 16/09/2026 :
--   - PLANIFIER n'est pas OUVRIR. Un arrete PLANIFIE est une ligne de ref_arrete, nature MISSION,
--     est_arrete_client = 1 : le referentiel sait qu'il viendra, les imports (pr_inscrire_import lit
--     ref_arrete) et les feuilles peuvent s'y adosser. Un arrete OUVERT est une ligne d'arrete_mission,
--     et ses 3 portes ne bougent pas. L'etape 6 de la maquette, « Ouvrir l'arrete », planifie les
--     arretes de l'exercice selon la periodicite de la VL, puis ouvre le premier ; si une porte le
--     refuse, la planification reste acquise, le refus s'ecrit sur la ligne de l'arrete
--     (ref_arrete.message_ecran) et l'ouverture se rejoue depuis cette ligne. Un client neuf n'a ni
--     actif ni filiale a balance : ses portes passent, l'arrete s'ouvre, l'essai B le montre.
--   - Le questionnaire d'acceptation s'adosse a l'arrete planifie par defaut : la premiere cloture
--     de l'entite (ref_entite.cloture) posterieure ou egale a aujourd'hui. Ce n'est pas une donnee
--     inventee, c'est une consequence de la date de cloture que le client a donnee a l'etape 1. Si
--     l'etape 6 retient un autre exercice, la feuille est re-adossee et la ligne planifiee en trop
--     est retiree si rien ne la reference.
--   - Le questionnaire ne passe PAS par pr_ouvrir_feuille : l'acceptation precede tout arrete ouvert
--     par nature. Sa feuille se cree ici, avec les 110 questions de la phase ACCEPT semees dans
--     feuille_question, comme ACC-OMEGA-OPCI en porte 110.
--   - Une reponse se controle contre le TYPE de la question : OUI_NON refuse NON_APPLICABLE ;
--     OUI_NON_NA exige un motif pour NON_APPLICABLE ; CHOIX, TEXTE, DATE, MONTANT ecrivent
--     reponse_valeur, et CHOIX se borne aux options quand elles sont renseignees, pas autrement :
--     les options se completeront a l'ecran Referentiels, elles ne s'inventent pas ici.
--   - L'import d'un classeur de reponses est TOUT OU RIEN : une seule ligne fautive et rien n'entre,
--     le refus nomme la question. Un questionnaire a moitie importe n'a pas d'etat lisible.
--
-- AUCUNE LIGNE DU JEU N'EST MODIFIEE. REJOUABLE. L'essai (_scratch/ecran1/essai_205.sql) cree un client
-- OPCI-ESSAI, le fait parcourir les 6 etapes, et l'efface : 0 ligne restante, controle A12 et B7.

-- --- 1. planifier un arrete au referentiel ------------------------------------------------------
CREATE   PROCEDURE dbo.pr_planifier_arrete
    @entite        VARCHAR (20),
    @date_arrete   DATE,
    @date_cloture  DATE,            -- la cloture annuelle de l'exercice auquel l'arrete se rattache
    @type_arrete   VARCHAR (14),    -- ANNUEL, SEMESTRIEL, INTERMEDIAIRE
    @par           NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
        THROW 50221, N'Un arrêté se planifie sur un client du cabinet. L''entité désignée n''en est pas un.', 1;
    IF @type_arrete NOT IN ('ANNUEL', 'SEMESTRIEL', 'INTERMEDIAIRE')
        THROW 50222, N'Le type d''un arrêté est ANNUEL, SEMESTRIEL ou INTERMEDIAIRE.', 1;
    IF @date_arrete > @date_cloture
        THROW 50223, N'La date de l''arrêté ne dépasse pas la clôture de son exercice.', 1;
    IF @type_arrete = 'ANNUEL' AND @date_arrete <> @date_cloture
        THROW 50224, N'Un arrêté annuel se date de la clôture de l''exercice.', 1;

    DECLARE @arrete VARCHAR (20) = CONVERT(VARCHAR (10), @date_arrete, 23);
    DECLARE @exercice VARCHAR (20) = CONVERT(VARCHAR (10), @date_cloture, 23);
    IF EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        SELECT @arrete AS arrete, N'L''arrêté ' + @arrete + N' était déjà au référentiel.' AS message;
        RETURN;
    END;

    -- rang_exercice : le rang de l'exercice dans la mission, 1 pour le premier.
    DECLARE @rang SMALLINT = 1 + ISNULL((SELECT COUNT(DISTINCT exercice) FROM dbo.ref_arrete
                                         WHERE entite = @entite AND nature_technique = 'MISSION'
                                           AND exercice < @exercice), 0);
    INSERT INTO dbo.ref_arrete
        (entite, arrete, date_arrete, exercice, date_cloture, type_arrete, nature_technique,
         trimestre, rang_exercice, est_arrete_client, porte_balance)
    VALUES
        (@entite, @arrete, @date_arrete, @exercice, @date_cloture, @type_arrete, 'MISSION',
         DATEPART(QUARTER, @date_arrete), @rang, 1, 0);

    SELECT @arrete AS arrete, N'Arrêté ' + @arrete + N' planifié, exercice ' + @exercice + N'.' AS message;
END;

GO

