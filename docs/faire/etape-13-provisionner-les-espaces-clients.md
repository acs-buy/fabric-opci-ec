# Étape 13. Créer l'espace SharePoint d'un client depuis la solution

**Durée :** 2 heures, dont 24 heures d'attente possible avant que les autorisations s'appliquent.
**Qui :** vous, plus un administrateur Microsoft Entra.

**Cette étape est facultative, et elle vient après les douze autres.** L'installation est complète
sans elle. Elle ajoute une chose : créer d'un clic l'espace collaboratif d'un client, site
SharePoint, équipe Teams et quatre bibliothèques, au lieu de le faire à la main.

Ne la commencez pas avant que la recette de l'étape 12 soit passée. Elle ne conditionne rien.

---

## Ce qu'elle ajoute, et ce qu'elle remplace

Sans cette étape, vous créez le site SharePoint du client à la main, puis vous collez son adresse
dans la fiche du dossier. La solution sait déjà enregistrer cette adresse.

Avec cette étape, la solution crée elle-même :

| Ce qui est créé | Par quel appel |
|---|---|
| Un groupe Microsoft 365, qui entraîne la création du site SharePoint | `POST /groups` |
| Une équipe Teams sur ce groupe | `POST /teams` |
| Quatre bibliothèques dans le site | `POST /sites/{id}/lists`, une fois par bibliothèque |

Les propriétaires du groupe sont les personnes qui tiennent un rôle vivant sur l'entité, associé
signataire et chef de mission. Ce point n'est pas cosmétique : voir plus bas.

---

## Pourquoi il faut une Azure Function, et pas seulement la base

La base sait appeler une adresse externe, par `sp_invoke_external_rest_endpoint`. Elle ne sait pas
obtenir un jeton Microsoft Graph sans qu'un secret vive quelque part.

Trois autres voies ont été examinées et écartées :

| La voie | Pourquoi elle ne convient pas |
|---|---|
| L'identité de l'espace de travail Fabric | Deux usages documentés seulement, et aucun n'expose son jeton Graph au code d'un élément |
| Une fonction de données Fabric | Elle n'emploie ni identité managée ni identité d'espace de travail, et ses connexions génériques n'admettent que deux audiences |
| Le rapport Power BI | Il n'a pas d'identité propre appelable |

L'Azure Function, elle, porte une **identité managée**. Elle obtient son jeton sans secret, et
aucune clé n'a besoin de vivre dans votre base ni dans votre dépôt.

---

## Les sept autorisations, et ce que chacune permet

Ce sont des **rôles d'application Microsoft Graph**, affectés à l'identité managée de la fonction.

| L'autorisation | Ce qu'elle permet | Sans elle |
|---|---|---|
| `Group.Create` | Créer le groupe Microsoft 365 | Rien ne se crée |
| `Group.ReadWrite.All` | Relire et compléter le groupe créé | Le groupe est créé mais non vérifiable |
| `Team.Create` | Créer l'équipe Teams sur le groupe | Le site existe, l'équipe non |
| `User.Read.All` | Résoudre les propriétaires depuis leur adresse | Voir l'encadré ci-dessous |
| `User.Invite.All` | Inviter les personnes du client | Le client n'a pas accès à son espace |
| `Sites.ReadWrite.All` | Créer les quatre bibliothèques | Le site est créé, mais vide |
| `Directory.Read.All` | Lire l'annuaire pour ces résolutions | Les résolutions échouent |

### Pourquoi `User.Read.All` décide de tout

La documentation de l'éditeur est explicite :

> « Creating a Microsoft 365 group in an app-only context and without specifying owners creates the
> group anonymously. Doing so can result in the associated SharePoint Online site not being created
> automatically until further manual action is taken. »

Autrement dit : **un groupe créé sans propriétaire ne crée pas forcément son site SharePoint.** La
fonction désigne donc toujours des propriétaires, et pour les désigner par leur adresse, elle doit
pouvoir lire l'annuaire.

C'est la raison pour laquelle l'étape 7 compte : les propriétaires sont lus dans `role_mission`, et
une entité dont aucun rôle ne porte d'adresse de connexion fait échouer le provisionnement avec le
message « Aucun proprietaire ».

---

## Trois choses que la documentation ne dit pas au bon endroit

Elles ont été mesurées le 08 et le 23/09/2026. Chacune coûte une demi-journée à qui l'ignore.

### 1. Ces autorisations ne se posent pas au portail

> « Currently, there's no option to assign such permissions through the Microsoft Entra admin
> center. »

Pour une identité managée, l'affectation se fait par Azure CLI ou PowerShell, et pas autrement. Le
dépôt fournit le script : [`azure/roles_graph.sh`](../../azure/roles_graph.sh).

**Et elle exige un rôle Entra Administrateur général ou Administrateur de rôle privilégié.** Si
vous ne l'avez pas, chaque affectation est refusée, et le message ne désigne pas votre rôle.

### 2. Une autorisation fraîchement posée ne s'applique pas tout de suite

Le jeton Graph d'une identité managée est mis en cache **environ 24 heures** par ressource, et le
rafraîchissement ne se force pas.

**Un refus dans l'heure qui suit une affectation ne prouve rien.** Le 23/09/2026, une permission
posée à 10 h 37 ne s'appliquait toujours pas l'heure suivante. Attendez avant de conclure que le
script a échoué.

### 3. Le déploiement du paquet échoue en 415 sur Flex Consumption

`az functionapp deploy --type zip` rend **415** sur une Function App en plan Flex Consumption. Ce
plan attend le paquet sur le point d'entrée OneDeploy du service SCM, en `application/zip`.

---

## La séquence, dans l'ordre

Chaque point dépend du précédent. Les sauter dans le désordre fait échouer le suivant sans dire
pourquoi.

| # | Ce que vous faites | Qui |
|---|---|---|
| 1 | Créer un groupe de ressources et un compte de stockage Azure | Vous |
| 2 | Créer la Function App, Python 3.11, et activer son identité managée système | Vous |
| 3 | Relever l'identifiant de l'identité managée et celui du principal Graph de votre locataire | Vous |
| 4 | Jouer `azure/roles_graph.sh` avec ces deux valeurs | Un administrateur Entra |
| 5 | Déployer le code de `azure/` sur la Function App | Vous |
| 6 | Relever la clé de la fonction | Vous |
| 7 | Créer la clé principale et la credential dans la base | Vous |
| 8 | Enregistrer l'adresse de votre fonction dans la base | Vous |
| 9 | Éprouver sur une entité de démonstration | Vous |

Les commandes de chaque point sont dans [`azure/README.md`](../../azure/README.md).

---

## Ce que vous devez voir, une fois posé

Un appel réussi rend une demande au statut `FAIT`, avec l'identifiant du groupe et l'adresse du
site. Sur l'installation d'origine, le groupe portait `resourceProvisioningOptions = [Team]`, une
visibilité privée, et le propriétaire résolu depuis `role_mission`.

*Vérification :* `SELECT * FROM dbo.v_espace_client WHERE entite = '<votre entité>'` montre la
dernière demande, son statut et le message d'écran s'il y a eu un refus.

---

## Si vous préférez vous en passer

La solution enregistre l'adresse d'un site que vous avez créé à la main, et tout le reste
fonctionne à l'identique. Vous perdez l'automatisme, rien d'autre.

---

Suite : [Dépannage](depannage.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](etape-01-ouvrir-la-capacite.md)
