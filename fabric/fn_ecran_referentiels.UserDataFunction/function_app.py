"""fn_ecran_referentiels : les boutons de l'ecran Referentiels (ecran 5), une fonction par bouton.

Lot 4 de la feuille de route 65_JOURNAL/roadmap_ecran_5_referentiels.md ; maquette retenue
20_LIVRABLES_V2/PARCOURS_ECRANS/83_referentiels_option_1.html (objets de fonction n° 182 a 186 et 190 a 193 ;
connexions et bibliotheques, n° 196 et 197). Forme de fn_ecran_arrete (lot 4 de l'ecran 4, repris le 15/10/2026,
commit 798a8ebe) : chaque fonction appelle UNE procedure d'ecran de la base (lot 1 de la feuille de route, scripts
323 et 324), rend la phrase du bouton, prend l'utilisateur dans le contexte d'execution (PreferredUsername) et jamais
dans un parametre, et un refus remonte en francais par UserThrownError. Connexions declarees : « DossierOPCI » (base),
liee ici par l'argument « connexion », et « Coffre » (lakehouse), que lieront les fonctions du lot 5 (exporter et
reimporter un classeur, rattacher un gabarit) ; bibliotheques : fabric-user-data-functions et openpyxl, que le lot 5
emploie.

Les etapes de l'ecran et leurs boutons :
  2a Tenir un referentiel    modifier_valeur         -> pr_ecran_modifier_valeur_referentiel (n° 182, objet n° 11)
                             ajouter_ligne           -> pr_ecran_ajouter_ligne_referentiel   (n° 183, objet n° 12)
                             changer_code            -> pr_ecran_changer_code_referentiel    (n° 184, objet n° 13)
                             ecarter_ligne           -> pr_ecran_ecarter_ligne_referentiel   (n° 185, objet n° 14)
                             supprimer_ligne         -> pr_ecran_supprimer_ligne_referentiel (n° 186, objet n° 15)
  2b Seuil du vehicule       poser_seuil_vehicule    -> pr_ecran_poser_seuil_vehicule        (n° 190, objet n° 24)
  3  Questions a valider     valider_questions       -> pr_ecran_valider_questions           (n° 191, objet n° 32)
                             ecarter_question        -> pr_ecran_ecarter_question            (n° 192, objet n° 33)
                             ajouter_question_tenue  -> pr_ecran_ajouter_question_tenue      (n° 193, objet n° 35)
  2a Classeur et fichier     exporter_referentiel    -> pr_deposer_classeur_referentiel      (n° 187, objet n° 36)
                             importer_referentiel    -> pr_importer_referentiel              (n° 188, objet n° 37)
                             rattacher_gabarit       -> pr_ecran_rattacher_gabarit           (n° 189, objet n° 27)
  3  Niveau de programme     exporter_niveaux        -> pr_deposer_classeur_referentiel      (n° 194, objet n° 36)
                             importer_niveaux        -> pr_importer_niveaux_programme        (n° 195, objet n° 38)
Les 5 fonctions du lot 5 (classeurs et fichier d'un gabarit) sont decrites en tete de leur section, en fin de fichier.

LES PARAMETRES (decision du candidat du 15/10/2026, « Gris + refus en français », § 1.5, n° 2 de la feuille de route).
Chaque parametre, le droit compris, a une valeur par defaut vide : un parametre facultatif dont la mesure est vide
n'est pas envoye par le bouton, et sa valeur par defaut le remplace (GUIDE_API_RAPPORT_POWER_BI.md, § 17.43, point 8) ;
un parametre obligatoire vide desactive le bouton avec une bulle anglaise (meme guide, § 17.25, point 1). Aucun
parametre d'etat : chaque procedure refuse en francais, avant toute ecriture, chaque etat que nomme la mesure
[Blocage ...], [Etat du seuil du vehicule] ou [Etat de la validation] du bouton. Aucun nom de parametre ne porte de
tiret bas : le service le refuse (fn_ecran_revision, deverrouiller_dossier, d'ou demandePar ; 70 fonctions publiees,
aucune n'en porte) ; les champs que la maquette nomme cycle_ou_phase et nouvelle_cle s'appellent donc cycleOuPhase et
nouvelleCle.

LE DROIT EST REFUSE AVANT TOUT APPEL A LA BASE (critere 1 du lot 4 ; lot 10, « 0 message, 0 ligne ») : teneur, lie a
[Teneur connecte] pour les 6 boutons des etapes 2a et 2b, et associe, lie a [Associe du cabinet connecte] pour les
3 boutons de l'etape 3, doivent egaler la personne connectee. Vide ou different, le refus est leve en francais avant
toute connexion a la base, sans journal ni message (_droit, hors de _rendre). Le texte reprend celui que la procedure
oppose a un @par sans droit (50859, 50875), sans le nom du referentiel, que seule la base connait.

L'AUTEUR EST LA PERSONNE CONNECTEE : PreferredUsername de ctx.executing_user, passe en @par a chaque procedure, jamais
un parametre. La session SQL d'une fonction porte le compte a la fois proprietaire de la fonction et auteur de sa
connexion, quel que soit le compte qui clique, et executing_user nomme le compte qui clique (R5, § 6.1 de la feuille de
route ; GUIDE_API_RAPPORT_POWER_BI.md, § 17.59) : seul @par nomme la personne en base, ou chaque procedure le pose dans
le contexte « par » le temps de ses ecritures.

LE LIBELLE D'UN SEGMENT EST TRADUIT EN CODE PAR LA FONCTION, apres le droit : le referentiel par ref_referentiel
(table_nom ou libelle), la colonne par v_ecran_referentiel_colonnes (colonne ou libelle_colonne, dans le referentiel
traduit), le vehicule par ref_entite (code, libelle_vehicule « CODE · nom », ou la partie avant le point median), le
cycle ou la phase par v_ecran_cycle_ou_phase (code ou nom d'usage), la question par v_ecran_question_referentiel
(reference, rendue en identifiant), le sujet par ref_sujet_tenue (code ou libelle). Un libelle qui ne se traduit pas
part tel quel : la procedure, qui recoit aussi le libelle, le refuse en le citant, a son rang. La ligne choisie
([Ligne du referentiel choisie], une mesure) part telle quelle.

LE MESSAGE : chaque procedure pose son message de reussite par dbo.pr_poser_message_ecran dans sa transaction et rend
une ligne (entite, message), sous l'entite « - » pour les actions du cabinet et sous le vehicule pour le seuil (§ 1.3) ;
la fonction pose la phrase rendue de la meme facon apres le commit. Un refus de la procedure est leve sous la
transaction de la fonction, que son rollback annule : la fonction le journalise par dbo.pr_journaliser_refus et le pose
par dbo.pr_poser_message_ecran apres le rollback, dans une connexion neuve (script 323, pr_e5_conclure_refus).

UN TEXTE SAISI plus long que le parametre de la procedure qui le recoit est refuse ici en nommant le champ : la base
tronquerait sans le dire un parametre de procedure trop long (parametres relus en base le 28/10/2026) : « Code de la
nouvelle ligne » et « Nouveau code » 400 caracteres, « Seuil du véhicule » 60, « En vigueur depuis » 40, « Niveau » 20.

UNE ERREUR NON PREVUE REMONTE EN FRANCAIS : seul un refus de la base (numero d'au moins 50000, THROW) devient le texte du
bouton ; toute autre erreur (moteur SQL, pilote, Python) rend le texte francais de l'erreur d'execution, le detail
technique allant au seul journal des refus, sous la forme des textes n° 17 et 19 de R9.
"""

import re

import fabric.functions as fn

udf = fn.UserDataFunctions()


# ----------------------------------------------------------------------------- outils, identiques a fn_ecran_arrete
# Ecarts : _rendre (lot 4) ; lecture des refus (D1) : _enregistrement_sql, _message_sql, _numero_sql, _refus_de_la_base.

def _qui(ctx) -> str:
    u = (ctx.executing_user or {}).get("PreferredUsername") or (ctx.executing_user or {}).get("Oid")
    if not u:
        raise fn.UserThrownError("L'utilisateur connecté n'est pas identifiable ; l'action n'est pas exécutée.", {})
    return u


def _texte_pilote(exc) -> str:
    """Le texte de l'erreur du pilote ODBC : le 2e argument de l'exception pyodbc, (etat SQL, texte), sinon str(exc)."""
    a = getattr(exc, "args", ())
    return a[1] if len(a) > 1 and isinstance(a[1], str) else str(exc)


