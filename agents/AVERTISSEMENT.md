# Reproduire avec un agent d'intelligence artificielle

Tout ce que ce dossier automatise figure aussi dans le `README.md` du dépôt et se fait à la
main, sans agent, sans surcoût et sans la moindre perte de fonctionnalité. Si la voie manuelle
vous convient, vous n'avez rien à lire ici.

---

## 1. Ce que ce dossier contient, et ce qu'il ne contient pas

Vous y trouverez des invites prêtes à coller dans un agent de codage, un jeu d'autorisations
donné en exemple et à adapter, et les points d'arrêt où une décision humaine est requise.
L'agent, le modèle et l'abonnement restent à votre charge. Personne ne vous garantit que
l'agent fera ce qui lui est demandé, et rien de ce qui suit ne vous dispense de vérifier le
résultat.

Les invites supposent un agent de codage qui dispose d'un terminal, d'un accès au système de
fichiers et d'un accès au réseau. Elles ne dépendent d'aucun produit nommé, et en publier une
ne revient pas à recommander un fournisseur.

---

## 2. Le partage des responsabilités, et il n'est pas négociable

Si vous lancez un agent sur votre environnement, vous répondez de ce qu'il y fait, exactement
comme si vous aviez tapé les commandes vous-même. Les invites de ce dossier sont fournies en
l'état, sans garantie d'aucune sorte, expresse ou implicite, et leur auteur n'assume aucune
responsabilité au titre de leur emploi, de leurs effets, ni des dommages directs ou indirects
qui en résulteraient.

Trois conséquences pratiques :

1. Relisez l'invite avant de la coller. C'est du texte, rien de plus : il se modifie, et il se
   refuse.
2. N'accordez que les autorisations nécessaires, et retirez-les une fois la reproduction faite.
   Le jeu proposé au §4 est un point de départ à réduire, jamais à élargir sans motif.
3. Contrôlez chaque résultat. Un agent qui annonce avoir réussi une étape n'apporte aucune
   preuve : la preuve est ce que la base et l'écran montrent.

---

## 3. Ce que la profession impose, et qu'aucun agent ne lève

Les règles qui suivent sont celles du mémoire dont ce dépôt est l'annexe technique. Elles
s'appliquent de la même façon que vous reproduisiez à la main ou avec un agent.

L'intelligence artificielle « n'entre à aucun moment dans la chaîne de production d'un livrable
opposable, le motif n'étant pas sa maturité mais la supervision humaine qu'impose la
responsabilité professionnelle » (introduction générale du mémoire).

Quant à la responsabilité, elle ne change pas de mains : « Une erreur de calcul de la VL
imputable à un défaut de l'outil engage la responsabilité civile professionnelle du cabinet au
même titre qu'une erreur commise à la main. Il n'existe pas d'exonération par le
dysfonctionnement logiciel » (annexe 7 du mémoire, cadre légal). Ce qui est écrit là d'un
défaut de l'outil vaut mot pour mot d'un défaut de l'agent.

La norme professionnelle de management de la qualité, agréée par arrêté du 30 mai 2024 et
applicable depuis le 1er janvier 2025, impose « la revue des productions par le responsable de
mission avant transmission », et fait de l'outil une ressource technologique à évaluer
périodiquement. Rien ne part donc chez le client avant d'être passé sous les yeux du
responsable de mission.

Côté traçabilité, le journal d'audit enregistre « les sorties de tout traitement automatisé,
avec leurs paramètres et la validation ou le rejet motivé par le professionnel responsable »
(règlement (UE) 2024/1689, en vigueur depuis le 2 août 2024, régime des systèmes à haut risque
depuis le 2 août 2026). Ce que produit un agent est une sortie de traitement automatisé.

Reste ce qu'aucun outillage ne prend en charge, et qu'un agent ne prendra pas davantage : « Le
rattachement d'un compte à un poste du modèle prescrit, l'appréciation d'une valeur
d'expertise, la décision de conclure sur les comptes : ces actes engagent la responsabilité du
professionnel » (partie 2, chapitre 3 du mémoire).

---

## 4. Où passe la frontière, pour ce dépôt précisément

La reproduction décrite ici est un déploiement technique : créer un espace de travail, créer
les tables, charger les référentiels, publier les rapports. Aucun livrable opposable n'en sort,
et un agent peut donc l'exécuter sous votre surveillance.

Quatre étapes restent humaines, sans exception :

| Étape | Pourquoi elle ne se délègue pas |
|---|---|
| Accorder les droits sur le locataire et la capacité | Engage la sécurité et le secret professionnel |
| Rattacher un compte du client à un poste du modèle | Décision comptable, cf. §3 |
| Arrêter une forme de conclusion, viser un cycle | Acte qui engage votre responsabilité |
| Déclarer la reproduction conforme | C'est un constat, et un constat se vérifie |

Le jeu de données livré est fictif. Reproduire sur les données d'un client réel suppose d'avoir
réglé d'abord le secret professionnel, la minimisation et la base légale du traitement. Ce
dossier ne s'en occupe pas.

---

## 5. Avant de lancer quoi que ce soit

1. Travaillez sur un espace de travail dédié et vide, jamais sur un environnement qui porte des
   données de production.
2. Vérifiez que le compte employé n'a de droits que sur cet espace.
3. Lisez le `README.md` du dépôt en entier : il dit ce que la reproduction produit, et c'est à
   cela que vous comparerez le résultat de l'agent.
4. Gardez une trace de ce que l'agent exécute, pour pouvoir le rejouer ou l'expliquer plus tard.

Un agent accélère une reproduction que vous savez déjà faire. Si le déroulé vous échappe, ce
qu'il fait de travers vous échappera aussi, et ça se voit souvent plusieurs étapes plus loin.
