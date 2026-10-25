CREATE TABLE [dbo].[ref_norme] (
    [code]                    VARCHAR (14)   NOT NULL,
    [libelle_court]           NVARCHAR (80)  NOT NULL,
    [libelle_complet]         NVARCHAR (400) NOT NULL,
    [autorite]                VARCHAR (14)   NOT NULL,
    [acte_agrement]           NVARCHAR (200) NULL,
    [date_application]        NVARCHAR (120) NULL,
    [edition]                 NVARCHAR (40)  NULL,
    [piece_au_dossier]        NVARCHAR (200) NULL,
    [en_vigueur]              INT            DEFAULT ((1)) NOT NULL,
    [abroge_par]              VARCHAR (14)   NULL,
    [applicable_presentation] INT            DEFAULT ((0)) NOT NULL,
    [note]                    NVARCHAR (400) NULL,
    [modifie_par]             NVARCHAR (400) NULL,
    [modifie_le]              DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_norme] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_norme_abrogation] CHECK ([en_vigueur]=(1) OR [abroge_par] IS NOT NULL),
    CONSTRAINT [ck_norme_abrogee_inapplicable] CHECK ([en_vigueur]=(1) OR [applicable_presentation]=(0)),
    CONSTRAINT [ck_norme_autorite] CHECK ([autorite]='AMF' OR [autorite]='LEGISLATEUR' OR [autorite]='ANC' OR [autorite]='CNOEC'),
    CONSTRAINT [ck_norme_bit] CHECK (([en_vigueur]=(1) OR [en_vigueur]=(0)) AND ([applicable_presentation]=(1) OR [applicable_presentation]=(0))),
    CONSTRAINT [fk_norme_abroge_par] FOREIGN KEY ([abroge_par]) REFERENCES [dbo].[ref_norme] ([code])
);


GO


CREATE   TRIGGER dbo.tr_ref_norme_annexe_retard ON dbo.ref_norme
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT code, abroge_par, acte_agrement, applicable_presentation, autorite, date_application, edition, en_vigueur, libelle_complet, libelle_court, piece_au_dossier FROM inserted
        EXCEPT SELECT code, abroge_par, acte_agrement, applicable_presentation, autorite, date_application, edition, en_vigueur, libelle_complet, libelle_court, piece_au_dossier FROM deleted
        UNION ALL
        SELECT * FROM (SELECT code, abroge_par, acte_agrement, applicable_presentation, autorite, date_application, edition, en_vigueur, libelle_complet, libelle_court, piece_au_dossier FROM deleted EXCEPT SELECT code, abroge_par, acte_agrement, applicable_presentation, autorite, date_application, edition, en_vigueur, libelle_complet, libelle_court, piece_au_dossier FROM inserted) d
    )
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT e.code, SYSUTCDATETIME(), N'ref_norme', (SELECT COUNT(*) FROM ch)
    FROM dbo.ref_entite e WHERE e.forme_vehicule IS NOT NULL AND EXISTS (SELECT 1 FROM ch);
END;

GO

CREATE   TRIGGER dbo.[tr_ref_norme_garde]
ON dbo.[ref_norme]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_norme',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_norme_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_norme_horodatage]
ON dbo.[ref_norme]
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
    FROM dbo.[ref_norme] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

