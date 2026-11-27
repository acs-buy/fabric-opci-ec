"""fn_ecran_revision : les boutons de l'ecran Revision, une fonction par bouton.

Memes regles que fn_ecran_client : chaque fonction appelle UNE procedure, rend la phrase du bouton, prend
l'utilisateur dans le contexte d'execution (PreferredUsername), et un refus remonte en francais par
UserThrownError. Connexions : « DossierOPCI » (base) et « Coffre » (lakehouse). Bibliotheque : openpyxl.

Les etapes de l'ecran et leurs boutons :
  Collecte      reclamer_document (fn_ecran_client la porte deja ; rappelee ici pour la page)
  Programme     choisir_programme, ajuster_programme, verifier_couverture, exporter_questions
  Questions     repondre_question, ouvrir_feuille, exporter_feuille, importer_classeur (feuille, OD,
                questions), conclure_feuille, exporter_od, inscrire_piece (fn_ecran_client), valider_od_question
  OD libres     saisir_od, exporter_od (sans question), importer_classeur, valider_od_libres
  Conclure      conclure_cycle, viser (nature CYCLE ou REVUE, parametre superviseur obligatoire),
                conclure_revue
  Livrables     exporter_dossier, demander_deverrouillage, importer_classeur (dossier entier), arreter_forme_rapport,
                saisir_cellule_annexe, recalculer_annexe, valider_pour_le_client

UN CHAMP VIDE NE DESACTIVE AUCUN BOUTON : tout parametre lie a un champ de saisie est facultatif, la fonction lui donne
un defaut vide et refuse en francais quand il manque (_obligatoires). Le service desactive un bouton dont un parametre
obligatoire est vide, et sa bulle est en anglais ; un bouton reste donc gris pour un droit ou un etat, jamais pour un
champ vide.

LES SELECTEURS, LES CHOIX ET LES ETATS VIDES (24/10/2026 ; tout message a l'ecran est en francais). Chaque parametre d'une fonction qu'appelle un bouton des ecrans 2 et 3 a une valeur par
defaut vide, sauf les constantes du bouton (actif, nature, decision, reponse), obligatoires et en tete de la signature.
Learn, « Python programming model for Fabric user data function » (ms.date 2026-01-21, mise a jour du 2026-08-04, relue
le 24/10/2026) : « Parameters with default values are optional at invocation time » ; un parametre facultatif dont la
mesure est vide n'est pas envoye, et sa valeur par defaut le remplace.
Cas general : la fonction passe la valeur vide telle quelle a la procedure, qui la refuse en francais avant toute
ecriture (THROW d'un numero d'au moins 50000), et la fonction relaie ce refus. Exception : une fonction qui se sert du
champ avant son 1er appel de procedure (lecture de la base, lecture ou fabrication d'un classeur) le refuse elle-meme,
avant de s'en servir, avec le texte de _controles : repondre_question, conclure_feuille,
valider_od_question, exporter_questions, exporter_od, exporter_dossier et importer_classeur.
L'ORDRE DES REFUS EST FIXE (24/10/2026) : une fonction qui oppose elle-meme un refus a un champ de
saisie ou a une ligne choisie (_obligatoires, ecriture sans compte, ligne du brouillon libre) refuse d'abord, aux
textes de _controles et dans leur ordre, les parametres places avant ce controle : conclure_cycle,
conclure_revue, saisir_od, saisir_od_double et retirer_ligne_od. Un champ et un selecteur vides a la fois rendent ainsi
le texte du selecteur, et non celui du champ.

UNE ERREUR NON PREVUE REMONTE EN FRANCAIS (24/10/2026), comme dans fn_ecran_arrete et fn_ecran_valorisation : seul un
refus de la base (numero d'au moins 50000) devient le texte du bouton et de la zone de message ; toute autre erreur, du
moteur SQL (numero inferieur), du pilote, du stockage ou de Python, rend TEXTE_ERREUR, le detail technique allant au
seul journal des refus, par une UserThrownError (reponse 422) et non plus par la relance brute (reponse 500). Le
classeur absent du site du cabinet est un refus nomme de importer_classeur, et non l'erreur du client de fichiers.
Une erreur non prevue sur un onglet n'arrete pas le reimport de importer_classeur : l'onglet passe aux « Refusés » avec
ONGLET_INTERROMPU, son detail au seul journal des refus, et les onglets suivants s'importent. valider_pour_le_client
dit le nombre de fichiers qui restent a copier et renvoie au journal des refus, qui porte le nom et le motif de chacun
(_copies_a_faire) : la phrase tient sur les 2 lignes de la zone de message quel que soit ce nombre.

Le verrou du dossier est controle par les procedures : une fonction n'a rien a en savoir, elle rend le refus.

LA ZONE DE MESSAGE DE L'ECRAN, comme pour fn_ecran_client (_poser_message, _journaliser_refus). Chaque fonction pose
son message dans la boite aux lettres de l'ecran, dbo.pr_poser_message_ecran, que le modele lit par
[Message de la revision] : la reussite avec la phrase rendue, le refus avec le texte de la base. Le refus se pose
APRES le rollback de l'action, dans une connexion neuve donc une transaction neuve, et il est journalise par
dbo.pr_journaliser_refus : SQL Server n'a pas de transaction autonome, un message ecrit dans la transaction de l'action
partirait avec son rollback.
L'ENTITE DU MESSAGE EST CELLE DE L'ACTION, jamais devinee dans les parametres : le parametre entite quand la fonction
en a un ; pour viser, l'entite en tete de objetRef (« entite|arrete|cycle », « entite|arrete »), et pour un lot le
vehicule du perimetre qui le porte ; pour une cote, le vehicule de la feuille.
L'utilisateur vient du contexte de chaque appel, porte par l'action, et non d'une variable de module : 2 appels
simultanes ne se melangent pas.
"""

import datetime
import io
import json
import re

import fabric.functions as fn

udf = fn.UserDataFunctions()


# ----------------------------------------------------------------------------- outils, identiques a fn_ecran_client

def _qui(ctx) -> str:
    u = (ctx.executing_user or {}).get("PreferredUsername") or (ctx.executing_user or {}).get("Oid")
    if not u:
        raise fn.UserThrownError("L'utilisateur connecté n'est pas identifiable ; l'action n'est pas exécutée.", {})
    return u


def _texte_pilote(exc) -> str:
    """Le texte de l'erreur ODBC, brut et non par le repr du tuple. Une erreur du pilote porte (etat SQL, texte), le
    texte commencant par « [ » ; une erreur levee par pyodbc lui-meme porte (texte, etat SQL), et le 2e argument seul
    rendait l'etat (HY000) au lieu du texte. Une erreur sans diagnostic du pilote (unixODBC, hote Linux de la
    fonction) porte (HY000, « The driver did not supply an error! ») : etat en 1er, texte sans « [ », lu en 2e.
    Toute autre forme se lit par str(exc), comme avant. Meme lecture que fn_ecran_client (21/11/2026), plus ce
    dernier cas (24/11/2026)."""
    a = getattr(exc, "args", ())
    if len(a) > 1 and isinstance(a[0], str) and isinstance(a[1], str):
        if a[1].startswith("["):
            return a[1]
        if re.fullmatch(r"[0-9A-Z]{5}", a[1]):
            return a[0]
        if re.fullmatch(r"[0-9A-Z]{5}", a[0]):
            return a[1]
    return str(exc)


def _message_sql(exc) -> str:
    s = _texte_pilote(exc)
    m = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQL\w+\)|$)", s, re.S)
    return (m.group(1) if m else s).strip().split(SEPARATEUR_DETAIL, 1)[0].strip()


# UN REFUS DE LA BASE PEUT JOINDRE UN DETAIL TECHNIQUE (code et texte d'un service appele, 50946) apres le separateur
# fixe SEPARATEUR_DETAIL : _message_sql coupe avant lui, pour l'ecran ; le detail va au journal des refus seul.
SEPARATEUR_DETAIL = "[[detail]]"


def _detail_de_la_base(exc):
    """Le texte du journal d'un refus qui joint un detail : le texte court, puis le detail ; None sans detail."""
    s = _texte_pilote(exc)
    m = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQL\w+\)|$)", s, re.S)
    t = (m.group(1) if m else s).strip()
    if SEPARATEUR_DETAIL not in t:
        return None
    court, detail = (x.strip() for x in t.split(SEPARATEUR_DETAIL, 1))
    return "%s Détail : %s" % (court, detail)


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


# ----------------------------------------------------------------------------- la zone de message

class _Geste:
    """L'action en cours : la base, la personne connectee, l'entite du message, les procedures appelees et le texte
    du dernier refus de la base."""

    def __init__(self, base, qui, entite):
        self.base, self.qui = base, qui
        e = None if entite is None else str(entite).strip()
        self.entite = e[:20] if e else None
        self.procedures, self.refus, self.detail_refus = [], None, None


def _geste(base, ctx, entite) -> _Geste:
    return _Geste(base, _qui(ctx), entite)


def _refus(g: _Geste, texte: str):
    """Un refus de la fonction elle-meme, avant toute procedure : son texte est retenu pour la zone de message."""
    g.refus = texte
    return fn.UserThrownError(texte, {})


def _texte(e) -> str:
    v = getattr(e, "message", None)
    if isinstance(v, str) and v.strip():
        return v
    return str(e) or e.__class__.__name__


def _poser(g, message, genre: str, procedure: str, journal: bool = False, detail: str = None) -> None:
    """Ecrit le message de l'action dans dbo.message_ecran, et le refus dans dbo.journal_refus quand journal est vrai ;
    detail, quand il est donne, remplace le message au journal seul (le detail technique d'une erreur non prevue).
    UNE CONNEXION NEUVE, donc une transaction neuve : l'action a deja fait commit ou rollback, et sa connexion est
    fermee. Ne leve jamais : un message qui echoue ne doit pas masquer l'action qu'il rapporte."""
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


# LE TEXTE D'UNE ERREUR NON PREVUE (24/11/2026) : celui de fn_ecran_client ; a la coupe publiee d'ec02 (870 px),
# 2 lignes, rien de coupe.
TEXTE_ERREUR = ("L'action n'a pas abouti à cause d'un problème technique. Vérifiez à l'écran ce qui a été enregistré, "
                "puis réessayez. Si le problème revient, prévenez l'administrateur.")


def _rendre(g: _Geste, nom: str, faire):
    """Execute l'action, puis pose son message : la phrase rendue a la reussite, le texte du refus sinon.

    faire() rend la phrase, ou (phrase, genre) quand la reussite porte des refus partiels (reimport d'un classeur).
    Un refus de la base ou de la fonction (UserThrownError) est journalise et pose, puis relance tel quel : la bulle
    du service le montre aussi. Une erreur non prevue, du moteur SQL, du pilote, du stockage ou de Python, rend
    TEXTE_ERREUR au bouton et a la zone de message, le detail au journal seul (24/10/2026, en-tete)."""
    try:
        r = faire()
    except fn.UserThrownError as e:
        _poser(g, g.refus or _texte(e), "REFUS", (g.procedures[-1] if g.procedures else nom), journal=True,
               detail=g.detail_refus if g.refus else None)
        raise
    except Exception as e:
        procedure = g.procedures[-1] if g.procedures else nom
        # LE DETAIL DU JOURNAL : « de la fonction » devant son nom, « procédure » devant celui de
        # la procedure ; sans procedure appelee, la forme de fn_documents, sans procedure nommee
        detail = ("Erreur d’exécution de la fonction %s, procédure %s : %s" % (nom, procedure, _detail(e))
                  if g.procedures else "Erreur d’exécution de la fonction %s : %s" % (nom, _detail(e)))
        _poser(g, TEXTE_ERREUR, "REFUS", procedure, journal=True, detail=detail)
        raise fn.UserThrownError(TEXTE_ERREUR, {"fonction": nom}) from e
    texte, genre = r if isinstance(r, tuple) else (r, "SUCCES")
    _poser(g, texte, genre, (g.procedures[0] if g.procedures else nom))
    return texte


