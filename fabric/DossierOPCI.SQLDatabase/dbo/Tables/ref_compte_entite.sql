CREATE TABLE [dbo].[ref_compte_entite] (
    [entite]            VARCHAR (20)   NOT NULL,
    [compte_entite]     VARCHAR (20)   NOT NULL,
    [libelle_entite]    NVARCHAR (200) NULL,
    [compte_modele]     VARCHAR (20)   NOT NULL,
    [rattache_par]      NVARCHAR (200) NOT NULL,
    [rattache_le]       DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [entite_liee]       VARCHAR (20)   NULL,
    [porte_intragroupe] INT            CONSTRAINT [df_rce_intragroupe] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([entite] ASC, [compte_entite] ASC),
    CONSTRAINT [ck_rce_intragroupe] CHECK ([porte_intragroupe]=(1) OR [porte_intragroupe]=(0)),
    CONSTRAINT [fk_rce_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rce_entite_liee] FOREIGN KEY ([entite_liee]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rce_modele] FOREIGN KEY ([compte_modele]) REFERENCES [dbo].[ref_compte] ([compte])
);


GO

CREATE   TRIGGER dbo.tr_rattachement_meme_classe
ON dbo.ref_compte_entite
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE LEFT(i.compte_entite, 1) <> LEFT(i.compte_modele, 1)
          AND i.compte_entite <> i.compte_modele
          AND NOT EXISTS (
              SELECT 1 FROM dbo.ref_correspondance_plan c
              WHERE c.compte_source = i.compte_entite
                AND c.compte_modele = i.compte_modele)
    )
        THROW 50048, 'Rattachement refuse : le compte de l''entite et le compte modele ne sont pas de la meme classe, et aucune correspondance n''est declaree entre les 2 plans. Une traduction qui change de classe se justifie : la declarer dans dbo.ref_correspondance_plan avec son motif, comme le passage du compte 4551 du PCG au compte 512 du plan de l''article 411-3.', 1;
END

GO

CREATE   TRIGGER dbo.[tr_ref_compte_entite_horodatage]
ON dbo.[ref_compte_entite]
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
    FROM dbo.[ref_compte_entite] t
    JOIN inserted i ON t.[entite] = i.[entite] AND t.[compte_entite] = i.[compte_entite];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_compte_entite_garde]
ON dbo.[ref_compte_entite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_compte_entite',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_compte_entite_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_compte_entite_annexe_retard ON dbo.ref_compte_entite
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT entite, compte_entite, compte_modele FROM inserted
        EXCEPT SELECT entite, compte_entite, compte_modele FROM deleted
        UNION ALL
        SELECT * FROM (SELECT entite, compte_entite, compte_modele FROM deleted EXCEPT SELECT entite, compte_entite, compte_modele FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'ref_compte_entite', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

