# 6. Les trois couches d'une reproduction

Cette page explique pourquoi l'installation ne se fait pas d'un seul coup, et pourquoi rien ne
fonctionne après l'étape 6.

À lire avant d'aborder l'étape 6.

---

## Une solution Fabric ne se reproduit pas en une seule opération

Elle se reproduit en trois couches. Les confondre mène à croire que l'installation a échoué juste
après la synchronisation, alors qu'elle n'est pas terminée.

| La couche | Ce qu'elle contient | Comment elle arrive | Étapes |
|---|---|---|---|
| **A. Les définitions** | La forme des éléments : tables, vues, procédures, code des fonctions, mesures, visuels | La synchronisation Git | 5 et 6 |
| **B. Les données** | Référentiels et jeu de démonstration | Des scripts SQL que vous jouez | 7 |
| **C. Les liaisons** | Ce qui désigne un élément par son identifiant | Des scripts, et des actions au portail | 8, 9 et 10 |

---

## Couche A. Les définitions arrivent par Git

C'est la partie la plus simple, et celle qui donne l'impression que tout est fait.

La synchronisation recrée les huit éléments de la solution dans votre espace de travail : le coffre,
la base avec ses tables, ses vues et ses procédures, les deux ensembles de fonctions, les deux
modèles de données et les deux rapports.

**Vous en compterez dix.** La plateforme ajoute d'elle-même un point de terminaison SQL au coffre et
un à la base. Ils ne sont pas dans le dépôt, vous n'avez rien à en faire, et leur présence est
normale.

Tout y est, et rien ne fonctionne. Les deux couches suivantes expliquent pourquoi.

---

## Couche B. Les données n'arrivent jamais par Git

L'éditeur l'écrit sans ambiguïté :

> « Git Integration re-creates item definitions only and does not restore item data. »

**La synchronisation recrée la forme, jamais le contenu.** Votre base a ses tables, ses vues et ses
procédures, et pas une seule ligne dedans.

Le dépôt porte pour cette raison 80 fichiers SQL, dont 77 de données. C'est la seule façon de
faire arriver le contenu dans votre base.

| Ce que le dépôt charge | Lignes | Ce que vous en faites |
|---|---|---|
| Le socle de référentiel | 3 452 | Vous le gardez. Questions d'acceptation, plan de comptes, articles du règlement |
| Le jeu de démonstration | 7 152 | Vous pourrez l'effacer quand vous passerez à vos dossiers |

Sans la couche B, vos écrans sont vides, et l'affichage n'y est pour rien.

---

## Couche C. Les liaisons ne se recollent pas toutes seules

C'est la couche qui décide si la solution fonctionne, et celle qu'on oublie.

### Le problème, en une phrase

Certains éléments en désignent d'autres **par leur identifiant**, et cet identifiant est celui de
l'espace de travail où la solution a été construite. Pas le vôtre.

### Les deux liaisons à refaire

| Ce qui ne se recolle pas | Combien | Sans réparation |
|---|---|---|
| Les sources des deux modèles vers la base | 73 | Le modèle ne s'actualise pas, aucun écran ne s'affiche |
| Les boutons vers les ensembles de fonctions | 36 | Les boutons ne font rien, ou écrivent au mauvais endroit |

Ces deux points sont documentés par l'éditeur de la plateforme.

Pour le modèle, le tableau de la liaison des dépendances entre espaces de travail porte, à la ligne
« Semantic models vers SQL database » : **« No. The connection string in TMDL expressions contains
workspace-specific values. »**

Pour les boutons : **« Data function buttons don't automatically rebind across workspaces. The
button stores an explicit reference to a specific Workspace, Function set, and Data function. »**

### Pourquoi c'est difficile à diagnostiquer

Un bouton mal relié ne dit rien et ne fait rien : aucun message, aucune erreur. Le dépôt fournit
donc un script qui le vérifie en une commande.

### Ce que le dépôt fait pour vous

Deux scripts réparent ces liaisons. Ils remplacent le texte des identifiants dans les fichiers,
sans reformater le reste, pour que vous puissiez relire ce qui a changé.

Ils refusent d'écrire si un fichier porte des identifiants qu'ils ne reconnaissent pas : c'est le
signe d'une modification à la main, et une écriture aveugle le casserait.

**L'ordre compte :** le modèle d'abord, les boutons ensuite.

### Les liaisons qui se posent à la main

Trois choses ne voyagent pas dans les fichiers et se posent au portail.

| Ce qui se pose à la main | Où | Quand |
|---|---|---|
| La connexion des fonctions à la base | Deux actions par ensemble de fonctions | Étape 8 |
| Les informations d'identification des modèles | Une fois par modèle, en OAuth2 | Étapes 9 et 10 |
| L'actualisation du modèle du client | Il garde une copie des données, contrairement à l'autre | Étapes 9 et 10 |

**Aucune des trois ne produit de message d'erreur.** Elles produisent un écran vide, ce qui est le
symptôme le plus opaque de l'installation.

---

## Ce qui se refait seul, et à quelle condition

Une liaison se refait seule, sous une condition.

**Le rapport retrouve son modèle de données tout seul**, parce qu'il le désigne par un chemin
relatif et non par un identifiant. L'éditeur donne cette liaison pour « partielle » : elle se
résout si le modèle est déployé au même emplacement relatif.

**La condition :** ne renommez aucun élément. Un renommage casse cette liaison, et le message
d'erreur ne désigne pas le renommage.

---

## Récapitulatif : ce qui manque à chaque étape

| Après l'étape | Ce qui marche | Ce qui ne marche pas encore |
|---|---|---|
| 6 | Les éléments existent | Tout le reste |
| 7 | La base est remplie | Les écrans, les boutons |
| 8 | Les fonctions joignent la base | Les écrans, les boutons |
| 9 | Les écrans s'affichent | Les boutons |
| 10 | **Tout** | |

---

Suite : [7. Ce que vous garantit le fait de tout garder dans Fabric](07-l-environnement-integre.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
