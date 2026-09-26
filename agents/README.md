# Reproduire avec l'aide d'un agent

**Lisez d'abord [AVERTISSEMENT.md](AVERTISSEMENT.md).** Il porte le partage des
responsabilités et les règles professionnelles que ce dossier ne lève pas.

---

## Ce qu'un agent fait, et ce qu'il ne fait pas

La reproduction compte 12 étapes. Un agent n'en exécute pas 12.

| Étapes | Nature | Ce que l'agent apporte |
|---|---|---|
| 1, 2, 3, 5, 6, 8, 11 | Gestes au portail Fabric | Rien à votre place. Il vous lit la marche à suivre, vous dit quoi vérifier, et note ce qui bloque |
| 4 | Cloner le dépôt, vérifier Python | **Il l'exécute** |
| 7 | Charger les données SQL | Il prépare et ordonne les scripts. **C'est vous qui les jouez au portail** |
| 9, 10 | Réécrire 73 sources et 36 boutons | **Il l'exécute**, et vérifie le résultat |
| 12 | Recette de 12 actions à l'écran | Il tient la liste et relève ce qui échoue. **Les clics sont les vôtres** |

**Compte honnête : 3 étapes exécutées sur 12.** Le reste est un accompagnement. Les 5 valeurs
d'identification se relèvent au portail, à l'œil, et personne ne peut le faire pour vous.

**Aucun des 4 scripts du dépôt ne se connecte à quoi que ce soit.** Ils réécrivent des fichiers
locaux et affichent du texte. Un agent qui les lance n'accède donc ni à votre locataire, ni à
votre base, ni à vos données.

---

## Les 3 invites

Elles se collent dans l'agent l'une après l'autre, jamais toutes ensemble. Chacune finit par un
point d'arrêt où vous vérifiez avant de passer à la suivante.

| Fichier | Couvre | Vous devrez fournir |
|---|---|---|
| [`01-preparation.md`](01-preparation.md) | Étapes 1 à 8 | L'adresse de votre dépôt forké |
| [`02-liaisons.md`](02-liaisons.md) | Étapes 9 et 10 | Les 5 valeurs relevées au portail |
| [`03-recette.md`](03-recette.md) | Étape 12 | Un second compte, pour l'action 11 |

---

## Autorisations

[`permissions-exemple.json`](permissions-exemple.json) donne un jeu minimal pour un agent de
codage, avec le motif de chaque ligne. **C'est un point de départ à réduire.** Deux règles :

1. **Aucune autorisation d'écriture hors du dépôt cloné.** Un agent n'a rien à faire ailleurs
   sur votre poste.
2. **Aucun accès à vos identifiants Fabric ou GitHub.** Le jeton GitHub de l'étape 5 se colle
   dans l'écran de Fabric, par vous, jamais dans une conversation avec un agent.

---

## Avant de commencer, ce qu'il vous faut

| Prérequis | Détail |
|---|---|
| Capacité Fabric | **F4 minimum**, ou l'essai gratuit de 60 jours qui ouvre exactement F4 |
| 5 réglages de locataire | À faire activer par votre administrateur, étape 2 |
| Licences | Sous F64, une licence Pro par personne qui ouvre un écran, **vos clients compris** |
| Sur le poste | Un navigateur, Python 3, git, un compte GitHub gratuit |
| Comptes | Un administrateur d'espace de travail, et **un second compte** pour l'action 11 |

---

## Réserve sur l'état du dépôt

`_outils/NOTE_FORMAT_BASE.md` signale que la base SQL est publiée sous forme de `dacpac`
binaire, alors que la synchronisation Git attend une arborescence de fichiers `.sql`. **L'étape
6 peut donc échouer sur la base**, et le mode opératoire n'a pas encore été rejoué de bout en
bout sur un environnement neuf. Un agent ne corrigera pas cela : si l'étape 6 ne ramène pas les
tables, c'est un défaut connu du dépôt, pas une erreur de votre part.
