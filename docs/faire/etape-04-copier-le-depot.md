# Étape 4. Copier ce dépôt sur votre compte GitHub

**Durée estimée :** 10 minutes. **Qui :** vous.

---

## Ce que vous allez faire

Vous créez votre propre copie de ce dépôt sur GitHub, puis vous la téléchargez sur votre poste.

## Pourquoi une copie, et pas le dépôt d'origine

L'installation vous fera modifier des fichiers : les étapes 9 et 10 réécrivent des identifiants
dans les définitions, et on n'écrit que dans un dépôt dont on est propriétaire. Votre solution
finira d'ailleurs par s'écarter de la nôtre, puisque vous adapterez le questionnaire d'acceptation
à votre cabinet.

---

## Avant de commencer

- Un compte GitHub. La création est gratuite, sur `github.com`.
- Sous Windows, si vous passez par `git clone`, activez une fois pour toutes la prise en charge des
  chemins longs. Certains fichiers de la solution sont rangés très profond dans l'arborescence :

```
git config --global core.longpaths true
```

---

## Partie 1. Créer votre copie

1. Ouvrez la page de ce dépôt sur GitHub.
2. Cliquez sur **Fork**, en haut à droite.
3. Choisissez le compte de destination, le vôtre ou celui de votre organisation.
4. Laissez le nom tel quel, ou changez-le. Aucun script n'en dépend.
5. Décochez **« Copy the main branch only »** si vous voulez aussi les branches d'archive. Sinon
   laissez coché, la branche principale suffit.
6. Cliquez sur **Create fork**.

### Public ou privé ?

Une copie issue d'un dépôt public est publique elle aussi. Pour la passer en privé :

1. Ouvrez votre copie, puis **Settings**.
2. Tout en bas, section **Danger Zone**, **Change repository visibility**.
3. Choisissez **Make private**.

Rien ne vous oblige à laisser votre copie visible de tous. L'installation se déroule exactement de
la même façon sur un dépôt privé, et c'est en général ce que votre administrateur préférera.

---

## Partie 2. Télécharger la copie sur votre poste

Les étapes 9 et 10 lancent des scripts, qui ont besoin des fichiers en local.

### Voie A, la plus simple : télécharger une archive

1. Sur votre copie, cliquez sur le bouton vert **Code**.
2. Choisissez **Download ZIP**.
3. Décompressez l'archive dans un dossier de votre poste, par exemple `Documents\opci`.

En contrepartie, vous renverrez vos modifications à GitHub par le site web, fichier par fichier.
C'est faisable, mais c'est long quand on arrive aux étapes 9 et 10.

### Voie B, recommandée si vous connaissez : cloner

1. Sur votre copie, **Code**, puis copiez l'adresse HTTPS.
2. Dans un terminal :

```
git clone <l'adresse copiée>
```

Aux étapes 9 et 10, vous renverrez vos modifications en deux commandes.

---

## Vérifier que c'est fait

1. Le dépôt apparaît sous votre nom sur GitHub, avec la mention « forked from » sous le titre.
2. Le dossier existe sur votre poste, et contient `README.md`, `fabric`, `docs`, `scripts` et
   `sql`.
3. Python trouve les scripts. Ouvrez un terminal dans le dossier et lancez :

```
python scripts/30_recette.py --donnees
```

Cette commande doit afficher une requête SQL. Si elle répond « python n'est pas reconnu »,
installez Python 3 avant de continuer.

---

## Si le téléchargement échoue sur un nom de fichier trop long

C'est Windows, et cela se règle en une commande :

```
git config --global core.longpaths true
```

Puis reprenez le clonage. Si vous êtes passé par l'archive ZIP, décompressez dans un dossier au
chemin plus court, par exemple `C:\opci`.

---

## Ce qu'il y a dans le dépôt, pour vous repérer

| Le dossier | Ce qu'il contient | Va-t-il dans votre espace de travail ? |
|---|---|---|
| `fabric/` | Les huit éléments Fabric | Oui, c'est le répertoire à indiquer à l'étape 5 |
| `sql/` | Les 80 fichiers SQL, dont 77 de données | Non, vous les jouerez à l'étape 7 |
| `scripts/` | Les quatre scripts | Non, ils s'exécutent sur votre poste |
| `docs/` | Ce mode opératoire | Non |

Notez le nom `fabric` : c'est la valeur à saisir à l'étape suivante, et l'oublier fait échouer la
synchronisation.

---

Suite : [Étape 5. Connecter votre espace de travail au dépôt](etape-05-connecter-le-depot.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
