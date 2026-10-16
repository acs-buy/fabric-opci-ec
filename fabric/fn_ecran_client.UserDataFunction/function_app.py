"""fn_ecran_client : les boutons de l'ecran Client et Acceptation, une fonction par bouton.

Chaque fonction appelle UNE procedure de la base DossierOPCI et rend la phrase que le bouton affiche. Les
regles metier ne sont jamais ici : elles sont dans la procedure, qui refuse en francais, et le refus
remonte tel quel.

La pose se fait par l'API (updateDefinition) et se relit par getDefinition. La connexion a la base porte
l'alias « DossierOPCI », meme alias que fn_documents et fn_valorisation ; celle du coffre « Coffre ».

AUCUN PARAMETRE DES BOUTONS DE L'ECRAN CLIENT N'EST OBLIGATOIRE. Un parametre obligatoire et vide desactive le
bouton, et le service affiche alors au survol une bulle en anglais qui nomme le parametre ; aucune propriete du
bouton ne la remplace. Chaque parametre de ces fonctions a donc un defaut, et le bouton se declenche toujours. Le
refus s'affiche en francais dans la zone de message de l'ecran, selon 2 regles :
  - UNE SAISIE MANQUANTE (un champ que l'utilisateur tape ou choisit dans un formulaire) part a NULL et la
    procedure la refuse ; quand la base n'a pas de refus pour ce cas, ou que son refus ne nomme pas le champ, la
    fonction refuse elle-meme en nommant le champ ;
  - UN CHOIX MANQUANT (le client, la filiale, la question ou le role choisis a l'ecran, le superviseur connecte)
    est refuse par la fonction, qui dit quoi choisir : la base ne connait pas l'ecran.
Le gris d'un bouton qui n'a pas lieu d'etre se lit sur une mesure du modele, et non plus sur un parametre vide.
Les fonctions qu'aucun bouton n'appelle gardent leurs parametres obligatoires.

CE QUE LA PLATEFORME IMPOSE, d'apres la documentation Microsoft Learn :
  - parametres en camelCase, sans soulignement, types annotes, retour annote ;
  - l'utilisateur qui clique est connu par UserDataFunctionContext.executing_user, cle
    PreferredUsername, decorateur @udf.context : c'est lui qui devient @par. Le rapport ne le passe
    pas, il ne peut donc pas le falsifier ;
  - une erreur attendue se rend par fn.UserThrownError, dont le message est affiche a l'appelant ;
  - pas d'execution dans Desktop, seulement sur le rapport publie ; les lecteurs recoivent
    « Execute functions » sur l'element.

PATRON D'APPEL. FabricSqlConnection.connect() rend une connexion pyodbc, autocommit desactive :
sans commit explicite, l'EXEC serait annule a la fermeture. Les procedures d'ecran (pr_ecran_*)
n'echouent pas : elles ecrivent le refus sur la ligne concernee, colonne message_ecran, pour que le
rapport le lise. La fonction relit cette colonne apres l'appel et le rend en erreur si elle est
posee, en succes sinon. Les autres procedures rendent un jeu de resultats (code, message) et
levent le refus : la fonction rend le dernier jeu de resultats.
"""

import datetime
import hashlib
import logging
import re
import threading

import fabric.functions as fn

udf = fn.UserDataFunctions()


# ----------------------------------------------------------------------------- outils

def _qui(ctx) -> str:
    """L'utilisateur connecte, tel que la plateforme l'authentifie.

    CHAQUE FONCTION L'APPELLE EN TETE, avant tout refus : le journal des refus et la zone de message lisent
    l'utilisateur retenu ici, et un refus constate avant cet appel serait adresse a l'utilisateur d'un appel
    precedent, ou a « inconnu »."""
    u = (ctx.executing_user or {}).get("PreferredUsername") or (ctx.executing_user or {}).get("Oid")
    if not u:
        raise fn.UserThrownError("L'utilisateur connecté n'est pas identifiable ; l'action n'est pas exécutée.", {})
    _UTILISATEUR.upn = u                         # retenu pour journaliser un refus apres rollback
    return u


def _message_sql(exc) -> str:
    """Le texte francais d'un THROW, sans le prefixe du pilote ODBC."""
    s = str(exc)
    m = re.search(r"\[SQL Server\](.*?)(\s\(\d+\)\s\(SQLExecDirectW\)|$)", s, re.S)
    return (m.group(1) if m else s).strip()


def _numero_sql(exc):
    """Le numero d'un THROW de la base (50220 par exemple), ou None."""
    m = re.search(r"\((\d{5,6})\)\s*\(SQLExecDirectW\)", str(exc))
    return int(m.group(1)) if m else None


def _entite_probable(params):
    """Le code d'entite d'un appel, par convention le premier parametre court et alphanumerique."""
    for p in (params or ()):
        if isinstance(p, str) and 2 < len(p) <= 20 and p.replace("-", "").replace("_", "").isalnum():
            return p
    return None


# L'ENTITE DU MESSAGE SE DONNE QUAND ELLE EST CONNUE. Par defaut elle se deduit des parametres ; un appel sans
# client la deduirait du code de la filiale, et le message ne s'afficherait sous aucun client. None l'adresse a
# tous les clients de la personne connectee.
_DEDUITE = object()


def _entite(params, entite):
    return _entite_probable(params) if entite is _DEDUITE else entite


def _nom_procedure(sql):
    m = re.search(r"EXEC dbo\.(\w+)", sql or "")
    return m.group(1)[:128] if m else "inconnue"


def _poser_message_dans(cur, sql, message, params, genre, entite=_DEDUITE):
    """Ecrit la boite aux lettres dans la transaction en cours, sans committer : l'appelant commit."""
    try:
        if message:
            cur.execute("EXEC dbo.pr_poser_message_ecran @pour=?, @message=?, @genre=?, @entite=?, @procedure_nom=?",
                        (_qui_sans_lever(), str(message)[:2000], genre,
                         _entite(params, entite), _nom_procedure(sql)))
    except Exception:
        pass


def _poser_message(conn, sql, message, params, genre, entite=_DEDUITE):
    """Ecrit le dernier geste dans la boite aux lettres de l'ecran, reussite comme refus.

    POURQUOI UNE BOITE AUX LETTRES ET NON LE JOURNAL : un refus lu dans journal_refus survivait a la
    reussite suivante, et le reviseur lisait « deja au perimetre » alors que son ajout venait de reussir.
    journal_refus est une TRACE, elle s'ajoute et ne s'efface pas ; la zone de message est un ETAT, une
    seule ligne vivante par personne et par dossier, remplacee a chaque geste.

    Ne leve jamais."""
    try:
        cur = conn.cursor()
        cur.execute("EXEC dbo.pr_poser_message_ecran @pour=?, @message=?, @genre=?, @entite=?, @procedure_nom=?",
                    (_qui_sans_lever(), (message or "")[:2000], genre,
                     _entite(params, entite), _nom_procedure(sql)))
        conn.commit()
    except Exception:
        try:
            conn.rollback()
        except Exception:
            pass


