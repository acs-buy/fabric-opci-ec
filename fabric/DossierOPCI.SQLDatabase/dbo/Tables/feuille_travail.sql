CREATE TABLE [dbo].[feuille_travail] (
    [cote]               VARCHAR (30)    NOT NULL,
    [cycle]              VARCHAR (10)    NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [modele_code]        VARCHAR (20)    NULL,
    [origine]            VARCHAR (10)    NOT NULL,
    [nom_fichier]        NVARCHAR (400)  NOT NULL,
    [chemin_coffre]      NVARCHAR (400)  NOT NULL,
    [empreinte_sha256]   CHAR (64)       NOT NULL,
    [conclusion]         NVARCHAR (400)  NULL,
    [preparateur]        NVARCHAR (200)  NOT NULL,
    [prepare_le]         DATETIME2 (7)   DEFAULT (sysutcdatetime()) NOT NULL,
    [reviseur]           NVARCHAR (200)  NULL,
    [revise_le]          DATETIME2 (7)   NULL,
    [phase]              VARCHAR (10)    NULL,
    [forme_conclusion]   VARCHAR (20)    NULL,
    [conclue_par]        NVARCHAR (200)  NULL,
    [conclue_le]         DATETIME2 (3)   NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    [question_id]        INT             NULL,
    CONSTRAINT [pk_feuille_travail] PRIMARY KEY CLUSTERED ([cote] ASC),
    CONSTRAINT [ck_ft_conclusion_visa] CHECK ([forme_conclusion] IS NULL AND [conclue_par] IS NULL AND [conclue_le] IS NULL OR [forme_conclusion] IS NOT NULL AND [conclue_par] IS NOT NULL AND [conclue_le] IS NOT NULL),
    CONSTRAINT [ck_ft_empreinte_longueur] CHECK (len([empreinte_sha256])=(64)),
    CONSTRAINT [ck_ft_origine] CHECK ([origine]='MOTEUR' OR [origine]='HUMAINE'),
    CONSTRAINT [ck_ft_revue_complete] CHECK ([reviseur] IS NOT NULL AND [revise_le] IS NOT NULL OR [reviseur] IS NULL AND [revise_le] IS NULL),
    CONSTRAINT [ck_ft_un_seul_proprietaire] CHECK ([cycle] IS NOT NULL AND [phase] IS NULL OR [cycle] IS NULL AND [phase] IS NOT NULL),
    CONSTRAINT [fk_ft_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ft_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_ft_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_ft_forme_conclusion] FOREIGN KEY ([forme_conclusion]) REFERENCES [dbo].[ref_forme_conclusion] ([code]),
    CONSTRAINT [fk_ft_modele] FOREIGN KEY ([modele_code]) REFERENCES [dbo].[modele_feuille] ([code]),
    CONSTRAINT [fk_ft_phase] FOREIGN KEY ([phase]) REFERENCES [dbo].[ref_phase] ([code]),
    CONSTRAINT [fk_ft_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id]),
    CONSTRAINT [uq_feuille_travail_naturelle] UNIQUE NONCLUSTERED ([cote] ASC, [arrete] ASC, [entite] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ft_cycle]
    ON [dbo].[feuille_travail]([cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ft_modele]
    ON [dbo].[feuille_travail]([modele_code] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ft_phase]
    ON [dbo].[feuille_travail]([phase] ASC);


GO


CREATE   TRIGGER dbo.tr_feuille_conclusion
ON dbo.feuille_travail
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted i
                   JOIN deleted d ON d.cote = i.cote
                   WHERE i.forme_conclusion IS NOT NULL
                     AND d.forme_conclusion IS NULL)
        RETURN;

    DECLARE @manquantes NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.libelle AS NVARCHAR (60)), N' | ')
         FROM (SELECT DISTINCT TOP 10 LEFT(rpa.libelle, 60) AS libelle
               FROM inserted i
               JOIN deleted d ON d.cote = i.cote
               JOIN dbo.ref_piece_attendue rpa ON rpa.cycle = i.cycle
               WHERE i.forme_conclusion IS NOT NULL
                 AND d.forme_conclusion IS NULL
                 AND rpa.obligatoire = 1
                 AND rpa.periodicite IN ('ARRETE', 'PERMANENT')
                 AND (rpa.en_vigueur_depuis IS NULL
                      OR rpa.en_vigueur_depuis <= CONVERT(DATE, i.arrete))
                 AND NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement pr
                                 WHERE pr.piece_attendue_id = rpa.id
                                   AND pr.entite = i.entite
                                   AND (rpa.periodicite = 'PERMANENT'
                                        OR pr.arrete = i.arrete))) AS x);
    IF @manquantes IS NOT NULL
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Conclusion refusée : des pièces obligatoires de ce cycle ne '
            + N'sont rattachées à aucun document, pour cette entité et cet '
            + N'arrêté. Manquent : ' + @manquantes
            + N'. Déposer les pièces au coffre, les rattacher à la '
            + N'question, puis conclure.';
        THROW 50028, @m1, 1;
    END;

    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN deleted d ON d.cote = i.cote
               WHERE i.forme_conclusion = 'SANS_OBSERVATION'
                 AND d.forme_conclusion IS NULL
                 AND EXISTS (SELECT 1 FROM dbo.derogation g
                             WHERE g.entite = i.entite
                               AND g.arrete = i.arrete
                               AND g.levee_le IS NULL))
    BEGIN
        THROW 50029,
            N'Conclusion refusée : une dérogation active existe pour cette entité et cet arrêté, la forme sans observation est indisponible. Conclure sous une autre forme, ou faire lever la dérogation par son auteur.',
            1;
    END;
END;

GO

