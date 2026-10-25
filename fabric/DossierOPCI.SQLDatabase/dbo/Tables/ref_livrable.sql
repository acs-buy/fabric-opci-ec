CREATE TABLE [dbo].[ref_livrable] (
    [code]            VARCHAR (20)   NOT NULL,
    [libelle]         NVARCHAR (200) NOT NULL,
    [nature]          VARCHAR (20)   NOT NULL,
    [applicable]      VARCHAR (20)   NOT NULL,
    [article]         NVARCHAR (200) NULL,
    [ordre]           INT            NOT NULL,
    [modifie_par]     NVARCHAR (400) NULL,
    [modifie_le]      DATETIME2 (3)  NULL,
    [formats]         VARCHAR (40)   NULL,
    [produit_etape_6] BIT            CONSTRAINT [df_ref_livrable_produit_etape_6] DEFAULT ((0)) NOT NULL,
    [ecartee_le]      DATE           NULL,
    [ecartee_par]     NVARCHAR (400) NULL,
    [motif_ecart]     NVARCHAR (600) NULL,
    CONSTRAINT [pk_ref_livrable] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_livrable_applicable] CHECK ([applicable]='LES_DEUX' OR [applicable]='ARRETE_CLOTURE' OR [applicable]='ARRETE_VL'),
    CONSTRAINT [uq_ref_livrable_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_livrable_garde]
ON dbo.[ref_livrable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_livrable',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_livrable_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_livrable_horodatage]
ON dbo.[ref_livrable]
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
    FROM dbo.[ref_livrable] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

