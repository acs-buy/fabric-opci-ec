# 7. Ce que vous garantit le fait de tout garder dans Fabric

La solution ne sort jamais de Microsoft Fabric. Ce choix apporte quatre garanties que vous n'auriez
pas en assemblant des outils séparés, et il a des contreparties.

Cette page dit les unes et les autres.

---

## 1. L'authentification, vous n'en écrivez pas une ligne

La solution ne porte aucun mot de passe : ni table d'utilisateurs, ni formulaire de connexion, ni
jeton à renouveler.

Chaque personne se connecte avec son compte professionnel Microsoft. La plateforme le reconnaît, et
la solution récupère son identité telle quelle.

| Ce que vous n'avez pas à faire | Pourquoi |
|---|---|
| Créer des comptes | Ce sont ceux de votre cabinet, déjà administrés |
| Gérer les mots de passe et leur renouvellement | Votre administrateur le fait déjà, une fois pour toutes vos applications |
| Poser l'authentification à deux facteurs | Elle s'applique si votre cabinet l'a activée, sans rien à faire ici |
| Retirer les accès d'un partant | Désactiver son compte suffit, partout à la fois |

**Ce que la solution en fait.** L'identité connectée sert à trois choses : filtrer ce que la
personne voit, vérifier ce qu'elle a le droit d'écrire, et signer ce qu'elle écrit. Quand une
réponse d'acceptation est enregistrée, c'est son compte qui est inscrit, pas un nom saisi à la main.

---

## 2. La sécurité au niveau des lignes : chacun ne voit que le sien

Le cloisonnement n'est pas fait par l'écran, il est fait par le modèle de données. Un utilisateur
qui exporterait la donnée, ou qui l'interrogerait autrement, se verrait appliquer le même filtre.

### Côté réviseur

Le modèle de conduite porte un rôle qui restreint chaque personne aux entités sur lesquelles elle
détient un mandat **vivant** :

```
le compte connecté  ->  ses mandats en cours  ->  les dossiers qu'il voit
```

Un réviseur retiré d'une mission cesse d'en voir le dossier, sans qu'on ait à toucher à ses
autorisations.

### Côté client

Le modèle de restitution porte **un rôle par client**, qui filtre sur le code du véhicule. Le filtre
se propage ensuite à toutes les tables qui dépendent de ce véhicule.

**Un point à connaître avant l'installation, et il commande une action de votre part.** Le dépôt
livre un seul rôle, celui du véhicule de démonstration. **Vous devrez créer un rôle par client réel
et y affecter les comptes concernés.** Ce n'est pas automatique, et c'est la seule façon d'ouvrir
l'écran à un client sans lui ouvrir ceux des autres.

### La limite à connaître, écrite dans le modèle lui-même

**La sécurité au niveau des lignes ne restreint que les lecteurs.** Un membre ou un administrateur
de l'espace de travail voit tout.

La conséquence est directe : **n'ajoutez jamais un client comme membre de votre espace de travail.**
Donnez-lui accès par l'application, avec le rôle de lecteur, et par son audience.

---

## 3. Où vos données sont stockées, et ce que vous pouvez en décider

Ce point est souvent mal rapporté. La documentation de l'éditeur dit ceci.

### La région de domiciliation n'est pas choisie librement

**La région de domiciliation de votre locataire est fixée par l'adresse du premier utilisateur qui
s'est inscrit.** Elle n'est pas un réglage que vous choisissez en installant la solution. Vous
pouvez la lire dans le portail, par le volet d'aide, puis « À propos » : elle s'affiche en face de
« Vos données sont stockées dans ».

### Ce que vous pouvez choisir

**Vous choisissez la région de votre capacité.** France Centre fait partie des régions Azure où
Fabric est disponible. En créant votre capacité dans une région de l'Union européenne, les données
de vos espaces de travail y sont stockées.

### La nuance qu'il faut connaître, et qu'on omet souvent

