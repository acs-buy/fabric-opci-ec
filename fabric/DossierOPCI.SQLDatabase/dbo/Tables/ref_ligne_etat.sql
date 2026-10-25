CREATE TABLE [dbo].[ref_ligne_etat] (
    [etat]        VARCHAR (14)   NOT NULL,
    [code]        VARCHAR (20)   NOT NULL,
    [libelle]     NVARCHAR (300) NOT NULL,
    [type_ligne]  VARCHAR (14)   NOT NULL,
    [romain]      VARCHAR (6)    NULL,
    [racines]     VARCHAR (300)  NULL,
    [sens]        VARCHAR (8)    NULL,
    [formule]     NVARCHAR (200) NULL,
    [renvoi]      NVARCHAR (400) NULL,
    [article]     NVARCHAR (40)  NOT NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_ligne_etat] PRIMARY KEY CLUSTERED ([etat] ASC, [code] ASC),
    CONSTRAINT [ck_ligne_detail] CHECK ([type_ligne]<>'DETAIL' OR [racines] IS NOT NULL OR [formule] IS NOT NULL),
    CONSTRAINT [ck_ligne_etat] CHECK ([etat]='RESULTAT' OR [etat]='BILAN_PASSIF' OR [etat]='BILAN_ACTIF'),
    CONSTRAINT [ck_ligne_sens] CHECK ([sens] IS NULL OR ([sens]='CREDIT' OR [sens]='DEBIT')),
    CONSTRAINT [ck_ligne_type] CHECK ([type_ligne]='RESULTAT' OR [type_ligne]='TOTAL' OR [type_ligne]='DETAIL' OR [type_ligne]='RUBRIQUE'),
    CONSTRAINT [uq_ref_ligne_etat_ordre] UNIQUE NONCLUSTERED ([etat] ASC, [ordre] ASC)
);


GO


CREATE   TRIGGER dbo.tr_ref_ligne_etat_annexe_retard ON dbo.ref_ligne_etat
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT etat, code, article, formule, libelle, ordre, racines, renvoi, romain, sens, type_ligne FROM inserted
        EXCEPT SELECT etat, code, article, formule, libelle, ordre, racines, renvoi, romain, sens, type_ligne FROM deleted
        UNION ALL
        SELECT * FROM (SELECT etat, code, article, formule, libelle, ordre, racines, renvoi, romain, sens, type_ligne FROM deleted EXCEPT SELECT etat, code, article, formule, libelle, ordre, racines, renvoi, romain, sens, type_ligne FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_ligne_etat', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ligne_etat_horodatage]
ON dbo.[ref_ligne_etat]
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
    FROM dbo.[ref_ligne_etat] t
    JOIN inserted i ON t.[etat] = i.[etat] AND t.[code] = i.[code];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ligne_etat_garde]
ON dbo.[ref_ligne_etat]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_ligne_etat',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_ligne_etat_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

