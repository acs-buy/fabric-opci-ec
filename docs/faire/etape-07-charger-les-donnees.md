# Étape 7. Charger les données

Vous remplissez la base, puis vous autorisez les fonctions à l'interroger.

## Ce que le dépôt apporte

| Dossier | Contenu | Ce que c'est |
|---|---|---|
| `sql/10_referentiels/` | 41 fichiers, 3 452 lignes | Le socle : questions d'acceptation, plan de comptes, natures de pièces, rôles, articles du règlement |
| `sql/80_demonstration/` | 36 fichiers, 7 152 lignes | Deux véhicules fictifs, leurs filiales, leurs arrêtés, leurs écritures |
| `sql/89_effacer_la_demonstration.sql` | | Le script qui retire la démonstration quand vous passerez à vos dossiers |

Le socle, vous le gardez. Il ne contient aucune donnée de client, seulement des nomenclatures et le
questionnaire d'acceptation.

La démonstration s'efface quand vous n'en avez plus besoin. Les dénominations et les numéros
d'identification y sont fictifs. Elle est là pour que vos écrans aient quelque chose à montrer dès
le premier clic.

## Comment les charger

Dans votre espace de travail, ouvrez la base `DossierOPCI`, puis **Nouvelle requête**.

Le bouton s'appelle **New Query** dans le bandeau de la base. L'explorateur de gauche montre la base
et les requêtes enregistrées.

![L'éditeur de la base, avec le bouton New Query](../../captures/base-nouvelle-requete.png)

Jouez les fichiers **dans l'ordre de leur numéro**, d'abord tout le dossier `10_referentiels`, puis
tout le dossier `80_demonstration`. Les clés étrangères imposent qu'une table soit remplie après
celles dont elle dépend.

Chaque fichier annonce ce qu'il a fait, par exemple :

```
ref_question : 620 ligne(s) chargee(s).
```

Vous pouvez rejouer un fichier sans crainte. Une table ne se remplit que si elle est vide, si bien
qu'un fichier rejoué vous répond « déjà chargée, rien à faire » et ne touche à rien. Vous ne
risquez donc pas de créer des doublons en vous y reprenant à deux fois.

## Vous inscrire aux missions, sans quoi votre écran sera vide

Cette action est obligatoire, et si vous l'oubliez, personne ne vous le dira : aucun message ne
signale le manque. Une installation réelle l'a montré le 26/09/2026.

### Si vous l'oubliez

Le dépôt n'emporte aucune identité. Les colonnes qui disaient qui tient quel rôle portent une valeur
neutre, `installation`, pour qu'aucune adresse de personne ne parte dans un dépôt public. Tant que
vous ne vous y inscrivez pas, l'écran du réviseur reste entièrement vide : la sécurité au niveau des
lignes ne montre à chacun que les entités où il détient un mandat vivant, et aucun mandat ne porte
votre adresse. Vos boutons de visa n'aboutissent pas davantage, la base refusant un visa à qui ne
détient pas un rôle habilité.

### Ce que vous faites

1. Ouvrez `sql/90_vous_inscrire_aux_missions.sql`.
2. Remplacez les **deux adresses** en tête du fichier : la vôtre, puis celle d'un collègue.
3. Jouez le fichier.

Il vous faut vraiment deux comptes. La base refuse l'approbation d'un visa à celui qui l'a soumis,
et avec un seul compte vous ne mènerez aucun dossier jusqu'à son visa.

La base impose aussi l'ordre des rôles, et l'inverser produit un refus.

| Le compte | Le rôle | Pourquoi celui-là |
|---|---|---|
| Vous | `ASSOCIE` | Créer un dossier client écrit dans le référentiel des entités, qui se tient au rôle associé |
| Votre collègue | `CHEF_MISSION` | Ce rôle vise lui aussi, il peut donc approuver ce que vous soumettez |

*Vérification :* le script affiche vos deux adresses avec 16 entités en face de chacune, puis
`mandats encore au nom neutre : 0`.

## Ouvrir la connexion des fonctions à la base

Les fonctions doivent avoir le droit d'interroger la base. Ce droit ne s'installe pas avec les
fichiers, Git ne le transporte pas : vous le donnez au portail.

1. Ouvrez `fn_ecran_client`.
2. Dans le bandeau, **Gérer les connexions**.
3. **Ajouter une connexion de données**, et choisissez votre base `DossierOPCI`.
4. Faites de même pour `fn_ecran_revision`.
5. Publiez chaque ensemble de fonctions, par **Publier**.

Deux points à connaître sur cette publication :

- Elle impose **deux minutes d'attente** entre deux publications successives. Si un message vous le
  signale, attendez et recommencez, rien n'est cassé.
- Seule la personne propriétaire d'un ensemble de fonctions peut le publier. Si vous installez pour
  un cabinet, faites-le donc depuis le compte qui restera responsable de la solution.

## Vérifier

Dans l'écran des fonctions, lancez `qui_suis_je`. Elle doit rendre une réponse contenant votre
identité. Si elle échoue, c'est que la connexion de l'étape précédente n'est pas enregistrée, ou que
la publication n'a pas abouti.

Côté données, cette requête vous dit où vous en êtes :

```sql
SELECT 'questions' AS quoi, COUNT(*) AS nb FROM dbo.ref_question
UNION ALL SELECT 'comptes', COUNT(*) FROM dbo.ref_compte
UNION ALL SELECT 'entites', COUNT(*) FROM dbo.ref_entite;
```

## Quand vous passerez à vos propres dossiers

Jouez `sql/89_effacer_la_demonstration.sql`. Lisez son en-tête d'abord : il dit exactement ce qu'il
supprime, ce qu'il vide entièrement, et pourquoi il vaut mieux le jouer **avant** de saisir vos
premiers dossiers plutôt qu'après.

---

Suite : [Étape 8. Connecter les fonctions à la base](etape-08-connecter-les-fonctions.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
