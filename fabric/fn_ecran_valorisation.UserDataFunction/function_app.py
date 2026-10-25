"""fn_ecran_valorisation : les boutons de l'ecran Valorisation (ecran 3), une fonction par bouton.

Memes regles que fn_ecran_revision : chaque fonction appelle UNE procedure de la base (lot 1 de la feuille de route
65_JOURNAL/roadmap_ecran_3_valorisation.md), rend la phrase du bouton, prend l'utilisateur dans le contexte d'execution
(PreferredUsername) et jamais dans un parametre, et un refus remonte en francais par UserThrownError.
Connexions : « DossierOPCI » (base) et « Coffre » (lakehouse, raccourci fec vers le site du cabinet). Bibliotheque :
openpyxl. « Generer le lot » n'est pas ici : il appelle fn_valorisation.generer_lot_valorisation (option 1 du lot 0).

Les etapes de l'ecran et leurs boutons :
  1a Immeubles   enregistrer_expertise, proposer_valeur_retenue, exporter_valeurs, importer_valeurs
  1b Avances     enregistrer_revision
  1c Instruments enregistrer_valeur_instrument
  3  Titres      enregistrer_cours
  4  Lots        reprendre_ecart_275, annuler_lot, creer_derogation
  5a Balance     marquer_compte_revu
  5b Groupe      passer_ecritures_miroir
  5c Synthese    proposer_synthese, viser_synthese

UN CHAMP VIDE NE DESACTIVE AUCUN BOUTON : tout parametre lie a un champ de saisie, a un segment de saisie ou a une ligne
choisie est facultatif, la fonction lui donne un defaut vide, et la base refuse en francais en nommant le champ
(refus 50700 a 50799 du lot 1).

LES SELECTEURS ET LES ETATS VIDES (24/10/2026, decision du candidat « 1-A », regle du meme jour : tout message a
l'ecran en francais). Les parametres d'etat ou de droit, jusque-la obligatoires (entite et arrete des selecteurs,
mesures vides par construction), ont aussi une valeur par defaut vide ; seule la decision de viser_synthese, constante
du bouton, reste obligatoire, en tete de la signature. Learn, « Python programming model for Fabric user data
function » (ms.date 2026-01-21, mise a jour du 2026-08-04, relue le 24/10/2026) : « Parameters with default values
are optional at invocation time ». Cas general : la fonction passe la valeur vide telle quelle a la procedure, qui la
refuse en francais avant toute ecriture (THROW d'un numero d'au moins 50000), et la fonction relaie ce refus.
Exception : une fonction qui se sert du champ avant son 1er appel de procedure (lecture de la base, d'une piece ou d'un
classeur, classeur fabrique) le refuse elle-meme, avant de s'en servir, avec le texte de l'etude du 24/10/2026
(_controles) : enregistrer_expertise, proposer_valeur_retenue, exporter_valeurs, importer_valeurs,
enregistrer_valeur_instrument, annuler_lot et viser_synthese.
L'ORDRE DES REFUS EST CELUI DU PLAN DE L'ETUDE (24/10/2026) : une fonction qui oppose elle-meme un refus a une saisie
(un montant qui n'est pas un nombre, _nombre) refuse d'abord, aux textes du plan et dans son ordre, le vehicule puis
l'arrete vides (_controles) : enregistrer_cours et enregistrer_revision. Une saisie illisible et un selecteur vide a la
fois rendent ainsi le texte du selecteur, et non celui de la saisie.

LE MESSAGE S'ECRIT SOUS LE VEHICULE DU SELECTEUR, jamais sous l'entite de l'objet (filiale d'un lot, d'un actif, d'une
feuille) : [Message ecran] ne lit que le vehicule choisi et « - ». Chaque procedure rend une ligne (vehicule, message) ;
la fonction pose ce message par dbo.pr_poser_message_ecran, la reussite comme le refus. Le refus se pose APRES le
rollback de l'action, dans une connexion neuve, et il est journalise par dbo.pr_journaliser_refus.

LES 3 PROCEDURES D'ECRAN EXISTANTES, pr_ecran_annuler_lot, pr_ecran_proposer_synthese et pr_ecran_viser_synthese,
ecrivent leur refus dans la colonne message_ecran de leur objet (lot_ecritures, ref_arrete, synthese_proposee) puis le
relevent par THROW (definitions relues en base le 10/10/2026) : la fonction le pose comme tout refus.

UN MONTANT SAISI se lit en francais (« 5 400 000,00 ») ou en notation decimale (« 5400000.00 ») ; un texte qui n'est pas
un nombre est refuse en nommant le champ.

UNE ERREUR NON PREVUE REMONTE EN FRANCAIS (10/10/2026) : _rendre la change en UserThrownError dont le texte dit que
l'action s'est interrompue ; la zone de message porte ce texte, le detail technique (fonction, procedure, classe, numero
et texte de l'exception) va au seul journal des refus. Le classeur des valeurs absent ou illisible au site du cabinet
est un refus nomme de importer_valeurs, et non une exception du client de fichiers.

UN REFUS DE LA BASE SE DISTINGUE D'UNE ERREUR DU MOTEUR SQL PAR SON NUMERO (10/10/2026). THROW n'admet que des numeros
d'au moins 50000 : _executer_tout rend le texte francais d'une erreur qui en porte un (refus 50700 a 50799, 50303, refus
des declencheurs). Toute autre erreur d'une procedure, sans numero (delai ou coupure du pilote) ou de numero inferieur
(interblocage 1205, delai de verrou 1222, depassement 8115, conversion, contrainte), est relevee telle quelle apres le
rollback, et _rendre la rend en francais : jamais un texte anglais au bouton ni a la zone de message.

LA REFERENCE CROISEE DE marquer_compte_revu (10/10/2026). La page retenue inscrit un parametre facultatif xref. La
procedure ne le recoit pas : elle rattache le compte a la feuille de valorisation la plus recente du vehicule a
l'arrete. Vide, xref laisse ce choix a la procedure ; saisi, il doit nommer cette feuille, sinon la fonction refuse en
francais avant tout appel, plutot que de rattacher le compte a une autre feuille que celle saisie.
"""

