# Étape 2. Faire activer les cinq réglages du locataire

**Durée estimée :** 15 minutes, dont l'essentiel est le temps de joindre votre administrateur.
**Qui :** votre administrateur Microsoft Fabric.

---

## Ce que vous allez faire

Transmettre à votre administrateur une liste de cinq réglages, et vérifier qu'ils sont activés.

## Pourquoi

Ces réglages ouvrent des fonctions que votre locataire ferme par défaut. Deux d'entre eux sont la
cause d'échecs qui n'annoncent pas leur cause :

- **sans le quatrième**, GitHub n'apparaît pas dans la liste des fournisseurs Git, et vous
  chercherez longtemps pourquoi ;
- **sans le cinquième**, vous verrez un classeur exporté dans le coffre sans pouvoir le télécharger,
  sans message clair.

---

## La liste à transmettre

Copiez le texte ci-dessous et envoyez-le à votre administrateur.

> Bonjour,
>
> Pour installer une solution Microsoft Fabric, j'ai besoin que cinq réglages de locataire soient
> activés dans le portail d'administration. Ils se trouvent dans **Paramètres du locataire**.
>
> 1. **Les utilisateurs peuvent créer des éléments Fabric**
> 2. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec leurs dépôts
>    Git**
> 3. **Créer des espaces de travail**
> 4. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec des dépôts
>    GitHub**
> 5. Section **OneLake** : **Les utilisateurs peuvent accéder aux données stockées dans OneLake avec
>    des applications externes à Fabric**
>
> Le quatrième est distinct du deuxième : le deuxième autorise Git en général, le quatrième autorise
> GitHub en particulier. Il faut les deux.
>
> Chacun peut être limité à un groupe de sécurité si vous le préférez. Merci de m'indiquer quand
> c'est fait.

---

## Ce que chaque réglage ouvre

| # | Le réglage | Ce qu'il permet | Sans lui |
|---|---|---|---|
| 1 | Créer des éléments Fabric | Créer la base, le coffre, les fonctions | Rien ne s'installe |
| 2 | Synchroniser avec Git | Connecter un dépôt à l'espace de travail | Pas d'intégration Git du tout |
| 3 | Créer des espaces de travail | L'étape 3 | Il faut qu'un administrateur le crée pour vous |
| 4 | Synchroniser avec GitHub | Voir GitHub dans la liste des fournisseurs | GitHub n'apparaît pas |
| 5 | Accès externe à OneLake | Télécharger un fichier du coffre, et l'Explorateur OneLake | Vous voyez les fichiers sans pouvoir les récupérer |

---

## Où ils se trouvent, si vous êtes vous-même administrateur

1. Dans Fabric, cliquez sur l'**icône d'engrenage**, en haut à droite.
2. Choisissez **Portail d'administration**.
3. Choisissez **Paramètres du locataire**.
4. Utilisez la zone de recherche pour retrouver chaque réglage par son libellé.
5. Dépliez-le, basculez-le sur **Activé**, puis **Appliquer**.

Le cinquième se trouve dans la section **Paramètres OneLake** de la même page.

---

## Un mot sur les groupes de sécurité

Chaque réglage peut être limité à un groupe plutôt qu'ouvert à toute l'organisation. C'est ce que
font la plupart des administrateurs, et c'est légitime.

**Si votre administrateur choisit cette voie, demandez à figurer dans le groupe**, et vérifiez-le
avant de passer à l'étape suivante. Un réglage activé pour un groupe dont vous ne faites pas partie
produit exactement les mêmes symptômes qu'un réglage désactivé.

---

## Vérifier que c'est fait

Les cinq doivent afficher **Activé** dans le portail d'administration.

**Un délai existe.** Un réglage vient d'être activé ne prend pas toujours effet immédiatement. Si
vous ne voyez pas le résultat attendu à l'étape 5, attendez quelques minutes et rafraîchissez la
page avant de conclure à un problème.

---

## Si votre administrateur refuse

Le plus souvent, c'est le deuxième ou le quatrième qui bloque, par crainte que du code du cabinet
parte vers un dépôt externe.

Deux arguments factuels à lui donner :

1. **La synchronisation ne transporte jamais de données**, seulement des définitions d'éléments.
   L'éditeur l'écrit : « Git Integration re-creates item definitions only and does not restore item
   data. »
2. **Le dépôt peut être privé.** Rien n'oblige à publier votre copie.

Si le refus persiste, l'installation n'est pas possible par Git. Une voie de remplacement existe par
l'interface de programmation, mais elle sort du cadre de ce mode opératoire.

---

Suite : [Étape 3. Créer l'espace de travail](etape-03-creer-l-espace.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
