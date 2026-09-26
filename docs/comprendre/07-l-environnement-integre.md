# 7. Ce que vous garantit le fait de tout garder dans Fabric

La solution ne sort jamais de Microsoft Fabric. C'est un choix assumé, et il vous vaut quatre
garanties que vous n'auriez pas en assemblant des outils séparés. Il a aussi ses contreparties,
qui sont à la fin.

---

## 1. L'authentification, vous n'en écrivez pas une ligne

Il n'y a aucun mot de passe dans cette solution, parce qu'elle n'en gère aucun : pas de table
d'utilisateurs, pas de formulaire de connexion, pas de jeton à renouveler. Chaque personne se
connecte avec son compte professionnel Microsoft, la plateforme le reconnaît, et la solution
récupère son identité telle quelle.

Concrètement, vous ne créez pas de comptes : ce sont ceux de votre cabinet, déjà administrés. Vous
ne gérez ni les mots de passe ni leur renouvellement, votre administrateur le fait une fois pour
toutes vos applications. L'authentification à deux facteurs s'applique si votre cabinet l'a activée,
sans rien à régler ici. Et quand quelqu'un s'en va, désactiver son compte lui retire l'accès partout
à la fois, ici comme ailleurs.

L'identité connectée sert ensuite à filtrer ce que la personne voit et à vérifier ce qu'elle a le
droit d'écrire. Elle signe aussi ce qu'elle écrit : quand une réponse d'acceptation est enregistrée,
c'est son compte qui est inscrit, pas un nom saisi à la main.

---

## 2. La sécurité au niveau des lignes : chacun ne voit que le sien

Le filtre est posé dans le modèle de données, et non sur l'écran. La différence compte : quelqu'un
qui exporterait la donnée, ou qui l'interrogerait par un autre chemin, se verrait appliquer
exactement le même filtre.

### Pour le réviseur

Le modèle de conduite contient un rôle qui restreint chaque personne aux entités sur lesquelles
elle détient un mandat vivant :

```
le compte connecté  ->  ses mandats en cours  ->  les dossiers qu'il voit
```

Retirez un réviseur d'une mission, il cesse d'en voir le dossier. Personne n'a à toucher à ses
autorisations.

### Pour le client

Le modèle de restitution contient un rôle par client, qui filtre sur le code du véhicule. Le filtre
se propage ensuite à toutes les tables qui dépendent de ce véhicule.

Il y a une chose à faire de votre côté, avant l'installation. Le dépôt ne livre qu'un seul rôle,
celui du véhicule de démonstration. À vous de créer un rôle par client réel et d'y affecter les
comptes concernés. Rien ne le fera à votre place, et c'est la seule façon d'ouvrir l'écran à un
client sans lui ouvrir ceux des autres.

### La limite, écrite dans le modèle lui-même

La sécurité au niveau des lignes ne restreint que les lecteurs. Un membre ou un administrateur de
l'espace de travail voit tout. D'où la règle, et elle ne souffre pas d'exception : n'ajoutez jamais
un client comme membre de votre espace de travail. Donnez-lui accès par l'application, avec le rôle
de lecteur, et par son audience.

---

## 3. Où vos données sont stockées, et ce que vous pouvez en décider

### La région de domiciliation, vous ne la choisissez pas

La région de domiciliation de votre locataire est fixée par l'adresse du premier utilisateur qui
s'est inscrit. Elle ne se règle pas au moment d'installer la solution, et c'est là qu'on se trompe
le plus souvent. Pour la lire, ouvrez le volet d'aide du portail, puis « À propos » : elle s'affiche
en face de « Vos données sont stockées dans ».

### Ce que vous choisissez

La région de votre capacité, celle-là oui. France Centre fait partie des régions Azure où Fabric est
disponible. Si vous créez votre capacité dans une région de l'Union européenne, les données de vos
espaces de travail y sont stockées.

### La nuance qu'on omet souvent