def _enregistrement_sql(exc) -> tuple:
    """(numero, texte) de l'enregistrement retenu du texte du pilote ODBC. Outil ajoute au lot 5 (decision D1 du
    29/10/2026, condition de la decision D5 du 30/10/2026) : _message_sql, _numero_sql et _refus_de_la_base
    l'emploient, et ne sont donc plus ceux de fn_ecran_arrete. Le pilote ecrit son 1er enregistrement de diagnostic
    « [etat] [...][SQL Server]texte (numero) (fonction) », puis chacun des suivants « ; [etat] [...][SQL Server]texte
    (numero) » ; l'exception pyodbc porte en 1er argument l'etat du 1er enregistrement et en 2e ce texte. Sous un
    appel avec parametres, un avertissement leve avant un THROW y precede le refus (8153 de pr_importer_referentiel,
    etat 01003 ; sonde du 29/10/2026, pyodbc 5.3.0 et ODBC Driver 18 for SQL Server du poste, pilote du service non
    mesure). Les enregistrements ne sont parcourus que si l'exception a cette forme et que l'etat est de classe 01
    (avertissement) : le 1er de numero au moins 50000 est alors retenu s'il n'est pas le 1er du texte, son texte sans
    le prefixe du pilote. Dans tous les autres cas, numero et texte sont ceux de la lecture du lot 4, celle du 1er
    enregistrement, sur le texte entier : numero None quand le texte n'en porte pas (delai ou coupure du pilote, erreur
    Python)."""
    s = _texte_pilote(exc)
    a = getattr(exc, "args", ())
    if len(a) > 1 and isinstance(a[0], str) and isinstance(a[1], str) and a[0].startswith("01"):
        for k, e in enumerate(re.split(r"(?<=\)); (?=\[[0-9A-Z]{5}\] )", s)):
            m = re.search(r"\[SQL Server\](.*)\s\((\d+)\)(?:\s\(SQL\w+\))?\Z", e, re.S)
            if m and int(m.group(2)) >= PREMIER_NUMERO_DE_REFUS:
                if k:
                    return int(m.group(2)), m.group(1).strip()
                break
    n = re.search(r"\[SQL Server\].*?\s\((\d+)\)\s\(SQL\w+\)", s, re.S)
    t = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQL\w+\)|$)", s, re.S)
    return (int(n.group(1)) if n else None), (t.group(1) if t else s).strip()


def _message_sql(exc) -> str:
    """Le texte de l'enregistrement retenu (_enregistrement_sql), sans le prefixe du pilote."""
    return _enregistrement_sql(exc)[1]


# THROW n'admet que des numeros d'au moins 50000 (en-tete, refus de la base et erreur du moteur).
PREMIER_NUMERO_DE_REFUS = 50000


def _numero_sql(exc):
    """Le numero d'erreur de SQL Server de l'enregistrement retenu (_enregistrement_sql), ou None quand le texte n'en
    porte pas (delai ou coupure du pilote, erreur Python)."""
    return _enregistrement_sql(exc)[0]


def _refus_de_la_base(exc):
    """Le texte francais d'un refus de la base (numero d'au moins 50000, lu sur l'enregistrement retenu), ou None pour
    toute autre erreur."""
    n, texte = _enregistrement_sql(exc)
    return texte if n is not None and n >= PREMIER_NUMERO_DE_REFUS else None


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
        # message, le detail au journal seul, sous la forme des textes n° 17 et 19 de R9 (fn_ecran_revision).
        procedure = g.procedures[-1] if g.procedures else nom
        detail = ("Erreur d’exécution de la fonction %s, procédure %s : %s" % (nom, procedure, _detail(e))
                  if g.procedures else "Erreur d’exécution de la fonction %s : %s" % (nom, _detail(e)))
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


def _texte_saisi(g: _Action, valeur, libelle: str, maximum: int):
    """Un texte saisi, ou None quand le champ est vide ; au-dela de maximum caracteres, refus qui nomme le champ."""
    t = _vide(valeur)
    if t is not None and len(t) > maximum:
        raise _refus(g, f"« {libelle} » : {maximum} caractères au plus ; le texte saisi en compte {len(t)}.")
    return t


# ----------------------------------------------------------------------------- outils propres a l'ecran 5

# L'entite du message d'une action du cabinet (§ 1.3 de la feuille de route) : [Message ecran] lit les messages de la
# personne dont l'entite vaut le client choisi ou « - ».
ENTITE_CABINET = "-"


def _droit(g: _Action, valeur, texte: str) -> None:
    """Le droit d'un bouton : la mesure liee au parametre ([Teneur connecte] ou [Associe du cabinet connecte]) rend
    l'adresse de connexion de la personne connectee quand elle tient le droit. Toute autre valeur, vide comprise, est
    refusee en francais AVANT TOUT APPEL A LA BASE : appele hors de _rendre, ce refus ne pose ni journal ni message
    (critere 1 du lot 4)."""
    v = _vide(valeur)
    if v is None or v.lower() != g.qui.strip().lower():
        raise fn.UserThrownError(texte, {})


# Les refus du droit, au texte de la procedure pour un @par sans droit (50859 aux n° 11 a 15 et 24, sans le nom du
# referentiel ; 50875 aux n° 32, 33 et 35, mot pour mot), relus en base le 28/10/2026.
REFUS_DROIT_MODIFIER = "Modification refusée : aucun droit de modification."
REFUS_DROIT_AJOUTER = "Ajout refusé : aucun droit de modification."
REFUS_DROIT_CHANGER = "Changement de code refusé : aucun droit de modification."
REFUS_DROIT_ECARTER = "Écart refusé : aucun droit de modification."
REFUS_DROIT_SUPPRIMER = "Suppression refusée : aucun droit de modification."
REFUS_DROIT_SEUIL = "Seuil refusé : aucun droit de modification."
REFUS_ASSOCIE_VALIDER = ("Validation refusée : réservé à l’associé. Seul l’associé valide une question de référence, "
                         "et votre adresse de connexion ne porte aucun mandat d’associé en cours.")
REFUS_ASSOCIE_ECARTER = ("Écart refusé : seul l’associé écarte une question de référence, et votre adresse de "
                         "connexion ne porte aucun mandat d’associé en cours.")
REFUS_ASSOCIE_AJOUTER = ("Ajout refusé : seul l’associé ajoute une question sur la tenue de la comptabilité, et votre "
                         "adresse de connexion ne porte aucun mandat d’associé en cours.")


def _table_referentiel(connexion, valeur):
    """La table du referentiel choisi au segment « Référentiel » (libelle de ref_referentiel), ou le texte recu tel quel
    quand il ne se traduit pas : la procedure le refuse alors en le citant (50831, pr_e5_lire_referentiel, meme
    recherche)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) table_nom FROM dbo.ref_referentiel WHERE table_nom = ? OR libelle = ? "
                         "ORDER BY CASE WHEN table_nom = ? THEN 0 ELSE 1 END", (t, t, t))
    return l[0]["table_nom"] if l and l[0].get("table_nom") else t


def _nom_colonne(connexion, table, valeur):
    """Le nom de la colonne choisie au segment « Colonne » (libelle_colonne de v_ecran_referentiel_colonnes) dans le
    referentiel traduit, ou le texte recu tel quel : la procedure le cherche encore dans la table et dans
    ref_libelle_colonne, puis le refuse en le citant (50845)."""
    t = _vide(valeur)
    if t is None or table is None:
        return t
    l = _lire(connexion, "SELECT TOP (1) colonne FROM dbo.v_ecran_referentiel_colonnes WHERE referentiel = ? "
                         "AND (colonne = ? OR libelle_colonne = ?) ORDER BY CASE WHEN colonne = ? THEN 0 ELSE 1 END "
                         "OPTION (RECOMPILE)", (table, t, t, t))
    return l[0]["colonne"] if l and l[0].get("colonne") else t


def _code_vehicule(connexion, valeur):
    """Le code du vehicule choisi au selecteur « Véhicule » (ref_entite.libelle_vehicule, « CODE · nom »), ou None quand
    il ne se traduit pas ; meme recherche que pr_ecran_poser_seuil_vehicule : le code, le libelle du vehicule, puis la
    partie qui precede le point median."""
    t = _vide(valeur)
    if t is None:
        return None
    avant = t.split("·", 1)[0].strip() if "·" in t[1:] else None
    l = _lire(connexion, "SELECT TOP (1) code FROM dbo.ref_entite WHERE code = ? OR libelle_vehicule = ? OR code = ? "
                         "ORDER BY CASE WHEN code = ? THEN 0 WHEN libelle_vehicule = ? THEN 1 ELSE 2 END",
              (t, t, avant, t, t))
    return l[0]["code"] if l and l[0].get("code") else None


def _code_cycle_ou_phase(connexion, valeur):
    """Le code du cycle ou de la phase choisi au segment « Cycle ou phase » (nom_usage de v_ecran_cycle_ou_phase), ou
    le texte recu tel quel : la procedure le refuse alors en le citant (50872)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) code FROM dbo.v_ecran_cycle_ou_phase WHERE code = ? OR nom_usage = ? "
                         "ORDER BY CASE WHEN code = ? THEN 0 ELSE 1 END, ordre", (t, t, t))
    return l[0]["code"] if l and l[0].get("code") else t


