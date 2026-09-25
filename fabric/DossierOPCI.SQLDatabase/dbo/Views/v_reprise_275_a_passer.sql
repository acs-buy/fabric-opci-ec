
-- --- depuis 63_SQL/127_valeur_historique_des_filiales.sql : v_reprise_275_a_passer ---
-- --- 3 : la reprise du compte 275 de la mere ------------------------
-- CE QUE LA PROCEDURE FAIT, ET CE QU'ELLE NE FAIT PAS. Elle rapproche le
-- compte 275 de la mere de la valeur que les actifs nets de ses filiales
-- justifient, a la quote-part, et passe l'ecart. Elle ne touche a aucune
-- filiale. Le mode a blanc est le defaut, pour la meme raison qu'au
-- script 126 : cette ecriture deplace l'actif net de l'OPCI, donc la
-- valeur liquidative.
CREATE   VIEW dbo.v_reprise_275_a_passer AS
WITH theorique AS (
    -- LA DETENTION SE LIT A SON ARRETE. Une jointure qui l'oublie
    -- multiplie les lignes par le nombre d'arretes : mesure le
    -- 05/09/2026, elle rendait 119 954 370,86 de titres pour 12
    -- filiales, soit plus de 2 fois leur actif net cumule.
    -- L'ACTIF NET REEVALUE, NON L'ACTIF NET COMPTABLE. Les filiales
    -- etant tenues en valeur historique, dbo.v_anr_entite ne rend pour
    -- elles que leurs capitaux propres comptables : s'en servir pour
    -- valoriser les titres reviendrait a ignorer la reevaluation, et le
    -- compte 275 de la mere paraitrait excedentaire de 8 413 426,70.
    -- C'est dbo.v_anr_filiale qui porte l'actif net REEVALUE, avec les
    -- differences d'estimation que les valeurs actuelles justifient.
    SELECT d.entite_mere, d.arrete,
           SUM(CAST(f.actif_net_reevalue * d.quote_part AS DECIMAL (19,2)))
                                                   AS valeur_actuelle_titres,
           SUM(CAST(f.capitaux_propres_comptables * d.quote_part
                    AS DECIMAL (19,2)))            AS quote_part_capitaux
    FROM dbo.detention d
    JOIN dbo.v_anr_filiale f ON f.entite = d.entite_fille
                            AND f.arrete = d.arrete
    GROUP BY d.entite_mere, d.arrete
),
comptabilise AS (
    SELECT l.entite, l.arrete,
           SUM(CASE WHEN e.compte_num LIKE '254%' AND l.famille <> 'DERIVABLE'
                    THEN e.debit - e.credit ELSE 0 END) AS titres_254,
           SUM(CASE WHEN e.compte_num LIKE '275%' AND l.famille = 'DERIVABLE'
                    THEN e.debit - e.credit ELSE 0 END) AS ecart_275
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY l.entite, l.arrete
)
SELECT t.entite_mere AS entite, t.arrete,
       t.valeur_actuelle_titres,
       c.titres_254, c.ecart_275,
       CAST(t.valeur_actuelle_titres - c.titres_254 AS DECIMAL (19,2))
                                                   AS ecart_275_cible,
       CAST(t.valeur_actuelle_titres - c.titres_254 - c.ecart_275
            AS DECIMAL (19,2))                     AS a_passer,
       CASE WHEN ABS(t.valeur_actuelle_titres - c.titres_254 - c.ecart_275) < 0.005
            THEN N'le compte 275 égale déjà la valeur que les actifs nets des filiales justifient'
            WHEN t.valeur_actuelle_titres - c.titres_254 - c.ecart_275 > 0
            THEN N'le compte 275 est insuffisant : la valeur des titres a monté'
            ELSE N'le compte 275 est excédentaire : la valeur des titres a baissé'
            END                                    AS lecture
FROM theorique t
JOIN comptabilise c ON c.entite = t.entite_mere AND c.arrete = t.arrete;

GO

