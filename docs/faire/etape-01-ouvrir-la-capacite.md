# Étape 1. Ouvrir une capacité Fabric

**Durée estimée :** 10 minutes. **Qui :** vous.

---

## Ce que vous allez faire

Ouvrir l'essai gratuit de Microsoft Fabric, ou vous faire affecter une capacité que votre cabinet
possède déjà.

## Pourquoi

La solution a besoin d'une capacité de calcul. Sans elle, les éléments Fabric autres que Power BI ne
fonctionnent pas, et les messages d'erreur ne désignent pas la capacité comme cause.

**Le niveau minimum est F4.** Cette exigence a été établie par la mesure, non par prudence : en F2,
la création d'une surface de saisie échoue avec un message qui désigne une cause inexistante.

**L'essai gratuit ouvre exactement ce qu'il faut**, pendant 60 jours, avec 1 To de stockage et une
licence Power BI individuelle si vous n'en avez pas.

[Comprendre les licences en détail](../comprendre/05-les-licences.md)

---

## Avant de commencer

- Un compte professionnel Microsoft. Un compte personnel ne convient pas.
- Savoir si votre cabinet possède déjà une capacité Fabric. Demandez à votre administrateur : si
  c'est le cas, passez à la variante B ci-dessous.

---

## Variante A. Ouvrir l'essai gratuit

1. Allez sur `app.fabric.microsoft.com` et connectez-vous.
2. Cliquez sur **votre photo**, en haut à droite.
3. Cliquez sur **Démarrer l'essai**.
4. Acceptez les conditions.
5. Dans la fenêtre **Activez votre essai gratuit de 60 jours**, **choisissez votre région**.
6. Cliquez sur **Activer**.

### Le choix de la région mérite trente secondes d'attention

Si vos clients relèvent d'exigences de localisation des données, choisissez une région de l'Union
européenne. **France Centre** en fait partie.

**Attention à une nuance.** La région de votre capacité n'est pas la seule qui compte : la région de
domiciliation de votre locataire, fixée à l'inscription du premier utilisateur, en stocke une
partie. [Le détail est ici](../comprendre/07-l-environnement-integre.md).

Pour la lire : volet d'aide, puis **À propos**, et regardez « Vos données sont stockées dans ».

---

## Variante B. Utiliser une capacité existante

Demandez à votre administrateur Fabric :

- le **nom de la capacité** à utiliser ;
- sa **taille**, qui doit être F4 ou plus ;
- sa **région** ;
- l'autorisation de **créer un espace de travail** dessus.

---

## Vérifier que c'est fait

1. Cliquez sur votre photo, en haut à droite.
2. Vous devez y lire un **état d'essai**, avec le nombre de jours restants.

Pour l'essai, vous pouvez aussi vérifier dans le portail d'administration, **Paramètres de
capacité**, onglet **Essai**.

---

## Si le bouton « Démarrer l'essai » n'apparaît pas

Trois causes possibles, dans l'ordre de fréquence.

| La cause | Ce qu'il faut faire |
|---|---|
| Votre administrateur a désactivé les essais | Lui demander d'activer **Les utilisateurs peuvent essayer les fonctionnalités payantes de Microsoft Fabric** |
| Vous avez déjà un essai en cours | Le gestionnaire de compte affiche alors un état d'essai. Vous n'avez rien à faire |
| Votre locataire n'est pas éligible | Contacter le support, ou passer à la variante B |

---

## Si vous voulez passer de 4 à 64 unités

C'est possible pour un essai, si vous y êtes éligible, et cela ne change pas la durée restante.

1. Portail d'administration, **Paramètres de capacité**, onglet **Essai**.
2. Cliquez sur **Changer la taille**.
3. Passez de 4 à 64 unités, puis **Appliquer**.

**Pourquoi vous pourriez le vouloir :** à partir de 64 unités, vos lecteurs n'ont plus besoin de
licence Power BI Pro. Sous ce seuil, chacun doit être licencié, vos clients compris.

---

## Ce qui se passe à la fin de l'essai

À retenir dès maintenant, pour ne pas le découvrir au 60e jour.

- L'accès à la capacité d'essai est retiré.
- Les espaces de travail qui lui étaient affectés repassent en licence Pro, et **les éléments Fabric
  autres que Power BI deviennent inaccessibles**.
- Le contenu reste dans OneLake pendant **7 jours**, et se réactive en affectant l'espace de travail
  à une capacité payante.

**Autrement dit :** vous avez 60 jours pour décider, et 7 jours de grâce. Au-delà, le contenu part.

---

Suite : [Étape 2. Faire activer les cinq réglages](etape-02-activer-les-reglages.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
