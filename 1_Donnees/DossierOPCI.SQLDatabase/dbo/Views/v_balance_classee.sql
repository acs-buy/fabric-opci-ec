
-- --- 3 : O9, la classe du compte a cote de la balance --------------
-- LA VUE DE BALANCE N'EST PAS MODIFIEE, et c'est un choix. Y ajouter une
-- colonne demanderait de la reecrire en entier : elle porte 9 colonnes
-- d'agregat sur les 3 familles de lots, et la reecrire pour une colonne
-- de plus ferait divergerdeux definitions du meme calcul. La classe est
-- donc posee par une vue derivee, que l'ecran E4-0b lit a la place.
-- Une premiere tentative de reecrire la definition lue de
-- sys.sql_modules a echoue : le texte rendu ne portait pas la chaine
-- attendue et le CREATE a ete rejoue tel quel, refuse par la base.
CREATE   VIEW dbo.v_balance_classee AS
SELECT b.*,
       dbo.fn_classe_du_compte(b.compte) AS classe,
       LEFT(b.compte, 1)                 AS classe_code
FROM dbo.v_balance b;

GO

