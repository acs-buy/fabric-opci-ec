
-- Une piece deposee pour le vehicule ou l'une de ses filiales (piece.entite), de la nature attendue quand elle est donnee.
CREATE   FUNCTION dbo.fn_e3_piece_du_perimetre (@vehicule VARCHAR (20), @arrete VARCHAR (20), @piece_id INT, @nature VARCHAR (40))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.piece pc
                             JOIN dbo.v_perimetre_vehicule p ON p.entite = pc.entite AND p.vehicule = @vehicule AND p.arrete = @arrete
                             WHERE pc.id = @piece_id AND (@nature IS NULL OR pc.nature = @nature))
                THEN 1 ELSE 0 END;
END;

GO

