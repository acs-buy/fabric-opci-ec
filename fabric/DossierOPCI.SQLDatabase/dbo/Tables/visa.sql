CREATE TABLE [dbo].[visa] (
    [id]             INT            IDENTITY (1, 1) NOT NULL,
    [nature]         VARCHAR (12)   NOT NULL,
    [objet_ref]      VARCHAR (60)   NOT NULL,
    [entite]         VARCHAR (20)   NOT NULL,
    [arrete]         VARCHAR (20)   NOT NULL,
    [cycle]          VARCHAR (10)   NULL,
    [decision]       VARCHAR (8)    NOT NULL,
    [motif]          NVARCHAR (600) NULL,
    [propose_par]    NVARCHAR (200) NOT NULL,
    [decide_par]     NVARCHAR (200) NOT NULL,
    [decide_le]      DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [annexe_version] INT            NULL,
    CONSTRAINT [pk_visa] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_visa_decision] CHECK ([decision]='RENVOYE' OR [decision]='VISE'),
    CONSTRAINT [ck_visa_motif_au_renvoi] CHECK ([decision]='VISE' OR [motif] IS NOT NULL),
    CONSTRAINT [ck_visa_nature] CHECK ([nature]='REVUE' OR [nature]='CYCLE' OR [nature]='LOT' OR [nature]='CONCLUSION' OR [nature]='DEROGATION' OR [nature]='EVALUATION' OR [nature]='PUBLICATION' OR [nature]='OBLIGATION' OR [nature]='ACCEPTATION' OR [nature]='MAINTIEN' OR [nature]='SYNTHESE' OR [nature]='CLOTURE'),
    CONSTRAINT [ck_visa_roles_separes] CHECK ([propose_par]<>[decide_par]),
    CONSTRAINT [fk_visa_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete])
);


GO

CREATE NONCLUSTERED INDEX [ix_visa_arrete]
    ON [dbo].[visa]([entite] ASC, [arrete] ASC, [cycle] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_visa_objet]
    ON [dbo].[visa]([nature] ASC, [objet_ref] ASC);


GO


-- --- 8 : le verrou, un lot perime ne se vise pas sans le savoir ------
-- Il ne refuse pas le visa : il refuse le visa SILENCIEUX. Viser un lot
-- perime exige un motif, ce qui oblige le chef de mission a dire pourquoi
-- il passe outre. C'est la trace que la supervision doit porter.
CREATE   TRIGGER dbo.tr_visa_lot_perime
ON dbo.visa
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.lot_ecritures l ON l.id = TRY_CAST(i.objet_ref AS INT)
        WHERE i.nature = 'LOT' AND i.decision = 'VISE'
          AND l.perime_le IS NOT NULL
          AND i.motif IS NULL
    )
        THROW 50060, N'Visa refusé : ce lot est marqué périmé, son périmètre ayant changé après sa génération. Le viser exige un motif disant pourquoi la génération n''est pas reprise. Lire dbo.v_lot_perime pour le fait qui l''a périmé.', 1;
END

GO


-- --- E8 : le verrou lit la nature ----------------------------------
CREATE   TRIGGER dbo.tr_visa_separation_des_roles
ON dbo.visa
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_proposant(i.nature, i.objet_ref) IS NOT NULL
          AND dbo.fn_proposant(i.nature, i.objet_ref) = i.decide_par
    )
        THROW 50050, N'Visa refusé : le décideur est celui qui a proposé l''objet. Nul ne vise son propre travail, quelle que soit la nature de l''objet.', 1;

    -- Le role doit etre habilite POUR CETTE NATURE, et non habilite en
    -- general. Corrige le 04/09/2026, ecart E8 de la revue : le drapeau
    -- vise de dbo.ref_role laissait l'associe signataire viser une
    -- derogation, ce que le libelle de son role ne prevoit pas.
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_peut_viser_nature(i.entite, i.decide_par, i.nature,
                                       CAST(i.decide_le AS DATE)) = 0
    )
        THROW 50051, N'Visa refusé : le décideur ne tient sur cette entité, à la date de la décision, aucun rôle habilité à viser CETTE NATURE d''objet. Lire dbo.v_role_nature_visa pour la répartition.', 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE dbo.fn_proposant(i.nature, i.objet_ref) IS NOT NULL
          AND dbo.fn_proposant(i.nature, i.objet_ref) <> i.propose_par
    )
        THROW 50052, N'Visa refusé : le proposant porté par le visa n''est pas celui que la source de l''objet désigne. Lire dbo.fn_proposant pour la valeur attendue.', 1;
END

GO


-- ------------------------------------------------------------------------------------------------- 2.5, point 4 : la garde de visa
-- A toute inscription d'un visa CLOTURE RENVOYE (INSERT, ou modification qui fait d'une ligne un tel visa), la demande
-- de reouverture EN_ATTENTE du meme arrete, de l'auteur egal au proposant, passe ACCORDEE et se lie au visa ; sans
-- elle, l'inscription est refusee (50998). Les renvois sont traites un a un, dans l'ordre des identifiants : un 2e
-- renvoi du meme arrete ne trouve plus de demande.
CREATE   TRIGGER dbo.tr_visa_accord_reouverture ON dbo.visa
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @r TABLE (n INT IDENTITY, id INT, entite VARCHAR (20), arrete VARCHAR (20), propose_par NVARCHAR (400), decide_par NVARCHAR (400), decide_le DATETIME2 (3));
    INSERT INTO @r (id, entite, arrete, propose_par, decide_par, decide_le)
    SELECT i.id, i.entite, i.arrete, i.propose_par, i.decide_par, i.decide_le
    FROM inserted i LEFT JOIN deleted d ON d.id = i.id
    WHERE i.nature = 'CLOTURE' AND i.decision = 'RENVOYE' AND NOT (ISNULL(d.nature, '') = 'CLOTURE' AND ISNULL(d.decision, '') = 'RENVOYE')
    ORDER BY i.id;
    DECLARE @k INT = 1, @n INT = (SELECT COUNT(*) FROM @r);
    WHILE @k <= @n
    BEGIN
        UPDATE q SET etat = 'ACCORDEE', decide_par = r.decide_par, decide_le = ISNULL(r.decide_le, SYSUTCDATETIME()), visa_id = r.id
        FROM dbo.demande_reouverture q JOIN @r r ON r.n = @k
        WHERE q.entite = r.entite AND q.arrete = r.arrete AND q.nature = 'REOUVERTURE' AND q.etat = 'EN_ATTENTE' AND q.demande_par = r.propose_par;
        IF @@ROWCOUNT = 0
            THROW 50998, N'Renvoi de clôture refusé : il s''inscrit par l''accord d''une demande de réouverture, et aucune demande de ce proposant n''attend sur cet arrêté.', 1;
        SET @k += 1;
    END;
END;

GO