def _journaliser(g, procedure: str, detail: str) -> None:
    """Le detail technique d'une erreur qui n'interrompt pas l'action (la copie d'un fichier de valider_pour_le_client),
    au seul journal des refus. UNE CONNEXION NEUVE ; ne leve jamais."""
    texte = (detail or "").strip()[:2000]
    if not texte or not g.qui:
        return
    try:
        conn = g.base.connect()
    except Exception:
        return
    try:
        cur = conn.cursor()
        cur.execute("EXEC dbo.pr_journaliser_refus @procedure_nom=?, @message=?, @par=?, @entite=?",
                    (procedure[:128], texte, g.qui, g.entite))
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


def _executer(base: fn.FabricSqlConnection, sql: str, params: tuple, g: _Geste = None) -> dict:
    """Execute une procedure qui rend (…, message) et leve ses refus ; rend la derniere ligne. L'action g, quand elle
    est donnee, retient la procedure et le texte du refus, que _rendre pose apres ce rollback. Seul un refus de la base
    (numero d'au moins 50000) devient une UserThrownError a son texte ; toute autre erreur est relevee telle quelle
    apres le rollback, et _rendre la rend en francais (en-tete)."""
    if g is not None:
        g.procedures.append(_nom_procedure(sql))
        g.refus = None
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        derniere = None
        while True:
            if cur.description:
                colonnes = [d[0] for d in cur.description]
                for ligne in cur.fetchall():
                    derniere = dict(zip(colonnes, ligne))
            if not cur.nextset():
                break
        conn.commit()
        return derniere or {}
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        message = _refus_de_la_base(e)
        if message is None:
            raise
        if g is not None:
            g.refus, g.detail_refus = message, _detail_de_la_base(e)
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        try:
            conn.close()
        except Exception:
            pass


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


def _obligatoires(g: _Geste, champs) -> None:
    """Refuse l'action, en francais et avant toute procedure, quand un champ de saisie obligatoire est vide. champs :
    [(valeur, libelle du champ a l'ecran)] ; le refus nomme tous les champs vides, dans l'ordre de l'ecran."""
    manquants = ["« %s »" % lib for v, lib in champs if _vide(v) is None]
    if manquants:
        raise _refus(g, "Champs obligatoires à remplir : %s." % ", ".join(manquants))


def _superviseur(g: _Geste, superviseur: str) -> None:
    if not superviseur or superviseur.strip().lower() != g.qui.strip().lower():
        raise _refus(g, "Le visa est réservé au superviseur connecté ; l'action n'est pas exécutée.")


# LES REFUS DES CHAMPS VIDES QUE LA FONCTION OPPOSE ELLE-MEME (24/10/2026, exception au cas general de l'en-tete) :
# un seul texte par champ, que la base reprend dans ses procedures.
REFUS_VEHICULE = "Choisissez le véhicule dans le sélecteur Véhicule."
REFUS_ARRETE = "Choisissez l'arrêté dans le sélecteur Arrêté."
REFUS_QUESTION = "Choisissez la question dans la grille « Questions du cycle »."
REFUS_CYCLE_DU_CLASSEUR = "Choisissez le cycle dans la grille « Cycles du programme »."
REFUS_COTE_REPONSE = ("Réponse refusée : la question choisie n'est rattachée à aucune feuille de questions de cet "
                      "arrêté.")
REFUS_COTE_CONCLUSION = ("Conclusion refusée : choisissez dans la grille « Questions du cycle » une question dont la "
                         "feuille de travail est ouverte.")
REFUS_ARRETE_REIMPORT = ("Choisissez l'arrêté dans le sélecteur Arrêté ; les OD libres ne se réimportent que sur un "
                         "arrêté ouvert dont le dossier de travail n'est pas verrouillé.")
REFUS_CLASSEUR = ("Réimport refusé : aucun classeur n'est désigné ; choisissez la question dans la grille "
                  "« Questions du cycle », ou exportez d'abord le classeur à réimporter.")
# Les selecteurs refuses avant le controle existant du champ (en-tete, ordre des refus)
REFUS_CYCLE_A_CONCLURE = ("Conclusion refusée : choisissez le cycle dans la bande des cycles ; un cycle se conclut sur "
                          "un arrêté ouvert, dossier de travail non verrouillé, tant que ni lui ni la revue ne sont "
                          "visés.")
REFUS_REVUE_A_CONCLURE = ("Conclusion refusée : aucune revue à conclure pour le véhicule et l'arrêté des sélecteurs : "
                          "la revue est visée, le dossier de travail est verrouillé, ou l'arrêté n'a pas de revue.")
REFUS_ARRETE_OD_LIBRES = ("Choisissez l'arrêté dans le sélecteur Arrêté ; les OD libres ne se modifient que sur un "
                          "arrêté ouvert dont le dossier de travail n'est pas verrouillé.")
# L'ONGLET QU'UNE ERREUR NON PREVUE INTERROMPT, dans le bilan de importer_classeur : « Refusés : <onglet> :
# <ONGLET_INTERROMPU> » ; le reimport passe a l'onglet suivant, le detail technique va au seul journal des refus
# (24/10/2026, en-tete).
ONGLET_INTERROMPU = "Import interrompu par une erreur d'exécution, détail consigné au journal des refus."


def _copies_a_faire(n: int) -> str:
    """La phrase des copies que valider_pour_le_client n'a pas faites (24/10/2026) : leur nombre, et le journal des
    refus, qui porte le nom et le motif de chacune. Elle ne nomme aucun fichier : avec la phrase de la validation, elle
    tient sur les 2 lignes de la zone de message de la Revision quel que soit leur nombre. L'espace avant « : » est
    insecable, pour que la 2e ligne ne commence jamais par le signe (coupe de la zone a un blanc)."""
    if n == 1:
        return "Reste 1 fichier à copier\u00a0: son nom et son motif sont consignés au journal des refus."
    return "Restent %d fichiers à copier\u00a0: la liste et le motif de chacun sont consignés au journal des refus." % n


def _controles(g, champs) -> None:
    """Les controles d'entree d'une fonction qui se sert d'un champ avant son 1er appel de procedure : champs,
    [(valeur, texte du refus)] dans l'ordre des refus ; la 1re valeur vide est refusee en francais, avant toute lecture
    ou procedure de la base, le refus etant ensuite journalise et pose par _rendre."""
    for valeur, texte in champs:
        if _vide(valeur) is None:
            raise _refus(g, texte)


def _absent(exc) -> bool:
    """Vrai quand le client de fichiers dit le fichier absent : statut 404 (ResourceNotFoundError), ou code NotFound,
    PathNotFound ou BlobNotFound dans son texte (« Failed with NotFound on GetBlob operation », releve le 23/10/2026
    sur « Réimporter le dossier »)."""
    if getattr(exc, "status_code", None) == 404 or exc.__class__.__name__ == "ResourceNotFoundError":
        return True
    return re.search(r"\b(NotFound|PathNotFound|BlobNotFound)\b", str(exc)) is not None


def _entite_de_cote(base, cote):
    """Le vehicule d'une feuille, pour le message : celui du perimetre qui porte la feuille (v_feuilles_du_cycle,
    filiales comprises), sinon l'entite de la feuille (les feuilles Q- sont au vehicule). None si rien, et sans
    lecture quand la cote est vide (24/10/2026) : le refus du champ vide precede alors toute lecture de la base."""
    if _vide(cote) is None:
        return None
    try:
        l = _lire(base, "SELECT TOP 1 x.e FROM (SELECT vehicule AS e, 0 AS o FROM dbo.v_feuilles_du_cycle WHERE cote = ? "
                        "UNION ALL SELECT entite, 1 FROM dbo.feuille_travail WHERE cote = ?) x ORDER BY x.o", (cote, cote))
        return l[0]["e"] if l else None
    except Exception:
        return None


def _entite_de_visa(base, objetRef, nature=None):
    """L'entite d'un visa, pour le message : la tete de objetRef pour un cycle ou une revue (« entite|arrete|cycle »,
    « entite|arrete ») ; pour un lot, dont objetRef est le seul numero, le vehicule du perimetre qui le porte
    (v_lots_perimetre, le sien d'abord), sinon l'entite du lot. Jamais la nature.
    POUR UNE VALEUR RETENUE (nature EVALUATION, 10/10/2026, ecran 3), objetRef est le numero de la
    ligne de evaluation_actif, et non celui d'un lot : l'entite est celle de cette ligne (l'entite detentrice de
    l'actif, filiale comprise), puis le vehicule du perimetre qui la porte a son arrete (v_perimetre_vehicule, le sien
    d'abord), sous lequel [Message ecran] lit le message."""
    ref = (objetRef or "").strip()
    if "|" in ref:
        return ref.split("|", 1)[0].strip() or None
    if not ref.isdigit():
        return None
    try:
        if (nature or "").strip().upper() == "EVALUATION":
            l = _lire(base, "SELECT TOP 1 x.e FROM (SELECT p.vehicule AS e, CASE WHEN p.vehicule = ev.entite THEN 0 ELSE 1 END AS o "
                            "FROM dbo.evaluation_actif ev JOIN dbo.v_perimetre_vehicule p ON p.entite = ev.entite AND p.arrete = ev.arrete "
                            "WHERE ev.id = ? UNION ALL SELECT entite, 2 FROM dbo.evaluation_actif WHERE id = ?) x ORDER BY x.o",
                      (int(ref), int(ref)))
            return l[0]["e"] if l else None
        l = _lire(base, "SELECT TOP 1 x.e FROM (SELECT vehicule AS e, CASE WHEN vehicule = entite THEN 0 ELSE 1 END AS o "
                        "FROM dbo.v_lots_perimetre WHERE lot_id = ? UNION ALL SELECT entite, 2 FROM dbo.lot_ecritures "
                        "WHERE id = ?) x ORDER BY x.o", (int(ref), int(ref)))
        return l[0]["e"] if l else None
    except Exception:
        return None


