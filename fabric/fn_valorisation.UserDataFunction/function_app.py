"""Fonction metier fn_valorisation : enveloppe mince du moteur teste.

Publiee par l'API, jamais collee a la main : 61_DEPLOIEMENT/poser_fonction_ecran.py --nom fn_valorisation --ecrire
envoie ce fichier, definition.json et la roue
`privateLibraries/moteur_opci-0.3.0-py3-none-any.whl` par updateDefinition, puis relit chaque partie par
getDefinition. La roue est produite, versionnee et verifiee module par module par `66_FONCTIONS/publier_roue.py` :
elle n'est jamais copiee a la main, une roue de contenu different sous un meme numero de version ayant deja circule.

CE FICHIER EST LA COPIE DE REFERENCE, VERSIONNEE DANS LE DEPOT. Les copies 60_FABRIC_DEV et
66_FONCTIONS/fn_valorisation.py lui sont egales.

Contraintes du service, valeurs verifiees le 19/08/2026 :
  charge de requete 4 Mo, execution 240 s, point de terminaison public 100 s,
  reponse 30 Mo, Python 3.11, delai de 2 minutes entre deux publications,
  seul le proprietaire de l'element peut modifier les fonctions.

Trois points de conception imposes par la plateforme ou par le modele :

1. LES ECRITURES NE SONT JAMAIS PASSEES EN PARAMETRES. La charge de requete
   plafonne a 4 Mo. La fonction recoit un arrete, une entite et, au besoin, une
   version de regles, et lit la base.

2. LES LIGNES D'UN LOT SONT INSEREES EN UNE SEULE INSTRUCTION. Le declencheur
   d'equilibre verifie la somme des debits et des credits apres chaque
   instruction : une insertion ligne a ligne echouerait sur la premiere.

3. LA CLAUSE `OUTPUT` EXIGE `INTO` SUR UNE TABLE A DECLENCHEUR. SQL Server
   refuse `OUTPUT` sans `INTO` lorsque la table cible porte un declencheur
   actif. Les identifiants inseres sont donc relus par une requete separee.

=======================================================================
LES QUATRE REPARATIONS DU 25/08/2026, CHAINE A DU PARAGRAPHE 6 DE
docs/superpowers/specs/2026-08-25-valorisation-participations-design.md.

1. LA FEUILLE DE TRAVAIL EST CREEE AVANT LE LOT (ck_lot_source_par_famille ;
   cle fk_lot_feuille composee, cote, arrete et entite).
2. LE FILTRE D'ENTITE EST POSE, sur l'entite qui detient l'actif.
3. LE PLAFOND DE 210 LIGNES PAR LOT EST LEVE : une seule instruction
   INSERT ... SELECT ... FROM OPENJSON(...) WITH (...), un seul parametre ;
   un tableau JSON porte au plus 65 535 elements (page « JSON data type »,
   relevee le 25/08/2026).
4. LA REFERENCE DE ROUE EST CORRIGEE.

=======================================================================
LA REPRISE DU 10/10/2026, OBJET N° 224 DE LA MAQUETTE RETENUE DE L'ECRAN 3
(option 1 du lot 0, tranchee par le candidat le 10/10/2026 ;
65_JOURNAL/roadmap_ecran_3_valorisation.md, § 4.2 et lot 4).

1. LA GARDE B6 BIS RESTE LA 1RE ETAPE. Une valeur d'expertise sans son rapport
   au coffre n'alimente pas la valorisation (dbo.v_expertise_sans_rapport,
   filtree sur l'arrete et l'entite detentrice). Son refus est desormais un
   refus francais (UserThrownError) pose dans la zone de message, et non une
   phrase rendue comme une reussite.

2. LA GARDE DE LA GENERATION, dbo.pr_garde_generer_lot_valorisation (objet de
   base n° 25), S'EXECUTE A SA SUITE, DANS LA TRANSACTION DE LA FONCTION, AVANT
   TOUTE ECRITURE. Elle prend les verrous d'entite et un verrou d'application
   sur l'entite et l'arrete, tenus jusqu'au commit de la fonction, puis relit
   les 3 gardes de l'ancienne demande : une demande EN_ATTENTE, un lot
   DERIVABLE PROPOSE non perime, aucun actif CALCULABLE (refus 50061). Un 2e
   appel concurrent attend le commit du 1er, puis est refuse : jamais 2 lots
   PROPOSE concurrents. La transaction est celle du pilote : la connexion n'est
   pas en validation automatique, et la 1re lecture (garde B6 bis) ouvre la
   transaction implicite que la garde exige (refus 50795 sans transaction).

3. LA MATIERE EST CELLE DE L'ECRAN : les seuls actifs CALCULABLE de
   dbo.v_a_generer a l'arrete, pour l'entite, avec leur valeur actuelle (valeur
   retenue visee comprise) et le POSTE DU BILAN de l'actif, d'ou la roue 0.3.0
   derive le compte de difference (21 a 26 vers 271 a 276, classe 3 vers 37) et
   sa contrepartie (dbo.ref_contrepartie_estimation). Le stock deja passe se lit
   sur ce compte, par l'axe de l'actif, dans les lots DERIVABLE vises.

4. LES SEULS TITRES DE FILIALES VALORISES A L'ACTIF NET REEVALUE N'ENTRENT PAS
   DANS CE LOT : les lignes de dbo.v_a_generer de source ANR_FILIALE. Elles
   viennent de dbo.v_titres_valeur_actuelle (dbo.detention jointe a
   dbo.v_anr_filiale, a la quote-part), la meme matiere que la cible de la
   reprise du compte 275 (dbo.v_reprise_275_a_passer, bouton « Reprendre
   l'ecart du 275 ») : les ecrire ici aussi les ferait passer 2 fois.
   Correction du 10/10/2026 : le critere etait le compte 275, et il ecartait
   aussi les titres des comptes 256 et 258 (actions cotees, OPCI), dont la
   difference d'estimation n'etait alors ecrite par aucun chemin. Ces titres,
   et tout titre de la serie 25 dont la valeur ne vient pas de l'actif net
   reevalue d'une filiale, entrent dans le lot, au compte 275, par l'axe de
   l'actif. Fait releve en base le meme jour : dbo.v_reprise_275_a_passer
   compte toute ecriture DERIVABLE visee au 275 de l'arrete, axe d'actif ou
   non ; une difference de titre 256 ou 258 visee y entre donc dans le compte
   rapproche de la cible des filiales.

4 BIS. TANT QUE LA REPRISE DU 275 NE DISTINGUE PAS CES TITRES, LEUR
   DIFFERENCE EST UN REFUS NOMME, AVANT TOUTE ECRITURE (10/10/2026). Visee,
   une difference de titre 256 ou 258 au compte 275 serait contre-passee par
   « Reprendre l'ecart du 275 », qui rapproche ce compte de la seule valeur des
   titres de filiales. matiere_du_lot refuse donc tout lot qui porterait une
   ligne au compte 275, en nommant l'actif, son poste et le montant, tant que
   REPRISE_275_DISTINGUE_LES_TITRES est faux ; la constante passe a vrai,
   et la fonction se republie, quand la session base aura corrige la vue (filtre
   par l'axe des titres de filiales, ou subdivision du 275). Un ecart nul ne
   porte aucune ligne et ne refuse rien. FAIT LE 10/10/2026 : la session base a
   separe le 275 par l'axe de l'actif (63_SQL/291, commit aae31138, decision du
   candidat) ; la constante vaut vrai.

5. UN POSTE SANS COMPTE DE DIFFERENCE (NatureNonValorisable) EST UN REFUS
   FRANCAIS qui nomme l'actif et le poste, et non une exception anglaise.

6. CHAQUE APPEL POSE SON MESSAGE par dbo.pr_poser_message_ecran, sous l'entite
   passee (le vehicule du selecteur), pour la personne connectee : la phrase
   rendue a la reussite, le texte du refus sinon, ce dernier aussi journalise
   par dbo.pr_journaliser_refus. Le message s'ecrit APRES le commit ou le
   rollback de l'action, dans une connexion neuve.

7. versionRegles EST FACULTATIF : son defaut est moteur_opci.VERSION_REGLES,
   la version des regles que la roue embarque (ck_version_si_derivable exige une
   version sur tout lot DERIVABLE). Le bouton ne la passe pas.

8. L'AUTEUR DU LOT ET DE LA FEUILLE EST LA PERSONNE CONNECTEE
   (ctx.executing_user), et non plus le nom de la fonction : dbo.fn_proposant
   designe l'auteur du lot comme proposant, et dbo.tr_visa_separation_des_roles
   refuse qu'il le vise lui-meme (50050).

9. UNE ERREUR NON PREVUE REMONTE EN FRANCAIS (10/10/2026) : le bouton recoit
   une UserThrownError dont le texte dit que la generation s'est interrompue
   sans poser de lot ; la zone de message porte ce texte, et le detail
   technique (classe, numero et texte de l'exception) va au seul journal des
   refus. La phrase de reussite est composee avant le commit, apres lequel rien
   ne peut plus lever : une erreur rendue ne laisse donc jamais de lot pose.

10. UN REFUS DE LA BASE SE DISTINGUE D'UNE ERREUR DU MOTEUR SQL PAR SON NUMERO
   (10/10/2026). THROW n'admet que des numeros d'au moins 50000 : une erreur
   qui en porte un est un refus de la base, son texte francais va au bouton et
   a la zone de message, a l'etape de la garde comme a toute autre etape (un
   declencheur d'une table ecrite). Une erreur sans numero (delai du pilote,
   coupure) ou de numero inferieur (interblocage 1205, delai de verrou 1222,
   conversion, contrainte) est une erreur du moteur : texte francais du point
   9, detail au journal, et a l'etape de la garde le journal nomme
   pr_garde_generer_lot_valorisation.
"""

