
-- --- 4 : ce qui est generable, et ce qui bloque ----------------------
-- Une ligne par actif du perimetre, avec son etat : CALCULABLE, ou
-- bloque avec le motif. C'est l'ecran E3-A avant la generation.
CREATE   VIEW dbo.v_a_generer AS
SELECT p.entite, p.arrete, p.exercice, p.code_actif, p.nature, p.famille,
       p.valeur_comptable, p.valeur_actuelle, p.difference_estimation,
       p.source, p.citation_courte,
       -- L'etat, dans l'ordre de priorite des blocages.
       CASE WHEN p.valeur_actuelle IS NULL THEN 'SANS_VALEUR'
            WHEN p.source = 'EXPERTISE' AND ex.piece_id IS NULL
                 THEN 'RAPPORT_NON_RATTACHE'
            WHEN ev.id IS NOT NULL AND ev.etat = 'RENVOYE'
                 THEN 'VALEUR_RENVOYEE'
            WHEN ev.id IS NOT NULL AND ev.etat = 'PROPOSE'
                 THEN 'VALEUR_NON_VISEE'
            ELSE 'CALCULABLE' END                     AS etat_generation,
       CASE WHEN p.valeur_actuelle IS NULL
                 THEN N'Aucune valeur actuelle a cet arrete.'
            WHEN p.source = 'EXPERTISE' AND ex.piece_id IS NULL
                 THEN N'La valeur vient d''une expertise dont le rapport n''est pas rattache au coffre.'
            WHEN ev.id IS NOT NULL AND ev.etat = 'RENVOYE'
                 THEN N'La valeur retenue a ete renvoyee par le chef de mission : la reprendre avant de generer.'
            WHEN ev.id IS NOT NULL AND ev.etat = 'PROPOSE'
                 THEN N'La valeur retenue attend le visa du chef de mission.'
       END                                            AS motif_blocage,
       ex.date_valeur                                 AS date_expertise,
       ex.enregistre_le                               AS expertise_enregistree_le,
       ev.etat                                        AS etat_valeur_retenue
FROM dbo.v_patrimoine_valorise p
OUTER APPLY (
    SELECT TOP (1) e.piece_id, e.date_valeur, e.enregistre_le
    FROM dbo.expertise e
    JOIN dbo.ref_arrete r ON r.entite = p.entite AND r.arrete = p.arrete
    WHERE e.code_actif = p.code_actif AND e.date_valeur <= r.date_arrete
    ORDER BY e.date_valeur DESC
) AS ex
LEFT JOIN dbo.evaluation_actif ev ON ev.code_actif = p.code_actif
                                 AND ev.entite = p.entite AND ev.arrete = p.arrete;

GO

