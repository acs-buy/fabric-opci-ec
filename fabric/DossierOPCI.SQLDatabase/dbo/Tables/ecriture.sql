CREATE TABLE [dbo].[ecriture] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [lot_id]         INT             NOT NULL,
    [journal_code]   VARCHAR (10)    NOT NULL,
    [journal_lib]    NVARCHAR (100)  NOT NULL,
    [ecriture_num]   VARCHAR (30)    NOT NULL,
    [ecriture_date]  DATE            NOT NULL,
    [compte_num]     VARCHAR (20)    NOT NULL,
    [compte_lib]     NVARCHAR (200)  NOT NULL,
    [comp_aux_num]   VARCHAR (20)    NULL,
    [comp_aux_lib]   NVARCHAR (200)  NULL,
    [piece_ref]      VARCHAR (50)    NULL,
    [piece_date]     DATE            NULL,
    [ecriture_lib]   NVARCHAR (400)  NOT NULL,
    [debit]          DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [credit]         DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [ecriture_let]   VARCHAR (40)    NULL,
    [date_let]       DATE            NULL,
    [valid_date]     DATE            NULL,
    [montant_devise] DECIMAL (19, 3) NULL,
    [id_devise]      VARCHAR (3)     NULL,
    [compte_origine] VARCHAR (20)    NULL,
    [famille]        VARCHAR (10)    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ecriture_journal_od] CHECK ([famille] IS NULL OR [famille]='DECIDEE' AND [journal_code]='ODR' OR [famille]='DERIVABLE' AND [journal_code]='ODV' OR [famille]='IMPORTEE'),
    CONSTRAINT [ck_montant_positif] CHECK ([debit]>=(0) AND [credit]>=(0)),
    CONSTRAINT [ck_sens_unique] CHECK ([debit]=(0) OR [credit]=(0)),
    FOREIGN KEY ([lot_id]) REFERENCES [dbo].[lot_ecritures] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_ecriture_compte]
    ON [dbo].[ecriture]([compte_num] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_ecriture_lot]
    ON [dbo].[ecriture]([lot_id] ASC);


GO


-- --- 2 : la regle, portee par un declencheur ------------------------
-- CE QUE LE DECLENCHEUR REFUSE, ET CE QU'IL LAISSE PASSER. Il refuse un
-- compte qui n'existe ni au plan de l'entite du lot, ni au plan du
-- modele. Il laisse passer les 2 autres cas, et le controle C81 mesure
-- ceux qui ne sont connus que du modele.
CREATE   TRIGGER dbo.tr_ecriture_compte_du_plan
ON dbo.ecriture
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;

    DECLARE @compte VARCHAR (20), @entite VARCHAR (20);
    SELECT TOP 1 @compte = i.compte_num, @entite = l.entite
    FROM inserted i
    JOIN dbo.lot_ecritures l ON l.id = i.lot_id
    WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite rce
                      WHERE rce.entite = l.entite
                        AND rce.compte_entite = i.compte_num)
      AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte rc
                      WHERE rc.compte = i.compte_num);

    IF @compte IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR (2000) =
            N'Écriture refusée : le compte ' + @compte
          + N' n''appartient ni au plan de l''entité ' + @entite
          + N', déclaré dans dbo.ref_compte_entite, ni au plan du modèle. '
          + N'Déclarer le compte au plan de l''entité, avec le compte du '
          + N'modèle auquel il se rattache, ou corriger le numéro.';
        THROW 50082, @m, 1;
    END;
END;

GO



-- ---------------------------------------------------------------------
-- BLOC 5 : tr_ecriture_lot_non_regenerable. Le refus de supprimer les
-- écritures d'un lot déjà remis. SEUL DANS SON LOT.
-- ---------------------------------------------------------------------
CREATE   TRIGGER dbo.tr_ecriture_lot_non_regenerable
ON dbo.ecriture
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF (ROWCOUNT_BIG() = 0)
        RETURN;

    DECLARE @statut VARCHAR (10) = (
        SELECT MAX(l.statut)
          FROM dbo.lot_ecritures l
         WHERE l.id IN (SELECT d.lot_id FROM deleted d)
           AND l.statut IN ('EXPORTE', 'PUBLIE'));

    IF @statut IS NOT NULL
    BEGIN
        DECLARE @msg NVARCHAR (700) =
            N'Suppression refusee par tr_ecriture_lot_non_regenerable de '
            + N'63_SQL/33_export_fec.sql : des ecritures supprimees '
            + N'appartiennent a un lot au statut ' + @statut
            + N', deja remis. Un lot exporte ou publie n''est plus '
            + N'regenerable : sa correction passe par une ecriture inverse '
            + N'dans un nouveau lot, jamais par une destruction. La liste '
            + N'des lots concernes est rendue par dbo.v_lot_non_regenerable.';
        THROW 50019, @msg, 5;
    END
