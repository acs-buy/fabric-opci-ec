# Étape 12. Relier SharePoint : le site du cabinet, la fonction, le site de chaque client

**Durée :** 2 heures de travail. Comptez jusqu'à 24 heures d'attente après l'affectation des
autorisations : voyez plus bas comment ne pas les subir.
**Qui :** vous, plus un administrateur Microsoft Entra pour un seul point.

**Cette étape est obligatoire, et elle vient avant la recette.** La solution ne garde aucun fichier
dans le coffre. Tout fichier, classeur exporté ou pièce justificative, se dépose dans SharePoint,
et le coffre ne le voit que par un raccourci. Sans cette étape, l'écran s'affiche, mais tout ce qui
touche un fichier échoue :

| Ce que vous tentez | Ce qui se passe sans l'étape 12 |
|---|---|
| Exporter un classeur depuis l'écran de révision | Refus : `Le dépôt des classeurs n'est pas installé : les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés. Voir azure/README.md du dépôt.` |
| Exporter un classeur depuis l'écran Référentiels | Refus : `Dépôt refusé : le dépôt des classeurs n’est pas installé ; les paramètres DEPOT_CLASSEUR_URL et SITE_CABINET doivent être renseignés (azure/README.md du dépôt).` |
| Réimporter un classeur | Le classeur est introuvable : le raccourci `fec` n'existe pas |
| Rattacher le fichier d'un gabarit, à l'écran Référentiels | Refus : `Rattachement refusé : le raccourci du site du cabinet n’est pas installé (paramètre RACCOURCI_SITE_CABINET).` |
| Ouvrir une pièce du dossier | La colonne « Ouvrir la pièce » est vide |
| Déposer une pièce | Le bouton n'a pas d'adresse : le client n'a pas de site |
| Créer l'espace d'un client | Refus : `Le provisionnement n'est pas installé : le paramètre ESPACE_CLIENT_URL est vide.` |

---

## Ne subissez pas les 24 heures : demandez les autorisations dès l'étape 2

Le jeton Microsoft Graph d'une identité managée est mis en cache **environ 24 heures**, et on ne
peut pas forcer son renouvellement. Une autorisation affectée à 10 h 37 ne s'appliquait toujours
pas l'heure suivante, mesure du 23/09/2026.

Les points 1 à 4 de la séquence ci-dessous se font donc de préférence **le jour de l'étape 2** :
vous créez la fonction, votre administrateur Entra lui affecte ses autorisations, et vous
reprenez la suite le lendemain, au moment de cette étape-ci.

---

## Ce que cette étape met en place

| Ce qui est créé | Où | À quoi il sert |
|---|---|---|
| Une Azure Function, avec son identité managée | Votre abonnement Azure | Écrire dans SharePoint à la place de la base, qui ne sait pas obtenir de jeton Graph sans secret |
| Le site SharePoint du cabinet | Votre locataire | Recevoir les classeurs exportés, sous `Dossiers de travail/<client>/<arrêté>/` et, pour l'écran Référentiels, sous `Référentiels/` ; garder, sous `Modeles/`, le modèle Word des livrables et les fichiers des gabarits |
| Le raccourci `fec` du coffre | Le coffre | Relire un classeur modifié dans Excel, pour le réimporter |
| Un site SharePoint par client | Votre locataire | Recevoir les pièces du client et de ses filiales, dans quatre bibliothèques |
| Un raccourci par bibliothèque du client | Le coffre | Que la solution voie les pièces sans les recopier |

**Un seul site par client, filiales comprises.** Les documents d'une filiale se rangent dans le
site du véhicule qui la détient, et se classent par la colonne **Entité légale**, que la fonction
crée dans chaque bibliothèque. La base refuse de créer un site pour une filiale.

