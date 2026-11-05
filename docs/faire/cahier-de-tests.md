# Le cahier des tests d'acceptation

**Qui :** les personnes qui se serviront de la solution, chacune avec le compte que désigne le profil du test.
**Où :** dans l'espace reproduit, ou dans TEST pour une installation en 3 espaces, jamais dans PROD.
**Durée :** 24 heures de jeu en tout, soit 5 minutes par test scénarisé, 15 minutes par contrôle par recalcul et 45 minutes par parcours métier, réparties entre les comptes, estimation.

La phase, ses conditions d'entrée, les statuts, la criticité et la décision sont décrits dans
[Les tests d'acceptation, après la reproduction](tests-d-acceptation.md).

La copie à remplir est le classeur [`cahier-de-tests.xlsx`](cahier-de-tests.xlsx) : une ligne par test,
avec le résultat obtenu, le statut, l'anomalie, le testeur et la date, et une feuille de procès-verbal
qui compte les résultats.

Ce cahier est **indicatif**. Retirez ce qui ne concerne pas votre cabinet, ajoutez ce qui manque, et
gardez la trace de qui a testé quoi.

| La sorte de test | Tests |
|---|---|
| Les tests scénarisés | 152 |
| Les tests manuels des utilisateurs métier | 28 |
| **En tout** | **180** |

Les noms de profil désignent les comptes de la phase :

| Le profil | Le compte |
|---|---|
| Compte 1 | L'adresse `@vous` de `sql/90_vous_inscrire_aux_missions.sql` : les mandats d'associé et de préparateur des dossiers de démonstration |
| Compte 2 | L'adresse `@second` du même script : les mandats de chef de mission. En lecteur par l'application, dans le rôle `Reviseur` du modèle `conduite_de_mission` |
| Compte 3 | Un 3e membre de l'équipe, sans mandat au départ, en lecteur dans le rôle `Reviseur` ; certains tests le désignent à l'écran |
| Compte client | Un compte de l'audience client, en lecteur, dans le rôle de sécurité du véhicule de démonstration du modèle `restitution_client` |
| Analyste | La personne qui lit la base par SQL, pour l'étape de jeu 7, en 3 espaces seulement |

---

## Les tests scénarisés

Chaque test donne les actions à faire, avec le nom exact des boutons, et le résultat à obtenir. Quand la
solution affiche un message, le cahier le recopie tel quel : si vous lisez autre chose, le test est en
échec. Les parties variables d'un message s'écrivent entre chevrons, comme `<code>`.

Ces règles de l'écran valent pour chaque test, qu'il les rappelle ou non :

| Ce que dit le test | Ce que vous faites |
|---|---|
| « Saisissez » une valeur | Remplacez tout le contenu du champ : certains champs gardent la saisie du test précédent. Effacez un champ que le test dit de laisser vide. |
| « Choisissez » ou « cliquez » une ligne, ou un élément d'une liste | Regardez d'abord s'il est déjà choisi. S'il l'est, ne cliquez pas : un clic sur un élément déjà choisi le désélectionne. |
| Le clic est refusé | Le service affiche une bulle d'échec, et la page ne s'actualise pas. Cliquez le bouton « Actualiser » de la barre du rapport, en haut de l'écran, avant de lire la zone « Message de l'écran ». |
| Lire la zone « Message de l'écran » | Elle porte le dernier message posé pour votre compte sur le client choisi, depuis 30 minutes au plus. |

## Les tests manuels des utilisateurs métier

Ces tests ne donnent pas le détail des actions. L'utilisateur conduit le travail comme en mission, et
note ce qui l'a arrêté, ce qui lui a manqué et le temps passé.

| La nature | Ce que le testeur fait | Ce qu'il note |
|---|---|---|
| Parcours métier | Il conduit une partie de la mission sur le jeu de démonstration, dans l'ordre qu'il choisit | Ce qui l'a arrêté, ce qui lui a manqué, le temps passé, et si le résultat d'ensemble est atteint |
| Contrôle par recalcul | Il lit des montants à l'écran et refait le calcul à la main ou dans un tableur | L'écart entre son calcul et celui de la solution |

Notez les montants lus et votre calcul dans la colonne des constats. Chaque contrôle dit l'écart admis :
un écart au-delà est un échec.

## L'ordre de jeu

Jouez le cahier de haut en bas. Il suit l'ordre d'une mission : la lecture du client avant toute écriture,
le dossier et son acceptation, la révision, la valorisation, la validation, puis la réouverture d'un arrêté
clos, qui change ce que voit le client. Dans chaque étape de jeu, les tests scénarisés viennent d'abord,
puis les tests manuels, qui emploient l'état laissé par les premiers.

Le numéro d'un test commence par son étape de jeu : le test 3-07 est le 7e de l'étape 3.

| L'étape de jeu | Tests scénarisés | Tests manuels | Profils |
|---|---|---|---|
| 1. La lecture, avant toute écriture | 10 | 9 | Compte 1, Compte 3, Compte client |
| 2. Le dossier du client et son acceptation | 56 | 3 | Compte 1, Compte 2, Compte 3 |
| 3. La révision de l'arrêté | 44 | 7 | Compte 1, Compte 2 |
| 4. La valorisation de l'arrêté | 16 | 6 | Compte 1, Compte 2 |
| 5. La validation et la publication | 10 | 2 | Compte 1, Compte 2, Compte 3 |
| 6. La réouverture d'un arrêté clos | 11 | 1 | Compte 1, Compte 2 |
| 7. Le passage d'un espace à l'autre | 5 | 0 | Analyste |

## Les anomalies connues

Ces tests décrivent ce que la solution doit faire. Le code publié ne le fait pas encore : une installation
conforme les donne en échec. Jouez-les quand même, notez le résultat obtenu et portez l'échec à la feuille
« Anomalies » du classeur, avec l'origine « Solution ». Tant qu'une anomalie connue de criticité Bloquante ou
Majeure reste ouverte, la condition d'acceptation du procès-verbal n'est pas remplie ; le procès-verbal permet
alors une acceptation avec réserves.

| Le test | Ce que la solution fait aujourd'hui |
|---|---|
| 1-06. Aucun montant d'un arrêté non visé dans les historiques | Les historiques du rapport client portent aussi le 2025-12-31, arrêté non visé du jeu : le tableau des valeurs liquidatives, les graphiques d'évolution, du pilotage et des distributions lisent des tables reliées à l'entité seule, et non à l'arrêté visé. |
| 2-33. Réimport du questionnaire refusé en entier pour une seule réponse invalide | Le réimport est bien refusé en entier, mais son message est posé sous la cote du questionnaire, `ACC-<client>`, et non sous le client : la zone « Message de l'écran » ne l'affiche pas. |
| 2-34. Réimporter le questionnaire complété | Les réponses sont importées, mais le message de l'import est posé sous la cote du questionnaire, `ACC-<client>`, et non sous le client : la zone « Message de l'écran » ne l'affiche pas. |
| 3-11. Répondre en nombre aux questions d'un cycle par le classeur du dossier de travail | Le réimport réussit pour les onglets valides. La zone de message tient sur 2 lignes et la phrase nomme d'abord les onglets importés : la liste des onglets refusés ne se lit pas. |
| 3-21. Rattacher une pièce à la question de révision qu'elle justifie | La page « Pièce justificative » propose les questions du programme de révision, mais la fonction n'accepte que les questions des questionnaires d'acceptation et de maintien : le rattachement est refusé. |
| 3-34. Le visa d'un cycle attend toutes ses réponses et revient à un autre que son auteur | Les boutons de visa sont bien inactifs, mais la carte qui en donne la raison tient sur 1 ligne : la fin de la phrase, qui nomme la séparation des fonctions, ne se lit pas. |

---

## Étape de jeu 1. La lecture, avant toute écriture

### Le cloisonnement des dossiers entre les membres de l'équipe

#### 1-01. Un compte de l'équipe sans mandat ne voit aucun dossier

**Besoin :** Un membre du cabinet ne lit que les dossiers sur lesquels il tient un mandat.  
**Profil :** Compte 3 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 3 : un compte distinct des Comptes 1 et 2, qui ouvre l'application de conduite de mission dans les mêmes conditions qu'eux (même audience de l'application, même rôle de sécurité du modèle de conduite, rôle de lecteur et non membre de l'espace de travail). Aucun mandat ne porte son adresse de connexion : il n'est désigné sur aucun dossier.

1. Connectez-vous avec le Compte 3 et ouvrez l'application de conduite de mission.
2. Ouvrez la page « Client et Acceptation ».
3. Lisez la liste des clients.
4. Survolez le bouton « Désigner » de la section « Équipe de la mission » et lisez son infobulle.

**Vous devez obtenir :** La liste des clients ne porte aucune ligne : ni OMEGA-OPCI, ni OPCI-1, ni aucun autre client. L'infobulle du bouton « Désigner » porte le texte ci-contre.

```
Aucun client choisi dans la liste des clients.
```

Passé ☐ · Échec ☐ · Remarque :

### Le cloisonnement du client

#### 1-02. Le compte client n'ouvre que la restitution

**Besoin :** Le client lit l'état de son véhicule sans accéder au dossier de travail du cabinet.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client : compte de l'audience client de l'application publiée à l'étape 11 depuis l'espace où se joue la phase, avec le rôle de lecteur, jamais membre de l'espace, affecté au rôle « Client OMEGA-OPCI » du modèle `restitution_client` (étape 11, lignes 23-29, 57-61 et 86-88). Le lien du rapport « Conduite de mission », copié dans l'espace par le compte 1 et transmis au testeur.

1. Connectez-vous avec le compte client et ouvrez l'application.
2. Lisez la liste des pages du volet de gauche.
3. Ouvrez chacune des 8 pages et cherchez un bouton.
4. Collez dans la barre d'adresse du navigateur le lien du rapport « Conduite de mission ».

**Vous devez obtenir :** Le volet porte les 8 pages de la restitution, dans cet ordre : « La valeur de la part », « La rationalisation de la VL », « Le patrimoine », « Les participations », « Le pilotage », « Les ratios », « Le DIP », « La distribution ». Aucune page du rapport « Conduite de mission » n'y figure, par exemple « Client et Acceptation », « Révision » ou « Valorisation ». Hors la barre des 8 pages, aucune page ne porte de bouton. Le lien du rapport « Conduite de mission » n'ouvre pas ce rapport pour ce compte.

Passé ☐ · Échec ☐ · Remarque :

#### 1-03. La liste « Véhicule » ne porte que le véhicule du rôle

**Besoin :** Un client ne lit aucune donnée d'un autre véhicule du cabinet.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client affecté au rôle « Client OMEGA-OPCI », lecteur, jamais membre de l'espace. Jeu de démonstration chargé, qui porte 2 véhicules, « OPCI OMEGA » et « OPCI SIGMA », et modèle `restitution_client` actualisé (étapes 7 et 9-10).

1. Ouvrez la page « La valeur de la part ».
2. Ouvrez la liste « Véhicule » et lisez les véhicules proposés.
3. Lisez la case « Vehicule » du bandeau d'en-tête.

**Vous devez obtenir :** La liste « Véhicule » porte « OPCI OMEGA » et lui seul : « OPCI SIGMA », second véhicule du jeu, n'y figure pas. Le bandeau affiche « OPCI OMEGA ». Une liste qui porte aussi « OPCI SIGMA » désigne un compte administrateur, membre ou contributeur de l'espace de travail : la sécurité au niveau des lignes ne restreint que les lecteurs.

Passé ☐ · Échec ☐ · Remarque :

#### 1-04. Deux clients, chacun ne lit que son véhicule

**Besoin :** Avec plusieurs clients, chaque rôle de sécurité restreint son client à son véhicule ; un rôle oublié ouvre les données de tous les clients.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Le jeu livré porte 2 véhicules, « OPCI OMEGA » (code OMEGA-OPCI) et « OPCI SIGMA » (code OPCI-1), et un seul rôle, « Client OMEGA-OPCI ». Il faut en plus : (1) un 2e rôle dans le modèle `restitution_client`, filtré sur le code OPCI-1 de la table des entités, créé en modifiant le modèle dans le service ou dans Power BI Desktop (étape 11, lignes 66-79) ; (2) un 2e compte de l'audience client, lecteur, jamais membre de l'espace, affecté à ce rôle par « Security » puis « Assign » (étape 11, lignes 57-61). Le jeu ne porte aucun arrêté visé d'OPCI SIGMA : les arrêtés de mission sont tous ceux d'OMEGA-OPCI (46_arrete_mission.sql, lignes 9-13) et le seul arrêté d'OPCI-1 est hors mission (35_ref_arrete.sql, ligne 89).

1. Avec le compte client du rôle « Client OMEGA-OPCI », ouvrez la page « La valeur de la part », puis les listes « Véhicule » et « Arrêté ».
2. Avec le 2e compte client, ouvrez la même page ; dans « Véhicule », choisissez « OPCI SIGMA ».
3. Avec le 2e compte, ouvrez les listes « Véhicule » et « Arrêté ».
4. Avec le 2e compte, parcourez les 8 pages et lisez les cartes, les tableaux et les graphiques.

**Vous devez obtenir :** Compte du rôle « Client OMEGA-OPCI » : « Véhicule » porte « OPCI OMEGA » seul, « Arrêté » ne porte que des arrêtés d'OPCI OMEGA. 2e compte : « Véhicule » porte « OPCI SIGMA » seul ; la liste « Arrêté » dépliée ne propose aucune entrée, le jeu ne portant aucun arrêté visé d'OPCI SIGMA ; aucune page ne porte un montant, un actif ou une filiale d'OPCI OMEGA (« SCI OMEGA 1 » à « SCI OMEGA 11 », « OMEGA 12 SIIC »).

Passé ☐ · Échec ☐ · Remarque :

### Les arrêtés que lit le client

#### 1-05. La liste « Arrêté » ne propose que les arrêtés visés

**Besoin :** Le client ne lit que des arrêtés dont le cabinet a visé la clôture.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Le jeu porte 2 arrêtés d'OMEGA-OPCI ouverts dont le visa de clôture courant n'est pas « VISE » : le 2025-12-31, rouvert, dont le dernier visa de clôture est « RENVOYE », et le 2026-06-30, sans visa de clôture et sans balance.

1. Ouvrez la page « La valeur de la part ».
2. Ouvrez la liste « Arrêté » et lisez les entrées dans l'ordre.
3. Choisissez « Dernier arrêté » et lisez la case « Arrete choisi » du bandeau.
4. Essayez de cocher 2 arrêtés à la fois.

**Vous devez obtenir :** La liste porte 3 entrées, dans cet ordre : « Dernier arrêté », « 2023-12-31 », « 2022-12-31 ». Ni 2025-12-31 ni 2026-06-30 n'y figurent. Avec « Dernier arrêté », le bandeau affiche « 2024-12-31 ». La liste n'accepte qu'un arrêté à la fois.

Passé ☐ · Échec ☐ · Remarque :

#### 1-06. Aucun montant d'un arrêté non visé dans les historiques

**Besoin :** Aucun montant d'un arrêté que le cabinet n'a pas visé ne parvient au client, pas même dans un graphique d'évolution.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Arrêtés non visés du jeu : 2025-12-31 et 2026-06-30.

1. Ouvrez la page « La valeur de la part ».
2. Lisez la colonne « Arrêté » du tableau « L'historique des valeurs liquidatives ».
3. Lisez les arrêtés en abscisse des graphiques « Évolution de la valeur de la part, par arrêté » et « Évolution du rendement, distribution comprise, par arrêté ».
4. Ouvrez la page « Le pilotage » ; lisez les arrêtés du graphique « Trésorerie et résultat locatif du groupe, par arrêté ».
5. Ouvrez la page « La distribution » ; lisez les dates du graphique « Distributions versees, par part et par date de valeur ».

**Vous devez obtenir :** Aucun tableau ni graphique ne porte le 2025-12-31 ni le 2026-06-30, quel que soit l'arrêté choisi : les historiques ne portent que les arrêtés visés que la liste « Arrêté » propose, 2022-12-31, 2023-12-31 et 2024-12-31, ce dernier sous « Dernier arrêté ».

**Anomalie connue :** Les historiques du rapport client portent aussi le 2025-12-31, arrêté non visé du jeu : le tableau des valeurs liquidatives, les graphiques d'évolution, du pilotage et des distributions lisent des tables reliées à l'entité seule, et non à l'arrêté visé.

Passé ☐ · Échec ☐ · Remarque :

#### 1-07. Le bandeau dit l'arrêté lu, sa clôture visée et sa publication

**Besoin :** Le client sait quel arrêté il lit, quand le cabinet en a visé la clôture et quand il lui a été publié.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué.

1. Ouvrez la page « La valeur de la part » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Lisez les 4 cases du bandeau d'en-tête : « Vehicule », « Arrete choisi », « Cloture visee le », « Publie le ».
3. Dans « Arrêté », choisissez « Dernier arrêté » et lisez de nouveau le bandeau.

**Vous devez obtenir :** Étape 2 : « Vehicule » OPCI OMEGA ; « Arrete choisi » 2023-12-31 ; « Cloture visee le » 06/09/2026 ; « Publie le » 06/09/2026 16:27. Étape 3 : « Arrete choisi » 2024-12-31 ; « Cloture visee le » 06/09/2026 ; « Publie le » 06/09/2026 16:27.

Passé ☐ · Échec ☐ · Remarque :

### La lecture de l'état du véhicule

#### 1-08. Les 8 pages portent des valeurs au dernier arrêté

**Besoin :** Le client lit sur chaque page la réponse à la question qu'elle traite.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué.

1. Dans « Arrêté », choisissez « Dernier arrêté ».
2. Ouvrez les 8 pages l'une après l'autre et lisez les cartes, les tableaux et les graphiques de chacune.
3. Lisez la note du bas de chaque page.

**Vous devez obtenir :** Chaque page porte des montants dans ses cartes et des lignes dans ses tableaux, sauf ce que le jeu ne charge pas. Sur « La valeur de la part », la carte « Distribution par part » est vide : aucune distribution n'est datée du 2024-12-31. Sur « Le DIP », la carte « Distribution par part » est vide pour la même raison, la carte « Mouvements de la periode » vaut 0 et le tableau « Acquisitions, cessions et travaux de la période » est vide, le jeu ne chargeant aucun mouvement d'actif ; le tableau « 6. Les dividendes à verser : l'obligation minimale, article L. 214-69 du CMF » est vide. Sur « La distribution », « Obligation minimale » vaut 0,00 et le tableau « Le calcul de l'obligation minimale, fraction par fraction » est vide : l'obligation n'est chargée que pour l'exercice 2025-12-31. Sur « Les ratios », chaque ligne porte la conclusion « calcul à valider ». La note du bas des 8 pages est le message exact.

```
Jeu de démonstration simulé. Valeurs relevées sur la base au dernier arrêté choisi ; aucune écriture ne découle de ce rapport.
```

Passé ☐ · Échec ☐ · Remarque :

### Les arrêtés que lit le client

#### 1-09. Le choix d'un arrêté aligne les pages

**Besoin :** Le client lit l'arrêté qui l'intéresse sur toutes les pages, sans le choisir de nouveau à chaque page.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué.

1. Ouvrez la page « La valeur de la part » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Ouvrez l'une après l'autre « La rationalisation de la VL », « Le patrimoine », « Les participations », « Le pilotage », « Les ratios » et « Le DIP ».
3. Sur chacune, lisez la liste « Arrêté » et la case « Arrete choisi » du bandeau.
4. Sur « La rationalisation de la VL », choisissez « 2022-12-31 » et lisez les cartes et le tableau.

**Vous devez obtenir :** Étapes 2 et 3 : chaque page affiche 2023-12-31 dans « Arrêté » et dans « Arrete choisi », sans nouveau choix. Étape 4 : les cartes et le tableau « La feuille de rationalisation, ligne à ligne » sont vides ; le 2022-12-31 est le premier arrêté du véhicule qui porte balance, et la rationalisation part de l'arrêté précédent. La page « La distribution » n'entre pas dans ce test : elle ne porte que le dernier exercice annuel visé.

Passé ☐ · Échec ☐ · Remarque :

### La lecture de l'état du véhicule

#### 1-10. La simulation de distribution suit le curseur, de l'obligation au plafond

**Besoin :** Le client mesure ce que chaque porteur recevrait selon le montant distribué, entre ce qui est dû et ce qui est possible, sans qu'aucune décision n'en découle.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué.

1. Ouvrez la page « La distribution » ; dans « Arrêté », choisissez « Dernier arrêté ».
2. Sans toucher le curseur, lisez les cartes « Obligation minimale », « Plafond distribuable » et « Montant simule ».
3. Faites glisser la poignée droite du curseur « Montant a distribuer, de l'obligation au plafond » sur un montant compris entre les 2 bornes ; lisez « Montant simule » et le tableau « Repartition par porteur ».
4. Faites glisser la poignée droite en butée à droite ; lisez « Montant simule ».

**Vous devez obtenir :** Étape 2 : « Obligation minimale » vaut 0,00, et « Montant simule » est égal à « Obligation minimale ». Étape 3 : « Montant simule » est égal au plus grand montant proposé par le curseur qui ne dépasse pas la poignée droite, soit le montant de la poignée quand elle s'arrête sur un montant proposé ; le curseur propose l'obligation, le plafond et, entre les 2, les multiples d'un pas égal à la plus grande puissance de 10 qui ne dépasse pas l'écart des 2 bornes divisé par 200, 1,00 au moins ; le tableau porte 4 lignes, « Institutionnel A », « Institutionnel B », « Famille C » et « Personne physique D », dont les montants suivent le curseur. Étape 4 : « Montant simule » est égal à « Plafond distribuable », borne que le curseur atteint exactement. Si « Plafond distribuable » est inférieur à « Obligation minimale », le curseur ne propose aucun montant. La note de la page est le message exact.

```
Simulation. Le curseur porte les montants en euros, de l'obligation minimale, article L. 214-69 du code monétaire et financier, au plafond des sommes distribuables du tableau 333-1. Aucun versement n'en découle et aucune écriture n'est générée : la décision de distribution appartient à l'organe compétent.
```

Passé ☐ · Échec ☐ · Remarque :

#### 1-11. Le client lit l'état de son véhicule

**Nature :** Parcours métier  
**Besoin :** Le client trouve seul, dans l'écran qui lui est remis, la réponse aux questions qu'il pose au cabinet sur son véhicule.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Aucune aide du cabinet pendant le parcours.

1. Objectif : pour l'arrêté 2023-12-31, puis pour « Dernier arrêté », répondre par écrit, avec le seul rapport, à 7 questions : combien vaut la part et ce qu'elle a rapporté ; pourquoi sa valeur a bougé depuis l'arrêté précédent ; ce que le véhicule détient et à quelle valeur ; ce que valent les filiales ; comment le groupe se comporte en exploitation ; si les ratios réglementaires sont respectés ; de quoi le document d'information périodique est fait. Pour « Dernier arrêté » seulement, répondre à une 8e question : combien distribuer.
2. Périmètre : le véhicule OPCI OMEGA, les 8 pages de la restitution, en lecture seule, dans l'ordre que vous choisissez.
3. Pour chaque réponse, notez la page et le visuel qui la portent, et le temps passé.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté, ce qui lui a manqué et le temps passé par question. Résultat d'ensemble attendu : chaque question trouve sa réponse sur la page qui la traite, dans l'ordre « La valeur de la part », « La rationalisation de la VL », « Le patrimoine », « Les participations », « Le pilotage », « Les ratios », « Le DIP », « La distribution » ; la page « La distribution » ne porte que le dernier exercice annuel visé ; ce que le dossier ne porte pas est dit à l'écran : la note de la page « Le pilotage » nomme le taux d'occupation, la balance âgée des locataires, le délai de règlement et l'échéancier des baux, la rubrique 7 de la page « Le DIP » renvoie à la société de gestion, et chaque ratio porte « calcul à valider ».

Passé ☐ · Échec ☐ · Constats :

### Les montants que le client refait à la main, tests manuels

#### 1-12. La valeur liquidative se recalcule depuis l'actif net et les parts

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie que la valeur de sa part découle de l'actif net réévalué et du nombre de parts, et que l'écart et le rendement découlent de la valeur précédente.  
**Profil :** Compte client · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « La valeur de la part » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez les cartes « ANR de l'arrete », « Parts à l'arrêté », « VL de l'arrete », « Ecart de VL » et « Distribution par part ».
3. Dans le tableau « L'historique des valeurs liquidatives », relevez les lignes 2022-12-31 et 2023-12-31.
4. Survolez la barre 2023-12-31 du graphique « Évolution du rendement, distribution comprise, par arrêté » et relevez le rendement.
5. Dans le tableur, refaites les 3 calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées : « VL de l'arrete » = « ANR de l'arrete » / « Parts à l'arrêté », arrondi au centime ; « Ecart de VL » = valeur liquidative du 2023-12-31 moins celle du 2022-12-31, lues au tableau ; rendement du 2023-12-31 = (valeur liquidative 2023 moins valeur liquidative 2022, plus distribution par part 2023) / valeur liquidative 2022. Écart attendu : 0,00 sur la valeur liquidative et sur l'écart de valeur ; 0,01 point au plus sur le rendement, la carte « Distribution par part » étant arrondie à 2 décimales. Valeurs du jeu : « Parts à l'arrêté » 1 407 990 ; « Distribution par part » 5,08, soit 7 146 138,94 de distributions datées du 2023-12-31 divisés par 1 407 990 parts. Les cartes et la ligne 2023-12-31 du tableau portent les mêmes montants.

Passé ☐ · Échec ☐ · Constats :

#### 1-13. La rationalisation de la VL boucle

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie que les causes listées expliquent toute la variation de l'actif net depuis l'arrêté précédent.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « La rationalisation de la VL » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez les cartes « ANR precedent », « Variation expliquee », « ANR constate » et « Ecart de bouclage ».
3. Relevez les 11 lignes du tableau « La feuille de rationalisation, ligne à ligne ».
4. Ouvrez la page « La valeur de la part » ; relevez « ANR de l'arrete » au 2022-12-31, puis au 2023-12-31.
5. Dans le tableur, refaites les calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 sur chacune : la ligne « Actif net réévalué de clôture » égale la ligne « Actif net réévalué d'ouverture » augmentée des 9 lignes de causes, de « Souscriptions » à « Intérêts internes éliminés (produit mère, charge filiales) » ; « Variation expliquee » = « Actif net réévalué de clôture » moins « ANR precedent » ; « Ecart de bouclage » = « ANR precedent » plus « Variation expliquee » moins « ANR constate » ; « ANR precedent » égale « ANR de l'arrete » du 2022-12-31, et « ANR constate » celui du 2023-12-31. La carte « Ecart de bouclage » affiche 0,00, comme l'énonce la note de lecture de la page ; un autre montant est noté avec sa valeur.

Passé ☐ · Échec ☐ · Constats :

#### 1-14. La valeur des titres de filiales se recalcule

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie que la valeur de chaque participation découle de l'actif net réévalué de la filiale et de la quote-part détenue, et que les totaux sont la somme des filiales.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « Les participations » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez les cartes « Filiales detenues », « Total valeur actuelle des titres », « Total coût des titres » et « Total différence sur titres ».
3. Relevez toutes les lignes du tableau « Filiale par filiale, triées par différence sur titres ».
4. Notez au classeur la ligne « SCI OMEGA 1 » : elle sert au test « Un même montant de titres à l'écran du réviseur et à celui du client ».
5. Dans le tableur, refaites les calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées, ligne par ligne : « Actif net réévalué » = « Capitaux propres » + « Différences d'estimation » ; « Valeur actuelle des titres » = « Actif net réévalué » × « Quote-part », arrondi au centime et ramené à 0,00 quand le produit est négatif ; « Différence sur titres » = « Valeur actuelle des titres » moins « Coût des titres ». Identités sur les cartes : « Filiales detenues » = nombre de lignes du tableau ; chacune des 3 autres cartes = somme de sa colonne. Écart attendu : 0,00.

Passé ☐ · Échec ☐ · Constats :

#### 1-15. Un même montant de titres à l'écran du réviseur et à celui du client

**Nature :** Contrôle par recalcul  
**Besoin :** Le client lit la valeur que le cabinet a revue, sans écart entre l'écran du réviseur et le sien.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 1 inscrit aux missions par sql/90_vous_inscrire_aux_missions.sql. Test « La valeur des titres de filiales se recalcule » joué : la ligne « SCI OMEGA 1 » de la page « Les participations » au 2023-12-31 est notée au classeur. Aucun test des groupes 2 à 5 joué depuis l'actualisation du modèle `restitution_client`.

1. Ouvrez le rapport « Conduite de mission », page « Valorisation ».
2. Dans « VÉHICULE », choisissez « OMEGA-OPCI · OPCI OMEGA ».
3. Dans « ARRÊTÉ », choisissez « 31/12/2023 ».
4. Dans la barre d'étapes, cliquez sur « Valoriser les titres ».
5. Dans le tableau des titres, relevez la ligne OMEGA-SCI-1 : « Quote-part », « Actif net réévalué », « Valeur actuelle des titres », « Titres au compte 254 », « Différence au 275 ».
6. Comparez-la à la ligne « SCI OMEGA 1 » notée au classeur.

**Ce que vous comparez ou notez :** Écart attendu 0,00 sur chaque paire : « Actif net réévalué » du réviseur et « Actif net réévalué » du client ; « Valeur actuelle des titres » et « Valeur actuelle des titres » ; « Titres au compte 254 » et « Coût des titres » ; « Différence au 275 » et « Différence sur titres ». La quote-part est la même. OMEGA-SCI-1 est le code de la filiale dénommée « SCI OMEGA 1 ».

Passé ☐ · Échec ☐ · Constats :

#### 1-16. Les totaux du pilotage égalent la somme des sociétés

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie que les chiffres du groupe sont la somme de ses sociétés, et que le résultat locatif se lit dans les loyers, l'entretien et les intérêts.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « Le pilotage » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez les cartes « Tresorerie du groupe », « Emprunts bancaires du groupe », « Loyers de la periode » et « Resultat locatif net ».
3. Relevez toutes les lignes du tableau « La situation financière et locative, société par société ».
4. Survolez la barre 2023-12-31 du graphique « Trésorerie et résultat locatif du groupe, par arrêté » et relevez ses 2 montants.
5. Dans le tableur, refaites les calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 : sur chaque ligne, « Résultat locatif » = « Loyers » moins « Charges d'entretien » moins « Intérêts » ; « Tresorerie du groupe » = somme de la colonne « Trésorerie » ; « Emprunts bancaires du groupe » = somme de « Emprunt bancaire » ; « Loyers de la periode » = somme de « Loyers » ; « Resultat locatif net » = somme de « Résultat locatif » ; la barre 2023-12-31 du graphique porte les montants de « Tresorerie du groupe » et de « Resultat locatif net ».

Passé ☐ · Échec ☐ · Constats :

#### 1-17. La différence d'estimation de chaque actif se recalcule

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie que la différence d'estimation de chaque actif, et de chaque famille, est l'écart entre valeur actuelle et valeur comptable.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « Le patrimoine » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez toutes les lignes du tableau « Les actifs, triés par différence d'estimation ».
3. Relevez les lignes de famille et la ligne de total du tableau « Les 3 familles de détention, valeur comptable et valeur actuelle ».
4. Dans le tableur, refaites les calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 : sur chaque actif, « Différence d'estimation » = « Valeur actuelle » moins « Valeur comptable » ; sur chaque famille, « Total différence d'estimation » = « Total valeur actuelle » moins « Total valeur comptable » ; la ligne de total du tableau des familles égale la somme de ses lignes de famille, colonne par colonne.

Passé ☐ · Échec ☐ · Constats :

#### 1-18. Chaque ratio se recalcule depuis son numérateur et son dénominateur

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie chaque ratio réglementaire et sait lesquels le cabinet doit encore valider.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur.

1. Ouvrez la page « Les ratios » ; dans « Arrêté », choisissez « 2023-12-31 ».
2. Relevez les 4 compteurs « Ratios calcules », « Ratios respectes », « Ratios non respectes » et « Ratios a valider ».
3. Relevez les lignes du tableau « Le suivi des ratios à l'arrêté ».
4. Dans le tableur, refaites les calculs de l'attendu.

**Ce que vous comparez ou notez :** Identités vérifiées : sur chaque ligne, « Valeur » = « Numérateur » / « Dénominateur », écart attendu de 0,01 point au plus, la valeur étant affichée à 2 décimales ; « Ratios calcules » = nombre de lignes du tableau = « Ratios respectes » + « Ratios non respectes » + « Ratios a valider » + nombre de lignes conclues « non calculable ». Sur le jeu, chaque ligne porte « calcul à valider » : « Ratios a valider » est égal à « Ratios calcules », « Ratios respectes » et « Ratios non respectes » valent 0.

Passé ☐ · Échec ☐ · Constats :

#### 1-19. La répartition par porteur se recalcule

**Nature :** Contrôle par recalcul  
**Besoin :** Le client vérifie la part de la distribution simulée qui revient à chaque porteur, au prorata de ses parts.  
**Profil :** Compte client · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte client du rôle « Client OMEGA-OPCI ». Jeu de démonstration chargé et modèle `restitution_client` actualisé ; aucun test du groupe 5 joué. Un tableur. Les parts des 4 porteurs à la date du dernier arrêté, données par le fichier du dépôt sql/80_demonstration/56_mouvement_porteur.sql, lignes 11 à 14 : Institutionnel A 709 826 ; Institutionnel B 419 018 ; Famille C 183 892 ; Personne physique D 95 254 ; total 1 407 990.

1. Ouvrez la page « La distribution » ; dans « Arrêté », choisissez « Dernier arrêté ».
2. Placez la poignée droite du curseur « Montant a distribuer, de l'obligation au plafond » sur un montant différent de 0,00 ; relevez « Montant simule ».
3. Relevez les 4 lignes et la ligne de total du tableau « Repartition par porteur ».
4. Dans le tableur, calculez pour chaque porteur « Montant simule » × parts du porteur / 1 407 990, arrondi au centime.

**Ce que vous comparez ou notez :** Identités vérifiées : chaque ligne égale le calcul de l'étape 4, écart attendu 0,00 ; la ligne de total égale « Montant simule », écart 0,00 ; la somme des 4 lignes s'écarte de « Montant simule » de 0,02 au plus, chaque ligne étant arrondie au centime. Le total de 1 407 990 parts égale « Parts à l'arrêté » de la page « La valeur de la part » au même arrêté.

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 2. Le dossier du client et son acceptation

### La création du dossier client

#### 2-01. Création refusée tant qu'un champ obligatoire manque

**Besoin :** Un dossier ne se crée qu'avec l'identité complète du client : dénomination, adresse et dirigeant.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte 1 inscrit associé et collaborateur des dossiers de démonstration à l'installation (étape 7). Aucun client UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Dossier » de la barre d'étapes, puis le bouton « Nouveau dossier ».
3. Saisissez « Code du client » : UAT-OPCI et « Forme du véhicule » : SPPICAV. Laissez les autres champs vides ; effacez tout champ qui garderait une saisie antérieure.
4. Cliquez « Créer le dossier ».
5. Lisez la zone « Message de l'écran », puis la liste des clients.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre : les 6 champs manquants y sont nommés dans l'ordre du formulaire. La liste des clients ne porte pas UAT-OPCI.

```
Champs obligatoires à remplir : Dénomination, Adresse, Code postal, Ville, Nom du dirigeant, Qualité du dirigeant.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-02. Création refusée pour un code déjà employé

**Besoin :** Un client se crée une seule fois : son code est sa clé dans tout le dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Jeu de démonstration chargé : le client OMEGA-OPCI (dénomination OPCI OMEGA) existe.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Étape « Dossier », bouton « Nouveau dossier ».
3. « Code du client » et « Forme du véhicule » gardent UAT-OPCI et SPPICAV du test « Création refusée tant qu'un champ obligatoire manque ». Remplacez le contenu de « Code du client » par OMEGA-OPCI ; vérifiez que « Forme du véhicule » porte SPPICAV, sinon remplacez son contenu par SPPICAV. Saisissez « Dénomination » : OPCI essai ; « Forme sociale » : SA ; « Adresse » : 1 rue de l'Essai ; « Code postal » : 75001 ; « Ville » : Paris ; « Pays » : FR ; « Nom du dirigeant » : Société de gestion essai ; « Qualité du dirigeant » : société de gestion.
4. Cliquez « Créer le dossier ».
5. Lisez la zone « Message de l'écran ». Cliquez OMEGA-OPCI dans la liste des clients, puis l'étape « Dossier » de la barre d'étapes, et lisez l'en-tête de la fiche.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Aucun second client OMEGA-OPCI n'apparaît ; l'en-tête de la fiche porte toujours « OMEGA-OPCI · OPCI OMEGA ».

```
Ce code existe déjà. Un client se crée une fois ; pour le modifier, passez par les référentiels.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-03. Création refusée pour un FPI déclaré avec un SIREN

**Besoin :** Le dossier respecte la forme du véhicule : un FPI n'a ni forme sociale ni SIREN.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Aucun client UAT-FPI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Étape « Dossier », bouton « Nouveau dossier ».
3. Les champs gardent les saisies du test « Création refusée pour un code déjà employé ». Remplacez le contenu de « Code du client » par UAT-FPI, de « Dénomination » par FPI essai et de « Forme du véhicule » par FPI. Saisissez « SIREN » : 123456789. Effacez « Forme sociale », qui garde SA. Vérifiez que « Adresse », « Code postal », « Ville », « Pays », « Nom du dirigeant » et « Qualité du dirigeant » portent 1 rue de l'Essai, 75001, Paris, FR, Société de gestion essai et société de gestion, sinon remplacez leur contenu par ces valeurs.
4. Cliquez « Créer le dossier ».
5. Lisez la zone « Message de l'écran » et la liste des clients.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La liste des clients ne porte pas UAT-FPI.

```
Un FPI n'a ni forme sociale ni SIREN.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-04. Créer le dossier d'un nouveau client

**Besoin :** Ouvrir un dossier client le dote aussitôt de son questionnaire d'acceptation et de son chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 1 inscrit associé et collaborateur des dossiers de démonstration (étape 7). Aucun client UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Étape « Dossier », bouton « Nouveau dossier ».
3. Les champs gardent les saisies du test « Création refusée pour un FPI déclaré avec un SIREN ». Remplacez le contenu de « Code du client » par UAT-OPCI, de « Dénomination » par OPCI UAT, de « Forme du véhicule » par SPPICAV et de « Nom du dirigeant » par Société de gestion UAT. Effacez « SIREN ». Saisissez « Forme sociale » : SA et « Contact, nom » : Service comptable. Vérifiez que « Adresse », « Code postal », « Ville », « Pays » et « Qualité du dirigeant » portent 1 rue de l'Essai, 75001, Paris, FR et société de gestion, sinon remplacez leur contenu par ces valeurs. Laissez « Site SharePoint des pièces » vide.
4. Cliquez « Créer le dossier » et lisez la zone « Message de l'écran ».
5. Cliquez UAT-OPCI dans la liste des clients, puis l'étape « Dossier » : lisez la fiche, le tableau « Rôles du dossier » et l'alerte de la section « Équipe de la mission ».
6. Cliquez l'étape « Questionnaire et pièces » et lisez la ligne placée sous l'en-tête de l'étape, au-dessus de la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. La liste des clients porte UAT-OPCI, colonne « Acceptation » : En cours. La fiche porte « Code » : UAT-OPCI ; « Forme » : SPPICAV · SA ; « Clôture · VL » : 31/12 · VL à fixer ; « Site SharePoint des pièces » : aucun (Modifier). Le tableau « Rôles du dossier » porte « Chef de mission » : l'adresse de connexion du Compte 1, état « désigné » ; « Associé signataire » et « Collaborateur » : « Non désigné », état « à désigner ». L'alerte de l'équipe porte « 2 rôle(s) à désigner : le visa attend un associé signataire. ». L'étape « Questionnaire et pièces » porte, sous son en-tête, « 0 sur 110 répondue · 0 pièce · une ligne par question, on y répond directement ».

```
Client UAT-OPCI créé, vous en êtes le chef de mission. Questionnaire d'acceptation ouvert : 110 questions. Passez à l'étape 3.
```

Passé ☐ · Échec ☐ · Remarque :

### Le cloisonnement des dossiers entre les membres de l'équipe

#### 2-05. Un dossier reste invisible au membre qui n'y tient aucun rôle

**Besoin :** Un dossier n'est lu que par l'équipe qui y est désignée.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Le Compte 2 n'est désigné sur aucun rôle de UAT-OPCI.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Lisez la liste des clients.

**Vous devez obtenir :** La liste des clients du Compte 2 porte OMEGA-OPCI et OPCI-1 ; elle ne porte pas UAT-OPCI.

Passé ☐ · Échec ☐ · Remarque :

### La fiche du client

#### 2-06. Modifier la fiche du client sans ressaisir les champs inchangés

**Besoin :** Un champ de l'identité du client se corrige sans ressaisir les autres, et un champ facultatif s'efface.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier », bouton « Modifier le dossier ».
3. Saisissez « Adresse » : 5 rue de l'Essai et « Contact, nom » : - (un tiret). Laissez tous les autres champs vides.
4. Cliquez « Enregistrer les modifications » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Dossier » et lisez la fiche.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. La fiche porte « Adresse » : 5 rue de l'Essai ; « Contact » ne porte plus « Service comptable » (champ effacé) ; « Dirigeant » : Société de gestion UAT ; « Forme » : SPPICAV · SA ; « Code » : UAT-OPCI. L'en-tête porte toujours « UAT-OPCI · OPCI UAT ».

```
Informations de UAT-OPCI mises à jour. Le code du client ne change pas.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-07. Modification refusée pour une forme de véhicule autre que SPPICAV ou FPI

**Besoin :** Un client du cabinet est un véhicule OPCI : SPPICAV ou FPI.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier », bouton « Modifier le dossier ».
3. Saisissez « Forme du véhicule » : SCI. Effacez « Adresse » et « Contact, nom », qui gardent la saisie du test « Modifier la fiche du client sans ressaisir les champs inchangés » ; laissez les autres champs vides.
4. Cliquez « Enregistrer les modifications » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Dossier » et lisez la fiche.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La fiche porte toujours « Forme » : SPPICAV · SA.

```
Un client est un véhicule : SPPICAV ou FPI.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-08. Lien de site refusé quand il n'est pas celui d'un site SharePoint

**Besoin :** Le dossier ne rattache au client qu'une adresse de site SharePoint, où ses pièces seront déposées.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucun site enregistré pour UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier », bouton « Modifier le dossier ».
3. Effacez « Forme du véhicule », qui garde SCI du test « Modification refusée pour une forme de véhicule autre que SPPICAV ou FPI », et « Contact, nom ». Saisissez « Adresse » : 9 rue Refusée et « Site SharePoint des pièces » : sharepoint.com/sites/essai. Laissez les autres champs vides.
4. Cliquez « Enregistrer les modifications » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Dossier » et lisez la fiche.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre ; « <cabinet> » et « <nom> » y sont écrits tels quels, ce ne sont pas des parties variables. Rien n'est écrit : la fiche porte toujours « Adresse » : 5 rue de l'Essai et « Site SharePoint des pièces » : aucun (Modifier).

```
Le lien attendu est celui du site SharePoint de l'équipe Teams, de la forme https://<cabinet>.sharepoint.com/sites/<nom>.
```

Passé ☐ · Échec ☐ · Remarque :

### Les pièces justificatives du dossier

#### 2-09. Rattachement d'une pièce refusé pour un client sans site SharePoint

**Besoin :** Une pièce ne s'inscrit au dossier que si le client a un espace où la déposer.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucun site enregistré pour UAT-OPCI : test joué avant « Enregistrer le site SharePoint du client ».

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces », bouton « Pièce ».
3. Lisez l'avis du sous-état et survolez le bouton « Ouvrir le dépôt du client ».
4. Saisissez « Nom du fichier déposé, sous-dossier facultatif » : essai.pdf ; choisissez « Nature » : Lettre de mission.
5. Cliquez « Rattacher la pièce » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** L'avis porte « UAT-OPCI n'a pas d'espace SharePoint : aucune pièce ne se dépose dans son Dépôt du client. » et le bouton « Rattacher la pièce » est grisé. L'infobulle de « Ouvrir le dépôt du client » porte « UAT-OPCI n'a pas d'espace SharePoint : son Dépôt du client n'existe pas. ». Au clic, la zone « Message de l'écran » affiche le refus ci-contre et aucune pièce n'est inscrite.

```
Ni cette entité ni le véhicule qui la détient n'ont d'espace SharePoint : provisionnez d'abord celui du véhicule.
```

Passé ☐ · Échec ☐ · Remarque :

### La fiche du client

#### 2-10. Enregistrer le site SharePoint du client

**Besoin :** Le dossier connaît le site où le client dépose ses pièces.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Un site SharePoint d'équipe créé pour l'essai par une équipe Teams, dont vous avez le lien, de la forme https://<cabinet>.sharepoint.com/sites/<nom>.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier », bouton « Modifier le dossier ».
3. Effacez « Adresse », qui garde 9 rue Refusée du test « Lien de site refusé quand il n'est pas celui d'un site SharePoint », ainsi que « Forme du véhicule » et « Contact, nom » s'ils portent une saisie. Remplacez le contenu de « Site SharePoint des pièces » par le lien du site. Laissez les autres champs vides.
4. Cliquez « Enregistrer les modifications » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Dossier » et lisez la fiche.
6. Cliquez l'étape « Questionnaire et pièces », bouton « Pièce » : lisez l'avis et survolez « Ouvrir le dépôt du client ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. La fiche porte, à « Site SharePoint des pièces », le lien saisi (sans barre finale) au lieu de « aucun (Modifier) », et toujours « Adresse » : 5 rue de l'Essai. Dans le sous-état « Pièce », l'avis est vide et l'infobulle de « Ouvrir le dépôt du client » porte « Ouvre la bibliothèque Dépôt du client dans SharePoint. ».

```
Informations de UAT-OPCI mises à jour. Site SharePoint enregistré. Le code du client ne change pas.
```

Passé ☐ · Échec ☐ · Remarque :

### Le périmètre du véhicule

#### 2-11. Ajouter une filiale au périmètre du véhicule

**Besoin :** Le périmètre du véhicule porte chaque filiale avec ses droits de vote et son classement au sens de l'article R. 214-83 du code monétaire et financier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Ajouter une filiale ».
3. Saisissez « Code de la filiale » : UAT-SCI-1 ; « Dénomination » : SCI UAT 1 ; « Forme sociale » : SCI ; « Droits de vote (%) » : 80 ; « Contrôlée (R. 214-83) » : oui.
4. Cliquez « Ajouter cette filiale » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Filiales » et lisez le tableau « Filiales du groupe », puis la liste des clients.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le tableau « Filiales du groupe » porte UAT-SCI-1, SCI UAT 1, « Forme » SCI, « Quote-part » 80,00 %, « Contrôlée (R. 214-83) » : oui. La liste des clients porte, sous UAT-OPCI, la ligne « └ UAT-SCI-1 ».

```
Filiale UAT-SCI-1 ajoutée au périmètre de UAT-OPCI. Sa balance sera réclamée à la révision.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-12. Ajout refusé pour une filiale déjà au périmètre

**Besoin :** Une filiale figure une seule fois au périmètre d'un véhicule.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-SCI-1 au périmètre de UAT-OPCI (test « Ajouter une filiale au périmètre du véhicule »).

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Ajouter une filiale ».
3. Saisissez « Code de la filiale » : UAT-SCI-1 ; « Droits de vote (%) » : 80 ; « Contrôlée (R. 214-83) » : oui.
4. Cliquez « Ajouter cette filiale » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Filiales » et lisez le tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Filiales du groupe » porte 1 seule ligne UAT-SCI-1.

```
Cette filiale est déjà au périmètre de ce client.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-13. Ajout refusé pour des droits de vote à 0

**Besoin :** Les droits de vote d'une filiale se saisissent en pourcentage, de plus de 0 à 100.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucune filiale UAT-SCI-2.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Ajouter une filiale ».
3. Saisissez « Code de la filiale » : UAT-SCI-2 ; « Dénomination » : SCI UAT 2 ; « Droits de vote (%) » : 0 ; « Contrôlée (R. 214-83) » : oui.
4. Cliquez « Ajouter cette filiale » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Filiales » et lisez le tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Filiales du groupe » ne porte pas UAT-SCI-2.

```
Les droits de vote se saisissent en pourcentage, de plus de 0 à 100 : 80 pour 80 %.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-14. Ajout refusé sans classement au sens de l'article R. 214-83

**Besoin :** Chaque filiale porte son classement, contrôlée ou non, au sens de l'article R. 214-83 du code monétaire et financier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucune filiale UAT-SCI-2.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Ajouter une filiale ».
3. Saisissez « Code de la filiale » : UAT-SCI-2 ; « Dénomination » : SCI UAT 2 ; « Droits de vote (%) » : 80. Un de ces champs qui porterait encore une saisie du test « Ajout refusé pour des droits de vote à 0 » se remplace, il ne se complète pas. Laissez « Contrôlée (R. 214-83) » vide : effacez-le s'il porte encore une saisie.
4. Cliquez « Ajouter cette filiale » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Filiales » et lisez le tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Filiales du groupe » ne porte pas UAT-SCI-2.

```
Le classement de la filiale au sens de l'article R. 214-83 du code monétaire et financier est obligatoire : oui si elle est contrôlée, non sinon.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-15. Modifier les droits de vote d'une filiale

**Besoin :** Les droits de vote d'une filiale se corrigent sans ressaisir sa fiche.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-SCI-1 au périmètre de UAT-OPCI, droits de vote 80 %.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Modifier la filiale ».
3. Choisissez UAT-SCI-1 dans la liste « Filiale ».
4. Saisissez « Droits de vote (%) » : 60. Laissez les autres champs vides.
5. Cliquez « Enregistrer la filiale » et lisez la zone « Message de l'écran ».
6. Cliquez l'étape « Filiales » et lisez le tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le taux est formaté par la base, FORMAT(…, 'P2', 'fr-FR') : l'espace avant « % » est l'espace insécable de ce format (U+00A0, ou U+202F selon les données de culture du moteur). Le tableau « Filiales du groupe » porte UAT-SCI-1 avec « Quote-part » 60,00 % ; la dénomination SCI UAT 1 et le classement « oui » sont inchangés.

```
Filiale UAT-SCI-1 mise à jour : droits de vote → 60,00 %.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-16. Modification de filiale refusée sans aucun champ saisi

**Besoin :** Une modification de filiale porte au moins un changement.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-SCI-1 au périmètre de UAT-OPCI, droits de vote portés à 60 % par le test « Modifier les droits de vote d'une filiale ».

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Modifier la filiale ».
3. Vérifiez que l'en-tête du formulaire porte « Modifier UAT-SCI-1 · SCI UAT 1 » ; sinon, choisissez UAT-SCI-1 dans la liste « Filiale ». Laissez « Dénomination », « Forme sociale », « Droits de vote (%) » et « Contrôlée (R. 214-83) » vides : effacez celui qui porterait encore une saisie.
4. Cliquez « Enregistrer la filiale » et lisez la zone « Message de l'écran ».
5. Cliquez l'étape « Filiales » et lisez la ligne UAT-SCI-1 du tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Filiales du groupe » porte toujours UAT-SCI-1 telle que l'a laissée le test « Modifier les droits de vote d'une filiale » : « Dénomination » SCI UAT 1, « Quote-part » 60,00 %, « Contrôlée (R. 214-83) » : oui.

```
Rien à modifier : renseignez au moins un champ.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-17. Importer le classeur des filiales : une ligne refusée n'arrête pas les autres

**Besoin :** Le périmètre se reprend d'un classeur, ligne par ligne, et chaque ligne refusée est nommée avec son motif.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Étape 12 faite : le site SharePoint du cabinet est relié au coffre par le raccourci « fec ». Accès en écriture à la bibliothèque de documents du site du cabinet. Aucune filiale UAT-SCI-3 ni UAT-SCI-4.

1. Créez un classeur Excel filiales_essai.xlsx dont la feuille se nomme « Filiales ».
2. En ligne 2, colonnes A à D, saisissez les en-têtes code, denomination, droits_de_vote, controlee. La ligne 1 reste libre.
3. En ligne 3 : UAT-SCI-3, SCI UAT 3, 80, oui. En ligne 4 : UAT-SCI-4, SCI UAT 4, 0, oui.
4. Déposez le classeur dans le dossier « Dossiers de travail/UAT-OPCI » de la bibliothèque de documents du site du cabinet (créez le dossier au besoin).
5. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
6. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Ajouter une filiale ».
7. Saisissez « Nom du classeur déposé » : filiales_essai.xlsx et cliquez « Réimporter ».
8. Lisez la zone « Message de l'écran », puis l'étape « Filiales » et le tableau « Filiales du groupe ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le bilan ci-contre, sur le fond des refus puisqu'une ligne est refusée. Le tableau « Filiales du groupe » porte UAT-SCI-3 (quote-part 80 % à 2 décimales, classement « oui ») et ne porte pas UAT-SCI-4.

```
1 filiale ajoutée à UAT-OPCI, 1 ligne refusée : UAT-SCI-4, droits de vote hors de 0 à 100 %.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-18. Suppression refusée pour une filiale qui porte des données de mission

**Besoin :** Une filiale qui porte des arrêtés, des pièces ou des écritures ne sort pas du dossier par suppression : sa sortie se constate par la détention.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Jeu de démonstration : OMEGA-SCI-1 (SCI OMEGA 1) au périmètre d'OMEGA-OPCI, avec des arrêtés et des écritures ; le Compte 1 est associé d'OMEGA-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez OMEGA-OPCI dans la liste des clients, étape « Filiales », bouton « Supprimer la filiale ».
3. Choisissez OMEGA-SCI-1 dans la liste « Filiale ».
4. Lisez la confirmation et relevez les nombres d'arrêtés, de pièces et d'écritures qu'elle donne.
5. Survolez le bouton « Supprimer », puis cliquez-le.
6. Lisez la zone « Message de l'écran », puis le tableau « Filiales du groupe » de l'étape « Filiales ».

**Vous devez obtenir :** La confirmation porte « OMEGA-SCI-1 · SCI OMEGA 1 ne se supprime pas. » puis « Elle porte 7 arrêté(s), 2 pièce(s) et 42 écriture(s) ; sa sortie du groupe se constate par la détention à l'arrêté suivant. ». Le bouton « Supprimer » est grisé, d'infobulle « OMEGA-SCI-1 porte des arrêtés, des pièces ou des écritures : elle ne se supprime pas. ». Au clic, la zone « Message de l'écran » affiche le refus ci-contre (au-delà de 2 lignes, la zone coupe la fin par « … »). Les nombres sont ceux du jeu de démonstration chargé sans autre modification de OMEGA-SCI-1 ; dans tous les cas, ceux d'arrêtés, de pièces et d'écritures égalent ceux de la confirmation, et le refus ne nomme que les catégories non nulles. OMEGA-SCI-1 reste au tableau « Filiales du groupe ».

```
La filiale OMEGA-SCI-1 porte des données de mission et ne se supprime pas : 7 arrêté(s), 6 feuille(s), 2 pièce(s), 42 écriture(s) ou import(s), 19 compte(s), 5 détention(s) à un arrêté. Sa sortie du groupe se constate par la détention à l'arrêté suivant.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-19. Supprimer une filiale sans données de mission

**Besoin :** Une filiale ajoutée par erreur sort du périmètre, et l'action est tracée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-SCI-1 au périmètre de UAT-OPCI, sans arrêté, pièce ni écriture.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Filiales », bouton « Supprimer la filiale ».
3. Choisissez UAT-SCI-1 dans la liste « Filiale » et lisez la confirmation.
4. Cliquez « Supprimer » et lisez la zone « Message de l'écran ».
5. Lisez le tableau « Filiales du groupe » de l'étape « Filiales » et la liste des clients.

**Vous devez obtenir :** La confirmation porte « Supprimer UAT-SCI-1 · SCI UAT 1 ? » puis « Cette filiale ne porte aucune donnée : elle sort du périmètre, l'entité est effacée, l'action est tracée. ». La zone « Message de l'écran » porte le message ci-contre. UAT-SCI-1 n'est plus au tableau « Filiales du groupe » ni dans la liste des clients.

```
Filiale UAT-SCI-1 (SCI UAT 1) retirée du périmètre de UAT-OPCI.
```

Passé ☐ · Échec ☐ · Remarque :

### L'équipe de la mission

#### 2-20. Désignation refusée sans nom de personne

**Besoin :** Chaque rôle de l'équipe est tenu par une personne nommée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Le rôle « Collaborateur » de UAT-OPCI n'est pas désigné.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier ».
3. Dans le tableau « Rôles du dossier » de la section « Équipe de la mission », cliquez la ligne « Collaborateur ».
4. Laissez « Personne » vide ; saisissez « Connexion (UPN) » : l'adresse de connexion du Compte 3.
5. Cliquez « Désigner » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La ligne « Collaborateur » porte toujours « Non désigné ».

```
Le nom de la personne est obligatoire.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-21. Désigner l'associé signataire du dossier

**Besoin :** Le dossier porte l'associé signataire qui visera l'acceptation, désigné depuis l'écran par le chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Le Compte 2 ne tient aucun rôle sur UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier ».
3. Dans le tableau « Rôles du dossier », cliquez la ligne « Associé signataire ».
4. Saisissez « Personne » : le nom du titulaire du Compte 2 ; « Connexion (UPN) » : l'adresse de connexion exacte du Compte 2.
5. Cliquez « Désigner » et lisez la zone « Message de l'écran ».
6. Lisez le tableau « Rôles du dossier » et l'alerte de la section « Équipe de la mission ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre, avec le nom saisi. Le tableau porte « Associé signataire », le nom saisi, « Depuis » : la date du jour, état « désigné ». L'alerte porte « 1 rôle(s) à désigner : le visa attend un associé signataire. ».

```
<nom saisi> désigné associé signataire de UAT-OPCI.
```

Passé ☐ · Échec ☐ · Remarque :

### Le cloisonnement des dossiers entre les membres de l'équipe

#### 2-22. Le membre désigné voit le dossier et le bouton du visa

**Besoin :** Une désignation ouvre le dossier à la personne désignée, sans autre réglage.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 2 désigné associé signataire de UAT-OPCI (test « Désigner l'associé signataire du dossier »).

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Lisez la liste des clients et cliquez UAT-OPCI.
4. Cliquez l'étape « Visa » et survolez le bouton « Approuver ».

**Vous devez obtenir :** La liste des clients du Compte 2 porte UAT-OPCI. Le bouton « Approuver » n'est pas grisé ; son infobulle porte le texte ci-contre.

```
Accepte la mission ; action réservée au superviseur.
```

Passé ☐ · Échec ☐ · Remarque :

### L'équipe de la mission

#### 2-23. Désigner le collaborateur du dossier

**Besoin :** L'équipe du dossier porte le collaborateur qui prépare le dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Le Compte 3 ne tient aucun rôle sur UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier ».
3. Dans le tableau « Rôles du dossier », cliquez la ligne « Collaborateur ».
4. Saisissez « Personne » : le nom du titulaire du Compte 3 ; « Connexion (UPN) » : l'adresse de connexion exacte du Compte 3.
5. Cliquez « Désigner » et lisez la zone « Message de l'écran ».
6. Lisez le tableau « Rôles du dossier » et l'alerte de la section « Équipe de la mission ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre, avec le nom saisi et le code de rôle PREPARATEUR. Le tableau porte « Collaborateur », le nom saisi, état « désigné ». L'alerte de l'équipe est vide.

```
<nom saisi> désigné PREPARATEUR de UAT-OPCI.
```

Passé ☐ · Échec ☐ · Remarque :

### Le cloisonnement des dossiers entre les membres de l'équipe

#### 2-24. Le collaborateur désigné ne voit que son dossier

**Besoin :** Un membre de l'équipe ne lit que les dossiers où il est désigné.  
**Profil :** Compte 3 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 3 désigné « Collaborateur » de UAT-OPCI par le Compte 1, section « Équipe de la mission », bouton « Désigner » (test « Désigner le collaborateur du dossier ») ; aucun autre mandat.

1. Connectez-vous avec le Compte 3.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Lisez la liste des clients.

**Vous devez obtenir :** La liste des clients porte la ligne UAT-OPCI et, sous elle, la ligne « └ UAT-SCI-3 », seule filiale de UAT-OPCI à ce rang. Elle ne porte ni OMEGA-OPCI, ni OPCI-1, ni leurs filiales.

Passé ☐ · Échec ☐ · Remarque :

### L'équipe de la mission

#### 2-25. Désignation refusée au collaborateur

**Besoin :** L'équipe d'un dossier se désigne par son associé ou par son chef de mission.  
**Profil :** Compte 3 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 3 désigné « Collaborateur » de UAT-OPCI par le Compte 1, section « Équipe de la mission », bouton « Désigner ».

1. Connectez-vous avec le Compte 3.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Dossier ».
4. Dans le tableau « Rôles du dossier », cliquez la ligne « Collaborateur ».
5. Saisissez « Personne » : Essai ; « Connexion (UPN) » : essai.
6. Cliquez « Désigner » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La ligne « Collaborateur » porte toujours le nom du titulaire du Compte 3.

```
Désignation refusée : l'équipe d'un dossier se désigne par son associé ou par son chef de mission, et votre adresse de connexion ne tient aucun de ces 2 rôles sur ce dossier.
```

Passé ☐ · Échec ☐ · Remarque :

### Le visa de l'acceptation

#### 2-26. Visa refusé au collaborateur

**Besoin :** Le visa de l'acceptation est réservé au superviseur de la mission.  
**Profil :** Compte 3 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 3 désigné « Collaborateur » de UAT-OPCI par le Compte 1, section « Équipe de la mission », bouton « Désigner ».

1. Connectez-vous avec le Compte 3.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Survolez le bouton « Approuver », puis cliquez-le.
5. Lisez la zone « Message de l'écran », puis le « Statut » de la section « Acceptation de la mission » à l'étape « Dossier ».

**Vous devez obtenir :** Le bouton « Approuver » est grisé, d'infobulle « Action réservée au superviseur de la mission. ». Au clic, la zone « Message de l'écran » affiche le refus ci-contre. Le « Statut » reste « En cours ».

```
Le visa est réservé au superviseur connecté ; l'action n'est pas exécutée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-27. Approbation refusée à celui qui a préparé l'acceptation

**Besoin :** La décision d'accepter une mission se prend par un autre que celui qui l'a préparée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. L'acceptation de UAT-OPCI a été ouverte par le Compte 1 à la création du dossier.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
3. Cliquez « Approuver » et lisez la zone « Message de l'écran ».
4. Cliquez l'étape « Dossier » et lisez la section « Acceptation de la mission ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre (au-delà de 2 lignes, la zone coupe la fin par « … »). La section porte toujours « Statut » : En cours et « Décision » : En attente.

```
Approbation refusée : l'acceptation a été proposée par la même personne. La décision d'accepter une mission se prend par un autre que celui qui l'a préparée. Faire approuver par l'associé signataire.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-28. Approbation refusée tant que le questionnaire n'est pas complet

**Besoin :** Une mission ne s'accepte qu'une fois toutes les questions obligatoires du questionnaire d'acceptation répondues.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 2 désigné associé signataire de UAT-OPCI. Aucune réponse au questionnaire de UAT-OPCI : test joué avant « Répondre à une question du questionnaire en ligne ».

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Cliquez « Approuver » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre : 92 questions obligatoires sans réponse, la première étant ACCEPT-01, son énoncé coupé à 120 caractères (au-delà de 2 lignes, la zone coupe la fin par « … »). Le « Statut » reste « En cours ».

```
Approbation refusée : 92 question(s) obligatoire(s) du questionnaire d'acceptation sont sans réponse. La première est ACCEPT-01, « L’entité pour laquelle la mission est envisagée est-elle un organisme de placement collectif immobilier régi par le code ». Répondre à toutes les questions obligatoires, puis approuver.
```

Passé ☐ · Échec ☐ · Remarque :

### Le questionnaire d'acceptation

#### 2-29. Répondre à une question du questionnaire en ligne

**Besoin :** Le questionnaire d'acceptation se renseigne à l'écran, question par question.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucune réponse au questionnaire de UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
3. Dans la grille « Questionnaire d'acceptation », cliquez la ligne ACCEPT-01.
4. Saisissez « Réponse » : OUI.
5. Cliquez « Valider la réponse ».
6. Lisez la ligne ACCEPT-01 de la grille et le compteur de la grille.

**Vous devez obtenir :** La ligne ACCEPT-01 porte « OUI » en colonne « Réponse ». Le compteur porte « 1 sur 110 répondue · 10 affichées, la grille défile ». « Valider la réponse » n'écrit rien dans la zone « Message de l'écran » : la procédure ne rend pas de message et la fonction n'en pose pas au succès. La zone montre le dernier message posé au Compte 1 sous UAT-OPCI ou sous tous les clients, s'il a été posé 30 minutes au plus avant la lecture, minutes comptées par la vue à la minute près : ici le refus du test « Approbation refusée à celui qui a préparé l'acceptation », le Compte 1 n'ayant rien posé depuis. Au-delà, la zone est vide.

Passé ☐ · Échec ☐ · Remarque :

#### 2-30. Réponse « non applicable » refusée à une question qui ne l'admet pas

**Besoin :** Les questions d'éligibilité au régime OPCI se répondent par OUI ou par NON.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** ACCEPT-01 de UAT-OPCI répondue OUI (test « Répondre à une question du questionnaire en ligne »).

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
3. Vérifiez que la ligne au-dessus des champs de saisie porte « ACCEPT-01 · » suivi de l'énoncé ; sinon, cliquez la ligne ACCEPT-01 de la grille.
4. Remplacez le contenu de « Réponse », qui garde OUI du test « Répondre à une question du questionnaire en ligne », par NA ; saisissez « Motif si NA » : essai.
5. Cliquez « Valider la réponse » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La ligne ACCEPT-01 porte toujours « OUI » ; le compteur est inchangé.

```
La question ACCEPT-01 n'admet pas la non-applicabilité.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-31. Réponse « non applicable » refusée sans motif

**Besoin :** Une question déclarée non applicable porte son motif au dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. ACCEPT-03 sans réponse.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
3. Cliquez la ligne ACCEPT-03 de la grille.
4. « Réponse » garde NA du test « Réponse « non applicable » refusée à une question qui ne l'admet pas » : vérifiez qu'il porte NA, sinon remplacez son contenu par NA. Effacez « Motif si NA », qui garde essai du même test.
5. Cliquez « Valider la réponse » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. ACCEPT-03 reste sans réponse ; le compteur porte toujours « 1 sur 110 répondue · 10 affichées, la grille défile ».

```
La question ACCEPT-03 est déclarée non applicable sans motif. Le motif est obligatoire.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-32. Exporter le questionnaire en classeur Excel

**Besoin :** Le questionnaire se remplit hors de l'écran, dans un classeur déposé au dossier de travail du client.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Étape 12 faite : dépôt des classeurs installé (paramètres DEPOT_CLASSEUR_URL et SITE_CABINET) ; accès à la bibliothèque de documents du site du cabinet.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
3. Cliquez « Exporter le questionnaire » et lisez la zone « Message de l'écran ».
4. Ouvrez le site du cabinet, bibliothèque de documents, dossier nommé par le message, et ouvrez le classeur ACC-UAT-OPCI.xlsx.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre, où <arrêté> est la date, au format aaaa-mm-jj, de l'arrêté auquel le questionnaire est adossé : la prochaine clôture du client à sa création, soit 2026-12-31 pour un cahier joué en 2026. Le classeur porte une feuille « Questionnaire » ; ligne 1, les en-têtes Section, Référence, Question, Type, Obligatoire, Réponse, Motif si non applicable, Commentaire, Pièce attendue ; ligne 2, les clés techniques ; à partir de la ligne 3, 110 questions ; ACCEPT-01 porte OUI en colonne « Réponse ».

```
Questionnaire ACC-UAT-OPCI exporté, 110 questions, dans « Dossiers de travail/UAT-OPCI/<arrêté> » du site du cabinet. Pour le réimporter, saisissez <arrêté>/ACC-UAT-OPCI.xlsx.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-33. Réimport du questionnaire refusé en entier pour une seule réponse invalide

**Besoin :** Un classeur de réponses entre au dossier en entier ou pas du tout.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Classeur ACC-UAT-OPCI.xlsx exporté (test « Exporter le questionnaire en classeur Excel ») ; une seule réponse au questionnaire de UAT-OPCI (ACCEPT-01).

1. Dans le classeur ACC-UAT-OPCI.xlsx du site du cabinet, saisissez OUI en colonne « Réponse » sur chaque ligne de question, sauf ACCEPT-01 où vous saisissez PEUT-ETRE. Enregistrez le classeur à sa place.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
4. Saisissez « Nom du classeur déposé » : le chemin donné par le message d'export, <arrêté>/ACC-UAT-OPCI.xlsx.
5. Cliquez « Réimporter » et lisez la zone « Message de l'écran », puis le compteur de la grille.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Aucune réponse du classeur n'est écrite : le compteur porte toujours « 1 sur 110 répondue · 10 affichées, la grille défile ».

```
La question ACCEPT-01 se répond par OUI ou NON. Reçu : « PEUT-ETRE ».
```

**Anomalie connue :** Le réimport est bien refusé en entier, mais son message est posé sous la cote du questionnaire, `ACC-<client>`, et non sous le client : la zone « Message de l'écran » ne l'affiche pas.

Passé ☐ · Échec ☐ · Remarque :

#### 2-34. Réimporter le questionnaire complété

**Besoin :** Les réponses saisies dans le classeur entrent au dossier en une action.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Classeur ACC-UAT-OPCI.xlsx rempli de OUI sauf ACCEPT-01 (test « Réimport du questionnaire refusé en entier pour une seule réponse invalide »).

1. Dans le classeur ACC-UAT-OPCI.xlsx, remplacez PEUT-ETRE par OUI sur la ligne ACCEPT-01. Enregistrez le classeur à sa place.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
4. « Nom du classeur déposé » garde <arrêté>/ACC-UAT-OPCI.xlsx du test « Réimport du questionnaire refusé en entier pour une seule réponse invalide » : vérifiez-le, sans le saisir de nouveau.
5. Cliquez « Réimporter » et lisez la zone « Message de l'écran », le compteur placé sous la grille et la ligne placée sous l'en-tête de l'étape, au-dessus de la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre : 110 réponses, une par ligne remplie. Le compteur porte « 110 sur 110 répondues · 10 affichées, la grille défile » ; la ligne placée sous l'en-tête de l'étape porte « 110 sur 110 répondues · 0 pièce · une ligne par question, on y répond directement ».

```
110 réponses importées sur ACC-UAT-OPCI.
```

**Anomalie connue :** Les réponses sont importées, mais le message de l'import est posé sous la cote du questionnaire, `ACC-<client>`, et non sous le client : la zone « Message de l'écran » ne l'affiche pas.

Passé ☐ · Échec ☐ · Remarque :

### Le visa de l'acceptation

#### 2-35. L'étape Visa dit que le dossier peut partir au visa

**Besoin :** Le chef de mission voit, avant le visa, que le questionnaire est complet.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Questionnaire de UAT-OPCI complet (test « Réimporter le questionnaire complété ») ; acceptation au statut En cours.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Questionnaire et pièces ».
3. Cliquez « Soumettre au visa ».
4. Lisez l'en-tête, le bandeau et les 3 cases de l'étape « Visa ».
5. Cliquez l'étape « Dossier » et lisez le « Statut » de la section « Acceptation de la mission ».

**Vous devez obtenir :** L'étape « Visa » s'ouvre, en-tête « UAT-OPCI · soumettre au visa, et suivre le statut ». Le bandeau porte le texte ci-contre. Les cases portent « Proposé », « En attente de visa » et « Visé ». Le « Statut » reste « En cours » : le bouton « Soumettre au visa » ouvre l'étape sans rien écrire en base.

```
110 sur 110 questions répondues, 0 pièce(s) au coffre : le dossier peut partir au visa.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-36. Refus de la mission sans motif refusé

**Besoin :** Le refus d'une mission documente son motif (NPMQ, paragraphe 19).  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte 2 associé signataire de UAT-OPCI ; questionnaire complet ; acceptation au statut En cours.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Laissez « Motif » vide et cliquez « Refuser ».
5. Lisez la zone « Message de l'écran » et le « Statut » à l'étape « Dossier ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le « Statut » reste « En cours ».

```
Approbation refusée : le refus d'une mission exige un motif. La NPMQ paragraphe 19 impose de documenter la manière dont les difficultés ont été traitées.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-37. Refuser la mission avec son motif

**Besoin :** L'associé refuse une mission ; le refus et son motif restent au dossier.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Compte 2 associé signataire de UAT-OPCI ; questionnaire complet ; acceptation au statut En cours.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Saisissez « Motif » : Essai de refus. Cliquez « Refuser ».
5. Lisez la zone « Message de l'écran », le bandeau et la 3e case de l'étape « Visa », puis la section « Acceptation de la mission » à l'étape « Dossier ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le bandeau porte « Acceptation refusée <adresse de connexion du Compte 2> · <date du jour, jj/mm/aaaa> : reprendre le questionnaire, puis soumettre à nouveau. » ; la 3e case porte « Renvoyé avec un motif ». La section porte « Statut » : Refusée et « Décision » : Refusée.

```
Acceptation de UAT-OPCI : décision refusee visée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-38. Approbation refusée pour une acceptation au statut refusé

**Besoin :** Une acceptation refusée se reprend avant tout nouveau visa.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Acceptation de UAT-OPCI au statut Refusée (test « Refuser la mission avec son motif »).

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Cliquez « Approuver » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le « Statut » reste « Refusée ».

```
Approbation refusée : l'acceptation de cette entité est au statut refusé. L'action attendue est la reprise, qui exige un motif et remet le dossier à l'état ouvert.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-39. Reprise d'une acceptation refusée sans motif refusée

**Besoin :** La reprise d'un dossier refusé dit ce qui a changé depuis le refus.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Acceptation de UAT-OPCI au statut Refusée.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
3. Laissez « Motif » vide et cliquez « Reprendre ».
4. Lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le « Statut » reste « Refusée ».

```
Reprise refusée : la reprise d'une acceptation refusée exige un motif, qui dit ce qui a changé depuis le refus.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-40. Reprendre une acceptation refusée

**Besoin :** Un dossier refusé se reprend avec un motif ; ses réponses sont conservées.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Acceptation de UAT-OPCI au statut Refusée.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
3. Saisissez « Motif » : Circonstances nouvelles. Cliquez « Reprendre ».
4. Lisez la zone « Message de l'écran », la section « Acceptation de la mission » à l'étape « Dossier », puis le compteur de l'étape « Questionnaire et pièces ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. La section porte « Statut » : En cours, « Décision » : En attente, « Visa » : en attente de visa. Le compteur porte toujours « 110 sur 110 répondues · 10 affichées, la grille défile ».

```
Acceptation de UAT-OPCI reprise ; le questionnaire se complète à nouveau.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-41. Approuver l'acceptation de la mission

**Besoin :** L'associé signataire vise l'acceptation d'une mission préparée par un autre.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 2 associé signataire de UAT-OPCI ; questionnaire complet ; acceptation au statut En cours, ouverte par le Compte 1.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Cliquez « Approuver ».
5. Lisez la zone « Message de l'écran », le bandeau et la 3e case, la section « Acceptation de la mission » à l'étape « Dossier », puis la colonne « Acceptation » de la liste des clients.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le bandeau porte « Acceptation approuvée <adresse de connexion du Compte 2> · <date du jour, jj/mm/aaaa>. » ; la 3e case porte « Visé ». La section porte « Statut » : Approuvée, « Décision » : Acceptée, « Visa » : l'adresse de connexion du Compte 2 · la date du jour. La liste des clients porte « Approuvée » pour UAT-OPCI.

```
Acceptation de UAT-OPCI : décision acceptee visée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-42. Seconde approbation refusée

**Besoin :** Une acceptation approuvée ne se vise pas 2 fois.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Acceptation de UAT-OPCI approuvée (test « Approuver l'acceptation de la mission »).

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
3. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
4. Cliquez « Approuver » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le « Statut » reste « Approuvée ».

```
Approbation refusée : l'acceptation de cette entité est déjà approuvée. Pour la reprendre, passer par la reprise.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-43. Reprise refusée pour une acceptation approuvée

**Besoin :** Seule une acceptation refusée se reprend.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Acceptation de UAT-OPCI approuvée (test « Approuver l'acceptation de la mission »).

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Visa ».
3. Vérifiez que « Motif » porte Circonstances nouvelles, laissé par le test « Reprendre une acceptation refusée » ; sinon, saisissez-y Circonstances nouvelles : la reprise exige un motif non vide avant de juger le statut. Cliquez « Reprendre ».
4. Lisez la zone « Message de l'écran » et la case « Statut » de l'étape « Visa ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La case « Statut » porte toujours « Approuvée ».

```
Reprise refusée : seule une acceptation au statut refusé se reprend. Un dossier ouvert se répond, un dossier approuvé ne se reprend pas.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-44. Approbation refusée pour un client sans acceptation ouverte

**Besoin :** Une mission ne s'accepte que sur une acceptation ouverte avec son questionnaire.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Jeu de démonstration : OPCI-1 (OPCI SIGMA) n'a ni acceptation ni questionnaire d'acceptation ; le Compte 1 est associé d'OPCI-1.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez OPCI-1 dans la liste des clients, étape « Dossier » : lisez le « Statut » de la section « Acceptation de la mission ».
3. Cliquez l'étape « Visa » et lisez le bandeau.
4. Cliquez « Approuver » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La section porte « Statut » : À faire. Le bandeau porte « Aucun questionnaire d'acceptation ouvert : le visa attend. ». Au clic, la zone « Message de l'écran » affiche le refus ci-contre.

```
Approbation refusée : aucune acceptation n'est ouverte pour cette entité. Ouvrir l'acceptation, répondre au questionnaire, puis approuver.
```

Passé ☐ · Échec ☐ · Remarque :

### L'ouverture du premier arrêté

#### 2-45. Ouverture refusée sans périodicité de la valeur liquidative

**Besoin :** Les arrêtés de l'exercice se planifient selon la périodicité de la valeur liquidative du véhicule.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Acceptation de UAT-OPCI approuvée ; aucun arrêté ouvert pour UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Arrêtés ».
3. Saisissez « Début d'exercice » : 01/01/2026 et « Fin d'exercice » : 31/12/2026. Laissez « Périodicité de la VL » vide.
4. Cliquez « Ouvrir l'arrêté » et lisez la zone « Message de l'écran », puis le tableau des arrêtés.

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau des arrêtés ne porte pas de ligne 30/06/2026, et aucune de ses lignes n'a de date « Ouvert le ».

```
La périodicité de la VL est ANNUELLE, SEMESTRIELLE ou TRIMESTRIELLE.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-46. Ouverture refusée pour un exercice de plus de 24 mois

**Besoin :** Un exercice commence avant sa fin et ne dépasse pas 24 mois.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucun arrêté ouvert pour UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Arrêtés ».
3. « Début d'exercice » garde 01/01/2026 du test « Ouverture refusée sans périodicité de la valeur liquidative » : laissez-le. Remplacez le contenu de « Fin d'exercice » par 31/12/2028 ; saisissez « Périodicité de la VL » : Semestrielle.
4. Cliquez « Ouvrir l'arrêté » et lisez la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Aucun arrêté n'est planifié ni ouvert.

```
L'exercice commence avant sa fin et ne dépasse pas 24 mois.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-47. Planifier les arrêtés de l'exercice et ouvrir le premier

**Besoin :** L'exercice du client se découpe en arrêtés selon la périodicité de la valeur liquidative, et le premier s'ouvre à la révision.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Acceptation de UAT-OPCI approuvée ; aucun arrêté ouvert pour UAT-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Arrêtés ».
3. « Début d'exercice » et « Périodicité de la VL » gardent 01/01/2026 et Semestrielle du test « Ouverture refusée pour un exercice de plus de 24 mois » : laissez-les. Remplacez le contenu de « Fin d'exercice » par 31/12/2026.
4. Cliquez « Ouvrir l'arrêté » et lisez la zone « Message de l'écran ».
5. Lisez le tableau des arrêtés, puis la fiche de l'étape « Dossier ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre, où <n> est le nombre de dates de l'exercice qui n'étaient pas encore planifiées : 1 pour un cahier joué en 2026, le 31/12/2026 étant planifié depuis l'ouverture du questionnaire d'acceptation. Le tableau des arrêtés porte 30/06/2026, type « Semestriel », « Ouvert le » à la date du jour, et 31/12/2026, type « Annuel », « Ouvert le » vide. La fiche porte « Clôture · VL » : 31/12 · semestrielle.

```
<n> arrêté(s) planifié(s) sur l'exercice, périodicité semestrielle. Arrêté 2026-06-30 ouvert : la révision peut commencer.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-48. Un second clic sur « Ouvrir l'arrêté » ne crée aucun doublon

**Besoin :** Un arrêté se planifie et s'ouvre une seule fois.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Arrêté 30/06/2026 de UAT-OPCI ouvert (test « Planifier les arrêtés de l'exercice et ouvrir le premier »).

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez UAT-OPCI dans la liste des clients, étape « Arrêtés ».
3. Vérifiez que « Début d'exercice », « Fin d'exercice » et « Périodicité de la VL » portent toujours 01/01/2026, 31/12/2026 et Semestrielle du test « Planifier les arrêtés de l'exercice et ouvrir le premier » : le bouton ne les vide pas, ne les saisissez pas de nouveau.
4. Cliquez « Ouvrir l'arrêté » et lisez la zone « Message de l'écran », puis le tableau des arrêtés.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre, sans refus. Le tableau porte toujours 2 lignes pour l'exercice, 30/06/2026 et 31/12/2026 ; la date « Ouvert le » du 30/06/2026 est inchangée.

```
0 arrêté(s) planifié(s) sur l'exercice, périodicité semestrielle. Arrêté 2026-06-30 ouvert : la révision peut commencer.
```

Passé ☐ · Échec ☐ · Remarque :

### Le périmètre du véhicule

#### 2-49. Ajouter une filiale depuis la page Révision

**Besoin :** Une filiale oubliée s'ajoute au périmètre pendant la révision, sans changer de véhicule.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** UAT-OPCI créé au test « Créer le dossier d'un nouveau client » ; le Compte 1 en est chef de mission. Aucune filiale UAT-SCI-5.

1. Ouvrez la page « Révision ».
2. Dans le sélecteur « VÉHICULE », choisissez « UAT-OPCI · OPCI UAT ».
3. Cliquez le bouton « Ajouter une filiale » de l'en-tête.
4. Lisez l'en-tête du formulaire qui s'ouvre dans la page « Client et Acceptation ».
5. Saisissez « Code de la filiale » : UAT-SCI-5 ; « Dénomination » : SCI UAT 5 ; « Droits de vote (%) » : 100 ; « Contrôlée (R. 214-83) » : oui.
6. Cliquez « Ajouter cette filiale » et lisez la zone « Message de l'écran ».
7. Cliquez le bouton du formulaire dont l'infobulle est « Revient à l'étape en cours de la Révision. ».
8. Page « Révision », remettez le sélecteur « VÉHICULE » sur « OMEGA-OPCI · OPCI OMEGA ».
9. Page « Client et Acceptation », étape « Filiales » de UAT-OPCI : lisez le tableau « Filiales du groupe ».

**Vous devez obtenir :** Le formulaire porte l'en-tête « Ajouter une filiale à UAT-OPCI ». La zone « Message de l'écran » porte le message ci-contre. Le bouton d'infobulle « Revient à l'étape en cours de la Révision. » ouvre la page « Révision ». Le tableau « Filiales du groupe » de UAT-OPCI porte UAT-SCI-5, « Quote-part » 100,00 %, « Contrôlée (R. 214-83) » : oui.

```
Filiale UAT-SCI-5 ajoutée au périmètre de UAT-OPCI. Sa balance sera réclamée à la révision.
```

Passé ☐ · Échec ☐ · Remarque :

### La création du dossier client

#### 2-50. Créer un dossier depuis le classeur du client

**Besoin :** Un dossier se crée depuis le classeur Client rempli, sans ressaisie à l'écran.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Étape 12 faite : le site SharePoint du cabinet est relié au coffre par le raccourci « fec ». Accès en écriture à la bibliothèque de documents du site du cabinet. Aucun client UAT-OPCI-2.

1. Créez un classeur Excel client_essai.xlsx dont la feuille se nomme « Client ».
2. En ligne 2, une colonne par en-tête : code, denomination, forme_vehicule, forme_sociale, adresse_1, code_postal, ville, pays, dirigeant_nom, dirigeant_qualite. La ligne 1 reste libre.
3. En ligne 3 : UAT-OPCI-2, OPCI UAT 2, SPPICAV, SA, 2 rue de l'Essai, 75002, Paris, FR, Société de gestion UAT, société de gestion.
4. Déposez le classeur à la racine du dossier « Dossiers de travail » de la bibliothèque de documents du site du cabinet.
5. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
6. Étape « Dossier », bouton « Nouveau dossier ».
7. Saisissez « Nom du classeur déposé » : client_essai.xlsx et cliquez « Réimporter ».
8. Cliquez UAT-OPCI-2 dans la liste des clients, puis lisez la zone « Message de l'écran » et la colonne « Acceptation » de UAT-OPCI-2.

**Vous devez obtenir :** La liste des clients porte UAT-OPCI-2, colonne « Acceptation » : En cours. UAT-OPCI-2 choisi, la zone « Message de l'écran » porte le message ci-contre : créé par classeur, le message est rangé sous le code du nouveau client et ne s'affiche que lui choisi, ou quand aucune ligne n'est choisie.

```
Client UAT-OPCI-2 créé, vous en êtes le chef de mission. Questionnaire d'acceptation ouvert : 110 questions. Passez à l'étape 3.
```

Passé ☐ · Échec ☐ · Remarque :

### Les pièces justificatives du dossier

#### 2-51. Rattacher une pièce déposée par le client

**Besoin :** Une pièce déposée dans le site du client s'inscrit au dossier avec sa nature, sa question et son déposant.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Jeu de démonstration et étape 12 faits : site SharePoint d'OMEGA-OPCI provisionné, raccourci du Dépôt du client créé. Le Compte 1 a accès en écriture au site d'OMEGA-OPCI (propriétaire désigné au provisionnement). Un fichier d'essai nommé lettre_mission_essai.pdf, au contenu créé pour l'essai et jamais déposé.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Pièce ».
3. Cliquez « Ouvrir le dépôt du client » et déposez lettre_mission_essai.pdf à la racine de la bibliothèque qui s'ouvre.
4. Remplacez le contenu de « Nom du fichier déposé, sous-dossier facultatif », qui peut garder essai.pdf du test « Rattachement d'une pièce refusé pour un client sans site SharePoint », par lettre_mission_essai.pdf. Vérifiez que « Nature » porte Lettre de mission seule, sinon choisissez-la : un clic sur une nature déjà cochée la décoche. Choisissez « Question » : ACC-LM02.
5. Cliquez « Rattacher la pièce ».
6. Cliquez l'étape « Questionnaire et pièces » ; si son en-tête ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran » et la colonne « Pièces » de la ligne ACC-LM02.
7. Cliquez « Retirer une pièce » et ouvrez la liste « PIÈCE À RETIRER ».

**Vous devez obtenir :** « Ouvrir le dépôt du client » ouvre la bibliothèque « Dépôt du client » du site d'OMEGA-OPCI. La zone « Message de l'écran » porte le message ci-contre ; la taille du fichier en Ko n'y figure pas, la fonction ne l'ajoute qu'à la valeur qu'elle rend. La colonne « Pièces » de ACC-LM02 porte 1 : le jeu de démonstration ne rattache aucune pièce à une question, et aucun test joué avant celui-ci ne rattache de pièce à ACC-LM02 pour OMEGA-OPCI. La liste « PIÈCE À RETIRER » porte « lettre_mission_essai.pdf · sans arrêté · n° <numéro> », où <numéro> est le numéro du rattachement.

```
Pièce « lettre_mission_essai.pdf » inscrite au dossier de OMEGA-OPCI, rattachée à la question ACC-LM02.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-52. Une même pièce ne s'inscrit pas 2 fois

**Besoin :** Chaque fichier ne figure qu'une fois parmi les pièces du dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** lettre_mission_essai.pdf inscrite au dossier d'OMEGA-OPCI (test « Rattacher une pièce déposée par le client »).

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Pièce ».
3. Vérifiez que « Nom du fichier déposé, sous-dossier facultatif » porte lettre_mission_essai.pdf, sinon remplacez son contenu par ce nom. Vérifiez que « Nature » porte Lettre de mission seule, sinon choisissez-la : un clic sur une nature déjà cochée la décoche.
4. Cliquez « Rattacher la pièce ».
5. Cliquez l'étape « Questionnaire et pièces » ; si son en-tête ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran ».
6. Cliquez « Retirer une pièce » et ouvrez la liste « PIÈCE À RETIRER ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre, où <n> est l'identifiant de la pièce en base, que l'écran n'affiche pas : la liste « PIÈCE À RETIRER » porte le n° du rattachement, non celui de la pièce. La liste « PIÈCE À RETIRER » porte 1 seule ligne lettre_mission_essai.pdf.

```
Ce fichier est déjà inscrit, pièce n° <n> ; il n'est pas déposé deux fois.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-53. Rattachement refusé pour un fichier absent du Dépôt du client

**Besoin :** Une pièce ne s'inscrit au dossier que si son fichier est dans le Dépôt du client.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Jeu de démonstration et étape 12 faits : site SharePoint d'OMEGA-OPCI provisionné, raccourci du Dépôt du client créé. Aucun fichier absent_essai.pdf dans le Dépôt du client d'OMEGA-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Pièce ».
3. Remplacez le contenu de « Nom du fichier déposé, sous-dossier facultatif », qui peut garder lettre_mission_essai.pdf du test « Une même pièce ne s'inscrit pas 2 fois », par absent_essai.pdf. Vérifiez que « Nature » porte Lettre de mission seule, sinon choisissez-la : un clic sur une nature déjà cochée la décoche.
4. Cliquez « Rattacher la pièce ».
5. Cliquez l'étape « Questionnaire et pièces » ; si son en-tête ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran ».
6. Cliquez « Retirer une pièce » et ouvrez la liste « PIÈCE À RETIRER ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Aucune pièce absent_essai.pdf n'est inscrite : la liste « PIÈCE À RETIRER » ne la porte pas.

```
Le fichier « absent_essai.pdf » n'est pas dans la bibliothèque Dépôt du client de OMEGA-OPCI. Vérifiez son nom et son sous-dossier.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-54. Retrait d'une pièce refusé sans motif

**Besoin :** Le retrait d'une pièce laisse son motif dans la trace du dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** lettre_mission_essai.pdf inscrite au dossier d'OMEGA-OPCI ; le Compte 1 est membre de l'équipe d'OMEGA-OPCI.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Retirer une pièce ».
3. Choisissez dans « PIÈCE À RETIRER » la ligne lettre_mission_essai.pdf · sans arrêté · n° <numéro> : elle doit y être la seule choisie.
4. Vérifiez que « MOTIF DU RETRAIT » est vide, sinon effacez-le. Cliquez « Retirer la pièce ».
5. Lisez l'en-tête du sous-état : s'il ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran » et la liste « PIÈCE À RETIRER ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La pièce figure toujours dans « PIÈCE À RETIRER ».

```
Le motif du retrait est obligatoire : il reste dans la trace du dossier.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-55. Retrait refusé pour une pièce qui fonde une expertise

**Besoin :** Une pièce sur laquelle repose une donnée du dossier ne s'en retire pas.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Jeu de démonstration : la pièce Rapport_evaluation_IMM-201_2025-12-31.pdf, rattachée à OMEGA-OPCI au 31/12/2025 (rattachement n° 2), fonde l'expertise de l'immeuble IMM-201 au 31/12/2025 ; le dossier du 31/12/2025 n'est pas verrouillé.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Retirer une pièce ».
3. Choisissez dans « PIÈCE À RETIRER » la ligne Rapport_evaluation_IMM-201_2025-12-31.pdf · 31/12/2025 · n° 2 : elle doit y être la seule choisie.
4. Lisez l'avis du sous-état et la colonne « Retrait » du tableau « Pièces du dossier » pour cette pièce.
5. Vérifiez que « MOTIF DU RETRAIT » est vide, sinon effacez-le ; saisissez-y essai. Cliquez « Retirer la pièce ».
6. Lisez l'en-tête du sous-état : s'il ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran » et la liste « PIÈCE À RETIRER ».

**Vous devez obtenir :** L'avis porte le texte ci-contre et le bouton « Retirer la pièce » est grisé. La colonne « Retrait » porte « fonde une expertise ». Au clic, la zone « Message de l'écran » affiche le même refus. La pièce figure toujours dans « PIÈCE À RETIRER ».

```
La pièce fonde une expertise : elle ne se retire pas du dossier.
```

Passé ☐ · Échec ☐ · Remarque :

#### 2-56. Retirer une pièce du dossier avec son motif

**Besoin :** Une pièce rattachée par erreur se retire du dossier ; le fichier reste dans SharePoint et le retrait est tracé.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** lettre_mission_essai.pdf inscrite au dossier d'OMEGA-OPCI, sans autre rattachement.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Cliquez l'étape « Questionnaire et pièces » et lisez son en-tête : s'il porte OMEGA-OPCI, ne cliquez pas la liste des clients ; sinon, cliquez la ligne OMEGA-OPCI de la liste des clients. Un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier, UAT-OPCI-2. Cliquez ensuite le bouton « Retirer une pièce ».
3. Choisissez dans « PIÈCE À RETIRER » la ligne lettre_mission_essai.pdf · sans arrêté · n° <numéro> : elle doit y être la seule choisie.
4. Remplacez le contenu de « MOTIF DU RETRAIT », qui peut garder essai du test « Retrait refusé pour une pièce qui fonde une expertise », par Pièce rattachée pour l'essai. Cliquez « Retirer la pièce ».
5. Lisez l'en-tête du sous-état : s'il ne porte plus OMEGA-OPCI, cliquez la ligne OMEGA-OPCI de la liste des clients. Lisez la zone « Message de l'écran », le tableau « Pièces retirées du dossier » et la liste « PIÈCE À RETIRER ».
6. Ouvrez la bibliothèque « Dépôt du client » du site d'OMEGA-OPCI.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le tableau « Pièces retirées du dossier » porte lettre_mission_essai.pdf, « Question » ACC-LM02, « Motif du retrait » : Pièce rattachée pour l'essai, « Retirée par » : le nom que role_mission porte pour le Compte 1 sur OMEGA-OPCI, soit son adresse de connexion inscrite par sql/90_vous_inscrire_aux_missions.sql, « Retirée le » au format jj/mm/aaaa hh:mm UTC. La liste « PIÈCE À RETIRER » ne porte plus la pièce. Le fichier est toujours dans la bibliothèque « Dépôt du client ».

```
Pièce « lettre_mission_essai.pdf » retirée du dossier d'OMEGA-OPCI (question ACC-LM02). Le fichier reste dans SharePoint ; le retrait est tracé.
```

Passé ☐ · Échec ☐ · Remarque :

### Le suivi des acceptations du cabinet, tests manuels

#### 2-57. Recompter les acceptations à faire depuis la liste des clients

**Nature :** Contrôle par recalcul  
**Besoin :** Le compteur des acceptations à faire concorde avec l'état d'acceptation de chaque client de la liste.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Tests du visa de UAT-OPCI joués. Aucune ligne choisie dans la liste des clients.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission.
2. Si une ligne de la liste des clients est choisie, cliquez-la de nouveau pour la désélectionner.
3. Relevez la valeur des cartes « CLIENTS DU CABINET » et « ACCEPTATIONS À FAIRE », 1re et 2e cartes de la bande d'indicateurs, et la ligne sous la carte « ACCEPTATIONS À FAIRE ».
4. Dans la liste des clients, comptez les lignes de véhicule : celles dont la colonne « Entité » ne commence pas par « └ ».
5. Parmi elles, comptez celles dont la colonne « Acceptation » n'est pas « Approuvée ».
6. Comparez vos 2 décomptes aux cartes.

**Ce que vous comparez ou notez :** La carte « CLIENTS DU CABINET » égale le nombre de lignes de véhicule. La carte « ACCEPTATIONS À FAIRE » égale le nombre de lignes de véhicule dont « Acceptation » n'est pas « Approuvée ». La ligne sous la carte porte « <a> sur <c> clients » avec ces 2 nombres, ou « toutes approuvées » quand le second décompte vaut 0. Écart admis : 0. Les lignes de véhicule de la liste sont les entités dont la forme du véhicule est renseignée, la carte compte les entités clientes, et la création d'un client pose les 2 à la fois ; la colonne « Acceptation » et la carte lisent le même statut d'acceptation. Sur une installation neuve où le cahier est joué dans l'ordre, la liste porte à ce rang 4 véhicules, OMEGA-OPCI et UAT-OPCI « Approuvée », OPCI-1 « À faire », UAT-OPCI-2 « En cours » : les cartes portent 4 et 2, la ligne « 2 sur 4 clients ».

Passé ☐ · Échec ☐ · Constats :

### L'acceptation d'un nouveau client, tests manuels

#### 2-58. Accepter un nouveau client jusqu'au visa

**Nature :** Parcours métier  
**Besoin :** Le chef de mission conduit l'acceptation d'un nouveau client, de la création du dossier au visa de l'associé, sur la page « Client et Acceptation ».  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 1, qui crée le dossier et en devient chef de mission ; Compte 2, désigné associé signataire pendant le parcours, disponible pour le visa. Étape 12 faite. Un code de client choisi par le testeur et commençant par UAT-, par exemple UAT-PM-OPCI ; toute filiale créée pendant le parcours porte aussi un code commençant par UAT-.

1. Objectif : amener un client fictif de votre choix de la création du dossier au visa de son acceptation, comme pour un client réel.
2. Périmètre : page « Client et Acceptation », étapes « Dossier », « Filiales », « Questionnaire et pièces » et « Visa » ; un client nouveau créé par vous ; le Compte 2 pour le visa.
3. Créez le dossier sous un code commençant par UAT-, renseignez ses filiales sous des codes commençant par UAT-, désignez l'associé signataire et répondez au questionnaire, à l'écran ou par classeur, dans l'ordre que vous choisissez.
4. Faites viser l'acceptation par le Compte 2.
5. Notez, à chaque étape, ce qui vous a arrêté et ce qui vous a manqué, ainsi que l'heure de début et l'heure de fin.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté (message, bouton grisé, information introuvable), ce qui lui a manqué pour conduire l'acceptation et le temps passé. Résultat d'ensemble à atteindre : la section « Acceptation de la mission » du client porte « Statut » : Approuvée, « Décision » : Acceptée et « Visa » : l'adresse de connexion du Compte 2 · la date du jour ; le tableau « Rôles du dossier » porte l'associé signataire et le chef de mission, état « désigné » ; le bandeau de l'étape « Visa » commence par « Acceptation approuvée ».

Passé ☐ · Échec ☐ · Constats :

#### 2-59. Ouvrir la mission d'un client accepté : périmètre et premier arrêté

**Nature :** Parcours métier  
**Besoin :** Une fois le client accepté, le chef de mission fixe le périmètre du véhicule et ouvre le premier arrêté de l'exercice.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Client du parcours « Accepter un nouveau client jusqu'au visa », acceptation approuvée ; le Compte 1 en est chef de mission. Étape 12 faite.

1. Objectif : préparer le client accepté à sa première révision.
2. Périmètre : page « Client et Acceptation », étapes « Filiales » et « Arrêtés » du client du parcours précédent.
3. Ajoutez au moins 2 filiales, sous des codes commençant par UAT-, avec leurs droits de vote et leur classement, dont l'une par un classeur des filiales déposé dans le dossier « Dossiers de travail/<code du client> » du site du cabinet.
4. Ouvrez le premier arrêté de l'exercice en cours, avec la périodicité de la valeur liquidative de votre choix.
5. Notez ce qui vous a arrêté, ce qui vous a manqué et le temps passé.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté, ce qui lui a manqué et le temps passé. Résultat d'ensemble à atteindre : le tableau « Filiales du groupe » porte les filiales avec leur « Quote-part » et leur classement « Contrôlée (R. 214-83) » ; le tableau des arrêtés porte les arrêtés de l'exercice selon la périodicité choisie, le premier avec « Ouvert le » à la date du jour ; le message d'ouverture se termine par « ouvert : la révision peut commencer. ».

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 3. La révision de l'arrêté

### Programmer le travail de révision

#### 3-01. Choisir le programme de travail Classique

**Besoin :** Le réviseur arrête, pour l'arrêté, la liste des questions de révision à traiter, cycle par cycle.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Groupes 1 et 2 joués. Client OMEGA-OPCI, arrêté 2025-12-31 ouvert, de type ANNUEL (sql/80_demonstration/46_arrete_mission.sql:9). Le jeu de démonstration ne charge aucun programme de travail. Compte 1 inscrit ASSOCIE et PREPARATEUR par sql/90_vous_inscrire_aux_missions.sql:61-64. Référentiel des questions non modifié.

1. Ouvrir la page « Révision ».
2. Dans « VÉHICULE », choisir « OMEGA-OPCI · OPCI OMEGA » ; dans « ARRÊTÉ », choisir « 31/12/2025 ».
3. Cliquer l'étape 2 de la barre, « Programme de travail ».
4. Cliquer le bouton « Choisir » du type Classique, le 2e des 3 types (Allégé, Classique, Étendu).
5. Lire la carte d'état du type Classique et la carte « PROGRAMME DE TRAVAIL » de la bande d'indicateurs.
6. Cliquer l'étape 3 de la barre, « Questionnaires », et lire la zone de message en bas à droite.

**Vous devez obtenir :** La carte d'état du type Classique affiche « choisi » ou « choisi, proposé ». La carte « PROGRAMME DE TRAVAIL » affiche « CLASSIQUE », sous-titre « 11 cycles, 375 questions ». L'étape 2 n'a pas de zone de message : à l'étape 3, la zone, sur fond vert pâle, porte la phrase ci-dessous, 375 questions de cycle entrant au programme sur les 11 cycles du référentiel, aucune ne sortant ; la 2e phrase s'ajoute parce qu'aucune question du référentiel ne porte de niveau de programme. La zone tient sur 2 lignes : la 1re se lit « Programme classique : 375 questions sur 11 cycles, 375 entrée(s), 0 sortie(s). Les 3 types », la 2e « sélectionnent encore les mêmes questions : la profondeur des questions se renseigne aux… ».

```
Programme classique : 375 questions sur 11 cycles, 375 entrée(s), 0 sortie(s). Les 3 types sélectionnent encore les mêmes questions : la profondeur des questions se renseigne aux Référentiels.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-02. Vérifier que chaque compte de la balance est couvert par le programme

**Besoin :** Le réviseur s'assure que chaque compte de la balance de l'arrêté est revu par au moins une question du programme.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Choisir le programme de travail Classique » passé ; les 11 cycles au programme. Aucun lot ajouté à OMEGA-OPCI au 31/12/2025 par les groupes 1 et 2.

1. Page « Révision », OMEGA-OPCI et 31/12/2025 choisis, étape 2 « Programme de travail ».
2. Cliquer « Vérifier la couverture de la balance ».
3. Lire le tableau « 3. Couverture de la balance ».
4. Cliquer l'étape 3 « Questionnaires », puis cliquer « Actualiser » dans la barre d'actions du service Power BI : le bouton « Vérifier la couverture de la balance » n'actualise pas la page de lui-même. Lire la zone de message.

**Vous devez obtenir :** Après l'actualisation, la zone de message de l'étape 3 affiche la phrase ci-dessous, sur une ligne : chaque racine de compte de la balance d'OMEGA-OPCI au 31/12/2025 (10, 11, 12, 21, 25, 26, 27, 51, 61, 62, 72, 73) relève d'un cycle du référentiel, et chaque cycle est au programme. Avant l'actualisation, la zone peut encore porter la phrase du test « Choisir le programme de travail Classique ». Le bouton n'écrit rien. Le tableau « 3. Couverture de la balance » liste les 20 comptes avec leur libellé, leur solde et leurs cycles ; aucun n'est hors du programme.

```
La balance est couverte : 20 comptes, tous revus par une question du programme.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-03. Un cycle qui porte des comptes en balance ne se retire pas du programme

**Besoin :** La couverture de la balance ne se dégrade pas : un cycle dont des comptes figurent en balance reste au programme.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test « Choisir le programme de travail Classique » passé. Comptes 511 et 512 en balance d'OMEGA-OPCI au 31/12/2025, racine 51 du cycle TRESO (sql/10_referentiels/52_ref_cycle_compte.sql:59 ; sql/80_demonstration/99_ecriture.sql, lot 35).

1. Page « Révision », OMEGA-OPCI et 31/12/2025 choisis : cliquer l'étape 2 « Programme de travail ».
2. Dans la bande des cycles, en haut de la page, choisir « Trésorerie » ; la grille de droite s'intitule alors « Questions du cycle TRESO ». Le choix d'une ligne de la grille « 2. Cycles du programme » ne désigne pas le cycle des boutons.
3. Lire la colonne « Comptes » de la ligne « Trésorerie » dans la grille « 2. Cycles du programme ».
4. Saisir « Essai » dans « Motif du retrait ».
5. Observer le bouton « Retirer le cycle ».

**Vous devez obtenir :** La colonne « Comptes » de « Trésorerie » vaut 2. Le bouton « Retirer le cycle » est inactif (grisé) : son paramètre de cycle, la mesure « Cycle retirable », reste vide pour un cycle qui porte des comptes en balance, et le service désactive un bouton dont un paramètre obligatoire est vide. La base porte la même règle pour un appel direct (refus 50323 de pr_activer_cycle).

Passé ☐ · Échec ☐ · Remarque :

#### 3-04. Retirer un cycle sans compte en balance, avec son motif, puis le réactiver

**Besoin :** Le réviseur écarte du programme un cycle sans objet pour l'arrêté, le motif restant au journal du programme, et peut le réintégrer.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Un cycle qui porte des comptes en balance ne se retire pas du programme » passé : « Trésorerie » choisi dans la bande des cycles, et « Motif du retrait » garde « Essai » (« Retirer le cycle » et « Activer le cycle » ne vident pas ce champ). Aucune réponse dans le cycle HB. Les racines du cycle HB (90, 91, 92, 94, 95, 96) ne figurent pas dans la balance d'OMEGA-OPCI au 31/12/2025 (sql/10_referentiels/52_ref_cycle_compte.sql:28-33 ; sql/80_demonstration/99_ecriture.sql).

1. Étape 2 « Programme de travail » : effacer « Essai » dans « Motif du retrait » et laisser le champ vide.
2. Dans la bande des cycles, choisir « Hors bilan » ; la grille de droite s'intitule « Questions du cycle HB », et la ligne « Hors bilan » de la grille « 2. Cycles du programme » porte 0 en colonne « Comptes ».
3. Cliquer « Retirer le cycle » ; lire la bulle de refus du service.
4. Saisir « Aucun engagement hors bilan à l'arrêté » dans « Motif du retrait ». Vérifier que « Hors bilan » est toujours choisi dans la bande des cycles, sinon le choisir. Cliquer « Retirer le cycle ».
5. Cliquer l'étape 3 « Questionnaires », lire la zone de message, puis cliquer l'étape 2.
6. Effacer le motif de « Motif du retrait » : sinon il part avec l'activation et s'écrit au journal du programme.
7. Vérifier que « Hors bilan » est choisi dans la bande des cycles, sinon le choisir ; cliquer « Activer le cycle ».
8. Cliquer l'étape 3 et lire la zone de message.

**Vous devez obtenir :** 1er clic : refus ci-dessous dans la bulle du service ; le cycle reste au programme. 2e clic : la zone de message de l'étape 3 affiche « Cycle HB retiré : 11 question(s) sortie(s) du programme. » ; la colonne « Statut » de « Hors bilan » passe à « Inactif ». 3e clic : « Cycle HB activé : 11 question(s) entrée(s) au programme. » ; « Statut » revient à « Actif ».

```
Le motif du retrait est obligatoire : il reste au journal du programme.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-05. Retirer une question du programme avec son motif, puis la réintégrer

**Besoin :** Le réviseur ajuste le programme question par question, chaque retrait étant motivé au journal du programme.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Retirer un cycle sans compte en balance, avec son motif, puis le réactiver » passé : « Hors bilan » choisi dans la bande des cycles, « Motif du retrait » vide (le champ garde sa saisie d'un clic à l'autre). TRESO-23 au programme et sans réponse (sql/10_referentiels/55_ref_question.sql:478).

1. Étape 2 : vérifier que « Motif du retrait » est vide ; l'effacer sinon.
2. Dans la bande des cycles, choisir « Trésorerie » ; dans la grille « Questions du cycle TRESO », choisir TRESO-23.
3. Cliquer « Retirer du programme » ; lire la bulle de refus du service.
4. Saisir « Question couverte par TRESO-10 » dans « Motif du retrait ». Vérifier que TRESO-23 est toujours choisie ; sinon la choisir, sans recliquer une ligne déjà choisie, ce qui la désélectionnerait et griserait le bouton. Cliquer « Retirer du programme ».
5. Cliquer l'étape 3 « Questionnaires », lire la zone de message, puis cliquer l'étape 2.
6. Effacer le motif de « Motif du retrait » : sinon il part avec l'ajout et s'écrit au journal du programme.
7. Vérifier que « Trésorerie » est choisi dans la bande des cycles, sinon le choisir ; choisir TRESO-23 dans la grille si elle n'est plus choisie ; cliquer « Ajouter au programme ».
8. Cliquer l'étape 3 et lire la zone de message.

**Vous devez obtenir :** 1er clic : refus ci-dessous dans la bulle du service. 2e clic : la zone de message de l'étape 3 affiche « Question TRESO-23 retirée du programme. » ; la colonne « Questions » de « Trésorerie » passe à « 22 / 23 ». 3e clic : « Question TRESO-23 ajoutée au programme. » ; « Questions » revient à « 23 / 23 ».

```
Le motif du retrait est obligatoire : il reste au journal du programme.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-06. Ouvrir le classeur des questions d'un cycle

**Besoin :** Le réviseur dispose des questions d'un cycle dans un classeur déposé au site du cabinet, pour les préparer hors de l'écran.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Retirer une question du programme avec son motif, puis la réintégrer » passé : « Trésorerie » choisi dans la bande des cycles, TRESO-23 de nouveau au programme. Étape 12 faite : dépôt des classeurs installé, paramètres DEPOT_CLASSEUR_URL et SITE_CABINET renseignés (docs/faire/etape-12-relier-sharepoint.md:14).

1. Étape 2 : vérifier que « Trésorerie » est choisi dans la bande des cycles (la grille de droite s'intitule « Questions du cycle TRESO »), sinon le choisir.
2. Cliquer « Ouvrir le classeur des questions du cycle ».
3. Cliquer l'étape 3 « Questionnaires », puis cliquer « Actualiser » dans la barre d'actions du service Power BI : ce bouton n'actualise pas la page de lui-même. Lire la zone de message.
4. Cliquer « Voir le dossier exporté » ; page « Dossier de travail », ouvrir la ligne questions_TRESO_OMEGA-OPCI_2025-12-31.xlsx par son lien « Ouvrir le dossier » ; si la ligne n'y figure pas, cliquer « Actualiser ».

**Vous devez obtenir :** Après l'actualisation, la zone de message de l'étape 3 porte la phrase ci-dessous : sa 1re ligne se lit « Classeur de 23 questions déposé au site du cabinet : », l'adresse occupe la 2e ligne, coupée par « … » quand elle la dépasse. La page « Dossier de travail » porte questions_TRESO_OMEGA-OPCI_2025-12-31.xlsx ; le classeur a un onglet « Q-TRESO » dont la 1re ligne porte Cycle, Référence, Question, Type, Réponse, Motif si non applicable, Commentaire, Feuille, OD, Pièces, et les 23 questions de TRESO à partir de la 3e ligne.

```
Classeur de 23 questions déposé au site du cabinet : <adresse>
```

Passé ☐ · Échec ☐ · Remarque :

### Répondre au questionnaire des cycles

#### 3-07. Répondre à une question du cycle

**Besoin :** Le réviseur consigne sa réponse à chaque question du programme, enregistrée au dossier de l'arrêté.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test « Ouvrir le classeur des questions d'un cycle » passé : il finit sur la page « Dossier de travail », et « Trésorerie » reste choisi dans la bande des cycles de la page « Révision ». Aucune réponse au programme.

1. Sur la page « Dossier de travail », cliquer le bouton en haut à gauche, d'infobulle « Revenir à la Révision » : la page « Révision » s'ouvre.
2. Cliquer l'étape 3 de la barre, « Questionnaires », si elle n'est pas affichée.
3. Dans la bande des cycles, vérifier que « Trésorerie » est choisi, sinon le choisir.
4. Dans la grille « Questions du cycle Trésorerie », choisir TRESO-21.
5. Lire la carte « QUESTIONS RÉPONDUES », puis cliquer « Oui ».
6. Cliquer « Actualiser » dans la barre d'actions du service Power BI : les boutons « Oui », « Non » et « NA » n'actualisent pas la page d'eux-mêmes. Lire la zone de message, la colonne « Réponse » de TRESO-21 et la carte « QUESTIONS RÉPONDUES ».

**Vous devez obtenir :** Avant le clic, la carte « QUESTIONS RÉPONDUES » affiche « 0 / 375 ». Après l'actualisation, la zone de message, sur fond vert pâle, affiche la phrase ci-dessous ; la colonne « Réponse » de TRESO-21 porte OUI ; la carte affiche « 1 / 375 ».

```
Réponse à TRESO-21 enregistrée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-08. La non-applicabilité est refusée à une question qui ne l'admet pas

**Besoin :** Une question fermée Oui ou Non reçoit Oui ou Non, jamais une non-applicabilité.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** TRESO-21 est de type OUI_NON (sql/10_referentiels/55_ref_question.sql:476) et porte la réponse OUI (test « Répondre à une question du cycle »).

1. Étape 3, bande des cycles « Trésorerie » : vérifier que TRESO-21 est choisie dans la grille (ligne en surbrillance) ; sinon la choisir, sans recliquer une ligne déjà choisie, ce qui la désélectionnerait et griserait les boutons de réponse.
2. Saisir « Sans objet » dans « Motif si NA ».
3. Cliquer « NA », puis cliquer « Actualiser » dans la barre d'actions du service Power BI ; lire la zone de message et la colonne « Réponse » de TRESO-21.

**Vous devez obtenir :** Après l'actualisation, la zone de message, sur fond rose, porte le refus ci-dessous. La réponse de TRESO-21 reste OUI. Le champ « Motif si NA » garde « Sans objet » après le clic.

```
La question TRESO-21 n'admet pas la non-applicabilité.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-09. Déclarer une question non applicable exige un motif

**Besoin :** Une non-applicabilité se justifie : le motif reste au dossier de l'arrêté.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** TRESO-01, de type OUI_NON_NA (sql/10_referentiels/55_ref_question.sql:309), sans réponse. « Motif si NA » porte encore « Sans objet », saisi au test « La non-applicabilité est refusée à une question qui ne l'admet pas ».

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-01.
2. Effacer « Sans objet » dans « Motif si NA » et laisser le champ vide.
3. Cliquer « NA », puis cliquer « Actualiser » dans la barre d'actions du service Power BI ; lire la zone de message.
4. Saisir « Motif saisi pour la recette » dans « Motif si NA ». Vérifier que TRESO-01 est toujours choisie ; sinon la choisir, sans recliquer une ligne déjà choisie. Cliquer « NA », puis « Actualiser ».
5. Lire la zone de message et la colonne « Réponse » de TRESO-01.

**Vous devez obtenir :** 1er clic : après l'actualisation, la zone de message, sur fond rose, porte le refus ci-dessous. 2e clic : après l'actualisation, la zone, sur fond vert pâle, porte « Réponse à TRESO-01 enregistrée. » ; la colonne « Réponse » de TRESO-01 porte NON_APPLICABLE.

```
La question TRESO-01 est déclarée non applicable sans motif. Le motif est obligatoire.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-10. Le type du programme ne change plus après une première réponse

**Besoin :** Les réponses déjà données ne sont pas emportées par un changement de type de programme.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Au moins une question du programme porte une réponse (tests précédents).

1. Cliquer l'étape 2 « Programme de travail ».
2. Observer les 3 boutons « Choisir » (Allégé, Classique, Étendu).

**Vous devez obtenir :** Les 3 boutons « Choisir » sont inactifs (grisés) : le type choisi ne se choisit pas de nouveau, et les 2 autres types se ferment dès qu'une question du programme porte une réponse. La base porte la même règle pour un appel direct (refus 50304 de pr_choisir_programme).

Passé ☐ · Échec ☐ · Remarque :

#### 3-11. Répondre en nombre aux questions d'un cycle par le classeur du dossier de travail

**Besoin :** Le réviseur renseigne les réponses d'un cycle dans le classeur du dossier de travail et les reprend à l'écran en une fois.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Étape 12 faite (dépôt des classeurs et raccourci fec). Programme Classique choisi, HB réactivé et TRESO-23 réintégré par les tests précédents ; TRESO-01 et TRESO-21 répondues ; aucune feuille de travail encore ouverte dans ce groupe. Feuilles du jeu au 31/12/2025 : AFF-OMEGA-OPCI-20251231, VAL275-2025-12-31, VALO-20251231, non conclues, et DEM-VALO-OMEGA-OPCI-20251231, conclue et visée (sql/80_demonstration/73_feuille_travail.sql:12, :63, :71, :75 ; sql/80_demonstration/70_visa.sql:9).

1. Étape 3 « Questionnaires » : cliquer « Exporter le dossier », puis cliquer « Actualiser » dans la barre d'actions du service Power BI : ce bouton n'actualise pas la page de lui-même. Lire la zone de message.
2. Cliquer « Voir le dossier exporté » ; page « Dossier de travail », ouvrir dossier_OMEGA-OPCI_2025-12-31.xlsx par le lien « Ouvrir le dossier » ; si la ligne n'y figure pas, cliquer « Actualiser ».
3. Dans l'onglet « Q-TRESO », saisir OUI dans la colonne « Réponse » de chaque question qui n'en porte pas ; enregistrer et fermer le classeur.
4. Revenir à la page « Révision », étape 3, cliquer « Réimporter le dossier » ; lire la zone de message.
5. Choisir « Trésorerie » dans la bande des cycles ; lire la colonne « Réponse » de la grille et la carte « QUESTIONS RÉPONDUES ».

**Vous devez obtenir :** Export : après l'actualisation, la 1re ligne de la zone se lit « Dossier de travail, 29 onglets, déposé au site du cabinet : ». Réimport : la zone passe au fond rose et sa phrase commence par « Classeur relu au site du cabinet. 15 onglet(s) importé(s). » ; les 11 onglets Q-, les feuilles AFF-OMEGA-OPCI-20251231, VAL275-2025-12-31 et VALO-20251231 et l'onglet OD libres sont repris ; l'onglet DEM-VALO-OMEGA-OPCI-20251231 est refusé par la base sans arrêter les autres, et la zone de message le dit par la partie ci-dessous, qui finit la phrase. Les 23 questions de Trésorerie portent une réponse ; la carte « QUESTIONS RÉPONDUES » affiche « 23 / 375 ».

```
Refusés : DEM-VALO-OMEGA-OPCI-20251231 : Cette feuille est conclue et visée ; elle ne se modifie plus.
```

**Anomalie connue :** Le réimport réussit pour les onglets valides. La zone de message tient sur 2 lignes et la phrase nomme d'abord les onglets importés : la liste des onglets refusés ne se lit pas.

Passé ☐ · Échec ☐ · Remarque :

### Documenter et conclure les feuilles de travail

#### 3-12. Ouvrir la feuille de travail d'une question

**Besoin :** Le réviseur documente ses travaux sur une feuille de travail rattachée à la question, dont le gabarit est déposé au site du cabinet.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test « Choisir le programme de travail Classique » passé. Étape 12 faite. Aucune feuille ouverte sur TRESO-21.

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-21.
2. Cliquer « Ouvrir la feuille ».
3. Lire la zone de message et la colonne « Feuille » de TRESO-21.
4. Choisir de nouveau TRESO-21 et cliquer une 2e fois « Ouvrir la feuille » ; lire la zone de message.
5. Cliquer « Voir le dossier exporté » et repérer la ligne feuille_FT-TRESO-21-P<p>.xlsx.

**Vous devez obtenir :** 1er clic : phrase ci-dessous, <p> étant le numéro du programme ; la zone en montre 2 lignes, la 2e finissant par « … » avant la fin de l'adresse. La colonne « Feuille » de TRESO-21 porte FT-TRESO-21-P<p>. 2e clic : aucune 2e feuille ; la phrase devient « La feuille FT-TRESO-21-P<p> est déjà ouverte pour la question TRESO-21. Gabarit déposé au site du cabinet : <adresse> ». La page « Dossier de travail » porte feuille_FT-TRESO-21-P<p>.xlsx.

```
Feuille FT-TRESO-21-P<p> ouverte pour la question TRESO-21, gabarit TRESO-RAPPRO. Exportez-la, remplissez-la, redéposez-la. Gabarit déposé au site du cabinet : <adresse>
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-13. La conclusion d'une feuille prend l'une des 3 formes du référentiel

**Besoin :** Chaque feuille conclut sous une forme normalisée : sans observation, avec observation, ou refus d'attester.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Feuille FT-TRESO-21-P<p> ouverte (test « Ouvrir la feuille de travail d'une question »), qui finit sur la page « Dossier de travail ». « Forme de la conclusion » vide.

1. Sur la page « Dossier de travail », cliquer le bouton en haut à gauche, d'infobulle « Revenir à la Révision » ; page « Révision », cliquer l'étape 3 « Questionnaires » si elle n'est pas affichée.
2. Vérifier que « Trésorerie » est choisi dans la bande des cycles, sinon le choisir ; vérifier que TRESO-21 est choisie dans la grille (ligne en surbrillance), sinon la choisir.
3. Laisser « Forme de la conclusion » vide, cliquer « Conclure » ; lire la bulle du service.
4. Saisir FAVORABLE dans « Forme de la conclusion ». Vérifier que TRESO-21 est toujours choisie ; sinon la choisir, sans recliquer une ligne déjà choisie, ce qui la désélectionnerait et griserait « Conclure ». Cliquer « Conclure » ; lire la bulle du service.
5. Cliquer « Actualiser » dans la barre d'actions du service Power BI et lire la zone de message.

**Vous devez obtenir :** 1er clic : la bulle du service porte le refus qui nomme le champ vide, « Champs obligatoires à remplir : « Forme de la conclusion ». ». 2e clic : la bulle porte le refus ci-dessous ; après « Actualiser », la zone de message, sur fond rose, le porte aussi. La feuille reste ouverte.

```
La forme de conclusion est SANS_OBSERVATION, AVEC_OBSERVATION ou REFUS_ATTESTER.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-14. Une dérogation active ferme la conclusion sans observation

**Besoin :** Tant qu'une dérogation accordée sur l'arrêté n'est pas levée, aucune feuille ne conclut sans observation.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Dérogation du jeu de démonstration active sur OMEGA-OPCI au 31/12/2025 (sql/80_demonstration/86_derogation.sql:9, date de levée vide). Feuille FT-TRESO-21-P<p> ouverte ; pièces obligatoires du cycle TRESO rattachées par le jeu (sql/80_demonstration/94_piece_rattachement.sql:57-60, pièces attendues 41, 42, 45 et 46). « Forme de la conclusion » garde FAVORABLE, saisi au test « La conclusion d'une feuille prend l'une des 3 formes du référentiel » (fabric/Conduite de mission.Report/definition/pages/ec02000000000000b001/visuals/revFeuilleConclure/visual.json:483, autoClear faux).

1. Étape 3, bande des cycles « Trésorerie » : vérifier que TRESO-21 est toujours choisie dans la grille ; sinon la choisir, sans recliquer une ligne déjà choisie.
2. Dans « Forme de la conclusion », remplacer FAVORABLE par SANS_OBSERVATION ; cliquer « Conclure » ; lire la bulle du service.
3. Cliquer « Actualiser » dans la barre d'actions du service Power BI et lire la zone de message.

**Vous devez obtenir :** La bulle du service porte le refus ci-dessous. Après « Actualiser », la zone de message, sur fond rose, en montre 2 lignes, la 2e finissant par « … ». La feuille reste ouverte.

```
Conclusion refusée : une dérogation active existe pour cette entité et cet arrêté, la forme sans observation est indisponible. Conclure sous une autre forme, ou faire lever la dérogation par son auteur.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-15. Conclure une feuille de travail avec observation

**Besoin :** Le réviseur conclut sa feuille ; la conclusion alimente la forme du rapport de l'expert-comptable.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Feuille FT-TRESO-21-P<p> ouverte ; pièces obligatoires du cycle TRESO rattachées par le jeu.

1. Étape 3, bande des cycles « Trésorerie » : vérifier que TRESO-21 est toujours choisie dans la grille ; sinon la choisir, sans recliquer une ligne déjà choisie.
2. Dans « Forme de la conclusion », remplacer SANS_OBSERVATION par AVEC_OBSERVATION ; saisir « Rapprochement bancaire justifié, une opération en suspens » dans « Conclusion ».
3. Cliquer « Conclure ».

**Vous devez obtenir :** La zone de message affiche la phrase ci-dessous. La carte « FEUILLES CONCLUES » augmente de 1.

```
Feuille FT-TRESO-21-P<p> reprise et conclue (AVEC_OBSERVATION).
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-16. Une feuille ne se conclut pas tant que manquent les pièces obligatoires de son cycle

**Besoin :** Une conclusion repose sur les pièces obligatoires du cycle, rattachées au dossier de l'arrêté.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test « Choisir le programme de travail Classique » passé. Dans le jeu, la pièce permanente obligatoire « Titre de propriété » du cycle IMMO n'est rattachée à aucun document d'OMEGA-OPCI ; « Rapport d'expertise signé » et « État locatif à la date d'arrêté » le sont au 31/12/2025 (sql/10_referentiels/54_ref_piece_attendue.sql:9-13 ; sql/80_demonstration/94_piece_rattachement.sql:10 et :39). La feuille FT-IMMO-01-P<p> reste ouverte après le test : le cycle IMMO ne se vise plus sur cet arrêté.

1. Étape 3 : choisir « Immeubles » dans la bande des cycles, puis la question IMMO-01.
2. Cliquer « Ouvrir la feuille ».
3. Choisir de nouveau IMMO-01, saisir AVEC_OBSERVATION dans « Forme de la conclusion », cliquer « Conclure ».

**Vous devez obtenir :** L'ouverture rend la phrase « Feuille FT-IMMO-01-P<p> ouverte pour la question IMMO-01, gabarit STD. Exportez-la, remplissez-la, redéposez-la. Gabarit déposé au site du cabinet : <adresse> ». La conclusion est refusée par la phrase ci-dessous, qui nomme la pièce manquante, lue en entier dans la bulle du service ; la feuille reste ouverte.

```
Conclusion refusée : des pièces obligatoires de ce cycle ne sont rattachées à aucun document, pour cette entité et cet arrêté. Manquent : Titre de propriété. Déposer les pièces au coffre, les rattacher à la question, puis conclure.
```

Passé ☐ · Échec ☐ · Remarque :

### Joindre les pièces justificatives

#### 3-17. Rattacher au dossier de l'arrêté une pièce déposée par le client

**Besoin :** Une pièce déposée par le client dans son site SharePoint entre au dossier de l'arrêté, avec sa nature, son déposant et son lien.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Étape 12 faite, points 13 et 14 : site SharePoint d'OMEGA-OPCI et raccourci sp_omega_opci_depot vers sa bibliothèque « Dépôt du client » (docs/faire/etape-12-relier-sharepoint.md:159-160). Un petit fichier PDF nommé uat_releve_2025-12-31.pdf.

1. Page « Révision », étape 3 : cliquer « Joindre une pièce ».
2. Page « Pièce justificative » : ne rien choisir dans « QUESTION ».
3. Cliquer « Ouvrir le dépôt du client » et déposer uat_releve_2025-12-31.pdf à la racine de la bibliothèque.
4. Saisir uat_releve_2025-12-31.pdf dans « Nom du fichier déposé, sous-dossier facultatif » et Relevé bancaire dans « Nature ».
5. Cliquer « Rattacher la pièce ».

**Vous devez obtenir :** La zone de message de la page « Pièce justificative » affiche la phrase ci-dessous. La pièce figure dans le tableau de la page et, avec l'arrêté 31/12/2025, dans la liste « PIÈCE À RETIRER » de l'écran « Client et Acceptation », sous la forme « uat_releve_2025-12-31.pdf · 31/12/2025 · n° <n> ».

```
Pièce « uat_releve_2025-12-31.pdf » inscrite au dossier de OMEGA-OPCI.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-18. Un fichier absent de la bibliothèque du client est refusé

**Besoin :** Seul un fichier réellement déposé par le client entre au dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Étape 12 faite ; aucun fichier absent_uat.pdf dans « Dépôt du client » d'OMEGA-OPCI.

1. Page « Pièce justificative », rien de choisi dans « QUESTION ».
2. Saisir absent_uat.pdf dans « Nom du fichier déposé, sous-dossier facultatif » et Relevé bancaire dans « Nature ».
3. Cliquer « Rattacher la pièce ».

**Vous devez obtenir :** Refus ci-dessous ; rien n'est inscrit.

```
Le fichier « absent_uat.pdf » n'est pas dans la bibliothèque Dépôt du client de OMEGA-OPCI. Vérifiez son nom et son sous-dossier.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-19. Une nature de pièce hors référentiel est refusée

**Besoin :** Chaque pièce porte une nature du référentiel, qui commande son classement et sa conservation.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Fichier uat_releve_2025-12-31.pdf présent dans « Dépôt du client » d'OMEGA-OPCI.

1. Page « Pièce justificative », rien de choisi dans « QUESTION ».
2. Saisir uat_releve_2025-12-31.pdf dans « Nom du fichier déposé, sous-dossier facultatif » et Facture dans « Nature ».
3. Cliquer « Rattacher la pièce ».

**Vous devez obtenir :** Refus ci-dessous : la nature est contrôlée avant le doublon. Rien n'est inscrit.

```
La nature de la pièce n'est pas au référentiel. Les natures se complètent à l'écran Référentiels.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-20. Un même fichier ne s'inscrit pas 2 fois au dossier

**Besoin :** Le dossier ne porte pas 2 fois la même pièce : l'empreinte du fichier la reconnaît.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Rattacher au dossier de l'arrêté une pièce déposée par le client » passé.

1. Page « Pièce justificative », rien de choisi dans « QUESTION ».
2. Saisir uat_releve_2025-12-31.pdf dans « Nom du fichier déposé, sous-dossier facultatif » et Relevé bancaire dans « Nature ».
3. Cliquer « Rattacher la pièce ».

**Vous devez obtenir :** Refus ci-dessous, dans la bulle du service et dans la zone de message ; <n> est le numéro de la pièce créée au test « Rattacher au dossier de l'arrêté une pièce déposée par le client », qui n'est pas le n° de rattachement affiché dans « PIÈCE À RETIRER ». Rien n'est inscrit.

```
Ce fichier est déjà inscrit, pièce n° <n> ; il n'est pas déposé deux fois.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-21. Rattacher une pièce à la question de révision qu'elle justifie

**Besoin :** Le réviseur joint à une question du programme la pièce qui fonde sa réponse, depuis la page « Pièce justificative » qu'ouvre le bouton « Joindre une pièce » de l'étape 3, et dont le titre est « Pièce pour la question sélectionnée ».  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Étape 12 faite, points 13 et 14 : site SharePoint d'OMEGA-OPCI et raccourci sp_omega_opci_depot vers sa bibliothèque « Dépôt du client » (docs/faire/etape-12-relier-sharepoint.md:159-160). Test « Un même fichier ne s'inscrit pas 2 fois au dossier » passé : il finit sur la page « Pièce justificative », où « Nom du fichier déposé, sous-dossier facultatif » garde uat_releve_2025-12-31.pdf, « Nature » garde Relevé bancaire, et rien n'est choisi dans « QUESTION ». Sur la page « Révision », la bande des cycles porte encore « Immeubles », choisi au test « Une feuille ne se conclut pas tant que manquent les pièces obligatoires de son cycle ». TRESO-21 au programme d'OMEGA-OPCI au 31/12/2025, sans pièce rattachée. Un petit fichier PDF nommé uat_rappro_2025-12-31.pdf, de contenu différent de uat_releve_2025-12-31.pdf, l'empreinte du fichier reconnaissant un doublon.

1. Sur la page « Pièce justificative », cliquer le bouton en haut à gauche, d'infobulle « Revenir à la Révision » : la page « Révision » s'ouvre. Cliquer l'étape 3 « Questionnaires » si elle n'est pas affichée.
2. Dans la bande des cycles, vérifier que « Trésorerie » est choisi, sinon le choisir ; lire la colonne « Pièces » de TRESO-21 dans la grille « Questions du cycle Trésorerie ».
3. Cliquer « Joindre une pièce » : la page « Pièce justificative » s'ouvre.
4. Cliquer « Ouvrir le dépôt du client » et déposer uat_rappro_2025-12-31.pdf à la racine de la bibliothèque.
5. Dans la liste « QUESTION », faire défiler jusqu'à TRESO-21 et la choisir, seule.
6. Remplacer le contenu de « Nom du fichier déposé, sous-dossier facultatif » par uat_rappro_2025-12-31.pdf ; vérifier que « Nature » porte Relevé bancaire, sinon le saisir.
7. Cliquer « Rattacher la pièce » ; lire la bulle du service si elle s'affiche. Cliquer « Actualiser » dans la barre d'actions du service Power BI, puis lire la zone de message et le tableau de la page.
8. Cliquer le bouton en haut à gauche de la page, d'infobulle « Revenir à la Révision » ; à l'étape 3, cliquer « Actualiser » dans la barre d'actions du service Power BI, puis relire la colonne « Pièces » de TRESO-21.

**Vous devez obtenir :** Avant le rattachement, la colonne « Pièces » de TRESO-21 vaut 0. Le rattachement réussit : la zone de message de la page « Pièce justificative » porte la phrase ci-dessous, le tableau de la page porte uat_rappro_2025-12-31.pdf avec TRESO-21 en colonne « Question », et, à l'étape 3 de la page « Révision », la colonne « Pièces » de TRESO-21 vaut 1.

```
Pièce « uat_rappro_2025-12-31.pdf » inscrite au dossier de OMEGA-OPCI, rattachée à la question TRESO-21.
```

**Anomalie connue :** La page « Pièce justificative » propose les questions du programme de révision, mais la fonction n'accepte que les questions des questionnaires d'acceptation et de maintien : le rattachement est refusé.

Passé ☐ · Échec ☐ · Remarque :

#### 3-22. Retirer du dossier une pièce rattachée par erreur, avec son motif

**Besoin :** Une pièce rattachée à tort quitte le dossier ; le fichier reste chez le client et le retrait est tracé.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Test « Rattacher au dossier de l'arrêté une pièce déposée par le client » passé. Compte 1 membre de l'équipe d'OMEGA-OPCI.

1. Ouvrir la page « Client et Acceptation ». Dans la liste des clients, choisir OMEGA-OPCI : cliquer sa ligne seulement si elle n'est pas déjà choisie ; un clic sur la ligne déjà choisie la désélectionne, et l'écran passe alors sur le client créé en dernier.
2. Cliquer l'étape « Questionnaire et pièces », puis le bouton « Retirer une pièce ».
3. Dans « PIÈCE À RETIRER », choisir « uat_releve_2025-12-31.pdf · 31/12/2025 · n° <n> ».
4. Saisir « Pièce rattachée pour essai » dans « MOTIF DU RETRAIT ».
5. Cliquer « Retirer la pièce » et lire la zone « Message de l'écran ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche la phrase ci-dessous. La pièce quitte le tableau « Pièces du dossier » et figure au tableau « Pièces retirées du dossier » avec le motif, l'auteur et la date. Le fichier reste dans la bibliothèque « Dépôt du client ».

```
Pièce « uat_releve_2025-12-31.pdf » retirée du dossier d'OMEGA-OPCI, arrêté du 31/12/2025. Le fichier reste dans SharePoint ; le retrait est tracé.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-23. Une pièce qui fonde la conclusion d'une feuille ne se retire pas

**Besoin :** Une feuille conclue sur une pièce obligatoire garde cette pièce au dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Dans le jeu, la pièce Piece_21_OMEGA-OPCI_2025-12-31.pdf, rattachement n° 36, satisfait la pièce obligatoire « Rapport du comité de valorisation » du cycle VALO ; la feuille DEM-VALO-OMEGA-OPCI-20251231 de ce cycle est conclue (sql/80_demonstration/94_piece_rattachement.sql:44 ; sql/80_demonstration/75_piece.sql:45 ; sql/10_referentiels/54_ref_piece_attendue.sql:29 ; sql/80_demonstration/73_feuille_travail.sql:63).

1. Page « Client et Acceptation » : vérifier qu'OMEGA-OPCI est choisi dans la liste des clients (ligne en surbrillance) ; sinon cliquer sa ligne, jamais une ligne déjà choisie, ce qui la désélectionnerait et ferait passer l'écran sur le client créé en dernier. Cliquer l'étape « Questionnaire et pièces », puis le bouton « Retirer une pièce ».
2. Dans le tableau « Pièces du dossier », lire la colonne « Retrait » de la pièce Piece_21_OMEGA-OPCI_2025-12-31.pdf.
3. Dans « PIÈCE À RETIRER », vidé par le clic du test précédent, choisir « Piece_21_OMEGA-OPCI_2025-12-31.pdf · 31/12/2025 · n° 36 » ; lire l'avis du sous-état ; saisir « Essai de retrait » dans « MOTIF DU RETRAIT ».
4. Cliquer « Retirer la pièce » et lire la bulle du service.
5. Cliquer « Actualiser » dans la barre d'actions du service Power BI et lire la zone « Message de l'écran ».

**Vous devez obtenir :** Avant le clic, la colonne « Retrait » porte « fonde une conclusion » et l'avis du sous-état porte la phrase ci-dessous. Le clic est refusé par cette phrase, qui nomme la feuille : dans la bulle du service, puis, après « Actualiser », dans la zone « Message de l'écran ». La pièce reste au dossier et dans « PIÈCE À RETIRER ».

```
La pièce fonde la conclusion de la feuille de travail DEM-VALO-OMEGA-OPCI-20251231 : elle ne se retire pas du dossier.
```

Passé ☐ · Échec ☐ · Remarque :

### Passer les écritures de révision

#### 3-24. Saisir une écriture de révision liée à une question

**Besoin :** Le réviseur passe une OD de révision en partie double, rattachée à la question qui la justifie.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Programme choisi ; TRESO-21 au programme. Comptes 623 et 518 au plan OPCI (sql/10_referentiels/75_ref_compte.sql).

1. Ouvrez la page « Révision ». Étape 3, bande des cycles « Trésorerie » : choisir TRESO-21.
2. Ligne 1 des écritures : « Compte » 623, « Libellé » Intérêts courus UAT, « Débit » 1000.
3. Ligne 2 : « Compte » 518, « Libellé » Intérêts courus UAT, « Crédit » 1000.
4. Cliquer « Ajouter les 2 lignes ».

**Vous devez obtenir :** La zone de message affiche la phrase ci-dessous. La liste des écritures de la question porte les 2 lignes au journal ODR, 1 000,00 au débit du 623 et 1 000,00 au crédit du 518. La carte d'équilibre affiche « Équilibre du lot <montant>, équilibré ».

```
Les 2 lignes sont enregistrées au brouillon.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-25. Un compte hors du plan est refusé, et aucune des 2 lignes n'est écrite

**Besoin :** Une OD de révision ne mouvemente qu'un compte du plan OPCI ou du plan de l'entité.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Programme choisi.

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-21.
2. Ligne 1 : « Compte » 999999, « Libellé » Essai, « Débit » 100 ; ligne 2 : « Compte » 518, « Libellé » Essai, « Crédit » 100.
3. Cliquer « Ajouter les 2 lignes ».

**Vous devez obtenir :** Refus ci-dessous, qui nomme la ligne. La liste des écritures de la question ne change pas.

```
Ligne 1 : Le compte 999999 n'est ni au plan OPCI ni au plan de l'entité.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-26. Une ligne qui porte un débit et un crédit est refusée

**Besoin :** Chaque ligne d'OD porte un montant au débit ou au crédit, jamais les 2.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Programme choisi.

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-21.
2. Ligne 1 : « Compte » 623, « Libellé » Essai, « Débit » 100 et « Crédit » 100 ; ligne 2 : « Compte » 518, « Libellé » Essai, « Crédit » 100.
3. Cliquer « Ajouter les 2 lignes ».

**Vous devez obtenir :** Refus ci-dessous ; aucune ligne n'est écrite.

```
Ligne 1 : Une ligne porte un débit OU un crédit, positif.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-27. Valider les écritures d'une question sans brouillon est refusé

**Besoin :** La validation porte sur les lignes de la question choisie, et seulement sur elles.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** TRESO-22 sans ligne d'OD au brouillon.

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-22.
2. Cliquer « Valider les écritures ».

**Vous devez obtenir :** Refus ci-dessous, dans la bulle du service et dans la zone de message ; la phrase est écrite sans accents dans la source.

```
Aucune ligne de brouillon pour cette question : rien a valider. Le perimetre de la validation est la question, non la feuille entiere.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-28. Valider les écritures d'une question : le lot est proposé au visa

**Besoin :** Les OD de la question deviennent un lot proposé au visa du chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test « Saisir une écriture de révision liée à une question » passé.

1. Étape 3, bande des cycles « Trésorerie » : choisir TRESO-21.
2. Cliquer « Valider les écritures ».
3. Cliquer l'étape 5 « Conclure » et lire la liste « En attente de visa ».

**Vous devez obtenir :** La zone de message affiche la phrase ci-dessous. La liste « En attente de visa » porte « Lot <n> · OMEGA-OPCI · TRESO », proposé par le Compte 1 (colonne « Proposé par » du tableau des lots).

```
OD de la question TRESO-21 validées : le lot est proposé au visa.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-29. Un brouillon d'OD libres déséquilibré ne se valide pas, une ligne se retire

**Besoin :** Seul un brouillon équilibré devient un lot ; une ligne saisie à tort se retire du brouillon.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Brouillon d'OD libres d'OMEGA-OPCI au 31/12/2025 vide. Compte 627 au plan OPCI.

1. Cliquer l'étape 4 de la barre, « OD libres ».
2. Ligne 1 : « Compte » 627, « Libellé » Charge UAT, « Débit » 500 ; cliquer « Ajouter la ligne 1 seule ».
3. Lire le pied de la liste « OD libres » et observer « Valider le brouillon ».
4. Choisir la ligne dans la liste « OD libres », cliquer « Retirer la ligne ».

**Vous devez obtenir :** Après l'ajout : « Ligne enregistrée au brouillon. » ; le pied affiche « Équilibre du brouillon libre <montant>, déséquilibré de <montant> » ; « Valider le brouillon » est inactif tant que le brouillon n'est pas équilibré. Après le retrait : phrase ci-dessous ; le brouillon est vide.

```
Ligne retirée du brouillon des OD libres, équilibrées.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-30. Saisir des OD libres dans le classeur et les réimporter

**Besoin :** Le réviseur prépare ses OD libres dans un classeur déposé au site du cabinet et les reprend au brouillon en une fois.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Étape 12 faite. Brouillon d'OD libres vide (test « Un brouillon d'OD libres déséquilibré ne se valide pas, une ligne se retire »). Comptes 627 et 408 au plan OPCI.

1. Étape 4 « OD libres » : cliquer « Exporter le gabarit » ; lire la zone de message.
2. Cliquer l'étape 3 « Questionnaires », puis « Voir le dossier exporté » ; page « Dossier de travail », ouvrir od_libres_OMEGA-OPCI_2025-12-31.xlsx par son lien « Ouvrir le dossier ».
3. Dans l'onglet « OD libres », à partir de la 3e ligne, saisir 2 lignes : Journal ODR, Compte 627, Libellé Charge UAT, Débit 500 ; Journal ODR, Compte 408, Libellé Charge UAT, Crédit 500. Enregistrer et fermer.
4. Revenir à la page « Révision », étape 4 « OD libres », cliquer « Réimporter ».
5. Lire la zone de message, la liste « OD libres » et son pied.

**Vous devez obtenir :** Export : la zone affiche le début de « Classeur de 0 ligne(s) préremplie(s) déposé au site du cabinet : <adresse> », coupée au bord droit. Réimport : la zone affiche le début de la phrase ci-dessous, coupée au bord droit ; la liste « OD libres » porte les 2 lignes, 500,00 au débit du 627 et 500,00 au crédit du 408 ; le pied affiche « Équilibre du brouillon libre 500,00, équilibré ».

```
Classeur relu au site du cabinet. 1 onglet(s) importé(s). OD libres : 2 ligne(s) d'OD au brouillon libres, équilibrées.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-31. Valider le brouillon des OD libres : le lot est proposé au visa

**Besoin :** Les OD libres équilibrées deviennent un lot proposé au visa du chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Brouillon d'OD libres équilibré (test précédent).

1. Étape 4 « OD libres » : cliquer « Valider le brouillon ».
2. Cliquer l'étape 5 « Conclure » et lire la liste « En attente de visa ».

**Vous devez obtenir :** La zone de message de l'étape 4 affiche la phrase ci-dessous, dont la fin peut être coupée au bord droit. La liste « En attente de visa » de l'étape 5 porte « Lot <n> · OMEGA-OPCI · ENTITE », proposé par le Compte 1. Le pied de la liste « OD libres » affiche « Équilibre du brouillon libre 0,00, vide ».

```
Lot <n> proposé : les OD libres attendent le visa du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

### Superviser : visas des lots, des cycles et de la revue

#### 3-32. Le visa d'un lot revient au chef de mission, et un renvoi porte son motif

**Besoin :** Une écriture de révision n'entre en comptabilité qu'après le visa du chef de mission, distinct de son auteur.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Lots des tests « Valider les écritures d'une question : le lot est proposé au visa » et « Valider le brouillon des OD libres : le lot est proposé au visa » proposés par le Compte 1. Compte 2 inscrit CHEF_MISSION (sql/90_vous_inscrire_aux_missions.sql:66-69).

1. Avec le Compte 1 : page « Révision », OMEGA-OPCI et 31/12/2025 choisis, étape 5 « Conclure », liste « En attente de visa » : choisir « Lot <n> · OMEGA-OPCI · TRESO » ; observer « Viser le lot » et « Renvoyer le lot ».
2. Avec le Compte 2 : même page, choisir le même lot ; laisser « Motif, renvoi ou lot périmé » vide ; cliquer « Renvoyer le lot ».
3. Vérifier que le lot de TRESO est toujours choisi dans la liste, le choisir sinon, sans recliquer un lot déjà choisi ; cliquer « Viser le lot ».
4. Choisir « Lot <m> · OMEGA-OPCI · ENTITE », celui des OD libres, cliquer « Viser le lot ».

**Vous devez obtenir :** Compte 1 : les 2 boutons sont inactifs, le Compte 1 ne tenant pas le rôle qui vise un lot (CHEF_MISSION) et étant l'auteur des lots. Compte 2, renvoi sans motif : refus ci-dessous, dans la bulle du service et dans la zone de message ; le lot reste proposé. Chaque visa rend « LOT : vise. » ; le lot passe « visé » et quitte la liste « En attente de visa ».

```
Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-33. Conclure un cycle

**Besoin :** Le réviseur conclut le cycle sur la synthèse de ses feuilles, avant le visa du chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Les 23 questions de TRESO répondues ; feuille FT-TRESO-21-P<p> conclue ; lot de TRESO visé.

1. Étape 5 « Conclure » : dans la bande des cycles, choisir « Trésorerie ».
2. Laisser « Conclusion du cycle » vide, cliquer « Enregistrer la conclusion de TRESO ».
3. Saisir « Trésorerie rapprochée, une observation sur une opération en suspens » dans « Conclusion du cycle », cliquer « Enregistrer la conclusion de TRESO ».
4. Lire la zone de message, la carte d'état du cycle et le tableau « Conclusion du cycle enregistrée ».

**Vous devez obtenir :** 1er clic : le refus nomme le champ vide, « Champs obligatoires à remplir : « Conclusion du cycle ». », dans la bulle du service. 2e clic : phrase ci-dessous, dont la fin peut être coupée au bord droit de la zone ; le tableau porte le texte saisi ; la carte d'état du cycle affiche « Conclusion du cycle : enregistrée par <identifiant>, le <jj/mm/aaaa> · Visa du cycle : aucune décision », <identifiant> étant l'adresse de connexion du Compte 1 avant « @ ».

```
Cycle TRESO conclu, synthèse de 1 feuille(s) régénérée. Le visa du chef de mission peut être demandé.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-34. Le visa d'un cycle attend toutes ses réponses et revient à un autre que son auteur

**Besoin :** Le chef de mission ne vise qu'un cycle complet, conclu par un autre que lui.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Aucune question de CAPITAL répondue ; aucune feuille de CAPITAL au 31/12/2025 (sql/80_demonstration/73_feuille_travail.sql). Compte 1 ASSOCIE et PREPARATEUR, Compte 2 CHEF_MISSION sur OMEGA-OPCI. Le champ « Conclusion du cycle » du Compte 1 garde le texte du test « Conclure un cycle » (fabric/Conduite de mission.Report/definition/pages/ec02000000000000b001/visuals/revCclEnregistrer/visual.json:521, autoClear faux).

1. Avec le Compte 1 : étape 5, choisir « Capital » dans la bande des cycles ; dans « Conclusion du cycle », remplacer le texte laissé par le test « Conclure un cycle » par « Conclusion provisoire » ; cliquer « Enregistrer la conclusion de CAPITAL ».
2. Avec le Compte 1 : lire la carte de blocage du visa du cycle et observer « Viser le cycle ».
3. Avec le Compte 2 : page « Révision », OMEGA-OPCI et 31/12/2025 choisis, étape 5 : vérifier que « Capital » est choisi dans la bande des cycles, sinon le choisir ; lire la carte de blocage et observer « Viser le cycle ».

**Vous devez obtenir :** Conclusion : la zone de message porte « Cycle CAPITAL conclu, synthèse de 0 feuille(s) régénérée. Le visa du chef de mission peut être demandé. », dont la fin peut être coupée au bord droit de la zone. Compte 1 : la carte porte la phrase ci-dessous, puis « le connecté a conclu ce cycle » et « visa réservé au chef de mission », séparés par « ; » ; « Viser le cycle » est inactif. Compte 2 : la carte porte la phrase ci-dessous seule ; « Viser le cycle » est inactif.

```
Visa refusé : 31 question(s) du cycle sont sans réponse, dont CAPITAL-01, CAPITAL-02, CAPITAL-03, CAPITAL-04, CAPITAL-05.
```

**Anomalie connue :** Les boutons de visa sont bien inactifs, mais la carte qui en donne la raison tient sur 1 ligne : la fin de la phrase, qui nomme la séparation des fonctions, ne se lit pas.

Passé ☐ · Échec ☐ · Remarque :

#### 3-35. Renvoyer un cycle à son préparateur avec un motif

**Besoin :** Le chef de mission renvoie une conclusion insuffisante en disant ce qui est à reprendre.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** CAPITAL conclu par le Compte 1 (test « Le visa d'un cycle attend toutes ses réponses et revient à un autre que son auteur »).

1. Avec le Compte 2 : étape 5, choisir « Capital » dans la bande des cycles.
2. Laisser « Motif du renvoi » vide, cliquer « Renvoyer le cycle ».
3. Saisir « Répondre aux questions du cycle avant de conclure » dans « Motif du renvoi », cliquer « Renvoyer le cycle ».
4. Lire la zone de message, la carte d'état du cycle, le tableau de la conclusion et les pastilles des cycles.

**Vous devez obtenir :** 1er clic : refus « Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger. », dans la bulle du service et dans la zone de message. 2e clic : phrase ci-dessous. La carte d'état du cycle commence par « Conclusion du cycle : enregistrée par <identifiant>, le <jj/mm/aaaa> · Visa du cycle : renvoyé par <identifiant> » ; la colonne « Motif du renvoi du cycle » porte « Répondre aux questions du cycle avant de conclure » ; les pastilles portent « CAPITAL renvoyé ».

```
Cycle CAPITAL renvoyé : Répondre aux questions du cycle avant de conclure
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-36. Viser un cycle complet

**Besoin :** Le chef de mission vise un cycle dont les questions sont répondues, les feuilles conclues et les lots visés.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** TRESO conclu par le Compte 1 après la conclusion de sa feuille ; 23 questions répondues ; lot de TRESO visé. Le champ « Motif du renvoi » du Compte 2 garde « Répondre aux questions du cycle avant de conclure », saisi au test « Renvoyer un cycle à son préparateur avec un motif ».

1. Avec le Compte 2 : étape 5, choisir « Trésorerie » dans la bande des cycles.
2. Effacer « Motif du renvoi » : « Viser le cycle » transmet aussi ce champ, et le visa porterait ce motif.
3. Lire la carte de blocage du visa du cycle.
4. Cliquer « Viser le cycle ».
5. Lire la zone de message, les pastilles des cycles du programme, la carte « CYCLES À VALIDER » et la carte d'état du cycle.

**Vous devez obtenir :** La carte de blocage affiche « possible ». Le clic rend la phrase ci-dessous ; les pastilles portent « TRESO visé » ; la carte « CYCLES À VALIDER » passe de « 11 / 11 » à « 10 / 11 ». La carte d'état du cycle se lit « Conclusion du cycle : enregistrée par <identifiant>, le <jj/mm/aaaa> · Visa du cycle : visé par <identifiant>, le <jj/mm/aaaa> », sa fin pouvant être coupée au bord droit.

```
Cycle TRESO visé.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-37. Enregistrer la conclusion générale de la revue

**Besoin :** L'équipe conclut la revue de l'arrêté avant le visa du chef de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Tests précédents du groupe 3 passés ; les 11 cycles au programme.

1. Étape 5, bloc « Conclusion générale de la revue » : laisser le champ vide, cliquer « Enregistrer la conclusion générale » ; lire la bulle du service.
2. Saisir « Revue en cours, cycles restant à viser » dans « Conclusion générale de la revue », cliquer « Enregistrer la conclusion générale » ; lire la zone de message.

**Vous devez obtenir :** 1er clic : la bulle du service porte le refus qui nomme le champ vide, « Champs obligatoires à remplir : « Conclusion générale de la revue ». ». 2e clic : la zone de message porte la phrase ci-dessous ; 2 cycles portent une conclusion, TRESO (test « Conclure un cycle ») et CAPITAL (test « Le visa d'un cycle attend toutes ses réponses et revient à un autre que son auteur », renvoyé depuis), sur les 11 cycles au programme.

```
Revue conclue : 2 cycle(s) conclu(s) sur 11 au programme.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-38. La revue se vise après tous ses cycles

**Besoin :** Le chef de mission ne vise la revue qu'une fois chaque cycle du programme visé.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Revue conclue par le Compte 1 ; TRESO seul cycle visé ; les 11 cycles au programme.

1. Étape 5, bloc « Conclusion générale de la revue » : lire la carte de blocage du visa de la revue.
2. Observer « Viser la revue ».

**Vous devez obtenir :** La carte affiche la phrase ci-dessous, les cycles étant rangés dans l'ordre du référentiel ; « Viser la revue » est inactif.

```
Visa refusé : des cycles du programme ne sont pas visés : CAPITAL, AFFECT, IMMO, PART, VALO, FIN, TIERS, FRAIS, CESSIONS, HB. La revue se vise après ses cycles.
```

Passé ☐ · Échec ☐ · Remarque :

### Préparer les comptes annuels et l'annexe

#### 3-39. Recalculer l'annexe 2 fois de suite

**Besoin :** L'annexe se calcule sur les données de la base ; un calcul sans changement ne crée pas de version.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Arrêté de mission OMEGA-OPCI au 31/12/2025.

1. Page « Révision », étape 6 « Livrables » : choisir « Comptes annuels » dans « 1. Livrables de l’arrêté », cliquer « Voir à l’écran » : la page « Bilan » s'ouvre.
2. Lire le bandeau de calcul de l'annexe.
3. Cliquer « Recalculer » ; lire la zone de message et le bandeau.
4. Sans autre action, cliquer de nouveau « Recalculer » ; lire la zone de message.

**Vous devez obtenir :** 1er clic : phrase de recalcul, terminée par « aucune version créée. », « 1 version créée. » ou « <k> versions créées. » selon le nombre d'arrêtés dont une cellule change ; le bandeau affiche « Annexe : version <v> du <jj/mm/aaaa> à <hh:mm> UTC ; dernier calcul le <jj/mm/aaaa> à <hh:mm> UTC ». 2e clic : phrase ci-dessous ; la version du bandeau ne change pas. L'espace avant « : » et « ; » de la phrase est insécable.

```
Annexe recalculée le <jj/mm/aaaa> à <hh:mm> UTC : <n> cellules, dont <a> à remplir et <e> en attente ; aucune version créée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-40. Lire un article de l'annexe : valeur, cellule à remplir, calcul en attente

**Besoin :** Le réviseur voit, cellule par cellule, ce que la base porte et ce qui reste à remplir dans l'annexe.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Annexe recalculée (test précédent).

1. Dans le menu des comptes annuels, rubrique « ANNEXE », cliquer « Informations générales » : la page « 332-1 · Caractéristiques et activité de l’OPCI » s'ouvre (infobulle de l'entrée).
2. Lire les cellules des tableaux de l'article.
3. Lire la carte d'aide du bloc de saisie et la carte des faits de l'article.

**Vous devez obtenir :** Chaque cellule porte sa valeur, « à remplir » (la base ne porte pas la donnée), « calcul en attente » (elle dépend d'une cellule à remplir) ou rien (sans objet). La carte d'aide affiche le décompte ci-dessous. La carte des faits commence par « Modèle indicatif ; » ou « Modèle imposé ; » et donne le nombre de cellules, dont celles à remplir et en attente.

```
<np> cellules proposées : <nr> à remplir
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-41. Saisir une cellule à remplir de l'annexe, puis retirer la saisie

**Besoin :** Le réviseur complète l'annexe là où la base ne porte pas la donnée, et peut revenir sur sa saisie.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Annexe recalculée ; cellule STRATEGIE, colonne 1, de l'article 332-1 sans saisie. Aucun document produit non périmé à cet arrêté (sql/80_demonstration/51_document_produit.sql:9).

1. Page « 332-1 · Caractéristiques et activité de l’OPCI ».
2. Dans « CELLULE », choisir « STRATEGIE, colonne 1 ».
3. Saisir « Investissement en immobilier de bureaux en France » dans « VALEUR OU MONTANT », laisser « MOTIF » vide, cliquer « Enregistrer la cellule ».
4. Choisir de nouveau « STRATEGIE, colonne 1 », vider « VALEUR OU MONTANT », cliquer « Enregistrer la cellule ».
5. Le champ restant vide, cliquer une 3e fois « Enregistrer la cellule ».

**Vous devez obtenir :** 1er clic : « Cellule 332-1, ligne STRATEGIE, colonne 1 : ajout enregistré. » ; la cellule affiche le texte saisi, sans motif exigé. 2e clic : phrase ci-dessous ; la cellule revient à « à remplir ». 3e clic : « Aucune cellule saisie à retirer : la cellule rend déjà la valeur que la base calcule, ou « à remplir ». ». Aucun de ces messages ne parle de version de l'annexe.

```
Cellule 332-1, ligne STRATEGIE, colonne 1 : retrait enregistré.
```

Passé ☐ · Échec ☐ · Remarque :

#### 3-42. Les comptes annuels et le rapport ne se produisent pas avant le visa de la revue

**Besoin :** Aucun livrable ne sort avant que la revue de l'arrêté soit visée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Revue d'OMEGA-OPCI au 31/12/2025 non visée ; forme du rapport non arrêtée.

1. Page « Révision », étape 6 « Livrables » : dans « 1. Livrables de l’arrêté », choisir « Comptes annuels ».
2. Lire l'état et le message de la ligne ; observer « Produire en Word » et « Produire en Excel ».
3. Choisir le rapport de l'expert-comptable ; lire sa ligne ; observer « Produire le rapport ».
4. Lire la ligne du document d'information périodique.

**Vous devez obtenir :** Comptes annuels : état « à produire », message contenant « revue non visée » ; « Produire en Word » et « Produire en Excel » inactifs. Rapport : état « périmé » (la version 1 du jeu est périmée), message contenant « forme non arrêtée » et « comptes annuels non produits » ; « Produire le rapport » inactif. Document d'information périodique : état « sans objet », ce livrable n'étant dû qu'à un arrêté non annuel.

```
revue non visée
```

Passé ☐ · Échec ☐ · Remarque :

### Préparer le rapport de l'expert-comptable

#### 3-43. La forme du rapport s'arrête par l'associé signataire, sur la forme dérivée des feuilles

**Besoin :** Seul l'associé signataire arrête la forme du rapport, et une attestation suit la plus sévère des conclusions des feuilles de travail.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Valeur liquidative de l'arrêté publiée par le jeu (sql/80_demonstration/59_publication_vl.sql:9). Feuilles conclues avec observation : DEM-VALO-OMEGA-OPCI-20251231 du jeu et FT-TRESO-21-P<p>. OMEGA-OPCI soumise au commissariat aux comptes (sql/80_demonstration/15_ref_entite.sql:8).

1. Avec le Compte 2 : étape 6, bloc « 3. Rapport de l’expert-comptable », choisir « Attestation avec observation(s) » dans « FORME » ; observer « Arrêter la forme ».
2. Avec le Compte 1 : même bloc, choisir « Attestation sans observation » ; observer « Arrêter la forme ».
3. Lire les cartes « PROPOSÉE PAR LA BASE » et « ARRÊTÉE ».

**Vous devez obtenir :** Compte 2 : « Arrêter la forme » inactif, le Compte 2 ne tenant pas le rôle qui arrête la forme (ASSOCIE, nature PUBLICATION). Compte 1 avec « Attestation sans observation » : bouton inactif, la forme dérivée des feuilles étant AVEC_OBSERVATION. « PROPOSÉE PAR LA BASE » affiche « Compte rendu de travaux », l'entité étant soumise au commissariat aux comptes ; « ARRÊTÉE » affiche « non ».

Passé ☐ · Échec ☐ · Remarque :

#### 3-44. Une attestation dans une entité soumise au commissariat aux comptes exige le motif des considérations particulières

**Besoin :** Pour une entité soumise au commissariat aux comptes, le rapport est un compte rendu de travaux ; une attestation n'y est admise que motivée (NP 2300, A10).  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Test précédent passé.

1. Étape 6, bloc « 3. Rapport de l’expert-comptable » : choisir « Attestation avec observation(s) » dans « FORME » ; laisser « CONSIDÉRATIONS PARTICULIÈRES » vide ; cliquer « Arrêter la forme ».
2. Saisir « Attestation demandée par la société de gestion pour le dépositaire » dans « CONSIDÉRATIONS PARTICULIÈRES », cliquer « Arrêter la forme ».
3. Lire la carte « ARRÊTÉE ».

**Vous devez obtenir :** 1er clic : refus ci-dessous. 2e clic : « Forme du rapport arrêtée : Attestation avec observation(s). » ; la carte « ARRÊTÉE » affiche « le <jj/mm/aaaa> par <identifiant> ».

```
Forme refusée : l'entité OMEGA-OPCI est soumise au commissariat aux comptes ; son rapport est un compte rendu de travaux (NP 2300, A10). Une attestation n'y est admise qu'avec le motif des considérations particulières qui la justifient.
```

Passé ☐ · Échec ☐ · Remarque :

### Contrôler les comptes annuels par recalcul, tests manuels

#### 3-45. Recalculer la balance après les OD de révision

**Nature :** Contrôle par recalcul  
**Besoin :** La balance après révision égale la balance avant, augmentée des OD de révision et de valorisation validées.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Lots d'OD du groupe 3 visés par le Compte 2 (test « Le visa d'un lot revient au chef de mission, et un renvoi porte son motif »). Dans le jeu, la balance d'OMEGA-OPCI au 31/12/2025 vient des lots validés 35 (importé), 37 (OD de révision, virement des classes 6 et 7 au 120), 64 et 67 (valorisation) (sql/80_demonstration/92_lot_ecritures.sql:38, :40, :66, :69 ; sql/80_demonstration/99_ecriture.sql).

1. Page « Révision », étape 3 : cliquer « Ouvrir la balance ».
2. Page « Balance de révision » : relever, pour chaque compte affiché, « Balance avant », « OD de révision », « OD de valorisation » et « Balance après ».
3. Calculer, compte par compte, Balance avant + OD de révision + OD de valorisation, et comparer à « Balance après ».
4. Relever les 4 colonnes des comptes 623, 518, 627 et 408.

**Ce que vous comparez ou notez :** Identité vérifiée sur chaque ligne : Balance après = Balance avant + OD de révision + OD de valorisation, chaque colonne étant un solde débit moins crédit des lots validés ; écart attendu 0,00, la vue calculant « Balance après » comme cette somme. Comptes du groupe : 623, Balance avant 306 600,00, OD de révision -305 600,00 (-306 600,00 du lot 37 et 1 000,00 de l'OD de TRESO-21), Balance après 1 000,00 ; 518, 0,00, -1 000,00, -1 000,00 ; 627, 0,00, 500,00, 500,00 ; 408, 0,00, -500,00, -500,00 ; « OD de valorisation » nulle sur les 4. Un lot proposé et non visé n'entre dans aucune colonne.

Passé ☐ · Échec ☐ · Constats :

#### 3-46. Recalculer les rubriques et le total du bilan actif

**Nature :** Contrôle par recalcul  
**Besoin :** Le bilan actif est l'addition exacte de ses lignes de détail, au modèle de l'article 321-2.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI et 31/12/2025 choisis. Lots d'OD du groupe 3 visés. Au 31/12/2025, l'actif d'OMEGA-OPCI porte 213 (37 030 000,00), 271 (2 047 500,00), 254 (42 454 000,00), 275 (10 237 649,24), 266 (74 620 000,00) et 511 (8 835 478,50) (sql/80_demonstration/99_ecriture.sql, lots 35, 64 et 67).

1. Ouvrir la page « Bilan » par le menu des comptes annuels.
2. Relever, colonne « Exercice N », chaque ligne de détail.
3. Additionner les lignes de détail de chaque rubrique (« Actifs à caractère immobilier », « Dépôts et instruments financiers non immobiliers », « Autres actifs ») et comparer au montant de la rubrique.
4. Additionner toutes les lignes de détail et comparer à « Total de l'actif ».
5. Refaire les mêmes calculs sur la colonne « Exercice N-1 ».

**Ce que vous comparez ou notez :** Identités : chaque rubrique = somme de ses lignes de détail ; « Total de l'actif » = somme de toutes les lignes de détail ; écart attendu 0,00 sur N et sur N-1, par construction des totaux. Une ligne de détail sans donnée reste vide, et le total qui en dépend aussi. Au 31/12/2025, « Total de l'actif » vaut 175 224 627,74. La carte des faits du bilan actif affiche « 22 lignes du modèle de l’article 321-2 ; total de l’actif : 175 224 627,74, égal au total du passif ».

Passé ☐ · Échec ☐ · Constats :

#### 3-47. Recalculer les capitaux propres et le total du bilan passif, puis l'équilibre du bilan

**Nature :** Contrôle par recalcul  
**Besoin :** Les capitaux propres et le total du passif sont l'addition exacte de leurs lignes, au modèle de l'article 321-6.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Contrôle du bilan actif fait. Lots d'OD du groupe 3 visés : 1 000,00 au débit du 623 et au crédit du 518, 500,00 au débit du 627 et au crédit du 408.

1. Ouvrir la page « 321-6 · Bilan passif ».
2. Additionner Capital, Report des plus-values nettes réalisées (1), Report des résultats nets antérieurs (1), Résultat de l'exercice (1) et Acomptes versés au cours de l'exercice (1) ; comparer à « Capitaux propres (= actif net) ».
3. Additionner toutes les lignes de détail du passif ; comparer à « Total du passif ».
4. Calculer Total de l'actif (page « Bilan ») moins Total du passif.

**Ce que vous comparez ou notez :** Identités : « Capitaux propres (= actif net) » = somme des 5 lignes de capitaux propres ; « Total du passif » = somme des lignes de détail ; écart attendu 0,00 sur N et N-1 (v_ligne_etat_montant.sql:21-38). Total de l'actif moins Total du passif : écart attendu 0,00 sur N et N-1, et la carte des faits du bilan actif porte « égal au total du passif ». La ligne « Résultat de l'exercice (1) » lit les comptes 120 et 192 et les classes 6 et 7 de tous les lots ; au 31/12/2025 elle vaut 6 804 378,50.

Passé ☐ · Échec ☐ · Constats :

#### 3-48. Recalculer les totaux et les résultats du compte de résultat

**Nature :** Contrôle par recalcul  
**Besoin :** Chaque total et chaque résultat du compte de résultat suit la formule du modèle de l'article 322-2.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI et 31/12/2025 choisis. Lots d'OD du groupe 3 visés.

1. Ouvrir la page « Compte de résultat ».
2. Recalculer Total I à Total X à partir de leurs lignes.
3. Recalculer le résultat net (A) = I - II + III - IV + V - VI - VII, le résultat net après régularisations = A + VIII, le résultat des plus et moins-values (B) = IX - X, B + XI, et le résultat de l'exercice (C) = (A + VIII) + (B + XI).
4. Comparer (C) à « Résultat de l'exercice (1) » de la page « 321-6 · Bilan passif » et à la carte des faits du compte de résultat.

**Ce que vous comparez ou notez :** Écart attendu 0,00 entre chaque total ou résultat recalculé et la ligne affichée, sur N et N-1 (formules de 31_ref_ligne_etat.sql, somme signée). (C) = « Résultat de l'exercice (1) » du passif, écart attendu 0,00 sur N et N-1 ; au 31/12/2025, (C) vaut 6 804 378,50 (I 7 767 226,00, II 702 847,50, VI 169 780,00, VII 90 220,00, les autres nuls). La carte des faits du compte de résultat porte « résultat de l’exercice (C) égal au résultat de l’exercice du passif : 6 804 378,50 ; classes 6 et 7 lues avant leur virement au compte 120 ».

Passé ☐ · Échec ☐ · Constats :

#### 3-49. Rapprocher le tableau 333-3 du bilan et du compte de résultat

**Nature :** Contrôle par recalcul  
**Besoin :** Le tableau d'évolution de l'actif net se rapproche des capitaux propres du bilan et des résultats du compte de résultat.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Contrôles du bilan et du compte de résultat faits.

1. Cliquer « Recalculer » sur une page des comptes annuels.
2. Ouvrir la page « 333-3 · Évolution de l’actif net (= capitaux propres) » ; relever la colonne « Exercice N ».
3. Comparer « Actif net (= capitaux propres) en fin d'exercice » aux capitaux propres N de la page « 321-6 · Bilan passif ».
4. Comparer « Actif net (= capitaux propres) en début d'exercice » aux capitaux propres N-1 de la même page.
5. Comparer « Résultat net avant comptes de régularisations » au résultat net (A) N, et « Plus et moins-values réalisées avant comptes de régularisations » au résultat (B) N du compte de résultat.
6. Vérifier que « Variation de la différence d'estimation des actifs à caractère immobilier » égale la ligne « Différence d'estimation exercice N : » qui la suit, moins la ligne « Différence d'estimation exercice N-1 : ».
7. Appliquer à chaque montant affiché, avec son signe, la formule : début + souscriptions - rachats - frais d'acquisition de l'exercice - frais d'acquisition rapportés au résultat + différences de change + variations des différences d'estimation - distribution de l'exercice précédent + résultat net + plus et moins-values - acomptes sur résultat net - acomptes sur cessions + écart de fusion + autres éléments ; comparer à l'actif net de fin.

**Ce que vous comparez ou notez :** Écart attendu 0,00 à chaque comparaison des étapes 3 à 6 : la base lit ces cellules sur le bilan et le compte de résultat au recalcul. Étape 7 : écart attendu 0,00 ; un écart non nul est un obstacle de la base, et la ligne « Comptes annuels » de l'étape 6 porte alors « tableau 333-3 non rapproché du bilan ». Si une ligne de la formule est « à remplir », la base ne calcule pas ce contrôle : le testeur note les lignes « à remplir » et ne conclut pas sur l'étape 7.

```
tableau 333-3 non rapproché du bilan
```

Passé ☐ · Échec ☐ · Constats :

### Conduire la révision d'un arrêté, tests manuels

#### 3-50. Réviser l'arrêté et conduire des cycles jusqu'à leur visa

**Nature :** Parcours métier  
**Besoin :** L'équipe conduit la révision de l'arrêté comme en mission : réponses, feuilles, pièces, écritures, conclusions et visas.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Tests scénarisés du groupe 3 joués. Compte 1 prépare, Compte 2 vise. Le lot 65 du jeu (OMEGA-SCI-1, VALO, proposé et périmé) reste en l'état : c'est un lot de valorisation, joué au groupe 4 (sql/80_demonstration/92_lot_ecritures.sql:67). Des champs du Compte 1 gardent la saisie de tests antérieurs, à effacer ou remplacer avant chaque clic : les champs d'écriture de l'étape 3 (test « Une ligne qui porte un débit et un crédit est refusée » : 623, Essai, 100 au débit et 100 au crédit ; 518, Essai, 100 au crédit) ; la ligne 1 des OD libres de l'étape 4 (test « Un brouillon d'OD libres déséquilibré ne se valide pas, une ligne se retire » : 627, Charge UAT, 500 au débit), que « Ajouter la ligne 1 seule » et « Ajouter les 2 lignes » de l'étape 4 enverraient ; « Motif si NA » (« Motif saisi pour la recette », test « Déclarer une question non applicable exige un motif »), que « NA » enverrait comme motif ; « Forme de la conclusion » (AVEC_OBSERVATION) et « Conclusion » (test « Conclure une feuille de travail avec observation »), que « Conclure » enverrait pour une autre feuille ; « Conclusion du cycle » (« Conclusion provisoire ») ; sur la page « Pièce justificative », « QUESTION » garde TRESO-21, « Nom du fichier déposé, sous-dossier facultatif » garde uat_rappro_2025-12-31.pdf et « Nature » garde Relevé bancaire (test « Rattacher une pièce à la question de révision qu'elle justifie »).

1. Objectif : conduire jusqu'au visa du chef de mission au moins 2 cycles parmi « Capital », « Cessions », « Placements », « Frais de gestion », « Hors bilan » et « Tiers », sur OMEGA-OPCI au 31/12/2025, dans l'ordre choisi par l'équipe.
2. Périmètre : page « Révision », étapes 2 à 5 ; pages « Pièce justificative », « Balance de révision » et « Dossier de travail » ; classeurs du dossier de travail au site du cabinet.
3. Le Compte 1 répond, documente, conclut et propose les écritures ; le Compte 2 vise les lots et les cycles, ou les renvoie avec un motif. Après « Oui », « Non » ou « NA », cliquer « Actualiser » dans la barre d'actions du service Power BI : ces boutons n'actualisent pas la page.
4. Noter, pour chaque cycle, le temps passé, chaque refus lu (texte recopié) et ce qui a manqué à l'écran ou dans les classeurs.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté, ce qui lui a manqué et le temps passé par cycle. Résultat d'ensemble à atteindre : chaque cycle conduit rend « Cycle <c> visé. » et la carte « CYCLES À VALIDER » diminue d'autant. Sur ce jeu, AFFECT, PART et VALO ne se visent pas : AFF-OMEGA-OPCI-20251231 et VAL275-2025-12-31 ne se concluent pas, faute des pièces permanentes « Clef d'affectation des frais de gestion entre les catégories de revenus » et « Statuts des entités détenues et pièce établissant la quote-part de détention », qu'aucun bouton ne rattache à une pièce attendue ; les feuilles des filiales du périmètre (AFF-OMEGA-SCI-<n>-20251231, MIR-OMEGA-SCI-12-2025-12-31, DEM-PEREMPTION-SCI1-20251231) n'entrent pas au classeur du dossier du véhicule et n'ont pas de question à l'écran ; le lot 65 de VALO reste proposé. IMMO reste bloqué par la feuille FT-IMMO-01-P<p> du test « Une feuille ne se conclut pas tant que manquent les pièces obligatoires de son cycle », et une feuille ouverte dans « Hors bilan » est refusée de même, la pièce permanente « Actes de sûreté réelle, hypothèques, nantissements et cessions Dailly » n'étant rattachée à aucun document ; le refus cite chaque pièce manquante par ses 60 premiers caractères (« Actes de sûreté réelle, hypothèques, nantissements et cessio »). Un rattachement de pièce à une question de révision, choisie dans « QUESTION » de la page « Pièce justificative », est refusé (test « Rattacher une pièce à la question de révision qu'elle justifie ») : « La question <référence> n'appartient à aucun questionnaire de OMEGA-OPCI. », la fonction n'admettant que les questions d'acceptation et de maintien. La revue ne se vise donc pas sur cet arrêté : la carte de blocage du visa de chaque cycle bloqué nomme les feuilles non conclues ou les lots en attente.

