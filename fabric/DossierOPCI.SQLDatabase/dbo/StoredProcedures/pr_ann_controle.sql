
-- Un controle ou un signal du catalogue, sous une cle unique a l'arrete ; un ecart NULL n'a pas de ligne
-- (oracle, Table.controle).
CREATE   PROCEDURE dbo.pr_ann_controle
    @c INT, @a VARCHAR (20), @controle VARCHAR (24), @cle NVARCHAR (120), @ecart DECIMAL (38, 12)
AS
BEGIN
    SET NOCOUNT ON;
    IF @ecart IS NULL RETURN;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_controle_annexe WHERE controle = @controle)
        THROW 50659, N'Moteur de l''annexe : contrôle absent du catalogue ref_controle_annexe.', 1;
    INSERT INTO dbo.annexe_w_ctl (calcul_id, arrete, controle, cle, ecart) VALUES (@c, @a, @controle, @cle, @ecart);
END;

GO