**Un préfixe par installation.** La fonction nomme le groupe d'un client par un préfixe suivi de
son code, `opci-` puis le code par défaut, et reprend un groupe qui existe déjà
(`azure/function_app.py`, `prefixe_groupe` et `slug`). Si vous installez plusieurs fois dans un même
locataire, par exemple DEV, TEST et PROD, donnez à chaque Function App son préfixe, dans le réglage
d'application `PREFIXE_GROUPE` (par exemple `opci-test-`) : sans cela, la seconde installation écrit
dans le site d'un client de même code créé par la première. Les commandes sont dans
[`azure/README.md`](../../azure/README.md).

---

## Pourquoi une Azure Function, et pas seulement la base

La base sait appeler une adresse externe, par `sp_invoke_external_rest_endpoint`. Elle ne sait pas
obtenir un jeton Microsoft Graph sans qu'un secret vive quelque part.

Trois autres voies ont été examinées et écartées :

| La voie | Pourquoi elle ne convient pas |
|---|---|
| L'identité de l'espace de travail Fabric | Deux usages documentés seulement, et aucun n'expose son jeton Graph au code d'un élément |
| Une fonction de données Fabric | Elle n'emploie ni identité managée ni identité d'espace de travail, et ses connexions génériques n'admettent que deux audiences |
| Un raccourci OneLake | Il est en lecture seule vers SharePoint : les 4 opérations d'écriture rendent 405, mesure du 22/09/2026 |

L'Azure Function porte une **identité managée**. Elle obtient son jeton sans secret, et aucune clé
Graph ne vit dans votre base ni dans votre dépôt.

---

## Les huit autorisations, et ce que chacune permet

Ce sont des **rôles d'application Microsoft Graph**, affectés à l'identité managée de la fonction.

| L'autorisation | Ce qu'elle permet | Sans elle |
|---|---|---|
| `Group.Create` | Créer le groupe Microsoft 365 du client | Rien ne se crée |
| `Group.ReadWrite.All` | Relire et compléter le groupe créé | Le groupe est créé mais non vérifiable |
| `Team.Create` | Créer l'équipe Teams sur le groupe | Le site existe, l'équipe non |
| `User.Read.All` | Retrouver les propriétaires à partir de leur adresse | Voir l'encadré ci-dessous |
| `User.Invite.All` | Inviter les personnes du client | Le client n'a pas accès à son espace |
| `Sites.ReadWrite.All` | Créer les bibliothèques, déposer les classeurs et les pièces | Le site est vide, et aucun fichier ne part |
| `Sites.Manage.All` | Créer la colonne Entité légale | Les pièces se déposent, sans être classées par entité |
| `Directory.Read.All` | Lire l'annuaire pour ces recherches | Les recherches de propriétaires échouent |

**`Sites.ReadWrite.All` ne suffit pas à créer une colonne**, mesure du 28/09/2026 : il faut
`Sites.Manage.All`.

### Pourquoi `User.Read.All` décide de tout

La documentation de l'éditeur est explicite :

> « Creating a Microsoft 365 group in an app-only context and without specifying owners creates the
> group anonymously. Doing so can result in the associated SharePoint Online site not being created
> automatically until further manual action is taken. »

Autrement dit : **un groupe créé sans propriétaire ne crée pas forcément son site SharePoint.** La
fonction désigne donc toujours des propriétaires : les personnes qui tiennent un rôle sur le client,
lues dans `role_mission`. C'est pourquoi le script `sql/90_vous_inscrire_aux_missions.sql` de
l'étape 7 compte ici : sans lui, le provisionnement échoue avec le message `Aucun proprietaire`.

---

## Trois choses que la documentation ne dit pas au bon endroit

### 1. Ces autorisations ne se posent pas au portail

> « Currently, there's no option to assign such permissions through the Microsoft Entra admin
> center. »

Pour une identité managée, l'affectation se fait par Azure CLI ou PowerShell. Le dépôt fournit le
script : [`azure/roles_graph.sh`](../../azure/roles_graph.sh). **Il exige un rôle Entra
Administrateur général ou Administrateur de rôle privilégié.** Sans l'un des deux, chaque
affectation est refusée, et le message ne désigne pas votre rôle.

### 2. Un refus dans les 24 heures

C'est le cache du jeton, décrit plus haut. Attendez avant de conclure que le script a échoué.

