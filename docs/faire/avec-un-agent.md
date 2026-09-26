# Reproduire la solution avec un agent d'intelligence artificielle

Cette page est facultative. **Les douze étapes se font entièrement à la main, sans agent et sans
rien y perdre.** Elle s'adresse à celui qui dispose déjà d'un agent de codage et se demande ce
qu'il peut raisonnablement lui confier.

Elle s'appuie sur une reproduction complète menée le 26/09/2026, où un agent a joué les étapes
qu'il sait jouer. Les chiffres donnés sont ceux qui ont été relevés.

**Les demandes prêtes à coller sont dans [`agents/`](../../agents/README.md)**, avec un exemple
d'autorisations et [l'avertissement](../../agents/AVERTISSEMENT.md) qui porte le partage des
responsabilités. Cette page-ci explique pourquoi le partage est celui-là.

---

## Ce qu'il faut savoir avant de lire la suite

**L'expert-comptable qui installe cette solution en répond.** Un agent ne partage ni votre
inscription au tableau, ni votre responsabilité professionnelle, ni votre secret professionnel.
Trois conséquences pratiques :

| Ce que fait l'agent | Ce qui reste à vous |
|---|---|
| Il joue des commandes que vous lui donnez | Décider qu'elles doivent être jouées, et sur quel espace |
| Il vous rend une sortie | Lire cette sortie et juger si elle est bonne |
| Il ne voit jamais l'écran | Ouvrir les deux écrans et vérifier qu'ils portent ce qu'ils doivent porter |

Aucune vérification de cette installation ne se délègue. L'agent accélère la saisie ; la revue
reste entière.

---

## Ce qu'un agent sait faire, et ce qu'il ne sait pas faire

Ce partage tient à ce que la plateforme expose, et non à une préférence.

| # | L'étape | Un agent peut-il la faire ? | Pourquoi |
|---|---|---|---|
| 1 | Ouvrir une capacité Fabric | **Non** | Engagement financier, et le portail Azure demande votre compte |
| 2 | Faire activer les cinq réglages | **Non** | Ce sont des réglages de votre locataire, tenus par votre administrateur |
| 3 | Créer l'espace de travail | Partiellement | L'API sait le créer, mais lui affecter la capacité se fait au portail |
| 4 | Copier ce dépôt sur votre compte | **Oui** | Ce sont des commandes Git, sur votre poste |
| 5 | Connecter l'espace au dépôt | **Non** | Il faut un jeton GitHub, qui est un secret personnel |
| 6 | Ramener les éléments | **Non** | Le bouton « Mettre à jour tout » n'a pas d'équivalent sûr |
| 7 | Charger les données | **Oui**, si vous lui ouvrez la base | 77 fichiers à jouer dans l'ordre, c'est exactement son emploi |
| 8 | Connecter les fonctions à la base | **Non** | Se règle au portail, et commence de toute façon par un simple contrôle |
| 9 et 10 | Relier les modèles et les boutons | **Oui** | Deux scripts fournis, qu'il lance et dont il vous lit la sortie |
| 11 | Publier les deux écrans | **Non** | L'application et ses audiences se composent au portail |
| 12 | Passer la recette | **Non** | Douze actions à l'écran, et l'action 11 exige deux personnes |

Trois étapes sur douze, et ce sont les plus répétitives.

---

## Ce que l'agent vous fait gagner, en minutes

Mesuré sur la reproduction du 26/09/2026. Le temps machine ne change pas : c'est le temps de saisie
et de relecture qui bouge.

| L'étape | À la main | Avec un agent | Ce qui est économisé |
|---|---|---|---|
| 7. Charger les données | 30 min, dont l'ouverture de 77 fichiers un par un | 98 s d'attente, et une commande | La copie et le collage, et l'ordre des fichiers qu'on se trompe à suivre |
| 9 et 10. Relier | 30 min, dont le relevé de cinq identifiants | 61 s d'attente, et deux commandes | Le report des identifiants, où une faute de frappe ne se voit pas |

