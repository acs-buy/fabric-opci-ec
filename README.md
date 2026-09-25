# Conduite de mission OPCI : reproduire la solution dans votre espace de travail

Ce dépôt contient une solution complète de conduite de mission pour les organismes de placement
collectif immobilier, construite sur Microsoft Fabric et Power BI. Il est écrit pour que vous
puissiez la reproduire entièrement chez vous, à partir de rien.

**Ce mode opératoire s'adresse à un expert-comptable, pas à un informaticien.** Chaque action a faire y est
écrit en toutes lettres. Vous n'avez besoin d'aucune connaissance en programmation pour les étapes
1 à 6, 11 et 12.

**Quatre étapes relèvent du métier d'analyste de données : les étapes 7 à 10.** Elles consistent à
charger des données et à rebrancher la solution sur votre propre espace de travail. Ce dépôt les
outille par des scripts qui font le travail à votre place, et elles restent faisables seul. Si vous
préférez vous faire accompagner, un analyste certifié Power BI et Fabric les traite en environ deux
heures. Vous n'avez pas besoin de l'engager pour la journée entière : les autres étapes ne le
justifient pas.

---

## Ce que la solution fait

Elle porte le dossier d'un client OPCI de bout en bout, dans un seul écran de travail :

- créer le dossier d'un client, qui ouvre aussitôt son questionnaire d'acceptation de mission ;
- lister les filiales du véhicule, en ajouter, en modifier, en supprimer ;
- répondre aux questions d'acceptation, déposer les pièces justificatives, les tracer ;
- soumettre le dossier au visa, et le faire approuver par une autre personne que son auteur ;
- ouvrir les arrêtés de l'exercice et désigner l'équipe de la mission.

Chaque bouton écrit réellement en base de données. Ce n'est pas une maquette.

Un second écran, destiné au client, restitue ce qui le concerne.

---

## Avant de commencer : ce dont vous avez besoin

### La capacité

La solution demande une **capacité Fabric F4** au minimum.

**Vous pouvez tout reproduire gratuitement.** L'essai gratuit de Microsoft Fabric dure **60 jours**
et ouvre une capacité **F4 ou F64** selon votre éligibilité, avec 1 To de stockage. Il comprend
aussi une licence Power BI individuelle équivalente à Premium par utilisateur si vous n'en avez
pas. C'est exactement ce qu'il faut.

Cette exigence de F4 a été établie par la mesure : en F2, la création d'une surface de saisie
échoue. Cette mesure portait sur un composant que la présente solution ne contient plus. Il est donc
possible que F2 suffise, mais cela n'a pas été éprouvé sur ce périmètre. Nous annonçons F4.

### Les licences des personnes

| Qui | Ce qu'il lui faut |
|---|---|
| Vous, qui installez | Power BI Pro ou Premium par utilisateur. L'essai Fabric en fournit l'équivalent. |
| Vos collaborateurs, sur une capacité F4 à F32 | Power BI Pro ou Premium par utilisateur, chacun |
| Vos collaborateurs, sur une capacité F64 ou plus | Une licence gratuite suffit, avec le rôle de lecteur |

**Le point de coût, dit franchement :** passé l'essai, une capacité F4 ne rend pas l'écran gratuit
pour votre équipe. Tant que la capacité reste sous F64, chaque personne qui ouvre l'écran a besoin
d'une licence Pro. Pour le prix courant d'une capacité, consultez le calculateur de tarifs
Microsoft Azure : les tarifs varient par région et changent, et un chiffre inscrit ici serait faux
avant que vous le lisiez.

### Les autorisations à ouvrir

Votre administrateur Microsoft Fabric doit activer **quatre réglages** dans le portail
d'administration, section Paramètres du locataire :

1. **Les utilisateurs peuvent créer des éléments Fabric**
2. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec leurs dépôts Git**
3. **Créer des espaces de travail**
4. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec des dépôts GitHub**

Le quatrième est distinct du deuxième, et c'est celui qu'on oublie. Sans lui, GitHub n'apparaîtra
pas dans la liste des fournisseurs et vous chercherez longtemps pourquoi.

Vous devez par ailleurs être **administrateur de l'espace de travail** que vous allez créer.

### Sur votre poste

- Un navigateur.
- **Python 3**, pour les trois scripts de ce dépôt. Rien d'autre à installer : ils n'utilisent
  aucune bibliothèque extérieure.
- Un compte **GitHub**, gratuit.

---

## La reproduction, étape par étape

Suivez les étapes dans l'ordre. Chacune se termine par une vérification : ne passez à la suivante
que lorsqu'elle est passée.

### Étape 1. Ouvrir une capacité Fabric

