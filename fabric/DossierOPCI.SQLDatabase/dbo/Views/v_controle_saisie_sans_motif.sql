
-- C87 : une saisie qui exige un motif et n'en porte pas. ATTENDU zero.
CREATE   VIEW dbo.v_controle_saisie_sans_motif AS
SELECT s.id, s.entite, s.arrete, s.article, s.ligne, s.colonne,
       s.valeur, s.montant, s.saisi_par, s.saisi_le,
       N'cette saisie recouvre une valeur que la base calcule, ou porte sur un exercice antérieur à la reprise du dossier, et aucun motif ne dit pourquoi'
                                                   AS lecture
FROM dbo.saisie_annexe s
WHERE s.motif IS NULL
  AND dbo.fn_cellule_exige_motif(s.entite, s.arrete, s.article, s.ligne, s.colonne) = 1;

GO

