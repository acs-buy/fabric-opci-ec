
-- RETIRER UNE LIGNE DU BROUILLON DES OD LIBRES, avec sa trace.
CREATE   PROCEDURE dbo.pr_retirer_ligne_od
    @entite   VARCHAR (20),
    @arrete   VARCHAR (20),
    @ligne_id INT,
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51215, N'Choisissez l''arrêté dans le sélecteur Arrêté ; les OD libres ne se modifient que sur un arrêté ouvert dont le dossier de travail n''est pas verrouillé.', 1;
    IF @ligne_id IS NULL
        THROW 51217, N'Aucune ligne du brouillon libre n''est choisie dans la liste ; l''action n''est pas exécutée.', 1;
    -- 327 fin
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50404, N'Retrait refusé : le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @cote VARCHAR (30) = 'ODL-' + LEFT(@entite, 15) + '-' + REPLACE(@arrete, '-', '');
    IF NOT EXISTS (SELECT 1 FROM dbo.ecriture_brouillon WHERE id = @ligne_id AND entite = @entite AND arrete = @arrete
                   AND feuille_cote = @cote AND question_id IS NULL)
        THROW 50403, N'Retrait refusé : la ligne désignée n''est pas au brouillon des OD libres de cet arrêté.', 1;
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.od_retrait (entite, arrete, feuille_cote, brouillon_id, compte_num, libelle, debit, credit, piece_ref, code_actif,
                                saisi_par, saisi_le, motif, retire_par)
    SELECT entite, arrete, feuille_cote, id, compte_num, libelle, debit, credit, reference, code_actif, saisi_par, saisi_le, NULL, @par
    FROM dbo.ecriture_brouillon WHERE id = @ligne_id;
    DELETE dbo.ecriture_brouillon WHERE id = @ligne_id;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    DECLARE @sd DECIMAL (19, 2), @sc DECIMAL (19, 2);
    SELECT @sd = ISNULL(SUM(debit), 0), @sc = ISNULL(SUM(credit), 0) FROM dbo.ecriture_brouillon
     WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
    SELECT @cote AS cote, @sd AS debit, @sc AS credit,
           N'Ligne retirée du brouillon des OD libres'
         + CASE WHEN @sd <> @sc THEN N'. Déséquilibre de ' + FORMAT(@sd - @sc, 'N2', 'fr-FR') + N' : la validation le refusera.' ELSE N', équilibrées.' END AS message;
END;

GO

