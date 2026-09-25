CREATE   VIEW dbo.v_ctx_avancement_1ligne AS
SELECT MAX(t.entite) + N'|' + CONVERT(nvarchar(10), MAX(t.arrete), 120) AS cle_ecran,
       MAX(t.entite)                                              AS dossier,
       MAX(CASE WHEN t.etape_ordre = 1 THEN t.message_court END)  AS collecte,
       MAX(CASE WHEN t.etape_ordre = 2 THEN t.message_court END)  AS revision,
       MAX(CASE WHEN t.etape_ordre = 3 THEN t.message_court END)  AS valorisation,
       MAX(CASE WHEN t.etape_ordre = 4 THEN t.message_court END)  AS arrete_etape,
       MAX(CASE WHEN t.etape_ordre = 5 THEN t.message_court END)  AS livrables,
       MAX(CASE WHEN t.en_cours = 1 THEN t.etape_libelle END)     AS etape_en_cours
FROM (SELECT v.*, CONCAT(v.fait, ' / ', v.total) AS message_court
      FROM dbo.v_ctx_avancement_etapes v) t;

GO

