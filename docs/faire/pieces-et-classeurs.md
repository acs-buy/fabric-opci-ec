# Les pièces justificatives et les classeurs Excel

**La règle : tout fichier se dépose dans SharePoint, et le coffre ne le voit que par un raccourci.**
La solution n'écrit aucun fichier dans le coffre. Cette page dit où va chaque fichier, par quel
chemin, et quelles autorisations cela demande. La mise en place est à
[l'étape 12](etape-12-relier-sharepoint.md).

---

## Où va chaque fichier

| Le fichier | Où il se dépose | Comment le coffre le voit |
|---|---|---|
| Une pièce du client ou d'une filiale | Le site SharePoint du véhicule, bibliothèque « Dépôt du client », « Dossier permanent » ou « Dossier annuel » | Un raccourci par bibliothèque, `sp_<véhicule>_<bibliothèque>` |
| Un classeur exporté de l'écran de révision | Le site SharePoint du cabinet, sous `Dossiers de travail/<client>/<arrêté>/` | Le raccourci `fec` |
| Un livrable remis au client | Le site du véhicule, bibliothèque « Livrables » | Un raccourci `sp_<véhicule>_livrables`, si vous le créez |

**Un site par véhicule, filiales comprises.** Les pièces d'une filiale se rangent dans le site du
véhicule qui la détient. Chaque fichier y porte la colonne **Entité légale**, qui dit s'il concerne
le véhicule ou l'une de ses filiales. Un filtre sur cette colonne donne les pièces d'une filiale.

---

## Pourquoi SharePoint, et pourquoi par une Azure Function

**Un lien OneLake ne s'ouvre pas dans un navigateur.** Il rend « Unauthorized, Bearer token is not
present ». Un fichier SharePoint s'ouvre au clic, dans Excel en ligne ou dans le lecteur PDF.

**Un raccourci OneLake vers SharePoint ne sait que lire.** Les quatre opérations d'écriture rendent
une erreur 405, avec le message « This operation is not supported through shortcuts of account type
OneDriveSharePoint », mesure du 22/09/2026. La documentation de l'éditeur ne le dit pas.

La solution écrit donc dans SharePoint par une autre voie : la base appelle l'Azure Function du
dépôt, qui dépose le fichier par Microsoft Graph sous son identité managée. Le raccourci sert
ensuite à relire.

| Ce que vous voulez faire | Par où cela passe |
|---|---|
| Que la solution dépose un fichier | La base, puis l'Azure Function, puis SharePoint |
| Que la solution relise un fichier | Le raccourci du coffre |
| Modifier un classeur dans Excel en ligne, puis le réimporter | Vous modifiez dans SharePoint ; le réimport relit par `fec` la version modifiée |

---

## Les pièces justificatives

### Déposer une pièce, à l'écran

1. Sur la page **Pièce justificative**, le bouton de dépôt ouvre la bibliothèque « Dépôt du client »
   du véhicule.
2. Vous y déposez le fichier, comme dans n'importe quelle bibliothèque SharePoint.
3. **Rattacher la pièce** l'inscrit au dossier : la solution calcule son empreinte, et l'enregistre
   avec sa nature, sa date et son déposant.

**L'empreinte est la garantie de la pièce.** C'est le condensé SHA-256 du fichier : deux fichiers
différents n'ont pas la même, et la base refuse d'inscrire deux fois le même fichier.

### Les pièces du jeu de démonstration

Les 98 fiches du jeu désignent chacune un PDF d'une page blanche, dont les propriétés disent « Piece
de demonstration sans contenu ». Vous les déposez d'une ligne, à l'étape 12 :

```sql
EXEC dbo.pr_deposer_pieces_de_demonstration @par = N'<votre adresse>';
```

La procédure refabrique chaque PDF à l'identique de celui qui a servi à calculer l'empreinte, et
refuse de déposer un fichier dont l'empreinte différerait. Chaque fiche reçoit ensuite son lien.

### Les autorisations du raccourci

Trois modes d'authentification sont possibles pour un raccourci SharePoint. Ils n'ont pas la même
difficulté.

| Le mode | Ce qu'il demande | Quand le retenir |
|---|---|---|
| **Compte organisationnel** | Rien de plus que vos droits sur le site | **Commencez par celui-ci.** C'est le plus simple, et il suffit à un cabinet |
| **Identité d'espace de travail** | Être administrateur de l'espace, puis autoriser cette identité sur le site par Microsoft Graph | Si vous voulez que le raccourci ne dépende plus d'une personne |
| **Principal de service** | Une inscription d'application, une autorisation `Sites.Selected`, un certificat dans Azure Key Vault | Seulement si votre direction informatique l'impose |

**L'authentification par principal de service avec une paire clé et secret n'est plus supportée.**
Le certificat est obligatoire.

### Les quatre limites du raccourci, vérifiées sur la documentation

1. **Ni site personnel, ni serveur local.** Seuls les sites SharePoint d'entreprise et OneDrive
   Entreprise sont acceptés.
2. **Au niveau du dossier, jamais du fichier.** Vous pointez une bibliothèque ou un dossier.
3. **Ni sous-site, ni site concentrateur.**
4. **Le débit de SharePoint est limité.** Des erreurs 429 viennent de la limitation de SharePoint,
   pas d'une panne.

### Créer un raccourci, et le nommer

1. Ouvrez le coffre dans votre espace de travail.
2. Dans le volet **Explorateur**, à côté de **Files**, choisissez **Nouveau raccourci**.
3. Sous **Sources externes**, choisissez **SharePoint Folder**.
4. Fournissez l'adresse racine du site, créez la connexion en **Compte organisationnel**.
5. Cochez la bibliothèque voulue, puis, à l'écran de revue, **renommez le raccourci** par l'icône
   crayon : `fec`, `sp_omega_opci_annuel`, `sp_omega_opci_permanent`.

**Les noms ne sont pas libres.** La solution lit les fichiers par ces noms, et un raccourci nommé
autrement rend la pièce introuvable.

---

## Les classeurs Excel

### Ce que l'écran de révision exporte

Les questions du programme de travail, une feuille de travail, les écritures d'opérations
diverses, et le dossier de travail complet. **Chaque classeur se dépose dans le site du
cabinet**, et l'écran rend un lien qui l'ouvre.

**Un classeur exporté se modifie dans Excel, puis se réimporte.** Le réimport relit la version
présente dans SharePoint, par le raccourci `fec`, et ses lignes entrent en base **par les mêmes
procédures que la saisie à l'écran**. Un import ne contourne aucun contrôle.

**Un dossier verrouillé s'exporte, et ne se réimporte pas.** L'export n'écrit rien dans le dossier ;
le réimport, si.

### Faut-il une licence Microsoft 365 ?

**Pour produire ou lire le classeur, la solution n'a besoin de rien.** Elle fabrique le fichier
elle-même, côté serveur, et aucune licence Microsoft 365 n'est consommée par l'export ou l'import.

**Pour ouvrir le classeur, il vous faut un tableur.**

| Comment vous l'ouvrez | Ce qu'il vous faut |
|---|---|
| Excel pour le web, depuis le lien | Un abonnement Microsoft 365 qui comprend les applications web |
| Excel installé sur votre poste | Un abonnement Microsoft 365 qui comprend Excel pour ordinateur |
| Un autre tableur | Rien de Microsoft : le format `.xlsx` se lit par d'autres logiciels |

**Vérifiez ce que votre abonnement comprend avant de vous engager.** Les plans Microsoft 365
évoluent, et nous ne reproduisons pas ici une liste qui serait périmée.

### Deux choses mesurées le 27/09/2026

- le lien rendu porte le nom **localisé** de la bibliothèque, par exemple « Documents partages »
  dans un locataire en français ;
- l'écrasement d'un classeur déjà déposé a fonctionné. L'éditeur prévient toutefois qu'un fichier
  porteur d'une étiquette de sensibilité ne peut pas être écrasé en contexte application.

---

## En résumé

1. Tout fichier va dans SharePoint. Le coffre n'en garde aucun.
2. La solution écrit par l'Azure Function, et relit par un raccourci, qui ne sait que lire.
3. Un site par véhicule, et la colonne Entité légale pour les filiales.
4. Les noms des raccourcis sont imposés : `fec` et `sp_<véhicule>_<bibliothèque>`.
5. Commencez par l'authentification par compte organisationnel, la plus simple.

---

[Revenir au sommaire](../../README.md) · [Les treize étapes](../../README.md#partie-2-faire--les-treize-étapes)
