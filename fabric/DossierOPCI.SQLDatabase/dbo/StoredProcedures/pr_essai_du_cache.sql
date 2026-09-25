-- 184 -- Une procedure d'essai pour mesurer si une grille voit le resultat d'un bouton
-- 13/09/2026. La question a trancher : le cache cote service des grilles PowerTable est-il
-- invalide quand une automatisation de bouton ecrit en base ? Trois issues possibles, et elles ne
-- se valent pas : le cache est vide pour toutes les grilles, pour la seule grille du bouton, ou
-- pour aucune. La troisieme produirait des doubles clics sur des boutons qui semblent sans effet.
--
-- POURQUOI UNE PROCEDURE D'ESSAI ET NON UNE PROCEDURE DU DOSSIER. Le protocole propose employait
-- pr_ecran_approuver_acceptation sur une entite sans ligne d'acceptation. Deux defauts :
--   1. acceptation_mission ne porte QU'UNE ligne, OMEGA-OPCI approuvee, et c'est la ligne du
--      dossier de demonstration. Toute ecriture dessus abime le jeu.
--   2. Si la procedure REFUSE, elle n'ecrit rien, et l'essai ne mesure pas le cache : il mesure
--      l'affichage d'un message d'erreur. Un essai de cache exige une ecriture CERTAINE.
-- Celle-ci ecrit a tout coup, dans la table d'essai du script 163, et se defait par un UPDATE.
--
-- CE QU'ELLE FAIT : elle incremente quantite et ecrit l'heure dans libelle, sur la ligne demandee.
-- Aucune garde, aucun THROW, aucune condition : deux appels produisent deux increments, ce qui
-- rend le second clic VISIBLE au lieu de le faire refuser.

CREATE   PROCEDURE dbo.pr_essai_du_cache
    @id int = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.essai_saisie_grille
       SET quantite = ISNULL(quantite, 0) + 1,
           libelle  = N'clic ' + CAST(ISNULL(quantite, 0) + 1 AS nvarchar(10))
                      + N' a ' + CONVERT(nvarchar(8), SYSDATETIME(), 108)
     WHERE id = @id;
END;

GO