**Le reste du parcours ne bouge pas.** Un agent ne raccourcit ni l'ouverture de la capacité, ni les
réglages du locataire, ni la recette.

---

## Comment lui donner le travail

### Ce qu'il lui faut, et rien de plus

1. **Le dépôt cloné sur votre poste**, à l'étape 4.
2. **Le droit de lancer `python` et `git`** dans ce dossier, et rien ailleurs.
3. **Vos cinq valeurs d'installation**, que `scripts/00_mes_identifiants.py` relève avec vous.

**Ce qu'il ne doit jamais recevoir :** votre jeton GitHub, votre mot de passe, et le droit d'écrire
ailleurs que dans le dossier du dépôt.

### L'étape 7, ce que vous lui demandez

> Dans le dépôt cloné, joue les fichiers de `sql/` sur ma base, dans cet ordre exact :
> `00_preparer_le_chargement.sql`, puis tout `10_referentiels/` par numéro croissant, puis tout
> `80_demonstration/` par numéro croissant, puis `99_terminer_le_chargement.sql`.
> Ne saute aucun fichier. Si l'un échoue, arrête-toi et donne-moi son nom et le message exact.
> À la fin, recopie-moi la sortie de `99_terminer_le_chargement.sql` sans la résumer.

**Ce que vous vérifiez vous-même**, et qui décide si l'étape est bonne : les deux premiers comptes
de cette sortie valent zéro, et les six comptes de contrôle égalent leur colonne « attendu ».

### Les étapes 9 et 10, ce que vous lui demandez

> Lance `python scripts/25_relier_le_modele.py --verifier`, montre-moi la sortie, et attends.

Vous lisez, vous décidez, puis :

> Maintenant relie, avec mes valeurs, puis relance `--verifier` et montre-moi les deux sorties.
> Fais ensuite la même chose avec `scripts/20_relier_les_boutons.py`.
> Ne modifie aucun autre fichier, et ne corrige rien de toi-même.

**Ce que vous vérifiez vous-même :** « restant à relier » et « identifiants inconnus » valent zéro
sur les deux scripts. Si « identifiants inconnus » n'est pas zéro, les scripts refusent d'écrire, et
c'est voulu : le dépôt a été modifié à la main quelque part.

---

## Les trois consignes qui évitent les ennuis

1. **Interdisez-lui de corriger un script.** Ces scripts refusent d'écrire quand ils ne
   reconnaissent pas un fichier. Un agent cherchant à vous satisfaire lèvera ce refus, et la
   protection tombe.
2. **Exigez la sortie brute, jamais un résumé.** « Tout s'est bien passé » ne se vérifie pas.
   `<n> source(s) reliées, 0 restant` se vérifie.
3. **Ne lui donnez jamais votre jeton GitHub.** L'étape 5 se fait à la main, et elle prend
   3 secondes de machine.

---

## Le contrôle final, qui vous revient entièrement

Quand l'agent a fini, quatre choses se regardent à l'écran, et elles ne se délèguent pas.

| Ce que vous ouvrez | Ce que vous devez voir |
|---|---|
| L'écran du réviseur | Vos dossiers, et non un écran vide. S'il est vide, l'étape 7 n'est pas finie : voir `sql/90_vous_inscrire_aux_missions.sql` |
| L'écran du client | Des valeurs, et non des cases vides. Sinon, le modèle du client n'a pas été actualisé |
| Un bouton qui écrit | Une phrase de confirmation en pied d'écran, et la ligne apparue dans la table |
| Un refus attendu | Le message en français, et non une erreur technique |

**Si l'une des quatre ne répond pas, reprenez l'étape correspondante à la main.** Le dépannage en
donne la cause probable.

---

Suite : [Dépannage](depannage.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](etape-01-ouvrir-la-capacite.md)
