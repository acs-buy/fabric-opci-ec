# Étape 13. La recette : douze actions qui prouvent que la solution marche

Ces douze actions parcourent la chaîne complète, du clic jusqu'à l'écriture en base. Si elles passent
toutes, votre installation est bonne.

**L'étape 12 doit être faite avant.** L'action 8 dépose un fichier dans le site SharePoint du client :
sans ce site, le bouton de dépôt n'a pas d'adresse.

Faites-les dans l'ordre : chacune prépare la suivante.

| # | L'action à faire | Où | Ce que vous devez obtenir |
|---|---|---|---|
| 1 | Créer un dossier client | Section Dossier, sous-état Nouveau dossier | Le dossier apparaît, et son questionnaire d'acceptation s'ouvre seul |
| 2 | Modifier les informations du client | Sous-état Modifier | La valeur change, un champ laissé vide reste inchangé |
| 3 | Enregistrer le site du client | Même formulaire | Le lien devient cliquable dans la fiche |
| 4 | Ajouter une filiale | Section Filiales | La filiale entre au périmètre |
| 5 | Modifier une filiale | Section Filiales | Le changement est tracé au journal du périmètre |
| 6 | Supprimer une filiale | Section Filiales | Refus motivé si la filiale porte des données de mission |
| 7 | Répondre à une question | Section Questionnaire | La réponse est enregistrée au clic, sans bouton de validation |
| 8 | Déposer une pièce | Page Pièce justificative | Le bouton ouvre la bibliothèque « Dépôt du client » ; une fois le fichier déposé et son nom tapé, « Rattacher la pièce » l'inscrit avec sa nature, sa date, son déposant et son lien |
| 9 | Retirer une pièce | Section Questionnaire | Motif obligatoire, refus si la pièce fonde une donnée |
| 10 | Soumettre au visa | Section Visa | Le dossier passe en attente d'approbation |
| 11 | Approuver le visa | Section Visa, **avec un second compte** | Refusé au compte qui a soumis, accepté à l'autre |
| 12 | Ouvrir un arrêté | Section Arrêtés | L'arrêté planifié devient ouvert |

## Où se font ces actions

> Les images qui suivent sont des **maquettes de conception**, et non des captures d'écran :
> l'écran de conduite est en cours de pose. Elles montrent la structure retenue, qui ne bougera
> plus. L'écran publié peut différer dans le détail.

**Actions 1 à 3, le dossier.**

