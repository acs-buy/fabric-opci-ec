
-- --- depuis 63_SQL/114_annexe_capitaux_propres.sql : v_ligne_annexe_montant ------
-- --- 2 : le montant de chaque ligne d'annexe ------------------------
-- Meme charpente que dbo.v_ligne_etat_montant du script 112 : les 2
-- sommes sont calculees dans l'APPLY et le sens choisit laquelle, SQL
-- Server refusant un agregat qui mele une reference externe et des
-- colonnes internes.
CREATE   VIEW dbo.v_ligne_annexe_montant AS
SELECT l.article, l.code, l.libelle, l.niveau, l.type_ligne, l.signe,
       l.ordre, l.renvoi, l.formule,
       t.libelle                                     AS tableau,
       r.entite, r.arrete,
       CAST(CASE WHEN l.sens = 'DEBIT' THEN COALESCE(n.solde_debit, 0)
                 ELSE COALESCE(n.solde_credit, 0) END AS DECIMAL (19,2))
                                                     AS exercice_n,
       CAST(CASE WHEN l.sens = 'DEBIT' THEN COALESCE(p.solde_debit, 0)
                 ELSE COALESCE(p.solde_credit, 0) END AS DECIMAL (19,2))
                                                     AS exercice_n_1,
       -- La saisie, quand la ligne n'est pas calculable.
       s.valeur                                      AS valeur_saisie,
       s.montant                                     AS montant_saisi,
       CAST(CASE WHEN l.type_ligne = 'SAISIE' AND s.id IS NULL
                 THEN 1 ELSE 0 END AS BIT)           AS a_saisir
FROM dbo.ref_ligne_annexe l
JOIN dbo.ref_tableau_annexe t ON t.article = l.article
CROSS JOIN (SELECT entite, arrete,
                   (SELECT MAX(x.arrete) FROM dbo.ref_arrete x
                    WHERE x.entite = ref_arrete.entite
                      AND x.porte_balance = 1
                      AND x.arrete < ref_arrete.arrete) AS arrete_precedent
            FROM dbo.ref_arrete
            WHERE nature_technique = 'MISSION') AS r
OUTER APPLY (
    SELECT SUM(e.debit - e.credit) AS solde_debit,
           SUM(e.credit - e.debit) AS solde_credit
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.entite = r.entite AND lo.arrete = r.arrete
      AND lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.racines IS NOT NULL
      AND EXISTS (SELECT 1 FROM STRING_SPLIT(l.racines, ',') x
                  WHERE e.compte_num LIKE x.value + '%')
      AND (l.racines_exclues IS NULL
           OR NOT EXISTS (SELECT 1
                          FROM STRING_SPLIT(l.racines_exclues, ',') y
                          WHERE e.compte_num LIKE y.value + '%'))
) AS n
OUTER APPLY (
    SELECT SUM(e.debit - e.credit) AS solde_debit,
           SUM(e.credit - e.debit) AS solde_credit
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.entite = r.entite AND lo.arrete = r.arrete_precedent
      AND lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.racines IS NOT NULL
      AND EXISTS (SELECT 1 FROM STRING_SPLIT(l.racines, ',') x
                  WHERE e.compte_num LIKE x.value + '%')
      AND (l.racines_exclues IS NULL
           OR NOT EXISTS (SELECT 1
                          FROM STRING_SPLIT(l.racines_exclues, ',') y
                          WHERE e.compte_num LIKE y.value + '%'))
) AS p
OUTER APPLY (
    SELECT TOP 1 sa.id, sa.valeur, sa.montant FROM dbo.saisie_annexe sa
    WHERE sa.entite = r.entite AND sa.arrete = r.arrete
      AND sa.article = l.article AND sa.ligne = l.code
) AS s;

GO