import datetime
import io
import json
import re
from decimal import Decimal, InvalidOperation

import fabric.functions as fn

udf = fn.UserDataFunctions()


# ----------------------------------------------------------------------------- outils, identiques a fn_ecran_revision

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


# THROW n'admet que des numeros d'au moins 50000 (en-tete, refus de la base et erreur du moteur).
PREMIER_NUMERO_DE_REFUS = 50000


def _numero_sql(exc):
    """Le numero d'erreur de SQL Server que porte l'exception, celui du 1er enregistrement, ou None quand elle n'en
    porte pas (delai ou coupure du pilote, erreur Python)."""
    m = re.search(r"\[SQL Server\].*?\s\((\d+)\)\s\(SQL\w+\)", _texte_pilote(exc), re.S)
    return int(m.group(1)) if m else None


def _refus_de_la_base(exc):
    """Le texte francais d'un refus de la base (numero d'au moins 50000), ou None pour toute autre erreur."""
    n = _numero_sql(exc)
    return _message_sql(exc) if n is not None and n >= PREMIER_NUMERO_DE_REFUS else None


def _detail(exc) -> str:
    """Le detail technique d'une erreur non prevue, pour le seul journal des refus : classe, numero, texte."""
    n = _numero_sql(exc)
    return "%s%s : %s" % (exc.__class__.__name__, "" if n is None else " n° %d" % n, _message_sql(exc) or _texte(exc))


def _nom_procedure(sql) -> str:
    m = re.search(r"EXEC dbo\.(\w+)", sql or "")
    return m.group(1)[:128] if m else "inconnue"


class _Action:
    """L'action en cours : la base, la personne connectee, l'entite du message, les procedures appelees et le texte
    du dernier refus de la base."""

    def __init__(self, base, qui, entite):
        self.base, self.qui = base, qui
        e = None if entite is None else str(entite).strip()
        self.entite = e[:20] if e else None
        self.procedures, self.refus = [], None


def _action(base, ctx, entite) -> _Action:
    return _Action(base, _qui(ctx), entite)


def _refus(g: _Action, texte: str):
    """Un refus de la fonction elle-meme, avant toute procedure : son texte est retenu pour la zone de message."""
    g.refus = texte
    return fn.UserThrownError(texte, {})


def _texte(e) -> str:
    v = getattr(e, "message", None)
    if isinstance(v, str) and v.strip():
        return v
    return str(e) or e.__class__.__name__


def _poser(g: _Action, message, genre: str, procedure: str, journal: bool = False, detail: str = None) -> None:
    """Ecrit le message de l'action dans dbo.message_ecran, et le refus dans dbo.journal_refus quand journal est vrai ;
    detail, quand il est donne, remplace le message au journal seul (le detail technique d'une erreur non prevue).
    UNE CONNEXION NEUVE, donc une transaction neuve. Ne leve jamais : un message qui echoue ne masque pas l'action."""
    texte = (message or "").strip()[:2000]
    if not texte or not g.qui:
        return
    try:
        conn = g.base.connect()
    except Exception:
        return
    try:
        if journal:
            try:
                cur = conn.cursor()
                cur.execute("EXEC dbo.pr_journaliser_refus @procedure_nom=?, @message=?, @par=?, @entite=?",
                            (procedure[:128], ((detail or "").strip()[:2000] or texte), g.qui, g.entite))
                cur.close()
                conn.commit()
            except Exception:
                try:
                    conn.rollback()
                except Exception:
                    pass
        cur = conn.cursor()
        cur.execute("EXEC dbo.pr_poser_message_ecran @pour=?, @message=?, @genre=?, @entite=?, @procedure_nom=?",
                    (g.qui, texte, genre, g.entite, procedure[:128]))
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


