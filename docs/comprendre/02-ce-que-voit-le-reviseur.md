# 2. Ce que voit le réviseur

> Les images de cette page sont des maquettes de conception. L'écran de conduite n'est pas encore
> terminé : une capture prise aujourd'hui montrerait un écran incomplet, et elle serait fausse
> demain. Les maquettes, elles, montrent la structure retenue, qui ne bougera plus. L'écran publié
> peut différer dans le détail.
>
> Les deux images prises sur l'installation réelle portent la mention.

---

## La question à laquelle l'écran répond

Où en sont mes missions, et sur quoi dois-je agir aujourd'hui ?

L'écran lit la base directement. Ce qu'il affiche est vrai à l'instant où vous le regardez, et non
à la date où quelqu'un a mis un classeur à jour pour la dernière fois.

---

## L'organisation de l'écran

Toujours la même, quel que soit le dossier ouvert.

En haut, l'en-tête : le cabinet, le client sélectionné, l'exercice. Juste en dessous, deux onglets
donnent accès aux deux écrans, la conduite de mission et la révision. Vient ensuite la bande
d'indicateurs, cinq compteurs qui donnent l'état du cabinet en un coup d'œil, puis la barre des
étapes, qui suit les cinq temps du dossier, de la création à l'arrêté. Tout le reste de la page est
la zone de travail, où s'affiche le détail de l'étape ouverte.

