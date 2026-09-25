# 6. Les trois couches d'une reproduction

Cette page explique pourquoi l'installation ne se fait pas d'un seul coup, et pourquoi il est normal
que rien ne fonctionne après l'étape 6.

Lisez-la avant l'étape 6. Elle vous évitera de croire que l'installation a échoué.

---

## Une solution Fabric ne se reproduit pas en une seule opération

Elle se reproduit en trois couches. **Confondre ces couches est la première cause d'échec d'une
reprise**, et la raison pour laquelle beaucoup de gens abandonnent après la synchronisation.

| La couche | Ce qu'elle contient | Comment elle arrive | Étapes |
|---|---|---|---|
| **A. Les définitions** | La forme des éléments : tables, vues, procédures, code des fonctions, mesures, visuels | La synchronisation Git | 5 et 6 |
| **B. Les données** | Référentiels et jeu de démonstration | Des scripts SQL que vous jouez | 7 |
| **C. Les liaisons** | Ce qui désigne un élément par son identifiant | Des scripts, et des actions au portail | 8, 9 et 10 |

---

## Couche A. Les définitions arrivent par Git

C'est la partie facile, et c'est celle qui donne l'illusion que tout est fait.

La synchronisation recrée les huit éléments de la solution dans votre espace de travail : le coffre,
la base avec ses tables, ses vues et ses procédures, les deux ensembles de fonctions, les deux
modèles de données et les deux rapports.

**Tout y est, et rien ne marche.** C'est normal, et les deux couches suivantes expliquent pourquoi.

---

## Couche B. Les données n'arrivent jamais par Git

L'éditeur l'écrit sans ambiguïté :

> « Git Integration re-creates item definitions only and does not restore item data. »

**La synchronisation recrée la forme, jamais le contenu.** Votre base a ses tables, ses vues et ses
procédures, et pas une seule ligne dedans.

C'est pour cela que le dépôt porte 79 fichiers SQL. Ils ne sont pas un complément : ils sont la
seule façon de faire arriver les données.

| Ce que le dépôt charge | Lignes | Ce que vous en faites |
|---|---|---|
| Le socle de référentiel | 3 452 | Vous le gardez. Questions d'acceptation, plan de comptes, articles du règlement |
| Le jeu de démonstration | 7 293 | Vous pourrez l'effacer quand vous passerez à vos dossiers |

**Sans la couche B, vos écrans sont vides.** Ce n'est pas une panne d'affichage.

---

## Couche C. Les liaisons ne se recollent pas toutes seules

C'est la couche que personne n'anticipe, et celle qui décide si la solution fonctionne.

### Le problème, en une phrase

Certains éléments en désignent d'autres **par leur identifiant**, et cet identifiant est celui de
l'espace de travail où la solution a été construite. Pas le vôtre.

### Les deux liaisons à refaire

| Ce qui ne se recolle pas | Combien | Sans réparation |
|---|---|---|
| Les tables du modèle vers la base | 72 | Le modèle ne s'actualise pas, aucun écran ne s'affiche |
| Les boutons vers les ensembles de fonctions | 24 | Les boutons ne font rien, ou écrivent au mauvais endroit |

**Ces deux points sont documentés par l'éditeur**, et ce ne sont pas des défauts de notre solution.

Pour le modèle, le tableau de la liaison des dépendances entre espaces de travail porte, à la ligne
« Semantic models vers SQL database » : **« No. The connection string in TMDL expressions contains
workspace-specific values. »**

Pour les boutons : **« Data function buttons don't automatically rebind across workspaces. The
button stores an explicit reference to a specific Workspace, Function set, and Data function. »**

### Pourquoi c'est difficile à diagnostiquer

**Un bouton mal relié ne dit rien.** Il ne fait rien. Aucun message, aucune erreur rouge. C'est le
symptôme le plus déroutant de toute l'installation, et c'est pour cela que le dépôt fournit un
script qui le vérifie en une commande.

### Ce que le dépôt fait pour vous

Deux scripts réparent ces liaisons. Ils remplacent le texte des identifiants dans les fichiers, sans
reformater le reste, afin que vous puissiez relire exactement ce qui a changé.

Ils refusent d'écrire si un fichier porte des identifiants qu'ils ne reconnaissent pas : c'est le
signe d'une modification à la main, et une écriture aveugle le casserait.

**L'ordre compte :** le modèle d'abord, les boutons ensuite.

### La troisième liaison, qui se pose à la main

La connexion des fonctions à la base ne voyage pas non plus. Elle se pose au portail, en deux
actions par ensemble de fonctions. C'est l'étape 8.

---

## Ce qui se recolle tout seul, et à quelle condition

Une bonne nouvelle, avec sa condition.

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

Suite : [7. L'environnement intégré](07-l-environnement-integre.md)
