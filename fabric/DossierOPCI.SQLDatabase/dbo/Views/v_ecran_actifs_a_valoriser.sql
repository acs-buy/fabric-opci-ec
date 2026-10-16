
CREATE   VIEW dbo.v_ecran_actifs_a_valoriser AS
-- liste = 'INSTRUMENT' : comptes 3 du vehicule et de ses filiales ; liste = 'TITRE_COTE' : comptes 256 et 258 du vehicule.
SELECT pv.vehicule, pv.arrete, a.entite_detentrice AS entite, a.code AS code_actif, a.nature, a.poste_bilan,
       CAST(CASE WHEN LEFT(a.poste_bilan, 1) = '3' THEN 'INSTRUMENT' ELSE 'TITRE_COTE' END AS VARCHAR (12)) AS liste,
       CAST(CASE WHEN LEFT(a.poste_bilan, 1) = '3'
                 THEN CASE WHEN EXISTS (SELECT 1 FROM dbo.valeur_instrument v WHERE v.code_actif = a.code AND v.entite = a.entite_detentrice AND v.arrete = pv.arrete) THEN 1 ELSE 0 END
                 ELSE CASE WHEN EXISTS (SELECT 1 FROM dbo.cours_titre c WHERE c.code_actif = a.code AND c.entite = a.entite_detentrice AND c.arrete = pv.arrete) THEN 1 ELSE 0 END
            END AS BIT) AS valeur_saisie,
       pv.vehicule + '|' + a.code + '|' + pv.arrete AS cle_ecran
FROM dbo.v_perimetre_vehicule pv
JOIN dbo.ref_arrete r ON r.entite = pv.entite AND r.arrete = pv.arrete AND r.porte_balance = 1
JOIN dbo.actif a ON a.entite_detentrice = pv.entite
WHERE LEFT(a.poste_bilan, 1) = '3'
   OR (LEFT(a.poste_bilan, 3) IN ('256', '258') AND pv.entite = pv.vehicule);

GO

