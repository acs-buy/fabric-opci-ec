# Invite 1 : de la capacité aux fonctions publiées (étapes 1 à 8)

Collez le texte du bloc ci-dessous dans votre agent. Rien avant, rien après.

**Ce que l'agent exécutera lui-même** : l'étape 4 seulement, et les vérifications qui ne
demandent aucune connexion. Les étapes 1, 2, 3, 5, 6, 7 et 8 sont des gestes au portail Fabric
qu'il vous guidera à faire, sans les faire.

---

```text
Tu m'aides à reproduire une solution Microsoft Fabric à partir d'un dépôt public. Tu travailles
sous ma supervision : je clique moi-même tout ce qui touche au portail, aux droits et aux
identifiants.

RÈGLES QUE TU NE CONTOURNES PAS
1. Tu n'écris jamais en dehors du dossier du dépôt cloné.
2. Tu ne me demandes aucun mot de passe, aucun jeton, aucune clé. Si une étape en exige un, tu
   me dis où le coller dans le portail et tu t'arrêtes.
3. Tu ne prétends jamais avoir vérifié quelque chose que tu n'as pas exécuté. Si tu ne peux pas
   vérifier, tu écris « à vérifier par toi » et tu dis exactement quoi regarder.
4. Tu ne modifies aucun fichier du dépôt en dehors de ce que les scripts fournis modifient.
5. À la fin de chaque étape, tu t'arrêtes et tu attends que je confirme.

CE QUE TU FAIS, DANS L'ORDRE

ÉTAPE 0. Lis le fichier README.md à la racine du dépôt, puis les fichiers de docs/faire/ de
etape-01 à etape-08. Fais-moi un résumé en 10 lignes de ce que la reproduction va produire.
Ne passe pas à la suite avant que je dise « vu ».

ÉTAPES 1 à 3, que je fais au portail. Pour chacune, donne-moi dans cet ordre : ce qu'elle
produit, le chemin exact des clics, et LA VÉRIFICATION qui prouve qu'elle est passée. Attends
ma confirmation entre chaque.
  1. Ouvrir une capacité Fabric F4 minimum, ou l'essai gratuit de 60 jours.
  2. Faire activer les 5 réglages de locataire par l'administrateur. Rédige-moi le message à
     lui envoyer, avec les 5 intitulés exacts tirés de docs/faire/etape-02.
  3. Créer l'espace de travail et l'affecter à la capacité.
  Rappelle-moi la règle de l'étape 3 : ne renommer aucun élément après l'installation.

ÉTAPE 4, que TU exécutes.
  a. Demande-moi l'adresse de mon dépôt forké sur GitHub. Ne devine pas.
  b. Clone-le dans le dossier de travail courant.
  c. Sous Windows, dis-moi la commande qui active la prise en charge des chemins longs, et
     laisse-moi la lancer : elle demande des droits d'administrateur.
  d. Lance : python scripts/30_recette.py --donnees
     S'il échoue, diagnostique : Python 3 absent, mauvais dossier, ou autre. Ne contourne pas.
  e. Rends-moi l'arborescence du dépôt cloné, à 2 niveaux.

ÉTAPES 5 et 6, que je fais au portail.
  5. Connecter l'espace au dépôt GitHub. Avertis-moi du point qui se rate : le répertoire doit
     valoir « fabric », et un répertoire laissé vide fait échouer la synchronisation. Pour le
     jeton GitHub, donne-moi le chemin des menus et rappelle-moi que ce jeton est un mot de
     passe, à coller dans Fabric et nulle part ailleurs.
  6. Cliquer « Mettre à jour tout ». Dis-moi les 8 éléments que je dois voir apparaître, et
     préviens-moi qu'ils arrivent VIDES : la synchronisation Git ramène les définitions, pas
     les données.
  Si les tables de la base ne reviennent pas, ne cherche pas une erreur de ma part : c'est un
  défaut connu du dépôt, décrit dans _outils/NOTE_FORMAT_BASE.md. Signale-le et continue.

ÉTAPE 7, que je joue au portail.
  a. Liste-moi, dans l'ordre exact de leur numéro, tous les fichiers de sql/10_referentiels/
     puis tous ceux de sql/80_demonstration/.
  b. Pour chacun, donne son nom et en 5 mots ce qu'il charge.
  c. Rappelle-moi qu'ils sont rejouables : une table ne se remplit que si elle est vide.
  d. Donne-moi la requête de comptage produite par python scripts/30_recette.py --donnees,
     et les valeurs attendues.

ÉTAPE 8, que je fais au portail.
  Donne-moi le chemin des clics pour ajouter une connexion de données à fn_ecran_client puis à
  fn_ecran_revision, et pour publier chacun. Rappelle-moi les 2 contraintes : attendre 2
  minutes entre 2 publications, et que seul le propriétaire d'un ensemble peut le publier.
  La vérification est que la fonction qui_suis_je rend une réponse.

À LA FIN
Écris-moi un état en 3 colonnes : étape, passée ou non, ce qui reste à faire. N'écris « passée »
que pour les étapes dont j'ai confirmé la vérification. Puis arrête-toi : l'invite 2 prend la
suite.
```

---

## Ce que vous vérifiez vous-même, avant de passer à l'invite 2

1. Les 8 éléments sont visibles dans l'espace de travail.
2. La requête de comptage rend les valeurs attendues.
3. `qui_suis_je` répond sur les 2 ensembles de fonctions.

Si l'un des 3 manque, l'invite 2 échouera sans le dire clairement.
