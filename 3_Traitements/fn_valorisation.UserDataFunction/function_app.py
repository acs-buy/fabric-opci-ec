"""Fonction metier fn_valorisation : enveloppe mince du moteur teste.

A coller dans l'element User data functions `fn_valorisation` de l'espace de
travail Cabinet-TEST, apres avoir televerse la roue
`60_FABRIC/fn_valorisation.UserDataFunction/privateLibraries/moteur_opci-0.2.3-py3-none-any.whl`
dans la gestion des bibliotheques. Cette roue est produite, versionnee et
verifiee module par module par `66_FONCTIONS/publier_roue.py` : elle n'est
jamais copiee a la main, une roue de contenu different sous un meme numero de
version ayant deja circule.

CE FICHIER EST LA COPIE DE REFERENCE, VERSIONNEE DANS LE DEPOT.
Le serveur MCP ne sachant pas fournir la definition d'un element, la mise en
place se fait dans le portail. Toute modification doit etre reportee ici.

Contraintes du service, valeurs verifiees le 19/08/2026 :
  charge de requete 4 Mo, execution 240 s, point de terminaison public 100 s,
  reponse 30 Mo, Python 3.11, delai de 2 minutes entre deux publications,
  seul le proprietaire de l'element peut modifier les fonctions.

Trois points de conception imposes par la plateforme ou par le modele :

1. LES ECRITURES NE SONT JAMAIS PASSEES EN PARAMETRES. La charge de requete
   plafonne a 4 Mo. La fonction recoit un arrete, une entite et une version de
   regles, et lit la base.

2. LES LIGNES D'UN LOT SONT INSEREES EN UNE SEULE INSTRUCTION. Le declencheur
   d'equilibre verifie la somme des debits et des credits apres chaque
   instruction : une insertion ligne a ligne echouerait sur la premiere.

3. LA CLAUSE `OUTPUT` EXIGE `INTO` SUR UNE TABLE A DECLENCHEUR. SQL Server
   refuse `OUTPUT` sans `INTO` lorsque la table cible porte un declencheur
   actif. Les identifiants inseres sont donc relus par une requete separee.

=======================================================================
LES QUATRE REPARATIONS DU 25/08/2026, CHAINE A DU PARAGRAPHE 6 DE
docs/superpowers/specs/2026-08-25-valorisation-participations-design.md.

1. LA FEUILLE DE TRAVAIL EST CREEE AVANT LE LOT. Depuis le 23/08/2026,
   `ck_lot_source_par_famille` exige de tout lot de famille derivable une cote
   de feuille de travail non nulle, `63_SQL/29_migration_lot_ecritures
   _source.sql`. La fonction ne la nommait pas : elle ne pouvait plus ecrire
   dans la base. Elle enregistre desormais sa feuille, sur le modele
   `VALO-ECARTS` du cycle VALO, puis nomme sa cote dans le lot.
   LA CLE `fk_lot_feuille` EST COMPOSEE, cote, arrete et entite, depuis
   `63_SQL/32_migration_feuille_cle_composee.sql` : la feuille porte donc
   l'arrete et l'entite du lot, et la cote les encode tous les deux.

2. LE FILTRE D'ENTITE EST POSE. Le parametre `entite` etait recu et non
   employe : sur un dossier a plusieurs entites, la fonction valorisait tous
   les actifs expertises a la date, quelle que soit l'entite qui les detient,
   et leur donnait a tous l'entite du parametre. Le filtre porte
   `actif.entite_detentrice`, colonne posee par
   `63_SQL/42_valorisation_participations.sql`.
   CONSEQUENCE A CONNAITRE : le perimetre de tout lot deja produit sans ce
   filtre n'est pas celui qu'un rejeu produira.

3. LE PLAFOND DE 210 LIGNES PAR LOT EST LEVE. L'insertion unique passait par
   un constructeur de valeurs de table portant 10 parametres par ligne, et le
   schema plafonne a 2 100 parametres par instruction, soit 210 lignes. Elle
   passe desormais par `INSERT ... SELECT ... FROM OPENJSON(...) WITH (...)`,
   AVEC UN SEUL PARAMETRE, la charge etant un tableau JSON.
   L'INVARIANT DU DECLENCHEUR RESTE TENU : c'est toujours UNE SEULE
   instruction d'insertion, donc un seul controle d'equilibre, sur le lot
   complet.
   LE NOUVEAU PLAFOND, ET IL EST DOCUMENTE PAR L'EDITEUR : un tableau JSON
   porte au plus 65 535 elements, page « JSON data type », section Size
   limitations, relevee le 25/08/2026. La forme `OPENJSON` avec `WITH` est
   celle de la page « OPENJSON (Transact-SQL) », section Syntax,
   `OPENJSON( jsonExpression [ , path ] ) [ WITH ( colName type ... ) ]`, dont
   l'applicabilite porte « SQL database in Microsoft Fabric ». La meme page
   pose que « OPENJSON converts JSON values to the types that are specified in
   the WITH clause » : les montants voyagent en chaines et sont convertis en
   DECIMAL par la clause, sans arrondi intermediaire.
   POURQUOI UNE VARIABLE PLUTOT QUE LE PARAMETRE DIRECTEMENT DANS OPENJSON.
   La meme page impose a `jsonExpression` un type de caracteres ; la variable
   `@lignes` le declare en NVARCHAR(MAX) explicitement, plutot que de laisser
   le pilote choisir la taille du parametre.

4. LA REFERENCE DE ROUE EST CORRIGEE. L'en-tete nommait 0.2.2 ; le depot porte
   0.2.3, valeur de `62_MOTEUR/pyproject.toml` et de
   `66_FONCTIONS/publier_roue.py`. Les 8 autres references perimees relevees
   le 24/08/2026 vivent dans des fichiers que cette tache ne touche pas.
=======================================================================
"""