def _identifiant_question(connexion, valeur):
    """L'identifiant de la question choisie au segment « Question » (reference de v_ecran_question_referentiel), ou le
    texte recu tel quel : pr_ecran_ecarter_question recoit la reference ou l'identifiant, et refuse une question
    inconnue en la citant (50877)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) question_id FROM dbo.v_ecran_question_referentiel WHERE reference = ?", (t,))
    return str(l[0]["question_id"]) if l and l[0].get("question_id") is not None else t


def _code_sujet(connexion, valeur):
    """Le code du sujet choisi au segment « Sujet » (libelle de ref_sujet_tenue), ou le texte recu tel quel : la
    procedure le refuse alors en le citant (50882)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) code FROM dbo.ref_sujet_tenue WHERE code = ? OR libelle = ? "
                         "ORDER BY CASE WHEN code = ? THEN 0 ELSE 1 END", (t, t, t))
    return l[0]["code"] if l and l[0].get("code") else t


# ----------------------------------------------------------------------------- 2a, tenir un referentiel

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def modifier_valeur(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                    referentiel: str = "", cle: str = "", colonne: str = "", valeur: str = "") -> str:
    """Bouton « Modifier la valeur » : la valeur saisie au champ « Nouvelle valeur » dans la colonne choisie de la
    ligne choisie du referentiel choisi. La fonction refuse d'abord un droit vide ou different de la personne connectee
    (_droit, avant tout appel a la base), puis traduit le referentiel et la colonne.
    pr_ecran_modifier_valeur_referentiel refuse ensuite, dans son ordre : referentiel vide ou inconnu (50831), fixe par
    un texte (50832), seuil propre au vehicule (50833), aucun droit de modification (50859), ligne vide ou inconnue
    (50839, 50842), adresse d'installation (50847), colonne vide ou inconnue (50845), colonne calculee ou non
    modifiable (50846), colonne d'un parametre autre que la valeur (50834), valeur refusee (50848 a 50850, 50852),
    designation deja prise (50854)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_MODIFIER)

    def faire():
        t = _table_referentiel(connexion, referentiel)
        c = _nom_colonne(connexion, t, colonne)
        r = _executer(connexion, "EXEC dbo.pr_ecran_modifier_valeur_referentiel @referentiel=?, @cle=?, @colonne=?, "
                                 "@valeur=?, @par=?", (t, _vide(cle), c, _vide(valeur), g.qui), g)
        return r.get("message") or "Valeur modifiée."
    return _rendre(g, "modifier_valeur", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def ajouter_ligne(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                  referentiel: str = "", modele: str = "", cle: str = "", libelle: str = "") -> str:
    """Bouton « Ajouter la ligne » : une ligne neuve, copie de la ligne choisie (modele), au code saisi au champ
    « Code de la nouvelle ligne » et au libelle saisi au champ « Libellé ». La fonction refuse d'abord le droit (_droit,
    avant tout appel a la base), puis un code de plus de 400 caracteres, et traduit le referentiel.
    pr_ecran_ajouter_ligne_referentiel refuse ensuite, dans son ordre : referentiel (50831), fixe par un texte (50832),
    seuil propre (50833), aucun droit (50859), actions de ligne fermees (50834, 50835, 50837), ligne a copier vide ou
    inconnue (50839, 50842), code numerote, mal forme ou deja pris (50838, 50840, 50841, 50843), libelle absent ou
    trop long (50853), valeur deja portee par une autre ligne (50854), article absent du referentiel des articles
    (50850)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_AJOUTER)

    def faire():
        k = _texte_saisi(g, cle, "Code de la nouvelle ligne", 400)
        t = _table_referentiel(connexion, referentiel)
        r = _executer(connexion, "EXEC dbo.pr_ecran_ajouter_ligne_referentiel @referentiel=?, @modele=?, @cle=?, "
                                 "@libelle=?, @par=?", (t, _vide(modele), k, _vide(libelle), g.qui), g)
        return r.get("message") or "Ligne ajoutée."
    return _rendre(g, "ajouter_ligne", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def changer_code(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                 referentiel: str = "", cle: str = "", nouvelleCle: str = "") -> str:
    """Bouton « Changer le code » : le code de la ligne choisie devient celui saisi au champ « Nouveau code »
    (D9 de l'existant, forme 2). La fonction refuse d'abord le droit (_droit, avant tout appel a la base), puis un code
    de plus de 400 caracteres, et traduit le referentiel. pr_ecran_changer_code_referentiel refuse ensuite, dans son
    ordre : referentiel (50831), fixe par un texte (50832), seuil propre (50833), aucun droit (50859), actions de ligne
    fermees (50834, 50836), ligne numerotee (50838), ligne vide ou inconnue (50839, 50842), code mal forme (50840,
    50841), ligne employee, en nommant l'emploi (50844), nouveau code vide ou inchange (50858), code deja pris (50843),
    designation deja prise (50854)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_CHANGER)

    def faire():
        n = _texte_saisi(g, nouvelleCle, "Nouveau code", 400)
        t = _table_referentiel(connexion, referentiel)
        r = _executer(connexion, "EXEC dbo.pr_ecran_changer_code_referentiel @referentiel=?, @cle=?, @nouvelle_cle=?, "
                                 "@par=?", (t, _vide(cle), n, g.qui), g)
        return r.get("message") or "Code changé."
    return _rendre(g, "changer_code", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def ecarter_ligne(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                  referentiel: str = "", cle: str = "", motif: str = "") -> str:
    """Bouton « Écarter la ligne » : la ligne choisie, mise hors d'usage sans etre supprimee, avec le motif saisi au
    champ « Motif » (facultatif). La fonction refuse d'abord le droit (_droit, avant tout appel a la base), puis
    traduit le referentiel. pr_ecran_ecarter_ligne_referentiel refuse ensuite, dans son ordre : referentiel (50831),
    fixe par un texte (50832), seuil propre (50833), aucun droit (50859), actions de ligne fermees (50834),
    referentiel sans colonnes d'ecart (50855), ligne vide ou inconnue (50839, 50842), ligne deja ecartee, avec la date
    de son ecart (50857), motif de plus de 600 caracteres (50856)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_ECARTER)

    def faire():
        t = _table_referentiel(connexion, referentiel)
        r = _executer(connexion, "EXEC dbo.pr_ecran_ecarter_ligne_referentiel @referentiel=?, @cle=?, @motif=?, @par=?",
                      (t, _vide(cle), _vide(motif), g.qui), g)
        return r.get("message") or "Ligne écartée."
    return _rendre(g, "ecarter_ligne", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def supprimer_ligne(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                    referentiel: str = "", cle: str = "") -> str:
    """Bouton « Supprimer la ligne » : la ligne choisie, supprimee si aucune ligne ne l'emploie. La fonction refuse
    d'abord le droit (_droit, avant tout appel a la base), puis traduit le referentiel.
    pr_ecran_supprimer_ligne_referentiel refuse ensuite, dans son ordre : referentiel (50831), fixe par un texte
    (50832), seuil propre (50833), aucun droit (50859), actions de ligne fermees (50834), ligne vide ou inconnue
    (50839, 50842), ligne employee, en nommant l'emploi et ce qui la met hors d'usage (50844)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_SUPPRIMER)

    def faire():
        t = _table_referentiel(connexion, referentiel)
        r = _executer(connexion, "EXEC dbo.pr_ecran_supprimer_ligne_referentiel @referentiel=?, @cle=?, @par=?",
                      (t, _vide(cle), g.qui), g)
        return r.get("message") or "Ligne supprimée."
    return _rendre(g, "supprimer_ligne", faire)


# ----------------------------------------------------------------------------- 2b, le seuil propre d'un vehicule

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def poser_seuil_vehicule(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, teneur: str = "",
                         entite: str = "", code: str = "", seuil: str = "", depuis: str = "", motif: str = "") -> str:
    """Bouton « Enregistrer le seuil du véhicule » : le seuil propre du vehicule choisi au selecteur « Véhicule » pour
    la limite choisie ([Ligne du referentiel choisie]), avec les champs « Seuil du véhicule », « En vigueur depuis » et
    « Motif ». La fonction refuse d'abord le droit (_droit, avant tout appel a la base), puis un seuil de plus de
    60 caracteres et une date de plus de 40, et traduit le vehicule en son code, qui est aussi l'entite du message
    (« - » quand il ne se traduit pas). pr_ecran_poser_seuil_vehicule refuse ensuite, dans son ordre : vehicule vide ou
    qui n'est pas un OPCI (50860), limite vide ou inconnue (50861), valeur fixee par le texte (50862), aucun droit
    (50859), forme du vehicule (50863), seuil vide, illisible ou hors de l'unite (50864, 50865), date vide ou illisible
    (50866), motif de plus de 600 caracteres (50867) ; la garde tr_ref_ratio_vehicule_garde les rejoue en base."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_SEUIL)

    def faire():
        s = _texte_saisi(g, seuil, "Seuil du véhicule", 60)
        d = _texte_saisi(g, depuis, "En vigueur depuis", 40)
        e = _code_vehicule(connexion, entite)
        g.entite = e or ENTITE_CABINET
        r = _executer(connexion, "EXEC dbo.pr_ecran_poser_seuil_vehicule @entite=?, @code=?, @seuil=?, @depuis=?, "
                                 "@motif=?, @par=?", (e or _vide(entite), _vide(code), s, d, _vide(motif), g.qui), g)
        return r.get("message") or "Seuil du véhicule enregistré."
    return _rendre(g, "poser_seuil_vehicule", faire)


# ----------------------------------------------------------------------------- 3, les questions a valider

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def valider_questions(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, associe: str = "",
                      cycleOuPhase: str = "") -> str:
    """Bouton « Valider les questions du cycle » : les questions « à valider » du cycle ou de la phase choisi passent a
    « validée ». La fonction refuse d'abord un associe vide ou different de la personne connectee (_droit, avant tout
    appel a la base, texte de 50875), puis traduit le cycle ou la phase. pr_ecran_valider_questions refuse ensuite,
    dans son ordre : cycle ou phase vide (50871), code commun a un cycle et a une phase (50887), inconnu (50872), aucune
    question a valider (50874), aucun mandat d'associe en cours (50875)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, associe, REFUS_ASSOCIE_VALIDER)

    def faire():
        c = _code_cycle_ou_phase(connexion, cycleOuPhase)
        r = _executer(connexion, "EXEC dbo.pr_ecran_valider_questions @cycle_ou_phase=?, @par=?", (c, g.qui), g)
        return r.get("message") or "Questions validées."
    return _rendre(g, "valider_questions", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def ecarter_question(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, associe: str = "",
                     question: str = "", motif: str = "") -> str:
    """Bouton « Écarter la question » : la question choisie au segment « Question » passe a « écartée », avec le motif
    saisi (facultatif). La fonction refuse d'abord l'associe (_droit, avant tout appel a la base, texte de 50875), puis
    traduit la reference en identifiant. pr_ecran_ecarter_question refuse ensuite, dans son ordre : aucun mandat
    d'associe en cours (50875), question vide ou inconnue (50876, 50877), question deja ecartee (50878), motif de plus
    de 600 caracteres (50880)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, associe, REFUS_ASSOCIE_ECARTER)

    def faire():
        q = _identifiant_question(connexion, question)
        r = _executer(connexion, "EXEC dbo.pr_ecran_ecarter_question @question=?, @motif=?, @par=?",
                      (q, _vide(motif), g.qui), g)
        return r.get("message") or "Question écartée."
    return _rendre(g, "ecarter_question", faire)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def ajouter_question_tenue(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, associe: str = "",
                           cycleOuPhase: str = "", sujet: str = "", niveau: str = "", enonce: str = "") -> str:
    """Bouton « Ajouter la question » : une question sur la tenue de la comptabilite, de niveau 2 ou 3, sur le sujet
    choisi, dans le cycle ou la phase choisi, au statut « à valider ». La fonction refuse d'abord l'associe (_droit,
    avant tout appel a la base, texte de 50875), puis un niveau de plus de 20 caracteres, et traduit le cycle ou la
    phase et le sujet. pr_ecran_ajouter_question_tenue refuse ensuite, dans son ordre : aucun mandat d'associe en cours
    (50875), cycle ou phase vide, commun, inconnu ou ecarte (50871, 50887, 50872, 50873), sujet vide ou inconnu (50881,
    50882), niveau vide ou autre que 2 ou 3 (50883, 50884), enonce vide ou de plus de 400 caracteres (50885, 50886)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, associe, REFUS_ASSOCIE_AJOUTER)

    def faire():
        n = _texte_saisi(g, niveau, "Niveau", 20)
        c = _code_cycle_ou_phase(connexion, cycleOuPhase)
        s = _code_sujet(connexion, sujet)
        r = _executer(connexion, "EXEC dbo.pr_ecran_ajouter_question_tenue @cycle_ou_phase=?, @sujet=?, @niveau=?, "
                                 "@enonce=?, @par=?", (c, s, n, _vide(enonce), g.qui), g)
        return r.get("message") or "Question ajoutée."
    return _rendre(g, "ajouter_question_tenue", faire)


# ----------------------------------------------------------------------------- lot 5, les classeurs et le fichier d'un gabarit
#
# Lot 5 de 65_JOURNAL/roadmap_ecran_5_referentiels.md : fonctions n° 187, 188, 189, 194 et 195 de la maquette retenue
# 20_LIVRABLES_V2/PARCOURS_ECRANS/83_referentiels_option_1.html, sur le contrat de la session base
# (65_JOURNAL/preuves_ecran_5/plan_lot5_base_20261025.md, § 2, et ses decisions D-t a D-x,
# 65_JOURNAL/preuves_ecran_5/decisions_session_base_lot1_20261021.md) et les procedures posees le 25/10/2026
# (63_SQL/331 a 334, vue 335) : pr_deposer_classeur_referentiel (objet n° 36), pr_importer_referentiel (n° 37),
# pr_importer_niveaux_programme (n° 38), pr_ecran_rattacher_gabarit (n° 27), v_export_niveaux_programme (D-v).
#
# TOUT FICHIER SE DEPOSE DANS SHAREPOINT ET SE LIT PAR LE RACCOURCI DU COFFRE (D21 de l'existant, regle du 28/09/2026) :
# un classeur exporte part au dossier « Référentiels » du site du cabinet par la base, pr_deposer_classeur_referentiel
# (route deposer_classeur, voie de pr_deposer_classeur : une Data function n'a pas d'identite a elle), qui l'inscrit
# dans classeur_cabinet ; le reimport relit le dernier classeur inscrit par son chemin_onelake (« fec/Référentiels/... ») ;
# le fichier d'un gabarit se lit a « <RACCOURCI_SITE_CABINET>/Modeles/<fichier> ». Rien ne s'ecrit au coffre.
#
# LE DROIT AVANT TOUT APPEL A LA BASE (critere 1 du lot 4) : importer_referentiel et rattacher_gabarit (teneur, lie a
# [Teneur connecte]) et importer_niveaux (associe, lie a [Associe du cabinet connecte]) refusent en francais un droit
# absent, vide ou d'une autre personne, sans connexion a la base ni lecture au coffre (_droit). Les 2 exports n'ont ni
# droit ni etat (objets n° 187 et 194) : l'export ne modifie pas le referentiel, et un referentiel fixe par un texte
# s'exporte aussi.
#
# LE 1ER APPEL DES 3 RELECTURES (plan du lot 5, § 2.2 a 2.4) : la procedure est d'abord appelee sans son contenu (sans
# @lignes ni @fichier, ou sans @empreinte), pour que ses refus suivent l'ordre de la mesure [Blocage ...] du bouton ; elle
# refuse alors en 50910 (classeurs) ou 50927 (gabarit) quand tout le reste est admis : ce numero, et lui seul, dit a la
# fonction de poursuivre (_premier_appel), sans journal ni message, son rollback effacant ce que la procedure a ecrit ;
# tout autre refus s'affiche tel quel. La fonction lit ensuite le fichier par le raccourci, puis rappelle la procedure
# avec le contenu ; un fichier absent est refuse par la fonction, sans 2e appel. Le numero et le texte d'un refus se
# lisent sur l'enregistrement retenu du texte du pilote (_enregistrement_sql, decision D1 du 29/10/2026) :
# pr_importer_referentiel leve l'avertissement 8153 avant son refus 50910 (63_SQL/332, lignes 238 et 239 du script), et
# le pilote place cet avertissement en 1er enregistrement sous un appel avec parametres (sonde du 29/10/2026).
#
# UN DEPOT REFUSE PAR LA ROUTE (50905, decision D-x du 25/10/2026) : la procedure pose le detail de la route dans la cle
# detail_route du contexte de session, qui survit au rollback ; la fonction la relit sur la meme connexion apres son
# rollback, la passe en detail de son journal (_rendre_depot, puis _poser), et la remet a vide ; l'ecran garde le texte
# francais de la procedure.

# Les numeros de refus de la base que les fonctions du lot 5 lisent (63_SQL/331 a 334, relus en base le 29/10/2026)
REFUS_DEPOT_DE_LA_ROUTE = 50905     # pr_deposer_classeur_referentiel : depot refuse par la route, detail en contexte
CONTENU_NON_PARVENU = 50910         # pr_importer_referentiel et pr_importer_niveaux_programme : tout le reste admis
EMPREINTE_MANQUANTE = 50927         # pr_ecran_rattacher_gabarit : tout le reste admis

# Les refus du droit, au texte de la procedure pour un @par sans droit (50908 des n° 37 et 27, sans le nom du
# referentiel ; 50908 du n° 38, mot pour mot), relus en base le 29/10/2026.
REFUS_DROIT_REIMPORTER = "Réimport refusé : aucun droit de modification."
REFUS_DROIT_RATTACHER = "Rattachement refusé : aucun droit de modification."
REFUS_ASSOCIE_NIVEAUX = ("Réimport refusé : réservé à l’associé. Seul l’associé pose les niveaux de programme, et votre "
                         "adresse de connexion ne porte aucun mandat d’associé en cours.")

# Le classeur des niveaux de programme : la forme de 61_DEPLOIEMENT/exporter_niveaux_a_cocher.py (28/09/2026), onglet
# « Questions », libelles en ligne 1, cles en ligne 2, donnees a partir de la ligne 3, puis l'onglet « Racines par
# cycle » ; les lignes et les croix sont celles de la vue v_export_niveaux_programme (decision D-v), dont les
# 13 premieres colonnes sont ces cles, dans cet ordre.
COLONNES_NIVEAUX = [("Cycle", "cycle", 10), ("Libellé du cycle", "cycle_libelle", 30), ("Référence", "reference", 13),
                    ("Question", "enonce", 70), ("Applicabilité", "applicabilite", 16),
                    ("Type de réponse", "type_reponse", 14), ("Feuille type", "feuille_type", 14),
                    ("Racines du cycle", "racines_cycle", 26), ("Racines directes", "racines_directes", 16),
                    ("Allégé", "allege", 9), ("Classique", "classique", 10), ("Étendu", "etendu", 9),
                    ("Motif de la proposition", "motif", 44)]
ONGLET_NIVEAUX = "Questions"
FICHIER_NIVEAUX = "niveaux_de_programme.xlsx"
ENTETE_CLASSEUR = "1D1A10"
CASE_A_COCHER = "FFF8E7"


def _absent(exc) -> bool:
    """Vrai quand le client de fichiers dit le fichier absent : statut 404 (ResourceNotFoundError), ou code NotFound,
    PathNotFound ou BlobNotFound dans son texte (forme de _absent de fn_ecran_revision, relevee le 23/10/2026)."""
    if getattr(exc, "status_code", None) == 404 or exc.__class__.__name__ == "ResourceNotFoundError":
        return True
    return re.search(r"\b(NotFound|PathNotFound|BlobNotFound)\b", str(exc)) is not None


def _compte(n: int, singulier: str, pluriel: str) -> str:
    """Le nombre et son nom accorde, sans « (s) » : le singulier pour 0 et 1 (forme de _compte de fn_ecran_revision)."""
    return "%d %s" % (n, singulier if n <= 1 else pluriel)


def _lignes_de(ws) -> list:
    """Les lignes d'un onglet, cle par cle (les noms de la ligne 2, en texte), et le numero de la ligne dans l'onglet
    sous « _ligne », que la base cite dans ses refus ; une ligne vide s'ignore (forme de _lignes_de de
    fn_ecran_revision)."""
    cles = [c.value for c in ws[2]]
    out = []
    for n, r in enumerate(ws.iter_rows(min_row=3, values_only=True), 3):
        if all(v is None or str(v).strip() == "" for v in r):
            continue
        d = {str(k): v for k, v in zip(cles, r) if k is not None and str(k).strip() != ""}
        d["_ligne"] = n
        out.append(d)
    return out


def _lire_au_coffre(coffre, chemin: str) -> bytes:
    """Les octets d'un fichier du site du cabinet, lus par le raccourci du coffre (chemin relatif a Files, forme de
    importer_classeur de fn_ecran_revision et de inscrire_piece de fn_ecran_client)."""
    return coffre.connectToFiles().get_file_client(chemin).download_file().readall()


def _premier_appel(connexion: fn.FabricSqlConnection, sql: str, params: tuple, g: _Action, poursuite: int) -> None:
    """Le 1er appel d'une procedure de relecture, sans son contenu (plan du lot 5, § 2.2 a 2.4) : ses refus suivent
    l'ordre de la mesure [Blocage ...] du bouton. Le refus au numero poursuite (50910 ou 50927), et lui seul, dit que tout
    le reste est admis : la fonction poursuit, sans journal ni message. Le numero est celui de l'enregistrement
    retenu du texte du pilote (_numero_sql) : un avertissement leve avant le refus ne le masque pas. Tout autre refus
    de la base est leve a son texte, comme par _executer_tout ; une erreur non prevue est relevee telle quelle, et
    _rendre la rend en francais. Ce 1er appel ne garde aucune ecriture : rollback dans tous les cas."""
    g.procedures.append(_nom_procedure(sql))
    g.refus = None
    conn = connexion.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        while True:
            if cur.description:
                cur.fetchall()
            if not cur.nextset():
                break
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        if _numero_sql(e) == poursuite:
            return
        message = _refus_de_la_base(e)
        if message is None:
            raise
        g.refus = message
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    else:
        try:
            conn.rollback()
        except Exception:
            pass
    finally:
        try:
            conn.close()
        except Exception:
            pass


def _detail_route(conn):
    """Le detail d'un depot refuse par la route, lu dans la cle detail_route du contexte de session de la connexion qui a
    appele la procedure (decision D-x : la valeur survit au rollback), puis la cle remise a vide. None quand la lecture
    echoue ou que la cle est vide ; ne leve jamais."""
    detail = None
    try:
        cur = conn.cursor()
        cur.execute("SELECT CAST(SESSION_CONTEXT(N'detail_route') AS NVARCHAR (4000)) AS detail", ())
        lignes = cur.fetchall()
        cur.close()
        detail = lignes[0][0] if lignes else None
    except Exception:
        detail = None
    try:
        cur = conn.cursor()
        cur.execute("EXEC sp_set_session_context N'detail_route', NULL", ())
        cur.close()
        conn.rollback()
    except Exception:
        pass
    return _vide(detail)


def _deposer_classeur(connexion: fn.FabricSqlConnection, g: _Action, genre: str, referentiel, fichier, wb) -> dict:
    """Depose le classeur au dossier « Référentiels » du site du cabinet par pr_deposer_classeur_referentiel (objet
    n° 36), qui l'inscrit dans classeur_cabinet et rend classeur_id, web_url, chemin_onelake, empreinte_sha256 et
    message. wb vaut None quand le referentiel ne se traduit pas : la procedure le refuse alors a son rang, en le citant
    (50831). Sur un depot refuse par la route (50905, decision D-x), le detail est relu sur la meme connexion apres le
    rollback, retenu pour le journal (g.detail), puis la cle detail_route est remise a vide."""
    import base64
    import io
    contenu = None
    if wb is not None:
        tampon = io.BytesIO()
        wb.save(tampon)
        contenu = base64.b64encode(tampon.getvalue()).decode("ascii")
    sql = "EXEC dbo.pr_deposer_classeur_referentiel @genre=?, @referentiel=?, @fichier=?, @contenu_base64=?, @par=?"
    g.procedures.append(_nom_procedure(sql))
    g.refus = None
    conn = connexion.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, (genre, referentiel, fichier, contenu, g.qui))
        lignes = []
        while True:
            if cur.description:
                colonnes = [d[0] for d in cur.description]
                lignes.extend(dict(zip(colonnes, l)) for l in cur.fetchall())
            if not cur.nextset():
                break
        conn.commit()
        portant = [l for l in lignes if "message" in l]
        return (portant or lignes or [{}])[-1]
    except Exception as e:
        try:
            conn.rollback()
        except Exception:
            pass
        message = _refus_de_la_base(e)
        if message is None:
            raise
        if _numero_sql(e) == REFUS_DEPOT_DE_LA_ROUTE:
            g.detail = _detail_route(conn)
        g.refus = message
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        try:
            conn.close()
        except Exception:
            pass


def _rendre_depot(g: _Action, nom: str, faire):
    """_rendre pour les 2 exports : sur un refus, le detail de la route (g.detail, depot refuse par la route, 50905) va
    au journal des refus a la place du texte, qui reste celui de l'ecran (decision D-x) ; tout le reste comme _rendre."""
    try:
        texte = faire()
    except fn.UserThrownError as e:
        _poser(g, g.refus or _texte(e), "REFUS", (g.procedures[-1] if g.procedures else nom), journal=True,
               detail=getattr(g, "detail", None))
        raise
    except Exception as e:
        procedure = g.procedures[-1] if g.procedures else nom
        detail = ("Erreur d’exécution de la fonction %s, procédure %s : %s" % (nom, procedure, _detail(e))
                  if g.procedures else "Erreur d’exécution de la fonction %s : %s" % (nom, _detail(e)))
        _poser(g, TEXTE_ERREUR, "REFUS", procedure, journal=True, detail=detail)
        raise fn.UserThrownError(TEXTE_ERREUR, {"fonction": nom}) from e
    _poser(g, texte, "SUCCES", (g.procedures[0] if g.procedures else nom))
    return texte


