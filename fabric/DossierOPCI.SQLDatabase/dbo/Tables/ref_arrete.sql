CREATE TABLE [dbo].[ref_arrete] (
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [date_arrete]        DATE            NOT NULL,
    [exercice]           VARCHAR (20)    NOT NULL,
    [date_cloture]       DATE            NOT NULL,
    [type_arrete]        VARCHAR (14)    NOT NULL,
    [nature_technique]   VARCHAR (12)    NOT NULL,
    [trimestre]          SMALLINT        NOT NULL,
    [rang_exercice]      SMALLINT        NOT NULL,
    [est_arrete_client]  BIT             NOT NULL,
    [porte_balance]      BIT             NOT NULL,
    [cree_le]            DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    CONSTRAINT [pk_ref_arrete] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC),
    CONSTRAINT [ck_ra_client_est_mission] CHECK ([est_arrete_client]=(0) OR [nature_technique]='MISSION'),
    CONSTRAINT [ck_ra_date_dans_exercice] CHECK ([date_arrete]<=[date_cloture]),
    CONSTRAINT [ck_ra_nature] CHECK ([nature_technique]='HORS_MISSION' OR [nature_technique]='REJEU' OR [nature_technique]='MISSION'),
    CONSTRAINT [ck_ra_rang] CHECK ([rang_exercice]>=(1)),
    CONSTRAINT [ck_ra_trimestre] CHECK ([trimestre]>=(1) AND [trimestre]<=(4)),
    CONSTRAINT [ck_ra_type] CHECK ([type_arrete]='INTERMEDIAIRE' OR [type_arrete]='SEMESTRIEL' OR [type_arrete]='ANNUEL'),
    CONSTRAINT [fk_ref_arrete_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_ref_arrete_nature] FOREIGN KEY ([type_arrete]) REFERENCES [dbo].[ref_nature_arrete] ([code])
);


GO

CREATE NONCLUSTERED INDEX [ix_ref_arrete_date]
    ON [dbo].[ref_arrete]([date_arrete] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ref_arrete_exercice]
    ON [dbo].[ref_arrete]([entite] ASC, [exercice] ASC);


GO


CREATE   TRIGGER dbo.tr_ref_arrete_annexe_retard ON dbo.ref_arrete
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite, arrete, cree_le, date_arrete, exercice, nature_technique, porte_balance, type_arrete FROM inserted
        EXCEPT SELECT entite, arrete, cree_le, date_arrete, exercice, nature_technique, porte_balance, type_arrete FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite, arrete, cree_le, date_arrete, exercice, nature_technique, porte_balance, type_arrete FROM deleted EXCEPT SELECT entite, arrete, cree_le, date_arrete, exercice, nature_technique, porte_balance, type_arrete FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'ref_arrete', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

