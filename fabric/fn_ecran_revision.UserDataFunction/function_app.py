"""fn_ecran_revision : les boutons de l'ecran Revision, une fonction par bouton.

Ecrit le 16/09/2026 d'apres la maquette 73 validee et les scripts 207 et 208. Memes
regles que fn_ecran_client : chaque fonction appelle UNE procedure, rend la phrase du bouton, prend
l'utilisateur dans le contexte d'execution (PreferredUsername), et un refus remonte en francais par
UserThrownError. Connexions : « DossierOPCI » (base) et « Coffre » (lakehouse). Bibliotheque : openpyxl.

Les 6 etapes de la maquette et leurs boutons :
  1 Collecte      reclamer_document (fn_ecran_client la porte deja ; rappelee ici pour la page)
  2 Programme     choisir_programme, ajuster_programme, verifier_couverture, exporter_questions
  3 Questions     repondre_question, ouvrir_feuille, exporter_feuille, importer_classeur (feuille, OD,
                  questions), conclure_feuille, exporter_od, inscrire_piece (fn_ecran_client), valider_od_question
  4 OD libres     saisir_od, exporter_od (sans question), importer_classeur, valider_od_libres
  5 Conclure      conclure_cycle, viser (nature CYCLE ou REVUE, parametre superviseur obligatoire),
                  conclure_revue
  6 Dossier       exporter_dossier, deverrouiller_dossier, importer_classeur (dossier entier)

Le verrou (207) est controle par les procedures : une fonction n'a rien a en savoir, elle rend le refus.

LA ZONE DE MESSAGE DE L'ECRAN, 04/10/2026, comme l'ecran 1 (fn_ecran_client : _poser_message, _journaliser_refus).
Avant, un refus ou une reussite ne se lisait que dans la bulle du service, qui disparait. Chaque fonction pose
desormais son message dans la boite aux lettres de l'ecran, dbo.pr_poser_message_ecran, que le modele lit par
[Message de la revision] : la reussite avec la phrase rendue, le refus avec le texte de la base. Le refus se pose
APRES le rollback du geste, dans une connexion neuve donc une transaction neuve, et il est journalise par
dbo.pr_journaliser_refus : SQL Server n'a pas de transaction autonome, un message ecrit dans la transaction du geste
partirait avec son rollback (mesure du 21/09/2026 sur l'ecran 1).
L'ENTITE DU MESSAGE EST CELLE DU GESTE, jamais devinee dans les parametres : le parametre entite quand la fonction
en a un ; pour viser, l'entite en tete de objetRef (« entite|arrete|cycle », « entite|arrete »), et pour un lot le
vehicule du perimetre qui le porte ; pour une cote, le vehicule de la feuille. La regle de l'ecran 1, le 1er
parametre court et alphanumerique, prenait la nature « CYCLE » pour viser.
L'utilisateur vient du contexte de chaque appel, porte par le geste, et non d'une variable de module : 2 appels
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


def _message_sql(exc) -> str:
    s = str(exc)
    m = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQLExecDirectW\)|$)", s, re.S)
    return (m.group(1) if m else s).strip()


def _nom_procedure(sql) -> str:
    m = re.search(r"EXEC dbo\.(\w+)", sql or "")
    return m.group(1)[:128] if m else "inconnue"


# ----------------------------------------------------------------------------- la zone de message, 04/10/2026

class _Geste:
    """Le geste en cours : la base, la personne connectee, l'entite du message, les procedures appelees et le texte
    du dernier refus de la base."""

    def __init__(self, base, qui, entite):
        self.base, self.qui = base, qui
        e = None if entite is None else str(entite).strip()
        self.entite = e[:20] if e else None
        self.procedures, self.refus = [], None


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


def _poser(g: _Geste, message, genre: str, procedure: str, journal: bool = False) -> None:
    """Ecrit le message du geste dans dbo.message_ecran, et le refus dans dbo.journal_refus quand journal est vrai.
    UNE CONNEXION NEUVE, donc une transaction neuve : le geste a deja fait commit ou rollback, et sa connexion est
    fermee. Ne leve jamais : un message qui echoue ne doit pas masquer le geste qu'il rapporte."""
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
                            (procedure[:128], texte, g.qui, g.entite))
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


