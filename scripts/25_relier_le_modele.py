# -*- coding: utf-8 -*-
u"""25. Relier le modele semantique a VOTRE base de donnees.

POURQUOI CE SCRIPT EXISTE
    Les tables du modele interrogent la base directement, et chacune porte en clair le nom du
    serveur SQL et le nom de la base. L'editeur l'ecrit dans son tableau des dependances, a la
    ligne « Semantic models vers SQL database » : « No. The connection string in TMDL expressions
    contains workspace-specific values. » Autrement dit : apres la synchronisation Git, VOTRE
    modele interroge encore NOTRE base. Aucun ecran ne s'affichera. Ce script remplace le serveur
    et le nom de la base par les votres, dans toutes les tables d'un coup.

CE QU'IL FAIT, ET RIEN D'AUTRE
    Il remplace deux chaines de caracteres dans les fichiers de tables du modele. Il ne touche ni
    aux mesures, ni aux relations, ni aux formats, et il ne reformate aucun fichier.

COMMENT S'EN SERVIR
    1. Regardez l'etat actuel, sans rien modifier :
         python scripts/25_relier_le_modele.py --verifier
    2. Reliez :
         python scripts/25_relier_le_modele.py --serveur xxxx-yyyy.database.fabric.microsoft.com \
                                               --base DossierOPCI-<identifiant de votre base>
       Ou, plus court, si votre base porte le nom DossierOPCI :
         python scripts/25_relier_le_modele.py --serveur xxxx-yyyy.database.fabric.microsoft.com \
                                               --identifiant-base <identifiant de votre base>
    3. Relisez pour confirmer :
         python scripts/25_relier_le_modele.py --verifier

OU TROUVER CES DEUX VALEURS
    Dans votre espace de travail, ouvrez la base DossierOPCI. Dans le bandeau, choisissez
    « Parametres », puis « Chaines de connexion ». Le serveur y est ecrit en entier, et le nom de
    la base est celui qui suit : il porte l'identifiant de l'element, ce qui est normal.
    Ne recopiez pas le nom affiche dans la liste des elements : ce n'est pas le nom de la base.

CE QU'IL REFUSE DE FAIRE
    Il n'ecrit pas si une table porte une source inconnue, c'est-a-dire ni celle d'origine ni la
    votre. Le script s'arrete alors en nommant la table en cause.
"""
from __future__ import print_function
import argparse
import io
import os
import re
import sys

# La source portee par le depot a sa publication. Elle n'a aucune valeur chez vous : elle sert de
# point de repere au script, pour reconnaitre une table qui n'a pas encore ete reliee.
SERVEUR_ORIGINE = "ra6uvi3ttf5e5kzvtpixiyxumu-5pgdmplbuqqu5iuftzacs77jay.database.fabric.microsoft.com"
BASE_ORIGINE = "DossierOPCI-fd9080bb-e3ae-4aab-bf09-edbfcc8606d1"

# LES DEUX MODELES SE RELIENT, PAS SEULEMENT CELUI DU REVISEUR.
# Ne relier que la conduite de mission laissait le modele du client sur la base d'origine, et
# l'ecran de restitution restait vide sans qu'aucun message ne le dise. Trouve par une
# installation reelle le 26/09/2026, en lisant la source que le portail affiche.
MODELES = [
    os.path.join("fabric", "conduite_de_mission.SemanticModel"),
    os.path.join("fabric", "restitution_client.SemanticModel"),
]

