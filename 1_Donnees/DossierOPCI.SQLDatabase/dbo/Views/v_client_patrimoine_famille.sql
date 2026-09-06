
-- --- 3 : le patrimoine, par famille et par actif -------------------------
CREATE   VIEW dbo.v_client_patrimoine_famille AS
SELECT s.entite + '|' + s.arrete AS cle_arrete, s.entite, s.arrete,
       s.famille,
       CASE s.famille WHEN 'IMMEUBLE'       THEN N'Immeubles en direct'
                      WHEN 'TITRE'          THEN N'Titres de filiales'
                      WHEN 'COMPTE_COURANT' THEN N'Avances en compte courant'
                      WHEN 'INSTRUMENT'     THEN N'Instruments financiers'
                      ELSE s.famille END    AS famille_libelle,
       CASE s.famille WHEN 'IMMEUBLE' THEN 1 WHEN 'TITRE' THEN 2
                      WHEN 'COMPTE_COURANT' THEN 3 ELSE 4 END AS ordre,
       s.article, s.citation_courte,
       s.nombre_actifs, s.valeur_comptable, s.valeur_actuelle, s.difference_estimation
FROM dbo.v_differences_synthese s
JOIN dbo.ref_arrete r ON r.entite = s.entite AND r.arrete = s.arrete
WHERE r.porte_balance = 1;

GO

