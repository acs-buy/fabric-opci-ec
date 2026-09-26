# Étapes 9 et 10. Relier la solution à votre espace de travail

Sans cette étape, les éléments sont chez vous et rien ne fonctionne. Vous n'aurez aucun message
d'erreur pour vous l'apprendre : simplement des écrans vides.

## Pourquoi cette étape existe

Une solution Fabric se reproduit en trois couches, et la synchronisation Git n'en apporte qu'une.

| Couche | Ce que c'est | Qui l'apporte |
|---|---|---|
| Les définitions | La forme des éléments : tables, vues, code, visuels | La synchronisation Git, étape 6 |
| Les données | Référentiels et jeu de démonstration | Les scripts SQL, étape 7 |
| Les liaisons | Ce qui désigne un élément par son identifiant | Cette étape |

L'éditeur l'écrit ainsi : « Git Integration re-creates item definitions only and does not restore
item data. » Quant aux liaisons, elles continuent de désigner l'espace de travail d'origine.

## Les deux liaisons à refaire

### Le modèle interroge encore la base d'origine

Les 73 sources des deux modèles sémantiques lisent la base directement, et chacune contient, écrit
en clair, le nom du serveur SQL et celui de la base. L'éditeur indique que cette liaison n'est pas
refaite lors d'un déploiement d'un espace de travail vers un autre : « Semantic models vers SQL
database : No. The connection string in TMDL expressions contains workspace-specific values. »

Si vous ne la refaites pas, le modèle ne s'actualise pas, ou bien il interroge une base à laquelle
vous n'avez pas accès. Aucun écran ne s'affiche.

### Les boutons appellent encore les fonctions d'origine

Les boutons qui écrivent en base contiennent, en clair, l'identifiant de l'espace de travail et
celui de l'ensemble de fonctions qu'ils appellent. **Le script vous dira combien votre version en
porte** : ce nombre augmente à chaque écran ajouté, et le figer ici le rendrait faux. L'éditeur l'écrit ainsi : « Data function
buttons don't automatically rebind across workspaces. The button stores an explicit reference to a
specific Workspace, Function set, and Data function. »

Si vous ne la refaites pas, vos boutons s'adressent toujours à l'espace de travail d'origine : soit
ils ne font rien, soit ils écrivent au mauvais endroit.

## Ce qui se recolle tout seul

La liaison du rapport vers son modèle sémantique se refait seule, parce que le rapport désigne son
modèle par un chemin relatif et non par un identifiant. Une seule chose la casse : le renommage.
Si vous renommez un élément, la liaison est rompue et le message d'erreur ne dira pas pourquoi. Ne
renommez rien.

## Comment faire

### Relever vos cinq valeurs

Ouvrez un terminal dans le dossier du dépôt et lancez :

```
python scripts/00_mes_identifiants.py
```

Le script vous demande de coller cinq choses et vérifie leur forme au passage. Il ne se connecte
à rien et ne vous demande aucun mot de passe.

1. **L'adresse de votre espace de travail.** Ouvrez-le dans le navigateur, copiez l'adresse entière.
2. **L'adresse de votre élément `fn_ecran_client`.** Ouvrez-le, copiez l'adresse. Elle contient
   deux identifiants, celui de l'espace d'abord et celui de l'élément ensuite. Le script retient le
   second, qui est le bon.
3. **L'adresse de votre élément `fn_ecran_revision`.** Le rapport appelle un ensemble de fonctions
   par écran. Sans celui-ci, 7 boutons de l'écran de révision resteraient sans effet.
4. **Le serveur SQL de votre base.** Ouvrez la base `DossierOPCI`, bandeau **Paramètres**, puis
   **Chaînes de connexion**.
5. **Le nom complet de votre base.** Sur la même page. Il comporte un identifiant après
   `DossierOPCI`, c'est normal. Ne recopiez pas le nom affiché dans la liste des éléments, ce n'est
   pas celui-là : c'est là qu'on se trompe.

À la fin, le script affiche les deux commandes à lancer, et les écrit aussi dans un fichier.

### Relier le modèle, puis les boutons

Le modèle d'abord, les boutons ensuite. Si vous actualisez le modèle avant de l'avoir relié,
l'erreur qui s'affiche ressemble à une panne de la solution, et vous la chercherez longtemps là où
elle n'est pas.

```
python scripts/25_relier_le_modele.py --serveur <le vôtre> --base <la vôtre>

python scripts/20_relier_les_boutons.py --espace <le vôtre> --fn-ecran-client <le vôtre> --fn-ecran-revision <le vôtre>
```

Le script `00_mes_identifiants.py` a déjà écrit ces deux lignes complètes, avec vos valeurs, dans le
fichier `mes_commandes.txt`. Vous pouvez les copier de là.

