
-- 4. LES MONTANTS DE L'ANNEXE. Par vehicule et arrete de mission, chaque ligne en N (colonne 1) et N-1 (colonne 2),
-- la saisie prevalant ; les colonnes 3 a 7 viennent de la saisie. Une ligne de formule se calcule colonne par
-- colonne sur ses composantes, et rend NULL des qu'une composante manque.
CREATE   VIEW dbo.v_ligne_annexe_racine AS
WITH solde AS (
    SELECT lo.entite, lo.arrete, e.compte_num,
           SUM(CASE WHEN lo.feuille_cote LIKE 'AFF-%' THEN 0 ELSE e.debit - e.credit END) AS solde_hors_aff,
           SUM(e.debit - e.credit) AS solde
    FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
    WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY lo.entite, lo.arrete, e.compte_num
),
compte_ligne AS (
    SELECT DISTINCT l.article, l.code, l.sens, s.entite, s.arrete, s.compte_num,
           CASE WHEN s.compte_num LIKE '[67]%' THEN s.solde_hors_aff ELSE s.solde END AS solde
    FROM dbo.ref_ligne_annexe l
    CROSS APPLY STRING_SPLIT(CASE WHEN l.formule_calcul LIKE 'REPARTI:%' THEN SUBSTRING(l.formule_calcul, 9, 400) ELSE l.racines END, ',') r
    JOIN solde s ON s.compte_num LIKE LTRIM(RTRIM(r.value)) + '%'
    WHERE (l.racines IS NOT NULL OR l.formule_calcul LIKE 'REPARTI:%')
      AND (l.racines_exclues IS NULL
           OR NOT EXISTS (SELECT 1 FROM STRING_SPLIT(l.racines_exclues, ',') x WHERE s.compte_num LIKE LTRIM(RTRIM(x.value)) + '%'))
)
SELECT article, code, entite, arrete,
       CAST(SUM(CASE WHEN sens = 'DEBIT' THEN solde ELSE -solde END) AS DECIMAL (19, 2)) AS montant
FROM compte_ligne GROUP BY article, code, entite, arrete;

GO

