# Politique de sécurité

Vous trouverez dans ce dépôt la définition d'une solution Microsoft Fabric et le mode opératoire
pour la reproduire. Aucune donnée de client réel n'y figure, aucun secret, aucun identifiant de
connexion.

---

## Ce qui est vérifié avant chaque publication

Trois vérifications passent sur le dépôt avant qu'il soit publié. On y cherche toute identité,
adresse de courriel, nom de cabinet, nom de personne, dans les fichiers comme dans les captures
d'écran. On y cherche les secrets, jeton, mot de passe, chaîne de connexion qui porte un
justificatif d'identité. Et l'on contrôle que le jeu de données livré est fictif de bout en bout,
dénominations et numéros d'identification compris.

Les définitions contiennent en revanche des identifiants d'espace de travail et d'éléments. Ce ne
sont pas des secrets : hors de l'espace de travail qui les héberge, ils n'ouvrent rien. Les scripts
de liaison les remplacent par les vôtres.

---

## Signaler une faille ou une fuite

Si vous découvrez une fuite de données ou une faille, n'ouvrez pas d'issue. Une issue est visible
de tous, et vous aggraveriez ce que vous vouliez justement faire cesser. Passez par la voie privée
de GitHub : onglet **Security** du dépôt, puis **Report a vulnerability**. Seuls les mainteneurs
voient le signalement.

### Ce qu'il faut nous signaler en premier

1. Une donnée réelle qui aurait échappé aux vérifications : une adresse, un nom de cabinet, une
   dénomination de client. Regardez aussi les captures d'écran et l'historique des commits, qui
   conserve ce qu'un fichier ne montre plus.
2. Un secret publié : jeton, mot de passe, certificat.
3. Une procédure du mode opératoire qui affaiblirait la sécurité de celui qui la suit, par exemple
   une autorisation trop large recommandée sans nécessité.
4. Une faille dans les scripts fournis.

### Ce que vous obtenez en retour

Vous recevez un accusé de réception sous quelques jours ouvrés. S'il s'agit d'une fuite de données,
le retrait se fait sans attendre, avant toute discussion sur le reste. Votre signalement sera
mentionné si vous le souhaitez, et restera anonyme si vous le préférez.

---

## Ce qui sort du cadre de cette politique

Une faille de Microsoft Fabric, de Power BI ou de GitHub se signale à son éditeur. Une question
d'installation se pose dans une issue, elles sont faites pour cela. Quant à la sécurité de votre
propre installation, elle tient à vos réglages de locataire, à vos autorisations et à vos licences :
le mode opératoire vous dit ce qu'il faut ouvrir et pourquoi, la configuration reste la vôtre.

---

## Deux points de sécurité que le mode opératoire traite

Aucun des deux n'est une faille, et tous deux se découvrent tard.

La sécurité au niveau des lignes ne s'applique qu'aux lecteurs. Un membre de l'espace de travail,
et à plus forte raison un administrateur, voit toutes les lignes quels que soient les rôles
définis. Si vous ajoutez un client comme membre de votre espace, il aura donc sous les yeux les
dossiers de tous les autres. Donnez-lui accès par l'application, avec son audience.

Il vous faut ensuite un rôle de sécurité par client. Le dépôt n'en livre qu'un, celui du véhicule
de démonstration. Tant que vous n'avez pas créé les autres, un client voit les données de ses
voisins.

Le détail est dans [l'environnement intégré](docs/comprendre/07-l-environnement-integre.md).