import hashlib
import json
from decimal import Decimal

import fabric.functions as fn

from moteur_opci.invariants import lot_est_equilibre, total_credit, total_debit
from moteur_opci.modeles import Actif, Expertise
from moteur_opci.valorisation import lignes_difference_estimation

udf = fn.UserDataFunctions()

JOURNAL_CODE = "ODV"
JOURNAL_LIB = "OD de valorisation"

# La feuille de travail que le lot derivable cite. Le cycle VALO et le modele
# VALO-ECARTS sont semes par 63_SQL/16_seed_ref_cycle_phase.sql et par le
# bloc 1 de 63_SQL/28_seed_modele_feuille.sql ; l'origine MOTEUR est la valeur
# que ck_ft_origine reserve a une feuille preremplie par un moteur.
CYCLE_FEUILLE = "VALO"
MODELE_FEUILLE = "VALO-ECARTS"
ORIGINE_FEUILLE = "MOTEUR"
PREFIXE_COTE = "VALO"
# dbo.feuille_travail.cote est en VARCHAR (30), 63_SQL/27_feuilles_de_travail
# .sql, longueur elle-meme dictee par ref_croisee.xref.
COTE_LONGUEUR_MAX = 30

# Lit les actifs valorisables d'un arrete POUR UNE ENTITE, avec le stock de
# difference d'estimation deja comptabilise, afin de n'ecrire que le delta.
#
# LE FILTRE D'ENTITE PORTE actif.entite_detentrice ET NON lot_ecritures.entite.
# Un immeuble appartient a l'entite qui le detient ; l'entite d'un lot dit
# seulement au nom de qui l'ecriture est passee. Faire porter le filtre au lot
# ferait dependre le perimetre du calcul des lots deja produits.
# La porte du critere B6 bis. La vue porte le motif, AMBIGU excepte : ici seul
# le perimetre de l'appel est regarde, l'arrete et l'entite detentrice, la vue
# rendant deja ces 2 colonnes.
REQUETE_EXPERTISES_SANS_RAPPORT = """
SELECT v.code_actif, v.motif
FROM dbo.v_expertise_sans_rapport v
WHERE v.date_valeur = ?
  AND v.entite_detentrice = ?
"""

REQUETE_ACTIFS = """
SELECT a.code,
       a.nature,
       a.prix_de_revient,
       e.date_valeur,
       e.valeur_actuelle,
       COALESCE((
           SELECT SUM(ec.debit) - SUM(ec.credit)
           FROM ecriture ec
           JOIN ecriture_axe ax ON ax.ecriture_id = ec.id
           JOIN lot_ecritures l ON l.id = ec.lot_id
           WHERE ax.code_actif = a.code
             AND l.famille = 'DERIVABLE'
             AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             AND ec.compte_num LIKE '27%'
       ), 0) AS stock_anterieur
FROM actif a
JOIN expertise e ON e.code_actif = a.code
WHERE e.date_valeur = ?
  AND a.entite_detentrice = ?
ORDER BY a.code
"""

