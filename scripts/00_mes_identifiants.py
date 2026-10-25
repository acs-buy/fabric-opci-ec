# -*- coding: utf-8 -*-
u"""00. Relever vos identifiants, et preparer les commandes a lancer.

POURQUOI CE SCRIPT EXISTE
    Les deux scripts qui relient la solution a votre espace de travail ont besoin de l'identifiant
    de votre espace, de celui de chaque ensemble de fonctions, du serveur SQL et du nom complet de
    votre base. Les identifiants se ressemblent tous, et le nom affiche d'une base n'est pas le nom
    de la base. Ce script vous les fait coller, verifie leur forme, et vous rend les deux commandes
    completes.

    Il ne se connecte a rien et ne demande aucun mot de passe. Il lit ce que vous collez.

COMMENT S'EN SERVIR
    python scripts/00_mes_identifiants.py
    Puis laissez-vous guider. A la fin, copiez les deux commandes affichees.
"""
from __future__ import print_function
import io
import os
import re
import sys

GUID = re.compile(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}")
SERVEUR = re.compile(r"[0-9a-z\-]+\.database\.fabric\.microsoft\.com", re.I)

# Les ensembles de fonctions que le rapport appelle, dans l'ordre de FONCTIONS_ORIGINE de
# 20_relier_les_boutons.py, avec l'endroit ou se trouvent leurs boutons.
ENSEMBLES = [
    (u"fn_ecran_client", u"l'ecran Client et Acceptation, et la page Piece justificative"),
    (u"fn_ecran_revision", u"l'ecran Revision et ses pages"),
    (u"fn_ecran_valorisation", u"l'ecran Valorisation"),
    (u"fn_ecran_arrete", u"l'ecran Arrete"),
    (u"fn_documents", u"la production des documents, aux pages de l'ecran Revision"),
    (u"fn_valorisation", u"la generation du lot de valorisation, a l'ecran Valorisation"),
]

try:
    saisir = raw_input  # Python 2
except NameError:
    saisir = input


def demander(question, aide, extraire):
    u"""Pose une question jusqu'a obtenir une reponse dont la forme est juste."""
    print(u"")
    print(question)
    for ligne in aide:
        print(u"   %s" % ligne)
    while True:
        reponse = saisir(u"> ").strip()
        if not reponse:
            print(u"   (rien n'a ete colle, on recommence)")
            continue
        if reponse.lower() in ("q", "quit", "quitter"):
            raise SystemExit(u"Abandon.")
        trouve = extraire(reponse)
        if trouve:
            print(u"   retenu : %s" % trouve)
            return trouve
        print(u"   Je ne reconnais pas cette valeur. Recollez la ligne entiere, sans la couper.")


def premier_guid(texte):
    u"""Le premier identifiant de la ligne. Dans l'adresse d'un espace de travail, c'est le sien."""
    t = GUID.search(texte)
    return t.group(0).lower() if t else None


def dernier_guid(texte):
    u"""Le dernier identifiant de la ligne.

    L'adresse d'un element porte DEUX identifiants : celui de l'espace de travail d'abord, puis
    celui de l'element. Prendre le premier rendrait l'espace de travail a la place de l'element,
    et les boutons appelleraient un element qui n'existe pas. Releve sur un essai le 25/09/2026.
    """
    t = GUID.findall(texte)
    return t[-1].lower() if t else None


def premier_serveur(texte):
    t = SERVEUR.search(texte)
    return t.group(0).lower() if t else None


def nom_de_base(texte):
    u"""Le nom complet de la base. Il porte l'identifiant de l'element, ce qui est normal."""
    texte = texte.strip().strip('"').strip("'")
    # Si la personne colle la chaine de connexion entiere, on en extrait le nom de base.
    m = re.search(r"(?:Initial Catalog|Database)\s*=\s*([^;]+)", texte, re.I)
    if m:
        texte = m.group(1).strip()
    return texte if GUID.search(texte) else None