def _journaliser_refus(conn, sql, message, params, entite=_DEDUITE):
    """Ecrit le refus dans journal_refus APRES le rollback, dans une transaction neuve.

    POURQUOI ICI ET NON DANS LA PROCEDURE : une procedure qui leve un THROW voit son propre INSERT de
    journal annule par le rollback que fait cette fonction, la connexion etant sans autocommit et SQL
    Server n'ayant pas de transaction autonome. Un refus journalise par la procedure elle-meme
    (pr_supprimer_filiale) ne survit que si l'appelant ne fait pas rollback.

    SANS CE JOURNAL, LE REVISEUR NE LIT RIEN : ajouter une filiale deja au perimetre laissait l'ecran
    muet, la base refusant sans qu'aucune table lue par l'ecran ne porte le message.

    Ne leve jamais : un journal qui echoue ne doit pas masquer le refus qu'il rapporte."""
    try:
        nom = "inconnue"
        m = re.search(r"EXEC dbo\.(\w+)", sql or "")
        if m:
            nom = m.group(1)
        entite = _entite(params, entite)
        cur = conn.cursor()
        cur.execute("EXEC dbo.pr_journaliser_refus @procedure_nom=?, @message=?, @par=?, @entite=?",
                    (nom[:128], (message or "")[:2000], _qui_sans_lever(), entite))
        cur.execute("EXEC dbo.pr_poser_message_ecran @pour=?, @message=?, @genre=?, @entite=?, @procedure_nom=?",
                    (_qui_sans_lever(), (message or "")[:2000], "REFUS", entite, nom[:128]))
        conn.commit()
    except Exception:                            # le journal ne doit jamais masquer le refus
        try:
            conn.rollback()
        except Exception:
            pass


# L'UTILISATEUR RETENU EST PROPRE AU FIL D'EXECUTION : 2 appels simultanes dans le meme processus ne se
# prennent pas leur utilisateur.
_UTILISATEUR = threading.local()


def _qui_sans_lever():
    """L'utilisateur retenu par _qui dans l'appel en cours, ou « inconnu » : le journal n'a pas de contexte."""
    return getattr(_UTILISATEUR, "upn", None) or "inconnu"


def _refus(message, sql, numero=None):
    """L'erreur rendue a l'ecran ; le numero du refus de la base, s'il y en a un, reste lisible par l'appelant."""
    e = fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    try:
        e.numero = numero
    except Exception:
        pass
    return e


def _executer(base: fn.FabricSqlConnection, sql: str, params: tuple, entite=_DEDUITE) -> dict:
    """Execute une procedure qui rend (…, message) et leve ses refus. Rend la derniere ligne."""
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
        # LE SUCCES S'AFFICHE AUSSI : sans cela le reviseur ne voit rien quand son geste marche, et
        # la zone de message garde le message du geste precedent.
        _poser_message_dans(cur, sql, (derniere or {}).get("message"), params, "SUCCES", entite)
        conn.commit()
        return derniere or {}
    except Exception as e:                      # pyodbc.Error, sans dependre de son import
        conn.rollback()
        message = _message_sql(e)
        _journaliser_refus(conn, sql, message, params, entite)
        raise _refus(message, sql, _numero_sql(e))
    finally:
        conn.close()


def _executer_ecran(base: fn.FabricSqlConnection, sql: str, params: tuple, relire: str,
                    relire_params: tuple, succes: str) -> str:
    """Execute une pr_ecran_* qui ecrit son refus dans message_ecran, puis relit cette colonne."""
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute(sql, params)
        while cur.nextset():
            pass
        _poser_message_dans(cur, sql, succes, params, "SUCCES")
        conn.commit()
        cur.execute(relire, relire_params)
        ligne = cur.fetchone()
    except Exception as e:
        conn.rollback()
        message = _message_sql(e)
        _journaliser_refus(conn, sql, message, params)
        raise fn.UserThrownError(message, {"sql": sql.split("(")[0].strip()})
    finally:
        conn.close()
    message = ligne[0] if ligne else None
    if message:
        _refuser(base, sql, message, params)
    return succes


def _vide(s) -> str:
    return None if s is None or str(s).strip() == "" else str(s).strip()


def _texte(e) -> str:
    """Le message d'un refus, sans les proprietes que la plateforme lui attache."""
    v = getattr(e, "message", None)
    if isinstance(v, str) and v.strip():
        return v
    return str(e) or e.__class__.__name__


_CLASSEMENT_ILLISIBLE = ("Classement « %s » non reconnu. Le classement de la filiale au sens de l'article R. 214-83 "
                         "du code monétaire et financier se saisit oui si elle est contrôlée, non sinon.")


def _classement(valeur):
    """Le classement de la filiale au sens de l'article R. 214-83 du CMF : « oui » rend 1, « non » rend 0, casse et
    espaces indifferents ; un champ vide rend None ; tout autre texte leve ValueError. Un booleen lu dans un
    classeur est admis tel quel."""
    if isinstance(valeur, bool):
        return 1 if valeur else 0
    s = _vide(valeur)
    if s is None:
        return None
    t = s.lower()
    if t == "oui":
        return 1
    if t == "non":
        return 0
    raise ValueError(s)


def _refuser(base: fn.FabricSqlConnection, sql: str, message: str, params: tuple, entite=_DEDUITE):
    """Un refus constate avant l'appel de la procedure : journalise et affiche comme un refus de la base."""
    conn = base.connect()
    try:
        _journaliser_refus(conn, sql, message, params, entite)
    finally:
        conn.close()
    raise _refus(message, sql)


def _choix(base: fn.FabricSqlConnection, sql: str, valeur, message: str, entite=None):
    """Un choix d'ecran : sa valeur nettoyee, ou le refus en francais qui dit quoi choisir."""
    v = _vide(valeur)
    if v is None:
        _refuser(base, sql, message, (entite,), entite=_vide(entite))
    return v


_CLIENT_A_CHOISIR = "Choisissez d'abord le client dans la liste des clients."
_FILIALE_A_CHOISIR = "Choisissez d'abord la filiale dans la liste des filiales."


def _entite_de_cote(base: fn.FabricSqlConnection, cote):
    """Le client d'une feuille, lu par sa cote : un message s'affiche sous le client, pas sous la cote."""
    if not _vide(cote):
        return None
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 entite FROM dbo.feuille_travail WHERE cote = ?", (_vide(cote),))
        ligne = cur.fetchone()
    finally:
        conn.close()
    return ligne[0] if ligne else None


# ----------------------------------------------------------------------------- creer le dossier