REQUETE_LIBELLES = """
SELECT compte, COALESCE(libelle_complet, libelle) AS libelle
FROM ref_compte
WHERE compte IN (SELECT value FROM STRING_SPLIT(?, ','))
"""

# La feuille n'est inseree que si sa cote manque. Un rejeu ne cree pas de
# doublon et n'ecrase ni la conclusion ni le visa qu'un reviseur aurait poses.
# LA CONSEQUENCE, ECRITE PLUTOT QUE TUE : si un second lot est produit pour le
# meme arrete et la meme entite, apres une expertise revisee, il cite la
# feuille deja enregistree et l'empreinte de celle-ci reste celle du premier
# contenu. Le reviseur voit alors 2 lots sur une seule feuille.
REQUETE_FEUILLE = """
INSERT INTO feuille_travail
  (cote, cycle, arrete, entite, modele_code, origine, nom_fichier,
   chemin_coffre, empreinte_sha256, conclusion, preparateur, prepare_le,
   reviseur, revise_le)
SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 'fn_valorisation',
       SYSUTCDATETIME(), NULL, NULL
WHERE NOT EXISTS (SELECT 1 FROM feuille_travail WHERE cote = ?)
"""

# UNE SEULE INSTRUCTION, UN SEUL PARAMETRE. Le declencheur d'equilibre ne voit
# donc qu'un lot complet, et le nombre de lignes n'est plus borne par le nombre
# de parametres du schema.
REQUETE_INSERTION = """
DECLARE @lignes NVARCHAR(MAX) = ?;
INSERT INTO ecriture
  (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
   compte_num, compte_lib, ecriture_lib, debit, credit)
SELECT j.lot_id, j.journal_code, j.journal_lib, j.ecriture_num,
       j.ecriture_date, j.compte_num, j.compte_lib, j.ecriture_lib,
       j.debit, j.credit
FROM OPENJSON(@lignes)
WITH (
    lot_id        INT,
    journal_code  VARCHAR(10),
    journal_lib   NVARCHAR(100),
    ecriture_num  VARCHAR(30),
    ecriture_date DATE,
    compte_num    VARCHAR(20),
    compte_lib    NVARCHAR(200),
    ecriture_lib  NVARCHAR(400),
    debit         DECIMAL(19,2),
    credit        DECIMAL(19,2)
) AS j
"""


def cote_de_feuille(arrete, entite):
    """Compose la cote de la feuille de travail d'un lot de valorisation.

    LA COTE ENCODE L'ARRETE ET L'ENTITE, et ce n'est pas une commodite de
    lecture : `fk_lot_feuille` est une cle etrangere COMPOSEE sur le triplet
    cote, arrete et entite depuis `63_SQL/32_migration_feuille_cle_composee
    .sql`. Une cote qui ne les porterait pas laisserait 2 arretes se disputer
    la meme feuille, la cote etant seule clef primaire de la table.

    LA LONGUEUR EST CONTROLEE PLUTOT QUE TRONQUEE. Une troncature ferait
    2 entites differentes partager une cote des que leurs codes partagent un
    prefixe, et la seconde recevrait la feuille de la premiere sans qu'aucune
    contrainte le voie. Au-dela de 30 caracteres, la composition est refusee et
    dit ce qui depasse.
    """
    cote = f"{PREFIXE_COTE}-{arrete}-{entite}"
    if len(cote) > COTE_LONGUEUR_MAX:
        raise fn.UserThrownError(
            "Cote de feuille de travail trop longue, generation interrompue.",
            {
                "cote": cote,
                "longueur": str(len(cote)),
                "maximum": str(COTE_LONGUEUR_MAX),
            },
        )
    return cote


