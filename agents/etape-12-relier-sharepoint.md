# Étape 12, avec un agent : relier SharePoint

**Cette étape ne se délègue qu'en partie.** Sur ses quinze points, sept restent à vous : l'affectation
des autorisations, qui demande un rôle d'administrateur ; les deux points qui manipulent la clé de la
fonction, qui est un secret ; la création du site du cabinet et des trois raccourcis, qui se font au
portail avec votre compte.

Lisez [l'étape 12 du mode opératoire](../docs/faire/etape-12-relier-sharepoint.md) avant de
commencer : elle explique ce que chaque autorisation permet, et pourquoi les noms des raccourcis
sont imposés.

---

## Ce qui se délègue, et ce qui ne se délègue pas

| # | Le point | Confiable à un agent |
|---|---|---|
| 1 | Créer le groupe de ressources et le stockage | **Oui** |
| 2 | Créer la Function App et son identité managée | **Oui** |
| 3 | Relever les deux identifiants du script des rôles | **Oui** |
| 4 | Affecter les huit rôles Graph | **Non**, rôle Administrateur général ou Administrateur de rôle privilégié |
| 5 | Déployer le code | **Oui** |
| 6 | Relever la clé de chacune des 2 routes | **Non**, c'est un secret |
| 7 | Créer la clé principale et les 2 credentials | **Non**, la clé y est écrite en clair |
| 8 | Enregistrer les adresses des 2 routes | **Oui** |
| 9 | Créer le site SharePoint du cabinet | **Non**, au portail SharePoint, avec votre compte |
| 10 | Enregistrer l'adresse de ce site, `SITE_CABINET` | **Oui** |
| 11 | Créer le raccourci `fec` | **Non**, au portail Fabric : la connexion se crée avec votre compte |
| 12 | Enregistrer `RACCOURCI_SITE_CABINET` | **Oui** |
| 13 | Créer l'espace du véhicule de démonstration | **Oui** |
| 14 | Créer les 3 raccourcis du site du véhicule | **Non**, au portail Fabric |
| 15 | Déposer les pièces de démonstration | **Oui** |

**Le jeu d'autorisations fourni interdit `az functionapp function keys`** pour cette raison. Ne le
modifiez pas pour arranger un agent qui bute dessus.

---

## La demande pour les points 1, 2, 3 et 5, le jour de l'étape 2

Faites-la tôt : l'affectation qui suit met jusqu'à 24 heures à s'appliquer.

> Déploie l'Azure Function du dossier `azure/` de ce dépôt, en suivant `azure/README.md`.
>
> Mes valeurs :
> - groupe de ressources : `<le vôtre>`
> - compte de stockage : `<le vôtre, en minuscules>`
> - nom de la Function App : `<le vôtre>`
> - région : `<la vôtre>`
>
> Fais les points 1, 2, 3 et 5 de ce fichier, et arrête-toi après le 5.
>
> Trois règles :
> - emploie `az functionapp deployment source config-zip`, jamais `az functionapp deploy`, qui
>   rend 415 sur un plan Flex Consumption ;
> - ne cherche pas à relever la clé de la fonction, je m'en occupe ;
> - à la fin, donne-moi le `principalId` de l'identité managée et l'identifiant du principal de
>   service Graph, et attends.

**Ce que vous vérifiez vous-même :** les deux identifiants ont la forme
`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, et la Function App apparaît dans le portail Azure avec une
identité managée active.

---

## Puis vous, seul, pour les points 4, 6 et 7

Ces trois points demandent votre compte d'administrateur et vos clés. Ils sont décrits dans
[`azure/README.md`](../azure/README.md).

**Après le point 4, attendez avant de conclure.** Le jeton Graph d'une identité managée est mis en
cache environ 24 heures : un refus dans l'heure qui suit l'affectation ne prouve rien.

---

## La demande pour le point 8

> Dans ma base, enregistre les adresses de ma fonction :
>
> ```sql
> EXEC dbo.pr_poser_parametre @code = 'ESPACE_CLIENT_URL',
>      @valeur = N'https://<ma-function-app>.azurewebsites.net/api/provisionner_espace', @par = N'<mon adresse>';
> EXEC dbo.pr_poser_parametre @code = 'DEPOT_CLASSEUR_URL',
>      @valeur = N'https://<ma-function-app>.azurewebsites.net/api/deposer_classeur', @par = N'<mon adresse>';
> ```
>
> Puis relis-les : `SELECT code, valeur FROM dbo.ref_parametre;` et recopie-moi la sortie.

---

## Puis vous, pour les points 9 et 11

Créez le site du cabinet au portail SharePoint, puis le raccourci `fec` dans le coffre, en suivant
[l'étape 12](../docs/faire/etape-12-relier-sharepoint.md). Notez l'adresse du site.

---

## La demande pour les points 10, 12 et 13

> Dans ma base, enregistre le site du cabinet et son raccourci, puis crée l'espace du véhicule de
> démonstration :
>
> ```sql
> EXEC dbo.pr_poser_parametre @code = 'SITE_CABINET',
>      @valeur = N'<mon-hote>.sharepoint.com:/sites/<mon-site>', @par = N'<mon adresse>';
> EXEC dbo.pr_poser_parametre @code = 'RACCOURCI_SITE_CABINET', @valeur = N'fec', @par = N'<mon adresse>';
>
> EXEC dbo.pr_ecran_provisionner_espace @entite = 'OMEGA-OPCI', @par = N'<mon adresse>';
> SELECT * FROM dbo.v_espace_client WHERE entite = 'OMEGA-OPCI';
> ```
>
> Recopie-moi la dernière sortie sans la résumer, la colonne `message_ecran` comprise.

**Ce que vous vérifiez vous-même :** le statut vaut `FAIT`, et les colonnes `groupe_id` et
`site_url` sont remplies. Un statut `PARTIEL` veut dire que le groupe existe mais qu'une étape
suivante a échoué ; `message_ecran` dit laquelle.

---

## Puis vous, pour le point 14

Dans le coffre, créez les raccourcis `sp_omega_opci_annuel`, `sp_omega_opci_permanent` et
`sp_omega_opci_depot` vers les bibliothèques « Dossier annuel », « Dossier permanent » et « Dépôt du
client » du site créé au point 13.

---

## La demande pour le point 15

> Dans ma base, dépose les pièces de démonstration :
>
> ```sql
> EXEC dbo.pr_deposer_pieces_de_demonstration @par = N'<mon adresse>';
> ```
>
> Recopie-moi les 2 sorties sans les résumer.

**Ce que vous vérifiez vous-même :** la première sortie dit
`Pièces déposées : 98, refusées : 0, restant sans lien : 0`. Ouvrez ensuite un lien, lu par
`SELECT TOP 1 web_url FROM dbo.piece`, dans votre navigateur : un PDF blanc doit s'afficher.

---

## Les refus que vous pouvez rencontrer

| Ce que vous lisez | Ce que cela veut dire |
|---|---|
| `Le provisionnement n'est pas installé` | Le point 8 n'a pas été fait |
| `Le dépôt n'est pas installé` | `DEPOT_CLASSEUR_URL` manque, point 8 |
| `Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de cette adresse` | Le point 7 n'a pas été fait, ou l'adresse diffère d'un caractère |
| `Aucun proprietaire` | Aucun rôle de l'entité ne porte d'adresse de connexion : jouez `sql/90_vous_inscrire_aux_missions.sql` |
| `REFUS 50963` dans la seconde sortie du point 15 | Le fichier fabriqué ne porte pas l'empreinte de la fiche : le jeu a été modifié |

Aucun de ces refus ne se corrige en modifiant un script. Ne laissez pas un agent le tenter.

---

[Les demandes à coller](README.md) · [L'avertissement](AVERTISSEMENT.md)
