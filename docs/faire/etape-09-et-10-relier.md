# Étapes 9 et 10. Relier la solution à votre espace de travail

Sans cette étape, les éléments sont chez vous mais rien ne fonctionne, et la cause est invisible à l'écran.

## Pourquoi cette étape existe

Une solution Fabric se reproduit en trois couches, et la synchronisation Git n'en apporte qu'une.

| Couche | Ce que c'est | Qui l'apporte |
|---|---|---|
| Les définitions | La forme des éléments : tables, vues, code, visuels | La synchronisation Git, étape 6 |
| Les données | Référentiels et jeu de démonstration | Les scripts SQL, étape 7 |
| Les liaisons | Ce qui désigne un élément par son identifiant | Cette étape |

L'éditeur l'écrit ainsi : « Git Integration re-creates item definitions only and does not restore
item data. » Les liaisons, elles, pointent encore vers l'espace de travail d'origine.

## Les deux liaisons à refaire

### Le modèle interroge encore la base d'origine

Les sources des deux modèles sémantiques lisent la base directement, et chacune porte en clair le nom du
serveur SQL et le nom de la base. L'éditeur donne cette liaison pour non reconstruite lors d'un
déploiement entre espaces de travail : « Semantic models vers SQL database : No. The connection
string in TMDL expressions contains workspace-specific values. »

**Sans réparation :** le modèle ne s'actualise pas, ou interroge une base à laquelle vous n'avez
pas accès. Aucun écran ne s'affiche.

### Les boutons appellent encore les fonctions d'origine

Les boutons qui écrivent en base portent, en clair, l'identifiant de l'espace de travail et
celui de l'ensemble de fonctions qu'ils appellent. **Le script vous dira combien votre version en
porte** : ce nombre augmente à chaque écran ajouté. L'éditeur l'écrit ainsi : « Data function
buttons don't automatically rebind across workspaces. The button stores an explicit reference to a
specific Workspace, Function set, and Data function. »

**Sans réparation :** vos boutons appellent l'espace de travail d'origine. Ou bien ils ne font
rien, ou bien ils écrivent au mauvais endroit.

## Ce qui se refait seul

La liaison du rapport vers son modèle sémantique se refait seule, parce que le rapport désigne son
modèle par un chemin relatif et non par un identifiant. **À une condition : ne renommez aucun
élément.** Un renommage casse cette liaison, et le message d'erreur ne dit pas pourquoi.

## Comment faire

### Relever vos valeurs

Ouvrez un terminal dans le dossier du dépôt et lancez :

```
python scripts/00_mes_identifiants.py
```

Le script vous demande de coller vos valeurs une par une et vérifie leur forme au passage. Il ne
se connecte à rien et ne demande aucun mot de passe.

1. **L'adresse de votre espace de travail.** Ouvrez-le dans le navigateur, copiez l'adresse entière.
2. **L'adresse de chacun de vos ensembles de fonctions** : `fn_ecran_client`, `fn_ecran_revision`,
   `fn_ecran_valorisation`, `fn_ecran_arrete`, `fn_documents` et `fn_valorisation`. Ouvrez-les un
   par un, copiez l'adresse. Attention, elle porte deux identifiants : celui de l'espace d'abord,
   celui de l'élément ensuite. Le script retient le second, qui est le bon. Le rapport appelle
   chacun de ces ensembles : un ensemble oublié laisse ses boutons sans effet.
3. **Le serveur SQL de votre base.** Ouvrez la base `DossierOPCI`, bandeau **Paramètres**, puis
   **Chaînes de connexion**.
4. **Le nom complet de votre base.** Sur la même page. Il porte un identifiant après `DossierOPCI`.
   Ne recopiez pas le nom affiché dans la liste des éléments : ce n'est pas
   celui-là.

À la fin, le script affiche les deux commandes à lancer, et les écrit aussi dans un fichier. Il
s'arrête si deux adresses donnent le même identifiant.

### Relier le modèle, puis les boutons

**L'ordre compte.** Le modèle d'abord, les boutons ensuite. Actualiser le modèle avant de l'avoir
relié produit une erreur qui fait croire à une panne de la solution.

```
python scripts/25_relier_le_modele.py --serveur <le vôtre> --base <la vôtre>

python scripts/20_relier_les_boutons.py --espace <le vôtre>
    --fn-ecran-client <le vôtre> --fn-ecran-revision <le vôtre>
    --fn-ecran-valorisation <le vôtre> --fn-ecran-arrete <le vôtre>
    --fn-documents <le vôtre> --fn-valorisation <le vôtre>
```

La seconde commande s'écrit sur une seule ligne. Le script des boutons refuse d'écrire s'il manque
un ensemble, ou si deux ensembles reçoivent le même identifiant.

Le script `00_mes_identifiants.py` a déjà écrit ces deux lignes complètes, avec vos valeurs, dans le
fichier `mes_commandes.txt`. Vous pouvez les copier de là.

Chaque script dit combien d'éléments il a traités, puis relit son travail pour le confirmer.
Envoyez ensuite les modifications à votre dépôt GitHub, et dans Fabric, faites **Mettre à jour
tout** une seconde fois.

### Deux actions restent, et sans elles vos écrans restent vides

Les scripts écrivent dans les fichiers. Deux choses ne s'y trouvent pas et se font au portail, une
fois pour toutes. **Ces deux actions ont été trouvées par une installation réelle le 26/09/2026 :
elles ne produisent aucun message d'erreur, seulement un écran vide.**

