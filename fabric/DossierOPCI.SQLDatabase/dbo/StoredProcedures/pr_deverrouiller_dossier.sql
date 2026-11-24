-- --- 6. pr_deverrouiller_dossier : refuse ----------------------------------------------------------------
-- 10. DEVERROUILLER LE DOSSIER : un motif, un demandeur et un decideur
-- distincts, le role qui vise la revue. La trace est un visa REVUE RENVOYE, motif « Déverrouillage : ».
-- : le deverrouillage passe par une demande (pr_ecran_demander_deverrouillage), decidee par
-- pr_ecran_accorder_reouverture ou pr_ecran_ecarter_reouverture ; cette procedure refuse (51253), memes parametres,
-- jusqu'au retrait de la fonction deverrouiller_dossier apres la pose d'ec02.
CREATE   PROCEDURE dbo.pr_deverrouiller_dossier
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @motif        NVARCHAR (500) = NULL,
    @demande_par  NVARCHAR (400) = NULL,
    @par          NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    THROW 51253, N'Déverrouillage refusé : il passe désormais par une demande. Tapez le motif et cliquez sur « Déverrouiller le dossier » ; le chef de mission la décide.', 1;
END;

GO

