CREATE TABLE [dbo].[ref_compte] (
    [compte]            VARCHAR (20)   NOT NULL,
    [libelle]           NVARCHAR (200) NOT NULL,
    [libelle_complet]   NVARCHAR (300) NULL,
    [classe]            CHAR (1)       NOT NULL,
    [niveau]            TINYINT        NOT NULL,
    [compte_parent]     VARCHAR (20)   NULL,
    [porte_actif]       INT            CONSTRAINT [df_ref_compte_porte_actif] DEFAULT ((0)) NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [source_article]    VARCHAR (60)   NULL,
    [reference_id]      INT            NULL,
    [rubrique_resultat] VARCHAR (14)   NULL,
    [ecartee_le]        DATE           NULL,
    [ecartee_par]       NVARCHAR (400) NULL,
    [motif_ecart]       NVARCHAR (600) NULL,
    PRIMARY KEY CLUSTERED ([compte] ASC),
    CONSTRAINT [ck_ref_compte_porte_actif] CHECK ([porte_actif]=(1) OR [porte_actif]=(0)),
    FOREIGN KEY ([compte_parent]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_compte_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id]),
    CONSTRAINT [fk_compte_rubrique] FOREIGN KEY ([rubrique_resultat]) REFERENCES [dbo].[ref_rubrique_resultat] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_ref_compte_horodatage]
ON dbo.[ref_compte]
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
    FROM dbo.[ref_compte] t
    JOIN inserted i ON t.[compte] = i.[compte];
END;

GO


CREATE   TRIGGER dbo.tr_ref_compte_annexe_retard ON dbo.ref_compte
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT compte, libelle FROM inserted
        EXCEPT SELECT compte, libelle FROM deleted
        UNION ALL
        SELECT * FROM (SELECT compte, libelle FROM deleted EXCEPT SELECT compte, libelle FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_compte', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

CREATE   TRIGGER dbo.[tr_ref_compte_garde]
ON dbo.[ref_compte]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_compte',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_compte_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

