# Étape 8. Connecter les fonctions à la base

**Durée estimée :** 20 minutes, dont 4 minutes d'attente imposée. **Qui :** analyste recommandé,
faisable seul.

---

## Ce que vous allez faire

Donner à chacun des deux ensembles de fonctions le droit d'interroger votre base, puis les publier.

## Pourquoi

Les fonctions sont ce que les boutons de l'écran appellent. Elles reçoivent les paramètres,
appellent une procédure de la base, et rapportent le résultat.

**Ce droit d'accès ne voyage pas par Git.** La synchronisation a bien recréé le code des fonctions,
mais pas leur autorisation de parler à la base. Tant que vous ne l'avez pas posée, chaque bouton
échouera.

[Comprendre les trois couches](../comprendre/06-les-trois-couches.md)

---

## Avant de commencer

- L'étape 7 doit être faite. Une fonction qui joint une base vide ne prouve rien.
- **Vous devez être propriétaire des ensembles de fonctions.** Si quelqu'un d'autre a fait la
  synchronisation, c'est lui qui doit faire cette étape, ou vous devez la refaire depuis votre
  compte.

---

## La procédure, pour fn_ecran_client

1. Dans votre espace de travail, ouvrez **fn_ecran_client**.
2. Dans le bandeau du haut, cliquez sur **Gérer les connexions**.
3. Cliquez sur **Ajouter une connexion de données**.
4. Dans la liste, choisissez votre base **DossierOPCI**.
5. Validez.
6. Toujours dans le bandeau, cliquez sur **Publier**.
7. Attendez la fin de la publication. Elle prend quelques minutes.

## Puis pour fn_ecran_revision

Reprenez exactement les mêmes points 1 à 7, sur **fn_ecran_revision**.

**Attendez deux minutes entre les deux publications.** Voir ci-dessous.

---

## Deux comportements qui surprennent, et qui sont normaux

### Le refroidissement de deux minutes

**La plateforme impose deux minutes d'attente entre deux publications successives.** Si vous
publiez le second ensemble de fonctions trop vite après le premier, un message vous le signale.

Ce n'est pas une panne. Attendez, et recommencez.

### Seul le propriétaire peut publier

**Une personne qui n'est pas propriétaire d'un ensemble de fonctions ne peut pas le publier**, même
si elle est administratrice de l'espace de travail.

**Ce que cela implique pour un cabinet :** installez depuis le compte qui restera responsable de la
solution. Si la personne qui a installé quitte le cabinet, la republication des fonctions demandera
un transfert de propriété.

---

## Vérifier que c'est fait

C'est la vérification la plus directe de tout le mode opératoire.

1. Ouvrez **fn_ecran_client**.
2. Dans la liste des fonctions, trouvez **qui_suis_je**.
3. Lancez-la.
4. **Elle doit rendre une réponse contenant votre identité.**

Si elle rend une erreur de connexion, la connexion de données n'est pas posée, ou la publication n'a
pas abouti.

Faites la même chose sur **fn_ecran_revision** si elle porte une fonction équivalente.

---

## Si cela ne marche pas

| Le symptôme | La cause la plus probable |
|---|---|
| « Connexion introuvable » | Le point 4 n'a pas été validé, ou la mauvaise base a été choisie |
| La publication échoue sans message clair | Les deux minutes de refroidissement. Attendez et recommencez |
| « Vous n'êtes pas autorisé à publier » | Vous n'êtes pas propriétaire de cet ensemble de fonctions |
| La fonction répond, mais une erreur SQL apparaît | L'étape 7 n'est pas faite, ou pas entièrement |

**Un point à ne pas confondre.** Si la fonction répond mais qu'un bouton de l'écran ne fait toujours
rien, ce n'est pas cette étape : c'est l'étape 10, qui n'est pas encore faite. Les deux symptômes se
ressemblent, et les causes sont différentes.

---

## Ce que vous venez de poser, et ce qui manque encore

| Couche | État |
|---|---|
| Les définitions | Posées à l'étape 6 |
| Les données | Posées à l'étape 7 |
| La connexion des fonctions | **Posée maintenant** |
| Le modèle vers la base | Étape 9 |
| Les boutons vers les fonctions | Étape 10 |

---

Suite : [Étapes 9 et 10. Relier la solution à votre espace](etape-09-et-10-relier.md)