Connectez-vous à `app.fabric.microsoft.com`. Cliquez sur votre photo en haut à droite, puis sur
**Démarrer l'essai**. Acceptez les conditions, choisissez votre région, validez.

*Vérification :* votre gestionnaire de compte affiche désormais un état d'essai.

Si le bouton n'apparaît pas, votre administrateur a désactivé les essais. Demandez-lui soit de les
autoriser, soit de vous affecter une capacité existante.

### Étape 2. Faire activer les quatre réglages

Transmettez à votre administrateur la liste des quatre réglages ci-dessus.

*Vérification :* les quatre sont sur « Activé » dans le portail d'administration.

### Étape 3. Créer l'espace de travail

Dans le menu de gauche, **Espaces de travail**, puis **Nouvel espace de travail**. Donnez-lui un
nom. Dépliez **Avancé** et affectez-le à votre capacité d'essai.

*Vérification :* les paramètres de l'espace de travail indiquent la capacité, et non « Pro ».

**Ne renommez aucun élément par la suite.** Le rapport retrouve son modèle de données par son nom.
Un renommage casse cette liaison de façon peu lisible.

### Étape 4. Copier ce dépôt sur votre compte GitHub

En haut de cette page, cliquez sur **Fork**. Cela crée votre propre copie, que vous pourrez
modifier sans affecter l'original.

*Vérification :* le dépôt apparaît sous votre nom d'utilisateur GitHub.

Téléchargez ensuite cette copie sur votre poste, par **Code**, puis **Download ZIP**, ou par
`git clone` si vous connaissez.

### Étape 5. Connecter l'espace de travail à votre dépôt

Dans votre espace de travail, **Paramètres de l'espace de travail**, puis **Intégration Git**.

- Fournisseur : **GitHub**
- Renseignez votre nom d'utilisateur, votre dépôt, la branche
- **Répertoire : `fabric`** — ce point est important. Ce dépôt contient aussi des scripts et de la
  documentation, qui n'ont rien à faire dans votre espace de travail. Seul le dossier `fabric`
  contient les éléments Fabric.

GitHub demandera un jeton d'accès personnel. Créez-le depuis votre compte GitHub, dans
**Settings**, **Developer settings**, **Personal access tokens**, avec le droit sur les dépôts.

*Vérification :* l'écran d'intégration Git affiche l'état de la connexion.

### Étape 6. Ramener les éléments dans votre espace de travail

Toujours dans l'écran d'intégration Git, cliquez sur **Mettre à jour tout**.

*Vérification :* huit éléments apparaissent dans votre espace de travail. Le lakehouse, la base, les
deux ensembles de fonctions, les deux modèles sémantiques et les deux rapports.

L'application organisationnelle ne vient pas par Git : vous la créerez à l'étape 11. Sa
représentation dans Git est en préversion, et nous préférons une action que vous maîtrisez à une
préversion qui peut changer.

**À ce stade, rien ne marche encore, et c'est normal.** La synchronisation Git recrée la *forme* des
éléments, jamais leur contenu ni leurs branchements. L'éditeur l'écrit ainsi : « Git Integration
re-creates item definitions only and does not restore item data ». Les étapes 7 à 10 posent le
contenu et les branchements.

### Étape 7. Charger les données

Votre base a ses tables, ses vues et ses procédures, mais aucune donnée. Les scripts du dossier
`sql/` la remplissent, dans cet ordre :

1. `sql/10_referentiels/` : le socle, soit 3 452 lignes. Questions d'acceptation, plan de comptes,
   articles du règlement, natures de pièces, rôles. C'est ce que vous gardez.
2. `sql/80_demonstration/` : 7 293 lignes. Deux véhicules fictifs, leurs filiales, leurs arrêtés et
   leurs écritures. C'est ce que vous pourrez effacer.

Vous pouvez les jouer depuis l'éditeur de requêtes de la base, dans Fabric : ouvrez la base,
onglet **Nouvelle requête**, collez le contenu d'un fichier, exécutez. Faites-les dans l'ordre des
numéros.

Le jeu de démonstration s'efface par `sql/89_effacer_la_demonstration.sql` quand vous passerez à vos
vrais dossiers. Lisez son en-tête avant : il vaut mieux le jouer avant vos premières saisies
qu'après, et il explique pourquoi.

*Vérification :* `python scripts/30_recette.py --donnees` compte les lignes et vous dit ce qui manque.

### Étape 8. Ouvrir la connexion des fonctions à la base

Les fonctions doivent avoir le droit de parler à la base, et ce droit ne se transporte pas par Git.

Ouvrez `fn_ecran_client`. Dans le bandeau, **Gérer les connexions**, puis **Ajouter une connexion
de données**. Choisissez votre base `DossierOPCI`. Faites de même pour `fn_ecran_revision`.