def main():
    nombre = 1 + len(ENSEMBLES) + 2
    print(u"=" * 78)
    print(u"Relevons les %d valeurs dont la solution a besoin pour marcher chez vous." % nombre)
    print(u"Tapez q a tout moment pour abandonner.")
    print(u"=" * 78)

    espace = demander(
        u"1. L'adresse de VOTRE espace de travail.",
        [u"Ouvrez votre espace de travail dans le navigateur.",
         u"Copiez l'adresse entiere de la barre du haut, et collez-la ici.",
         u"Elle ressemble a https://app.fabric.microsoft.com/groups/xxxx-xxxx/list"],
        premier_guid)

    # Le rapport appelle plusieurs ensembles de fonctions : une adresse par ensemble.
    fonctions = []
    for rang, (nom, boutons) in enumerate(ENSEMBLES, start=2):
        fonctions.append((nom, demander(
            u"%d. L'adresse de VOTRE element %s." % (rang, nom),
            [u"Dans votre espace de travail, ouvrez %s." % nom,
             u"Copiez l'adresse entiere et collez-la ici.",
             u"L'adresse porte deux identifiants : je retiens le second, qui est l'element.",
             u"Ses boutons : %s." % boutons],
            dernier_guid)))

    print(u"")
    print(u"Pour les deux valeurs suivantes : dans votre espace de travail, ouvrez la base")
    print(u"DossierOPCI, puis le bandeau Parametres, puis Chaines de connexion.")

    serveur = demander(
        u"%d. Le serveur SQL de VOTRE base." % (len(ENSEMBLES) + 2),
        [u"Copiez la ligne du serveur, ou la chaine de connexion entiere.",
         u"Le serveur se termine par .database.fabric.microsoft.com"],
        premier_serveur)

    base = demander(
        u"%d. Le nom complet de VOTRE base." % (len(ENSEMBLES) + 3),
        [u"Sur la meme page. Le nom porte un identifiant apres DossierOPCI.",
         u"Ne recopiez pas le nom affiche dans la liste des elements : ce n'est pas celui-la."],
        nom_de_base)

    identifiants = [espace] + [valeur for _, valeur in fonctions]
    if len(set(identifiants)) < len(identifiants):
        print(u"")
        print(u"ARRET. Deux des adresses collees donnent le meme identifiant.")
        print(u"Cela arrive quand on colle deux fois la meme adresse, ou celle de l'espace de travail")
        print(u"a la place de celle d'un element. Relancez le script : ouvrez chaque ensemble de")
        print(u"fonctions lui-meme, et copiez l'adresse qui s'affiche alors.")
        return 2

    python = os.path.basename(sys.executable) or "python"
    lignes = [
        u"%s scripts/25_relier_le_modele.py --serveur %s --base %s" % (python, serveur, base),
        u"%s scripts/20_relier_les_boutons.py --espace %s %s" % (
            python, espace, u" ".join(u"--%s %s" % (nom.replace(u"_", u"-"), valeur)
                                      for nom, valeur in fonctions)),
    ]

    print(u"")
    print(u"=" * 78)
    print(u"Vos %d valeurs sont relevees. Lancez ces deux commandes, DANS CET ORDRE :" % nombre)
    print(u"=" * 78)
    for ligne in lignes:
        print(u"")
        print(u"   %s" % ligne)
    print(u"")
    print(u"L'ordre compte : le modele d'abord, les boutons ensuite.")

    # On les ecrit aussi dans un fichier, pour qui prefere copier depuis un fichier.
    racine = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    chemin = os.path.join(racine, "mes_commandes.txt")
    with io.open(chemin, "w", encoding="utf-8") as f:
        f.write(u"# Commandes preparees pour votre espace de travail.\n")
        f.write(u"# A lancer depuis la racine du depot, dans cet ordre.\n\n")
        for ligne in lignes:
            f.write(ligne + u"\n")
    print(u"Elles sont aussi ecrites dans %s" % os.path.basename(chemin))
    return 0


if __name__ == "__main__":
    sys.exit(main())
