CREATE TABLE [dbo].[arrete_mission] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [arrete]      VARCHAR (20)   NOT NULL,
    [type_arrete] VARCHAR (14)   NOT NULL,
    [ouvert_par]  NVARCHAR (200) NOT NULL,
    [ouvert_le]   DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [exercice]    VARCHAR (20)   NULL,
    [date_arrete] DATE           NULL,
    CONSTRAINT [pk_arrete_mission] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_am_type] CHECK ([type_arrete]='INTERMEDIAIRE' OR [type_arrete]='SEMESTRIEL' OR [type_arrete]='ANNUEL'),
    CONSTRAINT [fk_am_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_am_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_am_nature_arrete] FOREIGN KEY ([type_arrete]) REFERENCES [dbo].[ref_nature_arrete] ([code]),
    CONSTRAINT [uq_arrete_mission] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [ux_arrete_annuel]
    ON [dbo].[arrete_mission]([entite] ASC, [exercice] ASC) WHERE ([type_arrete]='ANNUEL');


GO

CREATE UNIQUE NONCLUSTERED INDEX [ux_arrete_semestriel]
    ON [dbo].[arrete_mission]([entite] ASC, [exercice] ASC) WHERE ([type_arrete]='SEMESTRIEL');


GO

-- --- 2. le trigger des portes, sur la fonction unique -----------------------------------------------
-- 19/11/2026 : les 3 portes se jugent par dbo.fn_portes_arrete, que pr_ecran_ouvrir_arrete_corps appelle avant
-- l'INSERT. Numeros et textes inchanges (50025, 50026, 50027). Plusieurs lignes inserees a la fois : la
-- 1re ligne refusee, par entite puis arrete, donne le refus.
CREATE   TRIGGER dbo.tr_arrete_portes
ON dbo.arrete_mission
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @r NVARCHAR (2000) =
        (SELECT TOP (1) x.r
         FROM inserted i
         CROSS APPLY (SELECT dbo.fn_portes_arrete(i.entite, i.arrete) AS r) x
         WHERE x.r IS NOT NULL
         ORDER BY i.entite, i.arrete);
    IF @r IS NOT NULL
    BEGIN
        DECLARE @n INT = CAST(LEFT(@r, 5) AS INT);
        DECLARE @m NVARCHAR (2000) = REPLACE(SUBSTRING(@r, 7, 2000), N'%', N'%%');
        THROW @n, @m, 1;
    END;
END;

GO

