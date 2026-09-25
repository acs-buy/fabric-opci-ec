-- 180 -- Deux defauts du contexte de travail, releves a l'essai du 13/09/2026
-- Ils viennent de la demonstration menee par l'agent Fabric IQ sur l'ecran d'essai, et non d'une
-- relecture de code : la grille « Mon contexte » a accepte SCI-NORD comme vehicule, et les grilles
-- du dessous se sont videes sans rien dire.
--
-- DEFAUT 1, LE VEHICULE MUET. La cle etrangere de contexte_reviseur pointe ref_entite, donc les 16
-- entites, alors que seules 2 sont des VEHICULES au sens de v_perimetre_groupe : OMEGA-OPCI, qui
-- porte 13 entites, et OPCI-1, qui en porte 3. Saisir SCI-NORD, qui est une filiale, est accepte
-- par la base et rend un perimetre vide, donc un ecran vide sans explication. Le reviseur n'a
-- aucun moyen de savoir s'il s'est trompe ou si le dossier est vide.
-- CE QUI EST POSE : un message_ecran dans la grille de contexte, et une grille de reference qui
-- liste les vehicules ouverts. Ce n'est PAS une contrainte : une contrainte refuserait la saisie
-- et PowerTable rendrait une erreur de base illisible. Le message laisse saisir et explique.
--
-- DEFAUT 2, L'HORODATAGE QUI NE BOUGE PAS, TRANCHE LE 13/09/2026 PAR LE RETRAIT. modifie_le porte un DEFAULT, qui ne joue qu'a
-- l'insertion. Apres la modification du 13/09 par la grille, la colonne portait encore l'heure de
-- l'insertion. Un declencheur AFTER UPDATE est essaye ci-dessous.
-- SI LE SERVICE LE REFUSE : ne pas contourner, retirer la colonne de la grille et ecrire ici que
-- l'horodatage du contexte n'est pas tenu. Une colonne qui ment est pire qu'une colonne absente.

CREATE   VIEW dbo.v_ecran_vehicules_ouverts AS
SELECT p.vehicule,
       COUNT(*)                                   AS entites_du_groupe,
       (SELECT COUNT(*) FROM dbo.v_arrete_statut a
        WHERE a.entite = p.vehicule AND a.statut = 'OUVERT') AS arretes_ouverts
FROM dbo.v_perimetre_groupe p
GROUP BY p.vehicule;

GO