import datetime
import hashlib
import json
import re
from decimal import Decimal

import fabric.functions as fn

from moteur_opci import VERSION_REGLES
from moteur_opci.invariants import lot_est_equilibre, total_credit, total_debit
from moteur_opci.modeles import Actif, Expertise, NatureNonValorisable
from moteur_opci.valorisation import compte_difference_estimation, lignes_difference_estimation

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
# lot_ecritures.version_regles est en VARCHAR (20)
VERSION_LONGUEUR_MAX = 20
# La source des titres de filiales valorises a l'actif net reevalue, rapproches par la seule reprise du 275 (point 4
# de l'en-tete) : la valeur que dbo.v_patrimoine_valorise tire de dbo.v_titres_valeur_actuelle.
SOURCE_TITRES_FILIALES = "ANR_FILIALE"
# Point 4 bis de l'en-tete : faux tant que dbo.v_reprise_275_a_passer compte au 275 toute ecriture DERIVABLE visee,
# axe d'actif ou non (definition relue le 10/10/2026). Faux, un lot qui porterait une ligne au 275 est refuse.
REPRISE_275_DISTINGUE_LES_TITRES = True
COMPTE_TITRES = "275"
# Point 10 de l'en-tete : THROW n'admet que des numeros d'au moins 50000.
PREMIER_NUMERO_DE_REFUS = 50000
# Le texte d'une erreur non prevue (point 9 de l'en-tete)
TEXTE_ERREUR = ("Génération interrompue par une erreur d'exécution : aucun lot n'est posé. Le détail technique est "
                "consigné au journal des refus.")
