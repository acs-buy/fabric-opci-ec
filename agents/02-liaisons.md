# Invite 2 : relier le modèle et les boutons (étapes 9 et 10)

**Ce sont les 2 seules étapes qu'un agent exécute de bout en bout.** Elles réécrivent 72
sources de données et 36 boutons dans les fichiers du dépôt cloné. Aucune connexion, aucun
identifiant : les scripts ne parlent à personne.

**L'ordre est imposé** : le modèle (9) avant les boutons (10). Actualiser le modèle avant de
l'avoir relié produit une erreur qui fait croire à une panne générale.

---

## Avant de coller l'invite : relevez vos 5 valeurs

Elles se lisent au portail, à l'œil. Personne ne peut le faire pour vous.

| # | Valeur | Où la lire |
|---|---|---|
| 1 | Adresse de l'espace de travail | La barre d'adresse, sur l'espace ouvert. Premier identifiant |
| 2 | Adresse de `fn_ecran_client` | La barre d'adresse, sur l'élément ouvert. **Dernier** identifiant |
| 3 | Adresse de `fn_ecran_revision` | Idem |
| 4 | Serveur SQL | Base `DossierOPCI` > Paramètres > Chaînes de connexion |
| 5 | Nom complet de la base | Idem. De la forme `DossierOPCI-<identifiant>` |

Le script `00_mes_identifiants.py` les contrôle et refuse si 2 des 3 premières sont identiques.

---

```text
Nous reprenons la reproduction. L'invite 1 est passée : les 8 éléments sont dans l'espace, les
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
  e. La sortie doit donner 72 reliées, 0 restant, 0 inconnues. Si un seul de ces 3 nombres
     diffère, ARRÊTE-TOI et montre-moi la sortie brute. Ne corrige rien de toi-même.

ÉTAPE 10, relier les boutons à mes fonctions.
  a. Lance la commande de l'étape 10 telle qu'elle figure dans mes_commandes.txt.
  b. Lance la vérification avec --verifier.
  c. La sortie doit donner 36 reliés, 0 restant, 0 inconnus. Même règle qu'au-dessus : un
     écart, tu t'arrêtes et tu montres la sortie.
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

1. Le diff avant de pousser : il ne doit toucher que des `visual.json` et des `.tmdl`.
2. `30_recette.py` sort sans erreur.
3. Après « Mettre à jour tout », le rapport s'ouvre et affiche des données.

**Si un script a refusé d'écrire, ne passez pas outre.** Il refuse parce qu'il a trouvé des
identifiants qu'il ne connaît pas, ce qui signifie que les fichiers ont été touchés ailleurs.
