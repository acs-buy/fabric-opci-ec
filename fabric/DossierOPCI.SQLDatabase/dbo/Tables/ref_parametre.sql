CREATE TABLE [dbo].[ref_parametre] (
    [code]        VARCHAR (40)   NOT NULL,
    [valeur]      NVARCHAR (800) NULL,
    [description] NVARCHAR (400) NULL,
    [pose_par]    NVARCHAR (400) NULL,
    [pose_le]     DATETIME2 (3)  CONSTRAINT [df_param_le] DEFAULT (sysutcdatetime()) NOT NULL,
    [genre]       VARCHAR (12)   CONSTRAINT [df_ref_parametre_genre] DEFAULT ('SEUIL') NOT NULL,
    [libelle]     NVARCHAR (80)  NULL,
    CONSTRAINT [pk_ref_parametre] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_ref_parametre_genre] CHECK ([genre]='INSTALLATION' OR [genre]='SEUIL')
);


GO

CREATE   TRIGGER dbo.[tr_ref_parametre_garde]
ON dbo.[ref_parametre]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_parametre',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_parametre_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_parametre_horodatage]
ON dbo.[ref_parametre]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Genere par 61_DEPLOIEMENT/generer_e5_318_tables_gardees.py (script 318, ecran 5, objet n° 19). ref_parametre
    -- porte son auteur et sa date dans pose_par et pose_le, que pr_poser_parametre ecrit sous le contexte semis :
    -- pr_proteger_referentiel sort sans ecrire sur cette table, et cet horodatage s'ecrit ici, sous la forme des
    -- objets n° 16 et 17. Un semis ne marque pas la ligne comme modifiee.
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    UPDATE t SET pose_par = CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), pose_le = SYSUTCDATETIME()
    FROM dbo.[ref_parametre] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

