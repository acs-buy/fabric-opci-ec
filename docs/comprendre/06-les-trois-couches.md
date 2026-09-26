# 6. Les trois couches d'une reproduction

Après l'étape 6, tous les éléments de la solution seront dans votre espace de travail et pas un seul
écran ne s'affichera. L'installation n'a pas échoué. Il reste deux couches à installer.

---

## Une solution Fabric ne se reproduit pas en une seule opération

Elle se reproduit en trois couches. Les confondre est la première cause d'échec d'une reprise : on
s'arrête juste après la synchronisation, en croyant que le dépôt est cassé, alors que les deux
autres couches n'ont simplement pas encore été installées.

| La couche | Ce qu'elle contient | Comment elle arrive | Étapes |
|---|---|---|---|
| **A. Les définitions** | La forme des éléments : tables, vues, procédures, code des fonctions, mesures, visuels | La synchronisation Git | 5 et 6 |
| **B. Les données** | Référentiels et jeu de démonstration | Des scripts SQL que vous jouez | 7 |
| **C. Les liaisons** | Ce qui désigne un élément par son identifiant | Des scripts, et des actions au portail | 8, 9 et 10 |

---

## Couche A. Les définitions arrivent par Git

C'est la partie facile. C'est aussi celle qui donne l'impression que tout est fait.

La synchronisation recrée les huit éléments de la solution dans votre espace de travail : le coffre,
la base avec ses tables, ses vues et ses procédures, les deux ensembles de fonctions, les deux
modèles de données et les deux rapports.

Vous en compterez dix. La plateforme ajoute d'elle-même un point de terminaison SQL au coffre et un
à la base. Ils ne sont pas dans le dépôt, vous n'avez rien à en faire, et leur présence est normale.

À ce stade, tous les éléments existent et aucun ne rend encore service. Il manque les données et les
liaisons.

---

## Couche B. Les données n'arrivent jamais par Git

L'éditeur l'écrit sans ambiguïté :

> « Git Integration re-creates item definitions only and does not restore item data. »

Votre base arrive donc avec ses tables, ses vues et ses procédures, et pas une seule ligne dedans.

C'est pour cela que le dépôt contient 80 fichiers SQL, dont 77 de données. C'est par eux, et par eux
seuls, que les données entrent dans votre base.

| Ce que le dépôt charge | Lignes | Ce que vous en faites |
|---|---|---|
| Le socle de référentiel | 3 452 | Vous le gardez. Questions d'acceptation, plan de comptes, articles du règlement |
| Le jeu de démonstration | 7 152 | Vous pourrez l'effacer quand vous passerez à vos dossiers |

Tant que ces fichiers ne sont pas joués, vos écrans restent vides, et rien à l'écran ne vous indique
que la cause est l'absence de données.

---

## Couche C. Les liaisons ne se recollent pas toutes seules

Personne ne l'anticipe, et c'est elle qui décide si la solution fonctionne chez vous.

### D'où vient le problème

Certains éléments en désignent d'autres par leur identifiant, et cet identifiant est celui de
l'espace de travail où la solution a été construite. Pas le vôtre.

### Les deux liaisons à refaire

| Ce qui ne se recolle pas | Combien | Sans réparation |
|---|---|---|
| Les sources des deux modèles vers la base | 73 | Le modèle ne s'actualise pas, aucun écran ne s'affiche |
| Les boutons vers les ensembles de fonctions | 36 | Les boutons ne font rien, ou écrivent au mauvais endroit |

L'éditeur documente ces deux points. Ils tiennent au fonctionnement de la plateforme, et non à la
façon dont la solution a été construite.

Pour le modèle, le tableau de la liaison des dépendances entre espaces de travail indique, à la
ligne « Semantic models vers SQL database » : **« No. The connection string in TMDL expressions
contains workspace-specific values. »**

Pour les boutons : **« Data function buttons don't automatically rebind across workspaces. The
button stores an explicit reference to a specific Workspace, Function set, and Data function. »**

### Pourquoi c'est difficile à diagnostiquer

Un bouton mal relié ne proteste pas. Vous cliquez, il ne se passe rien, aucun message, aucune erreur
rouge. C'est le symptôme le plus déroutant de toute l'installation, et c'est pour cela que le dépôt
fournit un script qui le vérifie en une commande.

### Ce que le dépôt fait pour vous

Deux scripts réparent ces liaisons. Ils remplacent le texte des identifiants dans les fichiers sans
reformater le reste, afin que vous puissiez relire exactement ce qui a changé.

Ils refusent d'écrire si un fichier contient des identifiants qu'ils ne reconnaissent pas : c'est le
signe d'une modification à la main, et une écriture aveugle la casserait.

L'ordre compte : le modèle d'abord, les boutons ensuite.

### Ce qui se règle à la main, au portail

Trois choses ne voyagent pas dans les fichiers.

La connexion des fonctions à la base se fait au portail, en deux actions par ensemble de fonctions,
à l'étape 8. Les informations d'identification des modèles se saisissent une fois par modèle, en
OAuth2, aux étapes 9 et 10. Enfin, le modèle du client demande une actualisation, parce qu'il garde
une copie des données contrairement à l'autre ; c'est également aux étapes 9 et 10.

Aucune des trois ne produit de message d'erreur quand elle manque. Vous obtenez un écran vide, et
c'est le symptôme le plus trompeur de toute l'installation.

---

## Ce qui se recolle tout seul, et à quelle condition

Le rapport retrouve son modèle de données tout seul, parce qu'il le désigne par un chemin relatif et
non par un identifiant. L'éditeur donne cette liaison pour « partielle » : elle se résout si le
modèle est déployé au même emplacement relatif.

À une condition : ne renommez aucun élément. Un renommage casse cette liaison, et le message
d'erreur que vous obtiendrez ne parlera pas de renommage.

---

## Récapitulatif : ce qui manque à chaque étape

| Après l'étape | Ce qui marche | Ce qui ne marche pas encore |
|---|---|---|
| 6 | Les éléments existent | Tout le reste |
| 7 | La base est remplie | Les écrans, les boutons |
| 8 | Les fonctions joignent la base | Les écrans, les boutons |
| 9 | Les écrans s'affichent | Les boutons |
| 10 | Tout | |

---

Suite : [7. Ce que vous garantit le fait de tout garder dans Fabric](07-l-environnement-integre.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
