
-- L'actif choisi : renseigne, et detenu par le vehicule ou l'une de ses filiales a l'arrete.
CREATE   FUNCTION dbo.fn_e3_refus_actif (@vehicule VARCHAR (20), @arrete VARCHAR (20), @code_actif VARCHAR (20))
RETURNS NVARCHAR (1000)
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@code_actif)), '') IS NULL
        RETURN N'50703|Choisissez l''actif : aucune ligne n''est choisie dans la grille.';
    IF NOT EXISTS (SELECT 1 FROM dbo.actif a JOIN dbo.v_perimetre_vehicule p ON p.entite = a.entite_detentrice
                   WHERE a.code = @code_actif AND p.vehicule = @vehicule AND p.arrete = @arrete)
        RETURN N'50704|L''actif ' + @code_actif + N' n''est détenu ni par le véhicule ni par l''une de ses filiales à cet arrêté.';
    RETURN NULL;
END;

GO

