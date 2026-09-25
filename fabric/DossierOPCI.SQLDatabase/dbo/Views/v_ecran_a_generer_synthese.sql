-- =====================================================================
-- LES VUES D'ECRAN : v_ecran_<nom> = la vue d'origine, plus cle_ecran.
--
-- POURQUOI. PowerTable identifie chaque ligne d'une feuille par une colonne
-- d'identite ; sur une table elle se deduit de la cle primaire, une vue n'en a
-- pas, et les 52 feuilles branchees sur des vues ne s'affichaient pas, fait
-- etabli au portail le 06/09/2026 par la session des ecrans. Le candidat a
-- demande une colonne d'identifiant construite sur chaque vue d'ecran.
--
-- POURQUOI DES VUES D'ENVELOPPE ET NON 52 EDITIONS. Ajouter une colonne a une
-- vue oblige a la redefinir ; les 52 definitions vivent dans 25 scripts, et
-- les recopier ici les ferait diverger. L'enveloppe lit la vue d'origine par
-- v.*, si bien que toute colonne ajoutee a l'origine remonte d'elle-meme.
-- L'ecran lit v_ecran_x, la base garde v_x.
--
-- LA CLE. Texte, non nul, unique sur la vue : la concatenation des colonnes
-- qui distinguent la ligne, separees par « | », les NULL rendus vides. Quand
-- la vue porte deja un identifiant simple, la cle en est la copie en texte.
-- L'unicite est CONTROLEE par le bloc final : une vue dont la cle ne serait
-- pas unique y apparait, et la feuille ne doit pas etre branchee dessus.
--
-- LIMITE, posee par la session des ecrans : la cle rend la feuille
-- affichable, non modifiable ; une vue jointe ou agregee reste en lecture.
-- Genere par scratchpad/gen_144.py le 06/09/2026, 52 vues.
-- A executer contre la BASE SQL Fabric DossierOPCI, apres le 143.
-- =====================================================================

CREATE   VIEW dbo.v_ecran_a_generer_synthese AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') AS cle_ecran, v.*
FROM dbo.v_a_generer_synthese v;

GO

