-- =====================================================================
-- LA PUBLICATION AU CLIENT : LA PORTE EST DANS LA DONNEE.
--
-- LA REGLE, ARRETEE PAR LE CANDIDAT LE 06/09/2026. Rien ne remonte dans
-- le rapport client avant que le chef de mission ait vise la cloture de
-- l'etape 5, nature CLOTURE, decision VISE. Ce visa existe deja :
-- pr_cloturer_etape_5, script 109, l'exige apres la valeur liquidative
-- publiee, les categories visees et le document produit ; pr_rouvrir_arrete,
-- script 113, le RENVOIE quand l'arrete est rouvert. La dimension d'arrete
-- du modele client, v_arrete_client, ne porte donc plus que les arretes
-- dont le DERNIER visa de cloture est VISE : toutes les tables clientes en
-- dependent, script 141, et un arrete rouvert disparait du rapport sans
-- qu'aucun visuel n'ait a le savoir.
--
-- POURQUOI LA PORTE EST ICI ET NON DANS LE RAPPORT. Un filtre de rapport
-- se contourne par un autre rapport sur le meme modele ; une vue ne se
-- contourne pas. Et la regle vaut quel que soit le mode de stockage, requete
-- directe ou import.
--
-- LA PUBLICATION EST UN ACTE TRACE. Le modele client passe en import : le
-- client lit la photographie prise a la publication, non la base vivante.
-- Le rafraichissement est fait par un pipeline Fabric qui lit
-- v_publication_client_a_faire, rafraichit le modele, puis appelle
-- pr_marquer_publication_client. La table publication_client garde qui,
-- quand, sur quel visa ; le bandeau du rapport l'affiche.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : le dernier visa de cloture de chaque arrete --------------------
CREATE   VIEW dbo.v_visa_cloture_courant AS
WITH dernier AS (
    SELECT v.entite, v.arrete, v.id, v.decision, v.decide_par, v.decide_le,
           ROW_NUMBER() OVER (PARTITION BY v.entite, v.arrete ORDER BY v.id DESC) AS rang
    FROM dbo.visa v
    WHERE v.nature = 'CLOTURE'
)
SELECT entite, arrete, id AS visa_id, decision, decide_par, decide_le
FROM dernier
WHERE rang = 1;

GO

