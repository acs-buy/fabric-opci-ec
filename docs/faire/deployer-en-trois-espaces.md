# Déployer en trois espaces : DEV, TEST et PROD

**Durée :** 45 minutes par déploiement, dont 3 minutes de machine.
**Qui :** vous, contributeur des deux espaces concernés.

Cette page s'intercale entre les étapes numérotées. Elle suppose que vous avez créé trois espaces
à l'étape 3, et que l'installation est finie dans DEV.

Le pourquoi est dans [Trois espaces de travail](../comprendre/09-trois-espaces.md).

---

## Où cela s'intercale

| Quand | Ce que vous faites | Où |
|---|---|---|
| Étapes 1 et 2 | Capacité et réglages, une seule fois | Locataire |
| Étape 3 | Créer les **trois** espaces et le pipeline | Portail |
| Étapes 4 à 10 | Installer la solution | **DEV** |
| **Ici** | **Déployer DEV vers TEST**, puis les cinq actions de remise en service | **TEST** |
| Étape 12 | Passer la recette, et faire passer le cahier de tests | **TEST** |
| **Ici** | **Déployer TEST vers PROD**, puis les mêmes cinq actions | **PROD** |
| Étape 11 | Publier les applications | **PROD** |
| Étape 13 | Provisionner les espaces clients, facultatif | **PROD** |

**L'étape 11 vient après le déploiement en production**, et non avant : une application se publie
depuis l'espace où vivent les dossiers réels.

---

## Créer le pipeline, une seule fois

1. Dans le portail Fabric, volet de gauche, **Espaces de travail**, puis **Pipelines de déploiement**.
2. **Nouveau pipeline**, nommez-le, et gardez les trois étapes proposées.
3. Rattachez un espace à chaque étape : votre espace DEV, votre espace TEST, votre espace PROD.

**Il faut être membre de chaque espace** pour l'y rattacher. Un message le dit si vous ne l'êtes
pas, mais il parle de permissions d'espace, alors que vous regardez un pipeline.

---

## Déployer

1. Ouvrez le pipeline, étape source à gauche.
2. **Sélectionner les éléments** à déployer, ou **Tout déployer**.
3. Employez **Sélectionner les éléments liés** : un rapport déployé sans son modèle fait échouer
   le déploiement.
4. **Déployer**, puis attendez la fin.

---

## Les cinq actions de remise en service, après chaque déploiement

**Aucune n'est facultative, et aucune ne produit d'erreur si vous l'oubliez.** L'écran s'affiche,
et il est vide ou il écrit au mauvais endroit.

### 1. Charger les données

Le pipeline copie la base avec ses tables, ses vues et ses procédures, et **aucune ligne**. Jouez
les fichiers de `sql/` sur la base de l'espace d'arrivée, comme à
[l'étape 7](etape-07-charger-les-donnees.md).

En production, vous ne chargez que `sql/10_referentiels/`. Le jeu de démonstration n'a rien à faire
dans l'espace de vos dossiers réels.

### 2. Vous inscrire aux missions

Jouez `sql/90_vous_inscrire_aux_missions.sql` avec les adresses des personnes qui travailleront
dans cet espace. Sans cela, l'écran du réviseur y est vide.

### 3. Saisir les informations d'identification des deux modèles

Les identifiants ne se copient pas : « Data source credentials » ne fait pas partie de ce qu'un
déploiement transporte. Reprenez la procédure des [étapes 9 et 10](etape-09-et-10-relier.md),
section **Data source credentials**, sur les deux modèles.

Puis actualisez `restitution_client`, qui garde une copie des données.

### 4. Relier les boutons

**C'est celle qu'on oublie, et c'est la plus grave.** Un bouton déployé garde la référence des
fonctions de l'espace d'origine, et il écrit donc dans la base de l'espace d'origine.

```
python scripts/20_relier_les_boutons.py --verifier --espace <celui de l'espace d'arrivée> ...
```

La sortie doit annoncer autant de boutons **restant à relier** qu'il y en a. Reliez-les, puis
envoyez le rapport corrigé dans cet espace.

**Vérifiez avant de laisser quiconque cliquer.** Un bouton mal relié ne dit rien : il écrit
ailleurs.

### 5. Recréer les rôles de sécurité

« Role assignment » ne se copie pas. Recréez un rôle par client dans le modèle `restitution_client`
de cet espace, et affectez-y les comptes, comme à [l'étape 11](etape-11-publier-les-applications.md).

---

## La règle de déploiement, qui vous évite de relier les modèles

Elle fait pointer le modèle de l'espace d'arrivée vers la base de ce même espace, à chaque
déploiement.

1. Dans le pipeline, sur l'étape **d'arrivée**, choisissez **Règles de déploiement**.
2. Sélectionnez le modèle, puis **Règles de source de données**, puis **Ajouter une règle**.
3. Choisissez la source de l'étape précédente, et donnez la base de l'étape d'arrivée.
4. Recommencez pour le second modèle.
5. **Redéployez** : une règle ne s'applique qu'au déploiement suivant sa création.

**Une seule règle par modèle suffit**, chacun ne déclarant qu'une source.

**Deux choses peuvent vous arrêter**, et elles sont écrites dans la documentation de l'éditeur :
il faut être **propriétaire** du modèle pour créer la règle, faute de quoi l'option est grisée ;
et une règle de source ne s'applique pas à un modèle dont la source est une fonction Power Query.

---

## Ce que vous devez voir, dans l'espace d'arrivée

| Ce que vous ouvrez | Ce que vous devez voir |
|---|---|
| La base | Les comptes de contrôle de `99_terminer_le_chargement.sql`, tous conformes |
| L'écran du réviseur | Vos dossiers, et non un écran vide |
| Un bouton qui écrit | La ligne apparue **dans la base de cet espace**, et non dans celle de DEV |
| L'écran du client | Des valeurs, après actualisation du modèle |

---

## Corriger un défaut trouvé en TEST

**Corrigez dans DEV, puis redéployez.** Le déploiement arrière n'est possible que vers une étape
vide, et une correction faite directement dans TEST serait écrasée au déploiement suivant.

---

Suite : [Le cahier de tests, à faire passer dans l'espace TEST](cahier-de-tests.md)

[Revenir au sommaire](../../README.md) · [Comprendre les trois espaces](../comprendre/09-trois-espaces.md)