def _referentiel_du_cabinet(connexion, valeur):
    """(table, libelle) du referentiel choisi au segment « Référentiel » (table_nom ou libelle de ref_referentiel, meme
    recherche que pr_e5_lire_referentiel) quand c'est un referentiel du cabinet dont la table existe ; sinon None, et
    pr_deposer_classeur_referentiel le refuse a son rang, en le citant (50831)."""
    t = _vide(valeur)
    if t is None:
        return None
    l = _lire(connexion, "SELECT TOP (1) r.table_nom, r.libelle, r.du_cabinet, CASE WHEN OBJECT_ID(N'dbo.' + "
                         "QUOTENAME(r.table_nom), N'U') IS NULL THEN 0 ELSE 1 END AS presente FROM dbo.ref_referentiel r "
                         "WHERE r.table_nom = ? OR r.libelle = ? ORDER BY CASE WHEN r.table_nom = ? THEN 0 ELSE 1 END",
              (t, t, t))
    if not l or not l[0].get("table_nom") or not l[0].get("du_cabinet") or not l[0].get("presente"):
        return None
    return l[0]["table_nom"], (l[0].get("libelle") or l[0]["table_nom"])


def _nom_sql(nom) -> str:
    """Un nom de table ou de colonne lu au catalogue, entre crochets (QUOTENAME)."""
    return "[" + str(nom).replace("]", "]]") + "]"