# Le refus du vehicule vide (24/10/2026, docstring de generer_lot_valorisation) : [Entite si generable] est vide quand
# le selecteur l'est, et aussi quand le lot ne se genere pas en l'etat
REFUS_VEHICULE = ("Génération refusée : pour le véhicule du sélecteur Véhicule, le lot ne se génère pas en l'état "
                  "(expertise sans rapport rattaché, demande de réévaluation en attente, lot dérivable proposé non "
                  "périmé, ou aucun actif calculable).")

# 0. La porte du critere B6 bis : le perimetre de l'appel, l'arrete et l'entite detentrice.
REQUETE_EXPERTISES_SANS_RAPPORT = """
SELECT v.code_actif, v.motif
FROM dbo.v_expertise_sans_rapport v
WHERE v.date_valeur = ?
  AND v.entite_detentrice = ?
"""

# 1. La garde n° 25, dans la transaction de la fonction, avant toute ecriture.
REQUETE_GARDE = "EXEC dbo.pr_garde_generer_lot_valorisation @entite = ?, @arrete = ?"

# 2. Les actifs CALCULABLE de l'entite a l'arrete, leur poste du bilan, leur valeur
#    actuelle et le stock deja passe sur leur compte de difference.
#    LE FILTRE D'ENTITE PORTE v_a_generer.entite, qui est l'entite detentrice de l'actif
#    sur toutes les lignes de la vue ; l'entite d'un lot dit seulement au nom de qui
#    l'ecriture est passee.
REQUETE_ACTIFS = """
SELECT g.code_actif,
       g.nature,
       a.poste_bilan,
       a.prix_de_revient,
       g.valeur_actuelle,
       g.source,
       COALESCE((
           SELECT SUM(ec.debit) - SUM(ec.credit)
           FROM dbo.ecriture ec
           JOIN dbo.ecriture_axe ax ON ax.ecriture_id = ec.id
           JOIN dbo.lot_ecritures l ON l.id = ec.lot_id
           WHERE ax.code_actif = g.code_actif
             AND l.famille = 'DERIVABLE'
             AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             AND ec.compte_num LIKE dbo.fn_compte_difference_estimation(a.poste_bilan) + '%'
       ), 0) AS stock_anterieur
FROM dbo.v_a_generer g
JOIN dbo.actif a ON a.code = g.code_actif
WHERE g.arrete = ?
  AND g.entite = ?
  AND g.etat_generation = 'CALCULABLE'
ORDER BY g.code_actif
"""