# LES CHAMPS OBLIGATOIRES D'UN DOSSIER, sous le libelle de l'ecran. La base refuse elle-meme un code ou une forme
# du vehicule absents ; pour les autres, elle n'a pas de refus, et la fonction les nomme tous a la fois.
_CHAMPS_CLIENT = (("code", "Code du client", True), ("denomination", "Dénomination", False),
                  ("formeVehicule", "Forme du véhicule", True), ("adresse1", "Adresse", False),
                  ("codePostal", "Code postal", False), ("ville", "Ville", False),
                  ("dirigeantNom", "Nom du dirigeant", False), ("dirigeantQualite", "Qualité du dirigeant", False))

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def creer_client(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                 code: str = "", denomination: str = "", formeVehicule: str = "", adresse1: str = "",
                 codePostal: str = "", ville: str = "", dirigeantNom: str = "", dirigeantQualite: str = "",
                 siren: str = "", formeSociale: str = "", adresse2: str = "", pays: str = "FR",
                 contactNom: str = "", contactCourriel: str = "", contactTelephone: str = "",
                 cloture: str = "31/12", periodiciteVl: str = "", siteUrl: str = "") -> str:
    """Bouton « Créer le dossier » : les 15 champs de l'ecran, plus le lien du site SharePoint cree par le
    reviseur via Teams, vers pr_creer_client : le client, son questionnaire d'acceptation et son site dans le
    meme geste. Le message s'adresse a tous les clients de la personne : le client n'existe pas encore."""
    sql = ("EXEC dbo.pr_creer_client @code=?, @denomination=?, @siren=?, @forme_vehicule=?, @forme_sociale=?, "
           "@adresse_1=?, @adresse_2=?, @code_postal=?, @ville=?, @pays=?, @dirigeant_nom=?, @dirigeant_qualite=?, "
           "@contact_nom=?, @contact_courriel=?, @contact_telephone=?, @cloture=?, @periodicite_vl=?, @site_url=?, @par=?")
    par = _qui(ctx)
    valeurs = {"code": code, "denomination": denomination, "formeVehicule": formeVehicule, "adresse1": adresse1,
               "codePostal": codePostal, "ville": ville, "dirigeantNom": dirigeantNom,
               "dirigeantQualite": dirigeantQualite}
    manquants = [(lib, base_refuse) for nom, lib, base_refuse in _CHAMPS_CLIENT if _vide(valeurs[nom]) is None]
    if any(not base_refuse for _, base_refuse in manquants):
        _refuser(base, sql, "Champs obligatoires à remplir : %s." % ", ".join(lib for lib, _ in manquants), (None,),
                 entite=None)
    r = _executer(base, sql,
                  (_vide(code), _vide(denomination), _vide(siren), _vide(formeVehicule), _vide(formeSociale),
                   _vide(adresse1), _vide(adresse2), _vide(codePostal), _vide(ville), _vide(pays) or "FR",
                   _vide(dirigeantNom), _vide(dirigeantQualite), _vide(contactNom), _vide(contactCourriel),
                   _vide(contactTelephone), _vide(cloture) or "31/12", _vide(periodiciteVl), _vide(siteUrl), par),
                  entite=None)
    return r.get("message", "Client créé.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def modifier_client(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, code: str = "",
                    denomination: str = "", siren: str = "", formeVehicule: str = "", formeSociale: str = "",
                    adresse1: str = "", adresse2: str = "", codePostal: str = "", ville: str = "", pays: str = "",
                    dirigeantNom: str = "", dirigeantQualite: str = "", contactNom: str = "", contactCourriel: str = "",
                    contactTelephone: str = "", cloture: str = "", siteUrl: str = "") -> str:
    """Bouton « Enregistrer les modifications » de la fiche du dossier : pr_modifier_client.
    Le code ne change pas ; un champ vide reste inchange ; « - » efface un champ facultatif ; un lien SharePoint
    fourni remplace le precedent."""
    sql = ("EXEC dbo.pr_modifier_client @code=?, @denomination=?, @siren=?, @forme_vehicule=?, @forme_sociale=?, "
           "@adresse_1=?, @adresse_2=?, @code_postal=?, @ville=?, @pays=?, @dirigeant_nom=?, @dirigeant_qualite=?, "
           "@contact_nom=?, @contact_courriel=?, @contact_telephone=?, @cloture=?, @site_url=?, @par=?")
    _qui(ctx)
    code = _choix(base, sql, code, _CLIENT_A_CHOISIR)
    r = _executer(base, sql,
                  (code, _vide(denomination), _vide(siren), _vide(formeVehicule), _vide(formeSociale), _vide(adresse1),
                   _vide(adresse2), _vide(codePostal), _vide(ville), _vide(pays), _vide(dirigeantNom), _vide(dirigeantQualite),
                   _vide(contactNom), _vide(contactCourriel), _vide(contactTelephone), _vide(cloture), _vide(siteUrl), _qui(ctx)))
    return r.get("message", "Informations mises à jour.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def designer_role(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                  entite: str = "", role: str = "", personne: str = "", connexion: str = "") -> str:
    """Bouton « Désigner » de la section Equipe de la mission (fiche du dossier) : pr_designer_role_mission.
    Designer quelqu'un ferme le mandat en cours du meme role, la base l'imposant. La connexion
    est l'UPN : sans elle, la personne ne sera pas reconnue a l'ecran. Une personne absente est refusee par la
    base (50292)."""
    sql = "EXEC dbo.pr_designer_role_mission @entite=?, @role=?, @personne=?, @connexion=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    role = _choix(base, sql, role, "Choisissez d'abord le rôle dans la liste de l'équipe de la mission.", entite)
    r = _executer(base, sql, (entite, role, _vide(personne), _vide(connexion), par))
    return r.get("message", "Rôle désigné.")


# ----------------------------------------------------------------------------- les filiales

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ajouter_filiale(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                    client: str = "", code: str = "", droitsDeVote: float = 0.0, denomination: str = "",
                    formeSociale: str = "SCI", controlee: str = "") -> str:
    """Bouton « Ajouter cette filiale » : 80 ou 0,80 sont admis pour 80 %. Le classement au sens de l'article
    R. 214-83 du CMF est obligatoire, oui ou non.

    TOUS LES PARAMETRES SONT FACULTATIFS A LA FONCTION, LES REGLES RESTENT A LA BASE. Un champ vide part a NULL
    et pr_ajouter_filiale le refuse en francais : code (50210), droits de vote (50213), classement (50220). Un
    client absent est un choix manquant, refuse par la fonction. Le refus s'affiche dans la zone de message de
    l'ecran, sous le client de l'appel, ou sous tous les clients quand l'appel n'en porte pas."""
    sql = ("EXEC dbo.pr_ajouter_filiale @client=?, @code=?, @denomination=?, @forme_sociale=?, @droits_de_vote=?, "
           "@par=?, @controlee=?")
    par = _qui(ctx)
    client = _choix(base, sql, client, _CLIENT_A_CHOISIR)
    code = _vide(code)
    try:
        classement = _classement(controlee)
    except ValueError as e:
        _refuser(base, sql, _CLASSEMENT_ILLISIBLE % e, (client, code), entite=client)
    dv = None
    if droitsDeVote:
        dv = float(droitsDeVote)
        if dv > 1:
            dv = dv / 100.0
        dv = round(dv, 6)
    r = _executer(base, sql,
                  (client, code, _vide(denomination), formeSociale or "SCI", dv, par, classement), entite=client)
    return r.get("message", "Filiale ajoutée.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def modifier_filiale(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                     client: str = "", code: str = "", denomination: str = "", formeSociale: str = "",
                     droitsDeVote: str = "", controlee: str = "") -> str:
    """Bouton « Enregistrer la filiale » : pr_modifier_filiale. Le code ne change pas ; un champ vide reste
    inchange ; les droits de vote s'ecrivent 80 ou 0,80 ; le classement au sens de l'article R. 214-83 du CMF
    s'ecrit oui ou non. Le client et la filiale sont des choix de l'ecran."""
    sql = ("EXEC dbo.pr_modifier_filiale @client=?, @code=?, @denomination=?, @forme_sociale=?, @droits_de_vote=?, "
           "@par=?, @controlee=?")
    par = _qui(ctx)
    client = _choix(base, sql, client, _CLIENT_A_CHOISIR)
    code = _choix(base, sql, code, _FILIALE_A_CHOISIR, client)
    try:
        classement = _classement(controlee)
    except ValueError as e:
        _refuser(base, sql, _CLASSEMENT_ILLISIBLE % e, (client, code), entite=client)
    dv = None
    if _vide(droitsDeVote) is not None:
        try:
            dv = float(str(droitsDeVote).replace(",", ".").replace("%", "").strip())
        except ValueError:
            _refuser(base, sql, "Droits de vote illisibles : « %s ». Ils s'écrivent 80 ou 0,80 pour 80 %%."
                     % droitsDeVote, (client, code), entite=client)
        if dv > 1:
            dv = dv / 100.0
        dv = round(dv, 6)
    r = _executer(base, sql,
                  (client, code, _vide(denomination), _vide(formeSociale), dv, par, classement), entite=client)
    return r.get("message", "Filiale mise à jour.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def supprimer_filiale(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      client: str = "", code: str = "") -> str:
    """Bouton « Supprimer » de la confirmation du retrait : pr_supprimer_filiale.
    La base refuse si la filiale porte des donnees de mission, et dit lesquelles. Le client et la filiale sont
    des choix de l'ecran."""
    sql = "EXEC dbo.pr_supprimer_filiale @client=?, @code=?, @par=?"
    par = _qui(ctx)
    client = _choix(base, sql, client, _CLIENT_A_CHOISIR)
    code = _choix(base, sql, code, _FILIALE_A_CHOISIR, client)
    r = _executer(base, sql, (client, code, par), entite=client)
    return r.get("message", "Filiale retirée du périmètre.")


# ----------------------------------------------------------------------------- le questionnaire

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ouvrir_questionnaire_acceptation(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                                     entite: str) -> str:
    """Bouton « Ouvrir la saisie en ligne » : la feuille et ses 110 questions, puis l'acceptation."""
    r = _executer(base, "EXEC dbo.pr_ouvrir_questionnaire_acceptation @entite=?, @par=?", (entite, _qui(ctx)))
    return r.get("message", "Questionnaire ouvert.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def repondre_question(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      cote: str = "", reference: str = "", reponse: str = "", motif: str = "",
                      commentaire: str = "") -> str:
    """Une reponse, a l'ecran : OUI, NON, NA avec motif, ou la valeur d'un choix.

    UNE REPONSE VIDE EST REFUSEE ICI : pr_repondre_question la lit comme l'effacement de la reponse, geste que ce
    bouton n'a jamais permis."""
    sql = ("EXEC dbo.pr_repondre_question @cote=?, @reference=?, @reponse=?, @motif_non_applicable=?, @commentaire=?, "
           "@par=?")
    par = _qui(ctx)
    client = _entite_de_cote(base, cote)
    cote = _choix(base, sql, cote, "Le questionnaire d'acceptation de ce client n'est pas ouvert.", client)
    reference = _choix(base, sql, reference, "Cliquez d'abord la question dans la grille du questionnaire.", client)
    if _vide(reponse) is None:
        _refuser(base, sql, "Saisissez la réponse à %s : OUI, NON, NA avec un motif, ou la valeur attendue."
                 % reference, (client,), entite=client)
    _executer(base, sql, (cote, reference, _vide(reponse), _vide(motif), _vide(commentaire), par), entite=client)
    return f"Réponse à {reference} enregistrée."


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def importer_reponses(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      cote: str, reponses: list) -> str:
    """Bouton « Réimporter » : la liste des reponses lues du classeur, tout ou rien."""
    import json
    r = _executer(base, "EXEC dbo.pr_importer_reponses @cote=?, @reponses=?, @par=?",
                  (cote, json.dumps(reponses, ensure_ascii=False), _qui(ctx)))
    return r.get("message", "Réponses importées.")


# ----------------------------------------------------------------------------- les pieces

def _code_nature(base: fn.FabricSqlConnection, nature) -> str:
    """Le code de la nature d'une piece, lu par son code ou par son libelle dans ref_nature_piece ; la valeur recue
    telle quelle si elle n'y est pas, pour que la base la refuse en francais."""
    v = _vide(nature)
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 code FROM dbo.ref_nature_piece WHERE code = ? OR libelle = ? "
                    "ORDER BY CASE WHEN code = ? THEN 0 ELSE 1 END", (v, v, v))
        ligne = cur.fetchone()
    finally:
        conn.close()
    return ligne[0] if ligne and ligne[0] else v


def _question_du_client(base: fn.FabricSqlConnection, entite, question) -> bool:
    """Vrai si la reference est une question d'un questionnaire du client (v_questions_acceptation). pr_deposer_piece
    ne controle que l'existence de la reference dans ref_question : une piece d'un client se rattachait a une question
    du questionnaire d'un autre client."""
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 1 FROM dbo.v_questions_acceptation WHERE entite = ? AND reference = ?",
                    (entite, question))
        return cur.fetchone() is not None
    finally:
        conn.close()


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def inscrire_piece(base: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient,
                   ctx: fn.UserDataFunctionContext, entite: str = "", chemin: str = "", nature: str = "",
                   arrete: str = "", question: str = "") -> str:
    """Bouton « Rattacher la pièce » : inscrit un fichier DEJA DEPOSE dans la bibliotheque « Dépôt du
    client » du vehicule.

    Un fichier se depose dans SharePoint, et le coffre ne le lit que par un raccourci. « chemin » porte
    donc le NOM DU FICHIER tel que depose, sous-dossier facultatif, par exemple « Baux/bail_principal.pdf ».
    Le nom du parametre reste « chemin » : les boutons le lient sous ce nom.

    pr_resoudre_fichier_depot rend le chemin de lecture par le raccourci sp_<vehicule>_depot, le
    chemin_coffre et l'adresse SharePoint. La fonction lit le fichier pour son empreinte, et c'est elle
    qui refuse un fichier absent : la base ne voit pas SharePoint.

    LES 2 CHAMPS A REMPLIR, le nom du fichier et la nature, sont refuses par la fonction quand ils sont vides,
    tous 2 nommes dans le meme refus : le refus de la base sur une nature absente (50272) ne nomme pas le champ.
    LA NATURE ARRIVE PAR SON LIBELLE, celui que le segment « Nature » affiche ; la procedure attend son code. La
    fonction le traduit par ref_nature_piece (code ou libelle admis) ; une nature inconnue part telle quelle et la
    base la refuse en francais (50272).

    LA QUESTION, quand elle est donnee, est une question d'un questionnaire du client ; sinon le geste est refuse
    avant toute lecture du fichier."""
    sql = ("EXEC dbo.pr_deposer_piece @entite=?, @nom_fichier=?, @chemin_coffre=?, @empreinte=?, @nature=?, "
           "@arrete=?, @question=?, @par=?, @web_url=?")
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    fichier = (chemin or "").strip()
    manquants = [lib for v, lib in ((fichier, "« Nom du fichier déposé »"), (_vide(nature), "« Nature »")) if not v]
    if manquants:
        _refuser(base, sql, "Champs obligatoires à remplir : %s." % ", ".join(manquants), (entite,), entite=entite)
    q = _vide(question)
    if q is not None and not _question_du_client(base, entite, q):
        _refuser(base, sql, f"La question {q} n'appartient à aucun questionnaire de {entite}.", (entite,),
                 entite=entite)
    nature = _code_nature(base, nature)
    d = _executer(base, "EXEC dbo.pr_resoudre_fichier_depot @entite=?, @fichier=?", (entite, fichier), entite=entite)
    try:
        octets = coffre.connectToFiles().get_file_client(d["chemin_lecture"]).download_file().readall()
    except Exception:
        _refuser(base, sql,
                 f"Le fichier « {fichier} » n'est pas dans la bibliothèque Dépôt du client de "
                 f"{d.get('vehicule') or entite}. Vérifiez son nom et son sous-dossier.", (entite,), entite=entite)
    empreinte = hashlib.sha256(octets).hexdigest().upper()
    r = _executer(base, sql,
                  (entite, d["nom_fichier"], d["chemin_coffre"], empreinte, _vide(nature), _vide(arrete),
                   _vide(question), par, d.get("web_url")), entite=entite)
    return r.get("message", "Pièce inscrite.") + f" {len(octets) // 1024} Ko."


