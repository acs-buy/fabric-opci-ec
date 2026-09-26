# Étapes 9 et 10, avec un agent : relier la solution à votre espace

**C'est l'étape qui décide si la solution fonctionne, et celle dont les pannes sont les plus opaques.** Un
bouton mal relié ne dit rien : il ne fait rien. Un modèle mal relié interroge une base qui n'est pas
la vôtre.

Un agent y sert bien, parce que le travail consiste à reporter cinq identifiants sans en fausser
un seul caractère.

---

## Avant de le lancer

Relevez vos cinq valeurs. Un script du dépôt les demande une par une et vérifie leur forme au
passage, sans se connecter à quoi que ce soit :

```
python scripts/00_mes_identifiants.py
```

Il écrit les deux commandes complètes, avec vos valeurs, dans `mes_commandes.txt`.

---

## La demande à coller, en deux temps

**Le premier temps ne modifie rien.** Il sert à voir d'où vous partez.

> Lance ces deux commandes, et recopie-moi leurs sorties complètes sans les résumer :
>
> ```
> python scripts/25_relier_le_modele.py --verifier
> python scripts/20_relier_les_boutons.py --verifier
> ```
>
> Puis arrête-toi et attends ma réponse. Ne modifie aucun fichier.

**Vous lisez, et vous décidez.** Ensuite seulement :

> Maintenant relie, dans cet ordre, le modèle d'abord, les boutons ensuite :
>
> ```
> python scripts/25_relier_le_modele.py --serveur <le vôtre> --base <la vôtre>
> python scripts/20_relier_les_boutons.py --espace <le vôtre> --fn-ecran-client <le vôtre> --fn-ecran-revision <le vôtre>
> ```
>
> Relance ensuite les deux commandes `--verifier`, et montre-moi les quatre sorties.
>
> Trois règles :
> - ne modifie aucun autre fichier que ceux que les scripts modifient eux-mêmes ;
> - si un script refuse d'écrire, ne cherche pas à lever ce refus : rapporte-le-moi tel quel ;
> - ne corrige aucun script.

---

## Ce que vous vérifiez vous-même

**Avant la réparation**, les deux scripts doivent annoncer un nombre de sources et de boutons
« restant à relier », et **zéro identifiant inconnu**.

**Après la réparation**, les quatre lignes qui décident :

```
restant a relier          : 0
sources inconnues         : 0
restant a relier          : 0
identifiants inconnus     : 0
```

**Le nombre total de sources et de boutons n'est pas un chiffre à comparer à une valeur écrite
ici.** Il augmente à chaque écran ajouté à la solution. Ce qui compte est qu'il soit identique
avant et après, et que le restant tombe à zéro.

Si « identifiants inconnus » n'est pas zéro, les scripts refusent d'écrire.
Cela veut dire qu'un fichier du dépôt a été modifié à la main quelque part. Reprenez une copie
propre du dépôt plutôt que de forcer.

---

## Puis deux actions au portail, que l'agent ne peut pas faire

Elles ne produisent aucun message d'erreur. Sans elles, vos écrans restent vides.

1. **Saisir les informations d'identification des deux modèles**, en OAuth2. Paramètres du modèle,
   section **Data source credentials**, puis **Edit credentials**.
2. **Actualiser le modèle `restitution_client`**, qui garde une copie des données, contrairement à
   l'autre.

Le détail est aux [étapes 9 et 10 du mode opératoire](../docs/faire/etape-09-et-10-relier.md).

---

## La liaison qui se refait seule

Le rapport retrouve son modèle de données seul, parce qu'il le désigne par un chemin relatif.
**La condition : ne renommez aucun élément.** Un renommage casse cette liaison, et le message
d'erreur ne désigne pas le renommage.

Dites-le à l'agent si vous lui confiez autre chose : un agent qui range volontiers renomme aussi
volontiers.

---

Suite : [Étape 12. La recette : douze actions qui prouvent que la solution marche](../docs/faire/etape-12-passer-la-recette.md)

[Les demandes à coller](README.md) · [L'avertissement](AVERTISSEMENT.md)