```
Cycle <c> visé.
```

Passé ☐ · Échec ☐ · Constats :

### Préparer les comptes annuels et l'annexe, tests manuels

#### 3-51. Compléter l'annexe et relire les comptes annuels de l'arrêté

**Nature :** Parcours métier  
**Besoin :** Le réviseur complète l'annexe et relit bilan, compte de résultat et annexe avant leur production.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Annexe recalculée ; OMEGA-OPCI et 31/12/2025 choisis.

1. Objectif : ramener à zéro, article par article, les cellules « à remplir » que le dossier permet de renseigner.
2. Périmètre : pages « Bilan », « 321-6 · Bilan passif », « Compte de résultat », « Annexe » et articles 332-1 à 336-3 ; bouton « Recalculer » ; bloc de saisie « CELLULE », « VALEUR OU MONTANT », « MOTIF ».
3. Pour chaque article, lire la carte des faits et la carte d'aide, saisir les cellules documentées, avec un motif quand la saisie remplace une valeur de la base.
4. Noter les cellules non renseignables et leur cause.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté (refus recopiés), ce qui lui a manqué et le temps passé. Résultat d'ensemble à atteindre : pour chaque article traité, la carte d'aide affiche « <np> cellules proposées : 0 à remplir » en fin de saisie ; chaque saisie rend « Cellule <article>, ligne <ligne>, colonne <col> : ajout enregistré. » ou « Cellule <article>, ligne <ligne>, colonne <col> : modification enregistrée. ». La production en Word reste fermée tant que la revue n'est pas visée ; une cellule à remplir ne bloque pas la production, seul l'écart du tableau 333-3 le fait.

