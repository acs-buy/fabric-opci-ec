
-- La famille d'un actif, regle de v_patrimoine_valorise.
CREATE   FUNCTION dbo.fn_e3_famille (@nature VARCHAR (40))
RETURNS VARCHAR (20)
AS
BEGIN
    RETURN CASE WHEN @nature IN ('ACTION_ASSIMILEE', 'OBLIGATION_ASSIMILEE', 'TITRE_CREANCE', 'PART_OPC', 'DEPOT',
                                 'OPERATION_TEMPORAIRE', 'INSTRUMENT_TERME') THEN 'INSTRUMENT'
                WHEN @nature = 'TITRES_ENTITE_IMMOBILIERE' THEN 'TITRE'
                WHEN @nature = 'AVANCE_COMPTE_COURANT' THEN 'COMPTE_COURANT'
                ELSE 'IMMEUBLE' END;
END;

GO