# ----------------------------------------------------------------------------- le programme

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def choisir_programme(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      entite: str = "", arrete: str = "", typeProgramme: str = "") -> str:
    """Bouton « Choisir » d'un type : ALLEGE, CLASSIQUE ou ETENDU. Rejouable, la selection est vivante."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_choisir_programme @entite=?, @arrete=?, @type=?, @par=?",
                      (entite, arrete, typeProgramme.upper(), g.qui), g)
        return r.get("message", "Programme choisi.")
    return _rendre(g, "choisir_programme", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ajuster_programme(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      actif: int, entite: str = "", arrete: str = "", reference: str = "", motif: str = "") -> str:
    """Boutons « Ajouter au programme » et « Retirer du programme » : la selection change, le journal le dit.

    actif est un ENTIER, 1 ajoute et 0 retire, porte par une mesure constante comme les reponses Oui et
    Non ; un booleen ne se lie pas surement a une mesure. Le motif est obligatoire au retrait, la base le
    refuse sinon."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ajuster_programme @entite=?, @arrete=?, @reference=?, @actif=?, @par=?, @motif=?",
                      (entite, arrete, reference, 1 if int(actif) else 0, g.qui, _vide(motif)), g)
        return r.get("message", "Programme ajusté.")
    return _rendre(g, "ajuster_programme", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def activer_cycle(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                  actif: int, entite: str = "", arrete: str = "", cycle: str = "", motif: str = "") -> str:
    """Boutons « Activer le cycle » et « Retirer le cycle » : toutes les questions eligibles du cycle.

    Un cycle qui a des comptes en balance ne se retire jamais en entier, la
    couverture de la balance etant non negociable, et un cycle qui porte des reponses non plus."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_activer_cycle @entite=?, @arrete=?, @cycle=?, @actif=?, @motif=?, @par=?",
                      (entite, arrete, cycle, 1 if int(actif) else 0, _vide(motif), g.qui), g)
        return r.get("message", "Cycle mis à jour.")
    return _rendre(g, "activer_cycle", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def verifier_couverture(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                        arrete: str = "") -> str:
    """Bouton « Vérifier la couverture de la balance » : rend la phrase, ne modifie rien. Le contexte sert a savoir a
    qui poser le message ; les parametres du bouton restent entite et arrete."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_verifier_couverture @entite=?, @arrete=?", (entite, arrete), g)
        return r.get("message", "Couverture vérifiée.")
    return _rendre(g, "verifier_couverture", faire)


# ----------------------------------------------------------------------------- les questions

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def repondre_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      reponse: str, cote: str = "", reference: str = "", motif: str = "", commentaire: str = "") -> str:
    """La ligne de la question : OUI, NON, NA avec motif ; la cote est celle de la feuille Q-<cycle>-P<n>. La cote sert
    a lire le vehicule du message avant la procedure (_entite_de_cote) : la question puis la cote vides sont refusees
    ici (_controles, en-tete)."""
    g = _geste(base, ctx, _entite_de_cote(base, cote))

    def faire():
        _controles(g, [(reference, REFUS_QUESTION), (cote, REFUS_COTE_REPONSE)])
        _executer(base, "EXEC dbo.pr_repondre_question @cote=?, @reference=?, @reponse=?, @motif_non_applicable=?, @commentaire=?, @par=?",
                  (cote, reference, _vide(reponse), _vide(motif), _vide(commentaire), g.qui), g)
        return f"Réponse à {reference} enregistrée."
    return _rendre(g, "repondre_question", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ouvrir_feuille(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str = "", arrete: str = "", reference: str = "") -> str:
    """Pop-up Feuille, « Ouvrir » : la feuille de la question, son gabarit, sa cote.

    LE GABARIT PREREMPLI PART AU SITE DU CABINET : ouvrir exporte le gabarit, reimporter rattache le fichier. Sans ce classeur, le bouton Reimporter n'avait rien a
    relire. Une feuille deja ouverte n'est pas une erreur ici : son classeur est reecrit."""
    g = _geste(base, ctx, entite)

    def faire():
        deja = True
        try:
            r = _executer(base, "EXEC dbo.pr_ouvrir_feuille_question @entite=?, @arrete=?, @reference=?, @par=?",
                          (entite, arrete, reference, g.qui), g)
            message = r.get("message", "Feuille ouverte.")
            # LA FEUILLE OUVERTE PAR CET APPEL : la procedure rend alors son gabarit (colonne
            # modele) ; pour une feuille deja ouverte, sa cote et sa phrase seules (definition relue le 27/10/2026)
            deja = "modele" not in r
        except fn.UserThrownError as e:
            message = g.refus or _texte(e)
            if "déjà ouverte" not in message:
                raise
            g.refus = None
        f = _lire(base, "SELECT TOP 1 f.cote, f.modele_code AS modele, f.entite, f.arrete, f.cycle, q.reference, f.preparateur, "
                        "f.forme_conclusion AS forme, f.conclusion, f.objectif FROM dbo.feuille_travail f JOIN dbo.ref_question q ON q.id = f.question_id "
                        "WHERE f.entite=? AND f.arrete=? AND q.reference=? ORDER BY f.prepare_le DESC", (entite, arrete, reference))
        if not f:
            return message
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        _feuille_feuille(wb, f[0]["cote"], f[0])
        fichier = f"feuille_{f[0]['cote']}.xlsx"
        _deposer(base, g, entite, arrete, fichier, wb)
        date, heure = _depot_a_paris(base, entite, arrete, fichier)
        if deja:
            return (f"Feuille {f[0]['cote']} déjà ouverte pour la question {f[0]['reference']} ; son classeur, "
                    f"déposé de nouveau le {date} à {heure}, s’ouvre depuis la liste du dossier de travail (étape 6).")
        return (f"Feuille {f[0]['cote']} ouverte pour la question {f[0]['reference']}, gabarit {f[0]['modele']}, "
                f"déposée le {date} à {heure} : remplissez-la depuis la liste du dossier de travail (étape 6), puis "
                f"réimportez-la.")
    return _rendre(g, "ouvrir_feuille", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_feuille(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     cote: str = "", forme: str = "", conclusion: str = "") -> str:
    """Pop-up Feuille, « Conclure » : forme et texte ; les portes de la feuille (pieces, derogation) parlent. La forme
    est facultative au bouton : vide, la fonction refuse en nommant le champ. La cote sert a lire le vehicule du
    message avant la procedure (_entite_de_cote) : vide, elle est refusee ici, avant la forme (_controles, en-tete)."""
    g = _geste(base, ctx, _entite_de_cote(base, cote))

    def faire():
        _controles(g, [(cote, REFUS_COTE_CONCLUSION)])
        _obligatoires(g, [(forme, "Forme de la conclusion")])
        r = _executer(base, "EXEC dbo.pr_importer_feuille @cote=?, @conclusion=?, @forme=?, @par=?",
                      (cote, _vide(conclusion), forme.upper(), g.qui), g)
        return r.get("message", "Feuille conclue.")
    return _rendre(g, "conclure_feuille", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def valider_od_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                        entite: str = "", arrete: str = "", reference: str = "") -> str:
    """Pop-up OD, « Valider » : le brouillon de la question devient un lot propose au visa. La question se lit en base
    avant la procedure : le vehicule, l'arrete puis la question vides sont refuses ici (_controles, en-tete)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE), (reference, REFUS_QUESTION)])
        l = _lire(base, "SELECT fq.cote, q.id FROM dbo.ref_question q JOIN dbo.feuille_question fq ON fq.question_id = q.id "
                        "JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.entite=? AND f.arrete=? AND f.cote LIKE 'Q-%' WHERE q.reference=?",
                  (entite, arrete, reference))
        if not l:
            raise _refus(g, f"La question {reference} n'est pas au programme de cet arrêté.")
        _executer(base, "EXEC dbo.pr_valider_brouillon @entite=?, @arrete=?, @feuille_cote=?, @question_id=?, @valide_par=?",
                  (entite, arrete, l[0]["cote"], l[0]["id"], g.qui), g)
        return f"OD de la question {reference} validées : le lot est proposé au visa."
    return _rendre(g, "valider_od_question", faire)


# ----------------------------------------------------------------------------- les OD libres

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def saisir_od(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
              entite: str = "", arrete: str = "", compte: str = "", libelle: str = "", debit: float = 0,
              credit: float = 0, reference: str = "", journal: str = "ODR", piece: str = "") -> str:
    """Une ligne d'OD, liee a une question si reference est donnee, libre sinon. Le compte et le libelle sont
    facultatifs au bouton : vides, la fonction refuse en nommant les champs, apres le vehicule puis l'arrete vides,
    refuses ici dans l'ordre des refus (_controles, en-tete)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE_OD_LIBRES)])
        _obligatoires(g, [(compte, "Compte"), (libelle, "Libellé")])
        r = _executer(base, "EXEC dbo.pr_saisir_od @entite=?, @arrete=?, @compte=?, @libelle=?, @debit=?, @credit=?, @reference=?, @journal=?, @piece_ref=?, @par=?",
                      (entite, arrete, compte, libelle, float(debit or 0), float(credit or 0), _vide(reference), journal or "ODR", _vide(piece), g.qui), g)
        return r.get("message", "Ligne enregistrée.")
    return _rendre(g, "saisir_od", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def saisir_od_double(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     entite: str = "", arrete: str = "", compte1: str = "", libelle1: str = "",
                     compte2: str = "", libelle2: str = "",
                     debit1: float = 0, credit1: float = 0,
                     debit2: float = 0, credit2: float = 0,
                     reference: str = "", journal: str = "ODR",
                     piece1: str = "", piece2: str = "") -> str:
    """Les 2 lignes d'une ecriture de revision, ecrites en une seule action.

    Une ecriture porte toujours au moins 2 lignes. Les saisir une par une obligeait a vider le
    champ oppose entre les 2, et la seconde partait sans sa reference : l'execution d'une
    fonction efface la ligne choisie dans la grille.
    """
    # LES 2 LIGNES S'ECRIVENT ENSEMBLE OU PAS DU TOUT : pr_saisir_od_paire controle les 2 lignes avant toute
    # ecriture, un refus n'en ecrit aucune. Une seule ligne saisie passe par pr_saisir_od.
    # LE VEHICULE PUIS L'ARRETE VIDES SONT REFUSES D'ABORD, dans l'ordre des refus (_controles, en-tete) ; les
    # refus de l'ecriture sans compte et des champs obligatoires suivent, inchanges.
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE_OD_LIBRES)])
        un, deux = (compte1 or "").strip(), (compte2 or "").strip()
        # UNE RANGEE COMMENCEE porte un compte ou un libelle : son compte et son libelle sont alors exiges, nommes par
        # leur rangee. Aucune rangee commencee : le refus d'une ecriture vide.
        r1, r2 = bool(un or _vide(libelle1)), bool(deux or _vide(libelle2))
        if not r1 and not r2:
            raise _refus(g, "Aucun compte saisi : une écriture porte au moins une ligne.")
        _obligatoires(g, ([(un, "Compte de la ligne 1"), (libelle1, "Libellé de la ligne 1")] if r1 else [])
                      + ([(deux, "Compte de la ligne 2"), (libelle2, "Libellé de la ligne 2")] if r2 else []))
        if un and deux:
            r = _executer(base, "EXEC dbo.pr_saisir_od_paire @entite=?, @arrete=?, @compte1=?, @libelle1=?, @debit1=?, @credit1=?, @piece_ref1=?, "
                                "@compte2=?, @libelle2=?, @debit2=?, @credit2=?, @piece_ref2=?, @reference=?, @journal=?, @par=?",
                          (entite, arrete, un, libelle1, float(debit1 or 0), float(credit1 or 0), _vide(piece1),
                           deux, libelle2, float(debit2 or 0), float(credit2 or 0), _vide(piece2),
                           _vide(reference), journal or "ODR", g.qui), g)
            return r.get("message", "2 lignes enregistrées.")
        c, l, d, cr, p = ((un, libelle1, debit1, credit1, piece1) if un else (deux, libelle2, debit2, credit2, piece2))
        r = _executer(base, "EXEC dbo.pr_saisir_od @entite=?, @arrete=?, @compte=?, @libelle=?, @debit=?, @credit=?, @reference=?, @journal=?, @piece_ref=?, @par=?",
                      (entite, arrete, c, l, float(d or 0), float(cr or 0), _vide(reference), journal or "ODR", _vide(p), g.qui), g)
        return r.get("message", "Ligne enregistrée.")
    return _rendre(g, "saisir_od_double", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def retirer_ligne_od(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     entite: str = "", arrete: str = "", ligneId: str = "") -> str:
    """Bouton « Retirer la ligne » des OD libres : la ligne choisie du brouillon libre, par son identifiant
    (v_od_revision[brouillon_id]). La base refuse une ligne hors du brouillon libre de l'arrete (50403)
    et un dossier verrouille (50404), et garde la trace du retrait (od_retrait).

    ligneId EST UN TEXTE : un parametre de bouton Data function ne se lie jamais a
    une mesure numerique (documentation desktop-buttons). La mesure [Ligne OD libre choisie] rend donc le
    N° en texte, et la conversion se fait ici. Le vehicule puis l'arrete vides sont refuses avant la ligne, dans l'ordre
    des refus (_controles, en-tete)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE_OD_LIBRES)])
        n = (ligneId or "").strip()
        if not n.isdigit():
            raise _refus(g, "Aucune ligne du brouillon libre n'est choisie dans la liste ; l'action n'est pas exécutée.")
        r = _executer(base, "EXEC dbo.pr_retirer_ligne_od @entite=?, @arrete=?, @ligne_id=?, @par=?",
                      (entite, arrete, int(n), g.qui), g)
        return r.get("message", "Ligne retirée du brouillon.")
    return _rendre(g, "retirer_ligne_od", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def valider_od_libres(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                      arrete: str = "") -> str:
    """Bouton « Valider le brouillon » des OD libres : equilibre exige, lot propose au visa."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_valider_od_libres @entite=?, @arrete=?, @valide_par=?", (entite, arrete, g.qui), g)
        return r.get("message", "OD libres validées.")
    return _rendre(g, "valider_od_libres", faire)