Publiez ensuite chaque ensemble de fonctions, par **Publier**.

**Deux points qui surprennent, et qui sont normaux :**
- La publication impose **deux minutes d'attente** entre deux publications successives. Si un
  message vous le signale, attendez et recommencez.
- **Seule la personne propriétaire d'un ensemble de fonctions peut le publier.** Si vous installez
  pour un cabinet, faites-le depuis le compte qui restera responsable de la solution.

*Vérification :* dans l'écran des fonctions, lancez `qui_suis_je` : elle doit rendre une réponse.

### Étape 9. Relier le modèle à votre base

Les tables du modèle interrogent encore la base d'origine. Il faut les faire pointer vers la vôtre.

Ouvrez un terminal dans le dossier du dépôt, et lancez :

```
python scripts/00_mes_identifiants.py
```

Le script vous demande de coller cinq valeurs et vous rend les deux commandes à lancer. Lancez la
première, celle du modèle :

```
python scripts/25_relier_le_modele.py --serveur <le vôtre> --base <la vôtre>
```

Le script réécrit les 72 tables et vous dit combien il en a traité. Envoyez ensuite la modification
à votre dépôt GitHub, puis, dans Fabric, **Mettre à jour tout** de nouveau.

*Vérification :* ouvrez le modèle dans votre espace de travail et actualisez-le. Aucune erreur.

### Étape 10. Relier les boutons à vos fonctions

Même principe, et c'est le point le plus important de toute l'installation.

Les 24 boutons qui écrivent en base portent, en clair, l'identifiant de l'espace de travail et
de l'ensemble de fonctions qu'ils appellent. Le rapport appelle deux ensembles de fonctions, un par
écran, et il faut donner les deux identifiants. L'éditeur l'écrit ainsi : « Data function buttons don't
automatically rebind across workspaces ». Sans cette étape, vos boutons appellent l'espace de
travail d'origine : soit ils ne font rien, soit ils écrivent au mauvais endroit.

Lancez la seconde commande rendue à l'étape 9 :

```
python scripts/20_relier_les_boutons.py --espace <le vôtre> --fn-ecran-client <le vôtre> --fn-ecran-revision <le vôtre>
```

Le script traite les 24 boutons et vous dit combien il en a relié. Envoyez la modification à GitHub,
puis **Mettre à jour tout** dans Fabric.

*Vérification :* `python scripts/20_relier_les_boutons.py --verifier` affiche 24 boutons reliés et
zéro restant.

### Étape 11. Publier l'application

Dans votre espace de travail, ouvrez l'application organisationnelle et publiez-la. Donnez l'accès
aux personnes concernées.

*Vérification :* un collègue ouvre l'application et voit l'écran.

### Étape 12. Passer la recette

```
python scripts/30_recette.py
```

La recette passe douze actions, du clic jusqu'à la base, et vous dit lesquelles aboutissent. Vous
pouvez aussi les faire à la main : le détail est dans `docs/08-recette.md`, avec pour chacun le
résultat attendu et la capture d'écran correspondante.

**Une action demande deux comptes** : l'approbation d'un visa est refusée à la personne qui a
soumis le dossier. C'est voulu, et c'est la séparation des fonctions. Prévoyez un second compte pour
l'éprouver.

---

## Si quelque chose ne marche pas

`docs/09-depannage.md` reprend les erreurs rencontrées pendant la mise au point, avec leur cause
réelle. Deux exemples du genre de piège qui fait perdre une demi-journée :

- un bouton qui ne fait rien n'est presque jamais un bouton cassé : c'est l'étape 10 non faite, ou
  la connexion de l'étape 8 non posée ;
- un écran vide n'est pas une panne d'affichage : c'est l'étape 7 non faite.

---

## Comprendre et modifier la solution

`docs/10-comprendre.md` explique comment la solution est construite : ce que fait la base, comment
un bouton appelle une fonction, comment une fonction appelle une procédure, et où se trouve le
libellé que voit l'utilisateur. Lisez-le avant de modifier quoi que ce soit.

Une règle vaut d'être retenue dès maintenant : **les libellés affichés dans les tableaux viennent
des vues SQL, pas du modèle.** Renommer une colonne dans le modèle casse les mesures qui la lisent.
Si vous voulez changer un intitulé, changez-le dans la vue.

---

## Licence

MIT. Voir le fichier [LICENSE](LICENSE). Vous pouvez reprendre, adapter et utiliser cette solution
en mission, y compris commercialement, en conservant la mention de licence.

## Origine

Cette solution accompagne un mémoire d'expertise comptable. Elle est publiée pour que des confrères
puissent la reprendre, l'éprouver et l'adapter à leurs propres dossiers.
