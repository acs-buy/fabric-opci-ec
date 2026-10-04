# Le cahier de tests, à faire passer dans l'espace TEST

**Durée :** une demi-journée pour deux personnes.
**Qui :** vos collaborateurs, pas vous. Celui qui a installé ne teste pas ce qu'il a installé.

Ce cahier est **indicatif**. Retirez ce qui ne concerne pas votre cabinet, ajoutez ce qui manque, et
gardez la trace de qui a testé quoi.

**Il se passe dans TEST, jamais dans PROD.** Chaque clic écrit en base, et la base ne distingue pas
un essai d'un acte professionnel.

---

## Avant de commencer

| Ce qu'il faut | Pourquoi |
|---|---|
| Deux comptes distincts | L'approbation d'un visa est refusée à qui l'a soumis |
| Les deux comptes inscrits aux missions de TEST | Sans rôle, l'écran est vide |
| Le jeu de démonstration chargé | Sans lui, les écrans sont vides |
| Une heure sans interruption pour chaque testeur | Un test interrompu est un test à refaire |

---

## Partie 1. L'écran du réviseur, douze actions

Ce sont les douze actions de [l'étape 13](etape-13-passer-la-recette.md). Le détail de ce que
chacune doit rendre y figure, avec les messages exacts.

| # | L'action | Passé | Par qui | Remarque |
|---|---|---|---|---|
| 1 | Créer un dossier client, et voir son questionnaire s'ouvrir | ☐ | | |
| 2 | Modifier le client, un champ vide restant inchangé | ☐ | | |
| 3 | Enregistrer le site du client | ☐ | | |
| 4 | Ajouter une filiale au périmètre | ☐ | | |
| 5 | Modifier une filiale, et la retrouver au journal | ☐ | | |
| 6 | Supprimer une filiale | ☐ | | |
| 7 | Répondre à une question, enregistrée au clic | ☐ | | |
| 8 | Déposer une pièce, avec sa nature et son déposant | ☐ | | |
| 9 | Retirer une pièce, motif obligatoire | ☐ | | |
| 10 | Soumettre le dossier au visa | ☐ | | |
| 11 | Approuver le visa **avec le second compte** | ☐ | | |
| 12 | Ouvrir un arrêté planifié | ☐ | | |

---

## Partie 2. Les refus, qui prouvent les contrôles

Provoquez ces refus, et lisez le
message : il doit être en français et dire quoi faire.

| # | Ce que vous tentez | Le refus attendu | Passé |
|---|---|---|---|
| 13 | Approuver un visa que vous avez soumis | L'approbation revient à un autre | ☐ |
| 14 | Retirer une pièce sans motif | Le motif est obligatoire | ☐ |
| 15 | Saisir des droits de vote à 75 | Ils se donnent entre 0 et 1 | ☐ |
| 16 | Approuver une acceptation incomplète | Le nombre de questions sans réponse, et la première nommée | ☐ |
| 17 | Créer un client avec un code existant | Un client se crée une fois | ☐ |

**Si l'un de ces refus n'arrive pas**, arrêtez le test et prévenez celui qui a installé. Un
contrôle absent en TEST sera absent en PROD.

---

## Partie 3. L'écran du client

À faire avec un compte de l'audience client, jamais avec le vôtre.

| # | Ce que vous vérifiez | Passé |
|---|---|---|
| 18 | Les huit pages s'ouvrent et portent des valeurs | ☐ |
| 19 | Le choix d'un arrêté aligne toutes les pages | ☐ |
| 20 | Un arrêté non visé n'apparaît pas | ☐ |
| 21 | Le compte client **ne voit pas** l'écran de conduite | ☐ |
| 22 | Le compte client **ne voit que son véhicule** | ☐ |

**Ne signez pas le cahier sans le test 22.** Faites-le avec deux clients différents, et
vérifiez que chacun ne voit que le sien. Seul ce test détecte un rôle de sécurité oublié.

---

## Partie 4. Ce que le déploiement a pu casser

Ces 4 tests portent sur le passage d'un espace à l'autre.

| # | Ce que vous vérifiez | Comment | Passé |
|---|---|---|---|
| 23 | Les boutons écrivent dans la base **de cet espace** | Cliquez, puis relisez la ligne dans la base de TEST | ☐ |
| 24 | Le modèle interroge la base **de cet espace** | Paramètres du modèle, section des sources | ☐ |
| 25 | Les comptes de contrôle des données sont conformes | La sortie de `99_terminer_le_chargement.sql` | ☐ |
| 26 | Les rôles de sécurité existent dans cet espace | La page de sécurité du modèle de restitution | ☐ |

**Le test 23 rattrape une erreur qui ne se voit pas autrement.** Un bouton déployé garde la référence
des fonctions de DEV : il répond normalement, et il écrit au mauvais endroit.

---

## Ce qu'on écrit à la fin

Une ligne suffit.

> Cahier passé le **<date>**, dans l'espace TEST, par **<noms>**.
> Tests passés : **<nombre>** sur 26. Tests en échec : **<lesquels>**.
> Décision : **<déploiement en production autorisé, ou non, et pourquoi>**.

**Ne déployez pas en production tant qu'un test de la partie 2 ou 3 est en échec.**

---

Suite : [Étape 11. Publier les deux écrans, à deux publics distincts](etape-11-publier-les-applications.md)

[Revenir au sommaire](../../README.md) · [Déployer en trois espaces](deployer-en-trois-espaces.md)