def empreinte_du_contenu(lignes):
    """Rend l'empreinte SHA-256 du contenu que le moteur a calcule.

    CE QUE CETTE EMPREINTE COUVRE, ET CE QU'ELLE NE COUVRE PAS. Elle est prise
    sur les lignes calculees, actif par actif, compte par compte, avec leurs
    montants : deux executions qui rendent le meme resultat rendent la meme
    empreinte, et un montant qui bouge la fait bouger. ELLE NE COUVRE AUCUN
    FICHIER : aucun classeur n'est depose par cette fonction, et
    `dbo.feuille_travail.empreinte_sha256` est une colonne obligatoire. Ecrire
    ici l'empreinte d'un classeur inexistant serait une valeur forgee, ce que
    l'en-tete de `63_SQL/28_seed_modele_feuille.sql` refuse ; l'empreinte d'un
    contenu reellement calcule ne l'est pas.

    LA SERIALISATION EST ORDONNEE ET SANS ESPACES, pour que l'empreinte ne
    depende ni de l'ordre de parcours ni de la mise en forme.
    """
    matiere = "\n".join(
        sorted(
            f"{ligne.code_actif};{ligne.compte};{ligne.debit};{ligne.credit}"
            for ligne in lignes
        )
    )
    return hashlib.sha256(matiere.encode("utf-8")).hexdigest()


