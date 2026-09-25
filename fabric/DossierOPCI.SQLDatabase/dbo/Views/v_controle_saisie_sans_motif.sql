
-- C87 : une saisie qui recouvre une valeur calculee sans dire pourquoi.
-- La ligne d'annexe est de type CALCUL : la base sait donc produire le
-- montant, et une saisie manuelle s'ecarte de ce que le calcul rend.
CREATE   VIEW dbo.v_controle_saisie_sans_motif AS
SELECT s.id, s.entite, s.arrete, s.article, s.ligne, s.colonne,
       s.valeur, s.montant, s.saisi_par, s.saisi_le,
       N'cette saisie recouvre une ligne que la base sait calculer, et aucun motif ne dit pourquoi : le motif est exigé dès lors qu''une valeur calculée existe'
                                                   AS lecture
FROM dbo.saisie_annexe s
JOIN dbo.ref_ligne_annexe l ON l.article = s.article AND l.code = s.ligne
WHERE l.type_ligne = 'CALCUL'
  AND s.motif IS NULL;

GO

