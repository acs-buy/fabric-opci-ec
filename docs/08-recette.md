# 8. La recette : douze actions qui prouvent que la solution marche

Ces douze actions parcourent la chaîne complète, du clic jusqu'à l'écriture en base. Si elles passent
toutes, votre installation est bonne.

Faites-les dans l'ordre : chacune prépare la suivante.

| # | L'action à faire | Où | Ce que vous devez obtenir |
|---|---|---|---|
| 1 | Créer un dossier client | Section Dossier, sous-état Nouveau dossier | Le dossier apparaît, et son questionnaire d'acceptation s'ouvre seul |
| 2 | Modifier les informations du client | Sous-état Modifier | La valeur change, un champ laissé vide reste inchangé |
| 3 | Enregistrer le site du client | Même formulaire | Le lien devient cliquable dans la fiche |
| 4 | Ajouter une filiale | Section Filiales | La filiale entre au périmètre |
| 5 | Modifier une filiale | Section Filiales | Le changement est tracé au journal du périmètre |
| 6 | Supprimer une filiale | Section Filiales | Refus motivé si la filiale porte des données de mission |
| 7 | Répondre à une question | Section Questionnaire | La réponse est enregistrée au clic, sans bouton de validation |
| 8 | Déposer une pièce | Section Questionnaire | La pièce apparaît avec sa nature, sa date et son déposant |
| 9 | Retirer une pièce | Section Questionnaire | Motif obligatoire, refus si la pièce fonde une donnée |
| 10 | Soumettre au visa | Section Visa | Le dossier passe en attente d'approbation |
| 11 | Approuver le visa | Section Visa, **avec un second compte** | Refusé au compte qui a soumis, accepté à l'autre |
| 12 | Ouvrir un arrêté | Section Arrêtés | L'arrêté planifié devient ouvert |

## L'action 11 mérite une explication

L'approbation est refusée à la personne qui a soumis le dossier. Ce n'est pas un défaut : c'est la
séparation des fonctions, et elle est portée par la base, non par l'écran. Un utilisateur qui
contournerait l'écran se verrait opposer le même refus.

Pour l'éprouver, il vous faut deux comptes, et le second doit porter un rôle sur le dossier. La
désignation se fait sur l'écran lui-même, section **Équipe de la mission**.

## Ce qu'un échec vous apprend

| Symptôme | Cause la plus probable |
|---|---|
| Le bouton ne fait rien | L'étape 6 n'est pas faite, les boutons appellent encore l'espace d'origine |
| « Fonction introuvable » | La connexion de l'étape 5 n'est pas posée, ou la publication n'a pas abouti |
| L'écran est vide | Les données de l'étape 5 ne sont pas chargées |
| Aucun visuel ne s'affiche | Le modèle n'est pas relié, étape 6, premier script |
| « Écriture refusée : rôle » | Votre compte ne porte aucun rôle sur ce dossier. C'est le comportement attendu |

La page [9. Dépannage](09-depannage.md) reprend chacune de ces causes en détail.

## Garder une trace

Notez la date de votre recette et le résultat des douze actions. Si vous adaptez la solution plus
tard, cette liste vous dira ce qui marchait avant votre modification.