> « Choisir une région différente pour votre capacité ne relocalise pas entièrement vos données dans
> cette région. Certains éléments restent stockés dans la région de domiciliation. »

Ce qui reste dans la région de domiciliation comprend notamment les métadonnées de rapports, les
autorisations et les informations d'identification des modèles. Ce ne sont pas vos données
comptables. Ce sont quand même des droits d'accès et des identifiants de connexion, et cela compte
le jour où un client vous demande où tout est rangé.

### Ce qui est garanti, et à quelle condition

Pour la frontière européenne des données, l'éditeur pose une condition double : le locataire et la
capacité doivent tous deux résider dans une région de l'Union européenne ou de l'Association
européenne de libre-échange. Une capacité en France ne suffit donc pas si votre locataire est
ailleurs. Vérifiez les deux.

### Ce que vous devez faire, concrètement

1. Lisez votre région de domiciliation dans le portail, avant d'aller plus loin.
2. Si elle est hors de l'Union européenne et que vos clients l'exigent, vous avez deux voies :
   déplacer le locataire, ce qui demande une demande de support et une interruption de service, ou
   accepter que certaines métadonnées restent hors de l'Union.
3. Créez votre capacité dans une région de l'Union européenne.
4. Écrivez-le dans votre lettre de mission, avec la nuance ci-dessus. Un client de la gestion
   d'actifs posera la question.

---

## 4. Un environnement intégré : vous ne sortez jamais de la plateforme

Celle-ci, vous la mesurerez surtout à l'usage.

### Tout se fait au même endroit

Tout tient dans un seul espace de travail. Les pièces et les données sont dans le coffre et dans la
base. La saisie, les contrôles et les visas se font sur l'écran de conduite. Les calculs et les
analyses se font dans le modèle sémantique, la restitution au client sur l'écran de restitution,
l'export vers Excel écrit un classeur dans le coffre, et le partage passe par une application.

Il n'y a donc aucune recopie d'un outil à l'autre, aucun export intermédiaire, aucun fichier qui
transite par un poste. Vous ne risquez pas non plus de retomber sur une version téléchargée mardi
qui a divergé depuis.

### Vous gardez Excel

Rester dans Fabric ne veut pas dire renoncer à Excel. La solution exporte le questionnaire vers un
classeur, et réimporte un classeur rempli. Les lignes importées passent par les mêmes procédures
que la saisie à l'écran, donc un import ne contourne aucun contrôle.

[Le détail des exports et des imports](../faire/pieces-et-classeurs.md)

Et si votre cabinet range déjà ses pièces dans SharePoint ou OneDrive, un raccourci les fait
apparaître dans le coffre sans les recopier.

### La partie collaborative

Le même espace de travail vous sert d'outil de production et héberge l'écran que vous donnez à votre
client. Vous n'avez donc qu'une seule chose à construire, une seule à maintenir, et pas de seconde
version qui puisse s'éloigner de la première au fil des arrêtés.

Le client ouvre une application, avec son compte, et voit ce que son audience lui permet de voir.
Vous décidez ce qui est publié, et quand.

---

## Ce que ce choix ne vous donne pas

Quatre contreparties, qu'il vaut mieux connaître avant de s'engager.

Vous dépendez d'un éditeur. Les préversions changent et les fonctions évoluent. Le dépôt indique,
pour chaque point, la date à laquelle il a été vérifié, de sorte que vous sachiez sur quoi vous vous
appuyez et depuis quand.

Le client a besoin d'une licence. Sous une capacité F64, chaque lecteur client doit être licencié :
voir [les licences](05-les-licences.md).

La sécurité au niveau des lignes ne protège pas des membres. Un client ne doit donc jamais être
membre de l'espace de travail.

Certaines métadonnées restent dans la région de domiciliation, comme expliqué à la partie 3
ci-dessus.

---

Vous avez fini cette partie. La suite, c'est
[l'installation, étape 1](../faire/etape-01-ouvrir-la-capacite.md).

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
