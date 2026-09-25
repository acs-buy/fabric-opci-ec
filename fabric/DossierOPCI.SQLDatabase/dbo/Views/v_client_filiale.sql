
-- --- 4 : les participations, filiale par filiale ------------------------
CREATE   VIEW dbo.v_client_filiale AS
SELECT t.entite_mere + '|' + t.arrete AS cle_arrete,
       t.entite_mere AS entite, t.arrete,
       t.entite_fille, e.denomination AS filiale,
       f.capitaux_propres_comptables, f.differences_d_estimation, f.actif_net_reevalue,
       t.quote_part,
       t.valeur_actuelle_titres, t.valeur_comptable_titres AS cout_des_titres,
       t.difference_estimation_titres,
       t.valeur_comptable_compte_courant,
       CAST(CASE WHEN t.difference_estimation_titres < 0 THEN 1 ELSE 0 END AS BIT)
                                       AS moins_value_latente
FROM dbo.v_titres_valeur_actuelle t
JOIN dbo.v_anr_filiale f ON f.entite = t.entite_fille AND f.arrete = t.arrete
JOIN dbo.ref_entite e ON e.code = t.entite_fille
JOIN dbo.ref_arrete r ON r.entite = t.entite_mere AND r.arrete = t.arrete
WHERE r.porte_balance = 1;

GO

