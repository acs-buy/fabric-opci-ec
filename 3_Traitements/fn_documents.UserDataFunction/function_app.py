"""Fonction fn_documents : fabrique les documents Word des livrables.

A coller dans l'element User data functions `fn_documents` de l'espace de
travail OPCI-DEV, cree le 05/09/2026 par le serveur MCP Fabric,
identifiant 01b1f037-0147-4046-9106-bd80d60c1310.

CE FICHIER EST LA COPIE DE REFERENCE, VERSIONNEE DANS LE DEPOT.
Le serveur MCP ne sait pas fournir ni pousser la definition d'un element : la
mise en place se fait au portail. Toute modification faite au portail doit
etre reportee ici, meme convention que `fn_valorisation.py`.

-----------------------------------------------------------------------
MISE EN PLACE AU PORTAIL, 3 GESTES

1. Library Management : ajouter `docxtpl` depuis PyPI, puis Publish.
   `docxtpl` traite les balises Jinja d'un .docx et sait repeter une ligne de
   tableau ; `python-docx` seul, qu'il embarque, ne remplit pas un modele.

2. Manage connections : ajouter la base SQL `DossierOPCI` et le lakehouse
   `Coffre`. Reporter ci-dessous les 2 alias generes, qui ne sont pas
   choisis par nous.

3. Coller ce code, puis Publish. Compter 2 minutes entre 2 publications.

-----------------------------------------------------------------------
CONTRAINTES DU SERVICE, VERIFIEES LE 05/09/2026

  charge de requete 4 Mo, execution 240 s, point de terminaison public 100 s,
  reponse 30 Mo, Python 3.11 en execution publiee, 3.12 en test.

Trois consequences de conception :

1. LE DOCUMENT N'EST JAMAIS RENDU EN VALEUR DE RETOUR. Le plafond de 30 Mo
   n'est pas la seule raison : la valeur de retour d'une fonction n'est pas un
   fichier telechargeable. Le document s'ecrit dans le Coffre, et la fonction
   ne rend que le chemin, la taille et la version.

2. LES NOMS DE PARAMETRES SONT EN CAMELCASE, SANS SOULIGNEMENT. Contrainte de
   la plateforme, page des limitations : `arreteId`, jamais `arrete_id`.

3. LE MODELE EST LU DANS LE COFFRE, JAMAIS EMBARQUE DANS LE CODE. Le modele
   appartient au cabinet, il se modifie dans Word sans republier la fonction.

-----------------------------------------------------------------------
CHEMINS DU COFFRE, poses le 05/09/2026

  Files/modeles/modele_annexe_opci.docx   le modele du cabinet
  Files/documents/                        les documents produits, 1 par version

Dans le code, ces chemins s'ecrivent SANS le prefixe « Files/ » : le client
rendu par `connectToFiles()` ouvre deja sur ce dossier.

Le modele de reference est versionne au depot dans
`20_LIVRABLES_V2/MODELES_WORD/`, produit par `construire_modele_annexe.js`.
"""

import datetime
import io
import logging

import fabric.functions as fn

udf = fn.UserDataFunctions()

# Alias des connexions, releves au portail le 05/09/2026 : « Coffre » et
# « DossierOPCI ». Ils s'ecrivent en clair dans les decorateurs, jamais par une
# constante : le service a refuse « Invalid argument Alias is null or empty »
# sur un alias passe par une variable, le manifeste de l'element etant
# vraisemblablement construit par lecture statique du code.

# Chemins RELATIFS AU DOSSIER Files du lakehouse, et non a la racine de
# l'element. Etabli au portail le 05/09/2026 : `connectToFiles()` ouvre deja
# sur `Files`, ce que la documentation ne dit pas. Un chemin prefixe de
# « Files/ » a produit un dossier `Files/Files/` et un document introuvable a
# l'adresse rendue par la fonction.
MODELE_ANNEXE = "modeles/modele_annexe_opci.docx"
DOSSIER_DOCUMENTS = "documents"


def _lire(fichiers, chemin: str) -> bytes:
    try:
        return fichiers.get_file_client(chemin).download_file().readall()
    except Exception as e:  # noqa: BLE001
        raise fn.UserThrownError(
            "Le modele n'a pas ete trouve dans le Coffre.",
            {"chemin": chemin, "erreur": str(e)},
        )


def _ecrire(fichiers, chemin: str, octets: bytes) -> None:
    fichiers.get_file_client(chemin).upload_data(octets, overwrite=True)


@udf.connection(alias="Coffre", argName="coffre")
@udf.function()
def essai_modele(coffre: fn.FabricLakehouseClient) -> dict:
    """Essai du maillon 5, sans la base : remplit le modele avec un jeu fige.

    Eprouve les 3 inconnues du chemin retenu le 05/09/2026 : la bibliotheque
    s'installe, le modele se lit dans le Coffre, le document s'y ecrit.
    Les montants sont un exemple d'illustration, aucune donnee de client reel.
    """
    from docxtpl import DocxTemplate

    fichiers = coffre.connectToFiles()
    modele = DocxTemplate(io.BytesIO(_lire(fichiers, MODELE_ANNEXE)))

    modele.render({
        "nom_opci": "OPCI OMEGA",
        "date_cloture": "31 decembre 2025",
        "entete_1": "31/12/2025",
        "entete_2": "31/12/2024",
        "entete_3": "31/12/2023",
        "tableau_332_1": [
            {"libelle": "Actif net (= capitaux propres)",
             "v1": "48 250 000,00", "v2": "46 100 000,00", "v3": "44 700 000,00"},
            {"libelle": "Nombre de parts ou actions en circulation",
             "v1": "96 500", "v2": "95 000", "v3": "a remplir"},
            {"libelle": "Valeur liquidative par part ou action",
             "v1": "500,00", "v2": "485,26", "v3": "a remplir"},
        ],
        "note_332_2": (
            "Les comptes annuels sont etablis conformement au reglement ANC "
            "n. 2021-09, modifie par le reglement ANC n. 2024-01. Les immeubles "
            "sont evalues a leur valeur actuelle, arretee sur le rapport de "
            "l'evaluateur immobilier."
        ),
    })

    tampon = io.BytesIO()
    modele.save(tampon)
    octets = tampon.getvalue()

    horodatage = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    chemin = f"{DOSSIER_DOCUMENTS}/essai_annexe_{horodatage}.docx"
    _ecrire(fichiers, chemin, octets)

    return {"chemin": chemin, "octets": len(octets), "produit_le": horodatage}


# ----------------------------------------------------------------------
# La fonction de production, a activer quand le lot L1c aura livre les lignes
# de l'annexe et la table des demandes, points O14, O15, O27 a O29 du cahier
# des charges de la base. La requete ci-dessous suppose une vue qui rend, par
# arrete et par article, l'ordre, le type de ligne, le libelle et les 7
# colonnes de valeurs : son nom exact est a ajuster a la livraison.
#
# @udf.connection(alias="DossierOPCI", argName="base")
# @udf.connection(alias="Coffre", argName="coffre")
# @udf.function()
# def produire_annexe(coffre: fn.FabricLakehouseClient,
#                     base: fn.FabricSqlConnection,
#                     demandeId: int) -> dict:
#     ...
