
-- 1. LE VERROU DU VEHICULE VAUT POUR SES FILIALES AU MEME ARRETE (§ 7, point 7).
CREATE   FUNCTION dbo.fn_dossier_verrouille (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1)
                  OR EXISTS (SELECT 1 FROM dbo.v_perimetre_vehicule p
                             JOIN dbo.dossier_verrou v ON v.entite = p.vehicule AND v.arrete = p.arrete AND v.verrouille = 1
                             WHERE p.entite = @entite AND p.arrete = @arrete)
                THEN 1 ELSE 0 END;
END;

GO

