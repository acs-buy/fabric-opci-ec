# -*- coding: utf-8 -*-
"""Provisionnement de l'espace collaboratif d'un client OPCI : groupe Microsoft 365, site
SharePoint (automatique avec le groupe) et equipe Teams, par Microsoft Graph, sous l'identite
managee de la Function App. Aucun secret : les roles d'application Graph sont affectes a
l'identite managee (Group.Create, Group.ReadWrite.All, Team.Create, User.Read.All,
User.Invite.All, Sites.ReadWrite.All).

Appelee par la base SQL Fabric (sp_invoke_external_rest_endpoint, depuis la procedure du bouton
PowerTable) avec un JSON :
  {"entite": "OMEGA-SCI-11", "denomination": "SCI Omega 11", "proprietaires": ["upn", ...],
   "membres": ["upn", ...], "invites": ["adresse@client.fr", ...], "equipe": true}
Rend toujours un JSON, statut FAIT, PARTIEL ou ERREUR, avec le detail de chaque etape, pour que
la procedure l'ecrive dans la demande et que le reviseur le lise a l'ecran.

Idempotente : un groupe dont le mailNickname existe deja est repris, jamais recree.
Documentation de l'editeur suivie : create group (groupTypes Unified, mailEnabled, securityEnabled
false, owners@odata.bind), create team from group (404 possible moins de 15 min apres la creation
du groupe, reessai), sites/root du groupe, invitations.
"""
import json
import logging
import re
import time
import unicodedata

import azure.functions as func
import requests
from azure.identity import ManagedIdentityCredential

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

GRAPH = "https://graph.microsoft.com/v1.0"
PREFIXE_GROUPE = "OPCI - "

# LES 4 BIBLIOTHEQUES DE CHAQUE ESPACE CLIENT.
# Adaptez ces noms a l'organisation de votre cabinet : ils n'ont aucun effet technique.
BIBLIOTHEQUES = ["Dépôt du client", "Dossier permanent", "Dossier annuel", "Livrables"]


def roles_du_jeton(jeton: str):
    """Les roles d'application que porte le jeton, lus dans sa charge utile.

    POURQUOI, 23/09/2026. Sites.Manage.All a ete affectee a 10 h 37, et le 403 s'est reproduit.
    Cela ne prouve rien : « the back-end services for managed identities maintain a cache per
    resource URI for around 24 hours » et « it isn't possible to force a managed identity's
    token to be refreshed before its expiry », page managed-identities-faq. Sans lire la
    revendication, un rejeu n'est interpretable ni en succes ni en echec.

    ON NE DIVULGUE QUE LES ROLES. Le jeton n'est ni journalise, ni rendu, ni colle nulle part :
    le decodage est local, et seule la liste des roles sort.
    """
    import base64
    try:
        charge = jeton.split(".")[1]
        charge += "=" * (-len(charge) % 4)
        return json.loads(base64.urlsafe_b64decode(charge)).get("roles", [])
    except Exception:
        return None


def jeton_graph() -> str:
    return ManagedIdentityCredential().get_token("https://graph.microsoft.com/.default").token


def slug(texte: str) -> str:
    """mailNickname : lettres, chiffres et tirets, sans accent, 64 caracteres au plus."""
    t = unicodedata.normalize("NFKD", texte).encode("ascii", "ignore").decode("ascii")
    t = re.sub(r"[^A-Za-z0-9-]+", "-", t).strip("-").lower()
    return ("opci-" + t)[:64]


