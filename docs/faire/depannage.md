# Dépannage

Ces pannes ont toutes été rencontrées pendant la construction de la solution. Dans presque tous les
cas, le symptôme que vous avez sous les yeux ne désigne pas la cause.

## Un bouton ne fait rien

La cause la plus fréquente est l'étape 6 : elle n'a pas été faite, ou elle n'a pas été renvoyée vers
Fabric. Le bouton appelle donc encore l'espace de travail d'origine. Lancez la vérification :

```
python scripts/20_relier_les_boutons.py --verifier
```

Si vous lisez « restant à relier : 16 », vous avez la réponse. Si vous lisez « 16 reliés » et que le
bouton reste muet, vous avez sans doute relié les fichiers sans renvoyer la modification à GitHub, ou
sans refaire **Mettre à jour tout** dans Fabric.

L'autre cause est la connexion de données de l'ensemble de fonctions, qui n'a pas été renseignée.
Ouvrez `fn_ecran_client`, **Gérer les connexions**, et vérifiez que votre base y figure.

## Aucun visuel ne s'affiche, ou le modèle refuse de s'actualiser

Le modèle interroge encore la base d'origine.

```
python scripts/25_relier_le_modele.py --verifier
```

L'ordre compte : reliez le modèle **avant** les boutons. Un modèle non relié produit une erreur
d'actualisation qui ressemble à une panne générale de la solution, et vous allez chercher ailleurs.

## Les écrans sont vides, mais tout semble en place

Les données ne sont pas chargées, et c'est l'étape 5 qu'il faut reprendre. Cette requête tranche :

```sql
SELECT COUNT(*) FROM dbo.ref_question;
```

Si elle renvoie 0, le socle n'est pas chargé.

## « Écriture refusée : cette opération demande le rôle associé »

Rien n'est cassé : la base vérifie le rôle de la personne avant toute écriture sensible, et vous
n'êtes pas encore désigné sur la mission. Faites-vous désigner sur l'écran de conduite de mission,
section **Équipe de la mission**.

Le même refus tombe quand vous jouez le script d'effacement de la démonstration depuis un compte
sans rôle d'associé.

## La publication d'une fonction échoue

Deux causes possibles, et aucune n'est un défaut de la solution.

Deux minutes ne se sont peut-être pas écoulées depuis la publication précédente : attendez, puis
recommencez. Sinon, c'est que vous n'êtes pas propriétaire de l'ensemble de fonctions, et seul le
propriétaire peut le publier.

## GitHub n'apparaît pas dans la liste des fournisseurs Git

Le réglage de locataire qui autorise la synchronisation avec **GitHub** n'est pas activé. C'est un
réglage à part, distinct de celui qui autorise Git en général, et c'est là qu'on se trompe. Les
quatre réglages sont listés à l'étape 1.

## La synchronisation Git échoue ou ramène des fichiers étranges

Regardez le **répertoire** de la connexion : il doit valoir `fabric`. Si vous le laissez vide,
Fabric essaie d'interpréter tout le dépôt, scripts et documentation compris.

## Sous Windows, le clonage échoue sur un nom de fichier trop long

```
git config --global core.longpaths true
```

Puis reprenez le clonage.

## Un script de liaison refuse de s'exécuter

Il annonce un fichier portant des identifiants qu'il ne reconnaît pas : le rapport ou le modèle a été
modifié à la main entre-temps. Reprenez une copie propre du dépôt, puis relancez. Le script est fait
pour refuser dans ce cas, parce qu'écrire à l'aveugle sur un fichier déjà modifié le casserait sans
rien dire.

## Une erreur qui ne figure pas ici

Notez le message exact et l'étape où il apparaît. Le message d'erreur des fonctions porte le nom de
la procédure en cause : vous savez donc tout de suite où regarder dans la base.

---

[Revenir au sommaire](../../README.md) · [Les douze étapes](../../README.md#partie-2-faire--les-douze-étapes)
