
-- Les obstacles de l'annexe, apres le calcul (contrat, 3.1, point 3, 3, et 4.3) : pour ATTESTATION, les comptes annuels
-- produits sur une version de l'annexe et non perimes ; pour COMPTES_ANNUELS, un controle d'effet obstacle en ecart, et
-- rien d'autre (une cellule a remplir ou en attente ne refuse pas).
CREATE   FUNCTION dbo.fn_obstacle_annexe (@entite VARCHAR (20), @arrete VARCHAR (20), @livrable VARCHAR (20))
RETURNS NVARCHAR (2000)
AS
BEGIN
    IF @livrable = 'ATTESTATION'
       AND NOT EXISTS (SELECT 1 FROM dbo.demande_document dd
                       WHERE dd.entite = @entite AND dd.arrete = @arrete AND dd.livrable = 'COMPTES_ANNUELS' AND dd.etat = 'PRODUITE'
                         AND dd.version = (SELECT MAX(d.version) FROM dbo.document_produit d
                                           WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS')
                         AND NOT EXISTS (SELECT 1 FROM dbo.document_produit d
                                         WHERE d.entite = @entite AND d.arrete = @arrete AND d.livrable = 'COMPTES_ANNUELS'
                                           AND d.version = dd.version AND (d.perime_le IS NOT NULL OR d.annexe_version IS NULL)))
        RETURN N'les comptes annuels de l''arrêté ne sont pas produits, ou leur dernière version est périmée ; le rapport de l''expert-comptable les couvre.';
    IF @livrable = 'COMPTES_ANNUELS'
        RETURN dbo.fn_ann_message_obstacle(@entite, @arrete);
    RETURN NULL;
END;

GO

