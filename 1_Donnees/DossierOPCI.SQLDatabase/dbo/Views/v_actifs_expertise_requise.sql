CREATE   VIEW dbo.v_actifs_expertise_requise AS
SELECT a.code AS code_actif, a.entite_detentrice AS entite, a.nature,
       n.libelle AS nature_libelle, n.methode,
       rf.norme, rf.reference, rf.citation_courte,
       r.arrete, r.date_arrete, r.nature_technique,
       CAST(n.expertise_requise AS BIT)                   AS valeur_externe_attendue,
       -- L'exigence d'un rapport d'evaluateur ne vient pas du reglement
       -- comptable mais de l'article L. 214-55 du code monetaire et
       -- financier : la colonne le nomme.
       (SELECT citation_courte FROM dbo.v_reference
        WHERE norme = 'CMF' AND reference = 'L214-55')     AS fondement_evaluateur,
       CAST(CASE WHEN ex.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
           AS rapport_depose,
       CAST(CASE WHEN p.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
           AS rapport_au_coffre,
       ex.date_valeur AS date_rapport, ex.expert,
       CAST(CASE WHEN ev.id IS NOT NULL THEN 1 ELSE 0 END AS BIT)
           AS valeur_retenue_saisie
FROM dbo.actif a
JOIN dbo.ref_nature_actif n ON n.nature = a.nature
LEFT JOIN dbo.v_reference rf ON rf.id = n.reference_id
JOIN dbo.ref_arrete r ON r.entite = a.entite_detentrice AND r.porte_balance = 1
                     AND r.nature_technique <> 'HORS_MISSION'
OUTER APPLY (
    SELECT TOP (1) e.id, e.date_valeur, e.expert, e.piece_id
    FROM dbo.expertise e
    WHERE e.code_actif = a.code AND e.date_valeur <= r.date_arrete
    ORDER BY e.date_valeur DESC
) AS ex
LEFT JOIN dbo.piece p ON p.id = ex.piece_id
LEFT JOIN dbo.evaluation_actif ev ON ev.code_actif = a.code
                                 AND ev.entite = r.entite AND ev.arrete = r.arrete
WHERE a.date_acquisition IS NULL OR a.date_acquisition <= r.date_arrete;

GO