class Graph:
    def __init__(self, jeton: str):
        self.s = requests.Session()
        self.s.headers.update({"Authorization": "Bearer " + jeton, "Content-Type": "application/json"})

    def get(self, chemin, **kw):
        return self.s.get(GRAPH + chemin, timeout=30, **kw)

    def post(self, chemin, corps):
        return self.s.post(GRAPH + chemin, json=corps, timeout=60)

    def put(self, chemin, corps):
        return self.s.put(GRAPH + chemin, json=corps, timeout=60)

    def id_utilisateur(self, upn: str):
        r = self.get(f"/users/{upn}?$select=id")
        return r.json().get("id") if r.status_code == 200 else None

    def groupe_par_nickname(self, nick: str):
        r = self.get("/groups", params={"$filter": f"mailNickname eq '{nick}'", "$select": "id,displayName,mailNickname"})
        v = r.json().get("value", []) if r.status_code == 200 else []
        return v[0] if v else None

    def creer_groupe(self, nom: str, nick: str, proprietaires: list, membres: list):
        corps = {
            "displayName": nom,
            "description": f"Espace collaboratif du dossier {nom}, cree par la solution.",
            "groupTypes": ["Unified"],
            "mailEnabled": True,
            "mailNickname": nick,
            "securityEnabled": False,
            "visibility": "Private",
        }
        if proprietaires:
            corps["owners@odata.bind"] = [f"{GRAPH}/users/{i}" for i in proprietaires]
        if membres:
            corps["members@odata.bind"] = [f"{GRAPH}/users/{i}" for i in membres]
        r = self.post("/groups", corps)
        if r.status_code not in (200, 201):
            raise RuntimeError(f"creation du groupe refusee : {r.status_code} {r.text[:300]}")
        return r.json()

    def creer_equipe(self, groupe_id: str, essais: int = 6, attente: int = 10):
        """POST /teams depuis le groupe ; 404 tant que le groupe n'est pas replique (jusqu'a 15 min)."""
        corps = {
            "template@odata.bind": f"{GRAPH}/teamsTemplates('standard')",
            "group@odata.bind": f"{GRAPH}/groups('{groupe_id}')",
        }
        dernier = None
        for _ in range(essais):
            r = self.post("/teams", corps)
            if r.status_code in (201, 202):
                return {"statut": "CREEE" if r.status_code == 201 else "EN_COURS",
                        "operation": r.headers.get("Location")}
            if r.status_code == 409:
                return {"statut": "EXISTAIT"}
            dernier = f"{r.status_code} {r.text[:200]}"
            if r.status_code != 404:
                break
            time.sleep(attente)
        return {"statut": "A_REESSAYER", "message": dernier}

    def site_du_groupe(self, groupe_id: str, essais: int = 4, attente: int = 5):
        for _ in range(essais):
            r = self.get(f"/groups/{groupe_id}/sites/root?$select=id,webUrl")
            if r.status_code == 200:
                return r.json()
            time.sleep(attente)
        return None

    def inviter(self, adresse: str, redirection: str):
        r = self.post("/invitations", {"invitedUserEmailAddress": adresse,
                                       "inviteRedirectUrl": redirection or "https://myapps.microsoft.com",
                                       "sendInvitationMessage": True})
        if r.status_code not in (200, 201):
            return {"adresse": adresse, "statut": "ERREUR", "message": r.text[:200]}
        return {"adresse": adresse, "statut": "INVITE", "id": r.json().get("invitedUser", {}).get("id")}

    def ajouter_membre(self, groupe_id: str, utilisateur_id: str):
        r = self.post(f"/groups/{groupe_id}/members/$ref", {"@odata.id": f"{GRAPH}/directoryObjects/{utilisateur_id}"})
        return r.status_code in (204, 400)  # 400 : deja membre

    def retirer_membre(self, groupe_id: str, utilisateur_id: str):
        """Le retrait d'un role de mission retire du groupe : l'acces suit la mission."""
        r = self.s.delete(f"{GRAPH}/groups/{groupe_id}/members/{utilisateur_id}/$ref", timeout=60)
        return r.status_code in (204, 404)  # 404 : n'etait pas membre

    def bibliotheques(self, site_id: str):
        """Les listes du site, indexees par displayName ET par name, en suivant la PAGINATION.

        DEUX PIEGES, releves le 23/09/2026 sur la documentation de l'editeur.

        1. LA PAGINATION NE S'IGNORE PAS. « To read all results, you must continue to call
           Microsoft Graph with the @odata.nextLink property returned in each response until
           the @odata.nextLink property is no longer returned », page graph/paging. Une
           bibliotheque situee en 2e page serait declaree absente, et le provisionnement
           cesserait d'etre rejouable. La page suivante s'appelle TELLE QUELLE : la meme page
           interdit d'en extraire $skiptoken pour reconstruire l'URL.
        2. $top N'EST PAS DOCUMENTE sur cette route, et la page graph/known-issues pose que
           « Query parameters specified in a request might fail silently ». Un $top non honore
           ne se detecte pas. Il est donc retire, et seule la pagination fait foi.

        ON INDEXE LES 2 NOMS parce que displayName est MODIFIABLE, « The displayable title of
        the list », quand name est « Read-only » et fige a la creation, page resources/list. Un
        reviseur qui renomme « Livrables » en « Livrables 2026 » ferait recreer la bibliotheque
        et le site en porterait 2 pour un meme role.
        """
        noms, url = {}, f"/sites/{site_id}/lists?$select=id,name,displayName,list"
        while url:
            r = self.s.get(url if url.startswith("http") else GRAPH + url, timeout=30)
            if r.status_code != 200:
                return None
            d = r.json()
            for l in d.get("value", []):
                for cle in (l.get("displayName"), l.get("name")):
                    if cle:
                        noms[cle] = l.get("id")
            url = d.get("@odata.nextLink")
        return noms

    def creer_bibliotheque(self, site_id: str, nom: str):
        """Une bibliotheque de documents, POST /sites/{id}/lists avec le gabarit documentLibrary.

        LA FORME EST LUE, PAS DEVINEE : page graph/api/list-create, « If the list facet or
        template is unspecified, the list defaults to the genericList template », et la valeur
        « documentLibrary » est la premiere de l'enumeration de resources/listinfo.

        LA PERMISSION EST DEJA LA : Sites.ReadWrite.All est affectee a l'identite managee depuis
        le 07/09/2026, relevee le 23/09 par appRoleAssignments. Sites.Manage.All serait le
        moindre privilege, mais l'ajouter SANS RETIRER l'autre n'allegerait rien.

        AUCUN CODE D'ERREUR N'EST SUPPOSE. La page list-create ne documente QUE le 201 et ne
        porte aucune table d'erreurs : rien n'atteste qu'un nom deja pris rende 409 plutot que
        400. Sur tout retour non 2xx, on RELIT donc les listes du site et on conclut sur ce
        qu'elles portent, jamais sur le code seul.
        """
        r = self.post(f"/sites/{site_id}/lists",
                      {"displayName": nom, "list": {"template": "documentLibrary"}})
        if r.status_code in (200, 201):
            return {"nom": nom, "statut": "CREEE", "id": r.json().get("id")}
        code, texte = r.status_code, r.text[:200]
        apres = self.bibliotheques(site_id)
        if apres and nom in apres:
            return {"nom": nom, "statut": "EXISTAIT", "id": apres[nom], "code_refus": code}
        return {"nom": nom, "statut": "ERREUR", "message": f"{code} {texte}"}


