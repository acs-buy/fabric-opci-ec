# Étape 4, avec un agent : copier le dépôt sur votre poste

**Ce que l'agent fait :** il clone votre copie du dépôt et vérifie qu'elle est complète.

**Ce qu'il ne fait pas :** créer la copie sur votre compte GitHub. Cette action se fait au
navigateur, avec votre compte, et elle prend 1 minute.

---

## Avant de le lancer

1. Allez sur la page du dépôt, et créez votre copie par **Fork**.
2. Relevez l'adresse de **votre** copie.

---

## La demande à coller

> Clone le dépôt `<l'adresse de votre copie>` dans le dossier `<votre dossier de travail>`.
>
> Ensuite, sans rien modifier, dis-moi :
> 1. combien de fichiers `.sql` contient `sql/10_referentiels/` et combien `sql/80_demonstration/` ;
> 2. quels dossiers existent à la racine ;
> 3. si le dossier `fabric/` contient bien un sous-dossier par élément.
>
> Ne lance aucun autre script, et ne modifie aucun fichier.

---

## Ce que vous vérifiez vous-même

| Ce qu'il annonce | Ce que vous devez lire |
|---|---|
| Les dossiers à la racine | `fabric`, `sql`, `scripts`, `docs`, `agents`, et les fichiers de licence |
| Le dossier `fabric/` | Un sous-dossier par élément, dont `DossierOPCI.SQLDatabase` et les deux `.Report` |

**Le nombre de fichiers `.sql` n'est pas un chiffre à comparer à une valeur écrite ici :** il change
quand la solution s'enrichit. Ce qui compte est que les deux dossiers ne soient pas vides.

**Retenez le nom `fabric`.** C'est la valeur à saisir à l'étape 5, et l'oublier fait échouer la
synchronisation.

---

Suite : [Étape 7, avec un agent : charger les données](etape-07-charger-les-donnees.md)

[Les demandes à coller](README.md) · [L'avertissement](AVERTISSEMENT.md)
