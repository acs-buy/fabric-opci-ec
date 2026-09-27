#!/usr/bin/env bash
# Affecte a l'identite managee de VOTRE Function App les roles d'application Microsoft Graph.
#
# POURQUOI CE SCRIPT EXISTE, ET POURQUOI VOUS NE POUVEZ PAS LE REMPLACER PAR UN CLIC.
#   Une permission d'application ne s'affecte pas au portail Entra pour une identite managee.
#   La documentation de l'editeur l'ecrit ainsi : « Currently, there's no option to assign such
#   permissions through the Microsoft Entra admin center. » Elle s'affecte par Azure CLI ou
#   PowerShell, et c'est tout.
#
# CE QU'IL VOUS FAUT POUR LE JOUER
#   Un role Entra Administrateur general ou Administrateur de role privilegie. Sans l'un des deux,
#   chaque affectation rend un refus, et aucun message ne vous dira qu'il s'agit de votre role.
#
# LES DEUX VALEURS A RENSEIGNER, ET OU LES TROUVER
#   MI       l'identifiant d'objet de l'identite managee de votre Function App.
#            az functionapp identity show -n <votre-function-app> -g <votre-groupe> --query principalId -o tsv
#   GRAPH_SP l'identifiant du principal de service de Microsoft Graph DANS VOTRE LOCATAIRE.
#            Il differe d'un locataire a l'autre : ne recopiez pas celui d'un autre cabinet.
#            az ad sp show --id 00000003-0000-0000-c000-000000000000 --query id -o tsv
#
# LES IDENTIFIANTS DE ROLES, EUX, SONT LES MEMES PARTOUT : ils appartiennent a l'application
# Microsoft Graph, qui est la meme pour tout le monde. Ils ont ete relus le 08/09/2026.

MI=""          # A RENSEIGNER
GRAPH_SP=""    # A RENSEIGNER

if [ -z "$MI" ] || [ -z "$GRAPH_SP" ]; then
  echo "Renseignez MI et GRAPH_SP en tete de ce script. Les 2 commandes az sont en commentaire."
  exit 1
fi

# Chaque role porte ici ce qu'il autorise, pour que vous puissiez en retirer sans deviner.
declare -A ROLES=(
  [Group.Create]=bf7b1a76-6e77-406b-b258-bf5c7720e98f          # creer le groupe Microsoft 365
  [Group.ReadWrite.All]=62a82d76-70ea-41e2-9197-370581804d09   # relire et completer le groupe cree
  [Team.Create]=23fc2474-f741-46ce-8465-674744c5c361           # creer l'equipe Teams sur le groupe
  [User.Read.All]=df021288-bdef-4463-88db-98f22de89214         # resoudre les proprietaires par leur adresse
  [User.Invite.All]=09850681-111b-4a89-9bed-3f2cae46d706       # inviter les personnes du client
  [Sites.ReadWrite.All]=9492366f-7969-46a4-8d15-ed1a20078fff   # creer les bibliotheques du site
  [Directory.Read.All]=7ab1d382-f21e-4acd-a863-ba3e13f7da61    # lire l'annuaire pour ces resolutions
)

for nom in "${!ROLES[@]}"; do
  id=${ROLES[$nom]}
  out=$(az rest --method POST \
    --url "https://graph.microsoft.com/v1.0/servicePrincipals/$MI/appRoleAssignments" \
    --headers "Content-Type=application/json" \
    --body "{\"principalId\":\"$MI\",\"resourceId\":\"$GRAPH_SP\",\"appRoleId\":\"$id\"}" \
    --query "appRoleId" -o tsv 2>&1)
  case "$out" in
    "$id") echo "$nom affecte" ;;
    *Permission_ScopeAlreadyExists*|*already*) echo "$nom deja affecte" ;;
    *) echo "$nom ECHEC : ${out:0:160}" ;;
  esac
done

echo "--- relecture : 7 identifiants attendus"
az rest --method GET \
  --url "https://graph.microsoft.com/v1.0/servicePrincipals/$MI/appRoleAssignments?\$select=appRoleId,resourceDisplayName" \
  -o tsv --query "value[].appRoleId" 2>&1 | tr '\n' ' '
echo

# APRES CE SCRIPT, ATTENDEZ AVANT DE CONCLURE.
# Le jeton Graph d'une identite managee est mis en cache environ 24 heures par ressource, et le
# rafraichissement ne se force pas. Un refus dans l'heure qui suit une affectation ne prouve donc
# rien. Mesure le 23/09/2026 : une permission affectee a 10 h 37 ne s'appliquait pas encore
# l'heure suivante.
