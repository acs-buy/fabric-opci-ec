
CREATE VIEW dbo.v_ecran_colonne_libelle AS
SELECT
    CONCAT(l.vue, '|', l.colonne) AS cle_ecran,
    l.vue, l.colonne, l.libelle, l.libelle_court, l.aligne, l.format, l.ordre, l.visible,
    l.tri_rang, l.tri_sens,
    /* La colonne existe-t-elle encore dans la vue ? Un dictionnaire qui nomme une colonne
       disparue est une dette invisible, celle du 04/09/2026 est restee 5 jours. */
    CAST(CASE WHEN EXISTS (
            SELECT 1 FROM sys.columns sc
            JOIN sys.objects so ON so.object_id = sc.object_id
            WHERE so.name = l.vue AND sc.name = l.colonne)
         THEN 1 ELSE 0 END AS bit) AS colonne_existe
FROM dbo.ref_colonne_libelle l;

GO