_PIECE_A_CHOISIR = "Choisissez d'abord la pièce dans « Pièce à retirer »."


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def retirer_piece(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                  entite: str = "", rattachementId: str = "", motif: str = "") -> str:
    """Bouton « Retirer la pièce » du sous-etat 3c : pr_retirer_piece sur le RATTACHEMENT designe, et non sur le
    dernier rattachement de la piece. Le fichier reste dans SharePoint ; le rattachement au dossier part, avec sa
    trace et son motif.

    « rattachementId » porte la valeur du segment « Pièce à retirer », colonne [Pièce] de v_ecran_pieces_du_dossier :
    « fichier · jj/mm/aaaa · n° 208 ». Le nombre final est l'identifiant du rattachement, seul lu ici ; rien ne s'y
    lit, la fonction refuse en disant quoi choisir. Le motif vide part a NULL et la base le refuse (50277). La base
    juge, dans l'ordre : le droit de la personne connectee (50980), le motif, le rattachement (50278), le verrou du
    dossier de son arrete (50303), ce que la piece fonde (50279). @piece_id n'est pas passe : il prend son defaut
    NULL."""
    sql = "EXEC dbo.pr_retirer_piece @entite=?, @rattachement_id=?, @motif=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    m = re.search(r"(\d+)\s*$", _vide(rattachementId) or "")
    if not m:
        _refuser(base, sql, _PIECE_A_CHOISIR, (entite,), entite=entite)
    r = _executer(base, sql, (entite, int(m.group(1)), _vide(motif), par), entite=entite)
    return r.get("message", "Pièce retirée du dossier.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def reclamer_document(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                      entite: str, arrete: str, livrable: str) -> str:
    """Bouton « Réclamer » : la demande de document, tracee sur l'arrete."""
    return _executer_ecran(base,
                           "EXEC dbo.pr_ecran_demander_document @entite=?, @arrete=?, @livrable=?, @par=?",
                           (entite, arrete, livrable, _qui(ctx)),
                           "SELECT message_ecran FROM dbo.ref_arrete WHERE entite=? AND arrete=?", (entite, arrete),
                           f"Document {livrable} réclamé pour l'arrêté {arrete}.")


# ----------------------------------------------------------------------------- le visa

def _superviseur(base: fn.FabricSqlConnection, ctx, sql: str, superviseur: str, entite) -> None:
    """Le parametre « superviseur » est lie a la mesure Superviseur connecte : vide pour un preparateur, et le
    bouton est alors grise par sa mesure de fond. La valeur fournie doit etre l'utilisateur authentifie lui-meme,
    sinon le geste est refuse, en francais, dans la zone de message ; la procedure refuse a son tour le
    proposant et le role insuffisant."""
    qui = _qui(ctx)
    if _vide(superviseur) is None or superviseur.strip().lower() != qui.strip().lower():
        _refuser(base, sql, "Le visa est réservé au superviseur connecté ; l'action n'est pas exécutée.", (entite,),
                 entite=entite)


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def approuver_acceptation(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                          entite: str = "", decision: str = "", superviseur: str = "", motif: str = "") -> str:
    """Boutons « Approuver » et « Refuser » : decision ACCEPTEE ou REFUSEE, par l'associe.
    La procedure refuse le proposant et le role insuffisant ; le rapport grise le bouton en amont."""
    sql = "EXEC dbo.pr_ecran_approuver_acceptation @entite=?, @decision=?, @motif=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    _superviseur(base, ctx, sql, superviseur, entite)
    decision = _choix(base, sql, decision, "La décision manque : Approuver ou Refuser.", entite)
    return _executer_ecran(base,
                           sql,
                           (entite, decision, _vide(motif), par),
                           "SELECT TOP 1 message_ecran FROM dbo.acceptation_mission WHERE entite=? ORDER BY cree_le DESC",
                           (entite,),
                           f"Acceptation de {entite} : décision {decision.lower()} visée.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def reprendre_acceptation(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                          entite: str = "", motif: str = "") -> str:
    """Bouton « Reprendre » : une acceptation refusee revient a l'etat ouvert, avec motif. Un motif absent est
    refuse par la base (50073)."""
    sql = "EXEC dbo.pr_ecran_reprendre_acceptation @entite=?, @motif=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    return _executer_ecran(base,
                           sql,
                           (entite, _vide(motif), par),
                           "SELECT TOP 1 message_ecran FROM dbo.acceptation_mission WHERE entite=? ORDER BY cree_le DESC",
                           (entite,),
                           f"Acceptation de {entite} reprise ; le questionnaire se complète à nouveau.")


# ----------------------------------------------------------------------------- l'arrete

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ouvrir_arrete(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                  entite: str = "", exerciceDebut: str = "", exerciceFin: str = "", periodiciteVl: str = "") -> str:
    """Bouton « Ouvrir l'arrêté » : planifie les arretes de l'exercice selon la periodicite, ouvre le
    premier. Dates au format jj/mm/aaaa ou aaaa-mm-jj.

    DES DATES ABSENTES SONT REFUSEES ICI : la procedure ne refuse pas un exercice sans bornes. Une periodicite
    absente part vide, et la procedure la refuse (50262). Quand le premier arrete ne s'ouvre pas, la procedure
    leve 50264 et annule tout, planification comprise : le refus s'affiche en rouge, l'utilisateur leve
    l'obstacle et reclique."""
    sql = "EXEC dbo.pr_ecran_ouvrir_arrete @entite=?, @exercice_debut=?, @exercice_fin=?, @periodicite_vl=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    if _vide(exerciceDebut) is None or _vide(exerciceFin) is None:
        _refuser(base, sql, "Saisissez le début et la fin de l'exercice, au format jj/mm/aaaa.", (entite,),
                 entite=entite)

    def d(s):
        s = s.strip()
        for f in ("%d/%m/%Y", "%Y-%m-%d"):
            try:
                return datetime.datetime.strptime(s, f).date()
            except ValueError:
                pass
        _refuser(base, sql, f"Date illisible : « {s} ». Attendu jj/mm/aaaa.", (entite,), entite=entite)
    r = _executer(base, sql, (entite, d(exerciceDebut), d(exerciceFin), (periodiciteVl or "").strip().upper(), par),
                  entite=entite)
    return r.get("message", "Arrêté planifié.")


# ----------------------------------------------------------------------------- rouvrir un arrete clos

# LA REOUVERTURE SE FAIT EN 2 GESTES ET PAR 2 PERSONNES AUTHENTIFIEES : un membre de l'equipe demande, avec son motif ;
# le chef de mission accorde, ou ecarte avec le sien. Une fonction par geste : un parametre de bouton se lie a un segment
# ou a une mesure, jamais a un litteral. Celui qui demande et celui qui decide sont l'utilisateur connecte (_qui), jamais
# un champ. L'arrete arrive par le segment « Arrêté clos », colonne [Arrêté] de v_ecran_arretes, en jj/mm/aaaa ; la base
# l'attend en aaaa-mm-jj. Chaque refus de la base remonte tel quel, dans l'ordre ou elle les juge : le droit, puis
# l'etat, puis la saisie.

_ARRETE_A_CHOISIR = "aucun arrêté choisi dans « Arrêté clos »."


def _arrete_iso(valeur):
    """L'arrete du segment, jj/mm/aaaa ou aaaa-mm-jj, en aaaa-mm-jj ; None s'il est vide ou illisible."""
    v = _vide(valeur)
    if v is None:
        return None
    for f in ("%d/%m/%Y", "%Y-%m-%d"):
        try:
            return datetime.datetime.strptime(v, f).date().isoformat()
        except ValueError:
            pass
    return None


def _arrete_choisi(base: fn.FabricSqlConnection, sql: str, valeur, prefixe: str, entite):
    """L'arrete choisi en aaaa-mm-jj, ou le refus en francais, sous le prefixe du geste."""
    a = _arrete_iso(valeur)
    if a is None:
        v = _vide(valeur)
        message = (f"{prefixe} : arrêté « {v} » illisible, attendu jj/mm/aaaa." if v else
                   f"{prefixe} : {_ARRETE_A_CHOISIR}")
        _refuser(base, sql, message, (entite,), entite=entite)
    return a


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def demander_reouverture(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                         entite: str = "", arrete: str = "", motif: str = "") -> str:
    """Bouton « Demander la réouverture » du sous-etat 5b : pr_ecran_demander_reouverture. L'auteur de la demande est
    l'utilisateur connecte. La base refuse un non-membre de l'equipe (50981), le chef de mission, qui decide (50982),
    un arrete non valide pour le client (50983), un arrete anterieur au dernier arrete clos (50984), une 2e demande en
    attente (50985) et un motif vide (50986)."""
    sql = "EXEC dbo.pr_ecran_demander_reouverture @entite=?, @arrete=?, @motif=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    a = _arrete_choisi(base, sql, arrete, "Demande refusée", entite)
    r = _executer(base, sql, (entite, a, _vide(motif), par), entite=entite)
    return r.get("message", "Réouverture demandée.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def accorder_reouverture(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                         entite: str = "", arrete: str = "") -> str:
    """Bouton « Rouvrir l'arrêté » du sous-etat 5b : pr_ecran_accorder_reouverture, qui accorde la demande en attente
    sur l'arrete par pr_rouvrir_arrete, dans une seule transaction. Celui qui decide est l'utilisateur connecte. Sans
    motif propre : le renvoi reprend celui de la demande. La base refuse qui ne decide pas les reouvertures (50987),
    l'absence de demande en attente (50988), l'auteur de la demande (50989), puis les refus de pr_rouvrir_arrete
    (50991 quand un arrete posterieur a ete clos pendant l'attente)."""
    sql = "EXEC dbo.pr_ecran_accorder_reouverture @entite=?, @arrete=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    a = _arrete_choisi(base, sql, arrete, "Décision refusée", entite)
    r = _executer(base, sql, (entite, a, par), entite=entite)
    return r.get("message", "Arrêté rouvert.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ecarter_reouverture(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                        entite: str = "", arrete: str = "", motifEcart: str = "") -> str:
    """Bouton « Écarter la demande » du sous-etat 5b : pr_ecran_ecarter_reouverture ; l'arrete reste clos. Celui qui
    decide est l'utilisateur connecte. La base refuse qui ne decide pas les reouvertures (50992), l'absence de demande
    en attente (50993), l'auteur de la demande (50994) et un motif d'ecart vide (50995)."""
    sql = "EXEC dbo.pr_ecran_ecarter_reouverture @entite=?, @arrete=?, @motif_ecart=?, @par=?"
    par = _qui(ctx)
    entite = _choix(base, sql, entite, _CLIENT_A_CHOISIR)
    a = _arrete_choisi(base, sql, arrete, "Écart refusé", entite)
    r = _executer(base, sql, (entite, a, _vide(motifEcart), par), entite=entite)
    return r.get("message", "Demande écartée.")


# ----------------------------------------------------------------------------- client accepte : le maintien

@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def ouvrir_maintien(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                    entite: str, arreteConclu: str) -> str:
    """Bouton « Ouvrir le maintien » sur la ligne d'un arrete conclu : la feuille et ses questions."""
    r = _executer(base, "EXEC dbo.pr_ouvrir_questionnaire_maintien @entite=?, @arrete_conclu=?, @par=?",
                  (entite, arreteConclu, _qui(ctx)))
    return r.get("message", "Maintien ouvert.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def approuver_maintien(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext,
                       entite: str, arreteConclu: str, decision: str, superviseur: str, motif: str = "") -> str:
    """Bouton « Viser le maintien » : decision MAINTENU ou ROMPU, par le superviseur."""
    sql = "EXEC dbo.pr_ecran_approuver_maintien @entite=?, @arrete_conclu=?, @decision=?, @motif=?, @par=?"
    par = _qui(ctx)
    _superviseur(base, ctx, sql, superviseur, entite)
    return _executer_ecran(base,
                           sql,
                           (entite, arreteConclu, decision, _vide(motif), par),
                           "SELECT TOP 1 message_ecran FROM dbo.maintien_mission WHERE entite=? AND arrete_conclu=? ORDER BY cree_le DESC",
                           (entite, arreteConclu),
                           f"Maintien {arreteConclu[:4]} de {entite} : décision {decision.lower()} visée.")


# ----------------------------------------------------------------------------- la voie du classeur

# Les 2 voies de l'ecran, a l'ecran ou par classeur, ecrivent au meme endroit. Un bouton de rapport ne lit
# pas de fichier : le classeur est depose dans SharePoint, sur le site du cabinet, dans le dossier du client
# de la bibliotheque « Dossiers de travail », et le coffre le lit par le raccourci de ce site. Le champ de
# l'ecran porte le NOM DU FICHIER, sous-dossier facultatif, comme « Rattacher la pièce » ; la fonction le
# resout dans le dossier du client, ou a la racine de « Dossiers de travail » quand l'appel ne porte pas de
# client (creation d'un dossier). La feuille dit la nature, la ligne 2 des en-tetes donne le parametre.
# Bibliotheque : openpyxl.

_FEUILLES = ("Client", "Filiales", "Questionnaire")

_ORDRE_CLIENT = ["code", "denomination", "siren", "forme_vehicule", "forme_sociale", "adresse_1", "adresse_2",
                 "code_postal", "ville", "pays", "dirigeant_nom", "dirigeant_qualite", "contact_nom",
                 "contact_courriel", "contact_telephone"]

_DOSSIERS = "Dossiers de travail"


def _lire_classeur(octets: bytes):
    import io
    from openpyxl import load_workbook
    wb = load_workbook(io.BytesIO(octets), data_only=True)
    # LA FEUILLE SE CHOISIT PAR SON NOM, et non parce qu'elle est active : un classeur enregistre sur sa
    # feuille « Aide » etait refuse comme « Feuille « Aide » inconnue ».
    ws = next((wb[n] for n in _FEUILLES if n in wb.sheetnames), wb.active)
    cles = [c.value for c in ws[2]]
    lignes = []
    for r in ws.iter_rows(min_row=3, values_only=True):
        if all(v is None or str(v).strip() == "" for v in r):
            continue
        d = {k: (None if v is None or str(v).strip() == "" else v) for k, v in zip(cles, r) if k}
        if d.get("code") is None and d.get("reference") is None:
            continue
        lignes.append(d)
    return ws.title, lignes


def _cote_maintien(base: fn.FabricSqlConnection, client: str) -> str:
    """La cote de maintien porte l'annee : on prend la feuille MAINTIEN la plus recente du client."""
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 cote FROM dbo.feuille_travail WHERE entite=? AND phase='MAINTIEN' ORDER BY arrete DESC",
                    (client,))
        ligne = cur.fetchone()
    finally:
        conn.close()
    if not ligne:
        _refuser(base, "EXEC dbo.importer_classeur", "Aucun questionnaire de maintien n'est ouvert pour ce client.",
                 (client,), entite=client)
    return ligne[0]


def _raccourci_du_cabinet(base: fn.FabricSqlConnection):
    """Le nom du raccourci du coffre qui lit le site du cabinet, tel que la base le declare, ou None."""
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT valeur FROM dbo.ref_parametre WHERE code = 'RACCOURCI_SITE_CABINET'")
        ligne = cur.fetchone()
    finally:
        conn.close()
    return (ligne[0] or "").strip().strip("/") if ligne else None


def _nom_de_fichier(nom, client=None):
    """Le nom saisi, nettoye comme le fait pr_resoudre_fichier_depot : barres obliques inverses converties,
    barres de tete retirees. Rend (nom, motif du refus ou None). Le refus nomme le dossier ou deposer."""
    f = (nom or "").strip().replace("\\", "/")
    while f.startswith("/"):
        f = f[1:].strip()
    if not f:
        if client:
            return f, ("Saisissez le nom du classeur déposé dans le dossier « %s/%s » du site du cabinet."
                       % (_DOSSIERS, client))
        return f, "Saisissez le nom du classeur Client déposé dans le dossier « %s » du site du cabinet." % _DOSSIERS
    if ".." in f or f.endswith("/"):
        return f, "Le nom du classeur ne peut ni remonter d'un dossier, ni finir par une barre."
    return f, None


# LE BILAN D'UN IMPORT SE LIT DANS LA ZONE DE MESSAGE, 2 lignes : chaque ligne refusee y est nommee, regroupee
# avec celles du meme motif court. Au-dela de 2 lignes, la zone coupe la fin par « … » ; le bilan entier est la
# valeur rendue par la fonction, et le motif complet de chaque ligne reste au journal des refus. Un refus sans
# motif court connu garde le texte de la base.
_MOTIFS_COURTS = {
    50210: "code absent",
    50211: "client inconnu",
    50212: "code égal à celui du client",
    50213: "droits de vote hors de 0 à 100 %",
    50214: "déjà au périmètre",
    50215: "dénomination absente pour une filiale nouvelle",
    50220: "classement R. 214-83 absent (oui ou non)",
}


def _pluriel(n, singulier, pluriel):
    return "%d %s" % (n, singulier if n <= 1 else pluriel)


def _liste(codes):
    """« A », « A et B », « A, B et C »."""
    return codes[0] if len(codes) == 1 else "%s et %s" % (", ".join(codes[:-1]), codes[-1])


def _refus_regroupes(refus):
    """Les lignes refusees regroupees par motif, dans l'ordre de leur 1re apparition : 12 lignes deja au perimetre
    se lisent « A, B, ... et L, déjà au périmètre », et le bilan tient dans la zone de message."""
    groupes, ordre = {}, []
    for code, motif in refus:
        if motif not in groupes:
            groupes[motif] = []
            ordre.append(motif)
        groupes[motif].append(code)
    return " ; ".join("%s, %s" % (_liste(groupes[m]), m) for m in ordre)


@udf.context(argName="ctx")
@udf.connection(alias="Coffre", argName="coffre")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def importer_classeur(base: fn.FabricSqlConnection, coffre: fn.FabricLakehouseClient,
                      ctx: fn.UserDataFunctionContext, chemin: str = "", client: str = "") -> str:
    """Bouton « Réimporter » : le classeur Client, Filiales ou Questionnaire, depose dans SharePoint et lu par le
    raccourci du coffre, entre par les memes procedures que la saisie a l'ecran.

    « chemin » porte le NOM DU FICHIER tel que depose, sous-dossier facultatif ; le nom du parametre reste
    « chemin » parce que les boutons le lient sous ce nom. Il se resout dans « Dossiers de travail/<client> »
    du site du cabinet, ou dans « Dossiers de travail » quand l'appel ne porte pas de client.

    LE CLASSEUR DES FILIALES S'IMPORTE LIGNE A LIGNE : chaque ligne passe par pr_ajouter_filiale, comme un
    ajout a l'ecran, et une ligne refusee n'arrete pas les suivantes. Le bilan, ajouts et refus en francais,
    s'affiche dans la zone de message de l'ecran ; un refus partiel s'y affiche en refus."""
    import json
    par = _qui(ctx)
    client = _vide(client)
    sql_import = "EXEC dbo.importer_classeur"
    fichier, motif = _nom_de_fichier(chemin, client)
    if motif:
        _refuser(base, sql_import, motif, (client,), entite=client)
    raccourci = _raccourci_du_cabinet(base)
    if not raccourci:
        _refuser(base, sql_import, "Le site du cabinet n'est pas relié au coffre : l'import par classeur est "
                 "indisponible.", (client,), entite=client)
    dossier = _DOSSIERS + ("/" + client if client else "")
    try:
        octets = coffre.connectToFiles().get_file_client(
            "%s/%s/%s" % (raccourci, dossier, fichier)).download_file().readall()
    except Exception:
        _refuser(base, sql_import,
                 "Le classeur « %s » n'est pas dans le dossier « %s » du site du cabinet : déposez-le, puis "
                 "saisissez son nom." % (fichier, dossier), (client,), entite=client)
    try:
        feuille, lignes = _lire_classeur(octets)
    except Exception:
        _refuser(base, sql_import, "Le fichier « %s » n'est pas un classeur Excel lisible." % fichier,
                 (client,), entite=client)
    if feuille == "Client":
        if len(lignes) != 1:
            _refuser(base, sql_import, "Le classeur Client porte %d ligne(s) ; il en porte une et une seule."
                     % len(lignes), (client,), entite=client)
        d = lignes[0]
        r = _executer(base,
                      "EXEC dbo.pr_creer_client " + ", ".join("@%s=?" % k for k in _ORDRE_CLIENT) + ", @par=?",
                      tuple(str(d.get(k)) if d.get(k) is not None else None for k in _ORDRE_CLIENT) + (par,))
        return r.get("message", "Client créé.")
    if feuille not in _FEUILLES:
        _refuser(base, sql_import, "Feuille « %s » inconnue : Client, Filiales ou Questionnaire." % feuille,
                 (client,), entite=client)
    if not client:
        _refuser(base, sql_import, "Le classeur %s s'importe sur un client : sélectionnez-le." % feuille, (None,),
                 entite=None)
    if feuille == "Filiales":
        sql = ("EXEC dbo.pr_ajouter_filiale @client=?, @code=?, @denomination=?, @droits_de_vote=?, "
               "@par=?, @controlee=?")
        faites, refus = [], []
        for d in lignes:
            code = str(d.get("code"))
            motif, court = None, None
            try:
                classement = _classement(d.get("controlee"))
            except ValueError as e:
                motif = _CLASSEMENT_ILLISIBLE % e
                court = "classement « %s » non reconnu (oui ou non)" % e
            if motif is None:
                try:
                    dv = float(str(d.get("droits_de_vote")).replace(",", ".").replace("%", "").strip())
                    dv = dv / 100.0 if dv > 1 else dv
                except (TypeError, ValueError):
                    motif = court = "droits de vote illisibles"
            if motif is not None:
                # UN REFUS DE LA FONCTION SE JOURNALISE COMME UN REFUS DE LA BASE, avant tout appel
                conn = base.connect()
                try:
                    _journaliser_refus(conn, sql, motif, (client, code), entite=client)
                finally:
                    conn.close()
                refus.append((code, court))
                continue
            try:
                _executer(base, sql, (client, code, d.get("denomination"), round(dv, 6), par, classement),
                          entite=client)
                faites.append(code)
            except fn.UserThrownError as e:
                refus.append((code, _MOTIFS_COURTS.get(getattr(e, "numero", None)) or _texte(e)))
        texte = "%s à %s" % (_pluriel(len(faites), "filiale ajoutée", "filiales ajoutées"), client)
        if refus:
            texte += ", %s : %s." % (_pluriel(len(refus), "ligne refusée", "lignes refusées"),
                                     _refus_regroupes(refus))
        else:
            texte += "."
        # LE BILAN REMPLACE LE MESSAGE DE LA DERNIERE LIGNE : sans lui, la zone de message montrait le seul
        # geste de la derniere ligne traitee.
        conn = base.connect()
        try:
            _poser_message(conn, sql, texte, (client,), "REFUS" if refus else "SUCCES", entite=client)
        finally:
            conn.close()
        return texte
    reponses = [{"reference": d.get("reference"), "reponse": None if d.get("reponse") is None else str(d.get("reponse")),
                 "motif": d.get("motif"), "commentaire": d.get("commentaire")} for d in lignes if d.get("reference")]
    maintien = any(str(x["reference"]).startswith("MTN") or str(x["reference"]).startswith("MAINTIEN") for x in reponses)
    cote = _cote_maintien(base, client) if maintien else "ACC-" + client
    r = _executer(base, "EXEC dbo.pr_importer_reponses @cote=?, @reponses=?, @par=?",
                  (cote, json.dumps(reponses, ensure_ascii=False, default=str), par))
    return r.get("message", "Réponses importées.")


@udf.context(argName="ctx")
@udf.connection(alias="DossierOPCI", argName="base")
@udf.function()
def exporter_questionnaire(base: fn.FabricSqlConnection, ctx: fn.UserDataFunctionContext, cote: str = "") -> str:
    """Bouton « Exporter le questionnaire » : le classeur des questions de la feuille, reponses comprises, depose
    dans SharePoint, site du cabinet, « Dossiers de travail/<client>/<arrete> », la ou « Réimporter » le lit par son
    nom ; l'arrete est celui auquel la feuille est adossee.

    LE DEPOT PASSE PAR LA BASE, pr_deposer_classeur, qui appelle le service de depot du cabinet : une fonction n'a
    pas d'identite a elle pour ecrire dans SharePoint, et le coffre ne lit SharePoint que par un raccourci."""
    import base64
    import io
    from openpyxl import Workbook
    from openpyxl.styles import Font, PatternFill
    sql = "EXEC dbo.pr_deposer_classeur @entite=?, @arrete=?, @fichier=?, @contenu_base64=?, @par=?"
    par = _qui(ctx)
    client = _entite_de_cote(base, cote)
    cote = _choix(base, sql, cote, "Aucun questionnaire d'acceptation n'est ouvert pour ce client.", client)
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT TOP 1 entite, arrete FROM dbo.feuille_travail WHERE cote = ?", (cote,))
        feuille = cur.fetchone()
    finally:
        conn.close()
    if not feuille or not feuille[1]:
        _refuser(base, sql, "Le questionnaire %s n'est adossé à aucun arrêté : il ne se dépose pas." % cote, (client,),
                 entite=client)
    client, arrete = feuille[0], str(feuille[1])
    conn = base.connect()
    try:
        cur = conn.cursor()
        cur.execute("SELECT q.section, q.reference, q.enonce, q.type_reponse, q.obligatoire, "
                    "COALESCE(fq.reponse, fq.reponse_valeur), fq.motif_non_applicable, fq.commentaire, q.doc_attendu "
                    "FROM dbo.feuille_question fq JOIN dbo.ref_question q ON q.id = fq.question_id "
                    "WHERE fq.cote = ? ORDER BY q.ordre", (cote,))
        lignes = cur.fetchall()
    finally:
        conn.close()
    if not lignes:
        _refuser(base, sql, "Le questionnaire %s ne porte aucune question." % cote, (client,), entite=client)
    wb = Workbook()
    ws = wb.active
    ws.title = "Questionnaire"
    entetes = [("Section", "section"), ("Référence", "reference"), ("Question", "enonce"), ("Type", "type"),
               ("Obligatoire", "obligatoire"), ("Réponse", "reponse"), ("Motif si non applicable", "motif"),
               ("Commentaire", "commentaire"), ("Pièce attendue", "doc_attendu")]
    for j, (lib, cle) in enumerate(entetes, 1):
        c = ws.cell(row=1, column=j, value=lib)
        c.fill = PatternFill("solid", fgColor="1D1A10")
        c.font = Font(bold=True, color="FFFFFF") if cle in ("reponse", "motif", "commentaire") else Font(color="D9D2C0")
        ws.cell(row=2, column=j, value=cle).font = Font(italic=True, color="8A8578", size=9)
    for i, l in enumerate(lignes, 3):
        for j, v in enumerate(l, 1):
            ws.cell(row=i, column=j, value=("oui" if v else "non") if j == 5 else v)
    ws.freeze_panes = "A3"
    tampon = io.BytesIO()
    wb.save(tampon)
    fichier = "%s.xlsx" % cote
    r = _executer(base, sql, (client, arrete, fichier, base64.b64encode(tampon.getvalue()).decode("ascii"), par),
                  entite=client)
    texte = ("Questionnaire %s exporté, %d questions, dans « %s/%s/%s » du site du cabinet. Pour le réimporter, "
             "saisissez %s/%s." % (cote, len(lignes), _DOSSIERS, client, arrete, arrete, fichier))
    conn = base.connect()
    try:
        _poser_message(conn, sql, texte, (client,), "SUCCES", entite=client)
    finally:
        conn.close()
    return texte + (" " + r["web_url"] if r.get("web_url") else "")
