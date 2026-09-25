# 1. Ce qu'il vous faut avant de commencer

Lisez cette page avant tout achat. Elle dit ce que coûte la solution, et ce qui ne coûte rien.

## La capacité de calcul

La solution demande une capacité Microsoft Fabric **F4** au minimum.

**Vous pouvez tout reproduire gratuitement pendant 60 jours.** L'essai gratuit de Fabric ouvre une
capacité F4 ou F64 selon votre éligibilité, avec 1 To de stockage, et il comprend une licence
Power BI individuelle équivalente à Premium par utilisateur si vous n'en avez pas déjà une.

Pour l'ouvrir : connectez-vous à `app.fabric.microsoft.com`, cliquez sur votre photo en haut à
droite, puis sur **Démarrer l'essai**.

**D'où vient le chiffre F4.** Il a été établi par la mesure, et non par un calcul de charge : en
F2, la création d'une surface de saisie échoue. Cette mesure portait sur un composant que la
présente solution ne contient plus. Il est donc possible que F2 suffise, mais cela n'a pas été
éprouvé sur ce périmètre. Nous annonçons F4.

## Les licences des personnes

| Qui | Ce qu'il lui faut |
|---|---|
| Vous, qui installez | Power BI Pro ou Premium par utilisateur. L'essai Fabric en fournit l'équivalent. |
| Vos collaborateurs, capacité F4 à F32 | Power BI Pro ou Premium par utilisateur, chacun |
| Vos collaborateurs, capacité F64 ou plus | Une licence gratuite suffit, avec le rôle de lecteur |

**Le point de coût, dit franchement.** Passé l'essai, une capacité F4 ne rend pas l'écran gratuit
pour votre équipe. Tant que la capacité reste sous F64, chaque personne qui ouvre l'écran a besoin
d'une licence Pro. Pour le prix d'une capacité, consultez le calculateur de tarifs Microsoft Azure :
les tarifs varient par région et changent, et un chiffre inscrit ici serait faux avant que vous le
lisiez.

## Les quatre réglages à faire activer

Votre administrateur Microsoft Fabric les active dans le portail d'administration, section
**Paramètres du locataire**.

1. **Les utilisateurs peuvent créer des éléments Fabric**
2. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec leurs dépôts Git**
3. **Créer des espaces de travail**
4. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec des dépôts GitHub**

Le quatrième est distinct du deuxième, et c'est celui qu'on oublie. Sans lui, GitHub n'apparaît pas
dans la liste des fournisseurs, et vous chercherez longtemps pourquoi.

## Les rôles

- **Administrateur de l'espace de travail** : pour connecter le dépôt Git. C'est vous si vous créez
  l'espace.
- **Propriétaire des ensembles de fonctions** : seule la personne qui possède un ensemble de
  fonctions peut le publier. Installez depuis le compte qui restera responsable de la solution.
- **Un second compte** : l'approbation d'un visa est refusée à la personne qui a soumis le dossier.
  C'est la séparation des fonctions. Prévoyez un collègue pour éprouver ce geste.

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

Le temps d'installation sera porté ici après la première reproduction à blanc. Nous préférons ne
pas avancer de chiffre tant qu'il n'est pas mesuré.

Suite : [2. Créer l'espace de travail](02-espace-de-travail.md)
