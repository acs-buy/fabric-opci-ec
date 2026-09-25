CREATE TABLE [dbo].[role_mission] (
    [id]        INT            IDENTITY (1, 1) NOT NULL,
    [entite]    VARCHAR (20)   NOT NULL,
    [role]      VARCHAR (20)   NOT NULL,
    [personne]  NVARCHAR (200) NOT NULL,
    [du]        DATE           NOT NULL,
    [au]        DATE           NULL,
    [pose_par]  NVARCHAR (200) NOT NULL,
    [pose_le]   DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [connexion] NVARCHAR (400) NULL,
    CONSTRAINT [pk_role_mission] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_role_intervalle] CHECK ([au] IS NULL OR [au]>[du]),
    CONSTRAINT [fk_role_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_role_role] FOREIGN KEY ([role]) REFERENCES [dbo].[ref_role] ([code]),
    CONSTRAINT [uq_role_mission] UNIQUE NONCLUSTERED ([entite] ASC, [role] ASC, [personne] ASC, [du] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_role_mission_courant]
    ON [dbo].[role_mission]([entite] ASC, [role] ASC, [du] ASC);


GO


-- --- 3 : le non-chevauchement, refuse par la base ---------------------
-- Deux personnes ne tiennent pas le meme role sur la meme entite au meme
-- moment : sans cette garde, 2 chefs de mission pourraient viser, et la
-- separation des roles ne voudrait plus rien dire. L'intervalle etant
-- ferme a gauche et ouvert a droite, 2 mandats consecutifs qui se touchent
-- ne se chevauchent pas.
CREATE   TRIGGER dbo.tr_role_sans_chevauchement
ON dbo.role_mission
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM dbo.role_mission a
        JOIN dbo.role_mission b
          ON b.entite = a.entite AND b.role = a.role AND b.id <> a.id
         AND a.du < COALESCE(b.au, '9999-12-31')
         AND b.du < COALESCE(a.au, '9999-12-31')
        WHERE a.id IN (SELECT id FROM inserted)
    )
    BEGIN
        THROW 50045, 'Role refuse : une autre personne tient deja ce role sur cette entite pendant tout ou partie de la periode. Un role ne se partage pas dans le temps : fermer le mandat en cours par sa date de fin avant d''en ouvrir un autre. L''intervalle est ferme a gauche et ouvert a droite, si bien que 2 mandats consecutifs peuvent se toucher.', 1;
    END
END

GO

