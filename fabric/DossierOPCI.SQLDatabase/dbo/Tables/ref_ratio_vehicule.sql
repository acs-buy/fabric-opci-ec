CREATE TABLE [dbo].[ref_ratio_vehicule] (
    [entite]            VARCHAR (20)   NOT NULL,
    [code]              VARCHAR (30)   NOT NULL,
    [seuil]             DECIMAL (9, 6) NOT NULL,
    [source]            VARCHAR (12)   NOT NULL,
    [piece_id]          INT            NULL,
    [lu_le]             DATE           NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [en_vigueur_depuis] DATE           NULL,
    [motif]             NVARCHAR (600) NULL,
    CONSTRAINT [pk_ref_ratio_vehicule] PRIMARY KEY CLUSTERED ([entite] ASC, [code] ASC),
    CONSTRAINT [ck_rrv_source] CHECK ([source]='GESTIONNAIRE' OR [source]='STATUTS'),
    CONSTRAINT [fk_rrv_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rrv_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_rrv_ratio_memoire] FOREIGN KEY ([code]) REFERENCES [dbo].[ref_ratio_memoire] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_ref_ratio_vehicule_garde]
ON dbo.[ref_ratio_vehicule]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Generee par 61_DEPLOIEMENT/generer_e5_318_tables_gardees.py (script 318, ecran 5, objet n° 21) : ne pas
    -- modifier a la main. pr_garder_referentiel sort sans ecrire sur cette table, dont action_propre est posee
    -- (objet n° 1) : sa garde s'ecrit ici, en 2 temps.
    -- 1. Le role, comme les autres gardes (objets n° 16 et 17) : l'identite jugee est celle que la procedure d'ecran
    --    transmet (contexte par), a defaut le compte de la session. Le refus 50074 s'inscrit dans journal_refus apres
    --    l'annulation de la transaction, qui sinon emporterait l'inscription, puis se leve.
    -- 2. Hors semis, sur chaque ligne ecrite, les refus de pr_ecran_poser_seuil_vehicule (objet n° 24), a sa
    --    condition et a son texte, dans son ordre : une entite sans forme de vehicule ; une limite dont le texte fixe
    --    la valeur (valeur_laissee vide), ou laissee aux statuts sur un vehicule dont est_professionnel ne vaut pas 1 ;
    --    une limite d'une autre forme de vehicule ; une limite sans unite_seuil ; un seuil negatif ; un seuil
    --    au-dela de 1 pour une limite TAUX (100 pour cent). Puis le refus propre a la garde : une source autre que
    --    valeur_laissee, que la procedure n'ecrit jamais. ENDETTEMENT_40, retenue par le cabinet, admet le seuil des
    --    statuts d'un OPCI professionnel (decision D9 du 17/10/2026). Les textes citent les memes valeurs que la
    --    procedure : la limite du texte avec U+202F avant « % » (l.limite, sa mise en forme), le libelle, l'article et
    --    les formes tels que la base les porte. La garde porte ses propres numeros ; leur correspondance avec ceux de
    --    la procedure est dans l'en-tete du script 318, hors de ce corps.
    DECLARE @qui NVARCHAR (400) = CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400));
    IF dbo.fn_peut_ecrire_referentiel('ref_ratio_vehicule', @qui) = 0
    BEGIN
        DECLARE @refus NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
        DECLARE @vehicule VARCHAR (20) = (SELECT MIN(entite) FROM inserted);
        IF @vehicule IS NULL SET @vehicule = (SELECT MIN(entite) FROM deleted);
        ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus (procedure_nom, entite, message, refuse_pour, refuse_le)
        VALUES ('tr_ref_ratio_vehicule_garde', @vehicule, @refus, @qui, SYSUTCDATETIME());
        THROW 50074, @refus, 1;
    END;
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    DECLARE @n INT, @m NVARCHAR (2000);
    SELECT TOP (1) @n = CASE k.r WHEN 1 THEN 50890 WHEN 2 THEN 50891 WHEN 3 THEN 50891 WHEN 4 THEN 50892 WHEN 5 THEN 50893 WHEN 6 THEN 50894 WHEN 7 THEN 50894 WHEN 8 THEN 50891 END,
           @m = CASE k.r
                WHEN 1 THEN N'Seuil refusé : l’entité « ' + i.entite + N' » n’est pas un OPCI ; un seuil propre ne se pose que sur un véhicule.'
                WHEN 2 THEN N'Seuil refusé : le texte fixe cette limite (' + m.article + N', ' + l.limite + N'). Seules les valeurs que le texte laisse au gestionnaire ou aux statuts se tiennent ici.'
                WHEN 3 THEN N'Seuil refusé : le texte fixe cette limite pour un OPCI grand public (' + m.article + N', ' + l.limite + N') ; il ne la laisse aux statuts que pour un OPCI professionnel. Seules les valeurs que le texte laisse au gestionnaire ou aux statuts se tiennent ici.'
                WHEN 4 THEN N'Seuil refusé : la limite « ' + m.libelle + N' » vaut pour ' + CASE m.forme_vehicule WHEN 'FPI' THEN N'un ' ELSE N'une ' END + m.forme_vehicule + N', et ' + i.entite + N' est ' + CASE e.forme_vehicule WHEN 'FPI' THEN N'un ' ELSE N'une ' END + e.forme_vehicule + N'.'
                WHEN 5 THEN N'Seuil refusé : l’unité du seuil propre de la limite « ' + m.libelle + N' » n’est pas posée au référentiel des limites.'
                WHEN 6 THEN N'« Seuil du véhicule » : un seuil n’est pas négatif.'
                WHEN 7 THEN N'« Seuil du véhicule » : un taux ne dépasse pas 100' + NCHAR (8239) + N'%.'
                WHEN 8 THEN N'Seuil refusé : le champ « Fixée par » vaut « ' + CASE i.source WHEN 'GESTIONNAIRE' THEN N'le gestionnaire' ELSE N'les statuts' END + N' » pour la limite « ' + m.libelle + N' », dont le texte laisse la valeur ' + CASE m.valeur_laissee WHEN 'GESTIONNAIRE' THEN N'au gestionnaire' ELSE N'aux statuts' END + N' (' + CASE m.valeur_laissee WHEN 'GESTIONNAIRE' THEN N'directive 2011/61/UE, art. 15, § 4' ELSE N'CMF, art. R. 214-196 et R. 214-200' END + N').'
                END
    FROM inserted i
    JOIN dbo.ref_ratio_memoire m ON m.code = i.code
    JOIN dbo.ref_entite e ON e.code = i.entite
    -- la limite du texte mise en forme comme dans la procedure, avant ses refus : U+202F avant « % »
    CROSS APPLY (SELECT REPLACE(m.limite_texte COLLATE Latin1_General_BIN2, N' %', NCHAR (8239) + N'%') COLLATE DATABASE_DEFAULT AS limite) l
    CROSS APPLY (SELECT CASE
        WHEN e.forme_vehicule IS NULL THEN 1
        WHEN m.valeur_laissee IS NULL THEN 2
        WHEN m.valeur_laissee = 'STATUTS' AND ISNULL(e.est_professionnel, 0) = 0 THEN 3
        WHEN m.forme_vehicule IS NOT NULL AND m.forme_vehicule <> e.forme_vehicule THEN 4
        WHEN m.unite_seuil IS NULL OR m.unite_seuil NOT IN ('TAUX', 'NOMBRE') THEN 5
        WHEN i.seuil < 0 THEN 6
        WHEN m.unite_seuil = 'TAUX' AND i.seuil > 1 THEN 7
        WHEN i.source <> m.valeur_laissee THEN 8
        END AS r) k
    WHERE k.r IS NOT NULL
    ORDER BY i.entite, i.code;
    IF @n IS NOT NULL
    BEGIN
        -- THROW lit « % » comme un format : il se double (scripts 297 a 299), comme dans pr_e5_refuser (script 323).
        DECLARE @t NVARCHAR (4000) = REPLACE(@m, N'%', N'%%');
        THROW @n, @t, 1;
    END;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ratio_vehicule_horodatage]
ON dbo.[ref_ratio_vehicule]
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
    FROM dbo.[ref_ratio_vehicule] t
    JOIN inserted i ON t.[entite] = i.[entite] AND t.[code] = i.[code];
END;

GO

