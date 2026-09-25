# 3. Connecter votre espace de travail au dépôt

Cette étape établit le lien qui apportera les éléments de la solution dans votre espace de travail.

## D'abord, faire votre propre copie du dépôt

Sur la page GitHub de ce dépôt, cliquez sur **Fork**, en haut à droite. Vous obtenez une copie sous
votre propre compte, que vous pourrez modifier librement.

**Pourquoi une copie et non le dépôt d'origine :** l'installation vous fera modifier deux fichiers
de configuration, et vous ne pouvez écrire que dans un dépôt qui vous appartient.

Téléchargez ensuite cette copie sur votre poste, par **Code** puis **Download ZIP**, ou bien par
`git clone` si vous connaissez.

## Créer un jeton d'accès GitHub

Fabric a besoin d'un jeton pour lire votre dépôt.

1. Sur GitHub, cliquez sur votre photo, puis **Settings**.
2. Tout en bas à gauche, **Developer settings**.
3. **Personal access tokens**, puis **Tokens (classic)**, puis **Generate new token (classic)**.
4. Donnez-lui un nom, une durée de validité, et cochez la portée **repo**.
5. Copiez le jeton. GitHub ne vous le remontrera plus.

**Ce jeton est un mot de passe.** Ne le collez nulle part ailleurs que dans l'écran de connexion de
Fabric, et ne l'écrivez dans aucun fichier.

## Connecter

1. Dans votre espace de travail, ouvrez **Paramètres de l'espace de travail**.
2. Choisissez **Intégration Git**.
3. Fournisseur : **GitHub**.
4. Renseignez votre nom d'utilisateur GitHub, le nom du dépôt, et la branche.
5. **Répertoire : `fabric`**

Le répertoire est le point qui se rate le plus souvent. Ce dépôt contient aussi des scripts, de la
documentation et des fichiers SQL, qui n'ont rien à faire dans votre espace de travail. Seul le
dossier `fabric` porte les éléments Fabric. Si vous laissez le répertoire vide, Fabric essaiera
d'interpréter tout le dépôt et la synchronisation échouera.

6. Collez le jeton quand il vous est demandé.

## Vérifier

L'écran d'intégration Git affiche l'état de la connexion et la branche connectée. Le panneau de
contrôle de source apparaît dans le bandeau de l'espace de travail.

## Si GitHub n'apparaît pas dans la liste des fournisseurs

C'est le quatrième réglage de locataire qui manque, celui qui autorise la synchronisation avec des
dépôts **GitHub** en particulier. Il est distinct de celui qui autorise Git en général. Reportez-vous
à la page [1. Ce qu'il vous faut](01-prerequis.md).

## Une remarque sur le partage

La connexion Git est propre à chaque personne. Si un collègue travaille dans le même espace de
travail et veut aussi synchroniser, il configure sa propre connexion avec son propre jeton. Ne
partagez pas le vôtre.

Suite : [4. Après la synchronisation](04-apres-la-synchro.md)