def _rendre(g: _Geste, nom: str, faire):
    """Execute le geste, puis pose son message : la phrase rendue a la reussite, le texte du refus sinon.

    faire() rend la phrase, ou (phrase, genre) quand la reussite porte des refus partiels (reimport d'un classeur).
    Un refus de la base ou de la fonction (UserThrownError) est journalise et pose, puis relance tel quel : la bulle
    du service le montre aussi. Une erreur imprevue est posee de meme, puis relancee."""
    try:
        r = faire()
    except fn.UserThrownError as e:
        _poser(g, g.refus or _texte(e), "REFUS", (g.procedures[-1] if g.procedures else nom), journal=True)
        raise
    except Exception as e:
        _poser(g, "Erreur d'exécution : %s" % (str(e) or e.__class__.__name__), "REFUS",
               (g.procedures[-1] if g.procedures else nom), journal=True)
        raise
    texte, genre = r if isinstance(r, tuple) else (r, "SUCCES")
    _poser(g, texte, genre, (g.procedures[0] if g.procedures else nom))
    return texte


def _executer(base: fn.FabricSqlConnection, sql: str, params: tuple, g: _Geste = None) -> dict:
    """Execute une procedure qui rend (…, message) et leve ses refus ; rend la derniere ligne. Le geste g, quand il
    est donne, retient la procedure et le texte du refus, que _rendre pose apres ce rollback."""
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
        conn.rollback()
        message = _message_sql(e)
        if g is not None:
            g.refus = message
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        conn.close()


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


def _superviseur(g: _Geste, superviseur: str) -> None:
    if not superviseur or superviseur.strip().lower() != g.qui.strip().lower():
        raise _refus(g, "Le visa est réservé au superviseur connecté ; l'action n'est pas exécutée.")


def _entite_de_cote(base, cote):
    """Le vehicule d'une feuille, pour le message : celui du perimetre qui porte la feuille (v_feuilles_du_cycle,
    filiales comprises), sinon l'entite de la feuille (les feuilles Q- sont au vehicule). None si rien."""
    try:
        l = _lire(base, "SELECT TOP 1 x.e FROM (SELECT vehicule AS e, 0 AS o FROM dbo.v_feuilles_du_cycle WHERE cote = ? "
                        "UNION ALL SELECT entite, 1 FROM dbo.feuille_travail WHERE cote = ?) x ORDER BY x.o", (cote, cote))
        return l[0]["e"] if l else None
    except Exception:
        return None


def _entite_de_visa(base, objetRef):
    """L'entite d'un visa, pour le message : la tete de objetRef pour un cycle ou une revue (« entite|arrete|cycle »,
    « entite|arrete ») ; pour un lot, dont objetRef est le seul numero, le vehicule du perimetre qui le porte
    (v_lots_perimetre, le sien d'abord), sinon l'entite du lot. Jamais la nature."""
    ref = (objetRef or "").strip()
    if "|" in ref:
        return ref.split("|", 1)[0].strip() or None
    if not ref.isdigit():
        return None
    try:
        l = _lire(base, "SELECT TOP 1 x.e FROM (SELECT vehicule AS e, CASE WHEN vehicule = entite THEN 0 ELSE 1 END AS o "
                        "FROM dbo.v_lots_perimetre WHERE lot_id = ? UNION ALL SELECT entite, 2 FROM dbo.lot_ecritures "
                        "WHERE id = ?) x ORDER BY x.o", (int(ref), int(ref)))
        return l[0]["e"] if l else None
    except Exception:
        return None


# ----------------------------------------------------------------------------- etape 2 : le programme

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def choisir_programme(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      entite: str, arrete: str, typeProgramme: str) -> str:
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
                      entite: str, arrete: str, reference: str, actif: int, motif: str = "") -> str:
    """Boutons « Ajouter au programme » et « Retirer du programme » : la selection change, le journal le dit.

    actif est un ENTIER, 1 ajoute et 0 retire, porte par une mesure constante comme les reponses Oui et
    Non ; un booleen ne se lie pas surement a une mesure. Le motif est obligatoire au retrait, la base le
    refuse sinon, regle du 28/09/2026."""
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
                  entite: str, arrete: str, cycle: str, actif: int, motif: str = "") -> str:
    """Boutons « Activer le cycle » et « Retirer le cycle » : toutes les questions eligibles du cycle.

    Regle du 28/09/2026 : un cycle qui a des comptes en balance ne se retire jamais en entier, la
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
def verifier_couverture(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str) -> str:
    """Bouton « Vérifier la couverture de la balance » : rend la phrase, ne modifie rien. Le contexte est ajoute le
    04/10/2026 pour savoir a qui poser le message ; les parametres du bouton restent entite et arrete."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_verifier_couverture @entite=?, @arrete=?", (entite, arrete), g)
        return r.get("message", "Couverture vérifiée.")
    return _rendre(g, "verifier_couverture", faire)


