
-- --- 6 : la rationalisation d'un arrete vide -----------------------------
CREATE   VIEW dbo.v_controle_rationalisation AS
SELECT o.entite, o.arrete, o.actif_net_precedent, o.actif_net_rationalise,
       o.actif_net_calcule,
       o.actif_net_rationalise - o.actif_net_calcule AS ecart,
       CAST(CASE WHEN ISNULL(p.ecritures, 0) = 0 THEN 1
                 WHEN ABS(o.actif_net_rationalise - o.actif_net_calcule) <= 1000
                 THEN 1 ELSE 0 END AS BIT)       AS boucle,
       CASE WHEN ISNULL(p.ecritures, 0) = 0
            THEN N'aucune ecriture sur l''arrete : rien a rationaliser, l''ecart est l''actif net precedent'
            WHEN o.arrete_precedent IS NULL
            THEN N'premier arrete de l''entite : la rationalisation part de zero et ne boucle pas par construction'
            WHEN ABS(o.actif_net_rationalise - o.actif_net_calcule) <= 1000
            THEN N'la rationalisation boucle au seuil de 1 000,00'
            ELSE N'la rationalisation ne boucle pas : un poste manque ou un montant est mal qualifie'
            END                                  AS lecture,
       N'Seuil de 1 000,00 arrete par le candidat le 04/09/2026, non prescrit par le reglement'
                                                 AS source_du_seuil
FROM dbo.v_rationalisation_opci o
LEFT JOIN dbo.v_perimetre_arrete p ON p.entite = o.entite AND p.arrete = o.arrete;

GO

