CREATE TABLE [dbo].[ref_entite] (
    [code]                         VARCHAR (20)   NOT NULL,
    [denomination]                 NVARCHAR (200) NOT NULL,
    [siren]                        CHAR (9)       NULL,
    [forme_vehicule]               VARCHAR (10)   NULL,
    [forme_sociale]                VARCHAR (10)   NULL,
    [adresse_1]                    NVARCHAR (200) NOT NULL,
    [adresse_2]                    NVARCHAR (200) NULL,
    [code_postal]                  VARCHAR (10)   NOT NULL,
    [ville]                        NVARCHAR (100) NOT NULL,
    [pays]                         CHAR (2)       NOT NULL,
    [dirigeant_nom]                NVARCHAR (200) NOT NULL,
    [dirigeant_qualite]            VARCHAR (60)   NOT NULL,
    [contact_nom]                  NVARCHAR (200) NULL,
    [contact_courriel]             NVARCHAR (200) NULL,
    [contact_telephone]            VARCHAR (30)   NULL,
    [cloture]                      CHAR (5)       NOT NULL,
    [modifie_par]                  NVARCHAR (400) NULL,
    [modifie_le]                   DATETIME2 (3)  NULL,
    [plan_propre_en_service]       INT            CONSTRAINT [df_entite_plan_propre] DEFAULT ((0)) NOT NULL,
    [est_client]                   BIT            CONSTRAINT [df_entite_est_client] DEFAULT ((0)) NOT NULL,
    [periodicite_vl]               VARCHAR (13)   NULL,
    [cree_le]                      DATETIME2 (0)  NULL,
    [soumise_commissariat_comptes] BIT            NULL,
    [devise_comptabilite]          NVARCHAR (40)  NULL,
    [est_professionnel]            BIT            NULL,
    [libelle_vehicule]             AS             (CONVERT([nvarchar](240),case when [est_client]=(1) then ([code]+N' · ')+[denomination]  end)),
    [est_essai]                    BIT            CONSTRAINT [df_ref_entite_est_essai] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_ref_entite] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_entite_forme_sociale] CHECK ([forme_sociale] IS NULL OR [forme_sociale]='SA' OR [forme_sociale]='SAS' OR [forme_sociale]='SCI' OR [forme_sociale]='SNC' OR [forme_sociale]='SARL' OR [forme_sociale]='SCA'),
    CONSTRAINT [ck_entite_forme_vehicule] CHECK ([forme_vehicule] IS NULL OR [forme_vehicule]='SPPICAV' OR [forme_vehicule]='FPI'),
    CONSTRAINT [ck_entite_fpi_sans_forme_sociale] CHECK ([forme_vehicule] IS NULL OR [forme_vehicule]='SPPICAV' OR [forme_vehicule]='FPI' AND [forme_sociale] IS NULL AND [siren] IS NULL),
    CONSTRAINT [ck_entite_periodicite_vl] CHECK ([periodicite_vl] IS NULL OR ([periodicite_vl]='TRIMESTRIELLE' OR [periodicite_vl]='SEMESTRIELLE' OR [periodicite_vl]='ANNUELLE')),
    CONSTRAINT [ck_entite_plan_propre] CHECK ([plan_propre_en_service]=(1) OR [plan_propre_en_service]=(0)),
    CONSTRAINT [ck_entite_siren_neuf_chiffres] CHECK ([siren] IS NULL OR [siren] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CONSTRAINT [ck_entite_vehicule_commissariat] CHECK ([forme_vehicule] IS NULL OR [soumise_commissariat_comptes]=(1))
);


GO


CREATE   TRIGGER dbo.tr_ref_entite_annexe_retard ON dbo.ref_entite
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT code, denomination, devise_comptabilite, forme_vehicule, plan_propre_en_service FROM inserted
        EXCEPT SELECT code, denomination, devise_comptabilite, forme_vehicule, plan_propre_en_service FROM deleted
        UNION ALL
        SELECT * FROM (SELECT code, denomination, devise_comptabilite, forme_vehicule, plan_propre_en_service FROM deleted EXCEPT SELECT code, denomination, devise_comptabilite, forme_vehicule, plan_propre_en_service FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.code AS x, CAST(CASE WHEN ch.forme_vehicule IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'ref_entite', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 1, x.vehicule) v
    GROUP BY v.entite;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_entite_horodatage]
ON dbo.[ref_entite]
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
    FROM dbo.[ref_entite] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_entite_garde]
ON dbo.[ref_entite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_entite',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_entite_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