TEXTE_ERREUR = ("Action interrompue par une erreur d'exécution. Le détail technique est consigné au journal des refus ; "
                "relisez l'écran avant de recommencer.")


def _rendre(g: _Action, nom: str, faire):
    """Execute l'action, puis pose son message : la phrase rendue a la reussite, le texte du refus sinon.
    faire() rend la phrase, ou (phrase, genre) quand la reussite porte des refus partiels (reimport du classeur)."""
    try:
        r = faire()
    except fn.UserThrownError as e:
        _poser(g, g.refus or _texte(e), "REFUS", (g.procedures[-1] if g.procedures else nom), journal=True)
        raise
    except Exception as e:
        # Erreur non prevue, du moteur SQL, du pilote ou de Python : le texte francais au bouton et a la zone de
        # message, le detail au journal seul.
        procedure = g.procedures[-1] if g.procedures else nom
        detail = "Erreur d'exécution de %s, %s : %s" % (nom, procedure, _detail(e))
        _poser(g, TEXTE_ERREUR, "REFUS", procedure, journal=True, detail=detail)
        raise fn.UserThrownError(TEXTE_ERREUR, {"fonction": nom}) from e
    texte, genre = r if isinstance(r, tuple) else (r, "SUCCES")
    _poser(g, texte, genre, (g.procedures[0] if g.procedures else nom))
    return texte


def _executer_tout(base: fn.FabricSqlConnection, sql: str, params: tuple, g: _Action = None) -> list:
    """Execute une procedure et rend les lignes de TOUS ses jeux de resultats, dans l'ordre ; leve ses refus. L'action
    g retient la procedure et le texte du refus, que _rendre pose apres ce rollback. Seul un refus de la base (numero
    d'au moins 50000) devient une UserThrownError a son texte ; toute autre erreur est relevee telle quelle apres le
    rollback, et _rendre la rend en francais (en-tete)."""
    if g is not None:
        g.procedures.append(_nom_procedure(sql))
        g.refus = None
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        lignes = []
        while True:
            if cur.description:
                colonnes = [d[0] for d in cur.description]
                lignes.extend(dict(zip(colonnes, l)) for l in cur.fetchall())
            if not cur.nextset():
                break
        conn.commit()
        return lignes
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        message = _refus_de_la_base(e)
        if message is None:
            raise
        if g is not None:
            g.refus = message
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        try:
            conn.close()
        except Exception:
            pass


def _executer(base: fn.FabricSqlConnection, sql: str, params: tuple, g: _Action = None) -> dict:
    """La ligne qui porte le message, sinon la derniere ligne rendue."""
    lignes = _executer_tout(base, sql, params, g)
    portant = [l for l in lignes if "message" in l]
    return (portant or lignes or [{}])[-1]


def _lire(base: fn.FabricSqlConnection, sql: str, params: tuple) -> list:
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        colonnes = [d[0] for d in cur.description]
        return [dict(zip(colonnes, l)) for l in cur.fetchall()]
    finally:
        conn.close()


def _vide(s):
    return None if s is None or str(s).strip() == "" else str(s).strip()


def _superviseur(g: _Action, superviseur: str) -> None:
    if not superviseur or superviseur.strip().lower() != g.qui.strip().lower():
        raise _refus(g, "Le visa est réservé au superviseur connecté ; l'action n'est pas exécutée.")


# LES REFUS DES CHAMPS VIDES QUE LA FONCTION OPPOSE ELLE-MEME (24/10/2026, exception au cas general de l'en-tete) : les
# textes de l'etude du 24/10/2026 (_scratch/fonctions_fr/etude_fonctions_20261024.json, champ « plan »), mot pour mot,
# un seul texte par champ, que la base reprend dans ses procedures.
REFUS_VEHICULE = "Choisissez le véhicule dans le sélecteur Véhicule."
REFUS_ARRETE = "Choisissez l'arrêté dans le sélecteur Arrêté."
REFUS_LOT = "Choisissez dans la grille « Lots de valorisation de l’arrêté » un lot au statut proposé."
REFUS_SYNTHESE_A_VISER = ("Visa refusé : aucune synthèse proposée n'attend de visa pour le véhicule du sélecteur "
                          "Véhicule à cet arrêté ; une synthèse visée ne se vise plus.")


def _controles(g: _Action, champs) -> None:
    """Les controles d'entree d'une fonction qui se sert d'un champ avant son 1er appel de procedure : champs,
    [(valeur, texte du refus)] dans l'ordre de l'etude ; la 1re valeur vide est refusee en francais, avant toute lecture
    ou procedure de la base, le refus etant ensuite journalise et pose par _rendre."""
    for valeur, texte in champs:
        if _vide(valeur) is None:
            raise _refus(g, texte)


