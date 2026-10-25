"""fn_ecran_arrete : les boutons de l'ecran Arrete (ecran 4), une fonction par bouton.

Lot 4 de la feuille de route 65_JOURNAL/roadmap_ecran_4_arrete.md ; maquette retenue
20_LIVRABLES_V2/PARCOURS_ECRANS/82_arrete_option_2.html (objets de fonction n° 163 a 169). Memes regles que
fn_ecran_valorisation : chaque fonction appelle UNE procedure d'ecran de la base (lot 1 de la feuille de route), rend
la phrase du bouton, prend l'utilisateur dans le contexte d'execution (PreferredUsername) et jamais dans un parametre,
et un refus remonte en francais par UserThrownError. Connexion : « DossierOPCI » (base). Aucune autre bibliotheque que
fabric-user-data-functions.

Les etapes de l'ecran et leurs boutons :
  1  Ratios reglementaires   conclure_ratio        -> pr_ecran_conclure_ratio
  2  Valeur liquidative      « Publier la VL » appelle fn_ecran_revision.viser (nature PUBLICATION), pas cet element
  3a Base et visa            proposer_obligation   -> pr_ecran_proposer_obligation
                             viser_obligation      -> pr_ecran_viser_obligation_distribution
  3b Decision de l'assemblee decider_distribution  -> pr_ecran_decider_distribution

LES PARAMETRES (reprise du 15/10/2026, decision du candidat « Gris + refus en français »). Seule la decision du bouton
(VISE ou RENVOYE), constante qui n'est jamais vide, reste obligatoire (sans valeur par defaut). Tout autre parametre a
une valeur par defaut vide : entite et arrete des selecteurs, le droit (reviseur = [Reviseur connecte] pour la
proposition, associe = [Associe connecte] pour le visa), le segment « Limite » ou « Categorie » et chaque champ de
saisie. Motif : un parametre facultatif dont la mesure est vide n'est pas envoye par le bouton
(GUIDE_API_RAPPORT_POWER_BI.md, § 17.43, point 8) ; sans valeur par defaut, la fonction ne pourrait pas le refuser en
francais, et un parametre obligatoire vide desactive le bouton avec une bulle anglaise (meme guide, § 3.2, point 2).
Learn, « Fabric user data function programming model overview », « Default values » : un parametre qui a une valeur
par defaut est facultatif a l'appel. Une valeur vide est refusee en francais avant toute lecture ou procedure de la
base : le vehicule et l'arrete (_selecteurs : le texte de 50701 de fn_e3_refus_commun pour le vehicule, et pour
l'arrete la 1re phrase de 50702, sans sa suite « celui reçu n'existe pas pour ce véhicule », un arrete vide n'etant
pas un arrete inconnu), puis le droit (_droit) ;
le refus est ensuite pose et journalise comme tout refus (_rendre). Le champ de saisie vide reste refuse par la base,
ou par la fonction quand la base ne nomme pas le champ.

LE GRIS PAR DROIT OU PAR ETAT (decision du candidat du 15/10/2026). Sur les ecrans 4 et 5, un bouton de fonction sans
droit ou hors d'etat prend la couleur grise par une mesure et reste cliquable : la fonction refuse alors en francais.
Couche de la fonction, dans cet ordre, avant tout appel de procedure : les selecteurs (vehicule, puis arrete, non
vides), le droit (le parametre de droit egal a la personne connectee), puis, pour la decision, l'etat que la procedure
ne lit pas (arrete annuel, lu sur ref_arrete).
Les autres etats (arrete annuel ouvert, valeur liquidative publiee, base proposee, categorie visee, arrete valide pour
le client, limite sans objet) sont refuses par la base elle-meme, dans l'ordre de ses procedures (lot 1).

LE LIBELLE D'UN SEGMENT EST TRADUIT EN CODE PAR LA FONCTION : la limite par ref_ratio_memoire (code ou libelle), la
categorie d'obligation par dbo.fn_e4_categorie, la categorie de la decision par ref_obligation_distribution (RESULTAT,
PLUS_VALUES, EXONEREES). Un libelle qui ne se traduit pas part tel quel : la procedure le refuse en le citant, a son
rang.

LE MESSAGE S'ECRIT SOUS LE VEHICULE DU SELECTEUR : chaque procedure rend une ligne (vehicule, message), sauf
pr_ecran_decider_distribution, dont la phrase est composee ici ; la fonction pose ce message par
dbo.pr_poser_message_ecran, la reussite comme le refus. Le refus se pose APRES le rollback de l'action, dans une
connexion neuve, et il est journalise par dbo.pr_journaliser_refus.

UN TEXTE SAISI plus long que la colonne qui le recoit est refuse ici en nommant le champ : la base tronquerait sans
le dire un parametre de procedure trop long. Limites de la maquette retenue : conclusion 600 caracteres, source 400,
motif du renvoi 400.

UN MONTANT SAISI se lit en francais (« 5 400 000,00 ») ou en notation decimale (« 5400000.00 ») ; un texte qui n'est pas
un nombre est refuse en nommant le champ. UNE DATE SAISIE se lit jj/mm/aaaa (ou aaaa-mm-jj).

UNE ERREUR NON PREVUE REMONTE EN FRANCAIS : seul un refus de la base (numero d'au moins 50000, THROW) devient le texte du
bouton ; toute autre erreur (moteur SQL, pilote, Python) rend le texte francais de l'erreur d'execution, le detail
technique allant au seul journal des refus (guide de l'element Plan, point 47).

LE NOM DE LA CONNEXION. L'argument de la connexion s'appelle « connexion », et non « base » comme dans les autres
elements : « base » est le parametre de saisie de proposer_obligation (maquette retenue), et un nom d'argument ne sert
qu'une fois.
"""