```
Cellule <article>, ligne <ligne>, colonne <col> : ajout enregistré.
```

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 4. La valorisation de l'arrêté

### Choisir le véhicule et l'arrêté à valoriser

#### 4-01. Seuls les arrêtés ouverts du véhicule se choisissent

**Besoin :** Ne valoriser qu'un arrêté ouvert, et savoir où l'ouvrir quand le véhicule n'en a aucun.  
**Profil :** Compte 1 · **Criticité d'un échec :** Mineure  
**Avant de commencer :** Étape 13 passée. Compte 1 inscrit par sql/90_vous_inscrire_aux_missions.sql, qui lui donne un mandat sur OPCI-1 et sur OMEGA-OPCI. Le jeu de démonstration n'ouvre aucun arrêté pour OPCI-1 ; il ouvre pour OMEGA-OPCI les arrêtés du 31/12/2022, du 31/12/2023, du 31/12/2024, du 31/12/2025 et du 30/06/2026 ; le 31/12/2026 est planifié, non ouvert.

1. Ouvrez la page « Valorisation » du rapport « Conduite de mission ».
2. Dans le sélecteur « VÉHICULE », choisissez « OPCI-1 · OPCI SIGMA ».
3. Lisez les 2 lignes de texte affichées en tête de page, à gauche du sélecteur « VÉHICULE ».
4. Choisissez « OMEGA-OPCI · OPCI OMEGA », puis ouvrez la liste du sélecteur « ARRÊTÉ ».

