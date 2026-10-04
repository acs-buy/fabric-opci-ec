# 5. Les licences, et ce qu'il vous faut avant de commencer

Cette page liste la capacité, les licences, les réglages et les rôles nécessaires à la solution.

## La capacité de calcul

La solution demande une capacité Microsoft Fabric **F4** au minimum.

**Vous pouvez tout reproduire gratuitement pendant 60 jours.** L'essai gratuit de Fabric ouvre une
capacité F4 ou F64 selon votre éligibilité, avec 1 To de stockage, et il comprend une licence
Power BI individuelle équivalente à Premium par utilisateur si vous n'en avez pas déjà une.

Pour l'ouvrir : connectez-vous à `app.fabric.microsoft.com`, cliquez sur votre photo en haut à
droite, puis sur **Démarrer l'essai**.

**D'où vient le chiffre F4.** Il a été établi par la mesure, et non par un calcul de charge : en
F2, la création d'un élément de saisie échoue. Cette mesure portait sur un composant que la
présente solution ne contient plus. Il est donc possible que F2 suffise, mais cela n'a pas été
éprouvé sur ce périmètre. Nous annonçons F4.

## Les licences des personnes

Microsoft Fabric se vend en plusieurs tailles de capacité : F2, F4, F8, F16, F32, F64, F128, F256,
F512, F1024, F2048, F4096 et F8192. Le chiffre est le nombre d'unités de capacité. Les licences
nécessaires changent à partir de F64.

| Qui | Capacité F2 à F32 | Capacité F64 ou plus |
|---|---|---|
| Vous, qui installez | Power BI Pro ou Premium par utilisateur | Power BI Pro ou Premium par utilisateur |
| Vos collaborateurs, rôle de contributeur | Power BI Pro ou Premium par utilisateur, chacun | Power BI Pro ou Premium par utilisateur, chacun |
| Vos clients, rôle de lecteur | Power BI Pro ou Premium par utilisateur, chacun | Licence gratuite Microsoft Fabric (Free) |

À partir de F64, la licence gratuite permet de consulter le contenu Power BI avec le rôle de lecteur
seulement. Tout autre rôle dans l'espace de travail, contributeur compris, exige une licence Pro ou
Premium par utilisateur.

L'installation demande une licence Pro dans tous les cas : créer un rapport ou un modèle sémantique
hors de « Mon espace de travail » exige une licence Pro ou Premium par utilisateur, quelle que soit
la capacité. L'essai Fabric fournit une licence individuelle équivalente à Premium par utilisateur à
la personne qui l'ouvre.

**Exemple.** Un cabinet de 5 collaborateurs ouvre la restitution à 20 clients.

| Capacité | Licences Power BI Pro à acheter |
|---|---|
| F4, F8, F16 ou F32 | 25 : 5 collaborateurs et 20 clients |
| F64 | 5 : les collaborateurs ; les 20 clients ont la licence gratuite |

Le prix d'une capacité varie selon la région Azure et change dans le temps. Le calculateur de tarifs
Microsoft Azure donne le prix du jour.

Source : Microsoft Learn, *Understand Microsoft Fabric licenses and capacity*, consulté le
05/10/2026.

## Les quatre réglages à faire activer

Votre administrateur Microsoft Fabric les active dans le portail d'administration, section
**Paramètres du locataire**.

1. **Les utilisateurs peuvent créer des éléments Fabric**
2. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec leurs dépôts Git**
3. **Créer des espaces de travail**
4. **Les utilisateurs peuvent synchroniser les éléments d'un espace de travail avec des dépôts GitHub**

Le quatrième est distinct du deuxième. Sans lui, GitHub n'apparaît pas dans la liste des
fournisseurs, et aucun message n'en donne la raison.

## Les rôles

- **Administrateur de l'espace de travail** : pour connecter le dépôt Git. C'est vous si vous créez
  l'espace.
- **Propriétaire des ensembles de fonctions** : seule la personne qui possède un ensemble de
  fonctions peut le publier. Installez depuis le compte qui restera responsable de la solution.
- **Un second compte** : l'approbation d'un visa est refusée à la personne qui a soumis le dossier.
  C'est la séparation des fonctions. Prévoyez un collègue pour éprouver cette action.

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

---

Suite : [6. Les trois couches d'une reproduction](06-les-trois-couches.md)

[Revenir au sommaire](../../README.md) · [Les treize étapes](../faire/etape-01-ouvrir-la-capacite.md)
