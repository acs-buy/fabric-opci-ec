# Étape 7. Charger les données

Ici, vous remplissez la base. La connexion des fonctions se vérifie à l'étape suivante.

## Ce que le dépôt apporte

| Dossier | Contenu | Ce que c'est |
|---|---|---|
| `sql/10_referentiels/` | 46 fichiers, 3 543 lignes | Le socle : questions d'acceptation, plan de comptes, natures de pièces, rôles, articles du règlement |
| `sql/80_demonstration/` | 36 fichiers, 3 719 lignes | Deux véhicules fictifs, leurs filiales, leurs arrêtés, leurs écritures |
| `sql/89_effacer_la_demonstration.sql` | | Le script qui retire la démonstration quand vous passerez à vos dossiers |

**Le socle est ce que vous gardez.** Il ne contient aucune donnée de client : ce sont des
nomenclatures et le questionnaire d'acceptation.

**La démonstration est ce que vous pouvez effacer.** Les dénominations et les numéros
d'identification y sont fictifs. Elle existe pour que vos écrans aient quelque chose à montrer dès
le premier clic.

## Comment les charger

Dans votre espace de travail, ouvrez la base `DossierOPCI`, puis **Nouvelle requête**.

Le bouton s'appelle **New Query** dans le bandeau de la base. L'explorateur de gauche montre la base
et les requêtes enregistrées.

![L'éditeur de la base, avec le bouton New Query](../../captures/base-nouvelle-requete.png)

Jouez les fichiers **dans l'ordre de leur numéro**, et dans cet ordre-ci :

1. `sql/00_preparer_le_chargement.sql`, qui suspend les déclencheurs et les clés étrangères le temps
   du chargement. Sans lui, la plupart des fichiers de données sont refusés.
2. Tout le dossier `10_referentiels`, par numéro croissant : `9_` avant `10_`, et `100_` après `99_`.
3. Tout le dossier `80_demonstration`, de même.
4. `sql/99_terminer_le_chargement.sql`, qui rétablit les clés étrangères en contrôlant les données
   chargées, réactive les déclencheurs et compte ce qui est en place. Ses 2 premiers comptes
   doivent valoir 0.

Les clés étrangères imposent qu'une table soit remplie après celles dont elle dépend.

Chaque fichier annonce ce qu'il a fait, par exemple :

```
ref_question : 620 ligne(s) chargee(s).
```

**Les scripts sont rejouables.** Une table ne se remplit que si elle est vide. Si vous rejouez un
fichier, il vous répond « déjà chargée, rien à faire » et ne touche à rien. Vous ne risquez donc pas
de créer des doublons en vous y reprenant à deux fois.

## Vous inscrire aux missions, sans quoi votre écran sera vide

**Cette action est obligatoire, et son oubli ne produit aucun message.** Il a été trouvé par une
installation réelle le 26/09/2026.

### Ce qui se passe si vous l'oubliez

Le dépôt n'emporte aucune identité. Les colonnes qui disaient qui tient quel rôle portent une valeur
neutre, `installation`, pour qu'aucune adresse de personne ne parte dans un dépôt public. Tant que
vous ne vous y inscrivez pas :

| Ce que vous constatez | La cause, dans la base |
|---|---|
| L'écran du réviseur est **entièrement vide** | La sécurité au niveau des lignes ne montre à chacun que les entités où il détient un mandat vivant. Aucun mandat ne porte votre adresse |
| Aucun bouton de visa n'aboutit | La base refuse un visa à qui ne détient pas un rôle habilité |

### Ce que vous faites

1. Ouvrez `sql/90_vous_inscrire_aux_missions.sql`.
2. Remplacez les **deux adresses** en tête du fichier : la vôtre, puis celle d'un collègue.
3. Jouez le fichier.

**Deux comptes sont nécessaires.** La base refuse l'approbation d'un visa à
celui qui l'a soumis. Avec un seul compte, vous ne pouvez mener aucun dossier jusqu'à son visa.

**L'ordre des rôles est imposé par la base**, et l'inverser produit un refus :

| Le compte | Le rôle | Pourquoi celui-là |
|---|---|---|
| Vous | `ASSOCIE`, et `PREPARATEUR` | Créer un dossier client écrit dans le référentiel des entités, qui se tient au rôle associé |
| Votre collègue | `CHEF_MISSION` | Ce rôle vise lui aussi, il peut donc approuver ce que vous soumettez |

*Vérification :* le script affiche vos deux adresses avec 16 entités en face de chacune, puis
`mandats encore au nom neutre : 0`.

## La connexion des fonctions à la base

Elle se vérifie à l'étape 8, ensemble de fonctions par ensemble de fonctions, avec leurs
bibliothèques et leur publication.

**Deux contraintes :**

- La publication impose **deux minutes d'attente** entre deux publications successives. Si un
  message vous le signale, attendez et recommencez.
- **Seule la personne propriétaire d'un ensemble de fonctions peut le publier.** Si vous installez
  pour un cabinet, faites-le depuis le compte qui restera responsable de la solution.

## Vérifier

Cette requête vous dit où en sont les données :

```sql
SELECT 'questions' AS quoi, COUNT(*) AS nb FROM dbo.ref_question
UNION ALL SELECT 'comptes', COUNT(*) FROM dbo.ref_compte
UNION ALL SELECT 'entites', COUNT(*) FROM dbo.ref_entite;
```

## Quand vous passerez à vos propres dossiers

Jouez `sql/89_effacer_la_demonstration.sql`. Il supprime les 16 entités de démonstration et les
lignes qui s'y rattachent, dans 81 tables, dont une seule du socle, `ref_ratio_vehicule`. Il ne vide
aucune table entièrement : les lignes de vos propres dossiers restent en place, que vous le jouiez
avant ou après les avoir saisies. Son en-tête décrit les 14 tables qu'il ne touche pas, et le rôle
qu'il demande : un compte qui porte le rôle d'associé sur les dossiers.

---

Suite : [Étape 8. Connecter les fonctions à la base](etape-08-connecter-les-fonctions.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