![Le formulaire de création d'un dossier](../../captures/maquettes/nouveau-dossier.png)

**Actions 4 à 6, les filiales.** L'action 6 doit rendre un refus motivé si la filiale porte des
données de mission.

![Le refus motivé d'une suppression de filiale](../../captures/maquettes/filiales-suppression-refusee.png)

**Actions 7 à 9, le questionnaire et les pièces.**

![La grille des questions et les pièces](../../captures/maquettes/questionnaire-et-pieces.png)

**Actions 10 et 11, le visa.**

![La soumission au visa et son approbation](../../captures/maquettes/visa.png)

**Action 12, les arrêtés.**

![Les arrêtés de l'exercice](../../captures/maquettes/arretes.png)

---

L'approbation est refusée à la personne qui a soumis le dossier. C'est la séparation des fonctions,
portée par la base. Un utilisateur qui
contournerait l'écran se verrait opposer le même refus.

Pour l'éprouver, il vous faut deux comptes, et le second doit porter un rôle sur le dossier. La
désignation se fait sur l'écran lui-même, section **Équipe de la mission**.

## Ce qu'un échec vous apprend

| Symptôme | Cause |
|---|---|
| Le bouton ne fait rien | L'étape 10 n'est pas faite, les boutons appellent encore l'espace d'origine |
| « Fonction introuvable » | La connexion de l'étape 8 n'est pas posée, ou la publication n'a pas abouti |
| L'écran est vide | Les données de l'étape 7 ne sont pas chargées |
| Aucun visuel ne s'affiche | Le modèle n'est pas relié, étape 9 |
| Le bouton de dépôt d'une pièce ne mène nulle part | Le site du client n'existe pas, étape 12 |
| « Écriture refusée : rôle » | Votre compte ne porte aucun rôle sur ce dossier. C'est le comportement attendu |

La page [Dépannage](depannage.md) reprend chacune de ces causes en détail.

## Garder une trace

Notez la date de votre recette et le résultat des douze actions. Si vous adaptez la solution plus
tard, cette liste vous dira ce qui marchait avant votre modification.

---

## Les messages que vous devez lire, action par action

Les douze actions ont été jouées le 26/09/2026 sur une installation neuve. Les phrases ci-dessous
sont celles que la solution rend, recopiées telles quelles. **Si vous lisez autre chose, l'action
n'a pas produit ce qu'elle devait produire.**

| # | L'action | Ce que vous devez lire |
|---|---|---|
| 1 | Créer un dossier client | `Client <code> créé, vous en êtes le chef de mission. Questionnaire d'acceptation ouvert : 110 questions.` |
| 2 | Modifier le client | `Informations de <code> mises à jour. Le code du client ne change pas.` |
| 3 | Enregistrer le site | `Site SharePoint de <code> enregistré.` |
| 4 | Ajouter une filiale | `Filiale <code> ajoutée au périmètre de <client>. Sa balance sera réclamée à la révision.` |
| 5 | Modifier une filiale | `Filiale <code> mise à jour : droits de vote → 60,00 %.` |
| 6 | Supprimer une filiale | `Filiale <code> (<dénomination>) retirée du périmètre de <client>.` |
| 8 | Déposer une pièce | `Pièce « <nom> » inscrite au dossier de <code>.` |
| 9 | Retirer une pièce | `Pièce « <nom> » retirée du dossier de <code>. Le fichier reste dans SharePoint ; le retrait est tracé.` |
| 12 | Ouvrir un arrêté | L'arrêté passe de planifié à ouvert, et un second essai est refusé |

### Trois refus que vous devez provoquer, et qui prouvent les contrôles

| Ce que vous tentez | Le refus attendu |
|---|---|
| Retirer une pièce sans motif | `Le motif du retrait est obligatoire : il reste dans la trace du dossier.` |
| Saisir des droits de vote à 75 | `Les droits de vote se donnent entre 0 et 1, par exemple 0,80 pour 80 %.` |
| Enregistrer un site qui n'est pas un site SharePoint | `Le lien attendu est celui du site SharePoint de l'équipe Teams, de la forme https://<cabinet>.sharepoint.com/sites/<nom>.` |

Chacun de ces trois messages vient de la base, et il tiendrait
même si l'écran était contourné.

### Ce qui n'a pas été éprouvé, et qu'il faut savoir

**Les messages des actions 8 et 9 ont changé le 28/09/2026**, quand les fichiers sont passés du
coffre à SharePoint. Le texte ci-dessus est celui que la base rend depuis, relevé ce jour-là ; le
parcours complet de l'action 8, dépôt puis rattachement, a été éprouvé au clic le 28/09/2026 sur
l'installation d'origine, pas encore sur une installation neuve.

**Le refus de suppression d'une filiale qui porte des données.** Lors de l'essai, la filiale créée
pour l'occasion ne portait ni écriture ni pièce : elle a donc été supprimée sans refus, ce qui est
le comportement attendu dans ce cas. Pour éprouver le refus, supprimez une filiale du jeu de
démonstration qui porte des écritures.

---

## L'action 11, et ce que la base répond

Rejouée le 26/09/2026 sur une installation neuve. Les deux messages sont recopiés tels quels.

**Quand celui qui a préparé l'acceptation tente de l'approuver :**

```
Approbation refusée : l'acceptation a été proposée par la même personne. La décision
d'accepter une mission se prend par un autre que celui qui l'a préparée. Faire approuver
par l'associé signataire.
```

**Quand le questionnaire n'est pas complet, l'approbation est refusée avant même le visa :**

```
Approbation refusée : 92 question(s) obligatoire(s) du questionnaire d'acceptation sont
sans réponse. La première est ACCEPT-01, « L'entité pour laquelle la mission est envisagée
est-elle un organisme de placement collectif immobilier régi par le code ». Répondre à
toutes les questions obligatoires, puis approuver.
```

**Une fois les deux conditions remplies**, le second compte approuve, et la ligne d'acceptation
porte alors `APPROUVE`, avec les deux adresses distinctes en `cree_par` et `approuve_par`.

**Ces refus viennent de la base.** Un utilisateur qui appellerait directement une
fonction, sans passer par le bouton, recevrait le même refus.

**C'est la dernière étape.** Si les douze actions aboutissent, votre installation est bonne.

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
