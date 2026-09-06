-- =====================================================================
-- LES VUES LISENT LE REFERENTIEL, et cessent de porter des numeros
-- d'article en litteral.
--
-- CE QUI ETAIT EN DUR AVANT CE SCRIPT. dbo.v_patrimoine_valorise ecrivait
-- '212-4' pour les titres et '213-4' pour les comptes courants dans son
-- SELECT ; dbo.v_nature_compte_estimation lisait la colonne article de
-- 2 tables. Un numero rectifie dans dbo.ref_reference ne changeait donc
-- rien a l'ecran.
--
-- CE QUE LES VUES RENDENT DESORMAIS. Trois colonnes au lieu d'une :
--   reference        le numero seul, pour un tri ou un filtre
--   citation_courte  « Reglement ANC 2020-07, article 212-4 », telle
--                    qu'un rapport doit l'ecrire
--   norme            le code du texte, pour joindre dbo.ref_norme
-- La colonne article est conservee, pour que rien de ce qui la lisait ne
-- casse, mais elle est desormais alimentee par le referentiel.
--
-- L'EPREUVE DE LA PROPAGATION est au bloc 7 : elle change un intitule
-- dans dbo.ref_norme, relit 3 vues, constate que les 3 ont suivi, puis
-- remet l'intitule d'origine.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : la reference d'un poste de bilan, pour le niveau 2 ----------
-- Elle remplace les litteraux de dbo.v_patrimoine_valorise. La regle est
-- celle du plan de comptes, deja portee par
-- dbo.fn_compte_difference_estimation : la famille d'un actif determine
-- l'article qui l'evalue.
CREATE   FUNCTION dbo.fn_reference_evaluation
    (@nature VARCHAR (40))
RETURNS INT
AS
BEGIN
    RETURN (SELECT n.reference_id FROM dbo.ref_nature_actif n
            WHERE n.nature = @nature);
END

GO