**Vous devez obtenir :** Pour OPCI-1, la page affiche « Aucun arrêté ouvert pour ce véhicule », puis « Un arrêté s’ouvre à l’écran Client et Acceptation ». Pour OMEGA-OPCI, le sélecteur « ARRÊTÉ » propose, écrits jj/mm/aaaa, les 5 arrêtés ouverts : 31/12/2022, 31/12/2023, 31/12/2024, 31/12/2025 et 30/06/2026. Le 31/12/2026, planifié et non ouvert, n'y figure pas.

```
Aucun arrêté ouvert pour ce véhicule | Un arrêté s’ouvre à l’écran Client et Acceptation
```

Passé ☐ · Échec ☐ · Remarque :

### Arrêter la valeur des immeubles

#### 4-02. Enregistrer une expertise qui remplace la précédente

**Besoin :** Inscrire la valeur d'expertise d'un immeuble à l'arrêté, rattachée à son rapport, en gardant la trace de la valeur remplacée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Étape 13 passée ; Compte 1 (ASSOCIE et PREPARATEUR) et Compte 2 (CHEF_MISSION) inscrits par sql/90_vous_inscrire_aux_missions.sql. OMEGA-OPCI, arrêté du 31/12/2025 ouvert. Dossier du 31/12/2025 non verrouillé : la revue de cet arrêté n'est pas visée, sinon chaque bouton de la page répond « Le dossier de cet arrêté est visé et verrouillé. ». IMM-202 porte au 31/12/2025 une expertise de 9 310 000,00, version 1, rattachée au rapport « Rapport_evaluation_IMM-202_2025-12-31.pdf ». Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Page « Valorisation » : « VÉHICULE » = « OMEGA-OPCI · OPCI OMEGA », « ARRÊTÉ » = « 31/12/2025 ».
2. Dans la barre des étapes, cliquez « Arrêter les valeurs », puis la bande « Immeubles ».
3. Dans la grille « Immeubles », cliquez la ligne de l'actif IMM-202.
4. Lisez la grille « Expertises de l’actif, par date de valeur ».
5. Dans « RAPPORT AU COFFRE », cochez « Rapport_evaluation_IMM-202_2025-12-31.pdf ».
6. Dans « VALEUR ACTUELLE HORS DROITS », saisissez 9 400 000,00.
7. Cliquez « Enregistrer l’expertise » et lisez la zone « MESSAGE ».
8. Cochez de nouveau « Rapport_evaluation_IMM-202_2025-12-31.pdf » dans « RAPPORT AU COFFRE », saisissez de nouveau 9 400 000,00 dans « VALEUR ACTUELLE HORS DROITS », puis cliquez « Enregistrer l’expertise ».

