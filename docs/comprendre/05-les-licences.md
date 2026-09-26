# 5. Les licences, et ce qu'il vous faut avant de commencer

## La capacité de calcul

La solution demande une capacité Microsoft Fabric **F4** au minimum.

Pendant 60 jours, ça ne vous coûte rien. L'essai gratuit de Fabric ouvre une capacité F4 ou F64
selon votre éligibilité, avec 1 To de stockage, et il comprend une licence Power BI individuelle
équivalente à Premium par utilisateur si vous n'en avez pas déjà une.

Pour l'ouvrir : connectez-vous à `app.fabric.microsoft.com`, cliquez sur votre photo en haut à
droite, puis sur **Démarrer l'essai**.

Le chiffre F4 vient d'un essai : en F2, la création d'une interface de saisie échoue. Aucun calcul
de charge derrière, juste cette mesure. Elle portait sur un composant que la solution ne contient
plus, donc F2 suffit peut-être aujourd'hui, mais personne ne l'a vérifié sur ce périmètre. Nous
annonçons F4.

## Les licences des personnes

| Qui | Ce qu'il lui faut |
|---|---|
| Vous, qui installez | Power BI Pro ou Premium par utilisateur. L'essai Fabric en fournit l'équivalent. |
| Vos collaborateurs, capacité F4 à F32 | Power BI Pro ou Premium par utilisateur, chacun |
| Vos collaborateurs, capacité F64 ou plus | Une licence gratuite suffit, avec le rôle de lecteur |

Passé l'essai, la capacité F4 ne rend pas l'écran gratuit pour votre équipe. Tant que vous restez
sous F64, chaque personne qui ouvre l'écran a besoin d'une licence Pro, et c'est là que le budget
se décide. Pour le prix de la capacité elle-même, allez voir le calculateur de tarifs Microsoft
Azure : les tarifs varient selon la région et ils changent, un chiffre inscrit ici serait faux
avant même que vous le lisiez.

## Les quatre réglages à faire activer

Votre administrateur Microsoft Fabric les active dans le portail d'administration, section
**Paramètres du locataire**.

1. **Les utilisateurs peuvent créer des éléments Fabric**
2. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec leurs dépôts Git**
3. **Créer des espaces de travail**
4. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec des dépôts GitHub**

Le quatrième se règle à part du deuxième, et c'est celui qu'on oublie. Si vous le laissez
désactivé, GitHub n'apparaît pas dans la liste des fournisseurs, et vous chercherez longtemps
pourquoi.

## Les rôles

- **Administrateur de l'espace de travail** : pour connecter le dépôt Git. C'est vous si vous créez
  l'espace.
- **Propriétaire des ensembles de fonctions** : seule la personne qui possède un ensemble de
  fonctions peut le publier. Installez depuis le compte qui restera responsable de la solution.
- **Un second compte** : l'approbation d'un visa est refusée à la personne qui a soumis le dossier,
  au titre de la séparation des fonctions. Prévoyez un collègue si vous voulez tester ce passage.

## Sur votre poste

- Un navigateur.
- **Python 3**. Les trois scripts de ce dépôt n'utilisent aucune bibliothèque extérieure.
- Un compte **GitHub**, gratuit.

Si vous travaillez sous Windows, activez une fois pour toutes la prise en charge des chemins longs
dans Git, car certains fichiers de la solution ont des chemins profonds :

```
git config --global core.longpaths true
```

## Combien de temps

Le temps d'installation sera inscrit ici après la première reproduction à blanc. Tant qu'il n'est
pas mesuré, nous préférons ne pas avancer de chiffre.

---

Suite : [6. Les trois couches d'une reproduction](06-les-trois-couches.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
