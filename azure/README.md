# La fonction qui écrit dans SharePoint à la place de la base

Ce dossier porte le code d'une **Azure Function** à deux routes :

| La route | Ce qu'elle fait |
|---|---|
| `provisionner_espace` | Crée, pour un véhicule, un groupe Microsoft 365, son site SharePoint, son équipe Teams, quatre bibliothèques et leur colonne Entité légale |
| `deposer_classeur` | Dépose un fichier dans SharePoint : un classeur dans le site du cabinet, ou une pièce dans une bibliothèque du site d'un client |

**Elle est obligatoire.** La solution ne garde aucun fichier dans le coffre : sans cette fonction,
aucun classeur ne s'exporte et aucune pièce ne se dépose. Elle se met en place à
[l'étape 12](../docs/faire/etape-12-relier-sharepoint.md), qui explique aussi le pourquoi de chaque
autorisation. Cette page-ci donne les commandes.

---

## Ce que contient ce dossier

| Le fichier | Ce que c'est |
|---|---|
| `function_app.py` | Le code de la fonction, Python, deux routes : `provisionner_espace` et `deposer_classeur` |
| `host.json` | La configuration de l'hôte Azure Functions |
| `requirements.txt` | Les trois bibliothèques employées |
| `roles_graph.sh` | L'affectation des huit rôles Graph à l'identité managée |

**Aucun secret ici, et il ne doit jamais y en avoir.** La fonction s'authentifie par son identité
managée, et la clé d'appel vit dans une `DATABASE SCOPED CREDENTIAL`, côté base.

---

## Les commandes, dans l'ordre

Remplacez les valeurs entre chevrons par les vôtres. La région est un exemple : choisissez une
région de l'Union européenne si vos clients l'exigent.

### 1. Le groupe de ressources et le stockage

```bash
az group create -n <votre-groupe> -l francecentral

az storage account create -n <nom-unique-en-minuscules> -g <votre-groupe> -l francecentral \
  --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2
```

### 2. La Function App et son identité managée

```bash
az functionapp create --name <votre-function-app> --resource-group <votre-groupe> \
  --flexconsumption-location francecentral --runtime python --runtime-version 3.11 \
  --storage-account <nom-unique-en-minuscules> --assign-identity "[system]" \
  --query "{principalId:identity.principalId}" -o json
```

**Relevez le `principalId` rendu** : c'est la valeur `MI` du script des rôles.

### 3. Les huit rôles Graph

Relevez d'abord l'identifiant du principal de service Graph **dans votre locataire** :

```bash
az ad sp show --id 00000003-0000-0000-c000-000000000000 --query id -o tsv
```

Renseignez `MI` et `GRAPH_SP` en tête de `roles_graph.sh`, puis :

```bash
bash roles_graph.sh
```

**Il faut un rôle Entra Administrateur général ou Administrateur de rôle privilégié.** Cette
affectation ne se fait pas au portail : voir l'étape 12.

**Faites ce point le jour de l'étape 2.** Une autorisation Graph met jusqu'à 24 heures à
s'appliquer : posée tôt, elle sera prête à l'étape 12.

### 4. Le déploiement du code

```bash
zip -r espaces_client.zip function_app.py host.json requirements.txt
az functionapp deployment source config-zip -n <votre-function-app> -g <votre-groupe> \
  --src espaces_client.zip
```

**N'employez pas `az functionapp deploy --type zip`** sur un plan Flex Consumption : il rend
415 Unsupported Media Type. Ce plan attend le paquet sur le point d'entrée OneDeploy du service
SCM, en `application/zip`.

### 5. La clé de la fonction, puis la credential dans la base

```bash
az functionapp function keys list -n <votre-function-app> -g <votre-groupe> \
  --function-name provisionner_espace
```

Puis, dans votre base SQL Fabric, une seule fois :

```sql
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<un mot de passe fort, gardé hors du dépôt>';

CREATE DATABASE SCOPED CREDENTIAL [https://<votre-function-app>.azurewebsites.net/api/provisionner_espace]
    WITH IDENTITY = 'HTTPEndpointHeaders', SECRET = '{"x-functions-key":"<votre clé>"}';
```

**Le nom de la credential est l'adresse elle-même** :
`sp_invoke_external_rest_endpoint` apparie la credential à l'adresse appelée par son nom. Une
adresse différente impose une credential différente.

### 6. L'adresse de votre fonction, dans la base

```sql
EXEC dbo.pr_poser_parametre
     @code = 'ESPACE_CLIENT_URL',
     @valeur = N'https://<votre-function-app>.azurewebsites.net/api/provisionner_espace',
     @par = N'<votre adresse>';
```

Sans ce paramètre, la procédure refuse d'appeler quoi que ce soit, avec un message qui le dit.

### 7. Les droits de la base

```sql
GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [<le principal qui exécute>];
GRANT REFERENCES ON DATABASE SCOPED CREDENTIAL::[https://<votre-function-app>.azurewebsites.net/api/provisionner_espace]
      TO [<le principal qui exécute>];
```

`sp_invoke_external_rest_endpoint` est activé par défaut dans SQL database in Fabric : vous n'avez
rien à activer, seulement à donner ces deux droits.

---

## La seconde route : déposer un fichier dans SharePoint

La même fonction porte une seconde route, `deposer_classeur`. Elle sert à 2 procédures de la base :

| La procédure | Ce qu'elle dépose, et où |
|---|---|
| `dbo.pr_deposer_classeur` | Chaque classeur exporté de l'écran de révision, dans le site **du cabinet**, sous `Dossiers de travail/<client>/<arrêté>/` |
| `dbo.pr_deposer_fichier_espace` | Une pièce, dans l'une des 4 bibliothèques du site **du véhicule**, avec son entité légale |

Dans les deux cas, elle rend un lien qui s'ouvre au clic.

**Pourquoi SharePoint et non le coffre.** Une adresse OneLake directe ne s'ouvre pas dans un
navigateur : elle rend « Unauthorized, Bearer token is not present ». Un fichier SharePoint s'ouvre.

**Aucune autorisation de plus pour déposer** : `Sites.ReadWrite.All` couvre le dépôt. Graph accepte
le dépôt simple jusqu'à 250 Mo. La colonne Entité légale, elle, demande `Sites.Manage.All`.

**Une credential de plus**, parce que la base apparie la credential à l'adresse appelée par son
nom :

```sql
CREATE DATABASE SCOPED CREDENTIAL [https://<votre-function-app>.azurewebsites.net/api/deposer_classeur]
    WITH IDENTITY = 'HTTPEndpointHeaders', SECRET = '{"x-functions-key":"<la clé de deposer_classeur>"}';
```

**Trois paramètres**, lus par `dbo.pr_deposer_classeur` :

```sql
EXEC dbo.pr_poser_parametre @code = 'DEPOT_CLASSEUR_URL',
     @valeur = N'https://<votre-function-app>.azurewebsites.net/api/deposer_classeur', @par = N'<vous>';
EXEC dbo.pr_poser_parametre @code = 'SITE_CABINET',
     @valeur = N'<votre-hote>.sharepoint.com:/sites/<votre-site>', @par = N'<vous>';
EXEC dbo.pr_poser_parametre @code = 'RACCOURCI_SITE_CABINET',
     @valeur = N'<le nom du raccourci du coffre vers la bibliothèque de ce site>', @par = N'<vous>';
```

Le troisième est facultatif : il sert à relire un classeur déposé depuis le coffre, pour le
réimporter. Sans lui, le dépôt fonctionne, mais la procédure ne rend pas de chemin OneLake.

**Deux choses mesurées le 27/09/2026** :
- le lien rendu porte le nom **localisé** de la bibliothèque, par exemple « Documents partages »
  dans un locataire en français ;
- l'écrasement d'un fichier existant a fonctionné. L'éditeur prévient toutefois qu'un fichier
  porteur d'une étiquette de sensibilité ne peut pas être écrasé en contexte application.

**Un dossier verrouillé s'exporte.** L'export n'écrit rien dans le dossier de travail, et c'est le
dossier visé qu'on veut archiver. Le réimport, lui, reste refusé sur un dossier verrouillé.

---

## Éprouver

```sql
EXEC dbo.pr_ecran_provisionner_espace @entite = '<une entité de démonstration>',
     @par = N'<votre adresse>';

SELECT * FROM dbo.v_espace_client WHERE entite = '<la même>';
```

La demande doit porter le statut `FAIT`, un identifiant de groupe et une adresse de site.

**Un refus dans l'heure qui suit l'affectation des rôles ne prouve rien** : le jeton Graph d'une
identité managée est mis en cache environ 24 heures.

---

## Si la fonction refuse

| Ce que vous lisez | La cause |
|---|---|
| `Aucun proprietaire` | Aucun rôle de l'entité ne porte d'adresse de connexion. Jouez `sql/90_vous_inscrire_aux_missions.sql` |
| Un refus d'autorisation | Les rôles Graph ne sont pas encore appliqués. Attendez, le cache dure environ 24 heures |
| `415` au déploiement | Vous avez employé `az functionapp deploy` au lieu de `deployment source config-zip` |
| Le site n'est pas créé, le groupe si | Le groupe a été créé sans propriétaire. Voir l'étape 12 |

---

[L'étape 12, qui explique le pourquoi](../docs/faire/etape-12-relier-sharepoint.md) ·
[Revenir au sommaire](../README.md)