**Vous devez obtenir :** Avant la saisie, la grille « Expertises de l’actif, par date de valeur » porte 9 310 000,00 au 31/12/2025. Au 1er clic, la zone « MESSAGE » affiche « Expertise de IMM-202 au 31/12/2025 remplacée : <ancienne valeur> devient <valeur saisie> (version 2). », où <ancienne valeur> est 9 310 000,00 et <valeur saisie> 9 400 000,00 ; la grille porte alors 9 400 000,00 au 31/12/2025. Le rapport étant déjà rattaché à IMM-202, le message ne porte pas la phrase « Le rapport est rattaché à l'actif. ». Au 2e clic, la zone « MESSAGE » affiche « Expertise de IMM-202 au 31/12/2025 inchangée : même valeur et même rapport. ».

```
Expertise de IMM-202 au 31/12/2025 remplacée : <ancienne valeur> devient <valeur saisie> (version 2). | Expertise de IMM-202 au 31/12/2025 inchangée : même valeur et même rapport.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-03. Une expertise sans rapport ou de montant négatif est refusée

**Besoin :** Aucune valeur d'expertise n'entre en base sans le rapport qui la fonde, ni avec un montant négatif.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Mêmes conditions que le test « Enregistrer une expertise qui remplace la précédente ». IMM-203 porte au 31/12/2025 une expertise de 16 537 500,00 rattachée au rapport « Rapport_evaluation_IMM-203_2025-12-31.pdf ». Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » : cliquez la ligne IMM-203.
2. Ne cochez aucun rapport dans « RAPPORT AU COFFRE » ; dans « VALEUR ACTUELLE HORS DROITS », saisissez 16 600 000,00 ; cliquez « Enregistrer l’expertise ».
3. Cochez « Rapport_evaluation_IMM-203_2025-12-31.pdf » ; dans « VALEUR ACTUELLE HORS DROITS », vidée par le 1er clic, saisissez -1 ; cliquez « Enregistrer l’expertise ».
4. Lisez la grille « Expertises de l’actif, par date de valeur ».

**Vous devez obtenir :** Au 1er clic, la zone « MESSAGE » affiche « Choisissez le rapport d'expertise dans la liste « Rapport au coffre ». ». Au 2e clic : « La valeur d'expertise ne peut pas être négative. ». Aucune expertise n'est écrite : la grille porte toujours 16 537 500,00 au 31/12/2025 pour IMM-203.

```
Choisissez le rapport d'expertise dans la liste « Rapport au coffre ». | La valeur d'expertise ne peut pas être négative.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-04. Reprendre une valeur retenue renvoyée, avec le motif de l'écart