_ESPACES = (" ", " ", " ")


def _nombre(g: _Action, valeur, libelle: str):
    """Le nombre d'une saisie, en Decimal, ou None quand le champ est vide : la base refuse alors en nommant le champ.
    « 5 400 000,00 » et « 5400000.00 » se lisent ; un texte qui n'est pas un nombre est refuse ici."""
    if valeur is None:
        return None
    if isinstance(valeur, (int, float, Decimal)):
        return Decimal(str(valeur))
    t = _vide(valeur)
    if t is None:
        return None
    s = t
    for e in _ESPACES:
        s = s.replace(e, "")
    if "," in s and "." in s:
        s = s.replace(".", "")
    s = s.replace(",", ".")
    try:
        d = Decimal(s)
    except InvalidOperation:
        raise _refus(g, f"« {libelle} » : « {t} » n'est pas un nombre.")
    if not d.is_finite():
        raise _refus(g, f"« {libelle} » : « {t} » n'est pas un nombre.")
    return d


def _piece(base, g: _Action, entite: str, arrete: str, nom, libelle: str):
    """L'identifiant d'une piece choisie par son nom de fichier (ou son numero) dans le perimetre du vehicule a
    l'arrete, par dbo.fn_e3_piece_par_nom ; None quand le champ est vide, refus quand elle est inconnue ou ambigue."""
    n = _vide(nom)
    if n is None:
        return None
    l = _lire(base, "SELECT dbo.fn_e3_piece_par_nom(?, ?, ?) AS id", (entite, arrete, n))
    pid = l[0]["id"] if l else None
    if pid is None or int(pid) == -1:
        raise _refus(g, f"La pièce « {n} » de la liste « {libelle} » est inconnue ou ambiguë pour ce véhicule à cet "
                        "arrêté.")
    return int(pid)


def _date_ecran(arrete: str) -> str:
    try:
        return datetime.date.fromisoformat(arrete).strftime("%d/%m/%Y")
    except ValueError:
        return arrete


def _montant_ecran(x) -> str:
    """2 decimales, separateur de milliers U+202F et virgule decimale, comme FORMAT(x, 'N2', 'fr-FR') de la base."""
    return "{:,.2f}".format(Decimal(str(x))).replace(",", " ").replace(".", ",")


