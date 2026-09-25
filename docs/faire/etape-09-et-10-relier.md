# 6. Relier la solution à votre espace de travail

C'est l'étape la plus importante de l'installation. Sans elle, les éléments sont chez vous mais
rien ne fonctionne, et la cause est invisible à l'écran.

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

Les 72 tables du modèle sémantique lisent la base directement, et chacune porte en clair le nom du
serveur SQL et le nom de la base. L'éditeur donne cette liaison pour non reconstruite lors d'un
déploiement entre espaces de travail : « Semantic models vers SQL database : No. The connection
string in TMDL expressions contains workspace-specific values. »

**Sans réparation :** le modèle ne s'actualise pas, ou interroge une base à laquelle vous n'avez
pas accès. Aucun écran ne s'affiche.

### Les boutons appellent encore les fonctions d'origine

Les 24 boutons qui écrivent en base portent, en clair, l'identifiant de l'espace de travail et
celui de l'ensemble de fonctions qu'ils appellent. L'éditeur l'écrit ainsi : « Data function
buttons don't automatically rebind across workspaces. The button stores an explicit reference to a
specific Workspace, Function set, and Data function. »

**Sans réparation :** vos boutons appellent l'espace de travail d'origine. Ou bien ils ne font
rien, ou bien ils écrivent au mauvais endroit. Les deux sont mauvais.

## Ce qui se recolle tout seul

La liaison du rapport vers son modèle sémantique se refait seule, parce que le rapport désigne son
modèle par un chemin relatif et non par un identifiant. **À une condition : ne renommez aucun
élément.** Un renommage casse cette liaison, et le message d'erreur ne dit pas pourquoi.

## Comment faire

### Relever vos cinq valeurs

Ouvrez un terminal dans le dossier du dépôt et lancez :

```
python scripts/00_mes_identifiants.py
```

Le script vous demande de coller cinq choses et vérifie leur forme au passage. Il ne se connecte
à rien et ne demande aucun mot de passe.

1. **L'adresse de votre espace de travail.** Ouvrez-le dans le navigateur, copiez l'adresse entière.
2. **L'adresse de votre élément `fn_ecran_client`.** Ouvrez-le, copiez l'adresse. Attention, elle
   porte deux identifiants : celui de l'espace d'abord, celui de l'élément ensuite. Le script
   retient le second, qui est le bon.
3. **L'adresse de votre élément `fn_ecran_revision`.** Le rapport appelle deux ensembles de
   fonctions, un par écran. Sans celui-ci, 7 boutons de l'écran de révision resteraient sans effet.
4. **Le serveur SQL de votre base.** Ouvrez la base `DossierOPCI`, bandeau **Paramètres**, puis
   **Chaînes de connexion**.
5. **Le nom complet de votre base.** Sur la même page. Il porte un identifiant après `DossierOPCI`,
   ce qui est normal. Ne recopiez pas le nom affiché dans la liste des éléments : ce n'est pas
   celui-là.

À la fin, le script affiche les deux commandes à lancer, et les écrit aussi dans un fichier.

### Relier le modèle, puis les boutons

**L'ordre compte.** Le modèle d'abord, les boutons ensuite. Actualiser le modèle avant de l'avoir
relié produit une erreur qui fait croire à une panne de la solution.

```
python scripts/25_relier_le_modele.py --serveur <le vôtre> --base <la vôtre>

python scripts/20_relier_les_boutons.py --espace <le vôtre> --fn-ecran-client <le vôtre> --fn-ecran-revision <le vôtre>
```

Le script `00_mes_identifiants.py` a déjà écrit ces deux lignes complètes, avec vos valeurs, dans le
fichier `mes_commandes.txt`. Vous pouvez les copier de là.

Chaque script dit combien d'éléments il a traités, puis relit son travail pour le confirmer.
Envoyez ensuite les modifications à votre dépôt GitHub, et dans Fabric, faites **Mettre à jour
tout** une seconde fois.

### Vérifier

```
python scripts/25_relier_le_modele.py --verifier
python scripts/20_relier_les_boutons.py --verifier
```

Vous devez lire 72 sources reliées et 24 boutons reliés, et zéro restant.

## Ce que les scripts refusent de faire

Ils n'écrivent pas si un fichier porte des identifiants qu'ils ne reconnaissent pas, c'est-à-dire ni
ceux d'origine ni les vôtres. Ce cas signale un rapport ou un modèle modifié à la main, et une
écriture aveugle le casserait. Le script s'arrête alors en nommant le fichier en cause.

Ils ne reformatent rien non plus : ils remplacent le texte des identifiants et laissent le reste
des fichiers intact, afin que vous puissiez relire exactement ce qui a changé.

Relancer un script déjà passé ne fait rien et l'annonce.

Suite : [7. Publier l'application](etape-11-publier-les-applications.md)
