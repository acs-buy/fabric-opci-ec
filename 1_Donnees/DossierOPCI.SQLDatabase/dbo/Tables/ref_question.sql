CREATE TABLE [dbo].[ref_question] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [reference]         VARCHAR (20)   NOT NULL,
    [cycle]             VARCHAR (10)   NULL,
    [phase]             VARCHAR (10)   NULL,
    [enonce]            NVARCHAR (400) NOT NULL,
    [type_reponse]      VARCHAR (20)   NOT NULL,
    [obligatoire]       INT            DEFAULT ((1)) NOT NULL,
    [applicabilite]     VARCHAR (20)   NOT NULL,
    [statut]            VARCHAR (20)   DEFAULT ('A_AUDITER') NOT NULL,
    [ordre]             INT            NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [section]           NVARCHAR (120) NULL,
    [options]           NVARCHAR (200) NULL,
    [doc_attendu]       NVARCHAR (200) NULL,
    [reference_texte]   NVARCHAR (200) NULL,
    [en_vigueur_depuis] DATE           NULL,
    CONSTRAINT [pk_ref_question] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ref_question_applicabilite] CHECK ([applicabilite]='LES_DEUX' OR [applicabilite]='ARRETE_CLOTURE' OR [applicabilite]='ARRETE_VL'),
    CONSTRAINT [ck_ref_question_obligatoire] CHECK ([obligatoire]=(1) OR [obligatoire]=(0)),
    CONSTRAINT [ck_ref_question_statut] CHECK ([statut]='ECARTEE' OR [statut]='REECRITE' OR [statut]='VALIDEE' OR [statut]='A_AUDITER'),
    CONSTRAINT [ck_ref_question_type] CHECK ([type_reponse]='CHOIX' OR [type_reponse]='DATE' OR [type_reponse]='MONTANT' OR [type_reponse]='TEXTE' OR [type_reponse]='OUI_NON_NA' OR [type_reponse]='OUI_NON'),
    CONSTRAINT [ck_ref_question_un_seul_proprietaire] CHECK ([cycle] IS NOT NULL AND [phase] IS NULL OR [cycle] IS NULL AND [phase] IS NOT NULL),
    CONSTRAINT [fk_ref_question_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_ref_question_phase] FOREIGN KEY ([phase]) REFERENCES [dbo].[ref_phase] ([code]),
    CONSTRAINT [uq_ref_question_reference] UNIQUE NONCLUSTERED ([reference] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ref_question_cycle]
    ON [dbo].[ref_question]([cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ref_question_phase]
    ON [dbo].[ref_question]([phase] ASC);


GO



-- --- 5 : O26, le statut d'une question ajoutee ----------------------
-- 50075 : une question creee au portail nait A_AUDITER, quel que soit le
--         statut soumis. Seul l'associe la passe a VALIDEE.
-- 50076 : le passage a VALIDEE est reserve a l'associe.
CREATE   TRIGGER dbo.tr_question_statut
ON dbo.ref_question
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Un semis pose les statuts qu'il veut : les 620 questions du depot
    -- sont a A_AUDITER, et le referentiel des normes peut en ecarter.
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;

    -- A la creation, le statut est ramene a A_AUDITER.
    UPDATE q SET statut = 'A_AUDITER'
    FROM dbo.ref_question q
    JOIN inserted i ON i.id = q.id
    WHERE NOT EXISTS (SELECT 1 FROM deleted d WHERE d.id = i.id)
      AND q.statut <> 'A_AUDITER';

    -- Le passage a VALIDEE exige le role d'associe.
    IF EXISTS (SELECT 1 FROM inserted i
               JOIN deleted d ON d.id = i.id
               WHERE i.statut = 'VALIDEE' AND d.statut <> 'VALIDEE')
       AND NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                       WHERE r.connexion = SUSER_SNAME()
                         AND r.role = 'ASSOCIE' AND r.au IS NULL)
    BEGIN
        THROW 50076,
            N'Validation refusée : seul l''associé valide une question de référence. Une question ajoutée par un réviseur reste « à auditer » jusqu''à ce que l''associé la valide.',
            1;
    END;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_garde]
ON dbo.[ref_question]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_question',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé ou réviseur. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_horodatage]
ON dbo.[ref_question]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Un semis ne marque pas la ligne comme modifiee : sans quoi son
    -- premier passage interdirait a tous les suivants de corriger leurs
    -- propres lignes.
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    UPDATE t SET modifie_par = SUSER_SNAME(), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_question] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

