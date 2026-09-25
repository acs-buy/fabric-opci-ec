CREATE TABLE [dbo].[publication_vl] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [valeur_liquidative] DECIMAL (19, 2) NOT NULL,
    [nombre_parts]       DECIMAL (19, 4) NOT NULL,
    [version_regles]     VARCHAR (20)    NULL,
    [publie_par]         NVARCHAR (200)  NOT NULL,
    [publie_le]          DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_publication_vl] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_pv_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_pv_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_publication_vl] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO



-- --- 4 : O2, la porte de l'etape 5 ----------------------------------
-- pr_publier_vl teste desormais la synthese visee, en plus des lots
-- proposes. La procedure n'est pas reecrite : un declencheur sur la
-- table des publications porte le test, ce qui evite de dupliquer les
-- 60 lignes de la procedure et de faire diverger 2 versions.
-- 50082 : aucune synthese visee pour cet arrete.
CREATE   TRIGGER dbo.tr_publication_exige_synthese
ON dbo.publication_vl
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @e VARCHAR (20), @a VARCHAR (20);
    SELECT TOP 1 @e = entite, @a = arrete FROM inserted;
    IF NOT EXISTS (SELECT 1 FROM dbo.visa v
                   WHERE v.nature = 'SYNTHESE' AND v.entite = @e
                     AND v.arrete = @a AND v.decision = 'VISE')
    BEGIN
        DECLARE @m NVARCHAR (2000) =
            N'Publication refusée : la synthèse de l''arrêté n''est pas '
            + N'visée. La valeur liquidative ne se publie qu''une fois '
            + N'attesté que la rationalisation de l''actif net boucle et '
            + N'que la valeur liquidative est calculable.';
        THROW 50082, @m, 1;
    END;
END;

GO