> « Choisir une région différente pour votre capacité ne relocalise pas entièrement vos données dans
> cette région. Certains éléments restent stockés dans la région de domiciliation. »

Ce qui reste dans la région de domiciliation comprend notamment les métadonnées de rapports, les
autorisations et les informations d'identification des modèles. Ce ne sont pas vos données
comptables, mais ce ne sont pas rien non plus.

### Ce qui est garanti, et à quelle condition

L'éditeur l'écrit ainsi : pour la **frontière européenne des données**, le locataire **et** la
capacité doivent tous deux résider dans une région de l'Union européenne ou de l'Association
européenne de libre-échange.

**Autrement dit :** une capacité en France ne suffit pas si votre locataire est ailleurs. Vérifiez
les deux.

### Ce que vous devez faire, concrètement

1. **Lisez votre région de domiciliation** dans le portail, avant d'aller plus loin.
2. **Si elle est hors de l'Union européenne** et que vos clients l'exigent, deux voies : déplacer le
   locataire, ce qui demande une demande de support et une interruption de service, ou accepter que
   certaines métadonnées restent hors de l'Union.
3. **Créez votre capacité dans une région de l'Union européenne.**
4. **Écrivez-le dans votre lettre de mission**, avec la nuance ci-dessus. Un client de la gestion
   d'actifs posera la question.

---

## 4. Un environnement intégré : vous ne sortez jamais de la plateforme

C'est la garantie qui pèse le plus au quotidien.

### Tout se fait au même endroit

| Ce que vous faites | Où cela se passe |
|---|---|
| Stocker les pièces et les données | Le coffre et la base, dans votre espace de travail |
| Saisir, contrôler, viser | L'écran de conduite, dans le même espace |
| Calculer et analyser | Le modèle sémantique, dans le même espace |
| Restituer au client | L'écran de restitution, dans le même espace |
| Exporter vers Excel | Un classeur écrit dans le coffre, dans le même espace |
| Partager | Une application, dans le même espace |

Aucune recopie entre outils : pas de fichier qui transite par un poste, pas d'export intermédiaire,
pas de version qui diverge parce qu'elle a été téléchargée la semaine passée.

### Les outils que votre cabinet connaît déjà restent utilisables

Rester dans Fabric ne veut pas dire renoncer à Excel. La solution exporte le questionnaire vers un
classeur, et réimporte un classeur rempli. Les lignes importées entrent **par les mêmes procédures
que la saisie à l'écran** : un import ne contourne aucun contrôle.

[Le détail des exports et des imports](../faire/pieces-et-classeurs.md)

Et si votre cabinet range déjà ses pièces dans SharePoint ou OneDrive, un raccourci les fait
apparaître dans le coffre sans les recopier.

### La partie collaborative, qui est le point d'arrivée

Le même espace de travail porte votre outil de production et l'écran que vous donnez à votre
client. Vous n'en construisez donc qu'un, vous n'en maintenez qu'un, et ils ne peuvent pas
diverger.

Le client ouvre une application, avec son compte, et voit ce que son audience lui permet de voir.
Vous décidez ce qui est publié, et quand.

---

## Les contreparties

Les contreparties de ce choix :

| La contrepartie | Ce qu'elle implique |
|---|---|
| **Vous dépendez d'un éditeur** | Les préversions changent, et les fonctions évoluent. Le dépôt porte les dates de vérification pour que vous sachiez ce qui a été établi et quand |
| **Le client a besoin d'une licence** | Sous une capacité F64, chaque lecteur client doit être licencié. Voir [les licences](05-les-licences.md) |
| **La sécurité au niveau des lignes ne protège pas des membres** | Un client ne doit jamais être membre de l'espace de travail |
| **Certaines métadonnées restent dans la région de domiciliation** | Voir la partie 3 ci-dessus |

---

**C'est la dernière page de cette partie.** Vous pouvez passer à [l'installation, étape 1](../faire/etape-01-ouvrir-la-capacite.md).

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
