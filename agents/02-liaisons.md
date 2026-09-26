# Invite 2 : relier le modèle et les boutons (étapes 9 et 10)

Les étapes 9 et 10 sont les deux seules qu'un agent mène du début à la fin. Elles réécrivent,
dans les fichiers du dépôt que vous avez cloné, les sources de données du modèle et les boutons
du rapport. Les scripts n'ouvrent aucune connexion et ne vous demandent aucun identifiant : ils
travaillent sur vos fichiers, sur votre poste.

Faites le modèle d'abord, à l'étape 9, les boutons ensuite, à l'étape 10. Si vous actualisez le
modèle avant de l'avoir relié, vous obtenez une erreur qui a tout l'air d'une panne générale.

---

## Avant de coller l'invite : relevez vos 5 valeurs

Ces valeurs se lisent au portail, sur vos écrans. Aucun script ne va les chercher à votre place.

| # | Valeur | Où la lire |
|---|---|---|
| 1 | Adresse de l'espace de travail | Dans la barre d'adresse, espace ouvert. C'est le premier identifiant |
| 2 | Adresse de `fn_ecran_client` | Dans la barre d'adresse, élément ouvert. C'est le **dernier** identifiant |
| 3 | Adresse de `fn_ecran_revision` | Au même endroit, sur l'autre élément |
| 4 | Serveur SQL | Base `DossierOPCI` > Paramètres > Chaînes de connexion |
| 5 | Nom complet de la base | Au même endroit. Il se présente sous la forme `DossierOPCI-<identifiant>` |

Si vous collez deux fois la même adresse, le script `00_mes_identifiants.py` s'en aperçoit : il
refuse dès que deux des trois premières valeurs sont identiques.

---

```text
Nous reprenons la reproduction. L'invite 1 est passée : les éléments sont dans l'espace, les
données sont chargées, les 2 ensembles de fonctions répondent.

RÈGLES INCHANGÉES
1. Tu n'écris rien hors du dépôt cloné.
2. Tu ne me demandes aucun mot de passe ni jeton.
3. Tu ne déclares jamais « relié » sans avoir lancé la vérification et lu sa sortie.
4. Si un script refuse d'écrire, tu ne le forces pas et tu ne modifies pas les fichiers à la
   main. Tu me rapportes son message.

ÉTAPE 9, relier le modèle à ma base.
  a. Lance : python scripts/00_mes_identifiants.py
     Il me posera 5 questions. Laisse-moi répondre, ne réponds pas à ma place, ne devine
     aucune valeur. S'il refuse une saisie, montre-moi son message et redemande.
  b. Il écrit mes_commandes.txt à la racine. Lis-le et montre-moi les 2 commandes.
  c. Lance la commande de l'étape 9 telle qu'elle y figure, sans la modifier.
  d. Lance ensuite la vérification avec --verifier.
  e. La sortie doit donner 0 restant et 0 inconnues, et le nombre de reliées doit égaler le
     total que le script annonce lui-même. Si un seul de ces 3 nombres ne va pas, ARRÊTE-TOI
     et montre-moi la sortie brute. Ne corrige rien de toi-même, et n'invente aucun total
     attendu : le seul total juste est celui que le script affiche.

ÉTAPE 10, relier les boutons à mes fonctions.
  a. Lance la commande de l'étape 10 telle qu'elle figure dans mes_commandes.txt.
  b. Lance la vérification avec --verifier.
  c. La sortie doit donner 0 restant et 0 inconnus. Même règle qu'au-dessus : un écart, tu
     t'arrêtes et tu montres la sortie.
  d. Si le script refuse d'écrire en disant qu'un bouton porte un identifiant inconnu, ne
     cherche pas à le contourner : cela veut dire que le rapport a été modifié à la main.
     Nomme-moi le fichier qu'il désigne.

PUIS, CE QUE JE FAIS
  a. Montre-moi les commandes git pour pousser les modifications sur mon dépôt GitHub. Ne
     pousse pas toi-même : je veux voir le diff avant.
  b. Dis-moi de refaire « Mettre à jour tout » dans Fabric, et ce que je dois constater.

CONTRÔLE FINAL
Relance : python scripts/30_recette.py
Il rejoue les 2 vérifications et rend 1 si une liaison manque. Montre-moi sa sortie entière,
sans la résumer.
```

---

## Ce que vous vérifiez vous-même

1. Le diff, avant de pousser : il ne doit toucher que des `visual.json` et des `.tmdl`.
2. `30_recette.py` se termine sans erreur.
3. Après « Mettre à jour tout », le rapport s'ouvre et affiche des données.

Un script qui refuse d'écrire a trouvé des identifiants qu'il ne connaît pas, et cela veut dire
que les fichiers ont été modifiés ailleurs que par les scripts. Ne passez pas outre, et ne
retouchez rien à la main.
