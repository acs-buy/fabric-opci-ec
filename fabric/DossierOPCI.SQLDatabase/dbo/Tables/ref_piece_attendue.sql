CREATE TABLE [dbo].[ref_piece_attendue] (
    [id]                  INT            IDENTITY (1, 1) NOT NULL,
    [cycle]               VARCHAR (10)   NULL,
    [phase]               VARCHAR (10)   NULL,
    [libelle]             NVARCHAR (200) NOT NULL,
    [obligatoire]         INT            DEFAULT ((1)) NOT NULL,
    [periodicite]         VARCHAR (20)   NOT NULL,
    [racine_declenchante] VARCHAR (10)   NULL,
    [ordre]               INT            NOT NULL,
    [modifie_par]         NVARCHAR (400) NULL,
    [modifie_le]          DATETIME2 (3)  NULL,
    [en_vigueur_depuis]   DATE           NULL,
    [ecartee_le]          DATE           NULL,
    [ecartee_par]         NVARCHAR (400) NULL,
    [motif_ecart]         NVARCHAR (600) NULL,
    CONSTRAINT [pk_ref_piece_attendue] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_rpa_obligatoire] CHECK ([obligatoire]=(1) OR [obligatoire]=(0)),
    CONSTRAINT [ck_rpa_periodicite] CHECK ([periodicite]='EVENEMENT' OR [periodicite]='ARRETE' OR [periodicite]='PERMANENT'),
    CONSTRAINT [ck_rpa_racine_si_evenement] CHECK ([periodicite]='EVENEMENT' AND [racine_declenchante] IS NOT NULL OR [periodicite]<>'EVENEMENT' AND [racine_declenchante] IS NULL),
    CONSTRAINT [ck_rpa_un_seul_proprietaire] CHECK ([cycle] IS NOT NULL AND [phase] IS NULL OR [cycle] IS NULL AND [phase] IS NOT NULL),
    CONSTRAINT [fk_rpa_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code]),
    CONSTRAINT [fk_rpa_phase] FOREIGN KEY ([phase]) REFERENCES [dbo].[ref_phase] ([code]),
    CONSTRAINT [uq_rpa_proprietaire_libelle] UNIQUE NONCLUSTERED ([cycle] ASC, [phase] ASC, [libelle] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_rpa_cycle]
    ON [dbo].[ref_piece_attendue]([cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_rpa_phase]
    ON [dbo].[ref_piece_attendue]([phase] ASC);


GO

CREATE   TRIGGER dbo.[tr_ref_piece_attendue_garde]
ON dbo.[ref_piece_attendue]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_piece_attendue',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_piece_attendue_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_piece_attendue_horodatage]
ON dbo.[ref_piece_attendue]
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
    FROM dbo.[ref_piece_attendue] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

