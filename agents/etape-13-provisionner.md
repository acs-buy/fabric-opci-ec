# Étape 13, avec un agent : créer l'espace SharePoint d'un client

**Cette étape est facultative, et elle ne se délègue qu'en partie.** Sur ses neuf points, deux ne
se confient à personne : l'affectation des autorisations, qui demande un rôle d'administrateur, et
la manipulation de la clé de la fonction, qui est un secret.

Lisez [l'étape 13 du mode opératoire](../docs/faire/etape-13-provisionner-les-espaces-clients.md)
avant de commencer : elle explique ce que chaque autorisation permet.

---

## Ce qui se délègue, et ce qui ne se délègue pas

| # | Le point | Confiable à un agent |
|---|---|---|
| 1 | Créer le groupe de ressources et le stockage | **Oui** |
| 2 | Créer la Function App et son identité managée | **Oui** |
| 3 | Relever les deux identifiants du script des rôles | **Oui** |
| 4 | Affecter les sept rôles Graph | **Non**, rôle Administrateur général ou Administrateur de rôle privilégié |
| 5 | Déployer le code | **Oui** |
| 6 | Relever la clé de la fonction | **Non**, c'est un secret |
| 7 | Créer la clé principale et la credential | **Non**, la clé y est écrite en clair |
| 8 | Enregistrer l'adresse de la fonction | **Oui** |
| 9 | Éprouver sur une entité | **Oui** |

**Le jeu d'autorisations fourni interdit `az functionapp function keys`** pour cette raison. Ne le
modifiez pas pour arranger un agent qui bute dessus.

---

## La demande pour les points 1, 2, 3 et 5

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

**Ce que vous vérifiez vous-même :** les deux identifiants ressemblent à des identifiants Fabric,
et la Function App apparaît dans le portail Azure avec une identité managée active.

---

## Puis vous, seul, pour les points 4, 6 et 7

Ces trois points demandent votre compte d'administrateur et votre clé. Ils sont décrits dans
[`azure/README.md`](../azure/README.md).

**Après le point 4, attendez avant de conclure.** Le jeton Graph d'une identité managée est mis en
cache environ 24 heures : un refus dans l'heure qui suit l'affectation ne prouve rien.

---

## La demande pour les points 8 et 9

> Dans ma base, enregistre l'adresse de ma fonction, puis éprouve le provisionnement :
>
> ```sql
> EXEC dbo.pr_poser_parametre @code = 'ESPACE_CLIENT_URL',
>      @valeur = N'<l'adresse de ma fonction>', @par = N'<mon adresse>';
>
> EXEC dbo.pr_ecran_provisionner_espace @entite = '<une entité>', @par = N'<mon adresse>';
>
> SELECT * FROM dbo.v_espace_client WHERE entite = '<la même>';
> ```
>
> Recopie-moi la dernière sortie sans la résumer, la colonne `message_ecran` comprise.

**Ce que vous vérifiez vous-même :** le statut vaut `FAIT`, et les colonnes `groupe_id` et
`site_url` sont remplies. Un statut `PARTIEL` veut dire que le groupe existe mais qu'une étape
suivante a échoué ; `message_ecran` dit laquelle.

---

## Les trois refus que vous pouvez rencontrer

| Ce que vous lisez | Ce que cela veut dire |
|---|---|
| `Le provisionnement n'est pas installé` | Le point 8 n'a pas été fait |
| `Aucune DATABASE SCOPED CREDENTIAL ne porte le nom de cette adresse` | Le point 7 n'a pas été fait, ou l'adresse diffère d'un caractère |
| `Aucun proprietaire` | Aucun rôle de l'entité ne porte d'adresse de connexion : jouez `sql/90_vous_inscrire_aux_missions.sql` |

Aucun de ces trois refus ne se corrige en modifiant un script. Ne laissez pas un agent le tenter.

---

[Les demandes à coller](README.md) · [L'avertissement](AVERTISSEMENT.md)
