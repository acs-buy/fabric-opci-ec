CREATE TABLE [dbo].[parts_en_circulation] (
    [entite]       VARCHAR (20)    NOT NULL,
    [arrete]       VARCHAR (20)    NOT NULL,
    [nombre_parts] DECIMAL (19, 4) NOT NULL,
    [source]       NVARCHAR (200)  NOT NULL,
    [saisi_par]    NVARCHAR (400)  NULL,
    [saisi_le]     DATETIME2 (3)   NULL,
    CONSTRAINT [pk_parts_en_circulation] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC),
    CONSTRAINT [ck_parts_positives] CHECK ([nombre_parts]>(0)),
    CONSTRAINT [fk_parts_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_parts_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO


CREATE   TRIGGER dbo.tr_parts_en_circulation_annexe_retard ON dbo.parts_en_circulation
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite, arrete, nombre_parts, source FROM inserted
        EXCEPT SELECT entite, arrete, nombre_parts, source FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite, arrete, nombre_parts, source FROM deleted EXCEPT SELECT entite, arrete, nombre_parts, source FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'parts_en_circulation', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