# ----------------------------------------------------------------------------- etape 3 : les questions

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def repondre_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      cote: str, reference: str, reponse: str, motif: str = "", commentaire: str = "") -> str:
    """La ligne de la question : OUI, NON, NA avec motif ; la cote est celle de la feuille Q-<cycle>-P<n>."""
    g = _geste(base, ctx, _entite_de_cote(base, cote))

    def faire():
        _executer(base, "EXEC dbo.pr_repondre_question @cote=?, @reference=?, @reponse=?, @motif_non_applicable=?, @commentaire=?, @par=?",
                  (cote, reference, _vide(reponse), _vide(motif), _vide(commentaire), g.qui), g)
        return f"Réponse à {reference} enregistrée."
    return _rendre(g, "repondre_question", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ouvrir_feuille(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str, arrete: str, reference: str) -> str:
    """Pop-up Feuille, « Ouvrir » : la feuille de la question, son gabarit, sa cote.

    LE GABARIT PREREMPLI PART AU COFFRE, depuis le 27/09/2026 : la maquette dit « ouvrir exporte le
    gabarit ; reimporter rattache le fichier ». Sans ce classeur, le bouton Reimporter n'avait rien a
    relire. Une feuille deja ouverte n'est pas une erreur ici : son classeur est reecrit."""
    g = _geste(base, ctx, entite)

    def faire():
        try:
            r = _executer(base, "EXEC dbo.pr_ouvrir_feuille_question @entite=?, @arrete=?, @reference=?, @par=?",
                          (entite, arrete, reference, g.qui), g)
            message = r.get("message", "Feuille ouverte.")
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
        r = _deposer(base, g, entite, arrete, f"feuille_{f[0]['cote']}.xlsx", wb)
        return f"{message} Gabarit déposé au site du cabinet : {r.get('web_url')}"
    return _rendre(g, "ouvrir_feuille", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_feuille(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     cote: str, forme: str, conclusion: str = "") -> str:
    """Pop-up Feuille, « Conclure » : forme et texte ; les portes de la feuille (pieces, derogation) parlent."""
    g = _geste(base, ctx, _entite_de_cote(base, cote))

    def faire():
        r = _executer(base, "EXEC dbo.pr_importer_feuille @cote=?, @conclusion=?, @forme=?, @par=?",
                      (cote, _vide(conclusion), forme.upper(), g.qui), g)
        return r.get("message", "Feuille conclue.")
    return _rendre(g, "conclure_feuille", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def valider_od_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                        entite: str, arrete: str, reference: str) -> str:
    """Pop-up OD, « Valider » : le brouillon de la question devient un lot propose au visa."""
    g = _geste(base, ctx, entite)

    def faire():
        l = _lire(base, "SELECT fq.cote, q.id FROM dbo.ref_question q JOIN dbo.feuille_question fq ON fq.question_id = q.id "
                        "JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.entite=? AND f.arrete=? AND f.cote LIKE 'Q-%' WHERE q.reference=?",
                  (entite, arrete, reference))
        if not l:
            raise _refus(g, f"La question {reference} n'est pas au programme de cet arrêté.")
        _executer(base, "EXEC dbo.pr_valider_brouillon @entite=?, @arrete=?, @feuille_cote=?, @question_id=?, @valide_par=?",
                  (entite, arrete, l[0]["cote"], l[0]["id"], g.qui), g)
        return f"OD de la question {reference} validées : le lot est proposé au visa."
    return _rendre(g, "valider_od_question", faire)


# ----------------------------------------------------------------------------- etape 4 : les OD libres

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def saisir_od(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
              entite: str, arrete: str, compte: str, libelle: str, debit: float = 0, credit: float = 0,
              reference: str = "", journal: str = "ODR", piece: str = "") -> str:
    """Une ligne d'OD, liee a une question si reference est donnee, libre sinon."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_saisir_od @entite=?, @arrete=?, @compte=?, @libelle=?, @debit=?, @credit=?, @reference=?, @journal=?, @piece_ref=?, @par=?",
                      (entite, arrete, compte, libelle, float(debit or 0), float(credit or 0), _vide(reference), journal or "ODR", _vide(piece), g.qui), g)
        return r.get("message", "Ligne enregistrée.")
    return _rendre(g, "saisir_od", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def saisir_od_double(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     entite: str, arrete: str, compte1: str, libelle1: str,
                     compte2: str, libelle2: str,
                     debit1: float = 0, credit1: float = 0,
                     debit2: float = 0, credit2: float = 0,
                     reference: str = "", journal: str = "ODR",
                     piece1: str = "", piece2: str = "") -> str:
    """Les 2 lignes d'une ecriture de revision, ecrites en un seul geste.

    Une ecriture porte toujours au moins 2 lignes. Les saisir une par une obligeait a vider le
    champ oppose entre les 2, et la seconde partait sans sa reference : l'execution d'une
    fonction efface la ligne choisie dans la grille. Regle du 26/09/2026.
    """
    # LES 2 LIGNES S'ECRIVENT ENSEMBLE OU PAS DU TOUT, depuis le 03/10/2026 : pr_saisir_od_paire
    # controle les 2 lignes avant toute ecriture, un refus n'en ecrit aucune. Avant, la 1re ligne restait
    # au brouillon quand la 2e etait refusee. Une seule ligne saisie passe par pr_saisir_od.
    g = _geste(base, ctx, entite)

    def faire():
        un, deux = (compte1 or "").strip(), (compte2 or "").strip()
        if not un and not deux:
            raise _refus(g, "Aucun compte saisi : une écriture porte au moins une ligne.")
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
                     entite: str, arrete: str, ligneId: str) -> str:
    """Etape 4, « Retirer la ligne » : la ligne choisie du brouillon libre, par son identifiant
    (v_od_revision[brouillon_id]). La base refuse une ligne hors du brouillon libre de l'arrete (50403)
    et un dossier verrouille (50404), et garde la trace du retrait (od_retrait). 03/10/2026.

    ligneId EST UN TEXTE, depuis le 03/10/2026 : un parametre de bouton Data function ne se lie jamais a
    une mesure numerique (documentation desktop-buttons). La mesure [Ligne OD libre choisie] rend donc le
    N° en texte, et la conversion se fait ici."""
    g = _geste(base, ctx, entite)

    def faire():
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
def valider_od_libres(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str) -> str:
    """Bouton « Valider le brouillon » des OD libres : equilibre exige, lot propose au visa."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_valider_od_libres @entite=?, @arrete=?, @valide_par=?", (entite, arrete, g.qui), g)
        return r.get("message", "OD libres validées.")
    return _rendre(g, "valider_od_libres", faire)


# ----------------------------------------------------------------------------- etape 5 : conclure et viser

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_cycle(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str, arrete: str, cycle: str, conclusion: str, forme: str = "") -> str:
    """Bouton « Enregistrer la conclusion du cycle » : la synthese des feuilles se regenere, le texte se pose."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_conclure_cycle @entite=?, @arrete=?, @cycle=?, @conclusion=?, @forme=?, @par=?",
                      (entite, arrete, cycle, conclusion, _vide(forme), g.qui), g)
        return r.get("message", "Cycle conclu.")
    return _rendre(g, "conclure_cycle", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def conclure_revue(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                   entite: str, arrete: str, conclusion: str) -> str:
    """Bouton « Enregistrer la conclusion générale »."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_conclure_revue @entite=?, @arrete=?, @conclusion=?, @par=?",
                      (entite, arrete, conclusion, g.qui), g)
        return r.get("message", "Revue conclue.")
    return _rendre(g, "conclure_revue", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def viser(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
          nature: str, objetRef: str, decision: str, superviseur: str, motif: str = "") -> str:
    """Boutons « Viser le cycle », « Viser la revue », « Renvoyer » : pr_ecran_viser, un seul bouton pour
    toutes les natures. objetRef : « entite|arrete|cycle » pour CYCLE, « entite|arrete » pour REVUE.
    Le parametre superviseur est lie a la mesure Superviseur connecte : vide pour un preparateur.

    LE MOTIF EST FACULTATIF ICI ET AU BOUTON : un renvoi sans motif part,
    la base le refuse (50057, pr_garde_visa), et le refus s'affiche dans la zone de message de l'ecran. L'entite du
    message est celle de objetRef, jamais la nature (_entite_de_visa)."""
    g = _geste(base, ctx, _entite_de_visa(base, objetRef))

    def faire():
        _superviseur(g, superviseur)
        r = _executer(base, "EXEC dbo.pr_ecran_viser @nature=?, @objet_ref=?, @decision=?, @decide_par=?, @motif=?",
                      (nature.upper(), objetRef, decision.upper(), g.qui, _vide(motif)), g)
        return r.get("message", f"{nature} : {decision.lower()}.")
    return _rendre(g, "viser", faire)


# ----------------------------------------------------------------------------- etape 6 : le dossier

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def deverrouiller_dossier(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str,
                          motif: str = "", demandePar: str = "") -> str:
    """Bouton « Déverrouiller le dossier de travail », depuis le 03/10/2026 :
    un motif, la personne qui demande le deverrouillage et celle qui le decide, distinctes ; la decideuse est
    la personne connectee. La trace est un visa de revue renvoye, motif « Déverrouillage : ». Sans motif ou
    sans demandeur, la base refuse avec un message lisible (50516). Pas de tiret bas dans un nom de parametre :
    le service le refuse, d'ou demandePar."""
    g = _geste(base, ctx, entite)

    def faire():
        r = _executer(base, "EXEC dbo.pr_deverrouiller_dossier @entite=?, @arrete=?, @motif=?, @demande_par=?, @par=?",
                      (entite, arrete, _vide(motif), _vide(demandePar), g.qui), g)
        return r.get("message", "Dossier déverrouillé.")
    return _rendre(g, "deverrouiller_dossier", faire)


# ----------------------------------------------------------------------------- la voie du classeur

# REGLE SANS DEROGATION, du 28/09/2026 : TOUT FICHIER SE DEPOSE DANS
# SHAREPOINT, et le coffre ne le voit que par un raccourci OneLake. Aucun export n'ecrit plus au
# coffre : chaque classeur part au site du cabinet par _deposer, et le reimport le relit par le
# raccourci fec. Le 27/09/2026, les exports ecrivaient en natif dans Files/exports/ : c'etait une
# derogation, levee ici.
# Meme lecture que 61_DEPLOIEMENT/gabarits_ecran_revision.py et importer_ecran_revision.py.

_COL_Q = [("Cycle", "cycle"), ("Référence", "reference"), ("Question", "enonce"), ("Type", "type"), ("Réponse", "reponse"),
          ("Motif si non applicable", "motif"), ("Commentaire", "commentaire"), ("Feuille", "feuille_cote"), ("OD", "od"), ("Pièces", "pieces")]
_COL_OD = [("Journal", "journal"), ("Compte", "compte"), ("Libellé", "libelle"), ("Débit", "debit"), ("Crédit", "credit"), ("Pièce", "piece"), ("Actif", "actif")]
# L'ONGLET D'OD D'UN CYCLE porte la question de chaque ligne : sans elle, le reimport ne sait pas quel
# brouillon remplacer, et il ignorait l'onglet. Ajoute le 27/09/2026.
_COL_OD_CYCLE = [("Question", "reference")] + _COL_OD
_SAISIE = {"reference", "reponse", "motif", "commentaire", "journal", "compte", "libelle", "debit", "credit", "piece", "actif", "forme", "conclusion", "objectif", "methodologie"}


def _entete(ws, colonnes):
    from openpyxl.styles import Font, PatternFill
    for j, (lib, cle) in enumerate(colonnes, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = PatternFill("solid", fgColor="1D1A10")
        c.font = Font(bold=True, color="FFFFFF") if cle in _SAISIE else Font(color="D9D2C0")
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
        # LA LARGEUR SUIT L'EN-TETE, releve le 28/09/2026 dans Excel en ligne : « Balance in »,
        # « OD de révi », les en-tetes etaient coupes faute de largeur posee. Question et
        # Libellé prennent plus, leur texte etant long.
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


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_questions(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str, cycle: str) -> str:
    """Etape 2, « Ouvrir le classeur des questions du cycle » : les questions au programme, reponses comprises."""
    g = _geste(base, ctx, entite)

    def faire():
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        d = _questions(base, entite, arrete, cycle)
        if not d:
            raise _refus(g, f"Aucune question du cycle {cycle} au programme de cet arrêté.")
        _feuille_questions(wb, "Q-" + cycle, d)
        r = _deposer(base, g, entite, arrete, f"questions_{cycle}_{entite}_{arrete}.xlsx", wb)
        return f"Classeur de {len(d)} questions déposé au site du cabinet : {r.get('web_url')}"
    return _rendre(g, "exporter_questions", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_od(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str, arrete: str, reference: str = "") -> str:
    """Pop-up OD, « Exporter les OD liées » (reference donnee) ou etape 4, « Exporter le gabarit » (OD libres) : preremplies."""
    g = _geste(base, ctx, entite)

    def faire():
        from openpyxl import Workbook
        wb = Workbook(); wb.remove(wb.active)
        ref = _vide(reference)
        d = _od(base, entite, arrete, reference=ref, libres=ref is None)
        _feuille_od(wb, ("OD " + ref) if ref else "OD libres", d)
        r = _deposer(base, g, entite, arrete, f"od_{ref or 'libres'}_{entite}_{arrete}.xlsx", wb)
        return f"Classeur de {len(d)} ligne(s) préremplie(s) déposé au site du cabinet : {r.get('web_url')}"
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
                     entite: str, arrete: str) -> str:
    """Etapes 3 et 6, « Exporter le dossier de travail » : Balance, Programme, puis par cycle Q, FT, OD ; OD libres.

    LE CLASSEUR PART AUSSI DANS SHAREPOINT, regle du 27/09/2026 : le reviseur doit
    recevoir un lien qui s'ouvre au clic, et l'adresse OneLake directe rend « Unauthorized » dans
    le navigateur, mesure du meme jour. Le depot passe par la base, pr_deposer_classeur, qui appelle
    l'Azure Function du cabinet sous identite managee : une Data function n'a pas d'identite a elle.
    Le site est celui du CABINET, jamais l'espace du client : le dossier de travail est au cabinet."""
    g = _geste(base, ctx, entite)

    def faire():
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
        r = _deposer(base, g, entite, arrete, f"dossier_{entite}_{arrete}.xlsx", wb)
        return f"Dossier de travail, {len(wb.sheetnames)} onglets, déposé au site du cabinet : {r.get('web_url')}"
    return _rendre(g, "exporter_dossier", faire)


def _lignes_de(ws):
    """Les lignes d'un onglet, cle par cle, et le numero de la ligne dans l'onglet sous « _ligne » : la
    base le cite dans ses refus (« Ligne 9 du classeur : … »), depuis le 03/10/2026."""
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
                      entite: str, arrete: str, chemin: str) -> str:
    """Bouton « Réimporter » de toutes les etapes : le classeur depose au coffre, reconnu a ses feuilles :
    Q-<cycle> (reponses), OD <reference>, OD-<cycle> ou OD libres (brouillon remplace), <cote> (feuille : forme,
    conclusion). Balance et Programme ne s'importent pas : l'une se calcule, l'autre se choisit a l'etape 2."""
    g = _geste(base, ctx, entite)

    def faire():
        # LE CHEMIN EST CELUI DE LA FONCTION ENGLOBANTE, et faire() le reecrit pour un ancien chemin exports/ :
        # sans nonlocal, Python le tient pour une variable locale de faire(), lue avant d'etre affectee.
        # Mesure du 04/10/2026 : « An internal execution error occured » au clic sur « Réimporter le dossier »,
        # apres la reecriture pour la zone de message ; pyflakes le signale.
        nonlocal chemin
        from openpyxl import load_workbook
        import hashlib
        # LE DOSSIER DEPOSE DANS SHAREPOINT PRIME SUR SA COPIE DU COFFRE, depuis le 28/09/2026. Le
        # reviseur modifie le classeur dans Excel en ligne ; relire la copie du coffre perdrait son
        # travail. La recette l'a montre : l'ecran, non rafraichi apres l'export, envoyait encore le
        # chemin du coffre. La resolution se fait donc ici, et non dans une mesure.
        # LA SOURCE SE LIT SUR LE CHEMIN : fec/ est le raccourci du coffre vers le site du cabinet. La
        # mesure de l'ecran envoie deja ce chemin quand un depot existe, releve le 28/09/2026 ; le
        # message disait pourtant « coffre », faute d'avoir regarde le chemin recu.
        # UN ANCIEN CHEMIN exports/ SE LIT DESORMAIS AU SITE DU CABINET : plus aucun classeur n'est ecrit
        # au coffre, regle du 28/09/2026. Le depot range chaque classeur sous Dossiers de travail/<entite>/
        # <arrete>/, et le raccourci fec le rend lisible d'ici.
        if chemin.startswith("exports/"):
            chemin = f"fec/Dossiers de travail/{entite}/{arrete}/{chemin.rsplit('/', 1)[-1]}"
        source = "site du cabinet" if chemin.startswith("fec/") else "coffre"
        octets = coffre.connectToFiles().get_file_client(chemin).download_file().readall()
        wb = load_workbook(io.BytesIO(octets), data_only=True)
        par = g.qui
        faits, refus = [], []
        for ws in wb.worksheets:
            t = ws.title
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
                elif t.startswith("OD-"):
                    # L'ONGLET D'OD D'UN CYCLE, dans le dossier de travail. Chaque question du cycle voit son
                    # brouillon REMPLACE par ses lignes de l'onglet ; une question dont toutes les lignes ont
                    # ete effacees voit donc son brouillon vide, ce qui est le sens du geste.
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
                elif t == "OD libres" or t.startswith("OD "):
                    ref = None if t == "OD libres" else t[3:].strip()
                    lignes = [{"ligne": d["_ligne"], "journal": d.get("journal") or "ODR", "compte": str(d.get("compte")).strip(), "libelle": d.get("libelle"),
                               "debit": float(d.get("debit") or 0), "credit": float(d.get("credit") or 0), "piece": d.get("piece"), "actif": d.get("actif")}
                              for d in _lignes_de(ws) if d.get("compte") and str(d.get("compte")).strip().lower() not in ("total", "écart")]
                    # LES OD LIBRES PASSENT LE NOM DU CLASSEUR, sans dossier, depuis le 03/10/2026 : la base
                    # date son instant de reference par le dernier depot ou reimport de ce fichier, et refuse un
                    # classeur qui ferait perdre une saisie ou revenir un retrait posterieurs (50405, 50408), ou
                    # qu'elle ne connait pas (50406). Sans ce nom, elle refuse tout reimport d'OD libres (50409).
                    fichier = chemin.rsplit("/", 1)[-1] if ref is None else None
                    r = _executer(base, "EXEC dbo.pr_importer_od @entite=?, @arrete=?, @reference=?, @lignes=?, @par=?, @fichier=?",
                                  (entite, arrete, ref, json.dumps(lignes, ensure_ascii=False, default=str), par, fichier), g)
                    faits.append(f"{t} : {r.get('message', 'importé')}")
                else:
                    valeurs = {}
                    for row in ws.iter_rows(min_row=1, values_only=True):
                        if len(row) >= 3 and row[2] in ("cote", "forme", "conclusion", "objectif"):
                            valeurs[row[2]] = row[1]
                    cote = valeurs.get("cote") or t
                    # L'OBJECTIF DE LA FEUILLE SE RELIT, depuis le 03/10/2026 : prerempli
                    # depuis le gabarit, modifiable dans le classeur. Vide, il laisse en place celui de la base.
                    r = _executer(base, "EXEC dbo.pr_importer_feuille @cote=?, @conclusion=?, @forme=?, @nom_fichier=?, @empreinte=?, @par=?, @objectif=?",
                                  (cote, _vide(valeurs.get("conclusion")), _vide(valeurs.get("forme")), chemin.rsplit("/", 1)[-1],
                                   hashlib.sha256(octets).hexdigest().upper(), par, _vide(valeurs.get("objectif"))), g)
                    faits.append(f"{t} : {r.get('message', 'importé')}")
            except fn.UserThrownError as e:
                refus.append(f"{t} : {g.refus or _texte(e)}")
                g.refus = None
        texte = f"Classeur relu au {source}. {len(faits)} onglet(s) importé(s)." + (" " + " ".join(faits) if faits else "")
        if refus:
            texte += " Refusés : " + " ; ".join(refus)
        # UN REFUS PARTIEL S'AFFICHE EN REFUS : la zone de message passe au rose des qu'un onglet est refuse,
        # meme si d'autres sont importes ; la phrase dit lesquels.
        return texte, ("REFUS" if refus else "SUCCES")
    return _rendre(g, "importer_classeur", faire)
