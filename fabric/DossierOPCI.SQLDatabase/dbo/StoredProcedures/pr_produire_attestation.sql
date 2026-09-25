

-- --- 6 : O18, la production de l'attestation ------------------------
-- 50092 : l'associe signataire seul produit l'attestation.
-- 50093 : la forme n'est pas arretee.
-- 50094 : l'etape 5 n'est pas cloturee.
CREATE   PROCEDURE dbo.pr_produire_attestation
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @chemin NVARCHAR (600),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    IF dbo.fn_peut_viser_nature(@entite, @par, 'PUBLICATION',
                                CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50092,
            N'Production refusée : l''attestation est signée par l''associé signataire, et lui seul la produit.',
            1;

    IF NOT EXISTS (SELECT 1 FROM dbo.attestation a
                   WHERE a.entite = @entite AND a.arrete = @arrete
                     AND a.arretee_le IS NOT NULL)
        THROW 50093,
            N'Production refusée : la forme de l''attestation n''est pas arrêtée pour cet arrêté.',
            1;

    IF NOT EXISTS (SELECT 1 FROM dbo.visa v
                   WHERE v.nature = 'CLOTURE' AND v.entite = @entite
                     AND v.arrete = @arrete AND v.decision = 'VISE')
        THROW 50094,
            N'Production refusée : l''étape 5 n''est pas clôturée. Les livrables ne se produisent qu''une fois l''arrêté fermé par le chef de mission.',
            1;

    -- La version suivante, et l'empreinte des comptes couverts : une
    -- nouvelle version des comptes perime l'attestation, ce que le point
    -- O18 exige.
    DECLARE @v INT = (SELECT COALESCE(MAX(version), 0) + 1
                      FROM dbo.document_produit
                      WHERE entite = @entite AND arrete = @arrete
                        AND livrable = 'ATTESTATION');
    DECLARE @empreinte CHAR (64) = CONVERT(CHAR (64), HASHBYTES('SHA2_256',
        (SELECT STRING_AGG(CAST(CAST(x.exercice_n AS VARCHAR (30))
                                AS NVARCHAR (MAX)), N'|')
         FROM dbo.v_ligne_etat_montant x
         WHERE x.entite = @entite AND x.arrete = @arrete)), 2);

    INSERT INTO dbo.document_produit
        (entite, arrete, livrable, version, chemin_coffre, empreinte_sha256,
         produit_par, produit_le)
    VALUES (@entite, @arrete, 'ATTESTATION', @v, @chemin, @empreinte,
            @par, SYSUTCDATETIME());

    UPDATE dbo.attestation
    SET produit_par = @par, produit_le = SYSUTCDATETIME()
    WHERE entite = @entite AND arrete = @arrete;
END;

GO