Chaque script dit combien d'éléments il a traités, puis relit son travail pour le confirmer.
Envoyez ensuite les modifications à votre dépôt GitHub, et dans Fabric, faites **Mettre à jour
tout** une seconde fois.

### Deux actions au portail, sans lesquelles vos écrans restent vides

Les scripts écrivent dans les fichiers. Deux choses ne s'y trouvent pas et se font au portail, une
fois pour toutes. Une installation réelle les a trouvées le 26/09/2026 : elles ne produisent aucun
message d'erreur, seulement un écran vide.

#### Premièrement, dire à chaque modèle comment se connecter à votre base

Le modèle sait désormais où est votre base. Il ne sait pas encore sous quelle identité l'interroger.

1. Dans votre espace de travail, ouvrez les **Paramètres** du modèle `conduite_de_mission`.
2. Dépliez **Data source credentials**. Vous y lisez alors, en clair :
   *« Failed to test the connection to your data source. Please retry your credentials. »*
3. Cliquez **Edit credentials**.
4. Dans **Authentication method**, choisissez **OAuth2**, puis **Sign in**. Votre compte
   professionnel s'affiche : choisissez-le.
5. Recommencez à l'identique pour le modèle `restitution_client`.

Le message d'avertissement sur le chiffrement qui peut apparaître à cette étape n'empêche pas la
connexion de s'établir.

*Vérification :* le message d'échec disparaît de la section **Data source credentials**.

#### Deuxièmement, actualiser le modèle du client

Les deux modèles ne lisent pas la base de la même façon, et cela change ce que vous avez à faire.

| Le modèle | Comment il lit la base | Ce que vous devez faire |
|---|---|---|
| `conduite_de_mission` | Directement, à chaque affichage | Rien. L'écran du réviseur est alimenté dès que la connexion est établie |
| `restitution_client` | Il en garde une copie | L'actualiser, faute de quoi l'écran du client reste vide |

Dans votre espace de travail, sur la ligne du modèle `restitution_client`, choisissez **Actualiser
maintenant**. L'actualisation a pris 20 secondes sur une installation réelle.

Vous referez cette actualisation après chaque publication au client, parce que l'écran du client
affiche l'état de la dernière actualisation et non celui de la base à la seconde près.

*Vérification :* ouvrez l'écran du client. Les pages affichent des valeurs, et non des cases vides.

### Ce que vous devez voir, avant de relier

Ces sorties sont celles d'une installation réelle, recopiées telles quelles. **Les nombres qu'elles
portent sont ceux du jour où elles ont été relevées** : votre version peut en compter davantage, et
ce n'est pas une anomalie. Ce qui compte est la ligne « restant à relier », avant puis après. Elles vous montrent le
point de départ, avant toute intervention.

Le modèle, qui interroge encore la base d'origine :

```
73 source(s) de donnees dans les 2 modeles.
   deja reliees a votre base : 0
   restant a relier          : 73
   sources inconnues         : 0

Source portee par ces tables :
   serveur : <le serveur d'origine>.database.fabric.microsoft.com
   base    : DossierOPCI-<l'identifiant d'origine>
```

Les boutons, qui appellent encore les fonctions d'origine :

```
36 bouton(s) de fonction dans le rapport.
   deja relies a votre espace : 0
   restant a relier           : 36
   identifiants inconnus      : 0

fn_ecran_client, 13 fonction(s) appelee(s) :
   ajouter_filiale
   approuver_acceptation
   creer_client
   ...
fn_ecran_revision, 5 fonction(s) appelee(s) :
   conclure_feuille
   ouvrir_feuille
   ...
```

Regardez la ligne « identifiants inconnus » : elle doit valoir zéro. Si elle ne vaut pas zéro, le
rapport a été modifié à la main, et les scripts refuseront d'écrire.

### Ce que vous devez voir, une fois relié

```
73 source(s) de donnees dans les 2 modeles.
   deja reliees a votre base : 73
   restant a relier          : 0
   sources inconnues         : 0
```

```
36 bouton(s) de fonction dans le rapport.
   deja relies a votre espace : 36
   restant a relier           : 0
   identifiants inconnus      : 0
```

Tant que la ligne « restant à relier » n'est pas à zéro, l'installation n'est pas finie, même si les
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

Ils n'écrivent pas si un fichier contient des identifiants qu'ils ne reconnaissent pas, c'est-à-dire
ni ceux d'origine ni les vôtres. Ce cas signale un rapport ou un modèle modifié à la main, et une
écriture aveugle le casserait. Le script s'arrête alors en nommant le fichier en cause.

Ils ne reformatent rien non plus : ils remplacent le texte des identifiants et laissent le reste
des fichiers intact, afin que vous puissiez relire exactement ce qui a changé.

Relancer un script déjà passé ne fait rien et l'annonce.

---

Suite : [Étape 11. Publier les deux écrans, à deux publics distincts](etape-11-publier-les-applications.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
