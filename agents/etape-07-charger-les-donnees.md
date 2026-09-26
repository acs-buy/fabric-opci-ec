# Étape 7, avec un agent : charger les données

**C'est l'étape où un agent sert le plus.** Le dépôt porte 80 fichiers SQL à jouer dans un ordre
imposé par les clés étrangères. À la main, c'est 30 minutes de copie et de collage, et une seule
inversion d'ordre fait échouer une dizaine de fichiers d'un coup.

---

## Avant de le lancer

1. **L'étape 6 doit être passée.** Votre base doit exister, avec ses tables et ses procédures.
2. **Relevez le serveur et le nom complet de votre base.** Dans votre espace de travail, ouvrez la
   base `DossierOPCI`, bandeau **Paramètres**, puis **Chaînes de connexion**. Le nom de la base
   porte un identifiant après `DossierOPCI` : c'est normal, et ce n'est pas le nom affiché dans la
   liste des éléments.
3. **Vérifiez que l'agent sait se connecter à la base** avec votre compte, par `sqlcmd` et
   l'authentification Microsoft Entra.

---

## La demande à coller

> Joue les fichiers SQL du dépôt sur ma base, dans cet ordre exact :
> 1. `sql/00_preparer_le_chargement.sql`
> 2. tous les fichiers de `sql/10_referentiels/`, par numéro croissant
> 3. tous les fichiers de `sql/80_demonstration/`, par numéro croissant
> 4. `sql/99_terminer_le_chargement.sql`
>
> Serveur : `<votre serveur>`
> Base : `<le nom complet de votre base>`
>
> Trois règles :
> - ne saute aucun fichier, et ne change pas l'ordre ;
> - ne modifie aucun fichier SQL, même si tu penses qu'il contient une erreur ;
> - si un fichier échoue, arrête-toi immédiatement, et donne-moi son nom et le message exact ;
> - à la fin, recopie-moi la sortie complète de `99_terminer_le_chargement.sql`, sans la résumer.

---

## Ce que vous vérifiez vous-même

La sortie du dernier fichier est ce qui décide. Elle doit vous montrer ceci, et vous la lisez
vous-même :

```
declencheurs encore suspendus           0
cles etrangeres non verifiees           0
```

**Ces deux comptes valent zéro, ou l'étape n'est pas finie.** Le premier signifie que les contrôles
de la base sont bien remis en service. Le second signifie qu'aucune ligne chargée ne désigne une
valeur absente.

Viennent ensuite six comptes de contrôle, avec la valeur attendue en face de chacun. **Comparez-les
un par un.** Un écart sur un seul d'entre eux veut dire qu'un fichier n'est pas passé.

---

## Puis une action que l'agent ne peut pas faire à votre place

**Vous inscrire aux missions.** Le dépôt n'emporte aucune identité : sans cette action, l'écran du
réviseur est vide et aucun visa n'aboutit.

Ouvrez `sql/90_vous_inscrire_aux_missions.sql`, remplacez les **deux adresses** en tête du fichier
par la vôtre et celle d'un collègue, et jouez-le. Vous pouvez demander à l'agent de le jouer une
fois que **vous** y avez écrit les adresses.

Le détail est à [l'étape 7 du mode opératoire](../docs/faire/etape-07-charger-les-donnees.md).

---

## Si un fichier échoue

Ne demandez pas à l'agent de le corriger. Donnez-nous le message : les fichiers sont produits
automatiquement depuis la base de référence, et une erreur à cet endroit veut dire que quelque
chose diffère chez vous, pas qu'un fichier est mal écrit.

---

Suite : [Étapes 9 et 10, avec un agent : relier la solution à votre espace](etape-09-et-10-relier.md)

[Les demandes à coller](README.md) · [L'avertissement](AVERTISSEMENT.md)