# ----------------------------------------------------------------------------- conclure et viser

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_cycle(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str = "", arrete: str = "", cycle: str = "", conclusion: str = "", forme: str = "") -> str:
    """Bouton « Enregistrer la conclusion du cycle » : la synthese des feuilles se regenere, le texte se pose. La
    conclusion est facultative au bouton : vide, la fonction refuse en nommant le champ, apres le vehicule, l'arrete
    puis le cycle vides, refuses ici dans l'ordre des refus (_controles, en-tete)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE), (cycle, REFUS_CYCLE_A_CONCLURE)])
        _obligatoires(g, [(conclusion, "Conclusion du cycle")])
        r = _executer(base, "EXEC dbo.pr_conclure_cycle @entite=?, @arrete=?, @cycle=?, @conclusion=?, @forme=?, @par=?",
                      (entite, arrete, cycle, conclusion, _vide(forme), g.qui), g)
        return r.get("message", "Cycle conclu.")
    return _rendre(g, "conclure_cycle", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_revue(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str = "", arrete: str = "", conclusion: str = "") -> str:
    """Bouton « Enregistrer la conclusion générale ». La conclusion est facultative au bouton : vide, la fonction refuse
    en nommant le champ, apres l'arrete puis le vehicule vides, refuses ici dans l'ordre des refus (un arrete
    vide vide aussi [Entite de la revue a conclure] ; _controles, en-tete)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(arrete, REFUS_ARRETE), (entite, REFUS_REVUE_A_CONCLURE)])
        _obligatoires(g, [(conclusion, "Conclusion générale de la revue")])
        r = _executer(base, "EXEC dbo.pr_conclure_revue @entite=?, @arrete=?, @conclusion=?, @par=?",
                      (entite, arrete, conclusion, g.qui), g)
        return r.get("message", "Revue conclue.")
    return _rendre(g, "conclure_revue", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def viser(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
          nature: str, decision: str, objetRef: str = "", superviseur: str = "", motif: str = "") -> str:
    """Boutons « Viser le cycle », « Viser la revue », « Renvoyer » : pr_ecran_viser, un seul bouton pour
    toutes les natures. objetRef : « entite|arrete|cycle » pour CYCLE, « entite|arrete » pour REVUE.
    Le parametre superviseur est lie a la mesure Superviseur connecte : vide pour un preparateur.

    LE MOTIF EST FACULTATIF ICI ET AU BOUTON : un renvoi sans motif part,
    la base le refuse (50057, pr_garde_visa), et le refus s'affiche dans la zone de message de l'ecran. L'entite du
    message est celle de objetRef, jamais la nature (_entite_de_visa).

    LE MESSAGE D'UN VISA DE VALEUR RETENUE OU D'UNE PUBLICATION (15/10/2026) : pr_ecran_viser ne rend pas de ligne, et
    le texte par defaut « EVALUATION : vise. » portait la nature en code, sans accent ni objet (ecran 3). Pour les
    natures EVALUATION et PUBLICATION, la fonction lit apres la procedure dbo.fn_message_visa, qui rend
    « Valeur retenue de <actif> visée. », son renvoi, ou « Valeur liquidative publiée. » ; les
    natures LOT, CYCLE et REVUE gardent leur texte jusqu'au retour sur l'ecran 2. Aucun bouton n'appelle viser avec la
    nature SYNTHESE : le visa de la synthese passe par viser_synthese de fn_ecran_valorisation (rapport relu par
    getDefinition le 15/10/2026 : 8 boutons sur viser, natures CYCLE, LOT, REVUE et EVALUATION ; 2 sur viser_synthese).

    OBJETREF ET SUPERVISEUR ONT UNE VALEUR PAR DEFAUT VIDE (15/10/2026, ecran 4 : bouton gris pour un droit ou un etat,
    refus en francais pour un champ vide) : « Publier la VL » les lie, facultatifs, a [Publication a viser] et a
    [Associe connecte], et une mesure vide n'envoie pas le parametre. nature et decision,
    constantes du bouton, restent obligatoires, donc en tete ; l'invocation porte chaque parametre sous son nom. Vides,
    ils sont refuses en francais avant toute procedure : le droit d'abord, objetRef ensuite. Le droit d'une publication
    (nature PUBLICATION) appartient a l'associe signataire, lie par [Associe connecte] : son refus le nomme, comme la
    carte [Blocage publication de la VL] (« visa réservé à l'associé signataire ») ; toute autre nature garde le refus de
    _superviseur. Les boutons des ecrans 2 et 3 gardent ces 2 parametres obligatoires a leur pose (isOptional faux)."""
    g = _geste(base, ctx, _entite_de_visa(base, objetRef, nature))

    def faire():
        if nature.upper() == "PUBLICATION":
            if _vide(superviseur) is None or superviseur.strip().lower() != g.qui.strip().lower():
                raise _refus(g, "Visa refusé : la publication de la valeur liquidative est réservée à l'associé "
                                "signataire du dossier, rôle que votre adresse de connexion ne tient pas.")
        else:
            _superviseur(g, superviseur)
        if _vide(objetRef) is None:
            raise _refus(g, "Visa refusé : l'écran ne désigne aucun objet à viser ; l'action n'est pas exécutée.")
        r = _executer(base, "EXEC dbo.pr_ecran_viser @nature=?, @objet_ref=?, @decision=?, @decide_par=?, @motif=?",
                      (nature.upper(), objetRef, decision.upper(), g.qui, _vide(motif)), g)
        if nature.upper() in ("EVALUATION", "PUBLICATION"):
            m = _message_visa(base, nature.upper(), objetRef, decision.upper())
            if m:
                return m
        return r.get("message", f"{nature} : {decision.lower()}.")
    return _rendre(g, "viser", faire)


def _message_visa(base, nature, objetRef, decision):
    """Le message en francais d'un visa reussi, lu dans dbo.fn_message_visa ; None si la lecture echoue : le visa est
    fait, un message manquant ne doit pas le masquer."""
    try:
        l = _lire(base, "SELECT dbo.fn_message_visa(?, ?, ?) AS m", (nature, objetRef, decision))
        m = (l[0].get("m") if l else None) or ""
        return m.strip() or None
    except Exception:
        return None


# ----------------------------------------------------------------------------- le dossier de travail
# 21/11/2026 : deverrouiller_dossier (demandeur tape, pr_deverrouiller_dossier) est retiree apres la pose
# d'ec02 ; pr_deverrouiller_dossier refuse en base (51253). Le deverrouillage passe par demander_deverrouillage.

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def demander_deverrouillage(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                            arrete: str = "", motif: str = "") -> str:
    """Bouton « Déverrouiller le dossier » de l'etape 6 : pr_ecran_demander_deverrouillage inscrit une
    demande de deverrouillage ; le demandeur est la personne connectee, jamais tapee. Le chef de mission la decide a
    l'ecran 1, sous-etat 5b (accorder_reouverture ou ecarter_reouverture de fn_ecran_client). La base refuse un champ
    vide (51201, 51240), un non-membre de l'equipe (51241), qui decide les deverrouillages (51242), un arrete valide
    pour le client (51243), un dossier non verrouille (51240), une autre demande en attente (51244), un motif vide
    (51245) ou de plus de 580 caracteres (51247)."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_demander_deverrouillage @entite=?, @arrete=?, @motif=?, @par=?",
                      (entite, arrete, _vide(motif), g.qui), g)
        return r.get("message", "Déverrouillage demandé.")
    return _rendre(g, "demander_deverrouillage", faire)


# ----------------------------------------------------------------------------- les livrables

def _executer_tout(base: fn.FabricSqlConnection, sql: str, params: tuple, g: _Geste = None) -> list:
    """Comme _executer, mais rend TOUTES les lignes du dernier jeu de resultats : la validation pour le client rend
    une ligne par fichier a copier. Meme filtre des erreurs : seul un refus de la base devient une UserThrownError."""
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
                lignes = [dict(zip(colonnes, l)) for l in cur.fetchall()]
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
            g.refus, g.detail_refus = message, _detail_de_la_base(e)
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        try:
            conn.close()
        except Exception:
            pass


_MONTANT = re.compile(r"^-?\d{1,3}(?:[   ]?\d{3})*(?:[.,]\d+)?$|^-?\d+(?:[.,]\d+)?$")


def _montant(texte):
    """Le montant d'une saisie, ou None quand le texte n'est pas un nombre : « 1 234,56 », « 1234.56 », « -12 »."""
    t = (texte or "").strip()
    if not t or not _MONTANT.match(t):
        return None
    t = t.replace(" ", "").replace(" ", "").replace(" ", "").replace(",", ".")
    try:
        return round(float(t), 2)
    except ValueError:
        return None


# LE NOM COURT D'UNE FORME DU RAPPORT, celui que les tuiles des formes affichent
_FORME_COURT = ("CASE code WHEN 'COMPTE_RENDU_TRAVAUX' THEN N'Compte rendu de travaux' "
                "WHEN 'SANS_OBSERVATION' THEN N'Attestation sans observation' "
                "WHEN 'AVEC_OBSERVATION' THEN N'Attestation avec observation(s)' "
                "WHEN 'IMPOSSIBILITE' THEN N'Refus d’attester' ELSE libelle END")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def arreter_forme_rapport(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                          arrete: str = "", forme: str = "", considerations: str = "", motif: str = "") -> str:
    """Bouton « Arrêter la forme » du rapport de l'expert-comptable, NP 2300 : la forme choisie dans le segment des
    formes. considerations : le motif des considerations particulieres, exige par la base pour une attestation dans une
    entite soumise au commissariat aux comptes (A10) ; motif : la limitation des diligences, formes E2 et E3. Les 2
    sont facultatifs au bouton : la base juge et refuse, et son refus s'affiche dans la zone de message."""
    g = _geste(base, ctx, entite)

    def faire():
        code = (forme or "").strip().upper()
        r = _executer(base, "EXEC dbo.pr_ecran_arreter_forme_attestation @entite=?, @arrete=?, @forme=?, @par=?, @motif=?, "
                            "@motif_considerations=?",
                      (entite, arrete, code, g.qui, _vide(motif), _vide(considerations)), g)
        message = r.get("message", "Forme du rapport de l'expert-comptable arrêtée.")
        # LA FORME SE NOMME PAR SON LIBELLE, celui de ref_forme_rapport, et non par son code : la phrase de la base porte
        # le code (« Forme du rapport arrêtée : COMPTE_RENDU_TRAVAUX. »). La lecture ne defait pas l'action, deja
        # valide : le code reste si elle echoue.
        # LE LIBELLE EST CELUI DES TUILES DES FORMES (_FORME_COURT), le meme que la colonne libelle_court de
        # ref_forme_rapport au modele : le libelle long d'une attestation avec observation compte 195 caracteres, et le
        # message ne tiendrait pas dans les 2 lignes de la zone de message.
        try:
            l = _lire(base, "SELECT %s AS libelle FROM dbo.ref_forme_rapport WHERE code = ?" % _FORME_COURT, (code,))
            if code and l and l[0].get("libelle"):
                message = message.replace(code, l[0]["libelle"])
        except Exception:
            pass
        return message
    return _rendre(g, "arreter_forme_rapport", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def saisir_cellule_annexe(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str,
                          article: str, ligne: str = "", colonne: str = "1", valeur: str = "", motif: str = "") -> str:
    """Bouton « Enregistrer la cellule » d'une page de l'annexe : une cellule (article, ligne, colonne 1 a 7). Vide, le
    champ « Valeur ou montant » retire la cellule saisie. Rempli, il part en texte quand la cellule est de format texte
    dans la derniere version de l'annexe (v_annexe_cellule.format), « 2025 » compris ; sinon en montant quand il se lit
    comme un nombre, en texte autrement, et la base refuse un texte dans une colonne de montants (50645). Le motif est
    exige par la base quand la saisie recouvre une valeur calculee. La ligne est facultative au bouton : vide, la
    fonction refuse en nommant le champ « Cellule »."""
    g = _geste(base, ctx, entite)

    def faire():
        _obligatoires(g, [(ligne, "Cellule")])
        co = (colonne or "1").strip()
        fmt = None
        if _vide(valeur) is not None:
            try:
                l = _lire(base, "SELECT TOP 1 format FROM dbo.v_annexe_cellule WHERE entite = ? AND arrete = ? AND article = ? "
                                "AND ligne = ? AND colonne = TRY_CAST(? AS tinyint)", (entite, arrete, article, ligne, co))
                fmt = l[0]["format"] if l else None
            except Exception:
                fmt = None
        if fmt == "texte":
            m, texte = None, _vide(valeur)
        else:
            m = _montant(valeur)
            texte = None if m is not None else _vide(valeur)
        r = _executer(base, "EXEC dbo.pr_saisir_cellule_annexe @entite=?, @arrete=?, @article=?, @ligne=?, @colonne=?, "
                            "@valeur=?, @montant=?, @motif=?, @par=?",
                      (entite, arrete, article, ligne, co, texte, m, _vide(motif), g.qui), g)
        return r.get("message", "Cellule enregistrée.")
    return _rendre(g, "saisir_cellule_annexe", faire)


# LE MESSAGE DU RECALCUL TIENT EN 2 LIGNES de la zone de message la plus etroite des pages des comptes annuels : la
# phrase de la base, la liste des versions creees (arrete:version, une par arrete) resumee a leur nombre, « aucune
# version créée », « 1 version créée » ou « n versions créées » (la version de l'arrete affiche se lit dans la bande du
# titre) ; l'espace avant « ; » et « : » rendue insecable, pour qu'une ligne ne commence jamais par un signe double.
_NBSP = "\u00a0"


def _message_recalcul(texte: str) -> str:
    t = " ".join((texte or "").split())
    m = re.search(r" ; versions créées : (.*)\.$", t)
    if m:
        v = m.group(1).strip()
        n = 0 if v == "aucune" else len([x for x in v.split(",") if x.strip()])
        t = t[:m.start()] + " ; " + ("aucune version créée." if n == 0 else
                                     "%d version%s créée%s." % (n, "s" if n > 1 else "", "s" if n > 1 else ""))
    return t.replace(" ;", _NBSP + ";").replace(" :", _NBSP + ":")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def recalculer_annexe(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str) -> str:
    """Bouton « Recalculer » des comptes annuels : les cellules de l'annexe de tous les arretes de mission de l'entite,
    recalculees par la base sur ses sources (pr_ecran_recalculer_annexe), une version neuve pour chaque arrete dont une
    cellule change. La base refuse un arrete qui n'est pas un arrete de mission, et une personne qui ne tient aucun role
    de mission sur l'entite ; le refus s'affiche dans la zone de message. La reussite y affiche l'heure du calcul, le
    nombre de cellules, dont les cellules a remplir et en attente, et le nombre de versions creees."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_recalculer_annexe @entite=?, @arrete=?, @par=?",
                      (entite, arrete, g.qui), g)
        return _message_recalcul(r.get("message") or "Annexe recalculée.")
    return _rendre(g, "recalculer_annexe", faire)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def valider_pour_le_client(base: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient, ctx: fn.UserDataFunctionContext,
                           entite: str = "", arrete: str = "") -> str:
    """Bouton « Valider pour le client » : le visa de cloture du chef de mission (pr_ecran_valider_pour_client), puis la
    copie de chaque fichier valide dans la bibliotheque « Livrables » du site du vehicule, dossier de l'arrete, et sa
    trace (pr_enregistrer_copie_livrable). Le fichier se lit au site du cabinet par le raccourci fec et se depose par la
    base (pr_deposer_fichier_espace) : une Data function n'a pas d'identite a elle. Une copie qui echoue ne defait pas
    la validation : le fichier reste « copie à faire » dans v_copie_livrable, et la phrase le dit.
    LA PHRASE DIT LE NOMBRE DE COPIES A FAIRE, ET NON LEUR LISTE (24/10/2026) : la liste et le motif de chaque copie
    a faire vont au journal des refus, une ligne par fichier (le refus de la base, ou le detail d'une erreur non
    prevue du stockage, du moteur SQL ou de Python), et la phrase y renvoie (_copies_a_faire). Nommer chaque fichier
    et son motif faisait passer la phrase sur une 3e ligne des 2 copies a faire."""
    import base64
    g = _geste(base, ctx, entite)

    def faire():
        fichiers = _executer_tout(base, "EXEC dbo.pr_ecran_valider_pour_client @entite=?, @arrete=?, @par=?",
                                  (entite, arrete, g.qui), g)
        faites, a_faire = [], 0
        for f in fichiers:
            nom = f.get("fichier")
            avant = len(g.procedures)
            try:
                chemin = "fec/Dossiers de travail/%s/%s/Livrables/%s" % (entite, arrete, nom)
                octets = coffre.connectToFiles().get_file_client(chemin).download_file().readall()
                d = _executer(base, "EXEC dbo.pr_deposer_fichier_espace @entite=?, @bibliotheque=?, @dossier=?, @fichier=?, "
                                    "@contenu_base64=?, @par=?",
                              (entite, "Livrables", arrete, nom, base64.b64encode(octets).decode("ascii"), g.qui), g)
                _executer(base, "EXEC dbo.pr_enregistrer_copie_livrable @document_id=?, @web_url=?, @par=?",
                          (int(f.get("document_id")), d.get("web_url"), g.qui), g)
                faites.append(nom)
            except fn.UserThrownError as e:
                a_faire += 1
                procedure = g.procedures[-1] if len(g.procedures) > avant else "valider_pour_le_client"
                _journaliser(g, procedure, "Copie à faire : %s : %s" % (nom, g.refus or _texte(e)))
                g.refus = None
            except Exception as e:
                a_faire += 1
                procedure = g.procedures[-1] if len(g.procedures) > avant else "valider_pour_le_client"
                _journaliser(g, procedure, "Copie à faire : %s : copie interrompue, %s : %s" % (nom, procedure, _detail(e)))
        texte = ("Arrêté du %s validé pour le client. %d fichier(s) copié(s) dans la bibliothèque Livrables du site du "
                 "véhicule." % (arrete, len(faites)))
        if a_faire:
            texte += " " + _copies_a_faire(a_faire)
        return texte, ("REFUS" if a_faire else "SUCCES")
    return _rendre(g, "valider_pour_le_client", faire)


# ----------------------------------------------------------------------------- la voie du classeur

# TOUT FICHIER SE DEPOSE DANS
# SHAREPOINT, et le coffre ne le voit que par un raccourci OneLake. Aucun export n'ecrit plus au
# coffre : chaque classeur part au site du cabinet par _deposer, et le reimport le relit par le
# raccourci fec.

_COL_Q = [("Cycle", "cycle"), ("Référence", "reference"), ("Question", "enonce"), ("Type", "type"), ("Réponse", "reponse"),
          ("Motif si non applicable", "motif"), ("Commentaire", "commentaire"), ("Feuille", "feuille_cote"), ("OD", "od"), ("Pièces", "pieces")]
_COL_OD = [("Journal", "journal"), ("Compte", "compte"), ("Libellé", "libelle"), ("Débit", "debit"), ("Crédit", "credit"), ("Pièce", "piece"), ("Actif", "actif")]
# L'ONGLET D'OD D'UN CYCLE porte la question de chaque ligne : sans elle, le reimport ne sait pas quel
# brouillon remplacer.
_COL_OD_CYCLE = [("Question", "reference")] + _COL_OD
_SAISIE = {"reference", "reponse", "motif", "commentaire", "journal", "compte", "libelle", "debit", "credit", "piece", "actif", "forme", "conclusion", "objectif", "methodologie"}


def _entete(ws, colonnes):
    from openpyxl.styles import Font, PatternFill
    for j, (lib, cle) in enumerate(colonnes, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = PatternFill("solid", fgColor="1D1A10")
        c.font = Font(bold=True, color="FFFFFF") if cle in _SAISIE else Font(color="D9D2C0")
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
        # LA LARGEUR SUIT L'EN-TETE, sans quoi Excel en ligne coupe les en-tetes. Question et Libellé prennent
        # plus, leur texte etant long.
        from openpyxl.utils import get_column_letter
        large = 60 if cle in ("enonce", "libelle") else max(12, len(lib) + 4)
        ws.column_dimensions[get_column_letter(j)].width = large
    ws.freeze_panes = "A3"


def _lignes(ws, colonnes, donnees, vides=0):
    from openpyxl.styles import PatternFill
    creme = PatternFill("solid", fgColor="FFF8E7")
    r = 3
    for d in donnees:
        for j, (lib, cle) in enumerate(colonnes, 1):
            c = ws.cell(row=r, column=j, value=d.get(cle))
            if cle in _SAISIE:
                c.fill = creme
        r += 1
    for _ in range(vides):
        for j, (lib, cle) in enumerate(colonnes, 1):
            if cle in _SAISIE:
                ws.cell(row=r, column=j).fill = creme
        r += 1


def _feuille_questions(wb, titre, donnees):
    ws = wb.create_sheet(titre[:31]); _entete(ws, _COL_Q); _lignes(ws, _COL_Q, donnees)


def _feuille_od(wb, titre, donnees, vides=12, colonnes=_COL_OD):
    ws = wb.create_sheet(titre[:31]); _entete(ws, colonnes); _lignes(ws, colonnes, donnees, vides)


def _feuille_feuille(wb, titre, d):
    from openpyxl.styles import Font, PatternFill
    creme = PatternFill("solid", fgColor="FFF8E7")
    ws = wb.create_sheet(titre[:31])
    ws.column_dimensions["A"].width = 22; ws.column_dimensions["B"].width = 100
    ws.cell(row=1, column=1, value="Feuille de travail").font = Font(bold=True, size=13)
    ws.cell(row=1, column=2, value=d.get("cote")).font = Font(bold=True, size=13)
    r = 3
    for lib, cle in [("Cote", "cote"), ("Gabarit", "modele"), ("Entité", "entite"), ("Arrêté", "arrete"), ("Cycle", "cycle"),
                     ("Question", "reference"), ("Préparateur", "preparateur"), ("Objectif", "objectif"), ("Méthodologie", "methodologie")]:
        ws.cell(row=r, column=1, value=lib).font = Font(bold=True)
        c = ws.cell(row=r, column=2, value=d.get(cle))
        if cle in _SAISIE:
            c.fill = creme
        ws.cell(row=r, column=3, value=cle).font = Font(italic=True, color="8A8578", size=9)
        r += 1
    r += 1
    ws.cell(row=r, column=1, value="Travaux").font = Font(bold=True)
    r += 1
    for j, lib in enumerate(["Contrôle", "Attendu", "Constaté", "Écart", "Commentaire"], 1):
        c = ws.cell(row=r, column=j, value=lib); c.fill = PatternFill("solid", fgColor="1D1A10"); c.font = Font(bold=True, color="FFFFFF")
    for i in range(r + 1, r + 13):
        for j in range(1, 6):
            ws.cell(row=i, column=j).fill = creme
    r += 14
    for lib, cle in [("Forme de conclusion", "forme"), ("Conclusion", "conclusion")]:
        ws.cell(row=r, column=1, value=lib).font = Font(bold=True)
        c = ws.cell(row=r, column=2, value=d.get(cle)); c.fill = creme
        ws.cell(row=r, column=3, value=cle).font = Font(italic=True, color="8A8578", size=9)
        r += 1


def _questions(base, entite, arrete, cycle=None):
    return _lire(base, "SELECT cycle, reference, enonce, type_reponse AS type, reponse_lue AS reponse, motif_non_applicable AS motif, commentaire, "
                       "feuille_cote, od_brouillon + od_lots AS od, pieces FROM dbo.v_questions_programme WHERE entite=? AND arrete=? "
                       + ("AND cycle=? " if cycle else "") + "ORDER BY cycle, ordre",
                 (entite, arrete, cycle) if cycle else (entite, arrete))


def _od(base, entite, arrete, reference=None, libres=False, cycle=None):
    sql = ("SELECT reference, journal_code AS journal, compte_num AS compte, libelle, debit, credit, piece_ref AS piece, code_actif AS actif "
           "FROM dbo.v_od_revision WHERE entite=? AND arrete=? AND etat='BROUILLON' ")
    if reference:
        return _lire(base, sql + "AND reference=? ORDER BY le", (entite, arrete, reference))
    if libres:
        return _lire(base, sql + "AND reference IS NULL ORDER BY le", (entite, arrete))
    if cycle:
        return _lire(base, sql + "AND cycle=? ORDER BY le", (entite, arrete, cycle))
    return _lire(base, sql + "ORDER BY le", (entite, arrete))


def _feuilles(base, entite, arrete, cycle=None):
    return _lire(base, "SELECT f.cote, f.modele_code AS modele, f.entite, f.arrete, f.cycle, q.reference, f.preparateur, f.forme_conclusion AS forme, f.conclusion, f.objectif "
                       "FROM dbo.feuille_travail f LEFT JOIN dbo.ref_question q ON q.id = f.question_id "
                       "WHERE f.entite=? AND f.arrete=? AND f.cycle IS NOT NULL AND f.cote NOT LIKE 'Q-%' " + ("AND f.cycle=? " if cycle else "") + "ORDER BY f.cote",
                 (entite, arrete, cycle) if cycle else (entite, arrete))


def _deposer(base, g: _Geste, entite: str, arrete: str, fichier: str, wb) -> dict:
    """Depose le classeur au site du cabinet, Dossiers de travail/<entite>/<arrete>/<fichier>.

    Par la base, pr_deposer_classeur, qui appelle l'Azure Function sous identite managee : une Data
    function n'a pas d'identite a elle, et un raccourci SharePoint ne sait que lire. Rend web_url,
    chemin_onelake et message."""
    import base64
    tampon = io.BytesIO(); wb.save(tampon)
    return _executer(base, "EXEC dbo.pr_deposer_classeur @entite=?, @arrete=?, @fichier=?, @contenu_base64=?, @par=?",
                     (entite, arrete, fichier, base64.b64encode(tampon.getvalue()).decode("ascii"), g.qui), g)


# LA DATE ET L'HEURE D'UN DEPOT, A L'HEURE DE PARIS (27/10/2026) :
# celles de la mesure [Depose le heure de Paris] du modele, que montrent les lignes de titre des depots et les 2 listes
# du dossier de travail. L'instant est export_dossier.depose_le, ecrit en UTC par la base (defaut SYSUTCDATETIME, relu
# le 27/10/2026), lu dans v_export_dossier (dernier depot reussi du fichier) ; heure d'ete, UTC + 2, du dernier dimanche
# de mars a 01:00 UTC au dernier dimanche d'octobre a 01:00 UTC, UTC + 1 sinon, puis la troncature a la minute, comme
# l'expression de la mesure. Une lecture qui echoue prend l'heure de la fonction : le depot est fait, son message ne
# leve pas.

def _dernier_dimanche(an: int, mois: int) -> datetime.datetime:
    d = datetime.datetime(an, mois, 31)
    return d - datetime.timedelta(days=d.isoweekday() % 7)


def _a_paris(utc: datetime.datetime):
    """(« jj/mm/aaaa », « hh:mm ») d'un instant UTC sans fuseau, a l'heure de Paris, tronque a la minute."""
    debut = _dernier_dimanche(utc.year, 3) + datetime.timedelta(hours=1)
    fin = _dernier_dimanche(utc.year, 10) + datetime.timedelta(hours=1)
    p = utc + datetime.timedelta(hours=2 if debut <= utc < fin else 1)
    return p.strftime("%d/%m/%Y"), p.strftime("%H:%M")


def _maintenant_utc() -> datetime.datetime:
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)


def _depot_a_paris(base, entite: str, arrete: str, fichier: str):
    """(date, heure) a Paris du dernier depot reussi du fichier, lu dans v_export_dossier."""
    try:
        l = _lire(base, "SELECT depose_le FROM dbo.v_export_dossier WHERE entite = ? AND arrete = ? AND fichier = ?",
                  (entite, arrete, fichier))
        d = l[0]["depose_le"] if l else None
    except Exception:
        d = None
    if not isinstance(d, datetime.datetime):
        d = _maintenant_utc()
    return _a_paris(d.replace(tzinfo=None))


def _compte(n: int, singulier: str, pluriel: str) -> str:
    """Le nombre et son nom accorde, sans « (s) » : le singulier pour 0 et 1."""
    return "%d %s" % (n, singulier if n <= 1 else pluriel)


# LE NOM DU CYCLE A L'ECRAN : nom_usage de la vue dbo.v_ecran_cycle_ou_phase, genre CYCLE, que
# lit le segment « Cycle ou phase » ; la vue est generee depuis la colonne calculee ref_cycle[Cycle] du modele
# conduite_de_mission, et un cycle que le modele ne connait pas y prend
# le libelle de ref_cycle (vue et lignes relues le 27/10/2026 : 11 cycles, memes noms que le modele). Une lecture en
# echec ou sans ligne rend le code du cycle.
def _cycle_a_l_ecran(base, cycle: str) -> str:
    c = (cycle or "").strip()
    try:
        l = _lire(base, "SELECT nom_usage FROM dbo.v_ecran_cycle_ou_phase WHERE genre = 'CYCLE' AND code = ?", (c,))
        return (l[0]["nom_usage"] or c) if l else c
    except Exception:
        return c


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_questions(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                       arrete: str = "", cycle: str = "") -> str:
    """Bouton « Ouvrir le classeur des questions du cycle » : les questions au programme, reponses comprises. Elles se
    lisent en base avant la procedure : le vehicule, l'arrete puis le cycle vides sont refuses ici (_controles)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE), (cycle, REFUS_CYCLE_DU_CLASSEUR)])
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        d = _questions(base, entite, arrete, cycle)
        if not d:
            raise _refus(g, f"Aucune question du cycle {cycle} au programme de cet arrêté.")
        _feuille_questions(wb, "Q-" + cycle, d)
        fichier = f"questions_{cycle}_{entite}_{arrete}.xlsx"
        _deposer(base, g, entite, arrete, fichier, wb)
        date, heure = _depot_a_paris(base, entite, arrete, fichier)
        n = len(d)
        return (f"Classeur Excel {'des %d questions' % n if n > 1 else 'de %d question' % n} du cycle "
                f"{_cycle_a_l_ecran(base, cycle)} déposé le {date} à {heure} ; il s’ouvre depuis la liste du "
                f"dossier de travail (étape 6).")
    return _rendre(g, "exporter_questions", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_od(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "", arrete: str = "",
                reference: str = "") -> str:
    """Pop-up OD, « Exporter les OD liées » (reference donnee), ou « Exporter le gabarit » des OD libres : preremplies.
    Les lignes se lisent en base avant la procedure : le vehicule puis l'arrete vides sont refuses ici (_controles)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        ref = _vide(reference)
        d = _od(base, entite, arrete, reference=ref, libres=ref is None)
        _feuille_od(wb, ("OD " + ref) if ref else "OD libres", d)
        fichier = f"od_{ref or 'libres'}_{entite}_{arrete}.xlsx"
        _deposer(base, g, entite, arrete, fichier, wb)
        date, heure = _depot_a_paris(base, entite, arrete, fichier)
        return (f"Grille de saisie de {_compte(len(d), 'ligne préremplie', 'lignes préremplies')} déposée le {date} à "
                f"{heure} ; elle s’ouvre depuis la liste du dossier de travail (étape 6).")
    return _rendre(g, "exporter_od", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_feuille(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, cote: str) -> str:
    """Pop-up Feuille, « Exporter » : le gabarit generique prerempli de la feuille."""
    g = _geste(base, ctx, _entite_de_cote(base, cote))

    def faire():
        from openpyxl import Workbook
        d = _lire(base, "SELECT f.cote, f.modele_code AS modele, f.entite, f.arrete, f.cycle, q.reference, f.preparateur, f.forme_conclusion AS forme, f.conclusion, f.objectif "
                        "FROM dbo.feuille_travail f LEFT JOIN dbo.ref_question q ON q.id = f.question_id WHERE f.cote=?", (cote,))
        if not d:
            raise _refus(g, f"La feuille {cote} n'existe pas.")
        wb = Workbook(); wb.remove(wb.active)
        _feuille_feuille(wb, cote, d[0])
        r = _deposer(base, g, d[0]["entite"], d[0]["arrete"], f"feuille_{cote}.xlsx", wb)
        return f"Feuille déposée au site du cabinet : {r.get('web_url')}"
    return _rendre(g, "exporter_feuille", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_dossier(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     entite: str = "", arrete: str = "") -> str:
    """Bouton « Exporter le dossier de travail » : Balance, Programme, puis par cycle Q, FT, OD ; OD libres.

    LE CLASSEUR PART AUSSI DANS SHAREPOINT : le reviseur doit
    recevoir un lien qui s'ouvre au clic, et l'adresse OneLake directe rend « Unauthorized » dans
    le navigateur. Le depot passe par la base, pr_deposer_classeur, qui appelle
    l'Azure Function du cabinet sous identite managee : une Data function n'a pas d'identite a elle.
    Le site est celui du CABINET, jamais l'espace du client : le dossier de travail est au cabinet.
    Le dossier se lit en base avant la procedure : le vehicule puis l'arrete vides sont refuses ici (_controles)."""
    g = _geste(base, ctx, entite)

    def faire():
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE)])
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        ws = wb.create_sheet("Balance")
        colb = [("Compte", "compte"), ("Libellé", "libelle"), ("Balance initiale", "b0_initiale"), ("OD de révision", "od_revision"),
                ("OD de valorisation", "od_valorisation"), ("Balance finale", "balance_finale"), ("Cycles", "cycles"), ("Couverture", "etat")]
        _entete(ws, colb)
        _lignes(ws, colb, _lire(base, "SELECT b.compte, b.libelle, b.b0_initiale, b.od_revision, b.od_valorisation, b.balance_finale, c.cycles, c.etat "
                                      "FROM dbo.v_balance b LEFT JOIN dbo.v_couverture_balance c ON c.entite=b.entite AND c.arrete=b.arrete AND c.compte=b.compte "
                                      "WHERE b.entite=? AND b.arrete=? ORDER BY b.compte", (entite, arrete)))
        ws = wb.create_sheet("Programme")
        colp = [("Type", "type_programme"), ("Cycle", "cycle"), ("Référence", "reference"), ("Question", "enonce"), ("Active", "actif"), ("Origine", "origine")]
        prog = _lire(base, "SELECT p.type_programme, q.cycle, q.reference, q.enonce, pq.actif, pq.origine FROM dbo.programme_travail p "
                           "JOIN dbo.programme_question pq ON pq.programme_id=p.id JOIN dbo.ref_question q ON q.id=pq.question_id "
                           "WHERE p.entite=? AND p.arrete=? ORDER BY q.cycle, q.ordre", (entite, arrete))
        _entete(ws, colp); _lignes(ws, colp, prog)
        cycles = []
        for x in prog:
            if x["actif"] and x["cycle"] not in cycles:
                cycles.append(x["cycle"])
        for cy in cycles:
            _feuille_questions(wb, "Q-" + cy, _questions(base, entite, arrete, cy))
            for f in _feuilles(base, entite, arrete, cy):
                _feuille_feuille(wb, f["cote"], f)
            _feuille_od(wb, "OD-" + cy, _od(base, entite, arrete, cycle=cy), vides=6, colonnes=_COL_OD_CYCLE)
        _feuille_od(wb, "OD libres", _od(base, entite, arrete, libres=True))
        fichier = f"dossier_{entite}_{arrete}.xlsx"
        _deposer(base, g, entite, arrete, fichier, wb)
        date, heure = _depot_a_paris(base, entite, arrete, fichier)
        return (f"Dossier de travail de {_compte(len(wb.sheetnames), 'onglet', 'onglets')} déposé le {date} à "
                f"{heure} ; il s’ouvre par son lien, sur la page que montre « Voir le dossier exporté » (étape 3) ou "
                f"dans la liste du dossier de travail (étape 6).")
    return _rendre(g, "exporter_dossier", faire)