**Besoin :** Reprendre une valeur retenue que le chef de mission a renvoyée ; une valeur qui s'écarte de l'expertise porte son motif.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Mêmes conditions que le test « Enregistrer une expertise qui remplace la précédente ». Le jeu de démonstration porte pour IMM-201 au 31/12/2025 une valeur retenue de 13 000 000,00, source Modèle financier, renvoyée par « installation (vise_par) » le 06/09/2026, et une expertise de 13 230 000,00. Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » : cliquez la ligne IMM-201.
2. Lisez la colonne « État » de la grille « Immeubles » et l'état de la fiche « Valeur retenue proposée ».
3. Dans « SOURCE », cochez « Modèle financier » ; dans « VALEUR RETENUE », saisissez 13 000 000,00 ; laissez « MOTIF DE L’ÉCART » vide ; cliquez « Proposer la valeur retenue ».
4. Cochez de nouveau « Modèle financier » dans « SOURCE », saisissez de nouveau 13 000 000,00 dans « VALEUR RETENUE », puis, dans « MOTIF DE L’ÉCART », saisissez « Modèle documenté : hypothèses et taux joints. » ; cliquez « Proposer la valeur retenue ».

**Vous devez obtenir :** Avant la saisie, la colonne « État » d'IMM-201 porte « valeur renvoyée » et la fiche « renvoyée par installation (vise_par) le 06/09/2026 ». Au 1er clic, la zone « MESSAGE » affiche « Le motif de l'écart est obligatoire : la valeur retenue ne reprend pas l'expertise. ». Au 2e clic : « Valeur retenue de IMM-201 reprise : <montant>, source Modèle financier. Elle attend le visa du chef de mission. », où <montant> est 13 000 000,00 ; la fiche porte « proposée, en attente du visa » et la colonne « État » « valeur à viser ».

```
Le motif de l'écart est obligatoire : la valeur retenue ne reprend pas l'expertise. | Valeur retenue de IMM-201 reprise : <montant>, source Modèle financier. Elle attend le visa du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-05. Le visa d'une valeur retenue est réservé au chef de mission

**Besoin :** Séparation des fonctions : la valeur retenue se vise par le chef de mission, jamais par l'associé ou le préparateur.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué juste après « Reprendre une valeur retenue renvoyée, avec le motif de l'écart » : la valeur retenue d'IMM-201 au 31/12/2025 est proposée et attend le visa. Compte 1 ne tient pas le rôle CHEF_MISSION.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » : cliquez la ligne IMM-201.
2. Lisez la carte d'état placée à côté de « Viser la valeur ».
3. Cliquez « Viser la valeur ».

**Vous devez obtenir :** Le bouton « Viser la valeur » est gris (#D9DFE6) et la carte porte « visa réservé au chef de mission ». Le clic n'exécute aucune action : la fiche porte toujours « proposée, en attente du visa » et la grille « Visas de la valorisation, à l’arrêté » ne porte aucun visa nouveau.

```
visa réservé au chef de mission
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-06. Le chef de mission vise la valeur retenue, et un renvoi exige un motif

**Besoin :** Le chef de mission vise ou renvoie la valeur retenue ; un renvoi dit au préparateur ce qu'il doit corriger ; la valeur visée remplace l'expertise.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Le visa d'une valeur retenue est réservé au chef de mission » : la valeur retenue d'IMM-201 au 31/12/2025 est proposée par Compte 1. Compte 2 tient le rôle CHEF_MISSION sur OMEGA-OPCI.

1. Compte 2 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » ; cliquez la ligne IMM-201 et lisez la carte d'état de « Viser la valeur ».
2. Laissez « MOTIF DU RENVOI » vide ; cliquez « Renvoyer la valeur ».
3. Cliquez « Viser la valeur ».
4. Lisez la fiche « Valeur retenue proposée » et la ligne IMM-201 de la grille « Immeubles ».

