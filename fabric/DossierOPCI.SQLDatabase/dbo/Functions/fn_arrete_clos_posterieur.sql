
-- ------------------------------------------------------------------------------------------------- fonctions d'etat
-- Point ouvert 1, A : le dernier arrete clos du client, s'il est posterieur a @arrete (50984, 50991) ; NULL sinon.
CREATE   FUNCTION dbo.fn_arrete_clos_posterieur (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS VARCHAR (20)
AS
BEGIN
    DECLARE @dernier VARCHAR (20) = (SELECT MAX(c.arrete) FROM dbo.v_visa_cloture_courant c
                                     JOIN dbo.ref_arrete r ON r.entite = c.entite AND r.arrete = c.arrete AND r.est_arrete_client = 1
                                     WHERE c.entite = @entite AND c.decision = 'VISE');
    RETURN CASE WHEN @dernier > @arrete THEN @dernier END;
END;

GO

