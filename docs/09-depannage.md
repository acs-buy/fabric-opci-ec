# 9. Dépannage

Les pannes rencontrées pendant la construction de la solution, avec leur cause réelle. Dans presque
tous les cas, le symptôme ne désigne pas la cause.

## Un bouton ne fait rien

**Cause la plus fréquente :** l'étape 6 n'a pas été faite, ou n'a pas été renvoyée vers Fabric. Le
bouton appelle encore l'espace de travail d'origine.

**Vérification :**

```
python scripts/20_relier_les_boutons.py --verifier
```

Si vous lisez « restant à relier : 16 », vous avez la réponse. Si vous lisez « 16 reliés » mais que
le bouton ne fait toujours rien, vous avez sans doute relié les fichiers sans renvoyer la
modification à GitHub, ou sans refaire **Mettre à jour tout** dans Fabric.

**Deuxième cause :** la connexion de données de l'ensemble de fonctions n'est pas posée. Ouvrez
`fn_ecran_client`, **Gérer les connexions**, et vérifiez que votre base y figure.

## Aucun visuel ne s'affiche, ou le modèle refuse de s'actualiser

Le modèle interroge encore la base d'origine.

```
python scripts/25_relier_le_modele.py --verifier
```

Attention à l'ordre : reliez le modèle **avant** les boutons. Un modèle non relié produit une erreur
d'actualisation qui ressemble à une panne générale de la solution.

## Les écrans sont vides, mais tout semble en place

Les données ne sont pas chargées. Reportez-vous à l'étape 5. Cette requête vous le confirme :

```sql
SELECT COUNT(*) FROM dbo.ref_question;
```

Si elle rend 0, le socle n'est pas chargé.

## « Écriture refusée : cette opération demande le rôle associé »

Ce n'est pas une panne. La base vérifie le rôle de la personne avant toute écriture sensible.
Faites-vous désigner sur l'écran de conduite de mission, section **Équipe de la mission**.

Le même refus se produit quand vous jouez le script d'effacement de la démonstration depuis un
compte sans rôle d'associé.

## La publication d'une fonction échoue

Deux causes, toutes deux normales.

- **Deux minutes ne se sont pas écoulées** depuis la publication précédente. Attendez et
  recommencez.
- **Vous n'êtes pas propriétaire** de l'ensemble de fonctions. Seul le propriétaire peut le publier.

## GitHub n'apparaît pas dans la liste des fournisseurs Git

Le réglage de locataire qui autorise la synchronisation avec **GitHub** n'est pas activé. Il est
distinct de celui qui autorise Git en général. Les quatre réglages sont listés à l'étape 1.

## La synchronisation Git échoue ou ramène des fichiers étranges

Vérifiez le **répertoire** de la connexion : il doit valoir `fabric`. Laissé vide, Fabric essaie
d'interpréter tout le dépôt, y compris les scripts et la documentation.

## Sous Windows, le clonage échoue sur un nom de fichier trop long

```
git config --global core.longpaths true
```

Puis reprenez le clonage.

## Un script de liaison refuse de s'exécuter

Il annonce un fichier portant des identifiants qu'il ne reconnaît pas. Cela veut dire que le rapport
ou le modèle a été modifié à la main entre-temps. Reprenez une copie propre du dépôt et relancez.
Le script se comporte ainsi volontairement : écrire à l'aveugle sur un fichier déjà modifié le
casserait sans le dire.

## Une erreur qui ne figure pas ici

Notez le message exact et l'étape où il apparaît. Le message d'erreur des fonctions porte le nom de
la procédure en cause, ce qui désigne directement l'endroit à regarder dans la base.
