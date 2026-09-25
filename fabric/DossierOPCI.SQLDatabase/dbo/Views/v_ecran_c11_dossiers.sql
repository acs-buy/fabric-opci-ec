-- 175 -- Les 5 grilles de l'ecran 1.1, filtrees par le contexte du reviseur
-- 13/09/2026. Premiere application du contexte de travail pose au script 174. Chaque grille de cet
-- ecran ne montre desormais que le perimetre choisi par la personne connectee, et elle reste
-- SAISISSABLE : eprouve ce jour, un UPDATE et un INSERT passent a travers une vue qui filtre par
-- EXISTS sur une seule table de base, la transaction d'essai ayant ete annulee.
--
-- POURQUOI EXISTS ET NON UNE JOINTURE : une vue qui joint 2 tables n'accepte plus l'insertion.
-- EXISTS laisse une seule table dans le FROM, donc la vue reste modifiable, ce qu'une grille de
-- saisie exige. C'est la difference entre un ecran qui se lit et un ecran ou l'on travaille.
--
-- CE QUI ARRIVE QUAND AUCUN CONTEXTE N'EST CHOISI : les 5 grilles sont VIDES. C'est voulu. Un ecran
-- sans contexte ne doit rien montrer plutot que de montrer le dossier d'un autre.
--
-- LES 5 SOURCES ET LEUR CLE DE RATTACHEMENT, relevees ce jour :
--   v_ecran_etat_dossier   entite            (vue)
--   acceptation_mission    entite            (table)
--   arrete_mission         entite et arrete  (table)
--   maintien_mission       entite            (table)
--   feuille_question       cote seulement    (table) : elle ne porte NI entite NI arrete, son
--                          rattachement passe par la feuille de travail qui la porte.

CREATE   VIEW dbo.v_ecran_c11_dossiers AS
SELECT t.* FROM dbo.v_ecran_etat_dossier t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

