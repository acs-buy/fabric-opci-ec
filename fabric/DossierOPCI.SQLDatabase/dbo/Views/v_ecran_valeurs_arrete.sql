
-- ------------------------------------------------------------------ n° 15 : les valeurs de l'arrete
-- Une ligne par actif a valeur saisie (familles IMMEUBLE et INSTRUMENT) du vehicule et de ses filiales, a l'arrete.
-- Dates tronquees a la seconde. ordre_entite : rang de v_ordre_entite (filiales par numero, vehicule en dernier, D6).
CREATE   VIEW dbo.v_ecran_valeurs_arrete AS
SELECT pv.vehicule, g.arrete, g.entite,
       CAST(CASE WHEN g.entite <> pv.vehicule THEN 1 ELSE 0 END AS BIT)            AS est_filiale,
       g.famille, g.code_actif, g.nature, a.poste_bilan,
       CAST(CASE WHEN CHARINDEX(N',', a.adresse) > 0
                 THEN LTRIM(RIGHT(a.adresse, CHARINDEX(N',', REVERSE(a.adresse)) - 1)) ELSE a.adresse END AS NVARCHAR (200)) AS ville,
       a.prix_de_revient, g.valeur_comptable,
       ex.id                                                                         AS expertise_id,
       ex.valeur_actuelle                                                            AS valeur_expertise,
       ex.date_valeur                                                                AS date_expertise,
       ex.piece_id                                                                   AS rapport_id,
       pc.nom_fichier                                                                AS rapport_nom,
       pc.web_url                                                                    AS rapport_web_url,
       CAST(CASE WHEN ex.id IS NULL THEN NULL
                 WHEN EXISTS (SELECT 1 FROM dbo.v_expertise_sans_rapport s WHERE s.expertise_id = ex.id) THEN 0 ELSE 1 END AS BIT) AS rapport_rattache,
       CAST(ev.id AS NVARCHAR (12))                                                  AS evaluation_id,
       ev.valeur_retenue                                                             AS valeur_proposee,
       ev.etat                                                                       AS etat_valeur,
       CAST(CASE ev.etat WHEN 'PROPOSE' THEN N'proposée' WHEN 'VISE' THEN N'visée' WHEN 'RENVOYE' THEN N'renvoyée' END AS NVARCHAR (12)) AS etat_valeur_libelle,
       ev.propose_par                                                                AS proposee_par,
       CAST(ev.propose_le AS DATETIME2 (0))                                          AS proposee_le,
       g.valeur_actuelle, g.difference_estimation, g.source,
       sv.libelle                                                                    AS source_libelle,
       CAST(CASE WHEN g.entite = pv.vehicule THEN 1 ELSE COALESCE(dt.quote_part, pg.quote_part) END AS DECIMAL (12,6)) AS quote_part,
       CAST(g.difference_estimation * CASE WHEN g.entite = pv.vehicule THEN 1 ELSE COALESCE(dt.quote_part, pg.quote_part) END AS DECIMAL (19,2)) AS difference_quote_part,
       g.etat_generation,
       CAST(CASE g.etat_generation WHEN 'CALCULABLE' THEN CASE WHEN g.famille = 'IMMEUBLE' AND g.entite <> pv.vehicule THEN N'dans l’ANR' ELSE N'calculable' END WHEN 'SANS_VALEUR' THEN N'sans valeur'
                 WHEN 'RAPPORT_NON_RATTACHE' THEN N'rapport non rattaché' WHEN 'VALEUR_RENVOYEE' THEN N'valeur renvoyée'
                 WHEN 'VALEUR_NON_VISEE' THEN N'valeur à viser' END AS NVARCHAR (30)) AS etat,
       g.motif_blocage,
       o.ordre                                                                       AS ordre_entite,
       pv.vehicule + '|' + g.entite + '|' + g.code_actif + '|' + g.arrete            AS cle_ecran
FROM dbo.v_a_generer g
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = g.entite AND pv.arrete = g.arrete
JOIN dbo.actif a ON a.code = g.code_actif
JOIN dbo.ref_arrete r ON r.entite = g.entite AND r.arrete = g.arrete
LEFT JOIN dbo.v_perimetre_groupe pg ON pg.vehicule = pv.vehicule AND pg.entite = g.entite
-- 14/10/2026 : la part du capital detenue, celle de la cascade de l'actif net reevalue ; les droits de vote a defaut
LEFT JOIN dbo.detention dt ON dt.entite_mere = pv.vehicule AND dt.entite_fille = g.entite AND dt.arrete = g.arrete
LEFT JOIN dbo.ref_source_valeur sv ON sv.source = g.source
LEFT JOIN dbo.v_ordre_entite o ON o.entite = g.entite
LEFT JOIN dbo.evaluation_actif ev ON ev.code_actif = g.code_actif AND ev.entite = g.entite AND ev.arrete = g.arrete
OUTER APPLY (SELECT TOP (1) e.id, e.valeur_actuelle, e.date_valeur, e.piece_id FROM dbo.expertise e
             WHERE e.code_actif = g.code_actif AND e.date_valeur <= r.date_arrete ORDER BY e.date_valeur DESC) ex
LEFT JOIN dbo.piece pc ON pc.id = ex.piece_id
WHERE g.famille IN ('IMMEUBLE', 'INSTRUMENT');

GO

