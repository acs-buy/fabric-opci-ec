# Reproduire avec l'aide d'un agent

[AVERTISSEMENT.md](AVERTISSEMENT.md) dit qui répond de quoi. Les règles professionnelles
s'appliquent ici comme sur n'importe quel dossier, et rien de ce répertoire ne vous en dispense.

---

## Ce qu'un agent fait, et ce qu'il ne fait pas

La reproduction compte 12 étapes. Un agent n'en exécute pas 12.

| Étapes | Nature | Ce que l'agent apporte |
|---|---|---|
| 1, 2, 3, 5, 6, 8, 11 | À faire au portail, à la souris | Il ne fait rien à votre place. Il vous lit la marche à suivre et vous dit ce qu'il faut contrôler, en notant ce qui coince |
| 4 | Cloner le dépôt, vérifier Python | Il l'exécute |
| 7 | Charger les données SQL | Il prépare les scripts et les met dans l'ordre. Vous les jouez au portail vous-même |
| 9, 10 | Réécrire les sources du modèle et les boutons du rapport | Il l'exécute, puis il contrôle le résultat |
| 12 | Recette de 12 actions à l'écran | Il tient la liste et note ce qui échoue. Les clics sont les vôtres |

Au total, l'agent exécute 3 étapes sur 12. Sur les autres, il vous accompagne. Les cinq valeurs
d'identification se lisent à l'écran du portail, et personne ne peut les lire à votre place.

Les quatre scripts du dépôt ne se connectent à rien. Ils réécrivent des fichiers sur votre poste
et affichent du texte. Un agent qui les lance n'entre donc ni dans votre locataire, ni dans votre
base, ni dans vos données.

---

## Les 3 invites

Collez-les dans l'agent l'une après l'autre, jamais toutes ensemble. Chacune s'arrête sur un
point de contrôle : vous vérifiez, puis vous passez à la suivante.

| Fichier | Couvre | Vous devrez fournir |
|---|---|---|
| [`01-preparation.md`](01-preparation.md) | Étapes 1 à 8 | L'adresse de votre dépôt forké |
| [`02-liaisons.md`](02-liaisons.md) | Étapes 9 et 10 | Les cinq valeurs lues au portail |
| [`03-recette.md`](03-recette.md) | Étape 12 | Un second compte, pour l'action 11 |

---

## Autorisations

[`permissions-exemple.json`](permissions-exemple.json) donne un jeu minimal pour un agent de
codage, avec le motif de chaque ligne. Prenez-le comme un point de départ et retirez-en tout ce
dont vous n'avez pas l'usage. Deux limites ne se discutent pas.

L'agent n'écrit nulle part ailleurs que dans le dépôt cloné. Il n'a aucune raison d'aller toucher
au reste de votre poste, et une autorisation large est une autorisation que plus personne ne
surveille.

L'agent n'accède ni à vos identifiants Fabric, ni à ceux de GitHub. Le jeton GitHub de l'étape 5,
vous le collez vous-même dans l'écran de Fabric. Une fois collé dans une conversation avec un
agent, un jeton a quitté votre contrôle.

---

## Avant de commencer, ce qu'il vous faut

| Prérequis | Détail |
|---|---|
| Capacité Fabric | F4 au minimum. L'essai gratuit de 60 jours ouvre exactement F4 |
| Réglages de locataire | Cinq réglages, à faire activer par votre administrateur, à l'étape 2 |
| Licences | Sous F64, une licence Pro par personne qui ouvre un écran, vos clients compris |
| Sur le poste | Un navigateur, Python 3, git, un compte GitHub gratuit |
| Comptes | Un administrateur d'espace de travail, et un second compte pour l'action 11 |

---

## Réserve sur l'état du dépôt

`_outils/NOTE_FORMAT_BASE.md` signale que la base SQL est publiée sous forme de `dacpac` binaire,
alors que la synchronisation Git attend une arborescence de fichiers `.sql`. L'étape 6 peut donc
échouer sur la base. Le mode opératoire n'a pas encore été rejoué de bout en bout sur un
environnement neuf. Un agent ne corrigera pas cela : si l'étape 6 ne ramène pas les tables, c'est
un défaut connu du dépôt, et non une erreur de votre part.
