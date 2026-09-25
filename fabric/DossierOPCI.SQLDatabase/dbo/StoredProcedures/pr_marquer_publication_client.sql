
-- --- 5 : le pipeline marque ce qu'il a publie ---------------------------
CREATE   PROCEDURE dbo.pr_marquer_publication_client
    @par   NVARCHAR (200),
    @etat  VARCHAR (10) = 'EN_COURS',
    @motif NVARCHAR (600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- EN_COURS : le pipeline ouvre la publication de chaque arrete a publier AVANT
    -- de rafraichir le modele ; publiee_le est la date de la photographie.
    -- PUBLIEE / EN_ECHEC : il ferme les publications en cours apres le rafraichissement.
    IF @etat = 'EN_COURS'
    BEGIN
        INSERT INTO dbo.publication_client (entite, arrete, visa_id, etat, publiee_par, motif)
        SELECT entite, arrete, visa_cloture_id, 'EN_COURS', @par, @motif
        FROM dbo.v_publication_client_a_faire;
        SELECT @@ROWCOUNT AS arretes_marques;
        RETURN;
    END
    IF @etat NOT IN ('PUBLIEE', 'EN_ECHEC')
        THROW 50142, 'Etat de publication inconnu : EN_COURS, PUBLIEE ou EN_ECHEC.', 1;
    UPDATE dbo.publication_client
       SET etat = @etat, terminee_le = SYSUTCDATETIME(),
           motif = COALESCE(@motif, motif)
     WHERE etat = 'EN_COURS';
    SELECT @@ROWCOUNT AS arretes_marques;
END;

GO

