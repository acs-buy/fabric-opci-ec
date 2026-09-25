-- 185 -- Un refus metier se voit-il a l'ecran, ou passe-t-il pour un succes ?
-- 13/09/2026. Question ouverte par la mesure de l'agent Fabric IQ : une automatisation de bouton
-- ecrit en base et n'invalide PAS le cache de sa propre source. Le seul retour visuel est un toast
-- de 3 secondes, « Automation job completed successfully ».
--
-- CE QUE CELA MET EN CAUSE, ET C'EST UNE CONSTRUCTION DE CE PROJET, DONC DE MOI. Les 22 enveloppes
-- pr_ecran_* portent toutes le meme dispositif : un BEGIN TRY qui appelle la procedure metier, et
-- un BEGIN CATCH qui ecrit ERROR_MESSAGE() dans la colonne message_ecran de la ligne concernee.
-- Ce dispositif suppose DEUX choses que la mesure du 13/09 met en doute :
--   1. que le reviseur voie la colonne message_ecran se remplir. Or la grille sert un cache : elle
--      ne se rafraichit pas apres le clic, donc le message est ecrit et INVISIBLE.
--   2. que le service distingue un refus d'un succes. Or le CATCH avale l'erreur et ne la relance
--      pas : du point de vue du service, l'automatisation reussit TOUJOURS. Le toast vert
--      s'affiche donc aussi bien sur une approbation faite que sur une approbation refusee.
-- Si les 2 se confirment, un refus metier est indiscernable d'un succes pour le reviseur, et le
-- dispositif de message d'ecran ne sert a rien tant qu'aucun rafraichissement n'intervient.
--
-- DEUX PROCEDURES D'ESSAI, a cliquer l'une puis l'autre sur la meme feuille, pour comparer les
-- toasts. Elles n'ecrivent que dans la table d'essai du script 163.

-- CELLE QUI AVALE L'ERREUR, comme nos 22 enveloppes le font aujourd'hui.
CREATE   PROCEDURE dbo.pr_essai_refus_avale
    @id int = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        THROW 50001, N'REFUS METIER D''ESSAI : cette action est impossible dans cet etat.', 1;
    END TRY
    BEGIN CATCH
        UPDATE dbo.essai_saisie_grille
           SET libelle = N'REFUS avale : ' + LEFT(ERROR_MESSAGE(), 100)
         WHERE id = @id;
    END CATCH;
END;

GO