END

GO


-- INVARIANT : tout lot est equilibre, verifie a l'enregistrement
CREATE TRIGGER tr_lot_equilibre
ON ecriture
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT e.lot_id
        FROM ecriture e
        WHERE e.lot_id IN (
            SELECT lot_id FROM inserted
            UNION
            SELECT lot_id FROM deleted
        )
        GROUP BY e.lot_id
        HAVING SUM(e.debit) <> SUM(e.credit)
    )
    BEGIN
        THROW 50001, 'Lot desequilibre : la somme des debits doit egaler celle des credits.', 1;
    END
END

GO


-- --- depuis 63_SQL/60_contrepartie_prescrite.sql : tr_reevaluation_contrepartie ---
-- --- 3 : le refus, sur un lot de reevaluation --------------------------
-- Un lot DERIVABLE qui touche un compte de difference d'estimation doit
-- porter la contrepartie prescrite pour ce compte, et aucune autre
-- contrepartie de capital. Deux refus distincts, pour que le motif dise
-- lequel des 2 manquements est en cause.
CREATE   TRIGGER dbo.tr_reevaluation_contrepartie
ON dbo.ecriture
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Les lots de reevaluation touches par cette insertion.
    DECLARE @lots TABLE (lot_id INT PRIMARY KEY);
    INSERT INTO @lots (lot_id)
    SELECT DISTINCT i.lot_id
    FROM inserted i
    JOIN dbo.lot_ecritures l ON l.id = i.lot_id
    WHERE l.famille = 'DERIVABLE';
    IF NOT EXISTS (SELECT 1 FROM @lots) RETURN;

    -- Refus 1 : un compte d'estimation sans sa contrepartie prescrite
    -- dans le meme lot.
    DECLARE @manquants NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.txt AS NVARCHAR (60)), N', ')
         FROM (SELECT DISTINCT TOP 20
                      e.compte_num + N' attend ' + r.compte_contrepartie AS txt
               FROM dbo.v_ecriture_normalisee e
               JOIN @lots t ON t.lot_id = e.lot_id
               JOIN dbo.ref_contrepartie_estimation r
                 ON r.compte_estimation = e.compte_num
               WHERE NOT EXISTS (SELECT 1 FROM dbo.v_ecriture_normalisee c
                                 WHERE c.lot_id = e.lot_id
                                   AND c.compte_num = r.compte_contrepartie)
               ) AS x);
    IF @manquants IS NOT NULL
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Ecriture refusee : une reevaluation porte la contrepartie que '
          + N'le plan de comptes prescrit, elle ne la choisit pas. '
          + @manquants
          + N'. Article 411-3 du reglement ANC n° 2021-09 modifie par le '
          + N'reglement ANC n° 2024-01, et article 213-4 pour le compte 276.';
        THROW 50040, @m1, 1;
    END;

    -- Refus 2 : une contrepartie de capital presente dans le lot alors
    -- qu'aucun compte d'estimation ne la prescrit.
    DECLARE @intruses NVARCHAR (1200) =
        (SELECT STRING_AGG(CAST(x.compte_num AS NVARCHAR (24)), N', ')
         FROM (SELECT DISTINCT TOP 20 e.compte_num
               FROM dbo.v_ecriture_normalisee e
               JOIN @lots t ON t.lot_id = e.lot_id
               WHERE e.compte_num IN
                     (SELECT compte_contrepartie
                      FROM dbo.ref_contrepartie_estimation)
                 AND NOT EXISTS (SELECT 1
                                 FROM dbo.v_ecriture_normalisee s
                                 JOIN dbo.ref_contrepartie_estimation r
                                   ON r.compte_estimation = s.compte_num
                                 WHERE s.lot_id = e.lot_id
                                   AND r.compte_contrepartie = e.compte_num)
               ) AS x);
    IF @intruses IS NOT NULL
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Ecriture refusee : le lot porte la contrepartie de capital '
          + @intruses + N' alors qu''aucun compte de difference '
          + N'd''estimation du lot ne la prescrit. La correspondance se lit '
          + N'dans ref_contrepartie_estimation.';
        THROW 50040, @m2, 1;
    END;
END;

GO