def _lignes_de(ws):
    """Les lignes d'un onglet, cle par cle, et le numero de la ligne dans l'onglet sous « _ligne » : la
    base le cite dans ses refus (« Ligne 9 du classeur : … »)."""
    cles = [c.value for c in ws[2]]
    out = []
    for n, r in enumerate(ws.iter_rows(min_row=3, values_only=True), 3):
        if all(v is None or str(v).strip() == "" for v in r):
            continue
        d = {k: v for k, v in zip(cles, r) if k}
        d["_ligne"] = n
        out.append(d)
    return out


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def importer_classeur(base: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient, ctx: fn.UserDataFunctionContext,
                      entite: str = "", arrete: str = "", chemin: str = "") -> str:
    """Bouton « Réimporter » de l'ecran : le classeur depose au site du cabinet, reconnu a ses feuilles :
    Q-<cycle> (reponses), OD <reference>, OD-<cycle> ou OD libres (brouillon remplace), <cote> (feuille : forme,
    conclusion). Balance et Programme ne s'importent pas : l'une se calcule, l'autre se choisit au programme.
    Le classeur se lit avant toute procedure : le vehicule, l'arrete puis le chemin vides sont refuses ici
    (_controles), et un classeur absent du site du cabinet l'est par le texte du chemin (24/10/2026, en-tete). Un
    onglet refuse par la base, ou interrompu par une erreur non prevue (ONGLET_INTERROMPU, detail au seul journal des
    refus), passe aux « Refusés » sans arreter les autres."""
    g = _geste(base, ctx, entite)

    def faire():
        # LE CHEMIN EST CELUI DE LA FONCTION ENGLOBANTE, et faire() le reecrit pour un ancien chemin exports/ :
        # sans nonlocal, Python le tient pour une variable locale de faire(), lue avant d'etre affectee.
        nonlocal chemin
        _controles(g, [(entite, REFUS_VEHICULE), (arrete, REFUS_ARRETE_REIMPORT), (chemin, REFUS_CLASSEUR)])
        from openpyxl import load_workbook
        import hashlib
        # LE DOSSIER DEPOSE DANS SHAREPOINT PRIME SUR SA COPIE DU COFFRE : le reviseur modifie le classeur dans
        # Excel en ligne, et relire la copie du coffre perdrait son travail. La resolution se fait ici, et non
        # dans une mesure : l'ecran, non rafraichi apres l'export, peut envoyer encore le chemin du coffre.
        # LA SOURCE SE LIT SUR LE CHEMIN : fec/ est le raccourci du coffre vers le site du cabinet. La
        # mesure de l'ecran envoie ce chemin quand un depot existe.
        # UN ANCIEN CHEMIN exports/ SE LIT DESORMAIS AU SITE DU CABINET : plus aucun classeur n'est ecrit
        # au coffre. Le depot range chaque classeur sous Dossiers de travail/<entite>/
        # <arrete>/, et le raccourci fec le rend lisible d'ici.
        if chemin.startswith("exports/"):
            chemin = f"fec/Dossiers de travail/{entite}/{arrete}/{chemin.rsplit('/', 1)[-1]}"
        source = "site du cabinet" if chemin.startswith("fec/") else "coffre"
        # LE CLASSEUR ABSENT DU SITE DU CABINET EST UN REFUS NOMME (24/10/2026) : « Réimporter le dossier » sans
        # classeur depose rendait « Failed with NotFound on GetBlob operation » et une reponse 500
        # (23/10/2026). Toute autre erreur du client de fichiers suit le filet de _rendre.
        try:
            octets = coffre.connectToFiles().get_file_client(chemin).download_file().readall()
        except Exception as e:
            if _absent(e):
                raise _refus(g, REFUS_CLASSEUR) from None
            raise
        lu_le = _maintenant_utc()
        wb = load_workbook(io.BytesIO(octets), data_only=True)
        par = g.qui
        faits, refus = [], []
        # LE BILAN DU DOSSIER ENTIER : ce que rendent les procedures, onglet par onglet
        # (pr_importer_reponses : importees ; pr_importer_od : lignes, debit et credit du brouillon ;
        # pr_importer_feuille : la feuille reprise), definitions relues le 27/10/2026. pr_importer_od remplace le
        # brouillon de la question a chaque import : une question presente dans 2 onglets (OD-<cycle> et
        # OD <reference>) ne garde que son dernier import, seul compte (ses lignes et son equilibre) ; la cle est la
        # reference en majuscules, la base comparant sans egard a la casse. pr_importer_feuille met a jour la feuille de
        # sa cote sans refuser un 2e import : une feuille importee 2 fois (onglet duplique, cote ecrite en minuscules) ne
        # compte qu'une fois ; la cle est la cote que rend la procedure, en majuscules, espaces de fin otes, la base
        # comparant sans egard a la casse ni aux espaces de fin.
        onglets_lus, od_par_question, feuilles_reprises = set(), {}, set()
        n_reponses, n_cycles, n_lignes_l = 0, 0, 0
        libres_equilibrees = True
        for ws in wb.worksheets:
            t = ws.title
            avant = len(g.procedures)
            try:
                if t in ("Balance", "Programme"):
                    continue
                if t.startswith("Q-"):
                    l = _lire(base, "SELECT 'Q-' + ? + '-P' + CAST(id AS varchar) AS cote FROM dbo.programme_travail WHERE entite=? AND arrete=?", (t[2:], entite, arrete))
                    if not l:
                        raise _refus(g, "Aucun programme choisi pour cet arrêté.")
                    reponses = [{"reference": d.get("reference"), "reponse": None if d.get("reponse") is None else str(d.get("reponse")),
                                 "motif": d.get("motif"), "commentaire": d.get("commentaire")} for d in _lignes_de(ws) if d.get("reference")]
                    r = _executer(base, "EXEC dbo.pr_importer_reponses @cote=?, @reponses=?, @par=?", (l[0]["cote"], json.dumps(reponses, ensure_ascii=False, default=str), par), g)
                    faits.append(f"{t} : {r.get('message', 'importé')}")
                    # un onglet de questions ne compte dans « sur N cycles » que si ses reponses importees sont plus de 0
                    importees = int(r.get("importees") or 0)
                    n_reponses += importees
                    if importees > 0:
                        n_cycles += 1
                    onglets_lus.add(t)
                elif t.startswith("OD-"):
                    # L'ONGLET D'OD D'UN CYCLE, dans le dossier de travail. Chaque question du cycle voit son
                    # brouillon REMPLACE par ses lignes de l'onglet ; une question dont toutes les lignes ont
                    # ete effacees voit donc son brouillon vide, ce qui est le sens de l'action.
                    cycle = t[3:].strip()
                    lignes = [d for d in _lignes_de(ws)
                              if d.get("compte") and str(d.get("compte")).strip().lower() not in ("total", "écart")]
                    sans = [d for d in lignes if not d.get("reference")]
                    if sans:
                        raise _refus(g, f"{len(sans)} ligne(s) sans question : une OD sans question va dans l'onglet OD libres.")
                    refs = {str(d["reference"]).strip() for d in lignes}
                    refs |= {x["reference"] for x in _lire(base, "SELECT DISTINCT reference FROM dbo.v_od_revision WHERE entite=? AND arrete=? "
                                                                 "AND cycle=? AND etat='BROUILLON' AND reference IS NOT NULL", (entite, arrete, cycle))}
                    for ref in sorted(refs):
                        siennes = [{"ligne": d["_ligne"], "journal": d.get("journal") or "ODR", "compte": str(d.get("compte")).strip(), "libelle": d.get("libelle"),
                                    "debit": float(d.get("debit") or 0), "credit": float(d.get("credit") or 0), "piece": d.get("piece"),
                                    "actif": d.get("actif")} for d in lignes if str(d["reference"]).strip() == ref]
                        r = _executer(base, "EXEC dbo.pr_importer_od @entite=?, @arrete=?, @reference=?, @lignes=?, @par=?",
                                      (entite, arrete, ref, json.dumps(siennes, ensure_ascii=False, default=str), par), g)
                        faits.append(f"{t} {ref} : {r.get('message', 'importé')}")
                        od_par_question[ref.upper()] = (int(r.get("lignes") or 0), r.get("debit") == r.get("credit"))
                        onglets_lus.add(t)
                elif t == "OD libres" or t.startswith("OD "):
                    ref = None if t == "OD libres" else t[3:].strip()
                    lignes = [{"ligne": d["_ligne"], "journal": d.get("journal") or "ODR", "compte": str(d.get("compte")).strip(), "libelle": d.get("libelle"),
                               "debit": float(d.get("debit") or 0), "credit": float(d.get("credit") or 0), "piece": d.get("piece"), "actif": d.get("actif")}
                              for d in _lignes_de(ws) if d.get("compte") and str(d.get("compte")).strip().lower() not in ("total", "écart")]
                    # LES OD LIBRES PASSENT LE NOM DU CLASSEUR, sans dossier : la base
                    # date son instant de reference par le dernier depot ou reimport de ce fichier, et refuse un
                    # classeur qui ferait perdre une saisie ou revenir un retrait posterieurs (50405, 50408), ou
                    # qu'elle ne connait pas (50406). Sans ce nom, elle refuse tout reimport d'OD libres (50409).
                    fichier = chemin.rsplit("/", 1)[-1] if ref is None else None
                    r = _executer(base, "EXEC dbo.pr_importer_od @entite=?, @arrete=?, @reference=?, @lignes=?, @par=?, @fichier=?",
                                  (entite, arrete, ref, json.dumps(lignes, ensure_ascii=False, default=str), par, fichier), g)
                    faits.append(f"{t} : {r.get('message', 'importé')}")
                    if ref is None:
                        n_lignes_l += int(r.get("lignes") or 0)
                        libres_equilibrees = libres_equilibrees and r.get("debit") == r.get("credit")
                    else:
                        od_par_question[ref.upper()] = (int(r.get("lignes") or 0), r.get("debit") == r.get("credit"))
                    onglets_lus.add(t)
                else:
                    valeurs = {}
                    for row in ws.iter_rows(min_row=1, values_only=True):
                        if len(row) >= 3 and row[2] in ("cote", "forme", "conclusion", "objectif"):
                            valeurs[row[2]] = row[1]
                    cote = valeurs.get("cote") or t
                    # L'OBJECTIF DE LA FEUILLE SE RELIT : prerempli
                    # depuis le gabarit, modifiable dans le classeur. Vide, il laisse en place celui de la base.
                    r = _executer(base, "EXEC dbo.pr_importer_feuille @cote=?, @conclusion=?, @forme=?, @nom_fichier=?, @empreinte=?, @par=?, @objectif=?",
                                  (cote, _vide(valeurs.get("conclusion")), _vide(valeurs.get("forme")), chemin.rsplit("/", 1)[-1],
                                   hashlib.sha256(octets).hexdigest().upper(), par, _vide(valeurs.get("objectif"))), g)
                    faits.append(f"{t} : {r.get('message', 'importé')}")
                    # une feuille par cote, quel que soit le nombre de ses imports (la cle de la base)
                    feuilles_reprises.add(str(r.get("cote") or cote).rstrip(" ").upper())
                    onglets_lus.add(t)
            except fn.UserThrownError as e:
                refus.append(f"{t} : {g.refus or _texte(e)}")
                g.refus = None
            except Exception as e:
                # UNE ERREUR NON PREVUE SUR UN ONGLET (moteur SQL sous 50000, pilote, Python) N'ARRETE PAS LE REIMPORT
                # (24/10/2026, en-tete) : l'onglet passe aux refuses avec ONGLET_INTERROMPU, son detail technique au
                # seul journal des refus, et les onglets suivants s'importent, comme avant le filet du 24/10/2026.
                procedure = g.procedures[-1] if len(g.procedures) > avant else "importer_classeur"
                refus.append(f"{t} : {ONGLET_INTERROMPU}")
                g.refus = None
                _journaliser(g, procedure, "Import de l'onglet %s interrompu, %s : %s" % (t, procedure, _detail(e)))
        # LE DOSSIER ENTIER, SES OD TOUTES EQUILIBREES : le bilan compte ce que les procedures ont
        # rendu, nombres accordes, sans adresse, a l'heure de Paris de la relecture. Toute partie vide est omise : aucun
        # onglet importe, aucune reponse, aucune ligne d'OD de question ou libre, aucune feuille ; un onglet de questions
        # ne compte dans les cycles que si ses reponses importees sont plus de 0, une question que si les lignes de son
        # dernier import sont plus de 0 (un brouillon vide par le reimport n'est pas compte), une feuille une fois par
        # cote.
        # Tout autre classeur, ou un brouillon desequilibre, garde le texte detaille, qui cite chaque procedure.
        n_lignes_q = sum(n for n, _ in od_par_question.values())
        n_questions = sum(1 for n, _ in od_par_question.values() if n > 0)
        equilibrees = libres_equilibrees and all(e for _, e in od_par_question.values())
        if "Balance" in wb.sheetnames and "Programme" in wb.sheetnames and equilibrees:
            date, heure = _a_paris(lu_le)
            morceaux = []
            if onglets_lus:
                morceaux.append(_compte(len(onglets_lus), "onglet importé", "onglets importés"))
            if n_reponses > 0:
                morceaux.append("%s sur %s" % (_compte(n_reponses, "réponse", "réponses"),
                                               _compte(n_cycles, "cycle", "cycles")))
            od = []
            if n_questions > 0:
                od.append("%s d’OD de %s" % (_compte(n_lignes_q, "ligne", "lignes"),
                                             _compte(n_questions, "question", "questions")))
            if n_lignes_l > 0:
                od.append("%s d’OD %s" % (_compte(n_lignes_l, "ligne", "lignes"),
                                          "libre" if n_lignes_l <= 1 else "libres"))
            if od:
                morceaux.append(" et ".join(od) + (", toutes équilibrées" if n_lignes_q + n_lignes_l > 1 else ""))
            if feuilles_reprises:
                morceaux.append(_compte(len(feuilles_reprises), "feuille reprise", "feuilles reprises"))
            texte = f"Dossier relu le {date} à {heure}" + ((" : " + ", ".join(morceaux)) if morceaux else "") + "."
        else:
            texte = (f"Classeur relu au {source}. {len(faits)} onglet(s) importé(s)."
                     + (" " + " ".join(faits) if faits else ""))
        if refus:
            texte += " Refusés : " + " ; ".join(refus)
        # UN REFUS PARTIEL S'AFFICHE EN REFUS : la zone de message passe au rose des qu'un onglet est refuse,
        # meme si d'autres sont importes ; la phrase dit lesquels.
        return texte, ("REFUS" if refus else "SUCCES")
    return _rendre(g, "importer_classeur", faire)


