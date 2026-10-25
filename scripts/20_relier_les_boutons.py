# -*- coding: utf-8 -*-
u"""20. Relier les boutons du rapport aux fonctions de VOTRE espace de travail.

POURQUOI CE SCRIPT EXISTE
    Chaque bouton qui ecrit en base porte, en clair dans sa definition, l'identifiant de l'espace
    de travail et celui de l'element de fonctions qu'il appelle. L'editeur l'ecrit ainsi :
    « Data function buttons don't automatically rebind across workspaces. The button stores an
    explicit reference to a specific Workspace, Function set, and Data function. »
    Autrement dit : apres la synchronisation Git, VOS boutons appellent encore NOTRE espace de
    travail. Ils ne marcheront pas. Ce script remplace ces identifiants par les votres.

    LE RAPPORT APPELLE PLUSIEURS ENSEMBLES DE FONCTIONS, listes dans FONCTIONS_ORIGINE ci-dessous.
    Il faut donner l'identifiant de chacun : un bouton dont l'ensemble n'est pas relie reste sans
    effet.

CE QU'IL FAIT, ET RIEN D'AUTRE
    Il remplace des identifiants dans les fichiers du rapport : celui de l'espace de travail et
    celui de chaque ensemble de fonctions. Il ne touche ni aux visuels, ni aux mesures, ni a la mise
    en page, et il ne reformate aucun fichier : il substitue le texte des identifiants, ligne par
    ligne, et laisse le reste intact.

COMMENT S'EN SERVIR
    1. Regardez l'etat actuel, sans rien modifier :
         python scripts/20_relier_les_boutons.py --verifier
    2. Reliez, en donnant l'identifiant de votre espace et celui de chaque ensemble de fonctions :
         python scripts/20_relier_les_boutons.py --espace <votre espace>
              --fn-ecran-client <votre fn_ecran_client>
              --fn-ecran-revision <votre fn_ecran_revision>
              --fn-ecran-valorisation <votre fn_ecran_valorisation>
              --fn-ecran-arrete <votre fn_ecran_arrete>
              --fn-documents <votre fn_documents>
              --fn-valorisation <votre fn_valorisation>
    3. Relisez pour confirmer :
         python scripts/20_relier_les_boutons.py --verifier

OU TROUVER LES IDENTIFIANTS
    Ouvrez votre espace de travail dans le navigateur. L'adresse ressemble a
        https://app.fabric.microsoft.com/groups/AAAAAAAA-.../list
    La partie apres /groups/ est l'identifiant de l'espace de travail.
    Ouvrez ensuite chaque ensemble de fonctions. L'adresse d'un element porte DEUX identifiants :
    celui de l'espace d'abord, celui de l'element ensuite. C'est le second.
    Le script 00_mes_identifiants.py les releve pour vous et prepare la commande complete.

CE QU'IL REFUSE DE FAIRE
    Il n'ecrit pas si un bouton porte des identifiants inconnus, c'est-a-dire ni ceux d'origine ni
    les votres. Ce cas signale un rapport deja modifie a la main, et une ecriture aveugle le
    casserait. Le script s'arrete alors en nommant le fichier en cause.
    Il n'ecrit pas non plus si deux ensembles de fonctions recoivent le meme identifiant : leurs
    boutons appelleraient le meme element, et les fonctions de l'un y seraient introuvables.
"""
from __future__ import print_function
import argparse
import io
import json
import os
import re
import sys

# Les identifiants portes par le depot a sa publication. Ce sont ceux de l'espace de travail ou la
# solution a ete construite. Ils n'ont aucune valeur chez vous : ils servent de point de repere au
# script, pour reconnaitre un bouton qui n'a pas encore ete relie.
ESPACE_ORIGINE = "3d36cceb-a461-4e21-a285-9e40297fe906"

# LE RAPPORT APPELLE PLUSIEURS ENSEMBLES DE FONCTIONS, ET NON UN SEUL.
#   fn_ecran_client        l'ecran Client et Acceptation, et la page Piece justificative
#   fn_ecran_revision      l'ecran Revision et ses pages
#   fn_ecran_valorisation  l'ecran Valorisation
#   fn_ecran_arrete        l'ecran Arrete
#   fn_documents           les boutons qui produisent un document, aux pages de l'ecran Revision
#   fn_valorisation        la generation du lot de valorisation, a l'ecran Valorisation
# Un script qui en oublierait un laisserait les boutons de cet ensemble sans effet. Le compte de
# boutons par ensemble se lit par --verifier : il change quand un ecran change.
FONCTIONS_ORIGINE = {
    "d0b84751-7930-42d2-9e45-af8459070427": "fn_ecran_client",
    "379b2bbf-3dd3-49d4-8a0c-fbde1ed3d848": "fn_ecran_revision",
    "abf170ed-d12d-4587-b2d1-e12a58483fc9": "fn_ecran_valorisation",
    "2ce1e8e3-7775-4b7a-9365-e935a11499cb": "fn_ecran_arrete",
    "01b1f037-0147-4046-9106-bd80d60c1310": "fn_documents",
    "92f02959-0474-46b0-ba45-1ae7a7c9c0e5": "fn_valorisation",
}

