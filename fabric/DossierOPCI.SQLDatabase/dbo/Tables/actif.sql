CREATE TABLE [dbo].[actif] (
    [code]              VARCHAR (20)    NOT NULL,
    [nature]            VARCHAR (40)    NOT NULL,
    [poste_bilan]       VARCHAR (20)    NULL,
    [date_acquisition]  DATE            NULL,
    [prix_de_revient]   DECIMAL (19, 2) NOT NULL,
    [fongible]          INT             CONSTRAINT [df_actif_fongible] DEFAULT ((0)) NOT NULL,
    [entite_detentrice] VARCHAR (20)    NULL,
    [entite_liee]       VARCHAR (20)    NULL,
    [adresse]           NVARCHAR (400)  NULL,
    [surface_m2]        DECIMAL (12, 2) NULL,
    [secteur]           NVARCHAR (120)  NULL,
    [cas_r214_81]       VARCHAR (10)    NULL,
    [droit_r214_82]     VARCHAR (10)    NULL,
    PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_actif_fongible] CHECK ([fongible]=(1) OR [fongible]=(0)),
    CONSTRAINT [ck_actif_qualification_immeuble] CHECK ([nature]='IMMEUBLE' OR [cas_r214_81] IS NULL AND [droit_r214_82] IS NULL),
    CONSTRAINT [fk_actif_cas_r214_81] FOREIGN KEY ([cas_r214_81]) REFERENCES [dbo].[ref_cas_immeuble] ([cas]),
    CONSTRAINT [fk_actif_droit_r214_82] FOREIGN KEY ([droit_r214_82]) REFERENCES [dbo].[ref_droit_reel] ([droit]),
    CONSTRAINT [fk_actif_entite_detentrice] FOREIGN KEY ([entite_detentrice]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_actif_entite_liee] FOREIGN KEY ([entite_liee]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_actif_nature] FOREIGN KEY ([nature]) REFERENCES [dbo].[ref_nature_actif] ([nature])
);


GO


CREATE   TRIGGER dbo.tr_actif_annexe_retard ON dbo.actif
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT code, adresse, date_acquisition, entite_detentrice, entite_liee, nature, poste_bilan, prix_de_revient, secteur, surface_m2 FROM inserted
        EXCEPT SELECT code, adresse, date_acquisition, entite_detentrice, entite_liee, nature, poste_bilan, prix_de_revient, secteur, surface_m2 FROM deleted
        UNION ALL
        SELECT * FROM (SELECT code, adresse, date_acquisition, entite_detentrice, entite_liee, nature, poste_bilan, prix_de_revient, secteur, surface_m2 FROM deleted EXCEPT SELECT code, adresse, date_acquisition, entite_detentrice, entite_liee, nature, poste_bilan, prix_de_revient, secteur, surface_m2 FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite_detentrice AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'actif', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

