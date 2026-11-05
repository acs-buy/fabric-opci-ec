# Les tests d'acceptation, après la reproduction

**Quand :** après l'étape 13, une fois ses 12 actions passées.
**Qui :** les personnes qui se serviront de la solution : 3 membres de l'équipe de la mission et 1 compte de
l'audience client. Celui qui a installé en fait partie s'il se sert de la solution.
**Durée :** 24 heures de jeu en tout, soit 5 minutes par test scénarisé, 15 minutes par contrôle par recalcul et 45 minutes par parcours métier, réparties entre les comptes, estimation.

L'étape 13 établit que l'installation fonctionne, du clic jusqu'à la base. Les tests d'acceptation par
l'utilisateur (User Acceptance Testing, UAT) établissent que la solution sert les besoins de ceux qui
s'en servent : le réviseur qui conduit la mission, et le client qui lit l'état de son véhicule.

| | L'étape 13, la recette | Les tests d'acceptation |
|---|---|---|
| Qui la joue | Celui qui a installé, plus un collègue | Les utilisateurs métier, chacun avec son compte |
| Ce qu'elle établit | La chaîne du clic à la base fonctionne | Chaque besoin est servi, et chaque contrôle de la base tient |
| Son contenu | 12 actions | 180 tests, en 7 étapes de jeu |
| Sa trace | La date et le résultat des 12 actions | Le classeur rempli et un procès-verbal |

---

## Les 2 sortes de tests

| La sorte | Combien | Ce que l'utilisateur fait |
|---|---|---|
| Les tests scénarisés | 152 | Il suit des actions écrites, avec le nom exact des boutons, et compare ce qu'il obtient au résultat écrit, message compris |
| Les tests manuels des utilisateurs métier | 28 | Il conduit un dossier comme en mission, sans action imposée, et il refait à la main des calculs qu'il lit à l'écran |

Les tests manuels sont de 2 natures :

| La nature | Ce que le testeur fait | Ce qu'il note |
|---|---|---|
| Parcours métier | Il conduit une partie de la mission sur le jeu de démonstration, dans l'ordre qu'il choisit | Ce qui l'a arrêté, ce qui lui a manqué, le temps passé |
| Contrôle par recalcul | Il lit des montants à l'écran et refait le calcul à la main ou dans un tableur | L'écart entre son calcul et celui de la solution |

---

## Où les jouer

| Votre installation | Où | Pourquoi |
|---|---|---|
| Un seul espace | L'espace reproduit, sur le jeu de démonstration | Les tests écrivent dans les dossiers de démonstration, que `sql/89_effacer_la_demonstration.sql` retire avant vos premiers dossiers |
| Trois espaces | TEST, jamais PROD | Chaque clic écrit en base, et la base ne distingue pas un essai d'un acte professionnel |

