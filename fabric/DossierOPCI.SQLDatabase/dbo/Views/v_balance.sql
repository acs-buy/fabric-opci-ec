-- =====================================================================
-- LA REPRISE SUR LE SOCLE : LES DEFINITIONS QUI LISENT
-- v_ecriture_normalisee OU fn_compte_du_modele, REGROUPEES APRES LE 131.
--
-- POURQUOI CE SCRIPT EXISTE. Le chantier des 05 et 06/09/2026 a porte
-- 26 objets sur le socle de normalisation, en editant chaque definition
-- dans son script d'origine, du 08 au 127. Sur la base en etat, chaque lot
-- s'est mesure a 0 ecart. Mais le socle n'existe qu'au 131 : un rejeu
-- depuis une base purgee s'arretait au 08, « Cannot find ...
-- dbo.fn_compte_du_modele ». Le defaut a ete revele par le rejeu complet
-- du 06/09/2026, le premier depuis ce chantier.
--
-- CE QUE CE SCRIPT FAIT. Il porte la definition courante de chacun de
-- ces objets ; leur script d'origine a repris sa definition d'avant la
-- reprise, celle que la base portait quand la sequence a ete jouee le
-- 04/09/2026. Le dernier defini gagne : l'etat final est celui d'avant,
-- seul l'ordre de construction est devenu jouable. Les scripts 132 a 139
-- qui redefinissent certains de ces objets viennent apres et gagnent
-- toujours.
--
-- CE QU'IL NE FAIT PAS. Il ne fige rien et ne touche a aucune donnee :
-- les 377 grandeurs figees au 131 se comparent apres lui par
-- v_ecart_de_reprise, et doivent rester a 0 ecart.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- depuis 63_SQL/08_classe9_et_colonnes_balance.sql : v_balance ----------------
-- --- B3 : la vue de balance, avec ses 10 colonnes ---------------------
CREATE   VIEW dbo.v_balance AS
SELECT
    l.arrete,
    l.entite,
    e.compte_num                                     AS compte,
    -- LE COMPTE DU MODELE, EN PLUS ET NON A LA PLACE. Une balance
    -- est le document de son entite : elle porte le compte tel que
    -- l'entite le tient. La colonne suivante permet d'agreger les
    -- entites entre elles sans deformer ce qui est remis au client.
    dbo.fn_compte_du_modele(l.entite, e.compte_num) AS compte_modele,
    MAX(COALESCE(c.libelle_complet, c.libelle))      AS libelle,
    MAX(CAST(c.porte_actif AS INT))                  AS porte_actif,

    SUM(CASE WHEN l.famille = 'IMPORTEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS b0_initiale,

    SUM(CASE WHEN l.famille = 'DECIDEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_revision,

    SUM(CASE WHEN l.famille = 'DERIVABLE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS od_valorisation,

    SUM(CASE WHEN l.famille = 'IMPORTEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)
  + SUM(CASE WHEN l.famille = 'DECIDEE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)
  + SUM(CASE WHEN l.famille = 'DERIVABLE'
                  AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
             THEN e.debit - e.credit ELSE 0 END)      AS balance_finale,

    MAX(x.xref)                                      AS xref,
    MAX(COALESCE(x.etat, 'A_FAIRE'))                 AS etat,
    MAX(x.par)                                       AS par,
    MAX(x.date_etat)                                 AS date_etat
FROM ecriture e
JOIN lot_ecritures l ON l.id = e.lot_id
JOIN ref_compte    c ON c.compte = e.compte_num
LEFT JOIN ref_croisee x ON x.arrete = l.arrete
                       AND x.entite = l.entite
                       AND x.compte_num = e.compte_num
GROUP BY l.arrete, l.entite, e.compte_num;

GO

