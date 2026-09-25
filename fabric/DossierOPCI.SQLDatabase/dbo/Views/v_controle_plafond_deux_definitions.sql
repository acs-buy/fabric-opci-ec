
-- Le rapprochement des 2 definitions. Il n'est PAS attendu a zero : il
-- mesure l'ecart entre la vue du script 52 et celle du texte, et sert a
-- trancher laquelle les ecrans doivent lire.
CREATE   VIEW dbo.v_controle_plafond_deux_definitions AS
SELECT t.entite, t.arrete,
       p.plafond_distribuable              AS definition_script_52,
       t.total_distribuable                AS definition_du_texte,
       t.total_distribuable - COALESCE(p.plafond_distribuable, 0) AS ecart,
       CASE WHEN p.entite IS NULL
            THEN N'la vue du script 52 ne rend rien pour cet arrêté'
            WHEN ABS(t.total_distribuable
                     - p.plafond_distribuable) < 0.005
            THEN N'les 2 définitions concordent'
            ELSE N'les 2 définitions divergent : la définition du texte, article L. 214-69, doit prévaloir'
            END                            AS lecture
FROM dbo.v_sommes_distribuables t
LEFT JOIN dbo.v_plafond_distribuable p ON p.entite = t.entite
                                      AND p.arrete = t.arrete;

GO

