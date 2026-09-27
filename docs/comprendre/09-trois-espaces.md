# 9. Trois espaces de travail, et un pipeline entre eux

Vous pouvez installer la solution dans un seul espace de travail. Cette page explique pourquoi un
cabinet qui l'exploite vraiment en tient trois, et ce que cela change.

---

## Pourquoi trois

Un seul espace mélange trois usages qui ne vont pas ensemble.

| L'espace | Ce qu'on y fait | Qui y entre |
|---|---|---|
| **DEV** | Reproduire, corriger, essayer | Vous, et qui installe |
| **TEST** | Faire essayer la solution à vos collaborateurs | Votre équipe, sur un jeu fictif |
| **PROD** | Les dossiers réels de vos clients | Votre équipe, et vos clients |

**Le motif tient à la donnée.** Dès qu'un dossier réel entre dans la solution, vous ne pouvez plus
y faire d'essai : chaque clic sur un bouton écrit en base, et la base ne distingue pas un essai
d'un acte professionnel.

**Cela ne coûte rien de plus.** Un espace de travail ne se facture pas : c'est la capacité qui se
facture, et les trois espaces tiennent sur la même.

**Mesuré le 27/09/2026 :** trois espaces portant la solution coexistaient sur une seule capacité,
avec 65 éléments en tout. C'était une capacité d'essai F64. **Sur une F4, le minimum de la
solution, cette cohabitation n'a pas été mesurée** : si vous installez sur F4, surveillez votre
consommation après le second espace.

---

## Ce que le pipeline vous évite, et ce qu'il ne vous évite pas

Un pipeline de déploiement copie les éléments d'un espace vers le suivant. Les douze étapes
d'installation ne se refont donc pas. Mais il copie les **définitions**, et rien d'autre.

### Ce qu'il copie

| Ce qui passe | Ce que cela veut dire |
|---|---|
| Les éléments, tous nos types étant supportés | La base avec ses tables, le coffre, les fonctions, les modèles, les rapports |
| Les visuels et les pages des rapports | L'écran arrive complet |
| Les métadonnées du modèle | Mesures, relations, formats |
| Le lien entre le rapport et son modèle | L'éditeur appelle cela l'autobinding |

### Ce qu'il ne copie pas, et qui est à refaire dans chaque espace

C'est la même leçon qu'à l'installation : **la forme voyage, le contenu et les branchements
restent.**

| Ce qui ne passe pas | Ce que vous refaites | Combien de temps |
|---|---|---|
| **Les données** : « Data isn't copied. Only metadata is copied » | Rejouer les fichiers de `sql/` | 98 s de machine |
| **Les informations d'identification** des sources | Les ressaisir sur les deux modèles, en OAuth2 | 5 min |
| **Les rôles de sécurité** par client | Les recréer et y affecter les comptes | Selon le nombre de clients |
| **Les autorisations** de l'espace et de l'application | Les poser selon le tableau plus bas | 10 min |
| **Les boutons vers les fonctions** | Rejouer `scripts/20_relier_les_boutons.py` | 61 s |

### Le point des boutons, qui surprend

On pourrait croire qu'un pipeline, qui sait relier un rapport à son modèle, sait aussi relier un
bouton à sa fonction. L'éditeur écrit le contraire :

> « Data function buttons don't automatically rebind across workspaces. The button stores an
> explicit reference to a specific Workspace, Function set, and Data function. **When you deploy
> the report with deployment pipelines** or move it to another workspace, the reference stays
> pinned to the original user data function, even if a function with the same name exists in the
> target workspace. »

**Un bouton déployé vers TEST appelle donc toujours les fonctions de DEV**, et il écrit dans la
base de DEV. Aucune erreur n'apparaît : l'écran répond normalement, et les lignes partent au
mauvais endroit.

Le script du dépôt le corrige en une commande, et le vérifie.

---

## Ce que le pipeline vous fait gagner pour les modèles

Une **règle de déploiement** fait pointer le modèle de chaque espace vers la base de ce même
espace, automatiquement, à chaque déploiement.

**Une seule règle par modèle suffit.** Les deux modèles ne déclarent qu'une seule source chacun,
malgré leurs 73 tables : le modèle du client la déclare une fois dans une expression partagée, et
le modèle de conduite répète le même serveur et la même base dans chaque partition.

Cette règle remplace `scripts/25_relier_le_modele.py` pour les déploiements suivants. **Elle reste
à éprouver dans votre installation** : une règle de source ne s'applique pas à un modèle dont la
source est une fonction Power Query, et nos sources sont des expressions, ce qui n'est pas la même
chose.

---

## Les autorisations, espace par espace

Elles ne se copient pas non plus : « Permissions - For a workspace or a specific item ».

| L'espace | Qui est administrateur | Qui est membre ou contributeur | Qui est lecteur |
|---|---|---|---|
| **DEV** | Vous | Qui installe avec vous | Personne |
| **TEST** | Vous | Vos collaborateurs qui testent | Personne |
| **PROD** | Vous | Vos collaborateurs en mission | **Personne** |

**Aucun client n'entre dans un espace de travail**, ni comme lecteur. Les clients passent par
l'application, avec leur audience et leur rôle de sécurité. Le cloisonnement par rôle ne restreint
que les lecteurs de l'application, jamais les membres d'un espace.

**Pour déployer**, il faut être contributeur des deux espaces concernés, et membre pour rattacher
un espace à une étape du pipeline.

---

## Ce que vous déployez, et quand

| Quand | Ce que vous faites |
|---|---|
| L'installation est finie en DEV, étapes 1 à 10 | Déployer DEV vers TEST |
| Vos collaborateurs ont passé le cahier de tests | Déployer TEST vers PROD |
| Vous corrigez un défaut trouvé en TEST | Corriger dans **DEV**, puis redéployer |

**Ne corrigez jamais directement dans TEST ni dans PROD.** Le déploiement arrière n'est possible
que vers une étape vide, et vous perdriez la correction au déploiement suivant.

---

Suite : [Déployer en trois espaces : DEV, TEST et PROD](../faire/deployer-en-trois-espaces.md)

[Revenir au sommaire](../../README.md) · [Les trois couches](06-les-trois-couches.md)
