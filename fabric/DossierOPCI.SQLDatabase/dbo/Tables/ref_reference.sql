CREATE TABLE [dbo].[ref_reference] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [norme]           VARCHAR (14)   NOT NULL,
    [reference]       VARCHAR (20)   NOT NULL,
    [genre]           VARCHAR (10)   NOT NULL,
    [intitule]        NVARCHAR (300) NOT NULL,
    [citation]        NVARCHAR (MAX) NULL,
    [lu_sur_piece]    INT            DEFAULT ((0)) NOT NULL,
    [page_piece]      INT            NULL,
    [piece_reference] NVARCHAR (400) NULL,
    [lu_le]           DATE           NULL,
    [modifie_par]     NVARCHAR (400) NULL,
    [modifie_le]      DATETIME2 (3)  NULL,
    [abroge_le]       DATE           NULL,
    [abroge_par]      NVARCHAR (400) NULL,
    CONSTRAINT [pk_ref_reference] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_reference_abrogee] CHECK ([abroge_le] IS NULL OR [abroge_par] IS NOT NULL),
    CONSTRAINT [ck_reference_bit] CHECK ([lu_sur_piece]=(1) OR [lu_sur_piece]=(0)),
    CONSTRAINT [ck_reference_genre] CHECK ([genre]='TITRE' OR [genre]='ANNEXE' OR [genre]='PARAGRAPHE' OR [genre]='ARTICLE'),
    CONSTRAINT [ck_reference_lue] CHECK ([lu_sur_piece]=(0) OR [lu_le] IS NOT NULL AND ([page_piece] IS NOT NULL OR [piece_reference] IS NOT NULL)),
    CONSTRAINT [fk_reference_norme] FOREIGN KEY ([norme]) REFERENCES [dbo].[ref_norme] ([code]),
    CONSTRAINT [uq_ref_reference] UNIQUE NONCLUSTERED ([norme] ASC, [reference] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_reference_horodatage]
ON dbo.[ref_reference]
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
    FROM dbo.[ref_reference] t
    JOIN inserted i ON t.[id] = i.[id];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_reference_garde]
ON dbo.[ref_reference]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_reference',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_reference_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_reference_annexe_retard ON dbo.ref_reference
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, citation, genre, intitule, lu_le, lu_sur_piece, norme, page_piece, reference FROM inserted
        EXCEPT SELECT id, citation, genre, intitule, lu_le, lu_sur_piece, norme, page_piece, reference FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, citation, genre, intitule, lu_le, lu_sur_piece, norme, page_piece, reference FROM deleted EXCEPT SELECT id, citation, genre, intitule, lu_le, lu_sur_piece, norme, page_piece, reference FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_reference', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