![L'en-tête, les cinq indicateurs et la barre des étapes](../../captures/conduite-indicateurs.png)

*Capture de l'installation réelle.*

### Les cinq indicateurs de la bande

Chacun compte ce qui reste ouvert.

| L'indicateur | Ce qu'il compte |
|---|---|
| Clients du cabinet | Les dossiers suivis |
| Acceptations à faire | Les dossiers dont l'acceptation n'est pas achevée |
| Maintiens à faire | Les maintiens de mission attendus à la fin d'un arrêté |
| Arrêtés ouverts | Les arrêtés en cours, tous dossiers confondus |
| Cycles à valider | Les cycles de révision qui attendent une conclusion |

Sous les indicateurs, la liste des clients montre chaque véhicule avec ses filiales, et pour chacun
l'état de l'acceptation et du maintien.

![La liste des clients et de leur périmètre](../../captures/conduite-liste-clients.png)

*Capture de l'installation réelle.*

---

## Les cinq temps du dossier

La barre des étapes suit le parcours d'un dossier client de bout en bout.

### 1. Le dossier

La fiche du client : identité, dénomination, forme du véhicule, adresse, dirigeant, contact, site
documentaire. S'y ajoutent l'acceptation et sa date, les maintiens par exercice, les arrêtés, le
périmètre et l'équipe de la mission.

Deux sous-états s'ouvrent depuis cette fiche : **Nouveau dossier** pour créer un client, **Modifier**
pour corriger une fiche existante.

Quand vous créez un client, son questionnaire d'acceptation s'ouvre dans la foulée. Vous n'avez pas
à y penser, et aucun dossier ne peut exister sans son questionnaire.

![La fiche du dossier](../../captures/maquettes/fiche-du-dossier.png)

*Maquette de conception. La fiche porte l'identité, l'équipe de la mission avec son alerte de cumul
de rôles, l'acceptation, les maintiens par exercice et les arrêtés.*

![Le formulaire de création d'un dossier](../../captures/maquettes/nouveau-dossier.png)

*Maquette de conception. Le sous-état de création.*

### 2. Les filiales

Le périmètre du véhicule, où vous ajoutez une filiale, la modifiez ou la supprimez.

La suppression est refusée dès lors que des données de mission sont rattachées à la filiale, et le
refus vous dit ce qui s'y oppose. Il vient de la base. Chaque changement de périmètre est écrit dans
un journal.

![Le périmètre du véhicule](../../captures/maquettes/filiales-liste.png)

*Maquette de conception.*

![Le refus motivé d'une suppression](../../captures/maquettes/filiales-suppression-refusee.png)

*Maquette de conception. Le refus nomme ce qui s'oppose à la suppression.*

### 3. Le questionnaire et les pièces

La grille des questions d'acceptation, avec pour chacune sa section, sa référence, son énoncé et sa
réponse.

Votre réponse est enregistrée au clic. Il n'y a pas de bouton de validation en bas de grille : si
vous êtes interrompu au milieu du questionnaire, vous retrouvez les réponses déjà cliquées.

Dessous figurent les pièces justificatives déposées, avec leur nature, leur date de dépôt et le nom
du déposant. Pour en retirer une, il faut un motif, et le retrait est refusé si la pièce fonde une
donnée.

![La grille des questions et les pièces](../../captures/maquettes/questionnaire-et-pieces.png)

*Maquette de conception.*

### 4. Le visa

La soumission du dossier à l'approbation, puis l'approbation elle-même. Celui qui a soumis ne peut
pas approuver : voir plus bas, la partie sur la qualité.

![La soumission au visa et son approbation](../../captures/maquettes/visa.png)

*Maquette de conception.*

### 5. Les arrêtés

Les arrêtés planifiés de l'exercice, et leur ouverture.

Un arrêté planifié n'est qu'une échéance au calendrier ; il faut l'ouvrir pour y travailler. La
distinction évite qu'on commence un arrêté que personne n'a décidé.

![Les arrêtés de l'exercice](../../captures/maquettes/arretes.png)

*Maquette de conception.*

---

## Les quatre natures d'action, et où l'écran les montre

Un retard n'appelle pas la même décision selon sa cause, et l'écran les sépare.

### Le planning

Vous lisez les arrêtés planifiés, ceux qui sont ouverts, celui qui attend son visa, et la date de
clôture visée. De là, vous relancez le client ou vous décalez l'arrêté.

### L'affectation des personnes

La section **Équipe de la mission** affiche une ligne par rôle attendu, qu'il soit tenu ou non. Une
table qui ne montrerait que les mandats existants vous laisserait deviner qu'il manque un associé.
Ici, la ligne « Non désigné » se lit, et c'est sur elle que se trouve le bouton de désignation.

Trois signaux s'y ajoutent :

| Le signal | Ce qu'il veut dire |
|---|---|
| **À désigner** | Personne ne tient ce rôle |
| **Sans connexion** | Quelqu'un est désigné, mais son compte n'est pas renseigné : il ne sera pas reconnu à l'écran |
| **Cumul à signaler** | La même personne tient l'associé et le chef de mission, ce qui affaiblit la séparation des fonctions |

Vous désignez quelqu'un, ou vous répartissez autrement.

### La charge de travail

Par dossier, vous voyez les questions sans réponse, les pièces attendues et celles qui manquent, et
les cycles restant à valider. C'est ce qui vous dit s'il faut prévoir des jours ou redistribuer.

### La qualité

Vous voyez ce qui est soumis au visa, ce qui est approuvé, et par qui. Reste à décider si un travail
doit être revu avant d'être visé.

---

## La séparation des fonctions, et pourquoi elle tient

L'approbation d'un visa est refusée à la personne qui l'a soumis.

Ce refus ne vient pas de l'écran mais de la base de données, et la nuance compte : quelqu'un qui
appellerait la fonction directement, sans passer par l'écran, se verrait opposer exactement le même
refus. Un bouton grisé, lui, ne protège de rien. Il vous évite un clic inutile, rien de plus.

---

## Ce que l'écran ne fait pas

Trois limites, autant les connaître avant d'ouvrir.

Il ne calcule pas la charge en heures, parce qu'aucune saisie de temps ne l'alimente. Il n'envoie
aucun courriel : rien ne vient vous chercher, c'est vous qui ouvrez l'écran. Et il n'atteste pas la
conformité à la norme ; il en garde la trace, l'appréciation reste au professionnel.

---

Suite : [3. Ce que voit le client](03-ce-que-voit-le-client.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