#### Premièrement, dire à chaque modèle comment se connecter à votre base

Un modèle relié à votre base sait où elle est, mais pas encore sous quelle identité l'interroger.

1. Dans votre espace de travail, ouvrez les **Paramètres** du modèle `conduite_de_mission`.
2. Dépliez **Data source credentials**. Vous y lisez alors, en clair :
   *« Failed to test the connection to your data source. Please retry your credentials. »*
3. Cliquez **Edit credentials**.
4. Dans **Authentication method**, choisissez **OAuth2**, puis **Sign in**. Votre compte
   professionnel s'affiche : choisissez-le.
5. **Recommencez à l'identique pour le modèle `restitution_client`.**

Le message d'avertissement sur le chiffrement qui peut apparaître à cette étape n'empêche pas la
connexion de s'établir.

*Vérification :* le message d'échec disparaît de la section **Data source credentials**.

#### Deuxièmement, actualiser le modèle du client

Les deux modèles ne lisent pas la base de la même façon.

| Le modèle | Comment il lit la base | Ce que vous devez faire |
|---|---|---|
| `conduite_de_mission` | Directement, à chaque affichage | Rien. L'écran du réviseur est alimenté dès la connexion posée |
| `restitution_client` | Il en garde une copie | **L'actualiser**, sinon l'écran du client reste vide |

Dans votre espace de travail, sur la ligne du modèle `restitution_client`, choisissez **Actualiser
maintenant**. L'actualisation a pris **20 secondes** sur une installation réelle.

**C'est aussi ce que vous referez après chaque publication au client.** L'écran du client montre
l'état de la dernière actualisation, non l'état de la base à la seconde près.

*Vérification :* ouvrez l'écran du client. Les pages portent des valeurs, et non des cases vides.

### Vérifier

### Avant de relier

Voici la forme des sorties. Les nombres notés `<n>` sont ceux que les scripts annoncent pour votre
version : ils changent quand un écran change. Lisez la ligne « restant a relier », avant puis
après.

Le modèle, qui interroge encore la base d'origine :

```
<n> source(s) de donnees dans les 2 modeles.
   deja reliees a votre base : 0
   restant a relier          : <n>
   sources inconnues         : 0

Source portee par ces tables :
   serveur : <le serveur d'origine>.database.fabric.microsoft.com
   base    : DossierOPCI-<l'identifiant d'origine>
```

Les boutons, qui appellent encore les fonctions d'origine :

```
<n> bouton(s) de fonction dans le rapport.
   deja relies a votre espace : 0
   restant a relier           : <n>
   identifiants inconnus      : 0

fn_documents, <n> fonction(s) appelee(s) :
   produire_livrable
fn_ecran_arrete, <n> fonction(s) appelee(s) :
   conclure_ratio
   ...
fn_ecran_client, <n> fonction(s) appelee(s) :
   ajouter_filiale
   approuver_acceptation
   creer_client
   ...
fn_ecran_revision, <n> fonction(s) appelee(s) :
   conclure_feuille
   ouvrir_feuille
   ...
fn_ecran_valorisation, <n> fonction(s) appelee(s) :
   enregistrer_expertise
   ...
fn_valorisation, <n> fonction(s) appelee(s) :
   generer_lot_valorisation
```

**Ce qu'il faut lire dans ces sorties :** la ligne « identifiants inconnus » doit valoir zéro. Si
elle ne vaut pas zéro, le rapport a été modifié à la main, ou il appelle un ensemble de fonctions
que le dossier `fabric/` ne porte pas, et les scripts refuseront d'écrire.

### Une fois relié

**Vérifiez que le total est inchangé et que les deux lignes de restant sont tombées à zéro.**

```
<n> source(s) de donnees dans les 2 modeles.
   deja reliees a votre base : <n>
   restant a relier          : 0
   sources inconnues         : 0
```

```
<n> bouton(s) de fonction dans le rapport.
   deja relies a votre espace : <n>
   restant a relier           : 0
   identifiants inconnus      : 0
```

**Tant que « restant à relier » n'est pas à zéro, l'installation n'est pas finie**, même si les
écrans s'affichent.

### Vérifier

```
python scripts/25_relier_le_modele.py --verifier
python scripts/20_relier_les_boutons.py --verifier
```

Vous devez lire **zéro restant à relier et zéro identifiant inconnu**, sur les deux scripts. Le
nombre de sources et de boutons est celui que les scripts annoncent eux-mêmes : comparez-le à celui
qu'ils affichaient avant la réparation, et non à un nombre écrit dans cette page.

## Ce que les scripts refusent de faire

Ils n'écrivent pas si un fichier porte des identifiants qu'ils ne reconnaissent pas, c'est-à-dire ni
ceux d'origine ni les vôtres. Ce cas signale un rapport ou un modèle modifié à la main, et une
écriture aveugle le casserait. Il se présente aussi quand un bouton appelle un ensemble de fonctions
que le dossier `fabric/` ne porte pas. Le script s'arrête alors en nommant le fichier en cause.

Ils ne reformatent rien non plus : ils remplacent le texte des identifiants et laissent le reste
des fichiers intact, afin que vous puissiez relire exactement ce qui a changé.

Relancer un script déjà passé ne fait rien et l'annonce.

---

Suite : [Étape 11. Publier les deux écrans, à deux publics distincts](etape-11-publier-les-applications.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