REQUETE_LIBELLES = """
SELECT compte, COALESCE(libelle_complet, libelle) AS libelle
FROM ref_compte
WHERE compte IN (SELECT value FROM STRING_SPLIT(?, ','))
"""

# La feuille n'est inseree que si sa cote manque. Un rejeu ne cree pas de
# doublon et n'ecrase ni la conclusion ni le visa qu'un reviseur aurait poses.
# Un 2e lot du meme arrete et de la meme entite, apres l'annulation du 1er,
# cite la feuille deja enregistree, dont l'empreinte reste celle du 1er contenu.
REQUETE_FEUILLE = """
INSERT INTO feuille_travail
  (cote, cycle, arrete, entite, modele_code, origine, nom_fichier,
   chemin_coffre, empreinte_sha256, conclusion, preparateur, prepare_le,
   reviseur, revise_le)
SELECT ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?, SYSUTCDATETIME(), NULL, NULL
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


# ----------------------------------------------------------------------------- la personne et la zone de message
# Memes regles que fn_ecran_revision : l'utilisateur vient du contexte de chaque appel, jamais d'un parametre ; le
# message s'ecrit dans une connexion neuve, apres le commit ou le rollback de l'action, et ne leve jamais.

def _qui(ctx) -> str:
    u = (ctx.executing_user or {}).get("PreferredUsername") or (ctx.executing_user or {}).get("Oid")
    if not u:
        raise fn.UserThrownError("L'utilisateur connecté n'est pas identifiable ; l'action n'est pas exécutée.", {})
    return u


def _texte_pilote(exc) -> str:
    """Le texte de l'erreur du pilote ODBC : le 2e argument de l'exception pyodbc, (etat SQL, texte), sinon str(exc)."""
    a = getattr(exc, "args", ())
    return a[1] if len(a) > 1 and isinstance(a[1], str) else str(exc)


def _message_sql(exc) -> str:
    s = _texte_pilote(exc)
    m = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQL\w+\)|$)", s, re.S)
    return (m.group(1) if m else s).strip()


def _numero_sql(exc):
    """Le numero d'erreur de SQL Server que porte l'exception, celui du 1er enregistrement, ou None quand elle n'en
    porte pas (delai ou coupure du pilote, erreur Python)."""
    m = re.search(r"\[SQL Server\].*?\s\((\d+)\)\s\(SQL\w+\)", _texte_pilote(exc), re.S)
    return int(m.group(1)) if m else None


def _refus_de_la_base(exc):
    """Le texte francais d'un refus de la base (THROW, numero d'au moins 50000), ou None pour toute autre erreur
    (point 10 de l'en-tete)."""
    n = _numero_sql(exc)
    return _message_sql(exc) if n is not None and n >= PREMIER_NUMERO_DE_REFUS else None


def _detail(exc) -> str:
    """Le detail technique d'une erreur non prevue, pour le seul journal des refus : classe, numero, texte."""
    n = _numero_sql(exc)
    return "%s%s : %s" % (exc.__class__.__name__, "" if n is None else " n° %d" % n, _message_sql(exc) or _texte(exc))


def _texte(e) -> str:
    v = getattr(e, "message", None)
    if isinstance(v, str) and v.strip():
        return v
    return str(e) or e.__class__.__name__


def _poser(base, qui, entite, message, genre, procedure, journal=False, detail=None) -> None:
    """Ecrit le message dans dbo.message_ecran, et le refus dans dbo.journal_refus quand journal est vrai ; detail,
    quand il est donne, remplace le message au journal seul (le detail technique d'une erreur non prevue). UNE
    CONNEXION NEUVE, donc une transaction neuve. Ne leve jamais : un message qui echoue ne masque pas l'action."""
    texte = (message or "").strip()[:2000]
    e = (str(entite).strip()[:20] if entite is not None and str(entite).strip() else None)
    if not texte or not qui:
        return
    try:
        conn = base.connect()
    except Exception:
        return
    try:
        if journal:
            try:
                cur = conn.cursor()
                cur.execute("EXEC dbo.pr_journaliser_refus @procedure_nom=?, @message=?, @par=?, @entite=?",
                            (procedure[:128], ((detail or "").strip()[:2000] or texte), qui, e))
                cur.close()
                conn.commit()
            except Exception:
                try:
                    conn.rollback()
                except Exception:
                    pass
        cur = conn.cursor()
        cur.execute("EXEC dbo.pr_poser_message_ecran @pour=?, @message=?, @genre=?, @entite=?, @procedure_nom=?",
                    (qui, texte, genre, e, procedure[:128]))
        cur.close()
        conn.commit()
    except Exception:
        try:
            conn.rollback()
        except Exception:
            pass
    finally:
        try:
            conn.close()
        except Exception:
            pass


class _Refus(Exception):
    """Un refus de la fonction ou de la base : son texte francais, et la procedure qui l'a porte."""

    def __init__(self, texte, procedure="generer_lot_valorisation"):
        super().__init__(texte)
        self.texte, self.procedure = texte, procedure


class _ErreurExecution(Exception):
    """Une erreur du moteur SQL ou du pilote a une etape nommee (point 10 de l'en-tete) : l'exception d'origine et la
    procedure que le journal des refus nomme."""

    def __init__(self, origine, procedure):
        super().__init__(str(origine))
        self.origine, self.procedure = origine, procedure


# ----------------------------------------------------------------------------- les formes

def _date_ecran(arrete: str) -> str:
    try:
        return datetime.date.fromisoformat(arrete).strftime("%d/%m/%Y")
    except ValueError:
        return arrete


def _montant_ecran(x: Decimal) -> str:
    """2 decimales, separateur de milliers U+202F et virgule decimale, comme FORMAT(x, 'N2', 'fr-FR') de la base."""
    s = "{:,.2f}".format(x)
    return s.replace(",", " ").replace(".", ",")


def cote_de_feuille(arrete, entite):
    """Compose la cote de la feuille de travail d'un lot de valorisation.

    LA COTE ENCODE L'ARRETE ET L'ENTITE : fk_lot_feuille est une cle etrangere composee sur le triplet cote, arrete et
    entite. LA LONGUEUR EST CONTROLEE PLUTOT QUE TRONQUEE : une troncature ferait 2 entites partager une cote."""
    cote = f"{PREFIXE_COTE}-{arrete}-{entite}"
    if len(cote) > COTE_LONGUEUR_MAX:
        raise _Refus(f"Génération refusée : la cote de la feuille de travail {cote} dépasse {COTE_LONGUEUR_MAX} "
                     f"caractères ({len(cote)}).")
    return cote


def empreinte_du_contenu(lignes):
    """L'empreinte SHA-256 du contenu que le moteur a calcule, actif par actif, compte par compte, avec leurs
    montants. Elle ne couvre aucun fichier : aucun classeur n'est depose par cette fonction, et
    dbo.feuille_travail.empreinte_sha256 est obligatoire. Serialisation ordonnee et sans espaces."""
    matiere = "\n".join(
        sorted(
            f"{ligne.code_actif};{ligne.compte};{ligne.debit};{ligne.credit}"
            for ligne in lignes
        )
    )
    return hashlib.sha256(matiere.encode("utf-8")).hexdigest()


# ----------------------------------------------------------------------------- la generation

def matiere_du_lot(rangs, date_arrete):
    """Les lignes du lot a partir des actifs CALCULABLE relus (REQUETE_ACTIFS) : rend (lignes, examines, titres).

    titres : les codes des titres de filiales valorises a l'actif net reevalue (source ANR_FILIALE), ecartes du lot
    et rapproches par la seule reprise du compte 275 (point 4 de l'en-tete) ; examines : le nombre d'actifs passes a
    la regle, ecart nul compris. Tout autre actif passe par la regle testee unitairement dans le depot, poste par
    poste, titres des comptes 256 et 258 compris. Une ligne au compte 275 est refusee tant que la reprise du 275 ne
    distingue pas les titres de filiales des autres titres (point 4 bis). Fonction sans acces a la base, pour l'essai
    hors ligne."""
    lignes, examines, titres, postes = [], 0, [], {}
    for code, nature, poste, prix, valeur, source, stock in rangs:
        postes[code] = poste
        if (source or "") == SOURCE_TITRES_FILIALES:
            titres.append(code)
            continue
        try:
            compte_difference_estimation(poste or "")
        except NatureNonValorisable:
            raise _Refus(
                f"Génération refusée : le poste du bilan « {poste or 'vide'} » de l'actif {code} ne porte aucun "
                "compte de différence d'estimation (classe 2, rangs 21 à 26, ou classe 3). Corrigez le poste "
                "de l'actif."
            )
        examines += 1
        lignes.extend(
            lignes_difference_estimation(
                Actif(code=code, nature=nature, prix_de_revient=Decimal(str(prix)), poste_bilan=poste),
                Expertise(code_actif=code, date_valeur=date_arrete, valeur_actuelle=Decimal(str(valeur))),
                stock_anterieur=Decimal(str(stock)),
            )
        )
    au_275 = {}
    for ligne in lignes:
        if str(ligne.compte).startswith(COMPTE_TITRES):
            au_275[ligne.code_actif] = au_275.get(ligne.code_actif, Decimal("0")) + ligne.debit - ligne.credit
    if au_275 and not REPRISE_275_DISTINGUE_LES_TITRES:
        cites = "; ".join(f"{code} (poste {postes.get(code) or 'vide'}, {_montant_ecran(montant)})"
                          for code, montant in sorted(au_275.items()))
        raise _Refus(
            f"Génération refusée : la différence d'estimation de {cites} s'écrirait au compte 275, que « Reprendre "
            "l'écart du 275 » rapproche de la seule valeur des titres de filiales ; visée, elle serait contre-passée "
            "par cette reprise. Aucun lot n'est posé tant que cette reprise ne distingue pas les titres de filiales "
            "des autres titres."
        )
    return lignes, examines, titres


def _generer(base, qui: str, arrete: str, entite: str, version: str) -> str:
    connexion = base.connect()
    try:
        curseur = connexion.cursor()

        # 0. LA PORTE DU CRITERE B6 BIS, 1re etape. Cette lecture ouvre aussi la
        #    transaction implicite du pilote, que la garde n° 25 exige.
        curseur.execute(REQUETE_EXPERTISES_SANS_RAPPORT, arrete, entite)
        fautives = curseur.fetchall()
        if fautives:
            codes = ", ".join(sorted({r.code_actif for r in fautives}))
            raise _Refus(
                f"Génération refusée : {len(fautives)} expertise(s) de {entite} au {_date_ecran(arrete)} "
                f"n'ont pas leur rapport au coffre ({codes}). Déposez chaque rapport à la Collecte et "
                "rattachez-le à son actif ou à son entité, puis générez de nouveau."
            )

        # 1. LA GARDE N° 25, avant la lecture de la feuille et l'insertion du lot.
        #    Un refus de la base (numero d'au moins 50000) est un refus francais ; toute autre erreur est une erreur du
        #    moteur, rendue par le point 9 (point 10 de l'en-tete).
        try:
            curseur.execute(REQUETE_GARDE, entite, arrete)
            while curseur.nextset():
                pass
        except Exception as e:
            texte = _refus_de_la_base(e)
            if texte is None:
                raise _ErreurExecution(e, "pr_garde_generer_lot_valorisation")
            raise _Refus(texte, "pr_garde_generer_lot_valorisation")

        # 2. La matiere, bornee a l'entite et aux actifs CALCULABLE.
        curseur.execute(REQUETE_ACTIFS, arrete, entite)
        rangs = curseur.fetchall()
        date_arrete = datetime.date.fromisoformat(arrete)

        # 3. La regle testee unitairement dans le depot, poste par poste ; les titres de filiales valorises a l'actif
        #    net reevalue sont ecartes (point 4 de l'en-tete).
        lignes, examines, titres = matiere_du_lot(rangs, date_arrete)

        note_titres = (f" Les titres de filiales valorisés à l'actif net réévalué ({', '.join(titres)}) passent par "
                       "la reprise du compte 275." if titres else "")
        if not lignes:
            connexion.rollback()
            return (f"Aucun écart à écrire pour {entite} au {_date_ecran(arrete)} : {examines} actif(s) examiné(s), "
                    f"stock déjà à jour.{note_titres}")

        # 4. L'invariant avant d'ecrire, pour un message utile ; le declencheur le verifie de toute facon.
        if not lot_est_equilibre(lignes):
            raise _Refus(f"Génération refusée : le lot calculé n'est pas équilibré (débit "
                         f"{_montant_ecran(total_debit(lignes))}, crédit {_montant_ecran(total_credit(lignes))}).")

        # 5. Libelles de comptes, depuis le referentiel de l'article 411-3.
        comptes = sorted({ligne.compte for ligne in lignes})
        curseur.execute(REQUETE_LIBELLES, ",".join(comptes))
        libelles = {compte: libelle for compte, libelle in curseur.fetchall()}
        manquants = [c for c in comptes if c not in libelles]
        if manquants:
            raise _Refus(f"Génération refusée : compte(s) absent(s) du référentiel des comptes : "
                         f"{', '.join(manquants)}.")

        # 6. La feuille de travail AVANT le lot (ck_lot_source_par_famille).
        cote = cote_de_feuille(arrete, entite)
        nom_fichier = f"{cote}_differences_estimation.xlsx"
        chemin_coffre = f"/Coffre/{entite}/{arrete}/feuilles/{nom_fichier}"
        curseur.execute(REQUETE_FEUILLE, cote, CYCLE_FEUILLE, arrete, entite, MODELE_FEUILLE, ORIGINE_FEUILLE,
                        nom_fichier, chemin_coffre, empreinte_du_contenu(lignes), qui, cote)

        # 7. Le lot, qui cite sa feuille, son identifiant rendu par une variable de table (OUTPUT ... INTO : un
        #    declencheur d'insertion est actif sur lot_ecritures) ; SET NOCOUNT ON pour que le 1er resultat soit le
        #    SELECT.
        curseur.execute(
            """SET NOCOUNT ON;
               DECLARE @lots TABLE (id INT);
               INSERT INTO lot_ecritures
                 (arrete, famille, portee, entite, statut, version_regles,
                  feuille_cote, cree_par)
               OUTPUT INSERTED.id INTO @lots (id)
               VALUES (?, 'DERIVABLE', 'ENTITE', ?, 'PROPOSE', ?, ?, ?);
               SELECT id FROM @lots;""",
            arrete, entite, version, cote, qui,
        )
        lot_id = int(curseur.fetchone()[0])

        # 8. TOUTES les lignes en UNE SEULE instruction, un seul parametre JSON.
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
                    "ecriture_lib": f"Différence d'estimation {ligne.code_actif}",
                    "debit": str(ligne.debit),
                    "credit": str(ligne.credit),
                }
                for ligne in lignes
            ],
            ensure_ascii=False,
        )
        curseur.execute(REQUETE_INSERTION, charge)

        # 9. Les identifiants inseres, relus par une requete separee, puis l'axe actif : le numero d'ecriture encode
        #    le code de l'actif, le format fiscal des 18 champs ne sachant pas transporter d'axe.
        curseur.execute("SELECT id, ecriture_num FROM ecriture WHERE lot_id = ? ORDER BY id", lot_id)
        inserees = curseur.fetchall()
        curseur.executemany(
            "INSERT INTO ecriture_axe (ecriture_id, entite, code_actif) VALUES (?, ?, ?)",
            [(identifiant, entite, numero.split("-", 1)[1]) for identifiant, numero in inserees],
        )

        # 10. La phrase AVANT le commit (point 9 de l'en-tete) : apres lui, plus rien ne leve.
        phrase = (
            f"Lot {lot_id} des différences d'estimation proposé sur la feuille {cote} : {len(lignes)} ligne(s) sur "
            f"{examines} actif(s), {_montant_ecran(total_debit(lignes))} au débit et autant au crédit, règles "
            f"{version}. Il attend le visa du chef de mission.{note_titres}"
        )
        connexion.commit()
    except Exception:
        try:
            connexion.rollback()
        except Exception:
            pass
        raise
    finally:
        try:
            connexion.close()
        except Exception:
            pass

    return phrase


