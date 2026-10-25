CREATE TABLE [dbo].[ref_ligne_annexe] (
    [article]         VARCHAR (10)   NOT NULL,
    [code]            VARCHAR (24)   NOT NULL,
    [libelle]         NVARCHAR (400) NOT NULL,
    [niveau]          INT            NOT NULL,
    [type_ligne]      VARCHAR (14)   NOT NULL,
    [signe]           VARCHAR (4)    NULL,
    [racines]         VARCHAR (300)  NULL,
    [racines_exclues] VARCHAR (300)  NULL,
    [sens]            VARCHAR (8)    NULL,
    [formule]         NVARCHAR (300) NULL,
    [renvoi]          NVARCHAR (600) NULL,
    [ordre]           INT            NOT NULL,
    [modifie_par]     NVARCHAR (400) NULL,
    [modifie_le]      DATETIME2 (3)  NULL,
    [globalisable]    INT            DEFAULT ((0)) NOT NULL,
    [formule_calcul]  NVARCHAR (400) NULL,
    CONSTRAINT [pk_ref_ligne_annexe] PRIMARY KEY CLUSTERED ([article] ASC, [code] ASC),
    CONSTRAINT [ck_ligne_annexe_signe] CHECK ([signe] IS NULL OR ([signe]='=' OR [signe]='+/-' OR [signe]='-' OR [signe]='+')),
    CONSTRAINT [ck_ligne_annexe_type] CHECK ([type_ligne]='TOTAL' OR [type_ligne]='SAISIE' OR [type_ligne]='CALCUL' OR [type_ligne]='RUBRIQUE'),
    CONSTRAINT [fk_ligne_annexe_tableau] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_tableau_annexe] ([article]),
    CONSTRAINT [uq_ref_ligne_annexe_ordre] UNIQUE NONCLUSTERED ([article] ASC, [ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_ligne_annexe_horodatage]
ON dbo.[ref_ligne_annexe]
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
    FROM dbo.[ref_ligne_annexe] t
    JOIN inserted i ON t.[article] = i.[article] AND t.[code] = i.[code];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ligne_annexe_garde]
ON dbo.[ref_ligne_annexe]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_ligne_annexe',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_ligne_annexe_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_ligne_annexe_annexe_retard ON dbo.ref_ligne_annexe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT article, code, formule, formule_calcul, libelle, niveau, ordre, racines, racines_exclues, sens, signe, type_ligne FROM inserted
        EXCEPT SELECT article, code, formule, formule_calcul, libelle, niveau, ordre, racines, racines_exclues, sens, signe, type_ligne FROM deleted
        UNION ALL
        SELECT * FROM (SELECT article, code, formule, formule_calcul, libelle, niveau, ordre, racines, racines_exclues, sens, signe, type_ligne FROM deleted EXCEPT SELECT article, code, formule, formule_calcul, libelle, niveau, ordre, racines, racines_exclues, sens, signe, type_ligne FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_ligne_annexe', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

