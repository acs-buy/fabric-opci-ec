CREATE TABLE [dbo].[ref_tableau_annexe] (
    [article]        VARCHAR (10)    NOT NULL,
    [libelle]        NVARCHAR (300)  NOT NULL,
    [source_valeur]  VARCHAR (14)    NOT NULL,
    [cellules]       INT             NULL,
    [note]           NVARCHAR (600)  NULL,
    [ordre]          INT             NOT NULL,
    [modifie_par]    NVARCHAR (400)  NULL,
    [modifie_le]     DATETIME2 (3)   NULL,
    [indicatif]      INT             DEFAULT ((0)) NOT NULL,
    [principe]       BIT             CONSTRAINT [df_ref_tableau_annexe_principe] DEFAULT ((0)) NOT NULL,
    [texte_principe] NVARCHAR (1000) NULL,
    CONSTRAINT [pk_ref_tableau_annexe] PRIMARY KEY CLUSTERED ([article] ASC),
    CONSTRAINT [ck_ref_tableau_annexe_principe] CHECK ([principe]=(1) AND [texte_principe] IS NOT NULL OR [principe]=(0) AND [texte_principe] IS NULL),
    CONSTRAINT [ck_ref_tableau_annexe_principe_alineas] CHECK ([texte_principe] IS NULL OR (len([texte_principe]+N'x')-len(replace([texte_principe],nchar((10)),N'')+N'x'))<=(1)),
    CONSTRAINT [ck_tableau_source] CHECK ([source_valeur]='MIXTE' OR [source_valeur]='CALCUL' OR [source_valeur]='SAISIE'),
    CONSTRAINT [uq_ref_tableau_annexe_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_tableau_annexe_horodatage]
ON dbo.[ref_tableau_annexe]
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
    FROM dbo.[ref_tableau_annexe] t
    JOIN inserted i ON t.[article] = i.[article];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_tableau_annexe_garde]
ON dbo.[ref_tableau_annexe]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_tableau_annexe',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_tableau_annexe_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_tableau_annexe_annexe_retard ON dbo.ref_tableau_annexe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT article, libelle, indicatif FROM inserted
        EXCEPT SELECT article, libelle, indicatif FROM deleted
        UNION ALL
        SELECT * FROM (SELECT article, libelle, indicatif FROM deleted EXCEPT SELECT article, libelle, indicatif FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_tableau_annexe', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

