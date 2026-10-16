
-- ------------------------------------------------------------------ n° 1 : l'expertise
CREATE   FUNCTION dbo.fn_e3_refus_expertise (@vehicule VARCHAR (20), @arrete VARCHAR (20), @code_actif VARCHAR (20),
                                                   @valeur DECIMAL (19,2), @piece_id INT)
RETURNS NVARCHAR (1000)
AS
BEGIN
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_actif(@vehicule, @arrete, @code_actif);
    IF @r IS NOT NULL RETURN @r;
    IF (SELECT dbo.fn_e3_famille(nature) FROM dbo.actif WHERE code = @code_actif) <> 'IMMEUBLE'
        RETURN N'50705|L''expertise porte sur un immeuble : ' + @code_actif + N' n''en est pas un.';
    IF @valeur IS NULL
        RETURN N'50706|La valeur d''expertise est obligatoire : saisissez la valeur actuelle hors droits.';
    IF @valeur < 0
        RETURN N'50707|La valeur d''expertise ne peut pas être négative.';
    IF @piece_id IS NULL
        RETURN N'50708|Choisissez le rapport d''expertise dans la liste « Rapport au coffre ».';
    IF dbo.fn_e3_piece_du_perimetre(@vehicule, @arrete, @piece_id, 'RAPPORT_EVALUATION') = 0
        RETURN N'50709|Le rapport choisi n''est pas un rapport d''évaluation déposé pour ce véhicule ou l''une de ses filiales.';
    RETURN NULL;
END;

GO

