CREATE TABLE [dbo].[mouvement_porteur] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [porteur_id]   INT             NOT NULL,
    [date_valeur]  VARCHAR (20)    NOT NULL,
    [nature]       VARCHAR (14)    NOT NULL,
    [nombre_parts] DECIMAL (19, 4) DEFAULT ((0)) NOT NULL,
    [montant]      DECIMAL (19, 2) NOT NULL,
    [saisi_par]    NVARCHAR (200)  NOT NULL,
    [saisi_le]     DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_mouvement_porteur] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_mp_montant] CHECK ([montant]>(0)),
    CONSTRAINT [ck_mp_nature] CHECK ([nature]='DISTRIBUTION' OR [nature]='RACHAT' OR [nature]='SOUSCRIPTION'),
    CONSTRAINT [ck_mp_parts] CHECK ([nature]='DISTRIBUTION' AND [nombre_parts]=(0) OR [nature]<>'DISTRIBUTION' AND [nombre_parts]>(0)),
    CONSTRAINT [fk_mp_porteur] FOREIGN KEY ([porteur_id]) REFERENCES [dbo].[porteur] ([id])
);


GO


CREATE   TRIGGER dbo.tr_mouvement_porteur_annexe_retard ON dbo.mouvement_porteur
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, date_valeur, montant, nature, nombre_parts, porteur_id FROM inserted
        EXCEPT SELECT id, date_valeur, montant, nature, nombre_parts, porteur_id FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, date_valeur, montant, nature, nombre_parts, porteur_id FROM deleted EXCEPT SELECT id, date_valeur, montant, nature, nombre_parts, porteur_id FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT p.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch JOIN dbo.porteur p ON p.id = ch.porteur_id) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'mouvement_porteur', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