# Le rapport a relier, relativement a la racine du depot.
RAPPORT = os.path.join("fabric", "Conduite de mission.Report")

GUID = re.compile(r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")


def option(nom):
    u"""L'option de la ligne de commande d'un ensemble : fn_ecran_client donne --fn-ecran-client."""
    return "--" + nom.replace("_", "-")


def racine_du_depot():
    u"""La racine du depot, deduite de l'emplacement de ce script."""
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def fichiers_de_visuels(racine):
    u"""Tous les fichiers de definition de visuel du rapport."""
    base = os.path.join(racine, RAPPORT, "definition", "pages")
    if not os.path.isdir(base):
        raise SystemExit(
            u"Le rapport est introuvable : %s\n"
            u"Verifiez que vous lancez ce script depuis le depot, et que la synchronisation Git\n"
            u"a bien ramene le dossier fabric/." % base)
    trouves = []
    for page in sorted(os.listdir(base)):
        dossier = os.path.join(base, page, "visuals")
        if not os.path.isdir(dossier):
            continue
        for visuel in sorted(os.listdir(dossier)):
            chemin = os.path.join(dossier, visuel, "visual.json")
            if os.path.isfile(chemin):
                trouves.append(chemin)
    return trouves


def liaisons_du_fichier(chemin):
    u"""Les couples (espace, fonctions) portes par les boutons de fonction de ce fichier.

    Le fichier est lu en JSON pour comprendre sa structure, jamais reecrit par cette voie :
    un dump JSON reformaterait tout le fichier et polluerait la comparaison avec Git.
    """
    with io.open(chemin, encoding="utf-8") as f:
        contenu = json.load(f)
    liens = contenu.get("visual", {}).get("visualContainerObjects", {}).get("visualLink", [])
    couples = []
    for lien in liens:
        fonction = lien.get("properties", {}).get("dataFunction")
        if not fonction:
            continue
        reference = fonction.get("byReference", {})

        def valeur(cle):
            return reference.get(cle, {}).get("expr", {}).get("Literal", {}).get("Value")

        nom = fonction.get("metadata", {}).get("dataFunction", {}).get("name")
        # Les valeurs sont ecrites entre apostrophes dans le fichier : 'xxxxxxxx-...'
        couples.append({
            "espace": (valeur("workspaceId") or "").strip("'"),
            "fonctions": (valeur("itemId") or "").strip("'"),
            "nom": nom,
        })
    return couples


def etat(couple, espace_cible, cibles):
    u"""Dit ou en est un bouton : a relier, deja relie, ou inconnu.

    cibles associe chaque identifiant d'origine a celui du lecteur, ou None si inconnu.
    """
    if couple["espace"] == ESPACE_ORIGINE and couple["fonctions"] in FONCTIONS_ORIGINE:
        return "a_relier"
    if espace_cible and couple["espace"] == espace_cible and couple["fonctions"] in (cibles or {}).values():
        return "deja_relie"
    if not espace_cible and couple["espace"] != ESPACE_ORIGINE:
        return "deja_relie"
    return "inconnu"


def verifier(racine, espace_cible=None, cibles=None):
    u"""Parcourt le rapport et rend le compte des boutons, sans rien modifier."""
    compte = {"a_relier": [], "deja_relie": [], "inconnu": []}
    for chemin in fichiers_de_visuels(racine):
        for couple in liaisons_du_fichier(chemin):
            compte[etat(couple, espace_cible, cibles)].append((chemin, couple))
    return compte


def relier(racine, espace_cible, cibles):
    u"""Remplace les identifiants dans tous les boutons qui portent encore ceux d'origine."""
    compte = verifier(racine, espace_cible, cibles)

    if compte["inconnu"]:
        print(u"ARRET. %d bouton(s) portent des identifiants que je ne reconnais pas."
              % len(compte["inconnu"]))
        for chemin, couple in compte["inconnu"]:
            print(u"   %s" % os.path.relpath(chemin, racine))
            print(u"      espace lu    : %s" % couple["espace"])
            print(u"      fonctions lu : %s" % couple["fonctions"])
        print(u"\nCe rapport a ete modifie a la main. Je n'ecris pas, pour ne pas le casser.")
        print(u"Reprenez une copie propre du depot, puis relancez ce script.")
        return 2

    if not compte["a_relier"]:
        print(u"Rien a faire : les %d boutons sont deja relies a votre espace de travail."
              % len(compte["deja_relie"]))
        return 0

    # La substitution se fait sur le TEXTE du fichier, afin de ne reformater aucune autre ligne.
    fichiers = sorted(set(chemin for chemin, _ in compte["a_relier"]))
    ecrits = 0
    for chemin in fichiers:
        with io.open(chemin, encoding="utf-8") as f:
            texte = f.read()
        avant = texte
        texte = texte.replace(ESPACE_ORIGINE, espace_cible)
        for origine, cible in cibles.items():
            texte = texte.replace(origine, cible)
        if texte != avant:
            with io.open(chemin, "w", encoding="utf-8", newline="") as f:
                f.write(texte)
            ecrits += 1

    # On relit, pour dire ce qui est vrai et non ce qui etait prevu.
    apres = verifier(racine, espace_cible, cibles)
    print(u"%d fichier(s) de bouton reecrit(s)." % ecrits)
    print(u"%d bouton(s) relies a votre espace de travail." % len(apres["deja_relie"]))
    if apres["a_relier"] or apres["inconnu"]:
        print(u"ATTENTION : %d bouton(s) n'ont pas ete relies. Relancez avec --verifier."
              % (len(apres["a_relier"]) + len(apres["inconnu"])))
        return 1
    print(u"\nProchaine etape : republiez le rapport dans votre espace de travail, puis passez")
    print(u"la recette (scripts/30_recette.py).")
    return 0


def afficher(compte):
    total = sum(len(v) for v in compte.values())
    print(u"%d bouton(s) de fonction dans le rapport." % total)
    print(u"   deja relies a votre espace : %d" % len(compte["deja_relie"]))
    print(u"   restant a relier           : %d" % len(compte["a_relier"]))
    print(u"   identifiants inconnus      : %d" % len(compte["inconnu"]))
    if compte["a_relier"]:
        par_element = {}
        for _, c in compte["a_relier"]:
            par_element.setdefault(FONCTIONS_ORIGINE.get(c["fonctions"], c["fonctions"]), set())
            if c["nom"]:
                par_element[FONCTIONS_ORIGINE.get(c["fonctions"], c["fonctions"])].add(c["nom"])
        print(u"")
        for element in sorted(par_element):
            noms = sorted(par_element[element])
            print(u"%s, %d fonction(s) appelee(s) :" % (element, len(noms)))
            for nom in noms:
                print(u"   %s" % nom)
    return 0 if not compte["a_relier"] and not compte["inconnu"] else 1


def main():
    a = argparse.ArgumentParser(
        description=u"Relie les boutons du rapport aux fonctions de votre espace de travail.")
    a.add_argument("--espace", help=u"identifiant de VOTRE espace de travail")
    # Une option par ensemble de fonctions, dans l'ordre de FONCTIONS_ORIGINE.
    for nom in FONCTIONS_ORIGINE.values():
        a.add_argument(option(nom), dest=nom, help=u"identifiant de VOTRE element %s" % nom)
    a.add_argument("--verifier", action="store_true",
                   help=u"n'ecrit rien, dit seulement ou en sont les boutons")
    args = a.parse_args()

    racine = racine_du_depot()
    cibles = {}
    for origine, nom in FONCTIONS_ORIGINE.items():
        valeur = getattr(args, nom)
        if valeur:
            cibles[origine] = valeur.lower()

    if args.verifier:
        return afficher(verifier(racine, args.espace and args.espace.lower(), cibles))

    if not args.espace or len(cibles) != len(FONCTIONS_ORIGINE):
        a.error(u"il faut --espace et %s, ou bien --verifier"
                % u", ".join(option(nom) for nom in FONCTIONS_ORIGINE.values()))
    valeurs = [(u"--espace", args.espace)] + [
        (option(FONCTIONS_ORIGINE[origine]), valeur) for origine, valeur in cibles.items()]
    for nom, valeur in valeurs:
        if not GUID.match(valeur):
            a.error(u"%s ne ressemble pas a un identifiant Fabric : %s" % (nom, valeur))
    espace = args.espace.lower()
    if espace == ESPACE_ORIGINE:
        a.error(u"--espace est l'identifiant d'origine du depot, pas le votre.")
    if set(cibles.values()) & set(FONCTIONS_ORIGINE):
        a.error(u"un identifiant de fonctions est celui d'origine du depot, pas le votre.")
    if espace in cibles.values():
        a.error(u"un identifiant de fonctions est celui de votre espace de travail. Ouvrez l'ensemble "
                u"de fonctions lui-meme, et prenez le second identifiant de son adresse.")
    if len(set(cibles.values())) < len(cibles):
        a.error(u"deux ensembles de fonctions ont recu le meme identifiant. Chaque ensemble a le sien : "
                u"ouvrez-les un par un et copiez l'adresse de chacun.")

    return relier(racine, espace, cibles)


if __name__ == "__main__":
    sys.exit(main())
