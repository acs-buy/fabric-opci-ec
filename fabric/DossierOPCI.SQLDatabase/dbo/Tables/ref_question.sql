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
    [niveau_programme]  TINYINT        NULL,
    [sujet_tenue]       VARCHAR (30)   NULL,
    CONSTRAINT [pk_ref_question] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_question_niveau_programme] CHECK ([niveau_programme] IS NULL OR [niveau_programme]>=(1) AND [niveau_programme]<=(3)),
    CONSTRAINT [ck_ref_question_applicabilite] CHECK ([applicabilite]='LES_DEUX' OR [applicabilite]='ARRETE_CLOTURE' OR [applicabilite]='ARRETE_VL'),
    CONSTRAINT [ck_ref_question_obligatoire] CHECK ([obligatoire]=(1) OR [obligatoire]=(0)),
    CONSTRAINT [ck_ref_question_statut] CHECK ([statut]='ECARTEE' OR [statut]='REECRITE' OR [statut]='VALIDEE' OR [statut]='A_AUDITER'),
    CONSTRAINT [ck_ref_question_type] CHECK ([type_reponse]='CHOIX' OR [type_reponse]='DATE' OR [type_reponse]='MONTANT' OR [type_reponse]='TEXTE' OR [type_reponse]='OUI_NON_NA' OR [type_reponse]='OUI_NON'),
    CONSTRAINT [ck_ref_question_un_seul_proprietaire] CHECK ([cycle] IS NOT NULL AND [phase] IS NULL OR [cycle] IS NULL AND [phase] IS NOT NULL),
    CONSTRAINT [fk_ref_question_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_ref_question_phase] FOREIGN KEY ([phase]) REFERENCES [dbo].[ref_phase] ([code]),
    CONSTRAINT [fk_ref_question_sujet_tenue] FOREIGN KEY ([sujet_tenue]) REFERENCES [dbo].[ref_sujet_tenue] ([code]),
    CONSTRAINT [uq_ref_question_reference] UNIQUE NONCLUSTERED ([reference] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_ref_question_cycle]
    ON [dbo].[ref_question]([cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ref_question_phase]
    ON [dbo].[ref_question]([phase] ASC);


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
    -- Objet n° 16 de l'ecran 5 (script 317) : l'auteur est celui que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte, a la longueur de la colonne modifie_par.
    UPDATE t SET modifie_par = CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_question] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_question_garde]
ON dbo.[ref_question]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_question',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé ou réviseur. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_question_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;
GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[tr_ref_question_garde]', @order = N'first', @stmttype = N'insert';


GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[tr_ref_question_garde]', @order = N'first', @stmttype = N'update';


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

    -- Le passage a VALIDEE exige un mandat d'associe en cours. Objet n° 16 de l'ecran 5 (script 317) : l'identite
    -- jugee est celle que la procedure d'ecran pose dans le contexte par, a defaut le compte connecte ; la regle
    -- de date est celle de fn_peut_ecrire_referentiel (du au plus tard aujourd'hui, au vide ou posterieur).
    IF EXISTS (SELECT 1 FROM inserted i
               JOIN deleted d ON d.id = i.id
               WHERE i.statut = 'VALIDEE' AND d.statut <> 'VALIDEE')
       AND NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                       WHERE r.connexion = CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))
                         AND r.role = 'ASSOCIE'
                         AND r.du <= CAST(SYSUTCDATETIME() AS DATE)
                         AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
    BEGIN
        THROW 50076,
            N'Validation refusée : seul l''associé valide une question de référence. Une question ajoutée par un réviseur reste « à valider » jusqu''à ce que l''associé la valide.',
            1;
    END;
END;

GO

