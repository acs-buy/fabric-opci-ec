CREATE TABLE [dbo].[detention] (
    [entite_mere]  VARCHAR (20)   NOT NULL,
    [entite_fille] VARCHAR (20)   NOT NULL,
    [arrete]       VARCHAR (20)   NOT NULL,
    [quote_part]   DECIMAL (9, 6) NOT NULL,
    CONSTRAINT [pk_detention] PRIMARY KEY CLUSTERED ([entite_mere] ASC, [entite_fille] ASC, [arrete] ASC),
    CONSTRAINT [ck_detention_pas_de_boucle_directe] CHECK ([entite_mere]<>[entite_fille]),
    CONSTRAINT [ck_detention_quote_part] CHECK ([quote_part]>(0) AND [quote_part]<=(1)),
    CONSTRAINT [fk_detention_arrete] FOREIGN KEY ([entite_mere], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_detention_fille] FOREIGN KEY ([entite_fille]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_detention_mere] FOREIGN KEY ([entite_mere]) REFERENCES [dbo].[ref_entite] ([code])
);


GO


CREATE   TRIGGER dbo.tr_detention_annexe_retard ON dbo.detention
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite_mere, entite_fille, arrete, quote_part FROM inserted
        EXCEPT SELECT entite_mere, entite_fille, arrete, quote_part FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite_mere, entite_fille, arrete, quote_part FROM deleted EXCEPT SELECT entite_mere, entite_fille, arrete, quote_part FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite_mere AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'detention', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

