
-- --- 6 : B16, la concordance des 2 modes -------------------------------
-- Deux intentions sur le meme compte et le meme arrete, l'une par ligne
-- et l'autre par solde cible, concordent si leur montant resolu et leur
-- sens resolu sont egaux. La vue apparie par compte, la preuve se lit.
CREATE   VIEW dbo.v_concordance_modes AS
SELECT
    l.entite, l.arrete, l.compte_num,
    l.id AS intention_par_ligne, c.id AS intention_solde_cible,
    l.montant_resolu AS montant_par_ligne,
    c.montant_resolu AS montant_solde_cible,
    l.sens_resolu    AS sens_par_ligne,
    c.sens_resolu    AS sens_solde_cible,
    CAST(l.montant_resolu - c.montant_resolu AS DECIMAL (19,2)) AS ecart_montant,
    CASE WHEN l.montant_resolu = c.montant_resolu
              AND l.sens_resolu = c.sens_resolu
         THEN 'CONCORDANT' ELSE 'DIVERGENT' END AS verdict
FROM dbo.v_intention_resolue l
JOIN dbo.v_intention_resolue c
  ON c.entite = l.entite AND c.arrete = l.arrete
 AND c.compte_num = l.compte_num
WHERE l.mode = 'PAR_LIGNE' AND c.mode = 'SOLDE_CIBLE';

GO

