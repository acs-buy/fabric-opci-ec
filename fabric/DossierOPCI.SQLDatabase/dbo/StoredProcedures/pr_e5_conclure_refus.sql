-- ------------------------------------------------------------------ le refus apres le ROLLBACK : journal_refus et message, sans 2e ligne
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- Appelee dans le CATCH d'une procedure d'ecran, apres son ROLLBACK. Appel direct (@tc nul, plus aucune transaction) :
-- la ligne de journal_refus, sauf si une garde l'a deja inscrite depuis l'entree de la procedure (id posterieur a
-- @journal_avant : la garde fait ROLLBACK, INSERT, puis THROW, objet n° 17), puis le message REFUS sous l'entite recue
-- (« - », le vehicule pour le n° 24). La ligne d'une garde se reconnait a son texte, ou, quel que soit le texte recu
-- (erreur 266 ou 3609 au lieu du THROW de la garde), a son auteur : un declencheur (tr_...) qui a refuse pour @par depuis
-- l'entree ; le message pose est alors le sien, en francais. Sous la transaction d'un appelant (Data function), rien :
-- son rollback effacerait l'ecriture, et la fonction pose refus et message apres lui (pr_journaliser_refus, script 220 ;
-- point 19 de la decoupe, lot 4). Ne refuse jamais : un refus qui ne se journalise pas ne masque pas celui qu'il rapporte.
-- Signature figee : le script 324 l'appelle.
CREATE   PROCEDURE dbo.pr_e5_conclure_refus
    @tc            INT,
    @journal_avant INT,
    @procedure_nom VARCHAR (60),
    @par           NVARCHAR (400),
    @entite        VARCHAR (20),
    @message       NVARCHAR (2000)
AS
BEGIN
    SET NOCOUNT ON;
    IF @tc <> 0 OR @@TRANCOUNT <> 0 RETURN;
    SET @par = NULLIF(LTRIM(RTRIM(@par)), N'');
    SET @message = NULLIF(LTRIM(RTRIM(@message)), N'');
    IF @par IS NULL OR @message IS NULL RETURN;
    BEGIN TRY
        DECLARE @garde NVARCHAR (2000) =
            (SELECT TOP (1) j.message FROM dbo.journal_refus j
             WHERE j.id > ISNULL(@journal_avant, 0) AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
             ORDER BY j.id DESC);
        IF @garde IS NOT NULL
            SET @message = @garde;
        ELSE IF NOT EXISTS (SELECT 1 FROM dbo.journal_refus j WHERE j.id > ISNULL(@journal_avant, 0) AND j.message = LEFT(@message, 2000))
            INSERT INTO dbo.journal_refus (procedure_nom, entite, message, refuse_pour, refuse_le)
            VALUES (@procedure_nom, CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_entite e WHERE e.code = @entite) THEN @entite END,
                    LEFT(@message, 2000), LEFT(@par, 200), SYSUTCDATETIME());
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'REFUS', @entite = @entite,
             @procedure_nom = @procedure_nom;
    END TRY
    BEGIN CATCH
    END CATCH;
END;

GO

