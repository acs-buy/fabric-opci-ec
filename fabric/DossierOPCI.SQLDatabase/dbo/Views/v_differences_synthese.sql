
CREATE VIEW dbo.v_differences_synthese AS
SELECT p.entite, p.arrete, p.exercice, p.famille,
       /* 09/09/2026 : le libelle d'ecran, joint depuis v_famille_actif. La colonne famille reste
          le code, elle sert de cle dans 6 objets dont 2 controles. */
       MIN(f.libelle)                                       AS famille_libelle,
       MIN(f.libelle_court)                                 AS famille_libelle_court,
       MIN(f.ordre)                                         AS famille_ordre,
       MIN(p.article)                                       AS article,
       MIN(p.norme)                                         AS norme,
       MIN(p.citation_courte)                               AS citation_courte,
       COUNT(*)                                             AS nombre_actifs,
       CAST(SUM(p.valeur_comptable) AS DECIMAL (19,2))       AS valeur_comptable,
       CAST(SUM(p.valeur_actuelle) AS DECIMAL (19,2))        AS valeur_actuelle,
       CAST(SUM(p.difference_estimation) AS DECIMAL (19,2))
           AS difference_estimation,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       (SELECT TOP (1) s.message_ecran FROM dbo.synthese_proposee s
        WHERE s.entite = p.entite AND s.arrete = p.arrete ORDER BY s.id DESC) AS message_ecran
FROM dbo.v_patrimoine_valorise p
LEFT JOIN dbo.v_famille_actif f ON f.famille = p.famille
GROUP BY p.entite, p.arrete, p.exercice, p.famille;

GO

