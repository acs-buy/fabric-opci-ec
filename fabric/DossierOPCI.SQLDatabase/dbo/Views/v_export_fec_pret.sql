
-- --- 2 : ce que l'export porterait, avant de l'ecrire ------------------
-- ATTENDU : total debit egal au total credit, et zero compte sans
-- traduction dans le plan de l'entite.
CREATE   VIEW dbo.v_export_fec_pret AS
SELECT entite, arrete,
       CASE WHEN famille = 'IMPORTEE' THEN 'FISCAL' ELSE 'INTEROP' END AS pour_profil,
       COUNT(*) AS lignes,
       CAST(SUM(debit) AS DECIMAL (19,2))  AS total_debit,
       CAST(SUM(credit) AS DECIMAL (19,2)) AS total_credit,
       SUM(CASE WHEN compte_fichier IS NULL THEN 1 ELSE 0 END) AS comptes_sans_traduction
FROM dbo.v_fec_a_exporter
GROUP BY entite, arrete, CASE WHEN famille = 'IMPORTEE' THEN 'FISCAL' ELSE 'INTEROP' END;

GO

