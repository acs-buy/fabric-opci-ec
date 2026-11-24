-- --- les filiales d'un vehicule a un arrete ----------------------------------------------------
-- La detention saisie a l'arrete ; sans aucune ligne de detention
-- a cet arrete, les filiales declarees (eligibilite_participation), sans quote-part.
CREATE FUNCTION dbo.fn_filiales_a_l_arrete (@vehicule VARCHAR (20), @arrete VARCHAR (20))
RETURNS TABLE
AS
RETURN
    SELECT d.entite_fille
    FROM dbo.detention d
    WHERE d.entite_mere = @vehicule AND d.arrete = @arrete
    UNION
    SELECT ep.entite_fille
    FROM dbo.eligibilite_participation ep
    WHERE ep.entite_mere = @vehicule
      AND NOT EXISTS (SELECT 1 FROM dbo.detention d WHERE d.entite_mere = @vehicule AND d.arrete = @arrete);

GO

