
-- L'ANCIENNE CLOTURE DELEGUE : son enveloppe et son automatisation gardent leur signature.
CREATE   PROCEDURE dbo.pr_cloturer_etape_5
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_valider_pour_client @entite, @arrete, @par;
END;

GO