import datetime
import re
from decimal import Decimal, InvalidOperation

import fabric.functions as fn

udf = fn.UserDataFunctions()


# ----------------------------------------------------------------------------- outils, identiques a fn_ecran_valorisation

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

    def __init__(self, connexion, qui, entite):
        self.connexion, self.qui = connexion, qui
        e = None if entite is None else str(entite).strip()
        self.entite = e[:20] if e else None
        self.procedures, self.refus = [], None


def _action(connexion, ctx, entite) -> _Action:
    return _Action(connexion, _qui(ctx), entite)


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
        conn = g.connexion.connect()
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
    """Execute l'action, puis pose son message : la phrase rendue a la reussite, le texte du refus sinon."""
    try:
        texte = faire()
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
    _poser(g, texte, "SUCCES", (g.procedures[0] if g.procedures else nom))
    return texte


def _executer_tout(connexion: fn.FabricSqlConnection, sql: str, params: tuple, g: _Action = None) -> list:
    """Execute une procedure et rend les lignes de TOUS ses jeux de resultats, dans l'ordre ; leve ses refus. L'action
    g retient la procedure et le texte du refus, que _rendre pose apres ce rollback. Seul un refus de la base (numero
    d'au moins 50000) devient une UserThrownError a son texte ; toute autre erreur est relevee telle quelle apres le
    rollback, et _rendre la rend en francais (en-tete)."""
    if g is not None:
        g.procedures.append(_nom_procedure(sql))
        g.refus = None
    conn = connexion.connect()
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


def _executer(connexion: fn.FabricSqlConnection, sql: str, params: tuple, g: _Action = None) -> dict:
    """La ligne qui porte le message, sinon la derniere ligne rendue."""
    lignes = _executer_tout(connexion, sql, params, g)
    portant = [l for l in lignes if "message" in l]
    return (portant or lignes or [{}])[-1]


def _lire(connexion: fn.FabricSqlConnection, sql: str, params: tuple) -> list:
    conn = connexion.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        colonnes = [d[0] for d in cur.description]
        return [dict(zip(colonnes, l)) for l in cur.fetchall()]
    finally:
        conn.close()


def _vide(s):
    return None if s is None or str(s).strip() == "" else str(s).strip()


_ESPACES = (" ", " ", " ")