GUID = re.compile(r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")
SERVEUR = re.compile(r"^[0-9a-z\-]+\.database\.fabric\.microsoft\.com$", re.I)
# Sql.Database("<serveur>", "<base>")
SOURCE = re.compile(r'Sql\.Database\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*\)')


def racine_du_depot():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def fichiers_a_examiner(racine):
    u"""Les fichiers ou une source de donnees peut se trouver, dans les 2 modeles.

    LA SOURCE N'EST PAS TOUJOURS DANS UNE TABLE. Le modele du client la declare une seule fois,
    dans definition/expressions.tmdl, et ses tables s'y referent. Ne lire que le dossier tables/
    n'y trouvait aucune source, et le script croyait n'avoir rien a relier.
    """
    trouves = []
    for modele in MODELES:
        trouves += fichiers_de_tables(racine, modele)
        expressions = os.path.join(racine, modele, "definition", "expressions.tmdl")
        if os.path.isfile(expressions):
            trouves.append(expressions)
    return trouves


def fichiers_de_tables(racine, modele):
    base = os.path.join(racine, modele, "definition", "tables")
    if not os.path.isdir(base):
        raise SystemExit(
            u"Le modele est introuvable : %s\n"
            u"Verifiez que vous lancez ce script depuis le depot, et que la synchronisation Git\n"
            u"a bien ramene le dossier fabric/." % base)
    return [os.path.join(base, n) for n in sorted(os.listdir(base)) if n.endswith(".tmdl")]


def sources_du_fichier(chemin):
    u"""Les couples (serveur, base) declares par les partitions de cette table."""
    with io.open(chemin, encoding="utf-8") as f:
        texte = f.read()
    return SOURCE.findall(texte)


def etat(couple, serveur_cible, base_cible):
    serveur, base = couple
    if serveur == SERVEUR_ORIGINE and base == BASE_ORIGINE:
        return "a_relier"
    if serveur_cible and serveur == serveur_cible and base == base_cible:
        return "deja_relie"
    if not serveur_cible and serveur != SERVEUR_ORIGINE:
        return "deja_relie"
    return "inconnu"


def verifier(racine, serveur_cible=None, base_cible=None):
    compte = {"a_relier": [], "deja_relie": [], "inconnu": []}
    for chemin in fichiers_a_examiner(racine):
        for couple in sources_du_fichier(chemin):
            compte[etat(couple, serveur_cible, base_cible)].append((chemin, couple))
    return compte


def relier(racine, serveur_cible, base_cible):
    compte = verifier(racine, serveur_cible, base_cible)

    if compte["inconnu"]:
        print(u"ARRET. %d table(s) portent une source que je ne reconnais pas."
              % len(compte["inconnu"]))
        for chemin, couple in compte["inconnu"]:
            print(u"   %s" % os.path.relpath(chemin, racine))
            print(u"      serveur lu : %s" % couple[0])
            print(u"      base lue   : %s" % couple[1])
        print(u"\nCe modele a ete modifie a la main. Je n'ecris pas, pour ne pas le casser.")
        print(u"Reprenez une copie propre du depot, puis relancez ce script.")
        return 2

    if not compte["a_relier"]:
        print(u"Rien a faire : les %d sources sont deja reliees a votre base."
              % len(compte["deja_relie"]))
        return 0

    fichiers = sorted(set(chemin for chemin, _ in compte["a_relier"]))
    ecrits = 0
    for chemin in fichiers:
        with io.open(chemin, encoding="utf-8") as f:
            texte = f.read()
        avant = texte
        texte = texte.replace(SERVEUR_ORIGINE, serveur_cible)
        texte = texte.replace(BASE_ORIGINE, base_cible)
        if texte != avant:
            with io.open(chemin, "w", encoding="utf-8", newline="") as f:
                f.write(texte)
            ecrits += 1

    apres = verifier(racine, serveur_cible, base_cible)
    print(u"%d table(s) reecrite(s)." % ecrits)
    print(u"%d source(s) reliees a votre base." % len(apres["deja_relie"]))
    if apres["a_relier"] or apres["inconnu"]:
        print(u"ATTENTION : %d source(s) n'ont pas ete reliees. Relancez avec --verifier."
              % (len(apres["a_relier"]) + len(apres["inconnu"])))
        return 1
    print(u"\nProchaine etape : republiez les 2 modeles, ouvrez-les dans votre espace de travail")
    print(u"et verifiez qu'il s'actualise sans erreur. Ensuite seulement, reliez les boutons")
    print(u"(scripts/20_relier_les_boutons.py).")
    return 0


def afficher(compte):
    total = sum(len(v) for v in compte.values())
    print(u"%d source(s) de donnees dans les 2 modeles." % total)
    print(u"   deja reliees a votre base : %d" % len(compte["deja_relie"]))
    print(u"   restant a relier          : %d" % len(compte["a_relier"]))
    print(u"   sources inconnues         : %d" % len(compte["inconnu"]))
    if compte["a_relier"]:
        print(u"\nSource portee par ces tables :")
        serveur, base = compte["a_relier"][0][1]
        print(u"   serveur : %s" % serveur)
        print(u"   base    : %s" % base)
    return 0 if not compte["a_relier"] and not compte["inconnu"] else 1


def main():
    a = argparse.ArgumentParser(
        description=u"Relie le modele semantique a votre base de donnees.")
    a.add_argument("--serveur", help=u"le serveur SQL de VOTRE base, en entier")
    a.add_argument("--base", help=u"le nom complet de VOTRE base, identifiant compris")
    a.add_argument("--identifiant-base", dest="identifiant",
                   help=u"a la place de --base, si votre base s'appelle DossierOPCI")
    a.add_argument("--verifier", action="store_true",
                   help=u"n'ecrit rien, dit seulement ou en sont les tables")
    args = a.parse_args()

    racine = racine_du_depot()
    base = args.base or (u"DossierOPCI-%s" % args.identifiant if args.identifiant else None)

    if args.verifier:
        return afficher(verifier(racine, args.serveur, base))

    if not args.serveur or not base:
        a.error(u"il faut --serveur et (--base ou --identifiant-base), ou bien --verifier")
    if not SERVEUR.match(args.serveur):
        a.error(u"--serveur ne ressemble pas a un serveur SQL Fabric : %s\n"
                u"Il se termine par .database.fabric.microsoft.com" % args.serveur)
    if args.serveur.lower() == SERVEUR_ORIGINE:
        a.error(u"--serveur est celui d'origine du depot, pas le votre.")
    if args.identifiant and not GUID.match(args.identifiant):
        a.error(u"--identifiant-base ne ressemble pas a un identifiant Fabric : %s" % args.identifiant)

    return relier(racine, args.serveur.lower(), base)


if __name__ == "__main__":
    sys.exit(main())
