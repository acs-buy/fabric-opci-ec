# La fonction qui crée l'espace collaboratif d'un client

Ce dossier porte le code d'une **Azure Function** qui crée, pour un client, un groupe Microsoft 365,
son site SharePoint, son équipe Teams et quatre bibliothèques.

**Elle est facultative.** L'installation des douze étapes n'en dépend pas, et la solution sait
enregistrer l'adresse d'un site que vous avez créé à la main.

**Le pourquoi de chaque autorisation est dans [l'étape 13](../docs/faire/etape-13-provisionner-les-espaces-clients.md).**
Cette page-ci donne les commandes.

---

## Ce que contient ce dossier

| Le fichier | Ce que c'est |
|---|---|
| `function_app.py` | Le code de la fonction, Python, une seule route `provisionner_espace` |
| `host.json` | La configuration de l'hôte Azure Functions |
| `requirements.txt` | Les trois bibliothèques employées |
| `roles_graph.sh` | L'affectation des sept rôles Graph à l'identité managée |

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

### 3. Les sept rôles Graph

Relevez d'abord l'identifiant du principal de service Graph **dans votre locataire** :

```bash
az ad sp show --id 00000003-0000-0000-c000-000000000000 --query id -o tsv
```

Renseignez `MI` et `GRAPH_SP` en tête de `roles_graph.sh`, puis :

```bash
bash roles_graph.sh
```

**Il faut un rôle Entra Administrateur général ou Administrateur de rôle privilégié.** Cette
affectation ne se fait pas au portail : voir l'étape 13.

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

**Le nom de la credential est l'adresse elle-même**, et ce n'est pas une convention d'écriture :
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

| Ce que vous lisez | La cause la plus probable |
|---|---|
| `Aucun proprietaire` | Aucun rôle de l'entité ne porte d'adresse de connexion. Jouez `sql/90_vous_inscrire_aux_missions.sql` |
| Un refus d'autorisation | Les rôles Graph ne sont pas encore appliqués. Attendez, le cache dure environ 24 heures |
| `415` au déploiement | Vous avez employé `az functionapp deploy` au lieu de `deployment source config-zip` |
| Le site n'est pas créé, le groupe si | Le groupe a été créé sans propriétaire. Voir l'étape 13 |

---

[L'étape 13, qui explique le pourquoi](../docs/faire/etape-13-provisionner-les-espaces-clients.md) ·
[Revenir au sommaire](../README.md)
