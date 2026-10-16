CREATE TABLE [dbo].[eligibilite_participation] (
    [entite_mere]               VARCHAR (20)   NOT NULL,
    [entite_fille]              VARCHAR (20)   NOT NULL,
    [comptes_semestriels]       INT            NULL,
    [immeubles_conformes]       INT            NULL,
    [cas_relation]              CHAR (1)       NULL,
    [droits_de_vote]            DECIMAL (9, 6) NULL,
    [autre_associe_superieur]   INT            NULL,
    [accord_ecrit_piece_id]     INT            NULL,
    [qualifie_par]              NVARCHAR (400) NULL,
    [qualifie_le]               DATETIME2 (3)  NULL,
    [note]                      NVARCHAR (800) NULL,
    [controlee]                 BIT            NOT NULL,
    [engagement_couvrir_pertes] BIT            NULL,
    CONSTRAINT [pk_eligibilite_participation] PRIMARY KEY CLUSTERED ([entite_mere] ASC, [entite_fille] ASC),
    CONSTRAINT [ck_elig_accord_ecrit] CHECK ([cas_relation]<>'e' OR [accord_ecrit_piece_id] IS NOT NULL),
    CONSTRAINT [ck_elig_bits] CHECK (([comptes_semestriels] IS NULL OR ([comptes_semestriels]=(1) OR [comptes_semestriels]=(0))) AND ([immeubles_conformes] IS NULL OR ([immeubles_conformes]=(1) OR [immeubles_conformes]=(0))) AND ([autre_associe_superieur] IS NULL OR ([autre_associe_superieur]=(1) OR [autre_associe_superieur]=(0)))),
    CONSTRAINT [fk_elig_accord] FOREIGN KEY ([accord_ecrit_piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_elig_cas] FOREIGN KEY ([cas_relation]) REFERENCES [dbo].[ref_cas_eligibilite] ([cas]),
    CONSTRAINT [fk_elig_fille] FOREIGN KEY ([entite_fille]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_elig_mere] FOREIGN KEY ([entite_mere]) REFERENCES [dbo].[ref_entite] ([code])
);


GO


CREATE   TRIGGER dbo.tr_eligibilite_participation_annexe_retard ON dbo.eligibilite_participation
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite_mere, entite_fille, controlee FROM inserted
        EXCEPT SELECT entite_mere, entite_fille, controlee FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite_mere, entite_fille, controlee FROM deleted EXCEPT SELECT entite_mere, entite_fille, controlee FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite_mere AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'eligibilite_participation', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

