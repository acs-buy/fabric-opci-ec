CREATE TABLE [dbo].[porteur] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [entite]       VARCHAR (20)   NOT NULL,
    [code]         VARCHAR (20)   NOT NULL,
    [denomination] NVARCHAR (200) NOT NULL,
    [source]       NVARCHAR (200) NOT NULL,
    CONSTRAINT [pk_porteur] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_porteur_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_porteur] UNIQUE NONCLUSTERED ([entite] ASC, [code] ASC)
);


GO


CREATE   TRIGGER dbo.tr_porteur_annexe_retard ON dbo.porteur
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, entite FROM inserted
        EXCEPT SELECT id, entite FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, entite FROM deleted EXCEPT SELECT id, entite FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'porteur', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

