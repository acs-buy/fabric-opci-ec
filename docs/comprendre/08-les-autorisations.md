# 8. Les autorisations : qui les pose, et à quel moment

Cette page rassemble toutes les autorisations que l'installation demande. Elles sont dispersées
dans les étapes.

**À lire avant de commencer.** Deux d'entre elles ne dépendent pas de vous, et les obtenir peut
prendre plusieurs jours. Les demander au bon moment évite d'attendre au milieu du parcours.

---

## Ce que vous devez demander à quelqu'un d'autre

| Qui | Ce que vous lui demandez | Quand | Si vous attendez |
|---|---|---|---|
| **L'administrateur Microsoft Fabric** | Activer cinq réglages de locataire | Avant l'étape 2 | Rien ne s'installe, et GitHub n'apparaît pas dans la liste |
| **L'administrateur Microsoft Entra** | Affecter huit rôles d'application à une identité managée | Le jour de l'étape 2, pour l'étape 12 | Aucun fichier ne se dépose : ni classeur exporté, ni pièce, ni espace client |

**Demandez les deux dès le début.** La première bloque tout le reste. La seconde ne sert qu'à
l'étape 12, mais une autorisation Graph met jusqu'à 24 heures à s'appliquer : demandée le jour de
l'étape 2, elle est prête quand vous arrivez à l'étape 12.

---

## Les cinq réglages de locataire, à l'étape 2

Ils s'activent dans le portail d'administration Fabric, sous **Paramètres du locataire**.

| Le réglage | À quoi il sert | Sans lui |
|---|---|---|
| Créer des éléments Fabric | Créer la base, le coffre, les fonctions | Rien ne s'installe |
| Synchroniser avec Git | Connecter un dépôt à l'espace de travail | Pas d'intégration Git du tout |
| Créer des espaces de travail | L'étape 3 | Il faut qu'un administrateur le crée pour vous |
| Synchroniser avec GitHub | Voir GitHub dans la liste des fournisseurs | GitHub n'apparaît pas |
| Accès externe à OneLake | Télécharger un fichier du coffre | Vous voyez les fichiers sans pouvoir les récupérer |

Ces réglages s'activent pour tout le locataire ou pour un groupe de sécurité. **Si votre
administrateur retient la seconde voie, demandez à figurer dans ce groupe**, et vérifiez-le :
l'appartenance n'est pas immédiate.

Le détail est à [l'étape 2](../faire/etape-02-activer-les-reglages.md).

---

## Ce que vous devez être, vous

| Ce que vous devez être | Pour quoi faire | À quelle étape |
|---|---|---|
| Administrateur de votre espace de travail | Connecter l'espace au dépôt Git | 5 |
| Propriétaire des ensembles de fonctions | Les publier après la synchronisation | 8 |
| Propriétaire des modèles de données | Saisir leurs informations d'identification | 9 |
| Titulaire d'un rôle sur un dossier | Écrire dans ce dossier, et le viser | 12 |

Vous pouvez avoir installé toute la solution et ne rien voir à l'écran,
parce qu'aucun rôle de mission ne porte votre adresse. C'est ce que corrige
`sql/90_vous_inscrire_aux_missions.sql`, à l'étape 7.

---

## Ce que permet chaque rôle dans un dossier

La base reconnaît une personne par **son adresse de connexion**, jamais par le nom saisi dans le
rôle. Un rôle compte du jour de son début jusqu'à la veille de sa fin.

| Le geste | Qui peut le faire |
|---|---|
| Retirer une pièce du dossier | Un membre de l'équipe : associé, chef de mission, préparateur ou réviseur ; pour une filiale, aussi un membre de l'équipe du véhicule qui la détient |
| Demander la réouverture d'un arrêté clos | Un membre de l'équipe qui n'est pas chef de mission |
| Accorder ou écarter cette demande | Le chef de mission, s'il n'est pas l'auteur de la demande |
| Viser la revue, valider pour le client | Le chef de mission |

Le refus vient de la base, avec le même texte qu'à l'écran : « Demande refusée : votre adresse de
connexion n'est rattachée à aucun membre de l'équipe de ce dossier. »

---

## Ce que vous devez donner à la base, à l'étape 12

Ces droits permettent à la base d'appeler l'Azure Function : pour créer l'espace d'un client, et pour
déposer un fichier dans SharePoint. Il en faut un par route, `provisionner_espace` et
`deposer_classeur`, car une credential porte le nom exact de l'adresse appelée.

```sql
GRANT EXECUTE ANY EXTERNAL ENDPOINT TO [<le principal qui exécute>];
GRANT REFERENCES ON DATABASE SCOPED CREDENTIAL::[<l'adresse de provisionner_espace>] TO [<le même>];
GRANT REFERENCES ON DATABASE SCOPED CREDENTIAL::[<l'adresse de deposer_classeur>] TO [<le même>];
```

L'appel sortant lui-même est **activé par défaut** dans SQL database in Fabric : il n'y a rien à
activer, seulement ces deux droits à donner.

---

## Les huit autorisations Microsoft Graph, pour l'étape 12

Elles sont affectées à l'identité managée de l'Azure Function, jamais à une personne.

| L'autorisation | Ce qu'elle permet |
|---|---|
| `Group.Create` | Créer le groupe Microsoft 365 du client |
| `Group.ReadWrite.All` | Relire et compléter ce groupe |
| `Team.Create` | Créer l'équipe Teams |
| `User.Read.All` | Résoudre les propriétaires depuis leur adresse |
| `User.Invite.All` | Inviter les personnes du client |
| `Sites.ReadWrite.All` | Créer les quatre bibliothèques du site, déposer les classeurs et les pièces |
| `Sites.Manage.All` | Créer la colonne Entité légale des bibliothèques |
| `Directory.Read.All` | Lire l'annuaire pour ces résolutions |

**Deux choses à savoir avant de les demander :**
elles ne s'affectent pas au portail Entra pour une identité managée, et une autorisation
fraîchement posée met environ 24 heures à s'appliquer.

Le détail est à [l'étape 12](../faire/etape-12-relier-sharepoint.md).

---

## Les secrets, et où ils vivent

Trois secrets traversent l'installation. Aucun ne doit entrer dans votre dépôt.

| Le secret | Où il vit | Qui le manipule |
|---|---|---|
| Le jeton GitHub, portée `repo` | Dans l'écran de connexion Fabric, une seule fois | Vous, jamais un agent |
| Les 2 clés de votre Azure Function, une par route | Dans 2 `DATABASE SCOPED CREDENTIAL`, en base | Vous, jamais un agent |
| Le mot de passe de la clé principale de la base | Nulle part : gardez-le dans votre coffre-fort | Vous |

**La solution elle-même n'a aucun mot de passe.** Chaque personne se connecte avec son compte
professionnel, et la base reconnaît cette identité.

---

## Ce que les licences exigent, qui n'est pas une autorisation mais s'oublie autant

Sous une capacité inférieure à F64, **toute personne qui ouvre un écran a besoin d'une licence
Power BI Pro ou Premium par utilisateur**, vos clients compris.

Le détail, avec les chiffres, est dans [les licences](05-les-licences.md).

---

Suite : [9. Trois espaces de travail, et un pipeline entre eux](09-trois-espaces.md)

[Revenir au sommaire](../../README.md) · [Les licences](05-les-licences.md)