def _nombre(g: _Action, valeur, libelle: str):
    """Le nombre d'une saisie, en Decimal, ou None quand le champ est vide.
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


def _date_ecran(arrete: str) -> str:
    try:
        return datetime.date.fromisoformat(arrete).strftime("%d/%m/%Y")
    except (TypeError, ValueError):
        return arrete


def _montant_ecran(x) -> str:
    """2 decimales, separateur de milliers U+202F et virgule decimale, comme FORMAT(x, 'N2', 'fr-FR') de la base."""
    return "{:,.2f}".format(Decimal(str(x))).replace(",", " ").replace(".", ",")


# ----------------------------------------------------------------------------- outils propres a l'ecran 4

REFUS_VEHICULE = "Choisissez le véhicule dans le sélecteur Véhicule."
REFUS_ARRETE = "Choisissez l'arrêté dans le sélecteur Arrêté."


def _selecteurs(g: _Action, entite, arrete) -> None:
    """Les 2 selecteurs de l'en-tete, lies aux parametres entite et arrete. Facultatifs au bouton : une mesure vide
    n'envoie pas le parametre, qui prend la valeur par defaut vide. Refus en francais avant toute lecture ou procedure
    de la base, le vehicule d'abord, comme fn_e3_refus_commun (50701, puis 50702) : REFUS_VEHICULE est le texte de
    50701, REFUS_ARRETE la 1re phrase de 50702, dont la suite vise un arrete inconnu du vehicule."""
    if _vide(entite) is None:
        raise _refus(g, REFUS_VEHICULE)
    if _vide(arrete) is None:
        raise _refus(g, REFUS_ARRETE)


def _droit(g: _Action, valeur, texte: str) -> None:
    """Le droit d'un bouton : la mesure liee au parametre rend la connexion de la personne connectee quand elle tient
    le role sur le vehicule. Toute autre valeur, vide comprise, est un refus en francais, avant tout appel."""
    v = _vide(valeur)
    if v is None or v.lower() != g.qui.strip().lower():
        raise _refus(g, texte)


def _texte_saisi(g: _Action, valeur, libelle: str, maximum: int):
    """Un texte saisi, ou None quand le champ est vide ; au-dela de maximum caracteres, refus qui nomme le champ."""
    t = _vide(valeur)
    if t is not None and len(t) > maximum:
        raise _refus(g, f"« {libelle} » : {maximum} caractères au plus ; le texte saisi en compte {len(t)}.")
    return t


def _date_saisie(g: _Action, valeur, libelle: str):
    """La date d'une saisie jj/mm/aaaa (ou aaaa-mm-jj), ou None quand le champ est vide ; refus qui nomme le champ
    pour toute autre forme ou une date qui n'existe pas."""
    t = _vide(valeur)
    if t is None:
        return None
    m = re.fullmatch(r"(\d{1,2})/(\d{1,2})/(\d{4})", t)
    try:
        if m:
            return datetime.date(int(m.group(3)), int(m.group(2)), int(m.group(1)))
        if re.fullmatch(r"\d{4}-\d{2}-\d{2}", t):
            return datetime.date.fromisoformat(t)
    except ValueError:
        pass
    raise _refus(g, f"« {libelle} » : « {t} » n'est pas une date au format jj/mm/aaaa.")


def _code_limite(connexion, valeur):
    """Le code de la limite choisie au segment « Limite » (libelle de ref_ratio_memoire), ou le texte recu tel quel
    quand il ne se traduit pas : pr_ecran_conclure_ratio le refuse alors en le citant (50801)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) code FROM dbo.ref_ratio_memoire WHERE code = ? OR libelle = ?", (t, t))
    return l[0]["code"] if l and l[0].get("code") else t


def _code_obligation(connexion, valeur):
    """Le code d'obligation_distribution de la categorie choisie au segment « Catégorie » (libelle de
    ref_obligation_distribution), par dbo.fn_e4_categorie, celle que les procedures d'ecran appliquent ; le texte recu
    tel quel quand il ne se traduit pas : la procedure le refuse alors en le citant (50813, 50823)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT dbo.fn_e4_categorie(?) AS code", (t,))
    return l[0]["code"] if l and l[0].get("code") else t


def _categorie_decision(connexion, valeur):
    """(code, libelle) de ref_obligation_distribution pour la categorie choisie : RESULTAT, PLUS_VALUES ou EXONEREES,
    le code que pr_decider_distribution_corps lit ; (texte recu, None) quand il ne se traduit pas : la procedure le
    refuse alors (50090, categorie hors du referentiel)."""
    t = _vide(valeur)
    l = _lire(connexion, "SELECT TOP (1) categorie, libelle FROM dbo.ref_obligation_distribution "
                         "WHERE categorie = ? OR libelle = ?", (t, t))
    return (l[0]["categorie"], l[0]["libelle"]) if l else (t, None)