### 3. Le déploiement du paquet échoue en 415 sur Flex Consumption

`az functionapp deploy --type zip` rend **415** sur une Function App en plan Flex Consumption.
Employez `az functionapp deployment source config-zip`, qui passe.

---

## La séquence, dans l'ordre

Chaque point dépend du précédent. Les commandes de la partie A sont dans
[`azure/README.md`](../../azure/README.md).

### A. La fonction, une fois pour toutes

| # | Ce que vous faites | Qui |
|---|---|---|
| 1 | Créer un groupe de ressources et un compte de stockage Azure | Vous |
| 2 | Créer la Function App, Python 3.11, avec son identité managée système | Vous |
| 3 | Relever l'identifiant de l'identité managée et celui du principal Graph de votre locataire | Vous |
| 4 | Jouer `azure/roles_graph.sh` avec ces deux valeurs | Un administrateur Entra |
| 5 | Déployer le code de `azure/` sur la Function App | Vous |
| 6 | Relever la clé de chacune des 2 routes, `provisionner_espace` et `deposer_classeur` | Vous |
| 7 | Créer, dans la base, la clé principale et une credential par route | Vous |
| 8 | Enregistrer les adresses des 2 routes : `ESPACE_CLIENT_URL` et `DEPOT_CLASSEUR_URL` | Vous |

### B. Le site du cabinet et le raccourci `fec`

| # | Ce que vous faites | Qui |
|---|---|---|
| 9 | Créer un site SharePoint d'équipe pour le cabinet, par exemple « Gestion du cabinet » | Vous |
| 10 | Enregistrer son adresse dans le paramètre `SITE_CABINET`, sous la forme `<votre-hote>.sharepoint.com:/sites/<nom>` | Vous |
| 11 | Dans le coffre, créer un raccourci **SharePoint Folder** vers la bibliothèque de documents par défaut de ce site, « Documents » ou « Documents partagés » selon la langue, et le nommer `fec` | Vous |
| 12 | Enregistrer `fec` dans le paramètre `RACCOURCI_SITE_CABINET` | Vous |

**Le nom `fec` n'est pas libre.** La fonction de réimport lit les classeurs sous
`fec/Dossiers de travail/`, et `fn_documents` lit le modèle Word sous `fec/Modeles/`. À l'écran de
revue du raccourci, l'icône crayon permet de le renommer avant de le créer.

**Les 3 dossiers du site du cabinet**, dans la bibliothèque de documents par défaut, celle du
raccourci `fec` :

| Le dossier | Ce qu'il porte | Qui le crée |
|---|---|---|
| `Dossiers de travail/<client>/<arrêté>/` | Les classeurs exportés des écrans Révision et Valorisation, et les livrables produits, sous `Livrables/` | La solution, par l'Azure Function, au dépôt |
| `Référentiels/` | Les classeurs exportés de l'écran Référentiels, que ses boutons « Réimporter » relisent | La solution, par l'Azure Function, au premier export |
| `Modeles/` | Le modèle Word `modele_livrables_opci.docx`, voir l'[étape 8](etape-08-connecter-les-fonctions.md), et les fichiers des gabarits que « Rattacher le fichier » relie à un modèle de feuille | **Vous.** La solution lit ce dossier et n'y dépose rien |

À l'écran Référentiels, le bouton « Ouvrir le dossier Modèles » ouvre ce dossier quand le
référentiel choisi est celui des modèles de feuille. Son adresse est
`https://<votre-hote>.sharepoint.com/sites/<nom>/Documents%20partages/Modeles`, tirée de
`SITE_CABINET` : la base l'écrit ainsi dans la vue `v_ecran_referentiel_choix`, quel que soit le
nom de la bibliothèque dans votre locataire, et ne rend aucune adresse si `SITE_CABINET` n'a pas la
forme du point 10.

Déposez d'abord le fichier du gabarit dans `Modeles/`, puis saisissez son nom à l'écran et cliquez
sur « Rattacher le fichier ». Un nom absent du dossier est refusé :

`Rattachement refusé : le fichier « <nom> » n’est pas au dossier Modeles du site du cabinet ; déposez-le, puis saisissez son nom.`