def _colonnes_du_classeur(connexion, table: str) -> tuple:
    """Les colonnes du classeur d'un referentiel (plan du lot 5, § 2.1), ([(colonne, libelle)], nombre de colonnes du
    code) : les colonnes du code (cle primaire, identifiant compris pour un referentiel numerote), dans l'ordre de la
    cle, au libelle de fn_e5_libelle_colonne ; puis les colonnes de la table que nomment la liste
    (v_ecran_referentiel_valeurs) ou le segment « Colonne » (v_ecran_referentiel_colonnes), dans l'ordre de leur rang, a
    leur libelle a l'ecran. « Employée par » n'est pas une colonne de la table et n'y entre pas, ni une colonne
    calculee."""
    table_cols = _lire(connexion,
                       "SELECT c.name AS colonne, c.column_id, c.is_computed, dbo.fn_e5_libelle_colonne(?, c.name) AS "
                       "libelle, (SELECT ic.key_ordinal FROM sys.indexes i JOIN sys.index_columns ic ON ic.object_id = "
                       "i.object_id AND ic.index_id = i.index_id WHERE i.object_id = c.object_id AND i.is_primary_key = 1 "
                       "AND ic.column_id = c.column_id) AS rang_cle FROM sys.columns c WHERE c.object_id = "
                       "OBJECT_ID(N'dbo.' + QUOTENAME(?), N'U') ORDER BY c.column_id", (table, table))
    liste = _lire(connexion,
                  "SELECT x.colonne, MIN(x.libelle_colonne) AS libelle_colonne, MIN(x.rang_libelle) AS rang_libelle "
                  "FROM (SELECT colonne, libelle_colonne, rang_libelle FROM dbo.v_ecran_referentiel_colonnes WHERE "
                  "referentiel = ? UNION ALL SELECT colonne, libelle_colonne, rang_libelle FROM "
                  "dbo.v_ecran_referentiel_valeurs WHERE referentiel = ?) x GROUP BY x.colonne OPTION (RECOMPILE)",
                  (table, table))
    par_nom = {c["colonne"]: c for c in table_cols if not c.get("is_computed")}
    cles = sorted((c for c in par_nom.values() if c.get("rang_cle") is not None), key=lambda c: c["rang_cle"])
    out = [(c["colonne"], c.get("libelle") or c["colonne"]) for c in cles]
    vus = {c["colonne"] for c in cles}
    for v in sorted(liste, key=lambda v: (v["rang_libelle"] if v.get("rang_libelle") is not None else 1000000,
                                          str(v["colonne"]))):
        nom = v.get("colonne")
        if nom in par_nom and nom not in vus:
            out.append((nom, v.get("libelle_colonne") or par_nom[nom].get("libelle") or nom))
            vus.add(nom)
    return out, len(cles)