REFUS_REVISEUR = ("Proposition refusée : la base se propose par le préparateur du dossier, rôle que votre adresse de "
                  "connexion ne tient pas.")
REFUS_ASSOCIE = ("Visa refusé : le visa d'une catégorie est réservé à l'associé signataire du dossier, rôle que votre "
                 "adresse de connexion ne tient pas.")
REFUS_CATEGORIE = "Choisissez la catégorie dans la liste « Catégorie »."


# ----------------------------------------------------------------------------- 1, les ratios reglementaires

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def conclure_ratio(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                   arrete: str = "", ratio: str = "", conclusion: str = "") -> str:
    """Bouton « Conclure la limite » : la conclusion saisie de la limite choisie au segment « Limite » (libelle de
    ref_ratio_memoire, traduit en code), pour le vehicule a l'arrete. La fonction refuse d'abord un vehicule ou un
    arrete vide (_selecteurs) ; pr_ecran_conclure_ratio refuse ensuite, dans cet ordre : vehicule, arrete, equipe et
    verrou (fn_e3_refus_commun), limite non choisie (50800), limite inconnue (50801), conclusion vide (50802), arrete
    valide pour le client (50803), limite sans objet pour le vehicule (50804)."""
    g = _action(connexion, ctx, entite)

    def faire():
        _selecteurs(g, entite, arrete)
        c = _texte_saisi(g, conclusion, "Conclusion de la limite", 600)
        code = _code_limite(connexion, ratio)
        r = _executer(connexion, "EXEC dbo.pr_ecran_conclure_ratio @entite=?, @arrete=?, @code=?, @conclusion=?, @par=?",
                      (entite, arrete, code, c, g.qui), g)
        return r.get("message") or f"Limite conclue au {_date_ecran(arrete)}."
    return _rendre(g, "conclure_ratio", faire)


