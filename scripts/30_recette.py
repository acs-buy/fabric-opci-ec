# -*- coding: utf-8 -*-
u"""30. Verifier l'installation, et preparer la recette des douze actions.

CE QU'IL VERIFIE TOUT SEUL
    Les deux liaisons de l'etape 6, en relisant les fichiers du depot. C'est la panne la plus
    frequente et la plus difficile a diagnostiquer a l'ecran, puisqu'un bouton mal relie ne dit
    rien : il ne fait rien.

CE QU'IL NE PEUT PAS VERIFIER SEUL, ET POURQUOI
    Le contenu de votre base et le comportement de vos boutons. Le premier demanderait vos
    identifiants de connexion, le second un pilotage du navigateur. Ce script vous donne donc la
    requete a jouer et la liste des actions a faire, plutot que de vous promettre une verification
    qu'il ne ferait pas.

USAGE
    python scripts/30_recette.py            verifie les liaisons et affiche la suite
    python scripts/30_recette.py --donnees  affiche seulement la requete de controle des donnees
"""
from __future__ import print_function
import argparse
import os
import subprocess
import sys

RACINE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

REQUETE = u"""SELECT 'questions d''acceptation' AS quoi, COUNT(*) AS nb, 620 AS attendu FROM dbo.ref_question
UNION ALL SELECT 'comptes du plan',        COUNT(*), 200 FROM dbo.ref_compte
UNION ALL SELECT 'articles du reglement',  COUNT(*), 111 FROM dbo.ref_article
UNION ALL SELECT 'roles',                  COUNT(*),   4 FROM dbo.ref_role
UNION ALL SELECT 'natures de pieces',      COUNT(*),  10 FROM dbo.ref_nature_piece
UNION ALL SELECT 'entites de demonstration', COUNT(*), 16 FROM dbo.ref_entite;"""

ACTIONS = [
    u"Creer un dossier client, et voir son questionnaire s'ouvrir seul",
    u"Modifier les informations du client, un champ vide restant inchange",
    u"Enregistrer le site du client, et le voir cliquable dans la fiche",
    u"Ajouter une filiale au perimetre",
    u"Modifier une filiale, et la retrouver au journal du perimetre",
    u"Supprimer une filiale, avec refus motive si elle porte des donnees",
    u"Repondre a une question, enregistree au clic",
    u"Deposer une piece, avec sa nature, sa date et son deposant",
    u"Retirer une piece, motif obligatoire",
    u"Soumettre le dossier au visa",
    u"Approuver le visa AVEC UN SECOND COMPTE, refuse au premier",
    u"Ouvrir un arrete planifie",
]


def verifier(script):
    u"""Lance un script de liaison en mode verification et rend sa sortie."""
    chemin = os.path.join(RACINE, "scripts", script)
    if not os.path.isfile(chemin):
        return None, u"script introuvable : %s" % script
    p = subprocess.run([sys.executable, chemin, "--verifier"],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return p.returncode, p.stdout.decode("utf-8", "replace").strip()


def main():
    a = argparse.ArgumentParser(description=u"Verifie l'installation.")
    a.add_argument("--donnees", action="store_true",
                   help=u"affiche seulement la requete de controle des donnees")
    args = a.parse_args()

    if args.donnees:
        print(u"Jouez cette requete dans votre base, onglet Nouvelle requete :")
        print(u"")
        print(REQUETE)
        return 0

    print(u"=" * 78)
    print(u"1. LES LIAISONS")
    print(u"=" * 78)
    bon = True
    for script, quoi in ((u"25_relier_le_modele.py", u"le modele vers votre base"),
                         (u"20_relier_les_boutons.py", u"les boutons vers vos fonctions")):
        print(u"")
        print(u"%s :" % quoi)
        code, sortie = verifier(script)
        for ligne in (sortie or u"").splitlines():
            print(u"   %s" % ligne)
        if code != 0:
            bon = False

    print(u"")
    print(u"=" * 78)
    print(u"2. LES DONNEES")
    print(u"=" * 78)
    print(u"Jouez cette requete dans votre base, et comparez les colonnes nb et attendu :")
    print(u"")
    print(REQUETE)

    print(u"")
    print(u"=" * 78)
    print(u"3. LES DOUZE ACTIONS, a faire a l'ecran")
    print(u"=" * 78)
    for i, g in enumerate(ACTIONS, start=1):
        print(u"   %2d. %s" % (i, g))
    print(u"")
    print(u"L'action 11 demande deux comptes : l'approbation est refusee a qui a soumis.")
    print(u"Le detail de chaque action est dans docs/08-recette.md.")

    print(u"")
    if bon:
        print(u"Les liaisons sont faites. Passez aux donnees, puis aux douze actions.")
        return 0
    print(u"ATTENTION : au moins une liaison n'est pas faite. Reprenez docs/06-relier.md.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
