
CREATE   FUNCTION dbo.fn_e3_refus_valeur (@vehicule VARCHAR (20), @arrete VARCHAR (20), @code_actif VARCHAR (20),
                                                @valeur DECIMAL (19,2), @source NVARCHAR (60), @motif NVARCHAR (600), @piece_id INT)
RETURNS NVARCHAR (1000)
AS
BEGIN
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_actif(@vehicule, @arrete, @code_actif);
    IF @r IS NOT NULL RETURN @r;
    DECLARE @detentrice VARCHAR (20), @famille VARCHAR (20);
    SELECT @detentrice = entite_detentrice, @famille = dbo.fn_e3_famille(nature) FROM dbo.actif WHERE code = @code_actif;
    IF @famille IN ('TITRE', 'COMPTE_COURANT')
        RETURN N'50715|La valeur d''un titre de filiale ou d''une avance se calcule : elle ne se propose pas.';
    IF @valeur IS NULL
        RETURN N'50716|La valeur retenue est obligatoire.';
    IF @valeur < 0
        RETURN N'50717|La valeur retenue ne peut pas être négative.';
    IF NULLIF(LTRIM(RTRIM(@source)), N'') IS NULL
        RETURN N'50718|Choisissez la source de la valeur dans la liste « Source ».';
    DECLARE @src VARCHAR (20) = dbo.fn_e3_source_saisie(@source);
    IF @src IS NULL
        RETURN N'50719|La source « ' + @source + N' » n''est pas une source admise pour une valeur retenue.';
    DECLARE @expertise INT = (SELECT TOP (1) e.id FROM dbo.expertise e
                              WHERE e.code_actif = @code_actif AND e.date_valeur <= TRY_CONVERT(DATE, @arrete) ORDER BY e.date_valeur DESC);
    IF @src = 'EXPERTISE' AND @expertise IS NULL
        RETURN N'50720|La source Expertise suppose une expertise enregistrée pour ' + @code_actif + N' à cet arrêté.';
    IF @expertise IS NOT NULL AND @src <> 'EXPERTISE' AND NULLIF(LTRIM(RTRIM(@motif)), N'') IS NULL
        RETURN N'50721|Le motif de l''écart est obligatoire : la valeur retenue ne reprend pas l''expertise.';
    IF @piece_id IS NOT NULL AND dbo.fn_e3_piece_du_perimetre(@vehicule, @arrete, @piece_id, NULL) = 0
        RETURN N'50722|La pièce choisie n''est pas déposée pour ce véhicule ou l''une de ses filiales.';
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @detentrice AND arrete = @arrete)
        RETURN N'50724|L''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' n''est pas planifié pour ' + @detentrice + N'.';
    IF EXISTS (SELECT 1 FROM dbo.evaluation_actif WHERE code_actif = @code_actif AND entite = @detentrice AND arrete = @arrete AND etat = 'VISE')
        RETURN N'50723|La valeur retenue de ' + @code_actif + N' est visée : elle ne se reprend plus à cet arrêté.';
    RETURN NULL;
END;

GO

