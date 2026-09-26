# Invite 3 : publier et passer la recette (étapes 11 et 12)

Ici, l'agent ne clique rien. Les 12 actions de recette vont du clic jusqu'à la base, et elles
s'éprouvent à l'écran, par une personne. L'agent, lui, tient la liste, note ce qui échoue et
prépare la requête qui prouvera en base que l'action a produit son effet.

À l'action 11, il vous faudra un second compte : l'approbation d'un visa est refusée à celui qui
l'a soumis, par séparation des fonctions. Le refus que vous verrez s'afficher est donc le signe
que le contrôle joue son rôle.

---

```text
Nous terminons la reproduction. Les liaisons sont vérifiées : 0 restant, 0 inconnu.

RÈGLES
1. Tu ne cliques rien à ma place et tu ne pilotes aucun navigateur.
2. Tu ne déclares aucune action « passée » sans que je te l'aie dit.
3. Une action qui échoue n'est pas une action à refaire jusqu'à ce qu'elle passe : tu me
   demandes le message exact affiché à l'écran, et tu cherches sa cause dans
   docs/faire/depannage.md avant de proposer quoi que ce soit.

ÉTAPE 11, publier les 2 écrans. Je la fais au portail.
  a. Lis docs/faire/etape-11-publier-les-applications.md et donne-moi le chemin des clics.
  b. Rappelle-moi les 2 règles : un rôle de sécurité par client réel dans le modèle de
     restitution, et ne jamais ajouter un client comme membre de l'espace de travail.
  c. Dis-moi les 2 vérifications : un collègue voit la conduite de mission ; un compte de
     l'audience client ne voit que la restitution, et que son propre véhicule.

ÉTAPE 12, la recette.
  a. Lance : python scripts/30_recette.py
     Il liste les 12 actions. Reprends-les une par une, dans son ordre.
  b. Pour chaque action, donne-moi 3 choses et rien de plus :
       ce que je dois faire à l'écran,
       ce que je dois voir à l'écran juste après,
       comment le prouver en base.
  c. Attends que je te dise « passée » ou que je te donne le message d'erreur.
  d. Pour l'action 11, rappelle-moi qu'il faut me connecter avec un SECOND compte, et que le
     refus opposé au premier est le comportement attendu.
  e. Tiens un tableau à jour : numéro, action, état, ce qui a été observé.

SI UNE ACTION ÉCHOUE
  a. Demande-moi le message exact, pas mon résumé.
  b. Cherche sa cause dans docs/faire/depannage.md. Cite le passage.
  c. Si la cause n'y est pas, dis-le franchement plutôt que de proposer une hypothèse. Écris
     « cause inconnue » et note ce qu'il faudrait mesurer pour la trouver.

À LA FIN
Écris un compte rendu de recette : les 12 actions, leur état, et pour chaque échec le message
observé et ce qui a été tenté. Ce compte rendu est une pièce : il doit pouvoir être relu par
quelqu'un qui n'était pas là.
```

---

## Ce qui reste à votre charge, et que rien n'automatise

Déclarer la recette conforme reste votre affaire : c'est un constat, et un constat se vérifie,
il ne se reçoit pas d'un agent. Rattacher un compte du client à un poste du modèle est une
décision comptable qui engage votre responsabilité. Arrêter une forme de conclusion, viser un
cycle, ce sont des actes professionnels qu'aucun outillage ne prend en charge.

Le compte rendu que l'agent produit vous aide à relire ; il ne remplace pas le constat que vous
êtes seul à pouvoir faire.
