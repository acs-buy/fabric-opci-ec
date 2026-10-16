
-- L'ecriture de l'expertise, controles faits, regle du remplacement (a) a (e) de l'objet n° 1.
CREATE   PROCEDURE dbo.pr_e3_ecrire_expertise
    @arrete     VARCHAR (20),
    @code_actif VARCHAR (20),
    @valeur     DECIMAL (19,2),
    @piece_id   INT,
    @par        NVARCHAR (400),
    @resultat   VARCHAR (10)   OUTPUT,   -- INSEREE, REMPLACEE, INCHANGEE
    @ancienne   DECIMAL (19,2) OUTPUT,
    @version    INT            OUTPUT,
    @rattachee  BIT            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @d DATE = TRY_CONVERT(DATE, @arrete), @id INT, @piece_avant INT,
            @detentrice VARCHAR (20) = (SELECT entite_detentrice FROM dbo.actif WHERE code = @code_actif);
    SELECT @id = id, @ancienne = valeur_actuelle, @piece_avant = piece_id, @version = version
    FROM dbo.expertise WHERE code_actif = @code_actif AND date_valeur = @d;
    SET @rattachee = 0;
    IF @id IS NULL
    BEGIN
        -- une expertise neuve : expert et methode vides, version 1
        INSERT INTO dbo.expertise (code_actif, date_valeur, valeur_actuelle, expert, methode, piece_id, enregistre_par, enregistre_le, version)
        VALUES (@code_actif, @d, @valeur, NULL, NULL, @piece_id, @par, SYSUTCDATETIME(), 1);
        SELECT @resultat = 'INSEREE', @version = 1;
    END
    ELSE IF @ancienne = @valeur AND ISNULL(@piece_avant, -1) = @piece_id
        -- (a) meme valeur et meme piece : rien n'est ecrit dans expertise
        SET @resultat = 'INCHANGEE';
    ELSE
    BEGIN
        -- (b) la ligne en place, copiee avant d'etre remplacee
        INSERT INTO dbo.expertise_remplacee (expertise_id, code_actif, date_valeur, valeur_actuelle, expert, methode, piece_id,
                                             enregistre_par, enregistre_le, version, remplacee_par)
        SELECT id, code_actif, date_valeur, valeur_actuelle, expert, methode, piece_id, enregistre_par, enregistre_le, version, @par
        FROM dbo.expertise WHERE id = @id;
        -- (c) la saisie, version plus 1 ; (d) expert et methode vides quand la piece change
        UPDATE dbo.expertise
           SET valeur_actuelle = @valeur, piece_id = @piece_id, enregistre_par = @par, enregistre_le = SYSUTCDATETIME(),
               version = ISNULL(version, 1) + 1,
               expert = CASE WHEN ISNULL(piece_id, -1) = @piece_id THEN expert END,
               methode = CASE WHEN ISNULL(piece_id, -1) = @piece_id THEN methode END
         WHERE id = @id;
        SELECT @resultat = 'REMPLACEE', @version = ISNULL(@version, 1) + 1;
    END;
    -- (e) le rattachement de la piece a l'actif, quand elle n'en a aucun sur l'actif ni sur son entite detentrice
    IF NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement
                   WHERE piece_id = @piece_id AND (code_actif = @code_actif OR entite = @detentrice))
    BEGIN
        INSERT INTO dbo.piece_rattachement (piece_id, entite, code_actif, question_id, arrete, rattache_par, piece_attendue_id,
                                            entite_couverte, arrete_couvert)
        VALUES (@piece_id, @detentrice, @code_actif, NULL, @arrete, @par, NULL, @detentrice, @arrete);
        SET @rattachee = 1;
    END;
END;

GO

