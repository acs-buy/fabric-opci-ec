

-- --- 7 : O19, la reouverture d'un arrete ----------------------------
-- 50095 : l'etape 5 n'est pas cloturee, il n'y a rien a rouvrir.
-- 50096 : la reouverture est reservee au chef de mission.
-- 50097 : la reouverture exige un motif.
CREATE   PROCEDURE dbo.pr_rouvrir_arrete
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @motif  NVARCHAR (600),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    IF @motif IS NULL OR LEN(LTRIM(@motif)) = 0
        THROW 50097,
            N'Réouverture refusée : elle exige un motif, qui dit quel lot tardif justifie de rouvrir un arrêté clôturé.',
            1;

    IF NOT EXISTS (SELECT 1 FROM dbo.visa v
                   WHERE v.nature = 'CLOTURE' AND v.entite = @entite
                     AND v.arrete = @arrete AND v.decision = 'VISE')
        THROW 50095,
            N'Réouverture refusée : l''étape 5 de cet arrêté n''est pas clôturée, il n''y a rien à rouvrir.',
            1;

    IF dbo.fn_peut_viser_nature(@entite, @par, 'CLOTURE',
                                CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50096,
            N'Réouverture refusée : elle relève du chef de mission, qui a clôturé l''arrêté.',
            1;

    BEGIN TRANSACTION;
    -- Le visa de cloture est renvoye, non supprime : la trace demeure.
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                          decision, motif, propose_par, decide_par, decide_le)
    VALUES ('CLOTURE', @entite + '|' + @arrete, @entite, @arrete, NULL,
            'RENVOYE', N'Réouverture : ' + @motif, @par, @par,
            SYSUTCDATETIME());

    -- LES LIVRABLES PRODUITS DEVIENNENT PERIMES. C'est le SEUL evenement
    -- qui pose « perime » sur un document, ce que le point O19 exige.
    UPDATE dbo.document_produit
    SET perime_le = SYSUTCDATETIME(),
        perime_motif = N'Arrêté rouvert le '
                     + FORMAT(SYSUTCDATETIME(), 'dd/MM/yyyy', 'fr-FR')
                     + N' : ' + @motif
                     + N' Le document a été produit sur des comptes '
                     + N'antérieurs à la réouverture.'
    WHERE entite = @entite AND arrete = @arrete AND perime_le IS NULL;

    -- LA FORME DE L'ATTESTATION EST A ARRETER DE NOUVEAU.
    UPDATE dbo.attestation
    SET arretee_par = NULL, arretee_le = NULL,
        produit_par = NULL, produit_le = NULL
    WHERE entite = @entite AND arrete = @arrete;
    COMMIT TRANSACTION;
END;

GO

