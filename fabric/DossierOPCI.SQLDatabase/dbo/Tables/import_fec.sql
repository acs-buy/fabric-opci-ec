CREATE TABLE [dbo].[import_fec] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [entite]          VARCHAR (20)   NOT NULL,
    [arrete]          VARCHAR (20)   NOT NULL,
    [nom_fichier]     NVARCHAR (400) NOT NULL,
    [empreinte]       VARCHAR (64)   NULL,
    [exercice_debut]  DATE           NOT NULL,
    [exercice_fin]    DATE           NOT NULL,
    [lignes_lues]     INT            DEFAULT ((0)) NOT NULL,
    [lignes_rejetees] INT            DEFAULT ((0)) NOT NULL,
    [statut]          VARCHAR (20)   DEFAULT ('EN_COURS') NOT NULL,
    [importe_par]     NVARCHAR (200) NOT NULL,
    [importe_le]      DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [format]          VARCHAR (10)   NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_import_exercice_ordonne] CHECK ([exercice_debut]<=[exercice_fin]),
    CONSTRAINT [ck_import_format] CHECK ([format]='BALANCE' OR [format]='FEC'),
    CONSTRAINT [ck_import_statut] CHECK ([statut]='CHARGE' OR [statut]='REJETE' OR [statut]='EN_COURS'),
    CONSTRAINT [fk_import_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_import_fec_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

-- LA BALANCE CHARGEE SE PORTE SEULE : un import CHARGE fait porter une balance a son arrete de mission de
-- vehicule. Le declencheur ne remet jamais une valeur a 0.
CREATE   TRIGGER dbo.tr_import_porte_balance
ON dbo.import_fec
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r SET porte_balance = 1
    FROM dbo.ref_arrete r
    JOIN (SELECT DISTINCT entite, arrete FROM inserted WHERE statut = 'CHARGE') i ON i.entite = r.entite AND i.arrete = r.arrete
    JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
    WHERE r.nature_technique = 'MISSION' AND r.porte_balance = 0;
END;

GO
