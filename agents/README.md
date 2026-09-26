# Reproduire avec un agent d'intelligence artificielle

Ce dossier contient des demandes prêtes à coller dans un agent de codage, et un exemple
d'autorisations à lui accorder.

**Rien ici n'est obligatoire.** Les douze étapes du mode opératoire se font entièrement à la main,
et le résultat est le même. Un agent est un facilitateur sur les étapes répétitives, jamais un
passage obligé.

**Lisez [l'avertissement](AVERTISSEMENT.md) avant tout.** Il porte le partage des responsabilités,
et il n'est pas une formalité.

---

## Ce qu'un agent fait, et ce qu'il ne fait pas

**Trois étapes sur douze.** Ce partage n'est pas une précaution de rédaction : il tient à ce que la
plateforme expose, et il a été établi lors d'une reproduction complète le 26/09/2026.

| # | L'étape | Confiable à un agent | Pourquoi |
|---|---|---|---|
| 1 | Ouvrir une capacité Fabric | Non | Engagement financier, et le portail demande votre compte |
| 2 | Faire activer les cinq réglages | Non | Réglages de votre locataire, tenus par votre administrateur |
| 3 | Créer l'espace de travail | Non | Lui affecter la capacité se fait au portail |
| **4** | **Copier ce dépôt sur votre compte** | **Oui** | [La demande](etape-04-copier-le-depot.md) |
| 5 | Connecter l'espace au dépôt | Non | Exige un jeton GitHub, qui est un secret personnel |
| 6 | Ramener les éléments | Non | Le bouton « Mettre à jour tout » n'a pas d'équivalent sûr |
| **7** | **Charger les données** | **Oui** | [La demande](etape-07-charger-les-donnees.md) |
| 8 | Connecter les fonctions à la base | Non | Se règle au portail, et commence par un simple contrôle |
| **9 et 10** | **Relier les modèles et les boutons** | **Oui** | [La demande](etape-09-et-10-relier.md) |
| 11 | Publier les deux écrans | Non | L'application et ses audiences se composent au portail |
| 12 | Passer la recette | Non | Douze actions à l'écran, et l'action 11 exige deux personnes |

**Ce que cela vous fait gagner**, mesuré le 26/09/2026 : environ 55 minutes de saisie et de
relecture sur les étapes 7, 9 et 10. Le temps d'attente de la machine, lui, ne change pas.

Le reste du parcours ne bouge pas. Un agent ne raccourcit ni l'ouverture de la capacité, ni les
réglages du locataire, ni la recette.

---

## Ce qu'il faut lui donner, et rien de plus

1. **Le dépôt cloné sur votre poste.**
2. **Le droit de lancer `python`, `git` et `sqlcmd` dans ce dossier**, et nulle part ailleurs.
   Un exemple est fourni dans [`permissions-exemple.json`](permissions-exemple.json).
3. **Vos cinq valeurs d'installation**, que `scripts/00_mes_identifiants.py` relève avec vous.

**Ce qu'il ne doit jamais recevoir :** votre jeton GitHub, un mot de passe, et le droit d'écrire
ailleurs que dans le dossier du dépôt.

---

## Les trois consignes qui évitent les ennuis

1. **Interdisez-lui de corriger un script.** Les scripts de ce dépôt refusent d'écrire quand ils ne
   reconnaissent pas un fichier : c'est une protection, pas une panne. Un agent serviable lèvera ce
   refus pour vous faire plaisir, et vous perdrez la dernière chose qui vous protégeait.
2. **Exigez la sortie brute, jamais un résumé.** « Tout s'est bien passé » ne se vérifie pas.
   `<n> source(s) reliées, 0 restant` se vérifie.
3. **Une étape à la fois, et vous lisez entre chaque.** Un agent qui enchaîne les douze étapes sans
   contrôle vous livre une installation dont personne n'a vu le détail.

---

## Les quatre contrôles qui vous reviennent entièrement

Quand l'agent a fini, ces quatre choses se regardent à l'écran. Aucune ne se délègue.

| Ce que vous ouvrez | Ce que vous devez voir |
|---|---|
| L'écran du réviseur | Vos dossiers, et non un écran vide. S'il est vide, `sql/90_vous_inscrire_aux_missions.sql` n'a pas été joué |
| L'écran du client | Des valeurs, et non des cases vides. Sinon le modèle du client n'a pas été actualisé |
| Un bouton qui écrit | Une phrase de confirmation en pied d'écran, et la ligne apparue dans la table |
| Un refus attendu | Le message en français, et non une erreur technique |

---

[L'avertissement, à lire en premier](AVERTISSEMENT.md) ·
[Revenir au sommaire](../README.md) ·
[Les douze étapes](../docs/faire/etape-01-ouvrir-la-capacite.md)
