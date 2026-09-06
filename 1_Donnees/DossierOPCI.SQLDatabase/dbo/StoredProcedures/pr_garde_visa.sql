
-- --- 3-bis : la garde du visa, appelee en tete de chaque procedure ----
-- Les 2 contraintes de table ck_visa_roles_separes et
-- ck_visa_motif_au_renvoi refusent bien, mais leur message est celui de
-- SQL Server : « The INSERT statement conflicted with the CHECK
-- constraint ». Un chef de mission ne le lit pas. La garde verifie les
-- memes 2 regles AVANT l'insertion et leve un message ecrit ; les
-- contraintes restent en place comme filet, pour le cas d'une insertion
-- directe dans la table.
CREATE   PROCEDURE dbo.pr_garde_visa
    @nature     VARCHAR (12),
    @objet_ref  VARCHAR (30),
    @decision   VARCHAR (8),
    @decide_par NVARCHAR (200),
    @motif      NVARCHAR (600)
AS
BEGIN
    SET NOCOUNT ON;
    IF @decision NOT IN ('VISE', 'RENVOYE')
        THROW 50057, 'Visa refuse : la decision se dit VISE ou RENVOYE, et rien d''autre.', 1;
    IF @decision = 'RENVOYE' AND @motif IS NULL
        THROW 50057, 'Renvoi refuse : un renvoi porte son motif. Sans lui, le preparateur ne sait pas ce qu''il doit corriger.', 1;
    IF dbo.fn_proposant(@nature, @objet_ref) = @decide_par
        THROW 50057, 'Visa refuse : le decideur est celui qui a propose l''objet. Nul ne vise son propre travail.', 1;
END

GO

