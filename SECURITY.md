# Politique de sécurité

Ce dépôt contient la définition d'une solution Microsoft Fabric et le mode opératoire pour la
reproduire. Il ne contient **aucune donnée de client réel, aucun secret et aucun identifiant de
connexion**, et c'est l'objet du premier contrôle ci-dessous.

---

## Ce qui est vérifié avant chaque publication

| Le contrôle | Ce qu'il cherche |
|---|---|
| Aucune identité | Adresse de courriel, nom de cabinet, nom de personne, dans les fichiers comme dans les captures |
| Aucun secret | Jeton, mot de passe, chaîne de connexion avec justificatif d'identité |
| Aucune donnée réelle | Le jeu livré est entièrement fictif, dénominations et numéros d'identification compris |

Les identifiants d'espace de travail et d'éléments qui figurent dans les définitions **ne sont pas
des secrets** : ce sont des références internes à un espace de travail, sans valeur hors de celui
qui les héberge. Ce sont eux que les scripts de liaison remplacent par les vôtres.

---

## Signaler une faille ou une fuite

**N'ouvrez pas d'issue publique** pour signaler une fuite de données ou une faille. Une issue est
visible de tous, et la signaler publiquement aggrave ce qu'elle expose.

**Utilisez la voie privée de GitHub :** onglet **Security** du dépôt, puis **Report a
vulnerability**. Le signalement n'est visible que des mainteneurs.

### Ce qui nous intéresse en priorité

1. **Une donnée réelle qui aurait échappé aux contrôles** : une adresse, un nom de cabinet, une
   dénomination de client, y compris dans une capture d'écran ou dans l'historique des commits.
2. **Un secret qui aurait été publié** : jeton, mot de passe, certificat.
3. **Une procédure du mode opératoire qui affaiblirait la sécurité de celui qui la suit**, par
   exemple une autorisation trop large recommandée sans nécessité.
4. Une faille dans les scripts fournis.

### Ce à quoi vous pouvez vous attendre

- Un accusé de réception sous quelques jours ouvrés.
- Pour une fuite de données, un retrait sans attendre, avant toute discussion sur le reste.
- Une mention de votre signalement si vous le souhaitez, ou l'anonymat si vous le préférez.

---

## Ce qui sort du cadre de cette politique

- Les failles de Microsoft Fabric, de Power BI ou de GitHub. Signalez-les à leur éditeur.
- Les questions d'installation. Ouvrez une issue, elles sont faites pour cela.
- La sécurité de **votre** installation, qui dépend de vos réglages de locataire, de vos
  autorisations et de vos licences. Le mode opératoire dit ce qu'il faut ouvrir et pourquoi, mais
  la configuration reste la vôtre.

---

## Deux points de sécurité que le mode opératoire traite

Ils ne sont pas des failles, mais ils se découvrent souvent trop tard.

**La sécurité au niveau des lignes ne restreint que les lecteurs.** Un membre ou un administrateur
de l'espace de travail voit tout. N'ajoutez jamais un client comme membre de votre espace : donnez-
lui accès par l'application, avec son audience.

**Un rôle de sécurité par client est à créer.** Le dépôt n'en livre qu'un, celui du véhicule de
démonstration. Sans les autres, un client verrait les données des autres clients.

Le détail est dans [l'environnement intégré](docs/comprendre/07-l-environnement-integre.md).
