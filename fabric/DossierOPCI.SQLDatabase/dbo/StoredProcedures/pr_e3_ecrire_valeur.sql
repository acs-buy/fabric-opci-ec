
-- L'ecriture de la valeur retenue, controles faits : une ligne par actif, entite detentrice et arrete ; une valeur
-- renvoyee ou proposee est reprise et repasse a PROPOSE.
CREATE   PROCEDURE dbo.pr_e3_ecrire_valeur
    @arrete     VARCHAR (20),
    @code_actif VARCHAR (20),
    @valeur     DECIMAL (19,2),
    @source     NVARCHAR (60),
    @motif      NVARCHAR (600),
    @piece_id   INT,
    @par        NVARCHAR (400),
    @resultat   VARCHAR (10) OUTPUT     -- PROPOSEE, REPRISE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @detentrice VARCHAR (20) = (SELECT entite_detentrice FROM dbo.actif WHERE code = @code_actif),
            @src VARCHAR (20) = dbo.fn_e3_source_saisie(@source),
            @expertise INT = (SELECT TOP (1) e.id FROM dbo.expertise e
                              WHERE e.code_actif = @code_actif AND e.date_valeur <= TRY_CONVERT(DATE, @arrete) ORDER BY e.date_valeur DESC);
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF EXISTS (SELECT 1 FROM dbo.evaluation_actif WHERE code_actif = @code_actif AND entite = @detentrice AND arrete = @arrete)
    BEGIN
        UPDATE dbo.evaluation_actif
           SET valeur_retenue = @valeur, source = @src, expertise_id = @expertise, motif_ecart = @motif, piece_id = @piece_id,
               propose_par = @par, propose_le = SYSUTCDATETIME(), etat = 'PROPOSE', vise_par = NULL, vise_le = NULL, motif_renvoi = NULL
         WHERE code_actif = @code_actif AND entite = @detentrice AND arrete = @arrete;
        SET @resultat = 'REPRISE';
    END
    ELSE
    BEGIN
        INSERT INTO dbo.evaluation_actif (code_actif, entite, arrete, valeur_retenue, source, expertise_id, motif_ecart, piece_id,
                                          propose_par, propose_le, etat)
        VALUES (@code_actif, @detentrice, @arrete, @valeur, @src, @expertise, @motif, @piece_id, @par, SYSUTCDATETIME(), 'PROPOSE');
        SET @resultat = 'PROPOSEE';
    END;
END;

GO