def _valeur_de_cellule(v):
    """Une valeur de la base sous une forme que le classeur garde : texte, nombre, booleen, date ; toute autre forme
    (date avec fuseau, identifiant, octets) passe en texte."""
    import datetime
    import decimal
    if v is None or isinstance(v, (str, bool, int, float, decimal.Decimal, datetime.date, datetime.time)):
        if isinstance(v, (datetime.datetime, datetime.time)) and v.tzinfo is not None:
            return str(v)
        return v
    return str(v)


def _ecrire_cellule(ws, ligne: int, colonne: int, valeur):
    """Ecrit une valeur ; un texte qu'Excel lirait comme une formule ou une erreur (« = », « #N/A ») reste un texte :
    sans quoi le classeur relu le rendrait vide (ref_ligne_annexe.signe porte « = », relu le 29/10/2026)."""
    c = ws.cell(row=ligne, column=colonne, value=_valeur_de_cellule(valeur))
    if isinstance(c.value, str) and c.data_type in ("f", "e"):
        c.data_type = "s"
    return c


def _classeur_referentiel(table: str, colonnes: list, nb_cles: int, lignes: list):
    """Le classeur d'un referentiel (plan du lot 5, § 2.1) : 1 onglet au nom de la table, ligne 1 les libelles, ligne 2
    les noms de colonne de la table, donnees a partir de la ligne 3, valeurs sous la forme de la base, que le reimport
    lit (forme des classeurs de fn_ecran_revision et de 61_DEPLOIEMENT/exporter_niveaux_a_cocher.py)."""
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.utils import get_column_letter
    wb = Workbook()
    ws = wb.active
    ws.title = table[:31]
    for j, (cle, lib) in enumerate(colonnes, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = PatternFill("solid", fgColor=ENTETE_CLASSEUR)
        c.font = Font(bold=True, color="FFFFFF")
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
    largeurs = [max(12, len(str(lib)) + 4) for _, lib in colonnes]
    for i, d in enumerate(lignes, 3):
        for j, (cle, _) in enumerate(colonnes, 1):
            c = _ecrire_cellule(ws, i, j, d.get(cle))
            c.alignment = Alignment(vertical="top", wrap_text=isinstance(c.value, str) and len(c.value) > 60)
            if c.value is not None:
                largeurs[j - 1] = min(60, max(largeurs[j - 1], len(str(c.value)) + 2))
    for j, larg in enumerate(largeurs, 1):
        ws.column_dimensions[get_column_letter(j)].width = larg
    ws.freeze_panes = "%s3" % get_column_letter(min(nb_cles, len(colonnes)) + 1)
    if lignes:
        ws.auto_filter.ref = "A2:%s%d" % (get_column_letter(len(colonnes)), len(lignes) + 2)
    return wb


def _classeur_niveaux(questions: list, cycles: list):
    """Le classeur des niveaux de programme, a la forme de 61_DEPLOIEMENT/exporter_niveaux_a_cocher.py : onglet
    « Questions » (les 13 colonnes de COLONNES_NIVEAUX, les croix a choisir dans la liste « X »), puis « Racines par
    cycle ». Aucune regle ici : les croix et le motif sont ceux de v_export_niveaux_programme (decision D-v)."""
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.utils import get_column_letter
    from openpyxl.worksheet.datavalidation import DataValidation
    entete, cocher = PatternFill("solid", fgColor=ENTETE_CLASSEUR), PatternFill("solid", fgColor=CASE_A_COCHER)
    wb = Workbook()
    ws = wb.active
    ws.title = ONGLET_NIVEAUX
    for j, (lib, cle, larg) in enumerate(COLONNES_NIVEAUX, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = entete
        c.font = Font(bold=True, color="FFFFFF")
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
        ws.column_dimensions[get_column_letter(j)].width = larg
    dv = DataValidation(type="list", formula1='"X"', allow_blank=True, showErrorMessage=True,
                        errorTitle="Une croix", error="Mettez X ou laissez vide.")
    ws.add_data_validation(dv)
    for i, d in enumerate(questions, 3):
        for j, (lib, cle, larg) in enumerate(COLONNES_NIVEAUX, 1):
            c = _ecrire_cellule(ws, i, j, d.get(cle))
            if cle in ("allege", "classique", "etendu"):
                c.fill = cocher
                c.alignment = Alignment(horizontal="center")
            elif cle == "enonce":
                c.alignment = Alignment(wrap_text=True, vertical="top")
            else:
                c.alignment = Alignment(vertical="top")
        dv.add("J%d:L%d" % (i, i))
    ws.freeze_panes = "E3"
    ws.auto_filter.ref = "A2:M%d" % (len(questions) + 2)
    r = wb.create_sheet("Racines par cycle")
    for j, (lib, larg) in enumerate((("Cycle", 10), ("Libellé", 55), ("Racines de comptes", 40), ("Questions", 11)), 1):
        c = r.cell(row=1, column=j, value=lib)
        c.fill = entete
        c.font = Font(bold=True, color="FFFFFF")
        r.column_dimensions[get_column_letter(j)].width = larg
    for i, x in enumerate(cycles, 2):
        for j, cle in enumerate(("code", "libelle", "racines", "questions"), 1):
            _ecrire_cellule(r, i, j, x.get(cle))
    return wb


def _phrase_du_depot(debut: str, n: int, singulier: str, pluriel: str, depot: dict) -> str:
    """La phrase d'un export reussi : ce qui est depose, le nombre de lignes, puis l'adresse du classeur que rend la
    procedure (web_url), quand elle la rend (« rend l'adresse dans le message », objet n° 187)."""
    adresse = _vide(depot.get("web_url"))
    texte = "%s déposé au dossier Référentiels du site du cabinet (%s)" % (debut, _compte(n, singulier, pluriel))
    return texte + (" : %s" % adresse if adresse else ".")


def _ouvrir_classeur(g: _Action, octets: bytes, fichier: str):
    """Le classeur relu ; un fichier qu'openpyxl ne lit pas est refuse en francais, en le nommant (forme du refus de
    importer_classeur de fn_ecran_client)."""
    import io
    from openpyxl import load_workbook
    try:
        return load_workbook(io.BytesIO(octets), data_only=True)
    except Exception:
        raise _refus(g, "Réimport refusé : le fichier « %s » n’est pas un classeur Excel lisible." % fichier) from None


# ----------------------------------------------------------------------------- 2a, le classeur d'un referentiel

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def exporter_referentiel(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                         referentiel: str = "") -> str:
    """Bouton « Exporter le classeur » (objet n° 187) : les lignes du referentiel choisi au segment « Référentiel » de
    l'etape 2, dans un classeur Excel (_classeur_referentiel : colonnes du code, puis colonnes de la table que montre la
    liste, valeurs sous la forme de la base), depose au dossier « Référentiels » du site du cabinet par
    pr_deposer_classeur_referentiel (genre REFERENTIEL), sous le nom referentiel_<table>.xlsx : un nouvel export du meme
    referentiel remplace le fichier au site et inscrit une nouvelle ligne de classeur_cabinet. La phrase rendue porte
    l'adresse du classeur. Aucun droit ni etat : l'export ne modifie pas le referentiel. Un referentiel vide, inconnu ou
    qui n'est pas du cabinet part sans contenu : pr_deposer_classeur_referentiel le refuse a son rang, en le citant
    (50831). La procedure refuse ensuite, dans son ordre : nom du classeur (50902), contenu (50903), depot non installe
    (50904), depot refuse par la route (50905, detail au journal des refus, decision D-x)."""
    g = _action(connexion, ctx, ENTITE_CABINET)

    def faire():
        r = _referentiel_du_cabinet(connexion, referentiel)
        if r is None:
            d = _deposer_classeur(connexion, g, "REFERENTIEL", _vide(referentiel), None, None)
            return d.get("message") or "Classeur déposé."
        table, libelle = r
        colonnes, nb_cles = _colonnes_du_classeur(connexion, table)
        ordre = ", ".join(_nom_sql(c) for c, _ in colonnes[:nb_cles]) or "1"
        lignes = _lire(connexion, "SELECT %s FROM dbo.%s ORDER BY %s"
                       % (", ".join(_nom_sql(c) for c, _ in colonnes), _nom_sql(table), ordre), ())
        wb = _classeur_referentiel(table, colonnes, nb_cles, lignes)
        d = _deposer_classeur(connexion, g, "REFERENTIEL", table, "referentiel_%s.xlsx" % table, wb)
        return _phrase_du_depot("Classeur du référentiel « %s »" % libelle, len(lignes), "ligne", "lignes", d)
    return _rendre_depot(g, "exporter_referentiel", faire)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def importer_referentiel(connexion: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient,
                         ctx: fn.UserDataFunctionContext, teneur: str = "", referentiel: str = "") -> str:
    """Bouton « Réimporter le classeur » (objet n° 188) : le dernier classeur depose du referentiel choisi, relu par le
    raccourci du coffre, passe ligne a ligne a pr_importer_referentiel (objet n° 37), qui n'ecrit que les lignes dont une
    valeur change, tout ou rien. La fonction refuse d'abord un droit vide ou different de la personne connectee (_droit,
    avant tout appel a la base), puis traduit le referentiel. 1er appel sans @lignes ni @fichier (plan du lot 5, § 2.2) :
    la procedure refuse, dans son ordre, referentiel vide ou inconnu (50831), fixe par un texte (50906), seuil propre au
    vehicule (50907), aucun droit (50908), aucun classeur depose (50909), code hors de 1 ou 2 parties (50911), et rend
    50910 quand tout le reste est admis. La fonction lit alors la ligne la plus recente de classeur_cabinet du
    referentiel, telecharge son chemin_onelake (« fec/Référentiels/<fichier> ») par le raccourci, refuse un classeur
    absent ou illisible, lit l'onglet au nom de la table (sinon l'onglet actif) et rappelle la procedure avec @lignes
    (tableau JSON, un objet par ligne : les cles de la ligne 2 et « _ligne ») et @fichier ; elle refuse alors chaque
    ligne en la nommant (50910 a 50919, 50928)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_REIMPORTER)

    def faire():
        import json
        sql = "EXEC dbo.pr_importer_referentiel @referentiel=?, @lignes=?, @fichier=?, @par=?"
        t = _table_referentiel(connexion, referentiel)
        _premier_appel(connexion, sql, (t, None, None, g.qui), g, CONTENU_NON_PARVENU)
        d = _lire(connexion, "SELECT TOP (1) fichier, chemin_onelake FROM dbo.classeur_cabinet WHERE genre = ? AND "
                             "referentiel = ? ORDER BY depose_le DESC, id DESC", ("REFERENTIEL", t))
        if not d:
            r = _executer(connexion, sql, (t, None, None, g.qui), g)
            return r.get("message") or "Classeur réimporté."
        fichier, chemin = d[0].get("fichier"), d[0].get("chemin_onelake")
        absent = ("Réimport refusé : le classeur « %s » n’est plus au dossier Référentiels du site du cabinet ; "
                  "« Exporter le classeur » le dépose de nouveau." % fichier)
        if not _vide(chemin):
            raise _refus(g, absent)
        try:
            octets = _lire_au_coffre(coffre, chemin)
        except Exception as e:
            if _absent(e):
                raise _refus(g, absent) from None
            raise
        wb = _ouvrir_classeur(g, octets, fichier)
        ws = wb[t] if t in wb.sheetnames else wb.active
        lignes = _lignes_de(ws)
        r = _executer(connexion, sql, (t, json.dumps(lignes, ensure_ascii=False, default=str), fichier, g.qui), g)
        return r.get("message") or "Classeur réimporté."
    return _rendre(g, "importer_referentiel", faire)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def rattacher_gabarit(connexion: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient,
                      ctx: fn.UserDataFunctionContext, teneur: str = "", referentiel: str = "", modele: str = "",
                      fichier: str = "") -> str:
    """Bouton « Rattacher le fichier » (objet n° 189) : le fichier saisi au champ « Nom du fichier déposé », depose au
    dossier « Modeles » du site du cabinet, rattache au modele de feuille choisi ([Ligne du referentiel choisie]) avec son
    empreinte, par pr_ecran_rattacher_gabarit (objet n° 27), patron de inscrire_piece de fn_ecran_client. referentiel,
    le segment « Référentiel » de l'etape 2, passe aux 2 appels (decision D-u de la session base). La fonction refuse
    d'abord un droit vide ou different de la personne connectee (_droit, avant tout appel a la base), puis traduit le
    referentiel. 1er appel sans @empreinte (plan du lot 5, § 2.3) : la procedure refuse, dans son ordre, le referentiel
    choisi qui ne porte pas de fichier (50923), aucun droit (50908), modele vide ou inconnu (50924), nom du fichier vide,
    trop long, avec un caractere refuse ou d'une autre extension que .docx, .dotx, .xlsx (50925), raccourci absent
    (50926), et rend 50927 quand tout le reste est admis. La fonction lit alors « <RACCOURCI_SITE_CABINET>/Modeles/
    <fichier> » par le raccourci du coffre, refuse un fichier absent, calcule l'empreinte SHA-256 des octets lus, en
    minuscules, et rappelle la procedure avec @chemin_coffre (le chemin lu) et @empreinte."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, teneur, REFUS_DROIT_RATTACHER)

    def faire():
        import hashlib
        sql = ("EXEC dbo.pr_ecran_rattacher_gabarit @modele=?, @fichier=?, @chemin_coffre=?, @empreinte=?, @web_url=?, "
               "@par=?, @referentiel=?")
        t = _table_referentiel(connexion, referentiel)
        m, f = _vide(modele), _vide(fichier)
        _premier_appel(connexion, sql, (m, f, None, None, None, g.qui, t), g, EMPREINTE_MANQUANTE)
        # le chemin que la procedure attend (@attendu) : le raccourci sous LTRIM et RTRIM (espaces seuls), « /Modeles/ »,
        # puis le nom ; un nom vide ou mal forme est deja refuse par le 1er appel (50925), un raccourci absent aussi (50926)
        l = _lire(connexion, "SELECT valeur FROM dbo.ref_parametre WHERE code = ?", ("RACCOURCI_SITE_CABINET",))
        raccourci = str((l[0].get("valeur") if l else None) or "").strip(" ")
        chemin = "%s/Modeles/%s" % (raccourci, f)
        try:
            octets = _lire_au_coffre(coffre, chemin)
        except Exception as e:
            if _absent(e):
                raise _refus(g, "Rattachement refusé : le fichier « %s » n’est pas au dossier Modeles du site du "
                                "cabinet ; déposez-le, puis saisissez son nom." % f) from None
            raise
        empreinte = hashlib.sha256(octets).hexdigest()
        r = _executer(connexion, sql, (m, f, chemin, empreinte, None, g.qui, t), g)
        return r.get("message") or "Fichier rattaché."
    return _rendre(g, "rattacher_gabarit", faire)


# ----------------------------------------------------------------------------- 3, le classeur des niveaux de programme

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def exporter_niveaux(connexion: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext) -> str:
    """Bouton « Exporter les niveaux » (objet n° 194) : les questions de cycle hors ECARTEE et les croix de leur niveau de
    programme, lues dans v_export_niveaux_programme (decision D-v : le niveau pose en base, sinon la proposition du
    28/09/2026, et le motif qui dit laquelle ; ORDER BY ordre_cycle, ordre_question), dans le classeur de
    61_DEPLOIEMENT/exporter_niveaux_a_cocher.py (_classeur_niveaux), depose au dossier « Référentiels » du site du
    cabinet par pr_deposer_classeur_referentiel (genre NIVEAUX), sous le nom niveaux_de_programme.xlsx. La fonction
    n'applique aucune regle elle-meme. Aucun parametre. La procedure refuse, dans son ordre : nom du classeur (50902),
    contenu (50903), depot non installe (50904), depot refuse par la route (50905, detail au journal des refus, decision
    D-x)."""
    g = _action(connexion, ctx, ENTITE_CABINET)

    def faire():
        questions = _lire(connexion, "SELECT cycle, cycle_libelle, reference, enonce, applicabilite, type_reponse, "
                                     "feuille_type, racines_cycle, racines_directes, allege, classique, etendu, motif "
                                     "FROM dbo.v_export_niveaux_programme ORDER BY ordre_cycle, ordre_question", ())
        cycles = _lire(connexion, "SELECT c.code, c.libelle, (SELECT STRING_AGG(rc.racine, ', ') WITHIN GROUP (ORDER BY "
                                  "rc.racine) FROM dbo.ref_cycle_compte rc WHERE rc.cycle = c.code) AS racines, (SELECT "
                                  "COUNT(*) FROM dbo.ref_question q WHERE q.cycle = c.code AND q.statut <> 'ECARTEE') AS "
                                  "questions FROM dbo.ref_cycle c ORDER BY c.ordre", ())
        wb = _classeur_niveaux(questions, cycles)
        d = _deposer_classeur(connexion, g, "NIVEAUX", None, FICHIER_NIVEAUX, wb)
        return _phrase_du_depot("Classeur des niveaux de programme", len(questions), "question de cycle",
                                "questions de cycle", d)
    return _rendre_depot(g, "exporter_niveaux", faire)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="connexion")
@udf.function()
def importer_niveaux(connexion: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient,
                     ctx: fn.UserDataFunctionContext, associe: str = "") -> str:
    """Bouton « Réimporter les niveaux » (objet n° 195) : le dernier classeur des niveaux depose, relu par le raccourci du
    coffre, passe a pr_importer_niveaux_programme (objet n° 38), qui pose niveau_programme sur les questions de cycle
    cochees (X : Allégé, Classique et Étendu, niveau 1 ; Classique et Étendu, 2 ; Étendu seul, 3), tout ou rien, une
    ligne sans croix laissant la question a son niveau. La fonction refuse d'abord un associe vide ou different de la
    personne connectee (_droit, avant tout appel a la base, texte de 50908). 1er appel sans @lignes ni @fichier (plan du
    lot 5, § 2.4) : la procedure refuse, dans son ordre, aucun classeur depose (50909), reserve a l'associe (50908), et
    rend 50910 quand tout le reste est admis. La fonction lit alors la ligne la plus recente de classeur_cabinet du genre
    NIVEAUX, telecharge son chemin_onelake par le raccourci, refuse un classeur absent ou illisible, lit l'onglet
    « Questions » (sinon l'onglet actif) et rappelle la procedure avec @lignes (« _ligne », reference, allege, classique,
    etendu ; les autres colonnes sont sans effet) et @fichier ; elle refuse alors chaque ligne en la nommant (50910,
    50920 a 50922)."""
    g = _action(connexion, ctx, ENTITE_CABINET)
    _droit(g, associe, REFUS_ASSOCIE_NIVEAUX)

    def faire():
        import json
        sql = "EXEC dbo.pr_importer_niveaux_programme @lignes=?, @fichier=?, @par=?"
        _premier_appel(connexion, sql, (None, None, g.qui), g, CONTENU_NON_PARVENU)
        d = _lire(connexion, "SELECT TOP (1) fichier, chemin_onelake FROM dbo.classeur_cabinet WHERE genre = ? "
                             "ORDER BY depose_le DESC, id DESC", ("NIVEAUX",))
        if not d:
            r = _executer(connexion, sql, (None, None, g.qui), g)
            return r.get("message") or "Classeur des niveaux réimporté."
        fichier, chemin = d[0].get("fichier"), d[0].get("chemin_onelake")
        absent = ("Réimport refusé : le classeur « %s » n’est plus au dossier Référentiels du site du cabinet ; "
                  "« Exporter les niveaux » le dépose de nouveau." % fichier)
        if not _vide(chemin):
            raise _refus(g, absent)
        try:
            octets = _lire_au_coffre(coffre, chemin)
        except Exception as e:
            if _absent(e):
                raise _refus(g, absent) from None
            raise
        wb = _ouvrir_classeur(g, octets, fichier)
        ws = wb[ONGLET_NIVEAUX] if ONGLET_NIVEAUX in wb.sheetnames else wb.active
        lignes = [{"_ligne": x["_ligne"], "reference": x.get("reference"), "allege": x.get("allege"),
                   "classique": x.get("classique"), "etendu": x.get("etendu")} for x in _lignes_de(ws)]
        r = _executer(connexion, sql, (json.dumps(lignes, ensure_ascii=False, default=str), fichier, g.qui), g)
        return r.get("message") or "Classeur des niveaux réimporté."
    return _rendre(g, "importer_niveaux", faire)