@udf.context(argName="ctx")
@udf.connection(argName="sqlDB", alias="DossierOPCI")
@udf.function()
def generer_lot_valorisation(
    sqlDB: fn.FabricSqlConnection,
    ctx: fn.UserDataFunctionContext,
    arrete: str = "",
    entite: str = "",
    versionRegles: str = "",
) -> str:
    """Bouton « Générer le lot » de l'ecran Valorisation : le lot derivable des differences d'estimation d'une entite a
    un arrete, au statut PROPOSE.

    Retourne la phrase du bouton, le service imposant un type de retour `str` ; un refus remonte en francais par
    UserThrownError. Les noms de parametres emploient la casse chameau, les soulignes etant interdits. versionRegles
    est facultatif, le bouton ne le passe pas (point 7 de l'en-tete).

    ARRETE ET ENTITE ONT UNE VALEUR PAR DEFAUT VIDE (24/10/2026, decision du candidat « 1-A », regle du meme jour : tout
    message a l'ecran en francais) : un parametre facultatif dont la mesure est vide n'est pas envoye par le service, et
    la valeur par defaut le remplace. La fonction lit la base avant la garde (expertises sans rapport) : l'arrete vide
    ou mal forme, puis le vehicule vide sont refuses ici, avant toute lecture. [Entite si generable] etant vide aussi
    par etat, le texte du vehicule vide est celui de l'etude du 24/10/2026 (_scratch/fonctions_fr/
    etude_fonctions_20261024.json, champ « plan »), que la base reprend dans ses procedures. L'ORDRE DES REFUS EST
    CELUI DU PLAN DE L'ETUDE (24/10/2026) : l'arrete, puis le vehicule, puis la version des regles trop longue, que le
    bouton ne passe pas."""
    qui = _qui(ctx)
    version = (versionRegles or "").strip() or VERSION_REGLES
    try:
        try:
            datetime.date.fromisoformat((arrete or "").strip())
        except ValueError:
            raise _Refus("Génération refusée : choisissez l'arrêté dans le sélecteur Arrêté.")
        if not (entite or "").strip():
            raise _Refus(REFUS_VEHICULE)
        if len(version) > VERSION_LONGUEUR_MAX:
            raise _Refus(f"Génération refusée : la version des règles « {version} » dépasse "
                         f"{VERSION_LONGUEUR_MAX} caractères.")
        texte = _generer(sqlDB, qui, arrete.strip(), entite.strip(), version)
    except _Refus as r:
        _poser(sqlDB, qui, entite, r.texte, "REFUS", r.procedure, journal=True)
        raise fn.UserThrownError(r.texte, {"entite": str(entite), "arrete": str(arrete)})
    except fn.UserThrownError:
        raise
    except Exception as e:
        origine = e.origine if isinstance(e, _ErreurExecution) else e
        procedure = e.procedure if isinstance(e, _ErreurExecution) else "generer_lot_valorisation"
        refus = _refus_de_la_base(origine)
        if refus is not None:
            # Point 10 de l'en-tete : un THROW de la base hors de la garde (declencheur d'une table ecrite).
            _poser(sqlDB, qui, entite, refus, "REFUS", procedure, journal=True)
            raise fn.UserThrownError(refus, {"entite": str(entite), "arrete": str(arrete)}) from e
        # Point 9 de l'en-tete : le texte francais au bouton et a la zone de message, le detail au journal seul.
        detail = "Erreur d'exécution de generer_lot_valorisation, %s : %s" % (procedure, _detail(origine))
        _poser(sqlDB, qui, entite, TEXTE_ERREUR, "REFUS", procedure, journal=True, detail=detail)
        raise fn.UserThrownError(TEXTE_ERREUR, {"entite": str(entite), "arrete": str(arrete)}) from e
    _poser(sqlDB, qui, entite, texte, "SUCCES", "generer_lot_valorisation")
    return texte
