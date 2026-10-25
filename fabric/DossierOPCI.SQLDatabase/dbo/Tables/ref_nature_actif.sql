CREATE TABLE [dbo].[ref_nature_actif] (
    [nature]            VARCHAR (40)   NOT NULL,
    [libelle]           NVARCHAR (200) NOT NULL,
    [methode]           NVARCHAR (300) NOT NULL,
    [article]           VARCHAR (40)   NOT NULL,
    [expertise_requise] SMALLINT       NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [reference_id]      INT            NULL,
    [ecartee_le]        DATE           NULL,
    [ecartee_par]       NVARCHAR (400) NULL,
    [motif_ecart]       NVARCHAR (600) NULL,
    CONSTRAINT [pk_ref_nature_actif] PRIMARY KEY CLUSTERED ([nature] ASC),
    CONSTRAINT [ck_rna_expertise] CHECK ([expertise_requise]=(1) OR [expertise_requise]=(0)),
    CONSTRAINT [fk_nature_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id])
);


GO


-- --- 5 : le verrou, une reference abrogee ne s'emploie pas -----------
-- Rattacher une nature d'actif a un article d'un reglement abroge
-- ferait citer par la solution un texte qui ne vaut plus. C'est
-- precisement le piege que la version precedente du memoire a paye, en
-- citant massivement le reglement ANC 2014-06.
CREATE   TRIGGER dbo.tr_nature_reference_en_vigueur
ON dbo.ref_nature_actif
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.ref_reference r ON r.id = i.reference_id
        JOIN dbo.ref_norme n ON n.code = r.norme
        WHERE n.en_vigueur = 0
    )
        THROW 50058, 'Rattachement refuse : la reference designee releve d''un texte abroge. Lire dbo.ref_norme pour le texte qui l''abroge, et rattacher la nature a l''article correspondant du texte en vigueur.', 1;
END

GO

CREATE   TRIGGER dbo.[tr_ref_nature_actif_garde]
ON dbo.[ref_nature_actif]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_nature_actif',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_nature_actif_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO


CREATE   TRIGGER dbo.tr_ref_nature_actif_annexe_retard ON dbo.ref_nature_actif
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT nature, expertise_requise, reference_id FROM inserted
        EXCEPT SELECT nature, expertise_requise, reference_id FROM deleted
        UNION ALL
        SELECT * FROM (SELECT nature, expertise_requise, reference_id FROM deleted EXCEPT SELECT nature, expertise_requise, reference_id FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_nature_actif', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

CREATE   TRIGGER dbo.[tr_ref_nature_actif_horodatage]
ON dbo.[ref_nature_actif]
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
    FROM dbo.[ref_nature_actif] t
    JOIN inserted i ON t.[nature] = i.[nature];
END;

GO