# ----------------------------------------------------------------------------- l'ajout d'une question de reference

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ajouter_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                     cycleOuPhase: str = "", enonce: str = "") -> str:
    """Bouton « Ajouter une question » de l'etape 2, a la bande des cycles (ecran 5) : une question de reference
    neuve, au statut « à valider », dans le cycle
    choisi a la bande des cycles (revCycles : nom d'usage ou code, une phase admise), avec l'enonce saisi au champ
    « Énoncé de la question ».

    teneur est lie a la mesure [Teneur des questions connecte]. Il a une valeur par defaut vide, comme cycleOuPhase et
    enonce, selon la regle du 24/10/2026 ecrite en tete de ce fichier (chaque parametre d'une fonction qu'appelle un
    bouton des ecrans 2 et 3 a une valeur par defaut vide, sauf les constantes du bouton). Le caractere obligatoire de
    teneur est tenu par la fonction : absent, vide, a
    blancs ou d'une autre personne que la personne connectee, teneur est refuse en francais AVANT TOUT APPEL A LA BASE,
    sans journal ni message, au texte du refus 50888 de la procedure (regle de fn_ecran_referentiels).
    cycleOuPhase et enonce passent tels quels a dbo.pr_ecran_ajouter_question (@cycle_ou_phase, @enonce, @par, relus en
    base le 28/10/2026), qui refuse en francais, dans son ordre : aucun mandat d'associe ni de reviseur en cours (50888),
    cycle ou phase vide, commun a un cycle et a une phase, inconnu ou ecarte (50871, 50887, 50872, 50873), enonce vide
    ou de plus de 400 caracteres (50885, 50886). Aucun parametre d'etat. Pas de tiret bas dans un nom de parametre,
    d'ou cycleOuPhase.

    L'auteur est la personne connectee (ctx.executing_user), passee en @par, jamais un parametre : la session SQL de la
    fonction porte le compte a la fois proprietaire de la fonction et auteur de sa connexion, quel que soit le compte qui
    clique, et seul @par nomme la personne en base. La procedure pose le message de
    reussite sous « - », que [Message de la revision] lit sur ec02 ; la fonction le pose de meme apres le commit, et pose
    un refus de la procedure apres le rollback."""
    qui = _qui(ctx)
    if _vide(teneur) is None or teneur.strip().lower() != qui.strip().lower():
        raise fn.UserThrownError("Ajout refusé : seuls l’associé et le réviseur ajoutent une question de référence, et "
                                 "votre adresse de connexion ne porte aucun mandat d’associé ni de réviseur en cours.", {})
    g = _geste(base, ctx, "-")

    def faire():
        r = _executer(base, "EXEC dbo.pr_ecran_ajouter_question @cycle_ou_phase=?, @enonce=?, @par=?",
                      (_vide(cycleOuPhase), _vide(enonce), g.qui), g)
        return r.get("message") or "Question ajoutée."
    return _rendre(g, "ajouter_question", faire)