# ----------------------------------------------------------------------------- 1a, les immeubles

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def enregistrer_expertise(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                          arrete: str = "", actif: str = "", valeur: str = "", piece: str = "") -> str:
    """Bouton « Enregistrer l'expertise » : la valeur d'expertise de l'immeuble choisi, rattachee au rapport choisi
    dans la liste « Rapport au coffre » (nom du fichier, traduit en piece dans le perimetre du vehicule a l'arrete).
    Remplacement (a) a (e) par la base : pr_ecran_enregistrer_expertise. La piece se lit au perimetre du vehicule a
    l'arrete avant la procedure : le vehicule puis l'arrete vides sont refuses ici (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        v = _nombre(g, valeur, "Valeur actuelle hors droits")
        p = _piece(base, g, entite, arrete, piece, "Rapport au coffre")
        r = _executer(base, "EXEC dbo.pr_ecran_enregistrer_expertise @vehicule=?, @arrete=?, @code_actif=?, @valeur=?, "
                            "@piece_id=?, @par=?", (entite, arrete, _vide(actif), v, p, g.qui), g)
        return r.get("message") or "Expertise enregistrée."
    return _rendre(g, "enregistrer_expertise", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def proposer_valeur_retenue(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                            arrete: str = "", actif: str = "", valeur: str = "", source: str = "", motif: str = "",
                            piece: str = "") -> str:
    """Bouton « Proposer la valeur retenue » : la valeur retenue de l'actif choisi, sa source (libelle ou code de
    ref_source_valeur saisissable), le motif de l'ecart et la piece qui la fonde ; la ligne de evaluation_actif porte
    l'entite detentrice de l'actif. pr_ecran_proposer_valeur_retenue. La piece se lit au perimetre du vehicule a
    l'arrete avant la procedure : le vehicule puis l'arrete vides sont refuses ici (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        v = _nombre(g, valeur, "Valeur retenue")
        p = _piece(base, g, entite, arrete, piece, "Pièce de la valeur")
        r = _executer(base, "EXEC dbo.pr_ecran_proposer_valeur_retenue @vehicule=?, @arrete=?, @code_actif=?, @valeur=?, "
                            "@source=?, @motif=?, @piece_id=?, @par=?",
                      (entite, arrete, _vide(actif), v, _vide(source), _vide(motif), p, g.qui), g)
        return r.get("message") or "Valeur retenue proposée."
    return _rendre(g, "proposer_valeur_retenue", faire)


# LE CLASSEUR DES VALEURS : une ligne par actif a valeur saisie (immeubles et instruments) du vehicule et de ses
# filiales a l'arrete (v_ecran_valeurs_arrete). Ligne 1 : les libelles ; ligne 2 : les cles, que le reimport lit ; a
# partir de la ligne 3, les actifs. Les colonnes de saisie sont celles du contrat de pr_importer_valeurs. L'expertise et
# son rapport sont preremplis : un reimport sans changement les rend « inchangées ». La valeur retenue, sa source, son
# motif et sa piece sont VIDES : la valeur en place et son etat se lisent dans 2 colonnes de lecture, et un reimport
# sans changement ne repropose donc aucune valeur deja visee ou renvoyee.
_ONGLET_VALEURS = "Valeurs"
_COL_VALEURS = [("Entité", "entite"), ("Actif", "actif"), ("Nature", "nature"), ("Prix de revient", "prix_de_revient"),
                ("Valeur d'expertise", "valeur_expertise"), ("Rapport", "rapport"),
                ("Valeur retenue en place", "valeur_retenue_en_place"), ("État de la valeur", "etat_valeur"),
                ("Valeur retenue", "valeur_retenue"), ("Source", "source"), ("Motif de l'écart", "motif"),
                ("Pièce", "piece"), ("État de l'actif", "etat")]
_SAISIE_VALEURS = {"valeur_expertise", "rapport", "valeur_retenue", "source", "motif", "piece"}
_CLES_IMPORT = ("actif", "valeur_expertise", "rapport", "valeur_retenue", "source", "motif", "piece")
_NOMBRES_IMPORT = {"valeur_expertise": "Valeur d'expertise", "valeur_retenue": "Valeur retenue"}


def _fichier_valeurs(entite: str, arrete: str) -> str:
    return f"valeurs_{entite}_{arrete}.xlsx"


def _classeur_valeurs(donnees):
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill
    from openpyxl.utils import get_column_letter
    wb = Workbook()
    ws = wb.active
    ws.title = _ONGLET_VALEURS
    creme = PatternFill("solid", fgColor="FFF8E7")
    for j, (lib, cle) in enumerate(_COL_VALEURS, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = PatternFill("solid", fgColor="1D1A10")
        c.font = Font(bold=True, color="FFFFFF") if cle in _SAISIE_VALEURS else Font(color="D9D2C0")
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
        ws.column_dimensions[get_column_letter(j)].width = max(12, len(lib) + 4)
    for i, d in enumerate(donnees, 3):
        for j, (lib, cle) in enumerate(_COL_VALEURS, 1):
            v = d.get(cle)
            c = ws.cell(row=i, column=j, value=float(v) if isinstance(v, Decimal) else v)
            if cle in _SAISIE_VALEURS:
                c.fill = creme
            if isinstance(v, Decimal):
                c.number_format = "#,##0.00"
    ws.freeze_panes = "A3"
    return wb


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_valeurs(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                     arrete: str = "") -> str:
    """Bouton « Exporter le classeur » : le classeur des valeurs du vehicule et de ses filiales a l'arrete, depose au
    site du cabinet (Dossiers de travail/<vehicule>/<arrete>/valeurs_<vehicule>_<arrete>.xlsx) par
    pr_deposer_classeur, qui rend son adresse SharePoint. Les valeurs se lisent en base avant la procedure : le
    vehicule puis l'arrete vides sont refuses ici (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        import base64
        donnees = _lire(base, """
            SELECT v.entite, v.code_actif AS actif, v.nature, v.prix_de_revient, v.valeur_expertise, v.rapport_nom AS rapport,
                   v.valeur_proposee AS valeur_retenue_en_place, v.etat_valeur_libelle AS etat_valeur, v.etat
            FROM dbo.v_ecran_valeurs_arrete v
            WHERE v.vehicule = ? AND v.arrete = ?
            ORDER BY v.ordre_entite, v.code_actif""", (entite, arrete))
        if not donnees:
            raise _refus(g, f"Aucun immeuble ni instrument du véhicule {entite} ou de ses filiales n'est à valoriser au "
                            f"{_date_ecran(arrete)} : le classeur n'est pas déposé.")
        wb = _classeur_valeurs(donnees)
        tampon = io.BytesIO()
        wb.save(tampon)
        r = _executer(base, "EXEC dbo.pr_deposer_classeur @entite=?, @arrete=?, @fichier=?, @contenu_base64=?, @par=?",
                      (entite, arrete, _fichier_valeurs(entite, arrete),
                       base64.b64encode(tampon.getvalue()).decode("ascii"), g.qui), g)
        return (f"Classeur des valeurs, {len(donnees)} actif(s), déposé au site du cabinet : "
                f"{r.get('web_url') or 'adresse non rendue'}")
    return _rendre(g, "exporter_valeurs", faire)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def importer_valeurs(base: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient, ctx: fn.UserDataFunctionContext,
                     entite: str = "", arrete: str = "", chemin: str = "") -> str:
    """Bouton « Réimporter le classeur » : le classeur des valeurs enregistre au site du cabinet, relu par le raccourci
    fec du coffre (un raccourci SharePoint ne sait que lire), puis pr_importer_valeurs, ligne a ligne sous les
    controles de la saisie ; une ligne refusee est citee et n'arrete pas les autres. Un refus partiel s'affiche en
    refus. Le classeur se lit avant la procedure : le vehicule puis l'arrete vides sont refuses ici (_controles,
    en-tete), avant le refus existant du chemin vide."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        from openpyxl import load_workbook
        c = _vide(chemin)
        if c is None:
            raise _refus(g, "Aucun classeur des valeurs n'est déposé pour cet arrêté : exportez-le d'abord.")
        source = "site du cabinet" if c.startswith("fec/") else "coffre"
        fichier = c.rsplit("/", 1)[-1]
        try:
            octets = coffre.connectToFiles().get_file_client(c).download_file().readall()
        except Exception:
            raise _refus(g, f"Le classeur {fichier} n'a pas pu être lu au {source} : exportez le classeur des valeurs "
                            "de cet arrêté, puis réimportez-le.")
        try:
            wb = load_workbook(io.BytesIO(octets), data_only=True)
        except Exception:
            raise _refus(g, f"Le fichier {fichier} n'est pas un classeur Excel lisible : exportez le classeur des "
                            "valeurs de cet arrêté, puis réimportez-le.")
        ws = wb[_ONGLET_VALEURS] if _ONGLET_VALEURS in wb.sheetnames else wb.worksheets[0]
        cles = [x.value for x in ws[2]]
        if "actif" not in cles:
            raise _refus(g, f"Le classeur {c.rsplit('/', 1)[-1]} n'est pas un classeur des valeurs : la ligne 2 ne "
                            "porte pas la clé « actif ».")
        lignes = []
        for n, rangee in enumerate(ws.iter_rows(min_row=3, values_only=True), 3):
            d = {k: v for k, v in zip(cles, rangee) if k}
            if all(d.get(k) is None or str(d.get(k)).strip() == "" for k in _CLES_IMPORT):
                continue
            ligne = {"ligne": n}
            for k in _CLES_IMPORT:
                v = d.get(k)
                if k in _NOMBRES_IMPORT:
                    try:
                        x = _nombre(g, v, _NOMBRES_IMPORT[k])
                    except fn.UserThrownError:
                        raise _refus(g, f"Ligne {n} du classeur : « {_NOMBRES_IMPORT[k]} » : « {v} » n'est pas un "
                                        "nombre ; aucune ligne n'est importée.")
                    ligne[k] = None if x is None else str(x)
                else:
                    ligne[k] = _vide(v)
            lignes.append(ligne)
        if not lignes:
            raise _refus(g, f"Le classeur {c.rsplit('/', 1)[-1]} ne porte aucune ligne à importer.")
        r = _executer(base, "EXEC dbo.pr_importer_valeurs @vehicule=?, @arrete=?, @lignes=?, @par=?",
                      (entite, arrete, json.dumps(lignes, ensure_ascii=False), g.qui), g)
        texte = f"Classeur relu au {source}. " + (r.get("message") or "Classeur réimporté.")
        return texte, ("REFUS" if int(r.get("refusees") or 0) > 0 else "SUCCES")
    return _rendre(g, "importer_valeurs", faire)


# ----------------------------------------------------------------------------- 1b, 1c et 3 : avances, instruments, titres

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def enregistrer_revision(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                         arrete: str = "", avance: str = "", montant: str = "", motif: str = "") -> str:
    """Bouton « Enregistrer la révision » : le montant revise de l'avance en compte courant choisie, et son motif.
    pr_ecran_enregistrer_revision. Le vehicule puis l'arrete vides sont refuses ici avant le montant, dans l'ordre du
    plan de l'etude (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        m = _nombre(g, montant, "Montant révisé")
        r = _executer(base, "EXEC dbo.pr_ecran_enregistrer_revision @vehicule=?, @arrete=?, @code_actif=?, "
                            "@montant_revise=?, @motif=?, @par=?", (entite, arrete, _vide(avance), m, _vide(motif), g.qui), g)
        return r.get("message") or "Révision enregistrée."
    return _rendre(g, "enregistrer_revision", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def enregistrer_valeur_instrument(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                                  arrete: str = "", actif: str = "", valeur: str = "", source: str = "",
                                  piece: str = "") -> str:
    """Bouton « Enregistrer la valeur » : la valeur actuelle de l'instrument financier de classe 3 choisi (art. 113-2
    du reglement ANC n° 2021-09, renvoi au reglement ANC n° 2020-07), sa source et sa piece.
    pr_ecran_enregistrer_valeur_instrument. La piece se lit au perimetre du vehicule a l'arrete avant la procedure : le
    vehicule puis l'arrete vides sont refuses ici (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        v = _nombre(g, valeur, "Valeur actuelle")
        p = _piece(base, g, entite, arrete, piece, "Pièce de la valeur")
        r = _executer(base, "EXEC dbo.pr_ecran_enregistrer_valeur_instrument @vehicule=?, @arrete=?, @code_actif=?, "
                            "@valeur_actuelle=?, @source=?, @piece_id=?, @par=?",
                      (entite, arrete, _vide(actif), v, _vide(source), p, g.qui), g)
        return r.get("message") or "Valeur enregistrée."
    return _rendre(g, "enregistrer_valeur_instrument", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def enregistrer_cours(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                      arrete: str = "", titre: str = "", quantite: str = "", cours: str = "", source: str = "") -> str:
    """Bouton « Enregistrer le cours » : la quantite et le cours d'un titre du vehicule inscrit au compte 256 ou 258,
    et la source du cours. pr_ecran_enregistrer_cours. Le vehicule puis l'arrete vides sont refuses ici avant la
    quantite et le cours, dans l'ordre du plan de l'etude (_controles, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        q = _nombre(g, quantite, "Quantité")
        c = _nombre(g, cours, "Cours")
        r = _executer(base, "EXEC dbo.pr_ecran_enregistrer_cours @vehicule=?, @arrete=?, @code_actif=?, @quantite=?, "
                            "@cours=?, @source=?, @par=?", (entite, arrete, _vide(titre), q, c, _vide(source), g.qui), g)
        return r.get("message") or "Cours enregistré."
    return _rendre(g, "enregistrer_cours", faire)


# ----------------------------------------------------------------------------- 4, les lots

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def reprendre_ecart_275(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                        arrete: str = "") -> str:
    """Bouton « Reprendre l'écart du 275 » : pr_reprendre_ecart_275 appelee avec @a_blanc = 0 (son defaut vaut 1),
    qui pose un lot DERIVABLE PROPOSE de reprise du compte 275 sur le vehicule, ou dit que le compte egale deja sa
    cible. Un 2e lot de reprise propose et non vise est refuse par la base (50796)."""
    g = _action(base, ctx, entite)

    def faire():
        lignes = _executer_tout(base, "EXEC dbo.pr_reprendre_ecart_275 @entite=?, @arrete=?, @a_blanc=?, @par=?",
                                (entite, arrete, 0, g.qui), g)
        pose = [l for l in lignes if l.get("lot_pose") is not None]
        if pose:
            p = pose[-1]
            return (f"Lot {p['lot_pose']} de reprise du compte 275 proposé : {_montant_ecran(p.get('montant') or 0)}, "
                    f"cible du 275 {_montant_ecran(p.get('cible_du_275') or 0)}. Il attend le visa du chef de mission.")
        lu = [l for l in lignes if l.get("lecture")]
        return (lu[-1]["lecture"][:1].upper() + lu[-1]["lecture"][1:] + ".") if lu else \
            "Reprise du compte 275 : aucun lot posé."
    return _rendre(g, "reprendre_ecart_275", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def annuler_lot(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "", arrete: str = "",
                lot: str = "", motif: str = "") -> str:
    """Bouton « Annuler le lot » : le lot choisi, s'il appartient au perimetre du vehicule a l'arrete
    (v_lots_perimetre), passe au statut REJETE par pr_ecran_annuler_lot, qui ne recoit aucune entite. Le message
    s'ecrit sous le vehicule, jamais sous l'entite du lot. La base exige le motif. Le perimetre se lit avant la
    procedure : le vehicule, l'arrete puis le lot vides sont refuses ici (_controles, en-tete) ; le texte du lot vaut
    aussi pour un lot qui n'est pas un numero, [Lot annulable] etant vide pour un lot qui n'est pas au statut
    propose."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        n = _vide(lot)
        if n is None or not re.fullmatch(r"\d+", n):
            raise _refus(g, REFUS_LOT)
        if not _lire(base, "SELECT 1 AS x FROM dbo.v_lots_perimetre WHERE vehicule = ? AND arrete = ? AND lot_id = ?",
                     (entite, arrete, int(n))):
            raise _refus(g, f"Le lot {n} n'appartient ni au véhicule {entite} ni à l'une de ses filiales au "
                            f"{_date_ecran(arrete)}.")
        _executer_tout(base, "EXEC dbo.pr_ecran_annuler_lot @lot_id=?, @par=?, @motif=?", (int(n), g.qui, _vide(motif)), g)
        return f"Lot {n} annulé : il passe au statut rejeté et garde ses écritures."
    return _rendre(g, "annuler_lot", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def creer_derogation(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "", arrete: str = "",
                     feuille: str = "", motif: str = "") -> str:
    """Bouton « Créer la dérogation » : une derogation sur la feuille de valorisation choisie, avec son motif ; elle
    attend le visa du chef de mission. pr_ecran_creer_derogation."""
    g = _action(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_creer_derogation @vehicule=?, @arrete=?, @cote=?, @motif=?, @par=?",
                      (entite, arrete, _vide(feuille), _vide(motif), g.qui), g)
        return r.get("message") or "Dérogation créée."
    return _rendre(g, "creer_derogation", faire)


# ----------------------------------------------------------------------------- 5, balance, groupe et synthese

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def marquer_compte_revu(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                        arrete: str = "", compte: str = "", xref: str = "") -> str:
    """Bouton « Marquer le compte revu » : le compte choisi dans la balance de la valorisation passe a l'etat conclu,
    rattache a une feuille du vehicule a l'arrete. pr_ecran_marquer_compte_revu. xref, champ « Référence croisée »,
    est facultatif : vide, la procedure rattache le compte a la feuille de valorisation la plus recente ; saisi, il
    passe a la procedure (@xref, 63_SQL/291, 10/10/2026), qui refuse en 50773 une feuille qui n'est pas du vehicule a
    l'arrete."""
    g = _action(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_marquer_compte_revu @vehicule=?, @arrete=?, @compte=?, @par=?, "
                            "@xref=?", (entite, arrete, _vide(compte), g.qui, _vide(xref)), g)
        return r.get("message") or "Compte revu."
    return _rendre(g, "marquer_compte_revu", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def passer_ecritures_miroir(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                            arrete: str = "") -> str:
    """Bouton « Passer les écritures miroir » : les ecritures miroir des flux intragroupe du vehicule et de ses
    filiales qui restent a passer, un lot DECIDEE PROPOSE par entite. pr_ecran_passer_ecritures_miroir, limitee au
    vehicule."""
    g = _action(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_passer_ecritures_miroir @entite=?, @arrete=?, @par=?",
                      (entite, arrete, g.qui), g)
        return r.get("message") or "Écritures miroir passées."
    return _rendre(g, "passer_ecritures_miroir", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def proposer_synthese(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                      arrete: str = "") -> str:
    """Bouton « Proposer la synthèse » : pr_ecran_proposer_synthese, qui releve les refus 50077 a 50080 et 50780 de
    pr_proposer_synthese."""
    g = _action(base, ctx, entite)

    def faire():
        _executer_tout(base, "EXEC dbo.pr_ecran_proposer_synthese @entite=?, @arrete=?, @par=?", (entite, arrete, g.qui), g)
        s = _lire(base, "SELECT TOP 1 id FROM dbo.synthese_proposee WHERE entite = ? AND arrete = ? AND perime_le IS NULL "
                        "ORDER BY propose_le DESC", (entite, arrete))
        if not s:
            raise _refus(g, "La synthèse n'a pas été proposée : aucune synthèse en cours n'est relue après l'appel.")
        return (f"Synthèse de l'arrêté du {_date_ecran(arrete)} proposée (n° {s[0]['id']}) : elle attend le visa du chef "
                "de mission.")
    return _rendre(g, "proposer_synthese", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def viser_synthese(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, decision: str, entite: str = "",
                   arrete: str = "", superviseur: str = "", motif: str = "") -> str:
    """Boutons « Viser la synthèse » et « Renvoyer la synthèse » : pr_ecran_viser_synthese. Le parametre superviseur
    est lie a la mesure [Superviseur connecte SYNTHESE] : vide pour qui ne tient pas le role, et il doit egaler la
    personne connectee. La base controle le role sur le vehicule (tr_visa_separation_des_roles, 50051). La decision,
    constante du bouton, reste obligatoire, en tete ; la synthese se lit avant la procedure : l'arrete vide, le droit,
    puis le vehicule vide sont refuses ici (_controles, _superviseur, en-tete)."""
    g = _action(base, ctx, entite)

    def faire():
        _controles(g, [(arrete, REFUS_ARRETE)])
        _superviseur(g, superviseur)
        _controles(g, [(entite, REFUS_SYNTHESE_A_VISER)])
        s = _lire(base, "SELECT TOP 1 id FROM dbo.synthese_proposee WHERE entite = ? AND arrete = ? AND perime_le IS NULL "
                        "ORDER BY propose_le DESC", (entite, arrete))
        if not s:
            raise _refus(g, "Visa refusé : aucune synthèse en cours n'est proposée pour cet arrêté, ou celle qui l'était "
                            "est périmée par le visa d'un lot postérieur. Proposer la synthèse de nouveau.")
        d = (decision or "").strip().upper()
        _executer_tout(base, "EXEC dbo.pr_ecran_viser_synthese @entite=?, @arrete=?, @decision=?, @motif=?, @par=?",
                       (entite, arrete, d, _vide(motif), g.qui), g)
        return ("Synthèse visée." if d == "VISE" else "Synthèse renvoyée.") + \
            f" Arrêté du {_date_ecran(arrete)}, synthèse n° {s[0]['id']}."
    return _rendre(g, "viser_synthese", faire)
