
-- --- depuis 63_SQL/112_etats_financiers_modeles.sql : v_ligne_etat_montant -------
-- --- 2 : le montant de chaque ligne, par entite et arrete -----------
-- Le sens de la ligne decide du signe : une ligne d'actif ou de charge
-- se lit au debit, une ligne de passif ou de produit au credit. La
-- valeur est celle des lots valides, l'arrete precedent servant la
-- colonne N-1 que les 3 modeles portent.
CREATE   VIEW dbo.v_ligne_etat_montant AS
SELECT l.etat, l.code, l.libelle, l.type_ligne, l.romain, l.ordre,
       l.article, l.renvoi,
       r.entite, r.arrete,
       -- LE SENS S'APPLIQUE HORS DE L'AGREGAT. SQL Server refuse un
       -- agregat qui mele une reference externe, l.sens, et des colonnes
       -- internes, e.debit et e.credit : erreur 8124, mesuree le
       -- 05/09/2026. Les 2 sommes sont donc calculees dans l'APPLY et le
       -- sens choisit laquelle ici.
       CAST(CASE WHEN l.sens = 'DEBIT' THEN COALESCE(n.solde_debit, 0)
                 ELSE COALESCE(n.solde_credit, 0) END AS DECIMAL (19,2))
                                                          AS exercice_n,
       CAST(CASE WHEN l.sens = 'DEBIT' THEN COALESCE(p.solde_debit, 0)
                 ELSE COALESCE(p.solde_credit, 0) END AS DECIMAL (19,2))
                                                          AS exercice_n_1,
       -- « Le cas echeant les lignes a 0 peuvent etre supprimees »,
       -- article 321-2. La regle est PERMISSIVE : la vue rend toutes les
       -- lignes et dit lesquelles l'ecran peut masquer.
       CAST(CASE WHEN COALESCE(n.solde_debit, 0) = 0
                  AND COALESCE(n.solde_credit, 0) = 0
                  AND COALESCE(p.solde_debit, 0) = 0
                  AND COALESCE(p.solde_credit, 0) = 0
                  AND l.type_ligne = 'DETAIL'
                 THEN 1 ELSE 0 END AS BIT)                AS supprimable,
       l.racines, l.formule
FROM dbo.ref_ligne_etat l
CROSS JOIN (SELECT entite, arrete,
                   (SELECT MAX(x.arrete) FROM dbo.ref_arrete x
                    WHERE x.entite = ref_arrete.entite
                      AND x.porte_balance = 1
                      AND x.arrete < ref_arrete.arrete) AS arrete_precedent
            FROM dbo.ref_arrete WHERE porte_balance = 1) AS r
OUTER APPLY (
    SELECT SUM(e.debit - e.credit) AS solde_debit,
           SUM(e.credit - e.debit) AS solde_credit
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.entite = r.entite AND lo.arrete = r.arrete
      AND lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.racines IS NOT NULL
      AND EXISTS (SELECT 1 FROM STRING_SPLIT(l.racines, ',') s
                  WHERE e.compte_num LIKE s.value + '%')
) AS n
OUTER APPLY (
    SELECT SUM(e.debit - e.credit) AS solde_debit,
           SUM(e.credit - e.debit) AS solde_credit
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.entite = r.entite AND lo.arrete = r.arrete_precedent
      AND lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.racines IS NOT NULL
      AND EXISTS (SELECT 1 FROM STRING_SPLIT(l.racines, ',') s
                  WHERE e.compte_num LIKE s.value + '%')
) AS p;

GO

