# Dépannage

Les pannes rencontrées pendant la construction de la solution, avec leur cause réelle.

## Un bouton ne fait rien

**Première cause :** l'étape 10 n'a pas été faite, ou n'a pas été renvoyée vers Fabric. Le
bouton appelle encore l'espace de travail d'origine.

**Vérification :**

```
python scripts/20_relier_les_boutons.py --verifier
```

Si « restant a relier » ne vaut pas zéro, la cause est celle-ci. Si tous les boutons sont reliés
mais que le bouton ne fait toujours rien, vous avez sans doute relié les fichiers sans renvoyer la
modification à GitHub, ou sans refaire **Mettre à jour tout** dans Fabric.

**Deuxième cause :** la connexion de données de l'ensemble de fonctions n'est pas posée. Le fichier
`definition.json` de chaque ensemble, sous `fabric/`, liste ses fonctions : ouvrez l'ensemble de la
fonction que le bouton appelle, **Gérer les connexions**, et vérifiez que votre base y figure.

**Troisième cause :** l'ensemble de fonctions n'est pas publié, ou ses bibliothèques ne le sont pas.
Ouvrez-le : en mode **Run only**, la liste ne montre que les fonctions publiées, et **Library
management** doit montrer chaque bibliothèque à l'état « Published ». Sinon, publiez-le. Le détail
est à l'étape 8.

## Une bibliothèque manque dans un ensemble de fonctions

Chaque ensemble déclare ses bibliothèques dans son `definition.json`, section `libraries`. Si
**Library management** ne montre pas l'une d'elles après la synchronisation :

- une bibliothèque de PyPI : **Add from PyPI**, son nom, puis la version écrite dans
  `definition.json` ;
- la roue `moteur_opci` de `fn_valorisation` : **Upload**, puis le fichier `.whl` du dossier
  `fabric/fn_valorisation.UserDataFunction/privateLibraries/` de votre copie du dépôt.

Publiez ensuite l'ensemble.

## La publication ou l'envoi d'une roue échoue sur une erreur CORS

L'éditeur l'écrit : votre réseau doit autoriser les requêtes `multipart/form-data` et l'envoi de
fichiers vers les adresses de Fabric, faute de quoi la publication des fonctions et l'envoi d'une
bibliothèque privée peuvent échouer sur une erreur CORS.

## « Production refusée : le modèle Word du cabinet est introuvable »

Les boutons de production des documents appellent `fn_documents`, dont les fonctions fabriquent
chaque document sur le modèle Word du cabinet. Elles le lisent au site SharePoint du cabinet,
bibliothèque Documents, dossier `Modeles`, sous le nom `modele_livrables_opci.docx`, par le
raccourci `fec` du coffre. Ce dépôt ne fournit pas ce modèle : déposez le vôtre à cet endroit, sous
ce nom.

D'après le code de `fn_documents`, le modèle est un document Word (`.docx`). Ses champs
`{{ entete }}` et `{{ pied }}` reçoivent l'en-tête et le pied de page du document produit, et le
corps s'écrit à la place d'un paragraphe dont le texte est `[CORPS]`, ou à la fin du modèle s'il
n'en porte pas.

## Aucun visuel ne s'affiche, ou le modèle refuse de s'actualiser

Le modèle interroge encore la base d'origine.

```
python scripts/25_relier_le_modele.py --verifier
```

Attention à l'ordre : reliez le modèle **avant** les boutons. Un modèle non relié produit une erreur
d'actualisation qui ressemble à une panne générale de la solution.

## Les écrans sont vides, mais tout semble en place

Les données ne sont pas chargées. Reportez-vous à l'étape 7. Cette requête vous le confirme :

```sql
SELECT COUNT(*) FROM dbo.ref_question;
```

Si elle rend 0, le socle n'est pas chargé.

## « Écriture refusée : cette opération demande le rôle associé »

La base vérifie le rôle de la personne avant toute écriture sensible.
Faites-vous désigner sur l'écran de conduite de mission, section **Équipe de la mission**.

Le même refus se produit quand vous jouez le script d'effacement de la démonstration depuis un
compte sans rôle d'associé.

## « L'annexe de l'entité … est en cours de calcul : réessayez dans un instant. »

Un autre calcul de l'annexe du même véhicule tient son verrou depuis plus de 120 secondes. Un calcul
dure quelques secondes ; une attente de 2 minutes désigne un calcul resté ouvert, par exemple un
essai lancé dans une transaction jamais fermée. Attendez sa fin, ou fermez la session qui le tient.

## « Document refusé : les cellules de l'annexe de … sont en retard sur une modification … »

Une écriture a changé une donnée que l'annexe lit, sans recalcul : un lot validé, un classeur
réimporté, une feuille de saisie. Cliquez **Recalculer**, puis produisez de nouveau. Le message
nomme la donnée modifiée et l'heure de la modification.

## La publication d'une fonction échoue

Deux causes.

- **Deux minutes ne se sont pas écoulées** depuis la publication précédente. Attendez et
  recommencez.
- **Vous n'êtes pas propriétaire** de l'ensemble de fonctions. Seul le propriétaire peut le publier.

## GitHub n'apparaît pas dans la liste des fournisseurs Git

Le réglage de locataire qui autorise la synchronisation avec **GitHub** n'est pas activé. Il est
distinct de celui qui autorise Git en général. Les cinq réglages sont listés à l'étape 2.

## La synchronisation Git échoue ou ramène des fichiers étranges

Vérifiez le **répertoire** de la connexion : il doit valoir `fabric`. Laissé vide, Fabric essaie
d'interpréter tout le dépôt, y compris les scripts et la documentation.

## Sous Windows, le clonage échoue sur un nom de fichier trop long

```
git config --global core.longpaths true
```

Puis reprenez le clonage.

Si le réglage `LongPathsEnabled` de Windows vaut 0 sur votre poste, copiez aussi le dépôt dans un
dossier dont le chemin compte moins de 130 caractères. Au-delà, les scripts Python du dépôt ne voient
pas tous les fichiers du rapport, et ils ne le signalent pas.

## Un script de liaison refuse de s'exécuter

Il annonce un fichier portant des identifiants qu'il ne reconnaît pas. Cela veut dire que le rapport
ou le modèle a été modifié à la main entre-temps. Reprenez une copie propre du dépôt et relancez.
Le script se comporte ainsi volontairement : écrire à l'aveugle sur un fichier déjà modifié le
casserait sans le dire.

Le script des boutons s'arrête aussi, avant d'écrire, s'il manque l'identifiant d'un ensemble de
fonctions, ou si deux ensembles reçoivent le même : chaque ensemble a le sien.

## Une erreur qui ne figure pas ici

Notez le message exact et l'étape où il apparaît. Le message d'erreur des fonctions porte le nom de
la procédure en cause, ce qui désigne directement l'endroit à regarder dans la base.

---

[Revenir au sommaire](../../README.md) · [Les treize étapes](../../README.md#partie-2-faire--les-treize-étapes)
