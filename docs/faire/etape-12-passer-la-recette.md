# Étape 12. La recette : douze actions qui prouvent que la solution marche

Les douze actions ci-dessous vont du clic sur un bouton jusqu'à l'écriture dans la base. Faites-les
dans l'ordre, chacune prépare la suivante. Si elles aboutissent toutes, votre installation est bonne.

| # | L'action à faire | Où | Ce que vous devez obtenir |
|---|---|---|---|
| 1 | Créer un dossier client | Section Dossier, sous-état Nouveau dossier | Le dossier apparaît, et son questionnaire d'acceptation s'ouvre seul |
| 2 | Modifier les informations du client | Sous-état Modifier | La valeur change, et un champ que vous laissez vide garde son ancien contenu |
| 3 | Enregistrer le site du client | Même formulaire | Le lien devient cliquable dans la fiche |
| 4 | Ajouter une filiale | Section Filiales | La filiale apparaît dans le périmètre |
| 5 | Modifier une filiale | Section Filiales | Le changement est tracé au journal du périmètre |
| 6 | Supprimer une filiale | Section Filiales | Un refus motivé si la filiale porte des données de mission |
| 7 | Répondre à une question | Section Questionnaire | La réponse est enregistrée au clic, sans bouton de validation |
| 8 | Déposer une pièce | Section Questionnaire | La pièce apparaît avec sa nature, sa date et son déposant |
| 9 | Retirer une pièce | Section Questionnaire | Motif obligatoire, refus si la pièce fonde une donnée |
| 10 | Soumettre au visa | Section Visa | Le dossier passe en attente d'approbation |
| 11 | Approuver le visa | Section Visa, **avec un second compte** | Le compte qui a soumis est refusé, l'autre passe |
| 12 | Ouvrir un arrêté | Section Arrêtés | L'arrêté planifié devient ouvert |

## L'action 11 mérite une explication

L'approbation est refusée à la personne qui a soumis le dossier. C'est la séparation des fonctions :
celui qui prépare l'acceptation ne la décide pas. Le contrôle est écrit dans la base, et pas
seulement dans l'écran, si bien qu'un utilisateur qui contournerait l'écran recevrait le même refus.

Pour l'éprouver, il vous faut deux comptes, et le second doit avoir un rôle sur le dossier. La
désignation se fait sur l'écran lui-même, section **Équipe de la mission**.

## Où se font ces actions

> Les images qui suivent sont des **maquettes de conception**, et non des captures d'écran :
> l'écran de conduite est encore en construction. Elles montrent la structure retenue, qui ne
> bougera plus, mais l'écran publié peut différer dans le détail.

**Actions 1 à 3, le dossier.**

![Le formulaire de création d'un dossier](../../captures/maquettes/nouveau-dossier.png)

**Actions 4 à 6, les filiales.** À l'action 6, la suppression doit vous être refusée, avec le motif,
si la filiale porte des données de mission.

![Le refus motivé d'une suppression de filiale](../../captures/maquettes/filiales-suppression-refusee.png)

**Actions 7 à 9, le questionnaire et les pièces.**

![La grille des questions et les pièces](../../captures/maquettes/questionnaire-et-pieces.png)

**Actions 10 et 11, le visa.**

![La soumission au visa et son approbation](../../captures/maquettes/visa.png)

**Action 12, les arrêtés.**

![Les arrêtés de l'exercice](../../captures/maquettes/arretes.png)

## Ce qu'un échec vous apprend

| Symptôme | Cause la plus probable |
|---|---|
| Le bouton ne fait rien | L'étape 6 n'est pas faite, les boutons appellent encore l'espace d'origine |
| « Fonction introuvable » | La connexion de l'étape 5 n'est pas faite, ou la publication n'a pas abouti |
| L'écran est vide | Les données de l'étape 5 ne sont pas chargées |
| Aucun visuel ne s'affiche | Le modèle n'est pas relié, étape 6, premier script |
| « Écriture refusée : rôle » | Votre compte n'a aucun rôle sur ce dossier. C'est le comportement attendu |

Chacune de ces causes est reprise en détail dans la page [9. Dépannage](depannage.md).

## Garder une trace

Notez la date de votre recette et le résultat des douze actions. Le jour où vous adapterez la
solution, cette liste vous dira ce qui marchait avant votre modification.

---

## L'action 11 a été éprouvée, et voici ce que la base répond

Nous l'avons rejouée le 26/09/2026 sur une installation neuve. Les deux messages sont recopiés
tels quels.

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

Une fois les deux conditions remplies, le second compte approuve, et la ligne d'acceptation passe à
`APPROUVE`, avec deux adresses différentes en `cree_par` et `approuve_par`.

Ces deux refus sont écrits dans la base de données, et pas seulement dans l'écran. Un utilisateur
qui appellerait directement une fonction, sans passer par le bouton, recevrait le même message.

---

C'est la dernière étape du parcours. Si les douze actions aboutissent, votre installation est bonne.

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