# ----------------------------------------------------------------------------- 3a, la base et le visa par categorie

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def proposer_obligation(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                        arrete: str = "", reviseur: str = "", categorie: str = "", base: str = "",
                        source: str = "") -> str:
    """Bouton « Proposer la base » : la base de calcul et sa source de la categorie choisie au segment « Catégorie ».
    La fonction refuse d'abord un vehicule ou un arrete vide (_selecteurs). Le parametre reviseur est lie a la mesure
    [Reviseur connecte] : il doit egaler la personne connectee, vide refuse (droit, decision du 09/10/2026, le
    reviseur propose la base). pr_ecran_proposer_obligation refuse ensuite, dans cet ordre :
    categorie, base ou source vide (50810 a 50812), categorie inconnue (50813), role PREPARATEUR absent (50814),
    arrete qui n'est pas un arrete annuel ouvert (50815), categorie deja visee (50816) ; a l'ecriture, 50086 garde le
    publiant de la valeur liquidative."""
    g = _action(connexion, ctx, entite)

    def faire():
        _selecteurs(g, entite, arrete)
        _droit(g, reviseur, REFUS_REVISEUR)
        b = _nombre(g, base, "Base proposée")
        s = _texte_saisi(g, source, "Source de la base", 400)
        cat = _code_obligation(connexion, categorie)
        r = _executer(connexion, "EXEC dbo.pr_ecran_proposer_obligation @entite=?, @arrete=?, @categorie=?, @base=?, "
                                 "@source=?, @par=?", (entite, arrete, cat, b, s, g.qui), g)
        return r.get("message") or "Base proposée : elle attend le visa de l'associé."
    return _rendre(g, "proposer_obligation", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def viser_obligation(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, decision: str,
                     entite: str = "", arrete: str = "", associe: str = "", categorie: str = "",
                     motif: str = "") -> str:
    """Boutons « Viser la catégorie » (decision VISE) et « Renvoyer la catégorie » (decision RENVOYE). decision,
    constante du bouton, est le seul parametre obligatoire, donc le 1er de la signature ; l'invocation porte chaque
    parametre sous son nom (corps releve au lot 5, R8). La fonction refuse d'abord un vehicule ou un arrete vide
    (_selecteurs). Le parametre associe est lie a la mesure [Associe connecte] : il doit egaler la personne connectee,
    vide refuse (droit, decision du 09/10/2026, l'associe signataire vise chaque categorie).
    pr_ecran_viser_obligation_distribution refuse ensuite, dans cet ordre : categorie vide (50820), decision hors VISE
    et RENVOYE (50821), renvoi sans motif (50822), categorie inconnue (50823), puis les 5 refus 50036 de
    pr_viser_obligation_distribution (aucun arrete annuel, valeur liquidative non publiee, base non proposee, categorie
    deja visee, proposant introuvable)."""
    g = _action(connexion, ctx, entite)

    def faire():
        _selecteurs(g, entite, arrete)
        _droit(g, associe, REFUS_ASSOCIE)
        m = _texte_saisi(g, motif, "Motif du renvoi", 400)
        cat = _code_obligation(connexion, categorie)
        r = _executer(connexion, "EXEC dbo.pr_ecran_viser_obligation_distribution @entite=?, @arrete=?, @categorie=?, "
                                 "@decision=?, @motif=?, @vise_par=?",
                      (entite, arrete, cat, (decision or "").strip().upper(), m, g.qui), g)
        return r.get("message") or ("Catégorie visée." if (decision or "").strip().upper() == "VISE"
                                    else "Catégorie renvoyée au préparateur.")
    return _rendre(g, "viser_obligation", faire)


# ----------------------------------------------------------------------------- 3b, la decision de l'assemblee

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def decider_distribution(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, entite: str = "",
                         arrete: str = "", categorie: str = "", montant: str = "", assemblee: str = "") -> str:
    """Bouton « Enregistrer la décision » : le montant decide par l'assemblee pour la categorie choisie au segment
    « Catégorie » (libelle traduit en RESULTAT, PLUS_VALUES ou EXONEREES) et la date de l'assemblee, facultative comme
    dans la base. La fonction refuse d'abord un vehicule ou un arrete vide (_selecteurs), avant la lecture de
    ref_arrete. pr_ecran_decider_distribution ne recoit que l'exercice et ne lit pas le type de l'arrete : la
    fonction refuse ensuite un arrete qui n'est pas ANNUEL, lu sur ref_arrete (couche fonctionnelle du gris de
    [Blocage decision]), puis la categorie et le montant vides, un montant qui n'est pas un nombre et une date qui n'est
    pas une date ; la procedure refuse une categorie hors du referentiel, des sommes distribuables non calculables et
    un montant hors des bornes (50090). L'exercice transmis est l'arrete annuel, egal a son exercice dans ref_arrete."""
    g = _action(connexion, ctx, entite)

    def faire():
        _selecteurs(g, entite, arrete)
        a = _lire(connexion, "SELECT type_arrete FROM dbo.ref_arrete WHERE entite = ? AND arrete = ?", (entite, arrete))
        if not a:
            raise _refus(g, "Choisissez l'arrêté dans le sélecteur Arrêté : celui reçu n'existe pas pour ce véhicule.")
        if (a[0].get("type_arrete") or "") != "ANNUEL":
            raise _refus(g, f"Décision refusée : la distribution se décide à la clôture annuelle, et l'arrêté du "
                            f"{_date_ecran(arrete)} n'est pas un arrêté annuel.")
        if _vide(categorie) is None:
            raise _refus(g, REFUS_CATEGORIE)
        m = _nombre(g, montant, "Montant décidé")
        if m is None:
            raise _refus(g, "Le montant décidé est obligatoire.")
        d = _date_saisie(g, assemblee, "Date de l'assemblée")
        code, libelle = _categorie_decision(connexion, categorie)
        _executer_tout(connexion, "EXEC dbo.pr_ecran_decider_distribution @entite=?, @exercice=?, @categorie=?, "
                                  "@montant=?, @assemblee=?, @par=?", (entite, arrete, code, m, d, g.qui), g)
        texte = (f"Décision enregistrée pour l'exercice clos le {_date_ecran(arrete)} : « {libelle or code} », "
                 f"montant décidé {_montant_ecran(m)}")
        return texte + (f", assemblée du {d.strftime('%d/%m/%Y')}." if d else ".")
    return _rendre(g, "decider_distribution", faire)