Dans une installation en 3 espaces, l'étape 11 se joue en PROD. Pour la phase, publiez aussi
l'application de l'espace TEST, comme à [l'étape 11](etape-11-publier-les-applications.md), avec les 2 audiences
et les seuls comptes de la phase : l'éditeur permet 1 application par espace de travail.

---

## Avant de commencer

| Ce qu'il faut | Pourquoi |
|---|---|
| L'étape 13 passée | Un test d'acceptation suppose que la chaîne du clic à la base fonctionne |
| L'étape 12 faite | Les tests des pièces justificatives passent par SharePoint |
| Les comptes 1 et 2 inscrits par `sql/90_vous_inscrire_aux_missions.sql`, à l'étape 7 : le compte 1 en `@vous`, le compte 2 en `@second` | Le compte 1 tient les mandats d'associé et de préparateur, le compte 2 ceux de chef de mission ; la base refuse un visa à qui a proposé |
| Un compte 3 de l'équipe, sans mandat | Certains tests le désignent sur un dossier, d'autres vérifient qu'un membre sans mandat ne voit aucun dossier |
| Les comptes 2 et 3 en lecteurs, par l'application, et placés dans le rôle `Reviseur` du modèle `conduite_de_mission` | La sécurité au niveau des lignes ne s'applique qu'aux lecteurs : un membre de l'espace voit tous les dossiers, et les tests du cloisonnement entre membres de l'équipe échoueraient |
| 1 compte de l'audience client, en lecteur, placé dans le rôle de sécurité du véhicule de démonstration du modèle `restitution_client` | Les tests de la restitution vérifient ce que le client voit, et ce qu'il ne voit pas |
| Une copie du classeur [`cahier-de-tests.xlsx`](cahier-de-tests.xlsx) | C'est la trace de la phase |

Un rôle de sécurité se garnit par le menu **Security** du modèle, comme à
[l'étape 11](etape-11-publier-les-applications.md) : survolez `conduite_de_mission`, **More options**,
**Security**, rôle `Reviseur`, **Assign**.

Les tests créent des dossiers d'essai, dont le code commence par `UAT-`. Ce ne sont pas des entités du jeu de
démonstration : `sql/89_effacer_la_demonstration.sql` ne les retire pas, et aucun écran ne supprime un client.
Dans une installation à un seul espace, ils restent donc dans la liste des clients. Pour ne pas les garder,
jouez la phase dans TEST d'une installation en 3 espaces.

---

## Consigner les résultats

1. Copiez le classeur, une copie par phase.
2. Jouez le cahier de haut en bas, étape de jeu après étape de jeu : un test emploie souvent ce qu'un test
   précédent a créé.
3. Pour chaque test, remplissez le résultat obtenu, le statut, le testeur et la date. Pour un test manuel,
   ajoutez les constats et le temps passé.
4. Un échec reçoit un numéro d'anomalie, décrite à la feuille « Anomalies » : ce qui s'est produit, le
   message recopié tel quel, la criticité, l'origine.

| Le statut | Quand le donner |
|---|---|
| Passé | Le résultat obtenu est le résultat écrit |
| Échec | Le résultat obtenu diffère du résultat écrit |
| Bloqué | Le test ne peut pas être joué : un prérequis manque, ou un test précédent a échoué |
| Non joué | Le test n'a pas été joué |
| Sans objet | Un test marqué « 3 espaces seulement », dans une installation à un seul espace |

---

## La criticité d'un échec

Chaque test porte la criticité qu'aurait son échec.

| La criticité | Ce qu'elle signifie |
|---|---|
| Bloquante | Le besoin n'est pas servi, ou un contrôle de la base manque : séparation des fonctions, cloisonnement du client |
| Majeure | Le besoin est servi, mais par un autre chemin que celui prévu |
| Mineure | Présentation ou libellé |

---

## La décision

La feuille « Procès-verbal » du classeur compte les statuts. La condition d'acceptation est remplie quand
chaque test Bloquant ou Majeur applicable porte le statut Passé.

| La décision | Quand |
|---|---|
| Acceptée | La condition est remplie, et aucune anomalie ne reste ouverte |
| Acceptée avec réserves | La condition est remplie, et des anomalies mineures restent ouvertes : elles sont listées en réserves |
| Refusée | Un test Bloquant ou Majeur applicable n'est pas passé |

Le procès-verbal tient en 3 lignes :

> Phase passée le **<date>**, dans l'espace **<nom>**, par **<noms>**.
> Tests passés : **<nombre>** sur 180. Tests en échec : **<lesquels>**.
> Décision : **<acceptée, acceptée avec réserves, ou refusée>**, prise par **<nom>**.

Dans une installation en 3 espaces, TEST ne se déploie vers PROD qu'une fois la phase acceptée.

---

## Ce que vous faites d'un échec

| L'origine | Ce que vous faites |
|---|---|
| Une étape de l'installation | La page [Dépannage](depannage.md) donne la cause de chaque symptôme ; corrigez, puis rejouez le test |
| La solution : une installation conforme ne produit pas le résultat écrit | Signalez-le au dépôt, modèle « Un test d'acceptation en échec » |
| Le cahier : le résultat écrit ne correspond plus à la solution | Signalez-le au dépôt, modèle « Une affirmation devenue fausse » |

---

Suite : [Le cahier des tests d'acceptation](cahier-de-tests.md)

[Revenir au sommaire](../../README.md) · [Étape 13. La recette](etape-13-passer-la-recette.md) · [Dépannage](depannage.md)