@app.route(route="provisionner_espace", methods=["POST"])
def provisionner_espace(req: func.HttpRequest) -> func.HttpResponse:
    etapes, statut = [], "FAIT"
    try:
        d = req.get_json()
        entite = d["entite"]
        nom = PREFIXE_GROUPE + d.get("denomination", entite)
        nick = slug(entite)
        jeton = jeton_graph()
        g = Graph(jeton)
        # CE QUE LE JETON PORTE VRAIMENT, et non ce que appRoleAssignments promet : les 2
        # divergent tant que le cache de 24 heures n'a pas tourne.
        etapes.append({"etape": "roles_du_jeton", "roles": roles_du_jeton(jeton)})

        proprietaires = [i for i in (g.id_utilisateur(u) for u in d.get("proprietaires", [])) if i]
        membres = [i for i in (g.id_utilisateur(u) for u in d.get("membres", [])) if i]
        if not proprietaires:
            raise RuntimeError("aucun proprietaire resolu : une equipe exige au moins 1 proprietaire reel")

        groupe = g.groupe_par_nickname(nick)
        if groupe:
            etapes.append({"etape": "groupe", "statut": "EXISTAIT", "id": groupe["id"]})
        else:
            groupe = g.creer_groupe(nom, nick, proprietaires, membres)
            etapes.append({"etape": "groupe", "statut": "CREE", "id": groupe["id"]})

        site = g.site_du_groupe(groupe["id"])
        site_url = site["webUrl"] if site else None
        etapes.append({"etape": "site", "statut": "PRET" if site else "EN_COURS", "url": site_url})
        if not site:
            statut = "PARTIEL"

        if d.get("equipe", True):
            equipe = g.creer_equipe(groupe["id"])
            etapes.append({"etape": "equipe", **equipe})
            if equipe["statut"] == "A_REESSAYER":
                statut = "PARTIEL"

        # LES 4 BIBLIOTHEQUES DU CLIENT :
        # « un espace central pour le cabinet, un espace par client, et dans chacun les memes
        # 4 bibliotheques, depot du client, dossier permanent, dossier annuel et livrables ».
        # Elles se creent ICI et non par une route a part : rester dans provisionner_espace
        # evite une route nouvelle, donc une DATABASE SCOPED CREDENTIAL nouvelle,
        # sp_invoke_external_rest_endpoint appariant la credential a l'URL par son nom.
        if site and d.get("bibliotheques", True):
            faites, presentes = [], g.bibliotheques(site["id"])
            if presentes is None:
                etapes.append({"etape": "bibliotheques", "statut": "ERREUR",
                               "message": "le site ne rend pas ses listes"})
                statut = "PARTIEL"
            else:
                for nom in d.get("noms_bibliotheques", BIBLIOTHEQUES):
                    if nom in presentes:
                        faites.append({"nom": nom, "statut": "EXISTAIT"})
                        continue
                    faites.append(g.creer_bibliotheque(site["id"], nom))
                etapes.append({"etape": "bibliotheques", "detail": faites})
                if any(f["statut"] == "ERREUR" for f in faites):
                    statut = "PARTIEL"
        elif not site:
            # SANS SITE, PAS DE BIBLIOTHEQUE : le site d'un groupe neuf met quelques secondes a
            # naitre, et site_du_groupe rend None quand il n'est pas encore la. On ne cree rien
            # a l'aveugle, la procedure appelante rappellera.
            etapes.append({"etape": "bibliotheques", "statut": "REPORTEE",
                           "message": "le site n'est pas encore pret"})

        invites = []
        for adresse in d.get("invites", []):
            inv = g.inviter(adresse, site_url)
            if inv.get("id"):
                inv["membre"] = g.ajouter_membre(groupe["id"], inv["id"])
            invites.append(inv)
        if invites:
            etapes.append({"etape": "invites", "detail": invites})

        corps = {"statut": statut, "entite": entite, "groupe_id": groupe["id"], "mail_nickname": nick,
                 "site_url": site_url, "etapes": etapes}
    except Exception as e:  # la procedure appelante lit le statut et le message
        logging.exception("provisionnement en echec")
        corps = {"statut": "ERREUR", "message": str(e)[:1500], "etapes": etapes}
    return func.HttpResponse(json.dumps(corps, ensure_ascii=False), mimetype="application/json", status_code=200)