### C. Le site du client de démonstration, et ses pièces

| # | Ce que vous faites | Qui |
|---|---|---|
| 13 | Créer l'espace du véhicule `OMEGA-OPCI` : `EXEC dbo.pr_ecran_provisionner_espace @entite = 'OMEGA-OPCI', @par = N'<votre adresse>';` | Vous |
| 14 | Dans le coffre, créer 3 raccourcis vers ce site : **Dossier annuel** nommé `sp_omega_opci_annuel`, **Dossier permanent** nommé `sp_omega_opci_permanent`, **Dépôt du client** nommé `sp_omega_opci_depot` | Vous |
| 15 | Déposer les pièces de démonstration : `EXEC dbo.pr_deposer_pieces_de_demonstration @par = N'<votre adresse>';` | Vous |

**Les noms des 3 raccourcis ne sont pas libres non plus.** Le troisième sert à rattacher une pièce
que le client a déposée. Les 98 pièces du jeu de démonstration désignent leur fichier par ce chemin,
par exemple
`/Coffre/sp_omega_opci_annuel/2024-12-31/Rapport_evaluation_IMM-201_2024-12-31.pdf`.

**Les pièces déposées sont des PDF d'une page blanche.** Leurs propriétés disent « Piece de
demonstration sans contenu », avec le numéro de la fiche. La procédure fabrique chaque fichier à
l'identique de celui qui a servi à calculer l'empreinte du jeu, et refuse de déposer un fichier dont
l'empreinte différerait. Elle est rejouable : relancée après une interruption, elle reprend les
pièces restées sans lien.

Pour un client réel, les points 13 et 14 se font une fois par véhicule, par la même requête : aucun
bouton de l'écran de conduite ne crée le site d'un client. Le point 15 ne concerne que la démonstration.

---

## Ce que vous devez voir, une fois posé

| Le contrôle | Ce qui est attendu |
|---|---|
| `SELECT * FROM dbo.v_espace_client WHERE entite = 'OMEGA-OPCI'` | Une demande au statut `FAIT`, avec l'identifiant du groupe et l'adresse du site |
| Le point 15 | `Pièces déposées : 98, refusées : 0, restant sans lien : 0` |
| `SELECT TOP 1 web_url FROM dbo.piece`, lien ouvert dans le navigateur | Un PDF blanc, dans la bibliothèque Dossier annuel, la colonne Entité légale renseignée |
| Un export depuis l'écran de révision | Un lien qui ouvre le classeur dans le site du cabinet |
| « Exporter le classeur » à l'écran Référentiels | `Classeur du référentiel « <nom> » déposé au dossier Référentiels du site du cabinet (<n> lignes) : <adresse du classeur>` |

Sur l'installation d'origine, le 28/09/2026 : 98 pièces sur 98 ont été relues par leur lien, par
leur raccourci et par leur empreinte, sans écart.

---

## Si un point refuse

| Ce que vous lisez | La cause |
|---|---|
| `Aucun proprietaire` | Aucun rôle du client ne porte d'adresse de connexion. Jouez `sql/90_vous_inscrire_aux_missions.sql` |
| `Une filiale n'a pas de site à elle` | Vous avez demandé l'espace d'une filiale. Provisionnez son véhicule |
| `Ni cette entité ni le véhicule qui la détient n'ont d'espace SharePoint` | Le point 13 n'est pas fait, ou il n'a pas abouti |
| `Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de l'adresse de dépôt` | La credential ne porte pas exactement l'adresse de la route, point 7 |
| `entité légale non posée` dans le bilan du point 15 | `Sites.Manage.All` manque, ou le cache de 24 heures ne l'a pas encore pris en compte |
| Un refus d'autorisation dans les 24 heures | Le cache du jeton. Attendez |

---

Suite : [Étape 13. La recette : douze actions qui prouvent que la solution marche](etape-13-passer-la-recette.md)

[Revenir au sommaire](../../README.md) · [Les pièces et les classeurs](pieces-et-classeurs.md)