**Vous devez obtenir :** Avant le clic, le bouton « Viser la valeur » est bleu (#0F5C8C) et la carte porte « conditions réunies ». Le renvoi sans motif est refusé : « Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger. », et la valeur reste à viser. Le visa affiche « Valeur retenue de IMM-201 visée. » ; la fiche porte « visée par <connexion du Compte 2> le <date du jour> » ; dans la grille « Immeubles », IMM-201 passe à l'état « calculable » et sa « Valeur actuelle » vaut 13 000 000,00, la valeur retenue visée remplaçant l'expertise de 13 230 000,00.

```
Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger. | Valeur retenue de IMM-201 visée.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-07. Nul ne vise la valeur retenue qu'il a proposée

**Besoin :** Séparation des fonctions portée par la base : le chef de mission ne vise pas une valeur qu'il a proposée lui-même.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Le chef de mission vise la valeur retenue, et un renvoi exige un motif ». IMM-203 n'a pas de valeur retenue au 31/12/2025 et porte une expertise de 16 537 500,00.

1. Compte 2 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » ; cliquez la ligne IMM-203.
2. Dans « SOURCE », cochez « Expertise » ; dans « VALEUR RETENUE », saisissez 16 537 500,00 ; cliquez « Proposer la valeur retenue ».
3. Compte 2 : cliquez « Viser la valeur ».
4. Compte 1 : même page, même ligne, mêmes saisies ; cliquez « Proposer la valeur retenue ».
5. Compte 2 : cliquez « Viser la valeur ».

**Vous devez obtenir :** Étape 2 : « Valeur retenue de IMM-203 proposée : <montant>, source Expertise. Elle attend le visa du chef de mission. ». Étape 3 : le bouton est bleu, la base refuse : « Visa refusé : le décideur est celui qui a proposé l'objet. Nul ne vise son propre travail. » ; IMM-203 reste « valeur à viser ». Étape 4 : « Valeur retenue de IMM-203 reprise : <montant>, source Expertise. Elle attend le visa du chef de mission. ». Étape 5 : « Valeur retenue de IMM-203 visée. ». <montant> vaut 16 537 500,00.

```
Valeur retenue de IMM-203 proposée : <montant>, source Expertise. Elle attend le visa du chef de mission. | Visa refusé : le décideur est celui qui a proposé l'objet. Nul ne vise son propre travail. | Valeur retenue de IMM-203 reprise : <montant>, source Expertise. Elle attend le visa du chef de mission. | Valeur retenue de IMM-203 visée.
```

Passé ☐ · Échec ☐ · Remarque :

### Justifier les autres actifs

#### 4-08. Réviser une avance en compte courant, à la baisse seulement

**Besoin :** Ramener une avance à une filiale à sa valeur actuelle, motif à l'appui, sans jamais la porter au-dessus de son nominal.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Mêmes conditions que le test « Enregistrer une expertise qui remplace la précédente ». L'avance CCA-01 d'OMEGA-OPCI à OMEGA-SCI-1 a un nominal de 425 000,00. Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Comptes courants » : cliquez la ligne CCA-01.
2. Dans « MONTANT RÉVISÉ », saisissez 500 000,00 ; dans « MOTIF DE LA RÉVISION », saisissez « Situation nette de la filiale dégradée. » ; cliquez « Enregistrer la révision ».
3. Saisissez de nouveau, dans « MONTANT RÉVISÉ », 400 000,00 et, dans « MOTIF DE LA RÉVISION », « Situation nette de la filiale dégradée. » ; cliquez « Enregistrer la révision ».
4. Lisez la grille « Révisions de l’avance ».

**Vous devez obtenir :** Au 1er clic : « Le montant révisé est compris entre 0 et le nominal de l'avance, <nominal> : la révision se fait à la baisse. », <nominal> valant 425 000,00 ; rien n'est écrit. Au 2e clic : « Révision de l'avance CCA-01 à OMEGA-SCI-1 enregistrée : nominal <nominal>, montant révisé <montant>. », <montant> valant 400 000,00 ; la grille « Révisions de l’avance » porte une ligne de montant révisé 400 000,00 avec le motif saisi, l'auteur et la date.

```
Le montant révisé est compris entre 0 et le nominal de l'avance, <nominal> : la révision se fait à la baisse. | Révision de l'avance CCA-01 à OMEGA-SCI-1 enregistrée : nominal <nominal>, montant révisé <montant>.
```

Passé ☐ · Échec ☐ · Remarque :

### Échanger les valeurs avec un classeur

#### 4-09. Exporter le classeur des valeurs, le modifier, le réimporter

**Besoin :** Travailler les valeurs dans Excel et les réintégrer en base sous les mêmes contrôles que la saisie à l'écran.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Étape 12 faite : dépôt des classeurs installé (paramètres DEPOT_CLASSEUR_URL et SITE_CABINET) et raccourci « fec » du coffre vers le site du cabinet. Joué après les tests d'expertise et de valeur retenue du 31/12/2025.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles » : cliquez « Exporter le classeur ».
2. Cliquez « Ouvrir le classeur ».
3. Dans l'onglet « Valeurs », à la ligne de l'actif IMM-202, remplacez la « Valeur d'expertise » par 9 450 000 ; ne touchez à aucune autre cellule ; enregistrez le classeur.
4. De nouveau sur la page, cliquez « Réimporter le classeur ».
5. Cliquez la ligne IMM-202 et lisez la grille « Expertises de l’actif, par date de valeur ».

**Vous devez obtenir :** L'export affiche « Classeur des valeurs, <n> actif(s), déposé au site du cabinet : <adresse> », <n> étant le nombre de lignes d'actifs du classeur. « Ouvrir le classeur » ouvre valeurs_OMEGA-OPCI_2025-12-31.xlsx sous « Dossiers de travail/OMEGA-OPCI/2025-12-31/ » : onglet « Valeurs », ligne 1 les libellés (Entité, Actif, Nature, Prix de revient, Valeur d'expertise, Rapport, Valeur retenue en place, État de la valeur, Valeur retenue, Source, Motif de l'écart, Pièce, État de l'actif), ligne 2 les clés, les actifs à partir de la ligne 3. Le réimport affiche « Classeur relu au site du cabinet. Classeur réimporté : 0 expertise(s) insérée(s), 1 remplacée(s), <m> inchangée(s) ; 0 valeur(s) retenue(s) proposée(s) ; 0 ligne(s) refusée(s). », <m> valant <n> moins 1 : chaque immeuble du classeur porte une expertise au 31/12/2025 avec son rapport, et seule celle d'IMM-202 change. La grille porte 9 450 000,00 au 31/12/2025 pour IMM-202.

```
Classeur des valeurs, <n> actif(s), déposé au site du cabinet : <adresse> | Classeur relu au site du cabinet. Classeur réimporté : 0 expertise(s) insérée(s), 1 remplacée(s), <m> inchangée(s) ; 0 valeur(s) retenue(s) proposée(s) ; 0 ligne(s) refusée(s).
```

Passé ☐ · Échec ☐ · Remarque :

### Contrôler la balance et proposer la synthèse

#### 4-10. Celui qui propose la synthèse ne la vise pas

**Besoin :** Séparation des fonctions : la synthèse de l'arrêté, qui atteste que l'actif net boucle, se vise par un autre que celui qui l'a proposée.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué avant la génération du lot du 31/12/2025. Sur la page « Valorisation », OMEGA-OPCI, 31/12/2025, bande « Rationalisation et synthèse », la carte d'état de « Proposer la synthèse » porte « conditions réunies ». La synthèse proposée ici reste en attente jusqu'au visa du lot, dans le test « Générer de nouveau le lot et le faire viser par le chef de mission », qui la périme.

1. Compte 2 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Contrôler la balance et le groupe », bande « Rationalisation et synthèse ».
2. Cliquez « Proposer la synthèse ».
3. Cliquez « Viser la synthèse ».
4. Lisez la carte d'état de « Proposer la synthèse ».

**Vous devez obtenir :** La proposition affiche « Synthèse de l'arrêté du 31/12/2025 proposée (n° <id>) : elle attend le visa du chef de mission. ». Le visa est refusé par la base : la zone « MESSAGE » affiche « Action interrompue par une erreur d'exécution. Le détail technique est consigné au journal des refus ; relisez l'écran avant de recommencer. ». La synthèse n'est pas visée : la carte de « Proposer la synthèse » porte « synthèse proposée le <date du jour>, en attente du visa » et l'étape « Contrôler la balance et le groupe » reste grise.

```
Synthèse de l'arrêté du 31/12/2025 proposée (n° <id>) : elle attend le visa du chef de mission. | Action interrompue par une erreur d'exécution. Le détail technique est consigné au journal des refus ; relisez l'écran avant de recommencer.
```

Passé ☐ · Échec ☐ · Remarque :

### Générer, viser et annuler le lot de valorisation

#### 4-11. Générer le lot de valorisation ; son auteur ne le vise pas

**Besoin :** Écrire les différences d'estimation de l'arrêté dans un lot proposé, que seul un autre que son auteur peut viser.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après les tests d'expertise et de valeur retenue du 31/12/2025 (IMM-201 et IMM-203 visées, IMM-202 réévaluée). Sur la page « Valorisation », étape « Générer les écritures », la carte d'état de « Générer le lot » porte « conditions réunies ».

1. Compte 2 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Générer les écritures ».
2. Cliquez « Générer le lot » et lisez la zone « MESSAGE ».
3. Lisez la grille « Lots de valorisation de l’arrêté » et la carte d'état de « Générer le lot ».
4. Cliquez « Ouvrir le visa des lots » : l'étape 5 « Conclure » de la page « Révision » s'ouvre. Dans la liste « En attente de visa », choisissez « Lot <n> · OMEGA-OPCI · VALO », <n> étant le numéro rendu par le message.
5. Cliquez « Viser le lot ».

**Vous devez obtenir :** La zone « MESSAGE » affiche « Lot <n> des différences d'estimation proposé sur la feuille VALO-2025-12-31-OMEGA-OPCI : <l> ligne(s) sur <m> actif(s), <montant> au débit et autant au crédit, règles <version>. Il attend le visa du chef de mission. », suivi, quand des titres de filiales sont valorisés à l'actif net réévalué, de « Les titres de filiales valorisés à l'actif net réévalué (<codes>) passent par la reprise du compte 275. ». La grille porte le lot <n>, entité OMEGA-OPCI, état « proposé ». « Générer le lot » passe gris et sa carte porte « lot <n> proposé, non périmé ». Sur la page « Révision », « Viser le lot » est gris (#D9DFE6) pour Compte 2, auteur du lot : le clic n'exécute aucune action et le lot reste « proposé ».

```
Lot <n> des différences d'estimation proposé sur la feuille VALO-2025-12-31-OMEGA-OPCI : <l> ligne(s) sur <m> actif(s), <montant> au débit et autant au crédit, règles <version>. Il attend le visa du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-12. Annuler un lot proposé, motif obligatoire

**Besoin :** Écarter un lot proposé qui ne doit pas être visé, en gardant ses écritures et le motif de l'annulation.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après « Générer le lot de valorisation ; son auteur ne le vise pas » : le lot <n> du 31/12/2025, généré par Compte 2, est proposé.

1. Compte 1 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Générer les écritures ».
2. Dans la grille « Lots de valorisation de l’arrêté », cliquez la ligne du lot <n> ; lisez la carte d'état de « Annuler le lot ».
3. Laissez « MOTIF DE L’ANNULATION » vide ; cliquez « Annuler le lot ».
4. Saisissez « Lot généré pour l'essai de séparation des fonctions. » ; cliquez « Annuler le lot ».

**Vous devez obtenir :** La carte porte « conditions réunies ». Au 1er clic : « Annulation refusée : le motif de l'annulation est obligatoire. ». Au 2e clic : « Lot <n> annulé : il passe au statut rejeté et garde ses écritures. » ; la grille porte pour ce lot l'état « annulé le <date du jour> » ; la carte de « Générer le lot » porte de nouveau « conditions réunies ».

```
Annulation refusée : le motif de l'annulation est obligatoire. | Lot <n> annulé : il passe au statut rejeté et garde ses écritures.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-13. Générer de nouveau le lot et le faire viser par le chef de mission

**Besoin :** Le lot de valorisation se vise par le chef de mission, qui n'en est pas l'auteur ; son visa périme la synthèse proposée avant lui.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Annuler un lot proposé, motif obligatoire ». La synthèse proposée par Compte 2 dans « Celui qui propose la synthèse ne la vise pas » attend toujours son visa.

1. Compte 1 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Générer les écritures » ; cliquez « Générer le lot ».
2. Compte 2 : même page ; cliquez « Ouvrir le visa des lots » ; dans la liste « En attente de visa » de l'étape 5 « Conclure » de la page « Révision », choisissez « Lot <n2> · OMEGA-OPCI · VALO », <n2> étant le numéro rendu par le message de génération ; cliquez « Viser le lot ».
3. Compte 2 : sur la page « Valorisation », lisez la grille « Lots de valorisation de l’arrêté », puis, bande « Rationalisation et synthèse », la carte d'état de « Proposer la synthèse ».

**Vous devez obtenir :** La génération affiche « Lot <n2> des différences d'estimation proposé sur la feuille VALO-2025-12-31-OMEGA-OPCI : <l> ligne(s) sur <m> actif(s), <montant> au débit et autant au crédit, règles <version>. Il attend le visa du chef de mission. », suivi, quand des titres de filiales sont valorisés à l'actif net réévalué, de « Les titres de filiales valorisés à l'actif net réévalué (<codes>) passent par la reprise du compte 275. ». Pour Compte 2, « Viser le lot » est bleu (#0F5C8C) ; le visa affiche « LOT : vise. ». La grille porte le lot <n2> à l'état « visé », visé par Compte 2. La synthèse en attente est périmée par ce visa : la carte de « Proposer la synthèse » ne porte plus « synthèse proposée le <date>, en attente du visa ».

```
Lot <n2> des différences d'estimation proposé sur la feuille VALO-2025-12-31-OMEGA-OPCI : <l> ligne(s) sur <m> actif(s), <montant> au débit et autant au crédit, règles <version>. Il attend le visa du chef de mission. | LOT : vise.
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-14. Créer une dérogation sur une feuille de valorisation

**Besoin :** Déroger, avec un motif écrit, à une règle interne sur une feuille de valorisation, une seule dérogation en cours par feuille.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Mêmes conditions que le test « Enregistrer une expertise qui remplace la précédente ». Le jeu de démonstration porte la dérogation n° 1, non levée, sur la feuille DEM-VALO-OMEGA-OPCI-20251231 ; la feuille VALO-20251231 n'en porte aucune. Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Compte 1 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Générer les écritures ».
2. Dans « FEUILLE », cochez « DEM-VALO-OMEGA-OPCI-20251231 » ; dans « MOTIF DE LA DÉROGATION », saisissez « Rapport d'évaluateur reçu après l'arrêté. » ; cliquez « Créer la dérogation ».
3. Dans « FEUILLE », cochez « VALO-20251231 » ; dans « MOTIF DE LA DÉROGATION », vidé par le 1er clic, saisissez de nouveau « Rapport d'évaluateur reçu après l'arrêté. » ; cliquez « Créer la dérogation ».
4. Lisez le bloc « Dérogations de l’arrêté ».

**Vous devez obtenir :** Au 1er clic : « Une dérogation est déjà en cours sur la feuille DEM-VALO-OMEGA-OPCI-20251231 (n° 1). ». Au 2e clic : « Dérogation n° <id> créée sur la feuille VALO-20251231 : elle attend le visa du chef de mission. » ; le bloc « Dérogations de l’arrêté » porte la feuille VALO-20251231 avec le motif saisi et l'état « à viser ».

```
Une dérogation est déjà en cours sur la feuille DEM-VALO-OMEGA-OPCI-20251231 (n° 1). | Dérogation n° <id> créée sur la feuille VALO-20251231 : elle attend le visa du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

### Contrôler la balance et proposer la synthèse

#### 4-15. Marquer un compte de la balance revu, rattaché à sa feuille

**Besoin :** Tracer la revue de chaque compte de la valorisation et la feuille de travail qui la porte.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après la génération et le visa du lot du 31/12/2025. Le compte 271 figure à la balance d'OMEGA-OPCI au 31/12/2025 ; les feuilles VALO-20241231 (arrêté du 31/12/2024) et VALO-20251231 (arrêté du 31/12/2025) existent. Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Compte 1 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Contrôler la balance et le groupe », bande « Balance des comptes ».
2. Dans la grille « Balance des comptes de la valorisation », cliquez la ligne du compte 271.
3. Dans « RÉFÉRENCE CROISÉE », saisissez VALO-20241231 ; cliquez « Marquer le compte revu ».
4. Dans « RÉFÉRENCE CROISÉE », vidée par le 1er clic, saisissez VALO-20251231 ; cliquez « Marquer le compte revu ».
5. Laissez « RÉFÉRENCE CROISÉE » vide ; cliquez de nouveau « Marquer le compte revu ».

**Vous devez obtenir :** Au 1er clic : « La feuille VALO-20241231 n'est pas une feuille du véhicule à cet arrêté. ». Au 2e clic : « Compte 271 revu, rattaché à la feuille VALO-20251231. » ; la ligne 271 de la grille porte VALO-20251231 dans « Xref », l'auteur et la date. Au 3e clic : « Le compte 271 est déjà revu (feuille VALO-20251231). ».

```
La feuille VALO-20241231 n'est pas une feuille du véhicule à cet arrêté. | Compte 271 revu, rattaché à la feuille VALO-20251231. | Le compte 271 est déjà revu (feuille VALO-20251231).
```

Passé ☐ · Échec ☐ · Remarque :

#### 4-16. Proposer, renvoyer puis viser la synthèse de l'arrêté

**Besoin :** Attester, par le visa du chef de mission, que l'actif net de l'arrêté boucle et que la valeur liquidative se calcule ; un renvoi dit ce qui est à reprendre.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Générer de nouveau le lot et le faire viser par le chef de mission », dont le visa a périmé la synthèse en attente. La carte d'état de « Proposer la synthèse » porte « conditions réunies ».

1. Compte 1 : page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Contrôler la balance et le groupe », bande « Rationalisation et synthèse » ; cliquez « Proposer la synthèse ».
2. Compte 2 : même page ; laissez « MOTIF DU RENVOI » vide ; cliquez « Renvoyer la synthèse ».
3. Compte 2 : saisissez « Relire le poste des plus-values de cession. » ; cliquez « Renvoyer la synthèse ».
4. Compte 1 : cliquez « Proposer la synthèse ».
5. Compte 2 : cliquez « Viser la synthèse » ; lisez la carte d'état de « Viser la synthèse » et la barre des étapes.

**Vous devez obtenir :** Étape 1 : « Synthèse de l'arrêté du 31/12/2025 proposée (n° <id>) : elle attend le visa du chef de mission. ». Étape 2 : « Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger. ». Étape 3 : « Synthèse renvoyée. Arrêté du 31/12/2025, synthèse n° <id>. ». Étape 4 : « Synthèse de l'arrêté du 31/12/2025 proposée (n° <id2>) : elle attend le visa du chef de mission. ». Étape 5 : « Synthèse visée. Arrêté du 31/12/2025, synthèse n° <id2>. » ; la carte porte « synthèse visée le <date du jour> » ; l'étape « Contrôler la balance et le groupe » passe au vert (#1F6D4A).

```
Synthèse de l'arrêté du 31/12/2025 proposée (n° <id>) : elle attend le visa du chef de mission. | Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu'il doit corriger. | Synthèse renvoyée. Arrêté du 31/12/2025, synthèse n° <id>. | Synthèse visée. Arrêté du 31/12/2025, synthèse n° <id2>.
```

Passé ☐ · Échec ☐ · Remarque :

### Recalculer la valorisation, tests manuels

#### 4-17. Recalculer la valeur actuelle et la différence d'estimation des immeubles

**Nature :** Contrôle par recalcul  
**Besoin :** S'assurer que la valeur de chaque immeuble et sa différence d'estimation se retrouvent à la main à partir du prix de revient, de l'expertise et de la valeur retenue visée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après les tests de valeur retenue du 31/12/2025 (IMM-201 visée à 13 000 000,00, IMM-203 visée à 16 537 500,00) et après « Exporter le classeur des valeurs, le modifier, le réimporter » (expertise d'IMM-202 à 9 450 000,00). Prix de revient du jeu : IMM-201 12 000 000,00, IMM-202 9 500 000,00, IMM-203 15 000 000,00.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Arrêter les valeurs », bande « Immeubles ».
2. Dans la grille « Immeubles », relevez pour IMM-201, IMM-202, IMM-203 et 2 immeubles de filiales de votre choix « Prix de revient », « Expertise », « Proposée », « Valeur actuelle », « Différence » et « État » dans un tableur.
3. Étape « Lire les différences » : dans la bande des familles en tête de l'étape, cliquez la tuile « Immeubles ». Dans le détail par actif, relevez pour IMM-201, IMM-202 et IMM-203 « Valeur comptable », « Valeur actuelle » et « Différence cumulée » ; dans la grille « Variation de l’arrêté », relevez « Arrêté précédent », « Arrêté » et « Variation » de la ligne des immeubles ; dans la grille « Immeubles des filiales », relevez pour vos 2 immeubles de filiales « Prix de revient », « Valeur actuelle » et « Différence ».
4. Refaites chaque calcul.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 sur chaque ligne : Différence = Valeur actuelle − Prix de revient, dans la grille « Immeubles » comme dans la grille « Immeubles des filiales » ; Différence cumulée = Valeur actuelle − Valeur comptable, la valeur comptable d'un immeuble étant son prix de revient ; Valeur actuelle = valeur retenue quand elle est visée, sinon la dernière expertise datée au plus tard de l'arrêté ; Variation = Arrêté − Arrêté précédent. Pour IMM-201 : 13 000 000,00 − 12 000 000,00 = 1 000 000,00. Pour IMM-202 : 9 450 000,00 − 9 500 000,00 = -50 000,00. Pour IMM-203 : 16 537 500,00 − 15 000 000,00 = 1 537 500,00. Les immeubles de filiales portent l'état « dans l’ANR » et ne figurent pas au détail par actif. Le testeur note l'écart de chaque ligne.

Passé ☐ · Échec ☐ · Constats :

#### 4-18. Recalculer la valeur actuelle des titres de filiales

**Nature :** Contrôle par recalcul  
**Besoin :** Retrouver la valeur des titres de chaque filiale à partir de son actif net réévalué et de la quote-part détenue, puis sa différence au compte 275.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** OMEGA-OPCI, arrêté du 31/12/2025 ouvert.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Valoriser les titres ».
2. Pour chaque filiale de la grille, relevez « Quote-part », « Actif net réévalué », « Valeur actuelle des titres », « Titres au compte 254 » et « Différence au 275 ».
3. Refaites les calculs dans un tableur.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 par filiale, arrondi au centime : Valeur actuelle des titres = Actif net réévalué × Quote-part, ramenée à 0 quand ce produit est négatif ; Différence au 275 = Valeur actuelle des titres − Titres au compte 254. Le testeur note chaque écart.

Passé ☐ · Échec ☐ · Constats :

#### 4-19. Recalculer la balance de la valorisation et le contrôle C84

**Nature :** Contrôle par recalcul  
**Besoin :** Vérifier que la balance après valorisation se reconstitue et que les écritures de valorisation correspondent aux différences des actifs.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après le visa du lot du 31/12/2025.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Contrôler la balance et le groupe », bande « Balance des comptes ».
2. Pour 5 comptes de la grille « Balance des comptes de la valorisation », dont 271 et 1052, relevez « Balance avant », « OD de révision », « OD de valorisation » et « Balance après ».
3. Dans le bloc « Différence des actifs et écritures », relevez « Différence des actifs », « Différence des écritures », « Écart » et « État ».
4. Refaites les calculs.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00 : Balance après = Balance avant + OD de révision + OD de valorisation, en débit moins crédit ; Écart = Différence des actifs − Différence des écritures. Le testeur note les écarts de recalcul et l'« État » affiché du contrôle.

Passé ☐ · Échec ☐ · Constats :

#### 4-20. Recalculer la rationalisation de l'actif net et la VL de l'arrêté

**Nature :** Contrôle par recalcul  
**Besoin :** Vérifier à la main que l'actif net rationalisé boucle sur l'actif net calculé et que la valeur liquidative découle de l'actif net réévalué et du nombre de parts.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après la synthèse visée du 31/12/2025. Nombre de parts du jeu au 31/12/2025 : 1 407 990.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Contrôler la balance et le groupe », bande « Rationalisation et synthèse ».
2. Relevez « Actif net de l’arrêté précédent », « Actif net rationalisé », « Actif net calculé » et « Écart, rationalisé moins calculé ».
3. Dans le bloc « Valeur liquidative », relevez « VL calculée », « Actif net réévalué » et « Nombre de parts ».
4. Refaites les calculs.

**Ce que vous comparez ou notez :** Identités vérifiées : Écart = Actif net rationalisé − Actif net calculé, écart de recalcul 0,00 ; la ligne « Rationalisation » des conditions de la proposition porte « la rationalisation boucle au seuil de 1 000,00 » quand la valeur absolue de l'Écart ne dépasse pas 1 000,00, et « hors du seuil » au-delà ; Nombre de parts = 1 407 990 ; VL calculée = Actif net réévalué ÷ Nombre de parts, portée à 2 décimales par la base, écart de recalcul au plus 0,01, l'actif net réévalué affiché étant arrondi au centime. Le testeur note chaque écart.

Passé ☐ · Échec ☐ · Constats :

#### 4-21. Recalculer la cible du compte 275 et l'état de sa reprise

**Nature :** Contrôle par recalcul  
**Besoin :** Vérifier que la cible du compte 275 se déduit de la valeur des titres, et que le bouton de reprise n'est actif que s'il reste un montant à passer.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** OMEGA-OPCI, arrêté du 31/12/2025 ouvert.

1. Page « Valorisation », OMEGA-OPCI, 31/12/2025, étape « Générer les écritures », bloc « Reprise du compte 275 ».
2. Relevez « Valeur actuelle des titres », « Titres au compte 254 », « Cible du compte 275 », « Compte 275 à l’arrêté » et « Reste à passer ».
3. Relevez la couleur de « Reprendre l’écart du 275 » et le texte de sa carte d'état.
4. Ne cliquez pas « Reprendre l’écart du 275 » : un clic pose un lot de reprise proposé, que les tests suivants ne prévoient pas.

**Ce que vous comparez ou notez :** Identité vérifiée, écart attendu 0,00 : Cible du compte 275 = Valeur actuelle des titres − Titres au compte 254. Règle vérifiée : « Reprendre l’écart du 275 » est bleu (#0F5C8C) et sa carte porte « conditions réunies » seulement quand « Reste à passer » n'est pas nul et qu'aucun lot de reprise n'est proposé ; sinon il est gris (#D9DFE6) et la carte porte « reste à passer nul » ou « lot de reprise proposé, en attente du visa ». Le testeur note l'écart et l'état lu.

Passé ☐ · Échec ☐ · Constats :

### Conduire la valorisation d'un arrêté, tests manuels

#### 4-22. Arrêter et justifier les valeurs du 31/12/2025 comme en mission

**Nature :** Parcours métier  
**Besoin :** Conduire la valorisation d'un arrêté de bout en bout, chaque valeur rapprochée de sa pièce, comme le fait une équipe de mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après les tests scénarisés du groupe 4. Compte 1 prépare, Compte 2 vise. OMEGA-OPCI, arrêté du 31/12/2025, dossier non verrouillé. Tout lot de l'arrêté visé après la synthèse visée au test « Proposer, renvoyer puis viser la synthèse de l'arrêté » périme cette synthèse (fabric/DossierOPCI.SQLDatabase/dbo/Tables/lot_ecritures.sql:106-123) : elle se propose et se vise de nouveau.

1. Objectif : arrêter les valeurs d'OMEGA-OPCI au 31/12/2025, immeubles du véhicule et des filiales, avances, titres, et conduire la page jusqu'à la synthèse visée, dans l'ordre que vous choisissez.
2. Périmètre : page « Valorisation », ses 5 étapes et leurs bandes ; page « Révision », étape 5 « Conclure », pour le visa des lots ; les rapports d'expertise ouverts depuis la fiche « Rapport d’expertise ».
3. Pour chaque immeuble, rapprochez la valeur affichée de son rapport ; reprenez, visez ou renvoyez ce qui doit l'être ; lisez les différences, les titres, la balance, les contrôles du groupe et la rationalisation.
4. Notez au fil du parcours chaque arrêt, chaque information manquante et l'heure de début et de fin.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté, ce qui lui a manqué et le temps passé. Résultat d'ensemble à atteindre pour le 31/12/2025 : dans la barre des étapes de la page « Valorisation », les étapes 1 « Arrêter les valeurs », 3 « Valoriser les titres », 4 « Générer les écritures » et 5 « Contrôler la balance et le groupe » sont vertes (#1F6D4A) ; l'étape 2 « Lire les différences », de lecture, n'a pas d'état ; chaque immeuble de la grille « Immeubles » est à l'état « calculable » ou « dans l’ANR » ; la carte d'état de « Viser la synthèse » contient « synthèse visée le <date> ». Pour chaque étape restée grise, le testeur relève la condition affichée par la page.

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 5. La validation et la publication

### Conclure les limites réglementaires

#### 5-01. Conclure une limite réglementaire de l'arrêté

**Besoin :** Inscrire, limite par limite, la conclusion du cabinet sur le respect des ratios réglementaires à l'arrêté.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI, arrêté du 31/12/2025 ouvert et non validé pour le client ; dossier non verrouillé. Compte 1 membre de l'équipe. Le bouton vide ses champs de saisie et ses listes après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent.

1. Page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 1 Ratios réglementaires », sous-onglet « Calcul et conclusion ».
2. Dans la liste « LIMITE », choisissez « Actifs immobiliers, 60 % de l’actif ».
3. Laissez « CONCLUSION DE LA LIMITE » vide ; cliquez « Conclure la limite ».
4. Dans « LIMITE », choisissez de nouveau « Actifs immobiliers, 60 % de l’actif » ; dans « CONCLUSION DE LA LIMITE », saisissez « Limite respectée à l'arrêté. » ; cliquez « Conclure la limite ».

**Vous devez obtenir :** Au 1er clic, la zone « MESSAGE » affiche « La conclusion est obligatoire : saisissez-la avant de conclure la limite. ». Au 2e clic : « Limite « Actifs immobiliers, 60 % de l’actif » conclue au 31/12/2025. ».

```
La conclusion est obligatoire : saisissez-la avant de conclure la limite. | Limite « Actifs immobiliers, 60 % de l’actif » conclue au 31/12/2025.
```

Passé ☐ · Échec ☐ · Remarque :

#### 5-02. Une limite ne se conclut plus sur un arrêté validé pour le client

**Besoin :** Les conclusions d'un arrêté validé pour le client sont figées.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué avant la réouverture du 31/12/2024 : cet arrêté porte un visa de clôture visé, il est validé pour le client. Le jeu ne pose aucun verrou de dossier sur le 31/12/2024 ; un dossier verrouillé ferait répondre d'abord « Le dossier de cet arrêté est visé et verrouillé. ».

1. Page « Arrêté », OMEGA-OPCI, arrêté 31/12/2024, étape « 1 Ratios réglementaires », sous-onglet « Calcul et conclusion ».
2. Dans la liste « LIMITE », choisissez « Actifs immobiliers, 60 % de l’actif » ; dans « CONCLUSION DE LA LIMITE », saisissez « Limite respectée à l'arrêté. » ; cliquez « Conclure la limite » et lisez la zone « MESSAGE ».

**Vous devez obtenir :** La zone « MESSAGE » affiche « L'arrêté est validé pour le client : ses conclusions ne se reprennent plus. » ; aucune conclusion n'est inscrite.

```
L'arrêté est validé pour le client : ses conclusions ne se reprennent plus.
```

Passé ☐ · Échec ☐ · Remarque :

### Publier la valeur liquidative

#### 5-03. La publication de la VL est réservée à l'associé signataire

**Besoin :** Séparation des fonctions : la valeur liquidative, qui sort vers le porteur, se publie par l'associé signataire seul.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI, arrêté du 31/12/2025, joué après « Proposer, renvoyer puis viser la synthèse de l'arrêté ». Le jeu porte au 31/12/2025 une VL publiée le 06/09/2026, non périmée. Compte 2 tient le rôle CHEF_MISSION, pas ASSOCIE.

1. Compte 2 : page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 2 Valeur liquidative ».
2. Lisez la carte d'état de « Publier la VL ».
3. Cliquez « Publier la VL ».

**Vous devez obtenir :** « Publier la VL » est gris (#D9DFE6). Sa carte d'état commence par « visa réservé à l’associé signataire » et se termine par « VL publiée le 06/09/2026 ». Le clic affiche « Visa refusé : la publication de la valeur liquidative est réservée à l'associé signataire du dossier, rôle que votre adresse de connexion ne tient pas. » ; la grille « Visas de l’arrêté » ne porte aucun visa nouveau.

```
Visa refusé : la publication de la valeur liquidative est réservée à l'associé signataire du dossier, rôle que votre adresse de connexion ne tient pas.
```

Passé ☐ · Échec ☐ · Remarque :

#### 5-04. Une VL déjà publiée ne se publie pas une 2e fois

**Besoin :** Une seule publication en vigueur par arrêté ; une nouvelle publication suppose la réouverture.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** OMEGA-OPCI, 31/12/2025 : le jeu de démonstration porte une VL publiée de 114,84, le 06/09/2026, non périmée. Joué après « Proposer, renvoyer puis viser la synthèse de l'arrêté » ; aucun lot d'OMEGA-OPCI au 31/12/2025 n'est au statut proposé, sinon la carte porte aussi « 1 lot proposé, non visé ».

1. Compte 1 : page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 2 Valeur liquidative ».
2. Lisez la couleur de « Publier la VL » et sa carte d'état.
3. Cliquez « Publier la VL ».

**Vous devez obtenir :** Le bouton est gris (#D9DFE6) et la carte porte « VL publiée le 06/09/2026 ». Le clic affiche « Visa refusé : l'écran ne désigne aucun objet à viser ; l'action n'est pas exécutée. » ; la grille « Valeurs liquidatives du véhicule » garde une seule publication au 31/12/2025.

```
Visa refusé : l'écran ne désigne aucun objet à viser ; l'action n'est pas exécutée.
```

Passé ☐ · Échec ☐ · Remarque :

### Proposer et viser l'obligation de distribution

#### 5-05. L'obligation de distribution se propose par le préparateur, à l'arrêté annuel seulement

**Besoin :** Seul le préparateur propose la base d'une catégorie, une catégorie visée ne se reprend pas, et la distribution ne se traite qu'à l'arrêté annuel.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI. Au 31/12/2025, le jeu de démonstration porte les catégories plus-values et produits exonérés visées. Le 30/06/2026 est un arrêté semestriel ouvert. Compte 1 tient encore le rôle PREPARATEUR. Le bouton vide ses champs de saisie et la liste « CATÉGORIE » après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent, catégorie comprise.

1. Compte 2 : page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Base et visa par catégorie » ; dans « CATÉGORIE », choisissez « Résultat distribuable afférent aux produits, 85 % au moins » ; « BASE PROPOSÉE » 100 ; « SOURCE DE LA BASE » « Essai » ; cliquez « Proposer la base ».
2. Compte 1 : même page ; choisissez « Plus-values de cession, 50 % au moins » ; « BASE PROPOSÉE » 0 ; « SOURCE DE LA BASE » « Essai » ; cliquez « Proposer la base ».
3. Compte 1 : choisissez de nouveau « Plus-values de cession, 50 % au moins » ; cliquez « Viser la catégorie ».
4. Compte 1 : choisissez l'arrêté 30/06/2026 ; lisez le libellé de l'étape 3 ; choisissez « Résultat distribuable afférent aux produits, 85 % au moins », base 100, source « Essai » ; cliquez « Proposer la base ».
5. Compte 1 : sous-onglet « Décision de l’assemblée » ; « MONTANT DÉCIDÉ » 100 ; cliquez « Enregistrer la décision ».

**Vous devez obtenir :** Étape 1 : « Proposition refusée : la base se propose par le préparateur du dossier, rôle que votre adresse de connexion ne tient pas. ». Étape 2 : « Proposition refusée : cette catégorie est déjà visée pour l'exercice. ». Étape 3 : « Visa refusé : cette catégorie est déjà visée pour l'exercice. ». Étape 4 : l'étape porte « 3 Distribution annuelle · sans objet » ; « Proposition refusée : l'obligation de distribution se calcule à la clôture annuelle, et cet arrêté n'est pas un arrêté annuel ouvert du véhicule. ». Étape 5 : « Décision refusée : la distribution se décide à la clôture annuelle, et l'arrêté du 30/06/2026 n'est pas un arrêté annuel. ». Rien n'est écrit.

```
Proposition refusée : la base se propose par le préparateur du dossier, rôle que votre adresse de connexion ne tient pas. | Proposition refusée : cette catégorie est déjà visée pour l'exercice. | Visa refusé : cette catégorie est déjà visée pour l'exercice. | Proposition refusée : l'obligation de distribution se calcule à la clôture annuelle, et cet arrêté n'est pas un arrêté annuel ouvert du véhicule. | Décision refusée : la distribution se décide à la clôture annuelle, et l'arrêté du 30/06/2026 n'est pas un arrêté annuel.
```

Passé ☐ · Échec ☐ · Remarque :

#### 5-06. L'associé ne vise pas la base qu'il a lui-même proposée

**Besoin :** Séparation des fonctions : la base d'une catégorie se propose par un autre que l'associé qui la vise.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Compte 1 tient ASSOCIE et PREPARATEUR (sql/90_vous_inscrire_aux_missions.sql). Au 31/12/2025, la catégorie résultat n'est pas visée dans le jeu de démonstration. Le bouton vide ses champs de saisie et la liste « CATÉGORIE » après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent, catégorie comprise.

1. Compte 1 : page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Base et visa par catégorie » ; dans « CATÉGORIE », choisissez « Résultat distribuable afférent aux produits, 85 % au moins ».
2. Lisez « Base calculée » de la ligne de cette catégorie dans « Obligation par catégorie ». Dans « BASE PROPOSÉE », saisissez cette base, ou 1 000 000,00 si la cellule porte « à remplir » ; « SOURCE DE LA BASE » « Base calculée par la solution, relue. » ; cliquez « Proposer la base ».
3. Choisissez de nouveau la même catégorie ; cliquez « Viser la catégorie ».
4. Choisissez de nouveau la même catégorie ; dans « MOTIF DU RENVOI », saisissez « Essai » ; cliquez « Renvoyer la catégorie ».

**Vous devez obtenir :** La proposition affiche « Base proposée : <base> × 85 % = <montant>. Elle attend le visa de l'associé. » ; <montant> = <base> × 0,85, arrondi au centime. Le visa et le renvoi sont refusés : « Visa refusé : le décideur est celui qui a proposé l'objet. Nul ne vise son propre travail. ».

```
Base proposée : <base> × 85 % = <montant>. Elle attend le visa de l'associé. | Visa refusé : le décideur est celui qui a proposé l'objet. Nul ne vise son propre travail.
```

Passé ☐ · Échec ☐ · Remarque :

#### 5-07. Le préparateur propose la base, l'associé la renvoie puis la vise

**Besoin :** La base de chaque catégorie se propose par le préparateur et se vise par l'associé signataire, un renvoi portant son motif.  
**Profil :** Compte 3 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « L'associé ne vise pas la base qu'il a lui-même proposée » : la base de la catégorie résultat du 31/12/2025 est proposée par Compte 1, et le renvoi refusé de ce test a pu laisser « Essai » dans « MOTIF DU RENVOI » du Compte 1. Compte 3 ouvre l'application en lecteur, rôle « Reviseur ». Il a été désigné « Collaborateur » d'UAT-OPCI au test « Désigner le collaborateur du dossier » et ne tient aucun mandat sur OMEGA-OPCI avant l'étape 1. L'étape 1 clôt le mandat PREPARATEUR de Compte 1 sur OMEGA-OPCI, qui reste ASSOCIE. Le Compte 1 a laissé OMEGA-OPCI choisi dans la liste des clients au test « Une pièce qui fonde la conclusion d'une feuille ne se retire pas » : la ligne peut l'être encore. « Proposer la base », « Renvoyer la catégorie » et « Viser la catégorie » vident automatiquement « CATÉGORIE » et leurs champs. Avant chaque clic, vérifiez la catégorie et les champs.

1. Compte 1 : ouvrez la page « Client et Acceptation » et cliquez l'étape « Dossier ». Lisez l'en-tête de l'étape. S'il ne commence pas par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier. Section « Équipe de la mission », tableau « Rôles du dossier » : cliquez la ligne « Collaborateur ». Le bouton « Désigner » ne vide pas « Personne » ni « Connexion (UPN) ». Effacez le texte qu'ils gardent d'une désignation antérieure, puis saisissez dans « Personne » le nom du titulaire de Compte 3 et dans « Connexion (UPN) » son adresse de connexion exacte. Si l'en-tête commence par « OMEGA-OPCI · », cliquez « Désigner ». S'il ne commence plus par « OMEGA-OPCI · » après le clic, cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran » et le tableau « Rôles du dossier ».
2. Compte 3 : page « Arrêté », « VÉHICULE » OMEGA-OPCI · OPCI OMEGA, « ARRÊTÉ » 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Base et visa par catégorie ». Dans « CATÉGORIE », choisissez « Résultat distribuable afférent aux produits, 85 % au moins ». Dans « BASE PROPOSÉE » et « SOURCE DE LA BASE », saisissez la base et la source du test « L'associé ne vise pas la base qu'il a lui-même proposée ». Cliquez « Proposer la base » et lisez la zone « MESSAGE ».
3. Compte 1 : page « Arrêté », « VÉHICULE » OMEGA-OPCI · OPCI OMEGA, « ARRÊTÉ » 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Base et visa par catégorie ». Vérifiez que « CATÉGORIE » porte la seule catégorie de l'étape 2, sinon choisissez-la. Effacez le texte de « MOTIF DU RENVOI » s'il en porte un. Cliquez « Renvoyer la catégorie » et lisez la zone « MESSAGE ».
4. Compte 1 : vérifiez que « CATÉGORIE » porte la catégorie de l'étape 2, sinon choisissez-la. Dans « MOTIF DU RENVOI », saisissez « Source à préciser : citer la balance et l'abattement. ». Cliquez « Renvoyer la catégorie » et lisez la zone « MESSAGE ».
5. Compte 3 : vérifiez que « CATÉGORIE » porte la catégorie de l'étape 2, sinon choisissez-la. Saisissez de nouveau la même base et la même source. Cliquez « Proposer la base » et lisez la zone « MESSAGE ».
6. Compte 1 : vérifiez que « CATÉGORIE » porte la catégorie de l'étape 2, sinon choisissez-la. Effacez le texte de « MOTIF DU RENVOI » s'il en porte un. Cliquez « Viser la catégorie ». Lisez la zone « MESSAGE » et la barre des étapes.

**Vous devez obtenir :** Étape 1 : la zone « Message de l'écran » affiche « <nom de Compte 3> désigné PREPARATEUR de OMEGA-OPCI. Le mandat de <titulaire précédent> est clos. ». <titulaire précédent> est le nom inscrit pour Compte 1 par sql/90_vous_inscrire_aux_missions.sql, c'est-à-dire son adresse de connexion. Dans « Rôles du dossier », la ligne « Collaborateur » porte le nom de Compte 3 et l'« État » « désigné ». Étapes 2 et 5 : la zone « MESSAGE » affiche « Base proposée : <base> × 85 % = <montant>. Elle attend le visa de l'associé. ». Étape 3 : « Le motif du renvoi est obligatoire : il dit au préparateur ce qui est à reprendre. ». Étape 4 : « Catégorie renvoyée au préparateur pour l'exercice clos le 31/12/2025. ». Étape 6 : « Catégorie visée pour l'exercice clos le 31/12/2025. ». L'étape « 3 Distribution annuelle » de la barre passe au vert, les 3 catégories de l'exercice étant visées.

```
<nom> désigné PREPARATEUR de OMEGA-OPCI. Le mandat de <titulaire précédent> est clos. | Base proposée : <base> × 85 % = <montant>. Elle attend le visa de l'associé. | Le motif du renvoi est obligatoire : il dit au préparateur ce qui est à reprendre. | Catégorie renvoyée au préparateur pour l'exercice clos le 31/12/2025. | Catégorie visée pour l'exercice clos le 31/12/2025.
```

Passé ☐ · Échec ☐ · Remarque :

### Enregistrer la décision de l'assemblée

#### 5-08. Enregistrer la décision de l'assemblée entre les bornes de l'obligation

**Besoin :** Inscrire le montant de distribution décidé par l'assemblée, refusé hors des bornes de l'article L. 214-69, II.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI, 31/12/2025, arrêté annuel. La « Fiche de la décision » de la catégorie résultat porte une borne basse et une borne haute. Le bouton vide ses champs de saisie et la liste « CATÉGORIE » après un appel réussi ; après un refus, ils peuvent garder leur saisie : avant chaque clic, vérifiez ce qu'ils portent, catégorie comprise.

1. Page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Décision de l’assemblée » ; dans « CATÉGORIE », choisissez « Résultat distribuable afférent aux produits, 85 % au moins ».
2. Dans « Fiche de la décision », relevez le montant de « Borne basse de la décision » et celui de « Borne haute de la décision ».
3. Dans « MONTANT DÉCIDÉ », saisissez la borne haute augmentée de 1 000,00 ; dans « DATE DE L’ASSEMBLÉE », saisissez 30/06/2026 ; cliquez « Enregistrer la décision ».
4. Choisissez de nouveau la même catégorie ; dans « MONTANT DÉCIDÉ », saisissez la borne basse ; dans « DATE DE L’ASSEMBLÉE », saisissez 30/06/2026 ; cliquez « Enregistrer la décision ».
5. Lisez la grille « Décisions inscrites ».

**Vous devez obtenir :** Au 1er clic : « Décision refusée : le montant de <montant> sort des bornes. L'obligation minimale est de <minimum>, soit <taux> des sommes distribuables, et le total distribuable est de <total>. Article L. 214-69, II. », <minimum> et <total> égalant la borne basse et la borne haute relevées, <taux> valant 85,00 %. Au 2e clic : « Décision enregistrée pour l'exercice clos le 31/12/2025 : « Résultat distribuable afférent aux produits, 85 % au moins », montant décidé <montant>, assemblée du 30/06/2026. », le libellé de la catégorie portant l'espace fine insécable entre 85 et % ; la grille « Décisions inscrites » porte la ligne de la catégorie avec l'obligation, le montant décidé et l'assemblée du 30/06/2026.

```
Décision refusée : le montant de <montant> sort des bornes. L'obligation minimale est de <minimum>, soit <taux> des sommes distribuables, et le total distribuable est de <total>. Article L. 214-69, II. | Décision enregistrée pour l'exercice clos le 31/12/2025 : « Résultat distribuable afférent aux produits, 85 % au moins », montant décidé <montant>, assemblée du 30/06/2026.
```

Passé ☐ · Échec ☐ · Remarque :

### Lire les conditions de la validation

#### 5-09. Lire les conditions de la validation pour le client

**Besoin :** Savoir, avant de valider l'arrêté pour le client, quelles conditions sont remplies et sur quel écran lever les autres.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après les tests de distribution du 31/12/2025. Le jeu de démonstration porte pour le 31/12/2025 un visa de clôture renvoyé.

1. Page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 4 Passer à la validation ».
2. Lisez le tableau « Condition », « Remplie », « Lecture », « Écran ».
3. Cliquez « Ouvrir les Livrables ».

**Vous devez obtenir :** La ligne « Valeur liquidative publiée » porte « Oui », « le 06/09/2026 » et l'écran « Arrêté, étape 2 ». La ligne « Sommes distribuables visées » porte « Oui », « 3 / 3, catégories de l’exercice, à l’arrêté annuel » et l'écran « Arrêté, étape 3 ». La ligne « Revue visée, dossier verrouillé » porte l'écran « Révision, étape 5 Conclure ». L'étape « 4 Passer à la validation » n'est pas verte, le visa de clôture n'étant pas visé. « Ouvrir les Livrables » ouvre l'étape 6 de la page « Révision ».

Passé ☐ · Échec ☐ · Remarque :

### Valider l'arrêté pour le client

#### 5-10. La validation pour le client revient au chef de mission, après le visa de la revue

**Besoin :** Un arrêté n'est validé pour le client que par le chef de mission, une fois la revue visée et les livrables produits par un autre que lui.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Groupe 4 joué. Revue d'OMEGA-OPCI au 31/12/2025 non visée (groupe 3). Arrêté non validé pour le client : la clôture du jeu est renvoyée (sql/80_demonstration/70_visa.sql:135).

1. Avec le Compte 1 : page « Révision », OMEGA-OPCI et 31/12/2025 choisis, étape 6 « Livrables », bloc « 4. Validation pour le client » : lire les 2 lignes de refus et observer « Valider pour le client ».
2. Avec le Compte 2 : même bloc : lire la ligne « Revue visée, dossier verrouillé », sa valeur et sa lecture ; observer « Valider pour le client ».

**Vous devez obtenir :** Compte 1 : les 2 lignes de refus se lisent bout à bout comme la phrase ci-dessous ; « Valider pour le client » est inactif. Compte 2 : la ligne « Revue visée, dossier verrouillé » vaut « Non », sa lecture indique le nombre de cycles visés sur le nombre de cycles au programme, puis « dossier non verrouillé » ; « Valider pour le client » est inactif tant que la revue n'est pas visée.

```
Validation refusée : cette personne n'a pas, sur cette entité, le rôle de chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

### Publier la valeur liquidative, tests manuels

#### 5-11. Recalculer la valeur liquidative et sa variation, arrêté par arrêté

**Nature :** Contrôle par recalcul  
**Besoin :** Retrouver à la main chaque valeur liquidative du véhicule à partir de l'actif net réévalué et du nombre de parts, et l'écart entre VL publiée et VL calculée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après le groupe 4. Jeu de démonstration : 1 407 990 parts aux 31/12/2022, 31/12/2023, 31/12/2024 et 31/12/2025 ; VL publiée au 31/12/2025 : 114,84.

1. Page « Arrêté », OMEGA-OPCI, arrêté 31/12/2025, étape « 2 Valeur liquidative ».
2. Dans la grille « Valeurs liquidatives du véhicule », relevez pour les lignes 31/12/2022, 31/12/2023 et 31/12/2025 : « Actif net réévalué », « Parts », « VL calculée », « Variation », « VL publiée » et « État ».
3. Refaites les calculs dans un tableur.

**Ce que vous comparez ou notez :** Identités vérifiées : VL calculée = Actif net réévalué ÷ Parts, portée à 2 décimales, écart de recalcul au plus 0,01 ; Parts = 1 407 990 sur les 3 lignes ; Variation du 31/12/2023 = VL calculée du 31/12/2023 − VL calculée du 31/12/2022, écart 0,00 ; ligne 31/12/2025 : VL publiée 114,84, État « publiée » quand VL publiée = VL calculée, sinon « publiée, écart » suivi de VL publiée − VL calculée, signe compris. Le testeur note chaque écart.

Passé ☐ · Échec ☐ · Constats :

### Proposer et viser l'obligation de distribution, tests manuels

#### 5-12. Recalculer l'obligation de distribution et les bornes de la décision

**Nature :** Contrôle par recalcul  
**Besoin :** Retrouver à la main l'obligation de chaque catégorie et les bornes dans lesquelles l'assemblée décide.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Joué après « Le préparateur propose la base, l'associé la renvoie puis la vise ». Taux des catégories : 85 % pour le résultat, 50 % pour les plus-values, 100 % pour les produits exonérés.

1. Page « Arrêté », OMEGA-OPCI, 31/12/2025, étape « 3 Distribution annuelle », sous-onglet « Base et visa par catégorie » : pour les 3 lignes de « Obligation par catégorie », relevez « Base calculée », « Taux » et « Obligation » ; relevez « Résultat distribuable » et « Plus-values distribuables » du bloc « Sommes distribuables ».
2. Sous-onglet « Décision de l’assemblée » : dans la liste « CATÉGORIE », choisissez l'une après l'autre les 3 catégories et relevez pour chacune, dans « Fiche de la décision », « Borne basse de la décision » et « Borne haute de la décision ».
3. Refaites les calculs.

**Ce que vous comparez ou notez :** Identités vérifiées, écart attendu 0,00, arrondi au centime : Obligation = Base calculée × Taux, le Taux s'affichant en pour cent (« 85,00 % » vaut 0,85), sur chaque ligne dont la « Base calculée » est un montant (une base « à remplir » donne une obligation « à remplir ») ; Borne haute = Plus-values distribuables pour la catégorie plus-values, Résultat distribuable pour les 2 autres ; Borne basse = Borne haute × taux de la catégorie. Le testeur note chaque écart.

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 6. La réouverture d'un arrêté clos

### La réouverture d'un arrêté clos

#### 6-01. Demande de réouverture refusée au chef de mission

**Besoin :** La réouverture d'un arrêté se fait à 2 personnes : un membre de l'équipe la demande, le chef de mission la décide ; elle commence par le dernier arrêté clos du client.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI : les visas de clôture courants du 31/12/2022, du 31/12/2023 et du 31/12/2024 sont « VISE », celui du 31/12/2025 est « RENVOYE » ; aucun test des groupes 3 à 5 ne valide le 31/12/2025 pour le client : le 31/12/2024 est le dernier arrêté clos. Rôles sur OMEGA-OPCI : Compte 2 chef de mission ; Compte 1 associé signataire ; Compte 3 collaborateur depuis le test « Le préparateur propose la base, l'associé la renvoie puis la vise ». Aucune demande de réouverture en attente.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
3. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
4. Ouvrez la liste « ARRÊTÉ CLOS » et relevez les arrêtés proposés ; cochez 31/12/2024 s'il ne l'est pas déjà et lisez l'avis de la demande.
5. Saisissez « MOTIF DE LA DEMANDE » : Lot tardif d'écritures. Cliquez « Demander la réouverture ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, et le tableau « Demandes de réouverture ».

**Vous devez obtenir :** La liste « ARRÊTÉ CLOS » propose 31/12/2024 seul : 31/12/2022 et 31/12/2023 ont un arrêté postérieur clos ; 31/12/2025, 30/06/2026 et 31/12/2026 ne sont pas validés pour le client. L'avis porte « Vous décidez les réouvertures de ce dossier ; la demande vient d'un autre membre de l'équipe. » et le bouton « Demander la réouverture » est grisé. Au clic, la zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Demandes de réouverture » ne porte aucune demande en attente.

```
Demande refusée : vous décidez les réouvertures de ce dossier ; la demande vient d'un autre membre de l'équipe.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-02. Demande de réouverture refusée sans motif

**Besoin :** Une demande de réouverture dit quel lot tardif la justifie.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** OMEGA-OPCI : 31/12/2024 est le dernier arrêté clos (visa de clôture « VISE » du jeu de démonstration) et 31/12/2025 est ouvert, non validé pour le client. Rôles sur OMEGA-OPCI : Compte 1 associé signataire, membre de l'équipe sans le rôle de chef de mission ; Compte 2 chef de mission ; Compte 3 collaborateur depuis le test « Le préparateur propose la base, l'associé la renvoie puis la vise », où le Compte 1 a choisi OMEGA-OPCI dans la liste des clients : la ligne peut l'être encore. Aucune demande de réouverture en attente.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
2. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
3. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Laissez « MOTIF DE LA DEMANDE » vide.
4. Cliquez « Demander la réouverture ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, et le tableau « Demandes de réouverture ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. Le tableau « Demandes de réouverture » ne porte aucune demande en attente.

```
Demande refusée : elle exige un motif, qui dit quel lot tardif justifie de rouvrir l'arrêté.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-03. Demander la réouverture d'un arrêté clos

**Besoin :** Un membre de l'équipe demande, avec son motif, la réouverture du dernier arrêté clos.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** OMEGA-OPCI : 31/12/2024 est le dernier arrêté clos (visa de clôture « VISE » du jeu de démonstration) et 31/12/2025 est ouvert, non validé pour le client. Rôles sur OMEGA-OPCI : Compte 1 associé signataire, membre de l'équipe sans le rôle de chef de mission ; Compte 2 chef de mission ; Compte 3 collaborateur depuis le test « Le préparateur propose la base, l'associé la renvoie puis la vise ». Aucune demande de réouverture en attente. Le Compte 1 a choisi OMEGA-OPCI au test « Demande de réouverture refusée sans motif » : la ligne peut l'être encore.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission. Cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
2. Lisez l'en-tête de l'étape. S'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
3. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Saisissez « MOTIF DE LA DEMANDE » : Lot tardif d'écritures.
4. Cliquez « Demander la réouverture ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape.
5. Si 31/12/2024 n'est plus coché dans « ARRÊTÉ CLOS », cochez-le de nouveau. S'il l'est encore, ne cliquez pas. Lisez le tableau « Demandes de réouverture » et la carte de la demande en attente.

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le tableau « Demandes de réouverture » porte 31/12/2024 avec « Demandée par » : l'adresse de connexion du Compte 1, que sql/90_vous_inscrire_aux_missions.sql inscrit comme nom de la personne ; « Demandée le » : la date du jour ; « Motif de la demande » : Lot tardif d'écritures ; « État » : En attente. La carte porte « Demande <de |d'><adresse du Compte 1> du <date du jour> pour l'arrêté du 31/12/2024, en attente de décision. ».

```
Réouverture de l'arrêté du 31/12/2024 demandée ; elle attend la décision du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-04. Seconde demande de réouverture refusée

**Besoin :** Un arrêté porte au plus une demande de réouverture en attente.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente (test « Demander la réouverture d'un arrêté clos »), à la fin duquel OMEGA-OPCI peut rester choisi dans la liste des clients et 31/12/2024 reste coché dans « ARRÊTÉ CLOS ».

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
2. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
3. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà, et lisez l'avis de la demande.
4. Saisissez « MOTIF DE LA DEMANDE » : essai. Cliquez « Demander la réouverture ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, et le tableau « Demandes de réouverture ».

**Vous devez obtenir :** L'avis porte « Une demande attend déjà la décision du chef de mission pour cet arrêté. » et le bouton est grisé. Au clic, la zone « Message de l'écran » affiche le refus ci-contre. Le tableau porte 1 seule demande « En attente ».

```
Demande refusée : une demande attend déjà la décision du chef de mission pour cet arrêté.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-05. Décision de réouverture refusée à qui n'est pas chef de mission

**Besoin :** La réouverture d'un arrêté se décide par le chef de mission du dossier.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente, faite par le Compte 1 au test « Demander la réouverture d'un arrêté clos ». Compte 1 associé signataire, sans le rôle de chef de mission. Le Compte 1 a choisi OMEGA-OPCI au test « Seconde demande de réouverture refusée » : la ligne peut l'être encore.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission. Cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
2. Lisez l'en-tête de l'étape. S'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
3. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà, et lisez l'avis de la décision.
4. Cliquez « Rouvrir l'arrêté ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape.
5. Si 31/12/2024 n'est plus coché dans « ARRÊTÉ CLOS », cochez-le de nouveau. S'il l'est encore, ne cliquez pas. Cliquez « Écarter la demande ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », le tableau « Demandes de réouverture » et la liste « ARRÊTÉ CLOS ».

**Vous devez obtenir :** L'avis porte « La réouverture d'un arrêté se décide par le chef de mission du dossier. ». Les boutons « Rouvrir l'arrêté » et « Écarter la demande » sont grisés. Au 1er clic, la zone « Message de l'écran » affiche le 1er refus ci-contre ; au 2e clic, le 2e refus. La demande reste « En attente » et 31/12/2024 reste dans « ARRÊTÉ CLOS ».

```
Décision refusée : la réouverture d'un arrêté se décide par le chef de mission du dossier. | Écart refusé : la réouverture d'un arrêté se décide par le chef de mission du dossier.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-06. Écart d'une demande refusé sans motif

**Besoin :** Le chef de mission qui laisse un arrêté clos dit pourquoi.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente, faite par le Compte 1. Le Compte 2 a choisi OMEGA-OPCI au test « Demande de réouverture refusée au chef de mission » : la ligne peut l'être encore.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
3. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
4. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Laissez « MOTIF DE L'ÉCART » vide.
5. Cliquez « Écarter la demande ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, et le tableau « Demandes de réouverture ».

**Vous devez obtenir :** La zone « Message de l'écran » affiche le refus ci-contre. La demande reste « En attente ».

```
Écart refusé : il exige un motif, qui dit pourquoi l'arrêté reste clos.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-07. Écarter une demande de réouverture

**Besoin :** Le chef de mission peut laisser l'arrêté clos, avec son motif.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente, faite par le Compte 1. Le Compte 2 a choisi OMEGA-OPCI au test « Écart d'une demande refusé sans motif » : la ligne peut l'être encore.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
3. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
4. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Saisissez « MOTIF DE L'ÉCART » : Lot intégré à l'exercice suivant.
5. Cliquez « Écarter la demande ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape.
6. Lisez le tableau « Demandes de réouverture » et la liste « ARRÊTÉ CLOS ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le tableau porte la demande à l'état « Écartée », « Décidée par » l'adresse de connexion du Compte 2, que sql/90_vous_inscrire_aux_missions.sql inscrit comme nom de la personne, « Décidée le » la date du jour et « Motif de l'écart » : Lot intégré à l'exercice suivant. 31/12/2024 reste dans « ARRÊTÉ CLOS ».

```
Demande de réouverture de l'arrêté du 31/12/2024 écartée ; l'arrêté reste clos.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-08. Demander de nouveau la réouverture après un écart

**Besoin :** Une demande écartée n'empêche pas une nouvelle demande motivée.  
**Profil :** Compte 1 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Demande précédente du 31/12/2024 d'OMEGA-OPCI écartée ; aucune demande en attente. Le Compte 1 a choisi OMEGA-OPCI au test « Décision de réouverture refusée à qui n'est pas chef de mission » : la ligne peut l'être encore.

1. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
2. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
3. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Saisissez « MOTIF DE LA DEMANDE » : Lot tardif confirmé.
4. Cliquez « Demander la réouverture ». Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, puis le tableau « Demandes de réouverture ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre. Le tableau porte la demande écartée et une nouvelle demande « En attente ».

```
Réouverture de l'arrêté du 31/12/2024 demandée ; elle attend la décision du chef de mission.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-09. Lire ce que touchera la réouverture avant de décider

**Besoin :** Le chef de mission voit, avant de décider, les effets de la réouverture sur le visa, les documents, le rapport client et le verrou.  
**Profil :** Compte 2 · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente, faite par le Compte 1 au test « Demander de nouveau la réouverture après un écart ». Le 31/12/2024 ne porte ni document produit, ni forme d'attestation, ni verrou, ni visa de revue, ni copie chez le client ; il porte une publication au client du 06/09/2026. Le Compte 2 a choisi OMEGA-OPCI au test « Écarter une demande de réouverture » : la ligne peut l'être encore.

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
3. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
4. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà.
5. Lisez les 8 lignes du tableau « Ce que touche la réouverture » ; relevez les colonnes « Aujourd'hui » des lignes « Documents produits » et « Rapport client ».

**Vous devez obtenir :** Le tableau porte 8 lignes, colonnes « Aujourd'hui » puis « Après la réouverture » : « Visa de clôture » : « visé le 06/09/2026 par installation (decide_par) » puis « renvoyé ; le visa d'origine demeure » ; « Statut de l'arrêté » : « Clos » puis « Ouvert » ; « Documents produits » : « aucun en vigueur » puis « aucun à périmer » ; « Forme de l'attestation » : « non arrêtée » puis « inchangée » ; « Rapport client » : « publié le 06/09/2026 » puis « publication du 06/09/2026 maintenue jusqu'à la suivante » ; « Verrou et revue » : « non verrouillé ; revue non visée » puis « inchangés » ; « Maintien, écritures, lots » : « en l'état » puis « inchangés » ; « Copies chez le client » : « aucune copie » puis « aucune copie chez le client ».

Passé ☐ · Échec ☐ · Remarque :

#### 6-10. Rouvrir l'arrêté sur la demande d'un membre de l'équipe

**Besoin :** Le chef de mission accorde la demande : l'arrêté repasse ouvert, ses documents passent périmés et la demande est accordée.  
**Profil :** Compte 2 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Demande de réouverture du 31/12/2024 d'OMEGA-OPCI en attente, faite par le Compte 1 ; valeurs « Aujourd'hui » des lignes « Documents produits » et « Rapport client » relevées au test « Lire ce que touchera la réouverture avant de décider », à la fin duquel OMEGA-OPCI peut rester choisi dans la liste des clients et 31/12/2024 coché dans « ARRÊTÉ CLOS ».

1. Connectez-vous avec le Compte 2.
2. Ouvrez la page « Client et Acceptation » de l'application de conduite de mission ; cliquez l'étape « Arrêtés », puis le bouton « Rouvrir un arrêté ».
3. Lisez l'en-tête de l'étape : s'il ne commence pas par « OMEGA-OPCI · rouvrir un arrêté clos », cliquez la ligne OMEGA-OPCI dans la liste des clients. Ne cliquez pas une ligne OMEGA-OPCI déjà choisie : le clic la désélectionne et l'écran passe au client créé en dernier.
4. Cochez 31/12/2024 dans « ARRÊTÉ CLOS » s'il ne l'est pas déjà. Cliquez « Rouvrir l'arrêté ».
5. Si l'en-tête ne commence plus par « OMEGA-OPCI · », cliquez la ligne OMEGA-OPCI. Lisez la zone « Message de l'écran », sous l'en-tête de l'étape, le tableau « Demandes de réouverture » et la liste « ARRÊTÉ CLOS ».
6. Comparez le message aux valeurs relevées des lignes « Documents produits » et « Rapport client ».

**Vous devez obtenir :** La zone « Message de l'écran » porte le message ci-contre (au-delà de 2 lignes, la zone coupe la fin par « … » ; si la coupure tombe avant la date de publication, le testeur la note). « aucun document à périmer » répond à « aucun en vigueur » relevé à la ligne « Documents produits » ; la date de publication du message, 06/09/2026, égale celle de la ligne « Rapport client » ; le message ne porte ni « verrou levé » ni « revue renvoyée ». Le tableau porte la demande à l'état « Accordée », « Décidée par » l'adresse de connexion du Compte 2. La liste « ARRÊTÉ CLOS » ne porte plus 31/12/2024 et porte 31/12/2023, devenu le dernier arrêté clos.

```
Arrêté du 31/12/2024 rouvert : visa de clôture renvoyé, aucun document à périmer ; la demande <de |d'><adresse du Compte 1> est accordée. Rapport client : la publication du 06/09/2026 reste en ligne jusqu'à la prochaine publication.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-11. Reprendre l'arrêté rouvert ; le client garde sa publication jusqu'à l'actualisation

**Besoin :** La réouverture rend l'arrêté de nouveau modifiable par l'équipe ; le client garde la publication en ligne jusqu'à la prochaine actualisation de son écran, puis ne lit plus l'arrêté rouvert.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Rouvrir l'arrêté sur la demande d'un membre de l'équipe » : le 31/12/2024 d'OMEGA-OPCI est rouvert. Le test « Une limite ne se conclut plus sur un arrêté validé pour le client » (groupe 5) a refusé la même conclusion avant la réouverture. Modèle `restitution_client` non actualisé depuis le début de la phase. Compte client du rôle « Client OMEGA-OPCI ». Pour l'actualisation : Compte 1 s'il est membre de l'espace avec un rôle qui permet d'actualiser un modèle (Contributeur ou plus), sinon la personne qui a installé la solution.

1. Compte 1 : page « Arrêté », « VÉHICULE » OMEGA-OPCI · OPCI OMEGA, « ARRÊTÉ » 31/12/2024, étape « 1 Ratios réglementaires », sous-onglet « Calcul et conclusion » ; dans la liste « LIMITE », choisissez « Actifs immobiliers, 60 % de l’actif » ; dans « CONCLUSION DE LA LIMITE », saisissez « Limite respectée à l'arrêté. » ; cliquez « Conclure la limite » et lisez la zone « MESSAGE ».
2. Compte client : page « La valeur de la part » ; dans « Arrêté », choisissez « Dernier arrêté » ; lisez les entrées de la liste « Arrêté » et les cases « Arrete choisi », « Cloture visee le » et « Publie le » du bandeau.
3. Compte 1, ou la personne qui a installé la solution si Compte 1 n'est pas membre de l'espace : dans l'espace, sur la ligne du modèle `restitution_client`, choisissez « Actualiser maintenant » et attendez la fin.
4. Compte client : rechargez le rapport ; lisez de nouveau les entrées de la liste « Arrêté » ; choisissez « Dernier arrêté » et lisez les 3 cases du bandeau.

**Vous devez obtenir :** Étape 1 : la zone « MESSAGE » porte le message ci-contre ; avant la réouverture, la même conclusion recevait « L'arrêté est validé pour le client : ses conclusions ne se reprennent plus. ». Étape 2 : la liste porte « Dernier arrêté », « 2023-12-31 », « 2022-12-31 » ; le bandeau porte « Arrete choisi » 2024-12-31, « Cloture visee le » 06/09/2026, « Publie le » 06/09/2026 16:27 : le modèle du client, en import, garde la publication du 06/09/2026. Étape 4 : la liste porte « Dernier arrêté » et « 2022-12-31 », 2024-12-31 n'y figure plus ; le bandeau porte « Arrete choisi » 2023-12-31, « Cloture visee le » 06/09/2026, « Publie le » 06/09/2026 16:27.

```
Limite « Actifs immobiliers, 60 % de l’actif » conclue au 31/12/2024.
```

Passé ☐ · Échec ☐ · Remarque :

#### 6-12. Valoriser l'arrêté rouvert jusqu'à la publication de la valeur liquidative

**Nature :** Parcours métier  
**Besoin :** Reprendre un arrêté rouvert, en valider la valorisation et publier sa valeur liquidative, comme en mission.  
**Profil :** Compte 1 · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Joué après « Rouvrir l'arrêté sur la demande d'un membre de l'équipe » et « Reprendre l'arrêté rouvert ; le client garde sa publication jusqu'à l'actualisation ». OMEGA-OPCI, arrêté du 31/12/2024 ouvert, sans VL publiée ni synthèse visée ; 1 407 990 parts au 31/12/2024. Compte 1 propose la synthèse et publie, Compte 2 vise. Si un lot est généré, Compte 3, collaborateur d'OMEGA-OPCI depuis le test « Le préparateur propose la base, l'associé la renvoie puis la vise », le génère : l'auteur du dernier lot de l'arrêté ne publie pas la VL, et l'auteur d'un lot ne le vise pas.

1. Objectif : publier la valeur liquidative d'OMEGA-OPCI au 31/12/2024, dans l'ordre que vous choisissez.
2. Périmètre : page « Valorisation », arrêté 31/12/2024, ses 5 étapes ; page « Révision », étape 5 « Conclure », si un lot est à viser ; page « Arrêté », étape « 2 Valeur liquidative ».
3. Revoyez les valeurs, faites proposer puis viser la synthèse de l'arrêté, puis cliquez « Publier la VL » avec Compte 1.
4. Notez au fil du parcours chaque arrêt, chaque information manquante et l'heure de début et de fin.

**Ce que vous comparez ou notez :** Le testeur note ce qui l'a arrêté, ce qui lui a manqué et le temps passé. Résultat d'ensemble à atteindre : la publication affiche « Valeur liquidative publiée. » ; dans la grille des valeurs liquidatives de l'étape « 2 Valeur liquidative », la ligne 31/12/2024 porte « État » « publiée », une « VL publiée » égale à la « VL calculée », elle-même égale à « Actif net réévalué » ÷ 1 407 990 à 0,01 près, et « Publiée le » à la date du jour ; l'étape « 2 Valeur liquidative » passe au vert ; la carte d'état de « Publier la VL » porte « VL publiée le <date du jour> ». Si la publication n'aboutit pas, le testeur recopie la carte d'état de « Publier la VL » ou de « Proposer la synthèse » qui l'en empêche.

```
Valeur liquidative publiée.
```

Passé ☐ · Échec ☐ · Constats :

---

## Étape de jeu 7. Le passage d'un espace à l'autre

### Le passage d'un espace à l'autre

#### 7-01. Les comptes de contrôle de la base de TEST sont conformes (3 espaces seulement)

**Besoin :** La base de l'espace où travaillent les utilisateurs porte ses contrôles actifs et un référentiel complet.  
**Profil :** Analyste · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Installation en 3 espaces ; phase jouée dans TEST après les 6 actions de remise en service. Analyste : le compte qui a joué sql/99_terminer_le_chargement.sql sur la base `DossierOPCI` de TEST, ou un compte qui voit comme lui la définition des objets de la base, les 2 premières requêtes lisant sys.triggers et sys.foreign_keys. Noté au classeur : le nombre d'entités, clients et filiales, créées et non supprimées pendant toute la phase, soit 4 par les tests scénarisés du groupe 2 (UAT-OPCI, UAT-SCI-3, UAT-SCI-5, UAT-OPCI-2), plus celles des parcours métier des groupes 2 à 6.

1. Ouvrez une requête sur la base `DossierOPCI` de TEST.
2. Jouez, seules, les 2 requêtes de comptage des lignes 36 à 39 de sql/99_terminer_le_chargement.sql.
3. Jouez, seule, la requête des lignes 42 à 47 du même fichier.

**Vous devez obtenir :** « declencheurs encore suspendus » : 0. « cles etrangeres non verifiees » : 0. La colonne nb égale la colonne attendu pour « questions d'acceptation » (620), « comptes du plan » (201), « articles du reglement » (139), « roles » (4) et « natures de pieces » (10). « entites de demonstration » vaut 16 plus le nombre d'entités créées et non supprimées pendant la phase, la requête comptant toutes les entités de la base.

Passé ☐ · Échec ☐ · Remarque :

#### 7-02. Les boutons de TEST écrivent dans la base de TEST (3 espaces seulement)

**Besoin :** Un clic dans TEST n'écrit jamais dans la base d'un autre espace.  
**Profil :** Analyste · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Installation en 3 espaces. Groupes 2 à 6 joués dans TEST par les comptes 1 et 2, qui n'ont pas travaillé dans DEV pendant la phase ; le cahier n'a jamais été joué dans DEV, dont la base ne porte aucun client UAT-OPCI. Notés au classeur : la date et l'heure UTC du début de la phase, les adresses de connexion des comptes 1 et 2. Analyste : lecture des bases `DossierOPCI` de TEST et de DEV.

1. Sur la base de TEST, jouez : SELECT pour, entite, genre, procedure_nom, pose_le FROM dbo.message_ecran WHERE pour IN (N'<adresse du compte 1>', N'<adresse du compte 2>') AND pose_le >= '<début de la phase, UTC>' ORDER BY pose_le;
2. Jouez la même requête sur la base de DEV.
3. Sur chacune des 2 bases, jouez : SELECT code, denomination, cree_le FROM dbo.ref_entite WHERE code = N'UAT-OPCI';

**Vous devez obtenir :** Base de TEST : des lignes pour chacun des 2 comptes, une par entité sous laquelle un message lui a été posé pendant la phase (code d'un client, cote d'un questionnaire ou « - »), pose_le postérieur au début de la phase, la colonne procedure_nom portant la procédure du dernier bouton cliqué sous cette entité ; une ligne UAT-OPCI, dénomination OPCI UAT, cree_le postérieur au début de la phase. Base de DEV : aucune ligne pour ces 2 adresses depuis le début de la phase, aucune ligne UAT-OPCI. Une ligne trouvée dans DEV désigne un bouton qui appelle encore les fonctions de DEV.

Passé ☐ · Échec ☐ · Remarque :

#### 7-03. Les 2 modèles de TEST lisent la base de TEST (3 espaces seulement)

**Besoin :** Ce que le réviseur et le client lisent dans TEST vient de la base de TEST.  
**Profil :** Analyste · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Installation en 3 espaces. Test « Les boutons de TEST écrivent dans la base de TEST » passé : UAT-OPCI, dénomination OPCI UAT, existe dans la base de TEST et pas dans celle de DEV. Analyste : contributeur de l'espace TEST, rôle auquel la sécurité au niveau des lignes ne s'applique pas (étape 11, lignes 83-84).

1. Dans l'espace TEST, sur la ligne du modèle `restitution_client`, choisissez « Actualiser maintenant » et attendez la fin.
2. Ouvrez le rapport `restitution_client` de TEST, page « La valeur de la part », et ouvrez la liste « Véhicule ».
3. Ouvrez le rapport « Conduite de mission » de TEST, page « Valorisation », et ouvrez la liste « VÉHICULE ».

**Vous devez obtenir :** Étape 2 : la liste porte « OPCI UAT », avec « OPCI OMEGA » et « OPCI SIGMA ». Étape 3 : la liste porte « UAT-OPCI · OPCI UAT ». UAT-OPCI n'existant que dans la base de TEST, sa présence établit que les 2 modèles, et les 2 rapports qui les lisent, sont reliés à la base de TEST.

Passé ☐ · Échec ☐ · Remarque :

#### 7-04. Le rôle de sécurité du client existe dans TEST et porte le compte client (3 espaces seulement)

**Besoin :** Le cloisonnement du client tient dans l'espace où il lit, les affectations aux rôles ne suivant pas le déploiement.  
**Profil :** Analyste · **Criticité d'un échec :** Bloquante  
**Avant de commencer :** Installation en 3 espaces. Analyste : contributeur de l'espace TEST au minimum, pour voir l'option « Security ».

1. Dans l'espace TEST, survolez le modèle `restitution_client`, cliquez sur « More options », puis sur « Security ».
2. Lisez la liste des rôles, puis les membres du rôle « Client OMEGA-OPCI ».
3. Dans le menu « More options » du rôle « Client OMEGA-OPCI », choisissez « Test as role » ; ouvrez la liste « Véhicule » de la page « La valeur de la part ».

**Vous devez obtenir :** Le rôle « Client OMEGA-OPCI » figure dans la liste, et le compte client de la phase en est membre. Sous « Test as role », la liste « Véhicule » porte « OPCI OMEGA » seul.

Passé ☐ · Échec ☐ · Remarque :

#### 7-05. Le dépôt SharePoint de TEST est renseigné (3 espaces seulement)

**Besoin :** Les boutons qui déposent ou provisionnent dans SharePoint trouvent, dans la base de TEST, leurs adresses et leurs clés.  
**Profil :** Analyste · **Criticité d'un échec :** Majeure  
**Avant de commencer :** Installation en 3 espaces. Analyste : le compte qui a posé, dans la base `DossierOPCI` de TEST, la clé principale, les 2 credentials et les 4 paramètres de l'étape 12 (points 7, 8, 10 et 12), ou un compte de même droit sur cette base.

1. Sur la base de TEST, jouez : SELECT code, valeur FROM dbo.ref_parametre WHERE code IN ('ESPACE_CLIENT_URL', 'DEPOT_CLASSEUR_URL', 'SITE_CABINET', 'RACCOURCI_SITE_CABINET');
2. Jouez : SELECT name FROM sys.database_scoped_credentials;

**Vous devez obtenir :** Étape 1 : 4 lignes, chacune avec une valeur ; RACCOURCI_SITE_CABINET vaut fec ; SITE_CABINET a la forme <hôte>.sharepoint.com:/sites/<nom> ; ESPACE_CLIENT_URL et DEPOT_CLASSEUR_URL commencent par https://. Étape 2 : parmi les noms rendus, 2 sont égaux, caractère pour caractère, aux valeurs de ESPACE_CLIENT_URL et de DEPOT_CLASSEUR_URL.

Passé ☐ · Échec ☐ · Remarque :

---

## Ce qu'on écrit à la fin

> Phase passée le **<date>**, dans l'espace **<nom>**, par **<noms>**.
> Tests passés : **<nombre>** sur 180. Tests en échec : **<lesquels>**.
> Décision : **<acceptée, acceptée avec réserves, ou refusée>**, prise par **<nom>**.

**Ne déployez pas en production tant qu'un test Bloquant ou Majeur applicable n'est pas passé.**

---

[Revenir au sommaire](../../README.md) · [Les tests d'acceptation](tests-d-acceptation.md) · [Déployer en trois espaces](deployer-en-trois-espaces.md)
