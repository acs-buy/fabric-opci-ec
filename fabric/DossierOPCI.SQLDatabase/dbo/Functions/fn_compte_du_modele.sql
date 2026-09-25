
-- LA FONCTION LIT LA BASCULE. Une entite passee a son propre plan voit
-- ses comptes traduits par la correspondance declaree ; une entite qui
-- n'y est pas encore garde l'identite pour les comptes du modele.
CREATE   FUNCTION dbo.fn_compte_du_modele (
    @entite VARCHAR (20),
    @compte VARCHAR (20)
)
RETURNS VARCHAR (20)
AS
BEGIN
    DECLARE @propre INT =
        ISNULL((SELECT TOP 1 plan_propre_en_service FROM dbo.ref_entite
                WHERE code = @entite), 0);

    IF @propre = 0 AND EXISTS (SELECT 1 FROM dbo.ref_compte
                               WHERE compte = @compte)
        RETURN @compte;

    RETURN ISNULL((SELECT TOP 1 rce.compte_modele
                   FROM dbo.ref_compte_entite rce
                   WHERE rce.entite = @entite
                     AND rce.compte_entite = @compte
                     AND rce.compte_modele IS NOT NULL), @compte);
END;

GO

