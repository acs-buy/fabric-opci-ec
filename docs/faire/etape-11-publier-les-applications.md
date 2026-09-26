# Étape 11. Publier les deux écrans, à deux publics distincts

Vos collaborateurs entrent dans la solution par une application organisationnelle. Ils y ouvrent
l'écran de travail sans voir l'espace de travail ni ses éléments techniques.

## Pourquoi passer par une application

Vos collaborateurs ne voient que ce qui les concerne : ni la base, ni les fonctions, ni le modèle ne
leur sont accessibles. Vous décidez ensuite qui voit quoi, audience par audience, et c'est ce qui
vous permet de séparer l'écran du cabinet de l'écran remis au client. Enfin, l'adresse que vous avez
diffusée ne change pas quand vous republiez le rapport : le lien envoyé à un client il y a six mois
fonctionne toujours.

## Créer l'application

Le bouton **Create app** se trouve dans le bandeau de l'espace de travail.

![Le bandeau de l'espace, avec Create app](../../captures/espace-bandeau.png)


1. Dans votre espace de travail, cliquez sur **Créer une application**.
2. Donnez-lui un nom, par exemple le nom de votre cabinet suivi de « conduite de mission ».
3. Ajoutez le rapport **Conduite de mission** au contenu.
4. Créez une seconde audience pour **restitution_client**, si vous voulez donner un écran à vos
   clients.
5. Dans **Autorisations**, donnez l'accès aux personnes ou aux groupes concernés.
6. **Publier**.

## Ce que l'application ne fait pas

Elle ne dispense pas des licences. Sur une capacité inférieure à F64, chaque personne qui ouvre
l'application a besoin d'une licence Power BI Pro, qu'elle passe par l'application ou par l'espace
de travail.

Les autorisations sur la base restent nécessaires, elles aussi. Les boutons qui écrivent passent par
les fonctions, et les fonctions vérifient le rôle de la personne dans la table des rôles de mission.
Quelqu'un qui n'a aucun rôle sur un dossier verra l'écran et se verra refuser l'écriture, avec un
message qui le lui dit.

## Vérifier

Demandez à un collègue d'ouvrir l'application. Il doit voir l'écran de conduite de mission et
pouvoir sélectionner un dossier. S'il ne voit rien, regardez son autorisation, puis sa licence.

### Ce que vous devez obtenir

## Avant l'application : créer un rôle de sécurité par client

Ne sautez pas cette étape. Le dépôt livré arrive avec un seul rôle, celui du véhicule de
démonstration : tant que vous n'avez pas créé un rôle par client réel, un client qui ouvre sa
restitution voit les données de tous les autres.

### Le chemin exact

1. Dans votre espace de travail, **survolez** le modèle sémantique `restitution_client`.
2. Cliquez sur le menu **More options**, les trois points qui apparaissent au survol.
3. Choisissez **Security**.
4. La page de sécurité au niveau des lignes s'ouvre, avec la liste des rôles.
5. Pour chaque rôle, cliquez sur **Assign** et ajoutez les comptes ou les groupes concernés.

Si l'option **Security** n'apparaît pas, c'est que vous n'avez pas le rôle de contributeur sur
l'espace de travail. C'est le minimum exigé pour y accéder.

### Créer un rôle qui n'existe pas encore

La page **Security** assigne des membres à des rôles existants ; elle n'en crée pas. L'éditeur le
dit : on ne peut gérer la sécurité que sur un modèle dont les rôles sont déjà définis.

Pour créer le rôle d'un nouveau client, vous avez deux voies. La plus simple consiste à modifier le
modèle directement dans le service : vous l'ouvrez, vous allez dans l'onglet de modélisation, vous
définissez le rôle et son filtre. L'autre passe par Power BI Desktop : vous téléchargez le modèle,
vous y définissez le rôle, vous republiez. C'est plus lourd.

Le filtre à écrire reprend celui du rôle livré : il restreint la table des entités au code du
véhicule du client.

### Là où le cloisonnement peut céder

La sécurité au niveau des lignes ne s'applique qu'aux lecteurs. L'éditeur l'écrit : elle ne
s'applique ni aux administrateurs, ni aux membres, ni aux contributeurs de l'espace de travail. Un
client que vous ajouteriez comme membre de votre espace verrait donc tout, rôle ou pas. Ne le faites
jamais. Donnez-lui accès par l'application, avec le rôle de lecteur, et par son audience : c'est la
seule configuration dans laquelle il ne voit que ses propres données.

### Vérifier

Sur la page **Security**, chaque rôle a un menu **More options** qui contient **Test as role**. Il
ouvre le rapport tel que ce rôle le voit.

Ce test ne fonctionne pas sur un modèle en connexion directe avec authentification unique. Dans ce
cas, connectez-vous réellement avec un compte de test placé dans le rôle de lecteur.

---


![L'application et ses deux audiences](../../captures/application-audiences.png)

*Capture de l'installation réelle. Le volet de gauche affiche les deux audiences : la conduite de
mission pour votre équipe, la restitution client pour vos clients.*

![Le volet des deux audiences](../../captures/application-volet.png)

*Une personne de l'audience client ne voit que la seconde, et les huit pages qu'elle contient.*


Profitez-en pour préparer la recette : une des douze actions demande deux comptes distincts, parce
qu'un visa ne peut pas être approuvé par la personne qui l'a soumis.

---

Suite : [Étape 12. La recette : douze actions qui prouvent que la solution marche](etape-12-passer-la-recette.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