@udf.connection(argName="sqlDB", alias="DossierOPCI")
@udf.function()
def generer_lot_valorisation(
    sqlDB: fn.FabricSqlConnection,
    arrete: str,
    entite: str,
    versionRegles: str,
) -> str:
    """Genere le lot derivable de differences d'estimation d'un arrete.

    Retourne un compte rendu en chaine, le service imposant un type de retour
    `str`. Les noms de parametres emploient la casse chameau, les soulignes
    etant interdits dans les noms de parametres.
    """
    connexion = sqlDB.connect()
    curseur = connexion.cursor()

    # 0. LA PORTE DU CRITERE B6 BIS, BRANCHEE LE 25/08/2026. Une valeur
    #    d'expertise sans son rapport au coffre n'alimente pas la valorisation.
    #    La vue dbo.v_expertise_sans_rapport, posee par
    #    63_SQL/44_expertise_rapport.sql, rend les expertises fautives avec
    #    leur motif : la fonction refuse tant qu'elle n'est pas vide sur le
    #    perimetre demande. Le refus est un compte rendu, pas une exception,
    #    le service imposant un retour en chaine.
    curseur.execute(REQUETE_EXPERTISES_SANS_RAPPORT, arrete, entite)
    fautives = curseur.fetchall()
    if fautives:
        codes = ", ".join(sorted({r.code_actif for r in fautives}))
        return (
            f"Refus : {len(fautives)} expertise(s) sans rapport au coffre "
            f"pour l'entite {entite} a la date {arrete} ({codes}). "
            "Deposer chaque rapport dans le coffre, le rattacher a son actif "
            "ou a son entite, puis relancer. Critere B6 bis : une valeur "
            "d'expertise sans son rapport n'alimente pas la valorisation."
        )

    # 1. Lire la matiere, BORNEE A L'ENTITE. Aucune ecriture n'est passee en
    #    parametre.
    curseur.execute(REQUETE_ACTIFS, arrete, entite)
    rangs = curseur.fetchall()
    if not rangs:
        return (
            f"Aucun actif de l'entite {entite} expertise a la date {arrete}. "
            f"Rien a ecrire."
        )

    # 2. Appliquer la regle testee unitairement dans le depot.
    lignes = []
    for code, nature, prix, date_valeur, valeur, stock in rangs:
        lignes.extend(
            lignes_difference_estimation(
                Actif(
                    code=code,
                    nature=nature,
                    prix_de_revient=Decimal(str(prix)),
                ),
                Expertise(
                    code_actif=code,
                    date_valeur=date_valeur,
                    valeur_actuelle=Decimal(str(valeur)),
                ),
                stock_anterieur=Decimal(str(stock)),
            )
        )

    if not lignes:
        return (
            f"Arrete {arrete}, entite {entite} : aucun ecart a ecrire. "
            f"{len(rangs)} actif(s) examine(s), stock deja a jour."
        )

    # 3. Verifier l'invariant AVANT d'ecrire, pour un message utile.
    #    Le declencheur de la base le verifiera de toute facon.
    if not lot_est_equilibre(lignes):
        raise fn.UserThrownError(
            "Lot desequilibre, generation interrompue.",
            {
                "debit": str(total_debit(lignes)),
                "credit": str(total_credit(lignes)),
            },
        )

    # 4. Libelles de comptes, depuis le referentiel de l'article 411-3.
    comptes = sorted({ligne.compte for ligne in lignes})
    curseur.execute(REQUETE_LIBELLES, ",".join(comptes))
    libelles = {compte: libelle for compte, libelle in curseur.fetchall()}
    manquants = [c for c in comptes if c not in libelles]
    if manquants:
        raise fn.UserThrownError(
            "Comptes absents du referentiel, generation interrompue.",
            {"comptes": ",".join(manquants)},
        )

    # 5. Creer la feuille de travail AVANT le lot.
    #    ck_lot_source_par_famille exige une cote de feuille non nulle sur un
    #    lot de famille derivable : sans ce geste, l'insertion du lot est
    #    refusee par la base.
    cote = cote_de_feuille(arrete, entite)
    nom_fichier = f"{cote}_differences_estimation.xlsx"
    chemin_coffre = f"/Coffre/{entite}/{arrete}/feuilles/{nom_fichier}"
    curseur.execute(
        REQUETE_FEUILLE,
        cote,
        CYCLE_FEUILLE,
        arrete,
        entite,
        MODELE_FEUILLE,
        ORIGINE_FEUILLE,
        nom_fichier,
        chemin_coffre,
        empreinte_du_contenu(lignes),
        cote,
    )

    # 6. Creer le lot, en citant sa feuille. Pas de declencheur d'insertion sur
    #    cette table, OUTPUT direct.
    curseur.execute(
        """INSERT INTO lot_ecritures
             (arrete, famille, portee, entite, statut, version_regles,
              feuille_cote, cree_par)
           OUTPUT INSERTED.id
           VALUES (?, 'DERIVABLE', 'ENTITE', ?, 'PROPOSE', ?, ?,
                   'fn_valorisation')""",
        arrete,
        entite,
        versionRegles,
        cote,
    )
    lot_id = int(curseur.fetchone()[0])

    # 7. Inserer TOUTES les lignes en UNE SEULE instruction, par un tableau
    #    JSON et un seul parametre. Les montants voyagent en chaines et la
    #    clause WITH les convertit en DECIMAL (19,2).
    charge = json.dumps(
        [
            {
                "lot_id": lot_id,
                "journal_code": JOURNAL_CODE,
                "journal_lib": JOURNAL_LIB,
                "ecriture_num": f"{JOURNAL_CODE}-{ligne.code_actif}",
                "ecriture_date": arrete,
                "compte_num": ligne.compte,
                "compte_lib": libelles[ligne.compte],
                "ecriture_lib": f"Difference d'estimation {ligne.code_actif}",
                "debit": str(ligne.debit),
                "credit": str(ligne.credit),
            }
            for ligne in lignes
        ],
        ensure_ascii=False,
    )
    curseur.execute(REQUETE_INSERTION, charge)

    # 7-bis. Relire les identifiants inseres, par une requete separee.
    #
    # Deux raisons de ne PAS employer un lot multi-instructions avec une clause
    # OUTPUT INTO, ce qui etait la premiere version et qui echouait :
    #   - apres execute() sur un lot, pyodbc positionne le curseur sur le
    #     PREMIER resultat. Les instructions DECLARE et INSERT produisent des
    #     nombres de lignes et non des jeux de resultats, donc fetchall() leve
    #     « No results. Previous SQL was not a query. » Il faudrait parcourir
    #     les jeux par nextset() jusqu'a trouver le SELECT ;
    #   - une clause OUTPUT sans INTO est refusee sur une table portant un
    #     declencheur actif, ce qui imposait la variable de table.
    #
    # Une requete separee filtree sur l'identifiant du lot est plus simple,
    # deterministe, et sans interaction avec le declencheur.
    curseur.execute(
        "SELECT id, ecriture_num FROM ecriture WHERE lot_id = ? ORDER BY id",
        lot_id,
    )
    inserees = curseur.fetchall()

    # 8. Porter l'axe actif. Le numero d'ecriture encode le code de l'actif,
    #    le format fiscal des 18 champs ne sachant pas transporter d'axe.
    axes = [
        (identifiant, entite, numero.split("-", 1)[1])
        for identifiant, numero in inserees
    ]
    curseur.executemany(
        "INSERT INTO ecriture_axe (ecriture_id, entite, code_actif) VALUES (?, ?, ?)",
        axes,
    )

    connexion.commit()

    return (
        f"Lot {lot_id} genere sur la feuille {cote}. "
        f"{len(lignes)} ligne(s) sur {len(rangs)} actif(s). "
        f"Arrete {arrete}, entite {entite}, regles {versionRegles}. "
        f"Total {total_debit(lignes)} au debit et autant au credit."
    )
