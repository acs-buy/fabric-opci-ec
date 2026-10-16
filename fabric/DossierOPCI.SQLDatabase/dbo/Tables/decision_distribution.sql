CREATE TABLE [dbo].[decision_distribution] (
    [entite]              VARCHAR (20)    NOT NULL,
    [exercice]            VARCHAR (20)    NOT NULL,
    [categorie]           VARCHAR (30)    NOT NULL,
    [obligation_minimale] DECIMAL (19, 2) NOT NULL,
    [total_distribuable]  DECIMAL (19, 2) NOT NULL,
    [montant_decide]      DECIMAL (19, 2) NOT NULL,
    [date_assemblee]      DATE            NULL,
    [decide_par]          NVARCHAR (400)  NOT NULL,
    [decide_le]           DATETIME2 (3)   NOT NULL,
    [message_ecran]       NVARCHAR (2000) NULL,
    [message_ecran_le]    DATETIME2 (3)   NULL,
    [message_ecran_pour]  NVARCHAR (200)  NULL,
    CONSTRAINT [pk_decision_distribution] PRIMARY KEY CLUSTERED ([entite] ASC, [exercice] ASC, [categorie] ASC),
    CONSTRAINT [ck_decision_bornes] CHECK ([montant_decide]>=[obligation_minimale] AND [montant_decide]<=[total_distribuable]),
    CONSTRAINT [fk_decision_categorie] FOREIGN KEY ([categorie]) REFERENCES [dbo].[ref_obligation_distribution] ([categorie])
);


GO


CREATE   TRIGGER dbo.tr_decision_distribution_annexe_retard ON dbo.decision_distribution
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite, exercice, categorie, montant_decide FROM inserted
        EXCEPT SELECT entite, exercice, categorie, montant_decide FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite, exercice, categorie, montant_decide FROM deleted EXCEPT SELECT entite, exercice, categorie, montant_decide FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'decision_distribution', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

