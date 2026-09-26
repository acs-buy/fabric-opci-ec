---
name: Un problème pendant l'installation
about: Une étape du mode opératoire qui ne donne pas le résultat annoncé
title: "[Étape N] "
labels: installation
---

## À quelle étape

<!-- Le numéro de l'étape, de 1 à 12. -->

## Ce que vous attendiez

<!-- La vérification annoncée à la fin de l'étape. -->

## Ce que vous obtenez

<!-- Le message exact, recopié et non reformulé. Si c'est une capture, recouvrez le nom de votre
     cabinet et votre identité de connexion avant de l'envoyer. -->

## Votre installation

- Taille de capacité, F4, F64 ou autre :
- Essai gratuit ou capacité achetée :
- Les cinq réglages de locataire sont activés : oui / non / je ne sais pas
- Votre région :

## Ce que vous avez déjà essayé

<!-- La page de dépannage donne la cause réelle de la plupart des symptômes.
     docs/faire/depannage.md -->

## Les deux vérifications qui règlent la moitié des cas

Lancez-les et collez le résultat, cela fait souvent gagner un aller-retour.

```
python scripts/20_relier_les_boutons.py --verifier
python scripts/25_relier_le_modele.py --verifier
```
