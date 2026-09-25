CREATE TABLE [dbo].[ref_entite] (
    [code]                   VARCHAR (20)   NOT NULL,
    [denomination]           NVARCHAR (200) NOT NULL,
    [siren]                  CHAR (9)       NULL,
    [forme_vehicule]         VARCHAR (10)   NULL,
    [forme_sociale]          VARCHAR (10)   NULL,
    [adresse_1]              NVARCHAR (200) NOT NULL,
    [adresse_2]              NVARCHAR (200) NULL,
    [code_postal]            VARCHAR (10)   NOT NULL,
    [ville]                  NVARCHAR (100) NOT NULL,
    [pays]                   CHAR (2)       NOT NULL,
    [dirigeant_nom]          NVARCHAR (200) NOT NULL,
    [dirigeant_qualite]      VARCHAR (60)   NOT NULL,
    [contact_nom]            NVARCHAR (200) NULL,
    [contact_courriel]       NVARCHAR (200) NULL,
    [contact_telephone]      VARCHAR (30)   NULL,
    [cloture]                CHAR (5)       NOT NULL,
    [modifie_par]            NVARCHAR (400) NULL,
    [modifie_le]             DATETIME2 (3)  NULL,
    [plan_propre_en_service] INT            CONSTRAINT [df_entite_plan_propre] DEFAULT ((0)) NOT NULL,
    [est_client]             BIT            CONSTRAINT [df_entite_est_client] DEFAULT ((0)) NOT NULL,
    [periodicite_vl]         VARCHAR (13)   NULL,
    [cree_le]                DATETIME2 (0)  NULL,
    CONSTRAINT [pk_ref_entite] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_entite_forme_sociale] CHECK ([forme_sociale] IS NULL OR [forme_sociale]='SA' OR [forme_sociale]='SAS' OR [forme_sociale]='SCI' OR [forme_sociale]='SNC' OR [forme_sociale]='SARL' OR [forme_sociale]='SCA'),
    CONSTRAINT [ck_entite_forme_vehicule] CHECK ([forme_vehicule] IS NULL OR [forme_vehicule]='SPPICAV' OR [forme_vehicule]='FPI'),
    CONSTRAINT [ck_entite_fpi_sans_forme_sociale] CHECK ([forme_vehicule] IS NULL OR [forme_vehicule]='SPPICAV' OR [forme_vehicule]='FPI' AND [forme_sociale] IS NULL AND [siren] IS NULL),
    CONSTRAINT [ck_entite_periodicite_vl] CHECK ([periodicite_vl] IS NULL OR ([periodicite_vl]='TRIMESTRIELLE' OR [periodicite_vl]='SEMESTRIELLE' OR [periodicite_vl]='ANNUELLE')),
    CONSTRAINT [ck_entite_plan_propre] CHECK ([plan_propre_en_service]=(1) OR [plan_propre_en_service]=(0)),
    CONSTRAINT [ck_entite_siren_neuf_chiffres] CHECK ([siren] IS NULL OR [siren] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);


GO

CREATE   TRIGGER dbo.[tr_ref_entite_garde]
ON dbo.[ref_entite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_entite',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
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
    UPDATE t SET modifie_par = SUSER_SNAME(), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_entite] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

